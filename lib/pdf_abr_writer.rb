class PdfAbrWriter
  include ActiveModel::AttributeMethods
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  include Lolrus

  attr_accessor :pdf_values
  attr_accessor :pdf_template_path
  
  attr_accessor :id, :uid, :locale, :created_at        
  
  def assign_attributes(values, options = {})
    self.pdf_values = values
    sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
      send("#{k}=", v) if self.respond_to?("#{k}=")      
    end
  end
  def generate_pdf(force_write = false, for_printer = false)
    if force_write || !pdf_exists?
      FileUtils.mkdir_p(pdf_file_dir)

      # 1. generate xfdf
      xfdf_contents = "<?xml version=\"1.0\"?><xfdf xmlns=\"http://ns.adobe.com/xfdf/\"><fields>"
      pdf_values.each do |k, v|
        xfdf_contents += "\n<field name=\"#{k}\"><value>#{v}</value></field>"
      end
      xfdf_contents += "</fields></xfdf>"
      
      File.open(pdf_xfdf_path, "w+") do |f|
        f.write xfdf_contents
      end
      `pdftk #{pdf_template_path.to_s} fill_form #{pdf_xfdf_path} output #{pdf_file_path} flatten`
      
      uploaded = nil
      if for_printer
        #uploaded = self.upload_pdf_to_printer(path, url_path)
      else
        uploaded = self.class.upload_pdf_to_s3(pdf_file_path, pdf_path)
      end
      # If it got there, delete the tmp file
      if uploaded
        File.delete(pdf_xfdf_path)
        File.delete(pdf_file_path)
      else
        raise "File #{path} not uploaded to #{for_printer ? 'Printer FTP site' : 'S3'}"
        # Handle failed upload to S3 - it's probably raising an error
      end      
    end
    # lets assume if there's no error raise, the file got generated (to limit FS operations)
    return true
  end

  def pdf_exists?
    File.exists?(pdf_file_path)
  end
  
  def to_param
    self.uid
  end

  def pdf_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}.pdf"
  end

  def xfdf_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}.xfdf"
  end


  def pdf_file_dir(pdfpre = nil)
    pdf_dir(pdfpre, false)
  end

  def pdf_dir(pdfpre = nil, url_format=true)
    if pdfpre
      "#{pdfpre}/#{bucket_code}"
    else
      # we're past this old format
      # if File.exists?(pdf_file_path("pdf"))
      #  "pdf/#{bucket_code}"
      # else
        "#{url_format ? '' : "public/"}pdfs/#{bucket_code}"
      # end
    end
  end

  def pdf_file_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, pdf_path(pdfpre, true))
  end

  def pdf_xfdf_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, xfdf_path(pdfpre, true))
  end

  def bucket_code
    super(DateTime.parse(self.created_at))
  end


  # def self.upload_pdf_to_printer(path, url_path)
  #   puts path
  #   return PdfDelivery.store_in_s3(path, url_path)
  #   #return PdfDelivery.transfer(path)
  # end
  
  def self.upload_pdf_to_s3(path, url_path)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    bucket_name = "rocky-pdfs#{Rails.env.production? ? '' : "-#{Rails.env}"}"
    directory = connection.directories.get(bucket_name)
    file = directory.files.create(
      :key    => url_path.gsub(/^\//,''),
      :body   => File.open(path).read,
      :content_type => "application/pdf",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => true
    ) 
  rescue Exception=>e
    #raise e
    return false   
  end
  
  private 
  
  # def pdf_date_of_birth_format
  #   if (/\A\d{1,2}\/\d{1,2}\/\d{2,4}\z/.match(self.pdf_date_of_birth))
  #     return true
  #   else
  #     errors.add(:pdf_date_of_birth, "Must be MM/DD/YYYY")
  #     return false
  #   end
  # end
  
end