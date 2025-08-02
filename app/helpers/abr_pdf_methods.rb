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
   "https://download.#{RockyConf.pdf_host_name}#{pdf_path(pdfpre, file)}"
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
  
  def i18n_key
    unless @i18n_key
      RockyConf.absentee_states[home_state_abbrev].tap do |state_config|
        if state_config && state_config.cities 
          self.cities_from_zip.each do |c|
            begin
              @i18n_key = c.to_s.downcase.strip if state_config.cities[c.to_s.downcase.strip]
            rescue
            end
          end
          @i18n_key = self.city.to_s.downcase.strip if state_config.cities[self.city.to_s.downcase.strip]
        end
        if @i18n_key.blank?
          if state_config && state_config.counties && state_config.counties[self.county_from_zip.downcase]
            @i18n_key = self.county_from_zip.downcase
          end
        end
      end
      state_key = home_state_abbrev.downcase
      @i18n_key = @i18n_key.blank? ? state_key : "#{state_key}.#{@i18n_key}"
    end
    return @i18n_key
  end
  
  def pdf_template_name
    unless @pdf_template_name 
      RockyConf.absentee_states[home_state_abbrev].tap do |state_config|
        if state_config && state_config.cities 
          self.cities_from_zip.each do |c|
            begin
              @pdf_template_name ||= state_config.cities[c.to_s.downcase.strip]&.pdf_template
            rescue
            end
          end
          @pdf_template_name ||= state_config.cities[self.city.to_s.downcase.strip]&.pdf_template
        end
        if @pdf_template_name.blank?
          if state_config && state_config.counties && state_config.counties[self.county_from_zip.downcase]
            @pdf_template_name = state_config.counties[self.county_from_zip.downcase].pdf_template
          end
          if !oabr_url_is_local_jurisdiction?
            @pdf_template_name ||= state_config&.pdf_template
          end
        end
      end
    end
    @pdf_template_name
  end
  
  def state_pdf_url
    unless @state_pdf_url 
      RockyConf.absentee_states[home_state_abbrev].tap do |state_config|
        if state_config && state_config.cities 
          self.cities_from_zip.each do |c|
            begin
              @state_pdf_url ||= state_config.cities[c.to_s.downcase.strip]&.pdf_url
            rescue
            end
          end
          @state_pdf_url ||= state_config.cities[self.city.to_s.downcase.strip]&.pdf_url
        end
        if @state_pdf_url.blank?
          if state_config && state_config.counties && state_config.counties[self.county_from_zip.downcase]
            @state_pdf_url = state_config.counties[self.county_from_zip.downcase].pdf_url
          end
          if !oabr_url_is_local_jurisdiction?
            @state_pdf_url ||= state_config&.pdf_url 
          end
        end
      end
    end
    @state_pdf_url
  end
  
  def has_pdf_template?
    !pdf_template_name.blank? && home_state&.abr_pdf_enabled
  end
  
  def has_state_pdf_url?
    !state_pdf_url.blank?
  end
  
  def pdf_template_path
    return nil unless has_pdf_template?
    abbrev = home_state_abbrev.downcase
    Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_name}")
  end

  def pdf_template_with_cover_filename
    pdf_template_name.gsub(/\.pdf\z/, '_with_cover.pdf')
  end

  def pdf_template_with_cover_path
    return nil unless has_pdf_template?
    abbrev = home_state_abbrev.downcase
    Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_with_cover_filename}")
  end

  def pdf_writer
    return nil unless has_pdf_template?
    if @pdf_writer.nil?
      @pdf_writer = PdfAbrWriter.new
      @pdf_writer.assign_attributes(self.to_pdf_hash)
      @pdf_writer.pdf_cover_values = make_cover_fields_hash 
      
      @pdf_writer.pdf_template_path = pdf_template_path
      @pdf_writer.pdf_template_with_cover_path = pdf_template_with_cover_path
      @pdf_writer.voter_signature = voter_signature
      @pdf_writer.signature_pdf_field_name = signature_pdf_field_name
      @pdf_writer.deliver_to_elections_office_via_email = deliver_to_elections_office_via_email?
    end
    @pdf_writer
  end

  def generate_pdf(force = false)
    if pdf_writer && pdf_writer.valid?
      if pdf_writer.generate_pdf(true || force)
        if deliver_to_elections_office_via_email?
          deliver_to_elections_office
        else
          deliver_confirmation_email
        end
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
    save(validate: false)
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