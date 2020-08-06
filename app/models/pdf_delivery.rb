require 'net/ftp'
class PdfDelivery < ActiveRecord::Base
  
  belongs_to :registrant
  
  def generate_pdf!
    generate_pdf(true)
  end
  
  def generate_pdf(force = false)
    if registrant.pdf_writer.valid?
      if registrant.pdf_writer.generate_pdf(force, true, registrant.pdf_is_esigned?)
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
  
  
  def self.store_in_s3(path, url_path, redacted=true)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    prefix_key = redacted ? "redacted" : "signed"
    bucket_name = "rocky-pdfs#{Rails.env.production? ? '' : "-#{Rails.env}"}"
    directory = connection.directories.get(bucket_name)
    date_stamp = Date.today.strftime("%Y-%m-%d")
    file = directory.files.create(
      :key    => "#{prefix_key}/#{date_stamp}/#{url_path.gsub(/^\//,'')}",
      :body   => File.open(path).read,
      :content_type => "application/pdf",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => true
    ) 
  rescue Exception=>e
    raise e
    
    return false   
  end
  
  def self.to_csv_string
    return CSV.generate do |csv|
      first = true
      self.all.includes({:registrant=>[:home_state, :mailing_state, :partner, :registrant_status]}).find_each do |d|
        pdf_hash = d.registrant.to_pdf_hash
        pdf_hash.delete(:state_id_number)
        pdf_hash.delete(:state_id_tooltip)
        pdf_hash.delete(:voter_signature_image)
        pdf_hash.delete(:signed_at_month)
        pdf_hash.delete(:signed_at_year)
        pdf_hash.delete(:signed_at_day)
        registrar_address = pdf_hash.delete(:state_registrar_address)
        if first
          csv << pdf_hash.keys + [
            :state_registrar_address_1,
            :state_registrar_address_2,
            :state_registrar_address_3,
            :state_registrar_address_4,
            :state_registrar_address_5,
            :state_registrar_address_6,
            :state_registrar_address_7,
          ]
          first = false
        end
        csv << pdf_hash.values + registrar_address.split(/<br\/?>/)
        
      end
    end
  end
  
  
  # URL is ftp.garnerprint.com
  # User name:whenwevote
  # Password: redfq86#
  def self.transfer(local_path)
    #file_name = 
    
    port = 21
    ftp = Net::FTP.new  # don't pass hostname or it will try open on default port
    ftp.connect('ftp.garnerprint.com', port)  # here you can pass a non-standard port number
    ftp.passive = true
    ftp.login('whenwevote', 'redfq86#')
    files = ftp.list('*')
    puts files
    ftp.close
    
    # Net::FTP.open('ftp.garnerprint.com') do |ftp|
    #   ftp.login('whenwevote', 'redfq86#')
    #   files = ftp.list('*')
    #   puts files
    #   #ftp.getbinaryfile('nif.rb-0.91.gz', 'nif.gz', 1024)
    # end
    
    
  end
  
end
