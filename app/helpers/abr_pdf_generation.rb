module AbrPdfGeneration

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
  
  def to_pdf_hash
    {
      :id =>  id,
      :uid  =>  uid,
      :locale => locale,
      :email_address => email_address,
      :us_citizen => us_citizen?,
      :will_be_18_by_election => will_be_18_by_election?,
      :home_zip_code => home_zip_code,
      :name_title_key => name_title_key,        
      :first_name => first_name,         
      :middle_name => middle_name,        
      :last_name => last_name,   
      :name_suffix_key => name_suffix_key,        
      :home_address => home_address,       
      :home_unit => home_unit,        
      :home_city => home_city,
      :home_state_id => home_state_abbrev,  
      :home_state_name => home_state && home_state.name,     
      :state_id_tooltip => state_id_tooltip,
      :has_mailing_address => has_mailing_address?,
      :mailing_address => mailing_address,    
      :mailing_unit => mailing_unit,      
      :mailing_city => mailing_city,       
      :mailing_state_id => mailing_state_abbrev,
      :mailing_zip_code => mailing_zip_code,
      :phone => phone,          
      :state_id_number => state_id_number,
      :prev_name_title_key => prev_name_title_key,    
      :prev_first_name => prev_first_name,    
      :prev_middle_name => prev_middle_name,   
      :prev_last_name => prev_last_name, 
      :prev_name_suffix_key => prev_name_suffix_key,
      :prev_address => prev_address,   
      :prev_unit => prev_unit,       
      :prev_city => prev_city,          
      :prev_state_id => prev_state_abbrev,
      :prev_zip_code => prev_zip_code,
      :partner_absolute_pdf_logo_path => partner_absolute_pdf_logo_path,
      :registration_instructions_url => registration_instructions_url,
      :home_state_pdf_instructions => home_state_pdf_instructions,
      :home_state_pdf_other_instructions => home_state_pdf_other_instructions,
      :state_registrar_address => state_registrar_address,
      :registration_deadline => registration_deadline,
      :party => party,
      :english_party_name => pdf_english_party_name,
      :pdf_english_race => pdf_english_race,
      :pdf_date_of_birth => pdf_date_of_birth,
      :pdf_barcode => pdf_barcode,
      pdf_assistant_info: pdf_assistant_info,
      :created_at => created_at.to_param
    }
  end
end