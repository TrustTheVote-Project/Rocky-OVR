class AbrsController < ApplicationController
  CURRENT_STEP = 1
  
  include ApplicationHelper
  include AbrHelper
  
  layout "abr"
  before_filter :find_partner
  
  
  def new
    @abr = Abr.new(
        partner_id: @partner_id, 
        # tracking_source: @source,
        # tracking_id: @tracking,
        email: @email_address,
        first_name: @first_name,
        last_name: @last_name,
        home_state: @home_state,
        zip: @home_zip_code,
    )
    render "show"
  end
end