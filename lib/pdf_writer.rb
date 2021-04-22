class PdfWriter
  include ActiveModel::AttributeMethods
  #include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations
  
  include Lolrus
  
  #registrant data values
  attr_accessor :id, :uid, :locale,
        :email_address,
        :us_citizen,  
        :will_be_18_by_election,
        :home_zip_code,
        :name_title,      
        :name_title_key,        
        :first_name,         
        :middle_name,        
        :last_name,   
        :name_suffix,    
        :name_suffix_key,        
        :home_address,       
        :home_unit,        
        :home_city,
        :home_state_id,  
        :home_state_name,  
        :state_id_tooltip,
        :has_mailing_address,
        :mailing_address,    
        :mailing_unit,      
        :mailing_city,       
        :mailing_state_id,
        :mailing_zip_code,   
        :phone,       
        :party,   
        :state_id_number,
        :prev_name_title,
        :prev_name_title_key,    
        :prev_first_name,    
        :prev_middle_name,   
        :prev_last_name, 
        :prev_name_suffix,  
        :prev_name_suffix_key,
        :prev_address,   
        :prev_unit,       
        :prev_city,          
        :prev_state_id,
        :prev_zip_code
        
        
  # computed registrant values
  attr_accessor :partner_absolute_pdf_logo_path,
      :registration_instructions_url,
      :home_state_pdf_instructions,
      :home_state_pdf_other_instructions,
      :state_registrar_address,
      :registration_deadline,
      :english_party_name,
      :pdf_english_race,
      :pdf_date_of_birth,
      :pdf_barcode,
      :created_at,
      :pdf_assistant_info,
      :voter_signature_image,
      :signed_at_month,
      :signed_at_day,
      :signed_at_year
      
  validates_presence_of :id, :uid, :home_state_id, :pdf_barcode, :locale, :registration_instructions_url, :state_registrar_address, :registration_deadline, :pdf_date_of_birth, :created_at
  validate :pdf_date_of_birth_format
  
  def us_citizen?
    self.us_citizen == true
  end

  def will_be_18_by_election?
    self.will_be_18_by_election == true
  end
  
  def yes_no(attribute)
    attribute ? "Yes" : "No"
  end

  def method_missing(sym, *args)
    if sym.to_s =~ /\Ayes_no_(.+)\z/
      attribute = $1
      return self.send(:yes_no, (self.send(attribute)))
    else
      super
    end
  end

  def pdf_date_of_birth_month
    pdf_date_of_birth.split('/')[0]
  end
  def pdf_date_of_birth_day
    pdf_date_of_birth.split('/')[1]
  end
  def pdf_date_of_birth_year
    pdf_date_of_birth.split('/')[2]
  end

  def assign_attributes(values, options = {})
    values.each do |k,v|
      send("#{k}=", v) if self.respond_to?("#{k}=")
    end
    # sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
    #   send("#{k}=", v)
    # end
  end


  def registrant_to_html_string(for_printer = false)
    return false if self.locale.blank? || self.home_state_id.blank?
    prev_locale = I18n.locale


    I18n.locale = self.locale
    renderer = PdfRenderer.new(self, for_printer)

    html_string = renderer.render(
      'registrants/registrant_pdf', 
      :layout => 'layouts/nvra',
      :encoding => 'utf8',
      :locale=>self.locale
    )
    I18n.locale = prev_locale
    puts html_string
    return html_string    
  end

  def generate_html(force_write = false)
    html_string = registrant_to_html_string
    return false if !html_string

    if force_write || !html_exists?
      PdfWriter.write_html_from_html_string(html_string, html_file_dir, html_file_path)
    end

    return true
  end
  
  def self.write_html_from_html_string(html_string, dir, path)
    FileUtils.mkdir_p(dir)
    File.open(path, "w") do |f|
      f << html_string.force_encoding('UTF-8')
    end
  end

  def generate_pdf(force_write = false, for_printer = false, esigned = false, date = nil)
    html_string = registrant_to_html_string(for_printer)
    return false if !html_string

    if force_write || !pdf_exists?
      PdfWriter.write_pdf_from_html_string(html_string, pdf_file_path, self.locale, pdf_file_dir, pdf_path, for_printer, esigned, date)
    end
    # lets assume if there's no error raise, the file got generated (to limit FS operations)
    return true
  end

  def pdf_exists?
    File.exists?(pdf_file_path)
  end
  
  def html_exists?
    File.exists?(html_file_path)
  end


  def to_param
    self.uid
  end

  def html_path(pdfpre = nil, file=false)
    pdf_path(pdfpre, file).gsub(/\.pdf$/,'.html')
  end
  def pdf_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}.pdf"
  end

  def html_file_dir(pdfpre = nil)
    pdf_file_dir(pdfpre)
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

  def html_file_path(pdfpre = nil)
    dir = File.join(Rails.root, html_file_dir(pdfpre))
    File.join(Rails.root, html_path(pdfpre, true))
  end
  def pdf_file_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, pdf_path(pdfpre, true))
  end


  def bucket_code
    super(DateTime.parse(self.created_at))
  end



  def self.write_pdf_from_html_string(html_string, path, locale, pdf_file_dir, url_path, for_printer=false, esigned=false, date=nil)
    pdf = WickedPdf.new.pdf_from_string(
      html_string,
      :disable_internal_links         => false,
      :disable_external_links         => false,
      :encoding => 'utf8',
      :locale=>locale,
      :page_size => locale.to_s == "en" ? "Letter" : "A4"
    )
    FileUtils.mkdir_p(pdf_file_dir)
    File.open(path, "w") do |f|
      f << pdf.force_encoding('UTF-8')
    end
    # And then upload it to s3
    uploaded = nil
    if for_printer
      redacted = !esigned
      uploaded = self.upload_pdf_to_printer(path, url_path, redacted, date)
    else
      uploaded = self.upload_pdf_to_s3(path, url_path)
    end
    # If it got there, delete the tmp file
    if uploaded
      File.delete(path)
    else
      raise "File #{path} not uploaded to #{for_printer ? 'Printer FTP site' : 'S3'}"
      # Handle failed upload to S3 - it's probably raising an error
    end
  end   
  
  def self.upload_pdf_to_printer(path, url_path, redacted, date)
    return PdfDelivery.store_in_s3(path, url_path, redacted, date)
    #return PdfDelivery.transfer(path)
  end
  
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
    return false   
  end
  
  private 
  
  def pdf_date_of_birth_format
    if (/\A\d{1,2}\/\d{1,2}\/\d{2,4}\z/.match(self.pdf_date_of_birth))
      return true
    else
      errors.add(:pdf_date_of_birth, "Must be MM/DD/YYYY")
      return false
    end
  end
  
end