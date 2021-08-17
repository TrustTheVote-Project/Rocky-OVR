class PdfRenderer < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Rendering
  include Rails.application.routes.url_helpers
  include WickedPdf::WickedPdfHelper
  include WickedPdf::WickedPdfHelper::Assets
  helper ApplicationHelper
  helper PdfRendererHelper
  
  helper_method :wicked_pdf_image_tag, :image_tag, :wicked_pdf_asset_base64, :wicked_pdf_stylesheet_link_tag

  self.view_paths = "app/views"
  
  attr_accessor :registrant, :state, :logo_image_tag, :locale, :registrant_instructions_link
  
  def initialize(registrant, for_printer = false)
    super()
    @for_printer = for_printer
    @esign = !registrant.voter_signature_image.blank?
    @locale =registrant.locale
    @registrant=registrant
    @logo_image_path = self.logo_image_path
    @state_esign_logo_path = self.state_esign_logo_path
    @rtv_esign_logo_path = self.rtv_esign_logo_path
    set_registrant_instructions_link
  end
  
  def logo_image_path
    if !@registrant.partner_absolute_pdf_logo_path.blank?
      @registrant.partner_absolute_pdf_logo_path
    else
      "file:///#{Rails.root.join('app/assets/images', RockyConf.pdf.nvra.page1.default_logo).to_s}" 
    end
  end

  def state_esign_logo_path
    "file:///#{Rails.root.join("app/assets/images/pdf/esign/{@registrant.home_state_abbrev.downcase}.png").to_s}"     
  end

  def rtv_esign_logo_path
    "file:///#{Rails.root.join('app/assets/images/pdf/esign/rtv.png').to_s}" 
  end
  
  def set_registrant_instructions_link
    url = self.registrant.registration_instructions_url
    if !url.blank?
      @registrant_instructions_link = "<br>" + link_to(url, url) + "<br>"
    else
      @registrant_instructions_link = ''
    end
  end
  
  
  
end