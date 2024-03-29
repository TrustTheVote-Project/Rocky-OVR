require 'rails_helper'

describe PdfRenderer do
  let(:r) { FactoryGirl.create(:maximal_registrant, :locale=>'es') }
  let(:pdfg) { PdfRenderer.new(r.pdf_writer) }
  
  describe "initialize(reg)" do
    it "sets locale" do
      pdfg.locale.should == r.locale
    end
    it "sets registrant" do
      pdfg.registrant.should == r.pdf_writer
    end
    it "sets logo_image_path" do
      pdfg.logo_image_path.should_not be_nil
    end
    it "calls set_registrant_instructions_link" do
      pdfg.registrant_instructions_link.should_not be_nil
    end
  end 
  
  describe "logo_image_path" do
    let(:default_path) { "file:///#{Rails.root.join('app/assets/images', RockyConf.pdf.nvra.page1.default_logo).to_s}"  }
    context "without a whitelabel partner" do
      it "returns the default path" do
        pdfg.logo_image_path.should == default_path
      end
    end
    context "with a whitelabel partner" do
      before(:each) do
        r.partner.stub(:whitelabeled?).and_return(true)
        r.partner.stub(:pdf_logo_present?).and_return(false)
      end
      it "returns the default path when pdf_logo isn't present" do
        pdfg.logo_image_path.should == default_path
      end
      context "when the pdf_logo is present" do
        before(:each) do
          r.partner.stub(:pdf_logo_present?).and_return(true)
          r.partner.stub(:absolute_pdf_logo_path).and_return"path"
        end
        it "returns the partner PDF logo" do
          pdfg.logo_image_path.should == "path"
        end
      end
    end
  end
  
  describe "set_registrant_instructions_link" do
    it "returns a link to the registrant's instruction URL with forced spacing" do
      pdfg.set_registrant_instructions_link.should == 
        "<br><a href=\"#{ERB::Util.html_escape(r.registration_instructions_url)}\">#{ERB::Util.html_escape(r.registration_instructions_url)}</a><br>"
    end
  end
  
  describe "render_to_string('registrants/registrant_pdf', :layout => 'layouts/nvra')" do
    let(:registrant) { FactoryGirl.create(:maximal_registrant, :home_zip_code=>"00501") }
    let(:pdfg) { PdfRenderer.new(registrant.pdf_writer) }
    let(:doc) { Nokogiri::XML(pdfg.render_to_string('registrants/registrant_pdf', :layout=>'layouts/nvra')) }
    
    before(:each) do
      z = ZipCodeCountyAddress.find_by_zip("00501")
      if z.nil?
        z = ZipCodeCountyAddress.new(zip: "00501")
      end
      z.address = "A Office\n542 Forbes Avenue\nSuite 609\nPittsburgh, LA 15219-2913"
      z.geo_state_id = GeoState["NY"].id
      z.save!
    end
    
    it "should use a custom address" do
      doc.css('#registrar_address').inner_html.should == "A Office<br>542 Forbes Avenue<br>Suite 609<br>Pittsburgh, LA 15219-2913"      
    end
  end
  
  describe "render_to_string('registrants/registrant_pdf', :layout => 'layouts/nvra')" do
    let(:registrant) { FactoryGirl.create(:maximal_registrant) }
    let(:pdfg) { PdfRenderer.new(registrant.pdf_writer) }
    let(:doc) { Nokogiri::XML(pdfg.render_to_string('registrants/registrant_pdf', :layout=>'layouts/nvra')) }
    

    
    it "should output us citizen" do
      assert_equal  registrant.us_citizen? ? 'Yes' : 'No',
                    doc.css('#us_citizen .value').inner_html
    end
    
    it "should output will be 18" do
      assert_equal  registrant.will_be_18_by_election? ? 'Yes' : 'No',
                    doc.css('#will_be_18_by_election .value').inner_html
    end

    it "should output name title" do
      assert_equal  registrant.name_title,
                    doc.css('#name_title .value .checkbox-checked span').inner_html
    end
    it "should output first name" do
      assert_equal  registrant.first_name,
                    doc.css('#name_first .value').inner_html
    end
    it "should output middle name" do
      assert_equal  registrant.middle_name,
                    doc.css('#name_middle .value').inner_html
    end
    it "should output last name" do
      assert_equal  registrant.last_name,
                    doc.css('#name_last .value').inner_html
    end
    it "should output name suffix" do
      assert_equal  registrant.name_suffix,
                    doc.css('#name_suffix .value .checkbox-checked span').inner_html
    end
    
    it "should output home address street" do
      assert_equal  CGI.escapeHTML(registrant.home_address),
                    doc.css('#home_address_street .value').inner_html
    end
    it "should output home address unit" do
      assert_equal  registrant.home_unit,
                    doc.css('#home_address_unit .value').inner_html
    end
    it "should output home address city" do
      assert_equal  CGI.escapeHTML(registrant.home_city),
                    doc.css('#home_address_city .value').inner_html
    end
    it "should output home address state" do
      assert_equal  registrant.home_state.abbreviation,
                    doc.css('#home_address_state .value').inner_html
    end
    it "should output home address zip code" do
      assert_equal  registrant.home_zip_code,
                    doc.css('#home_address_zip_code .value').inner_html
    end

    it "should output mailing address street" do
      assert_equal  "#{registrant.mailing_address} #{registrant.mailing_unit}",
                    doc.css('#mailing_address_street .value').inner_html
    end
    it "should output mailing address city" do
      assert_equal  registrant.mailing_city,
                    doc.css('#mailing_address_city .value').inner_html
    end
    it "should output mailing address state" do
      assert_equal  registrant.mailing_state.abbreviation,
                    doc.css('#mailing_address_state .value').inner_html
    end
    it "should output mailing address zip code" do
      assert_equal  registrant.mailing_zip_code,
                    doc.css('#mailing_address_zip_code .value').inner_html
    end

    it "should output date of birth" do
      assert_equal  registrant.pdf_date_of_birth,
                    doc.css('#date_of_birth .value').inner_html.gsub(/\s/, '')
    end
    it "should output phone" do
      assert_equal  registrant.phone,
                    doc.css('#phone_number .value').inner_html
    end
    it "should output state ID number" do
      assert_equal  registrant.state_id_number,
                    doc.css('#id_number .value').inner_html
    end
    it "should output party" do
      assert_equal  registrant.party.to_s,
                    doc.css('#party .value').inner_html.strip
    end
    
    it "should output previous name title" do
      assert_equal  registrant.prev_name_title,
                    doc.css('#prev_name_title .value .checkbox-checked span').inner_html
    end
    it "should output previous first name" do
      assert_equal  registrant.prev_first_name,
                    doc.css('#prev_name_first .value').inner_html
    end
    it "should output previous middle name" do
      assert_equal  registrant.prev_middle_name,
                    doc.css('#prev_name_middle .value').inner_html
    end
    it "should output previous last name" do
      assert_equal  registrant.prev_last_name,
                    doc.css('#prev_name_last .value').inner_html
    end
    it "should output previous name suffix" do
      assert_equal  registrant.prev_name_suffix,
                    doc.css('#prev_name_suffix .value .checkbox-checked span').inner_html
    end

    it "should output previous address street" do
      assert_equal  registrant.prev_address,
                    doc.css('#prev_address_street .value').inner_html
    end
    it "should output previous address unit" do
      assert_equal  registrant.prev_unit,
                    doc.css('#prev_address_unit .value').inner_html
    end
    it "should output previous address city" do
      assert_equal  registrant.prev_city,
                    doc.css('#prev_address_city .value').inner_html
    end
    it "should output previous address state" do
      assert_equal  registrant.prev_state.abbreviation,
                    doc.css('#prev_address_state .value').inner_html
    end
    it "should output previous address zip code" do
      assert_equal  registrant.prev_zip_code,
                    doc.css('#prev_address_zip_code .value').inner_html
    end
    
    describe "race" do
      it "should output race" do
        registrant.stub(:requires_race?) { true }
        pdfg = PdfRenderer.new(registrant)
        doc = Nokogiri::XML(pdfg.render_to_string('registrants/registrant_pdf', :layout=>'layouts/nvra'))

        assert_equal  registrant.race,
                      doc.css('#race .value').inner_html.strip
      end
      
      it "should not output race as decline to state" do
        registrant = FactoryGirl.create(:maximal_registrant, :race => "Decline to State")
        registrant.stub(:requires_race?) { true }
        pdfg = PdfRenderer.new(registrant) 
        doc = Nokogiri::XML(pdfg.render_to_string('registrants/registrant_pdf', :layout=>'layouts/nvra'))
        
        assert_equal  "",
                      doc.css('#race .value').inner_html.strip
      end
      it "should output race even if it is not required" do
        registrant = FactoryGirl.create(:maximal_registrant, :race => "Two or More Races")
        registrant.stub(:requires_race?) { false }
        pdfg = PdfRenderer.new(registrant) 
        doc = Nokogiri::XML(pdfg.render_to_string('registrants/registrant_pdf', :layout=>'layouts/nvra'))
        
        assert_equal  "Two or More Races",
                      doc.css('#race .value').inner_html.strip
      end
    end
    
    describe "barcode" do
      let(:registrant) { FactoryGirl.create(:maximal_registrant) }
      let(:pdfg) { PdfRenderer.new(registrant.pdf_writer) }
      before(:each) do
        registrant.id = 42_000_000
        doc = Nokogiri::XML(pdfg.render_to_string('registrants/registrant_pdf', :layout=>'layouts/nvra'))
      end
  
      it "generates ppp-nnnnnn barcode text" do
        assert_equal  "*RTV-0P07EO*", registrant.pdf_barcode
      end
  
      it "should output barcode text" do
        assert_equal  registrant.pdf_barcode,
                      doc.css('.pdf_barcode').inner_html
      end
    end
    
    
  end
  
end
