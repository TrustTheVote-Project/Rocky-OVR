module AbrPdfMethods

  def queue_pdf
    klass = PdfAbrGeneration
    # if self.email_address.blank?
    #   klass = PriorityPdfGeneration
    # end
    klass.create!(:registrant_id=>self.id)
  end
  

  def pdf_file_path(pdfpre=nil)
    pdf_writer.pdf_file_path(pdfpre)
  end
  
  def pdf_url(pdfpre = nil, file=false)
   "http://rocky-pdfs#{Rails.env.production? ? '' : "-#{Rails.env}"}.s3-website-us-west-2.amazonaws.com#{pdf_path(pdfpre, file)}"
  end
  def pdf_path(pdfpre = nil, file=false)
    pdf_writer.pdf_path(pdfpre, file)
  end
  def pdf_download_path
    download_abr_path(self)
  end
  
  def pdf_file_dir(pdfpre = nil)
    pdf_writer.pdf_file_dir(pdfpre)
  end
  
  def pdf_template_name
    @pdf_template_name ||= RockyConf.absentee_states[home_state_abbrev]&.pdf_template
  end
  
  def state_pdf_url
    @state_pdf_url ||= RockyConf.absentee_states[home_state_abbrev]&.pdf_url
  end
  
  def has_pdf_template?
    !pdf_template_name.blank?
  end
  
  def pdf_template_path
    return nil unless has_pdf_template?
    abbrev = home_state_abbrev.downcase
    Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_name}")
  end

  def pdf_writer
    return nil unless has_pdf_template?
    if @pdf_writer.nil?
      @pdf_writer = PdfAbrWriter.new
      @pdf_writer.assign_attributes(self.to_pdf_hash)
      
      @pdf_writer.pdf_template_path = pdf_template_path
    end
    @pdf_writer
  end

  def generate_pdf(force = false)
    if pdf_writer.valid?
      if pdf_writer.generate_pdf(force)
        deliver_confirmation_email
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def finalize_pdf
    self.current_step = '4' # lets make sure this is set
    self.pdf_ready = true
    redact_sensitive_data
    save
  end
  
  
  def to_pdf_hash
    to_pdf_values.merge(    {
      :id =>  id,
      :uid  =>  uid,
      :locale => locale,
      :created_at => created_at.to_param
    })
  end
end