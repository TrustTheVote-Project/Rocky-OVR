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
  
  

  def pdf_writer
    if @pdf_writer.nil?
      @pdf_writer = PdfAbrWriter.new
      @pdf_writer.assign_attributes(self.to_pdf_hash)
      abbrev = home_state_abbrev.downcase
      @pdf_writer.pdf_template_path = Rails.root.join("data/abr_pdfs/#{abbrev}/#{abbrev}.pdf")
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