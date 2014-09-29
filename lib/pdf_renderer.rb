class PdfRenderer < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  include WickedPdfHelper
  include WickedPdfHelper::Assets
  helper ApplicationHelper
  helper PdfRendererHelper
  
  
  self.view_paths = "app/views"
  
  attr_accessor :registrant, :state, :logo_image_tag, :locale, :registrant_instructions_link
  
  def initialize(registrant)
    super()
    @locale =registrant.locale
    @registrant=registrant
    @logo_image_path = self.logo_image_path
    set_registrant_instructions_link
  end
  
  def logo_image_path
    if !@registrant.partner_absolute_pdf_logo_path.blank?
      @registrant.partner_absolute_pdf_logo_path
    else
      "file:///#{Rails.root.join('app/assets/images', RockyConf.pdf.nvra.page1.default_logo).to_s}" 
    end
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