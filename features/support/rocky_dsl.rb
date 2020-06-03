require 'webmock'

module RockyDsl
  
  def stub_bulk_process
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v3/registrations/bulk.json}).to_return do |req|
      json = JSON.parse(req.body).deep_symbolize_keys
      r = {:body=>{
        :registrants_added=>V3::RegistrationService.bulk_create(json[:registrants], json[:partner_id], json[:partner_API_key])
      }.to_json}
      r
    end
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v4/registrations/bulk.json}).to_return do |req|
      json = JSON.parse(req.body).deep_symbolize_keys
      r = {:body=>{
        :registrants_added=>V4::RegistrationService.bulk_create(json[:registrants], json[:partner_id], json[:partner_API_key])
      }.to_json}
      r
    end
    
  end
  
  def stub_partners
    Partner.any_instance.stub(:valid_api_key?).and_return(true)
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v3/partners/\d+\.json}).to_return do |req|
      req.uri.to_s =~ /(\d+)\.json(\?.+)?$/
      id = $1
      {:body=>{:partner => V3::PartnerService.find({:partner_id=>id, :partner_api_key=>'abc123'}) }.to_json}
    end
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v4/partners/\d+\.json}).to_return do |req|
      req.uri.to_s =~ /(\d+)\.json(\?.+)?$/
      id = $1
      {:body=>{:partner => V4::PartnerService.find({:partner_id=>id, :partner_api_key=>'abc123'}) }.to_json}
    end
    PartnerAssetsFolder.any_instance.stub(:directory).and_return(FakeS3.new)
  end
  def stub_registrant_creation_via_api
    
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v3/registrations.json}).to_return do |req|
      begin
        params = JSON.parse(req.body).deep_symbolize_keys
        r = V3::RegistrationService.create_record(params[:registration])
        # Also RUN the pdfgen
        PdfGeneration.find_and_generate
        {:body=>{:pdfurl=>"https://#{RockyConf.pdf_host_name}#{r.pdf_download_path}", :uid=>r.uid}.to_json}
      rescue V3::RegistrationService::ValidationError => e
        raise({ :field_name => e.field, :message => e.message , :status => 400}.to_s)
      rescue V3::RegistrationService::SurveyQuestionError => e
        raise({:message => e.message, :status=>400}.to_s)
      rescue V3::UnsupportedLanguageError => e
        raise({ :message => e.message , :status => 400}.to_s)
      rescue ActiveRecord::UnknownAttributeError => e
        name = e.attribute
        raise({ :field_name => name, :message => "Invalid parameter type", :status => 400}.to_s)
      end
    end
    WebMock.stub_request(:any, %r{http://example-api\.com/api/v4/registrations.json}).to_return do |req|
      begin
        params = JSON.parse(req.body).deep_symbolize_keys
        r = V4::RegistrationService.create_record(params[:registration])
        # Also RUN the pdfgen
        PdfGeneration.find_and_generate
        {:body=>{:pdfurl=>"https://#{RockyConf.pdf_host_name}#{r.pdf_download_path}", :uid=>r.uid}.to_json}
      rescue V4::RegistrationService::ValidationError => e
        raise({ :field_name => e.field, :message => e.message , :status => 400}.to_s)
      rescue V4::RegistrationService::SurveyQuestionError => e
        raise({:message => e.message, :status=>400}.to_s)
      rescue V4::UnsupportedLanguageError => e
        raise({ :message => e.message , :status => 400}.to_s)
      rescue ActiveRecord::UnknownAttributeError => e
        name = e.attribute
        raise({ :field_name => name, :message => "Invalid parameter type", :status => 400}.to_s)
      end
    end
    Registrant.any_instance.stub(:pdf_ready?).and_return(true)
  end
  def stub_ca_disclosures
    WebMock.stub_request(:get, %r{https://a8e83b219df9c88311b3-01fbb794ac405944f26ec8749fe8fe7b.ssl.cf1.rackcdn.com/discl/.+/discl.+.txt}).to_return do |req|
      req.uri.to_s =~ /discl\/(.+)\/discl(.+)\.txt/
      lang = $1
      num = $2
      {:body=>"#{lang} disclosure number #{num}"}
    end
 end

end


World(RockyDsl)