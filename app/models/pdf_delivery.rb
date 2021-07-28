require 'net/ftp'
class PdfDelivery < ActiveRecord::Base
  
  belongs_to :registrant, optional: true
  
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
