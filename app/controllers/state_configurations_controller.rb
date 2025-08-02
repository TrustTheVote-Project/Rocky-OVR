class StateConfigurationsController < ApplicationController
  layout 'state_configuration'
  
  before_action :get_state_importer
  before_action :disallow_production
  
  before_action :authenticate, :if => lambda { !%w{ development test }.include?(Rails.env) }
  
  def index
  end
  
  # def show
  #   @state = GeoState.find(params[:id])    
  # end
  
  def submit
    file = @state_importer.generate_yml(config_parameters)
    if @state_importer.has_errors?
      render :action=>:show
    else
      File.open(StateImporter.tmp_file_path, "w+") do |f|
        f.write file
      end
      submit_data(file)
    end    
  end
  
protected
  def config_parameters
    params[:config].permit!
  end
  def disallow_production
    if Rails.env.production?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def get_state_importer
    @state_importer = StateImporter.new
  end
  
  def submit_data(file)
    # later this will be 'email'
    #send_data file, :filename=>"new_states.yml", :type=>"text"
    ConfigMailer.state_config_file(file, "updated-states.yml").deliver_now
    
  end
  
  private

  def authenticate
    authenticate_or_request_with_http_basic("Settings UI") do |user, password|
      pass = Settings.admin_password
      pass.present? && user == 'rtvdemo' && password == 'sunset'
    end
  end
  
  
end
