require 'net/ftp'
class PdfDelivery < ActiveRecord::Base
  
  def self.compile_for_date(date = Date.yesterday)
    date_string = date.strftime("%Y-%m-%d")
    deliveries = PdfDelivery.where("created_at >= ? AND created_at < ?", date.beginning_of_day, (date + 1.day).beginning_of_day).includes(:registrant=>[{:home_state=>[:localizations]}, {:mailing_state=>[:localizations]}, :voter_signature])
    folder = Rails.root.join("tmp", "deliveries", date_string)
    assistance_rows = [CSV_HEADER]
    relative_assistance_folder = "assistance"
    assistance_folder = File.join(folder, relative_assistance_folder)
    direct_mail_rows = [CSV_HEADER]
    relative_direct_folder = "direct"
    direct_folder = File.join(folder, relative_direct_folder)
    FileUtils.mkdir_p(assistance_folder)
    FileUtils.mkdir_p(direct_folder)
    deliveries.find_in_batches(batch_size: 500) do |batch|
      batch.each do |d|
        fname = "#{date_string}_#{d.registrant.first_name}_#{d.registrant.last_name}_#{d.registrant.uid}.pdf"
        fpath = nil
        row = self.csv_row(d)
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
    # Zip up files
    `cd #{folder} && zip -r assistance.zip #{relative_assistance_folder}`
    `rm -rf #{assistance_folder}`
    `cd #{folder} && zip -r direct_mail.zip #{relative_direct_folder}`
    `rm -rf #{direct_folder}`
    CSV.open(File.join(folder, "assistance.csv"), "w+") do |csv|
      assistance_rows.each do |row|
        csv << row
      end
    end
    CSV.open(File.join(folder, "direct_mail.csv"), "w+") do |csv|
      direct_mail_rows.each do |row|
        csv << row
      end
    end
    # Upload 2 zips and 2 CSVs to s3.
    upload_file(date_string, folder, "assistance.zip")
    upload_file(date_string, folder, "assistance.csv")
    upload_file(date_string, folder, "direct_mail.zip")
    upload_file(date_string, folder, "direct_mail.csv")
  end

  def self.s3_connection
    @@connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })    
  end
  
  def self.directory
    @@directory ||= s3_connection.directories.get('rocky-report-objects')    
  end
  
  def self.s3_key(date_string, fn)
    "#{Rails.env}/deliveries/#{date_string}/#{fn}"
  end
  
  def self.upload_file(date_string, folder, file)
    local_path = File.join(folder, file)
    directory.files.create(
      :key    => s3_key(date_string, file),
      :body   => File.read(local_path),
      :content_type => file.ends_with?(".csv") ? "text/csv" : "application/zip",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => false
    )
  end



  CSV_HEADER = [
    "Request Date/Time",
    "First Name",
    "Last Name",
    "Email",
    "UID",
    "Partner ID",
    "Registration Address 1",
    "Registration Address 2",
    "Registration City",
    "Registration State",
    "Registration ZIP",
    "Registrant Mailing Address 1",
    "Registrant Mailing Address 2",
    "Registrant Mailing City",
    "Registrant Mailing State",
    "Registrant Mailing ZIP",
    "Elections Office Address 1",
    "Elections Office Address 2",
    "Elections Office Address 3",
    "Elections Office Address 4",
    "Elections Office Address 5",
    "Elections Office Address 6",
    "Elections Office Address 7"    
  ]

  def self.csv_row(delivery) 
    r = delivery.registrant
    [ 
      delivery.created_at,
      r.first_name,
      r.last_name,
      r.email_address,
      r.uid,
      r.partner_id,
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

  belongs_to :registrant
  
  def generate_pdf!
    generate_pdf(true)
  end
  
  def generate_pdf(force = false)
    if registrant.pdf_writer.valid?
      if registrant.pdf_writer.generate_pdf(force, true, registrant.pdf_is_esigned?, created_at)
        registrant.deliver_confirmation_email
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def finalize_pdf
    self.pdf_ready = true
    save(validate: false)
  end
  
  def pdf_prefix
    self.class.pdf_prefix(!registrant.pdf_is_esigned?, created_at)
  end
  
  def self.pdf_prefix(redacted, date)
    prefix = redacted ? "redacted" : "signed"
    date_stamp = date.strftime("%Y-%m-%d")
    "#{prefix}/#{date_stamp}"
  end
  
  
  def self.store_in_s3(path, url_path, date, redacted=true)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    bucket_name = "rocky-pdfs#{Rails.env.production? ? '' : "-#{Rails.env}"}"
    directory = connection.directories.get(bucket_name)
    file = directory.files.create(
      :key    => "#{pdf_prefix(date, redacted)}/#{url_path.gsub(/^\//,'')}",
      :body   => File.open(path).read,
      :content_type => "application/pdf",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => true
    ) 
  rescue Exception=>e
    raise e
    
    return false   
  end
  
  
end
