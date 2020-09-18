class PdfDeliveryReport < ActiveRecord::Base
  
  CSV_HEADER = [
    "Request Date/Time",
    "First Name",
    "Last Name",
    "Email",
    "Phone",
    "DOB",
    "UID",
    "Partner ID",
    "Partner Org Name",
    "Registration Address 1",
    "Registration Address 2",
    "Registration City",
    "Registration State",
    "Registration ZIP",
    "Envelope Address 1",
    "Envelope Address 2",
    "Envelope City",
    "Envelope State",
    "Envelope ZIP",
    "Elections Office Address 1",
    "Elections Office Address 2",
    "Elections Office Address 3",
    "Elections Office Address 4",
    "Elections Office Address 5",
    "Elections Office Address 6",
    "Elections Office Address 7"    
  ]
    
  def self.compile_for_date(date = Date.yesterday)
    r = self.new(date: date, status: :queued)
    r.save!
    r.delay.run!
  end
  
  def folder
    @folder ||= Rails.root.join("tmp", "deliveries", date_string)
  end

  def date_string
    unless date
      self.date ||= Date.yesterday
    end
    @date_string ||= date.strftime("%Y-%m-%d")    
  end

  def relative_assistance_folder
    "#{date_string}_assistance"
  end

  def assistance_folder
    @assistance_folder ||= File.join(folder, relative_assistance_folder)
  end

  def relative_direct_folder
    "#{date_string}_direct"
  end
  def direct_folder 
    @direct_folder ||= File.join(folder, relative_direct_folder)
  end
    
  def pdf_name(d)
    "#{date_string}_#{d.registrant.first_name}_#{d.registrant.last_name}_#{d.registrant.uid}.pdf"
  end

  def assistance_zip_file_name
    "#{date_string}_assistance.zip"
  end
  def assistance_csv_file_name
    "#{date_string}_assistance.csv"
  end

  def direct_zip_file_name
    "#{date_string}_direct_mail.zip"
  end
  def direct_csv_file_name
    "#{date_string}_direct_mail.csv"
  end

  def run!
    self.update_attributes(status: :started)
    deliveries = PdfDelivery.where(pdf_ready: true).where("created_at >= ? AND created_at < ?", date.beginning_of_day, (date + 1.day).beginning_of_day).includes(:registrant=>[{:home_state=>[:localizations]}, {:mailing_state=>[:localizations]}, :voter_signature, :partner])
    self.update_attributes(status: "Processing #{deliveries.count} deliveries")
    assistance_rows = [CSV_HEADER]
    direct_mail_rows = [CSV_HEADER]
    FileUtils.mkdir_p(assistance_folder)
    FileUtils.mkdir_p(direct_folder)
    deliveries.find_in_batches(batch_size: 500).with_index do |batch, batch_num|
      self.update_attributes(status: "Processing Batch Num #{batch_num + 1}")
      batch.each do |d|
        fname = pdf_name(d)
        fpath = nil
        row = csv_row(d)
        if d.registrant.pdf_is_esigned?
          # direct mail
          direct_mail_rows << row
          fpath = File.join(direct_folder, fname)
        else
          # assistance mail
          assistance_rows << row
          fpath = File.join(assistance_folder, fname)
        end
        File.open(fpath, "wb+") do |f|
          f.write open(d.registrant.pdf_url).read
        end
      end
    end
    # save counts
    self.update_attributes({
      assistance_registrants: assistance_rows.length - 1,
      direct_mail_registrants: direct_mail_rows.length - 1
    })
    self.update_attributes(status: :compiling)
    # Zip up files
    `cd #{folder} && zip -r #{assistance_zip_file_name} #{relative_assistance_folder}`
    `rm -rf #{assistance_folder}`
    `cd #{folder} && zip -r #{direct_zip_file_name} #{relative_direct_folder}`
    `rm -rf #{direct_folder}`
    CSV.open(File.join(folder, "#{assistance_csv_file_name}"), "w+") do |csv|
      assistance_rows.each do |row|
        csv << row
      end
    end
    CSV.open(File.join(folder, "#{direct_csv_file_name}"), "w+") do |csv|
      direct_mail_rows.each do |row|
        csv << row
      end
    end
    self.update_attributes(status: :uploading)
    
    # Upload 2 zips and 2 CSVs to s3.
    upload_file(assistance_zip_file_name)
    upload_file(assistance_csv_file_name)
    upload_file(direct_zip_file_name)
    upload_file(direct_csv_file_name)
    # cleanup
    `rm -rf #{folder}`
    self.update_attributes(status: :complete)
  rescue Exception => e
    self.update_attributes(last_error: "#{e.message}\n#{e.backtrace}")
  end

  def csv_row(delivery) 
    r = delivery.registrant
    [ 
      delivery.created_at,
      r.first_name,
      r.last_name,
      r.email_address,
      r.phone,
      r.pdf_date_of_birth,
      r.uid,
      r.partner_id,
      r.partner&.organization,
      r.home_address,
      r.home_unit,
      r.home_city,
      r.home_state_abbrev,
      r.home_zip_code,
      r.has_mailing_address? ? r.mailing_address : r.home_address,
      r.has_mailing_address? ? r.mailing_unit : r.home_unit,
      r.has_mailing_address? ? r.mailing_city : r.home_city,
      r.has_mailing_address? ? r.mailing_state_abbrev : r.home_state_abbrev,
      r.has_mailing_address? ? r.mailing_zip_code : r.home_zip_code,      
    ] + r.state_registrar_address.split(/<br\/?>/)
  end


  def s3_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })    
  end
  
  def directory
    @@directory ||= s3_connection.directories.get('rocky-report-objects')    
  end
  
  def s3_key(fn)
    "#{Rails.env}/deliveries/#{date_string}/#{fn}"
  end
  
  def upload_file(file)
    local_path = File.join(folder, file)
    directory.files.create(
      :key    => s3_key(file),
      :body   => File.read(local_path),
      :content_type => file.ends_with?(".csv") ? "text/csv" : "application/zip",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => false
    )
  end

  def read_file(fn)
    file = directory.files.get(s3_key(fn))
    return file.body
  end



end
