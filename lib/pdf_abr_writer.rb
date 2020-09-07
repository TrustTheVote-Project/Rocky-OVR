class PdfAbrWriter
  include ActiveModel::AttributeMethods
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  include Lolrus

  attr_accessor :pdf_values
  attr_accessor :pdf_template_path
  attr_accessor :delivery_address
  attr_accessor :voter_signature
  attr_accessor :signature_field_name
  attr_accessor :deliver_to_elections_office_via_email

  def deliver_to_elections_office_via_email?
    deliver_to_elections_office_via_email
  end
  
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

      if voter_signature && !voter_signature.voter_signature_image.blank?
        voter_signature.save_file(pdf_signature_image_path)
        form = FormFiller::Form.new(template: pdf_template_path.to_s)
        signer = FormFiller::Signer.new({
          form: form,
          signature: pdf_signature_image_path,
          sig_field: self.signature_field_name
        })
        signer.sign
        form.save_as(pdf_file_path, flatten: false)
      end

      
      unless deliver_to_elections_office_via_email?
        # Temp solution for making sure every PDF includes address
        html_string = "Sign and return this form to:<br/><br/><p style='font-size: 24px; line-height: 1.6em;'>#{delivery_address}</p>"
        #0. generate address pdf
        pdf = WickedPdf.new.pdf_from_string(
          html_string,
          :disable_internal_links         => false,
          :disable_external_links         => false,
          :encoding => 'utf8',
          :locale=>locale,
          :page_size => locale.to_s == "en" ? "Letter" : "A4"
        )

        File.open(pdf_delivery_address_path, "w") do |f|
          f << pdf.force_encoding('UTF-8')
        end
      end

      # 1. generate xfdf
      xfdf_contents = "<?xml version=\"1.0\"?><xfdf xmlns=\"http://ns.adobe.com/xfdf/\"><fields>"
      pdf_values.each do |k, v|
        xfdf_contents += "\n<field name=\"#{k}\"><value>#{v}</value></field>"
      end
      xfdf_contents += "</fields></xfdf>"
      
      File.open(pdf_xfdf_path, "w+") do |f|
        f.write xfdf_contents
      end
      if deliver_to_elections_office_via_email?
        `pdftk #{(!voter_signature&.voter_signature_image.blank? ? pdf_file_path : pdf_template_path).to_s} fill_form #{pdf_xfdf_path} output #{pdf_file_path}-tmp flatten`
        `cp #{pdf_file_path}-tmp #{pdf_file_path}`
      else
        `pdftk #{(!voter_signature&.voter_signature_image ? pdf_file_path : pdf_template_path).to_s} fill_form #{pdf_xfdf_path} output #{pdf_file_path}-tmp flatten`
        `pdftk #{pdf_delivery_address_path} #{pdf_file_path}-tmp output #{pdf_file_path}`
      end
      uploaded = nil
      if for_printer
        #uploaded = self.upload_pdf_to_printer(path, url_path)
      else
        uploaded = self.class.upload_pdf_to_s3(pdf_file_path, pdf_path)
      end
      # If it got there, delete the tmp file
      if uploaded
        unless Rails.env.development?
          File.delete(pdf_signature_image_path) if File.exists?(pdf_signature_image_path)
          File.delete(pdf_xfdf_path) if File.exists?(pdf_xfdf_path)
          File.delete(pdf_file_path) if File.exists?(pdf_file_path)
          File.delete("#{pdf_file_path}-tmp") if File.exists?("#{pdf_file_path}-tmp")
          File.delete(pdf_delivery_address_path) if File.exists?((pdf_delivery_address_path))
        end
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

  def signature_image_path(pdfpre = ni, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}-sig.jpg"
  end

  def pdf_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}.pdf"
  end

  def xfdf_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}.xfdf"
  end
  
  def delivery_address_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}-address.pdf"
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

  def pdf_signature_image_path(pdfpre=nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, signature_image_path(pdfpre, true))
  end

  def pdf_file_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, pdf_path(pdfpre, true))
  end

  def pdf_xfdf_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, xfdf_path(pdfpre, true))
  end
  
  def pdf_delivery_address_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, delivery_address_path(pdfpre, true))
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