class AlertRequestsController < ApplicationController
  layout 'alert_request'
  before_action :find_partner

  def new
    @alert_request = AlertRequest.new(new_alert_request_params)

    if @alert_request.partner.primary?
      @alert_request.opt_in_email = true
    else
      if @alert_request.partner.rtv_email_opt_in?
        @alert_request.opt_in_email = true
      end
      if @alert_request.partner.partner_email_opt_in?
        @alert_request.partner_opt_in_email = true
      end
    end
  
    set_up_locale
    @question_1 = @alert_request.question_1
    @question_2 = @alert_request.question_2
  end

  def create
    @alert_request = AlertRequest.create(
      alert_request_params.merge(
        state: @home_state,
        opt_in_sms: alert_request_params[:phone].present?,
      )
    )
    @question_1 = @alert_request.question_1
    @question_2 = @alert_request.question_2
    update_partner_questions

    if @alert_request.save
      redirect_to alert_request_path(@alert_request)
    else
      render :new
    end
  end

  def show
    @alert_request = AlertRequest.find_by_param(params[:id])
  end

  private

  def alert_request_params
    @alert_request_params ||= params.require(:alert_request).permit(
      'first',
      'middle',
      'last',
      'address',
      'city',
      'zip',
      'date_of_birth_month',
      'date_of_birth_day',
      'date_of_birth_year',
      'tracking_source',
      'tracking_id',
      'phone',
      'phone_type',
      'email',
      'survey_answer_1',
      'survey_answer_2',
      'opt_in_email',
      'opt_in_sms',
      'partner_id',
      'partner_opt_in_email',
      'partner_opt_in_sms',
      'javascript_disabled',
    )
  end

  def new_alert_request_params
    {
      partner_id: @partner_id, 
      tracking_source: params[:source],
      tracking_id: params[:tracking],
      first: params[:first],
      middle: params[:middle],
      last: params[:last],
      address: params[:address],
      city: params[:city],
      zip: params[:zip],
      date_of_birth_month: params[:date_of_birth_month],
      date_of_birth_day: params[:date_of_birth_day],
      date_of_birth_year: params[:date_of_birth_year],
      phone: params[:phone],
      email: params[:email],
      phone_type: 'mobile',
    }
  end

  def find_partner
    @partner = Partner.find_by_id(params[:partner]) || Partner.find(Partner::DEFAULT_ID)
    @partner_id = @partner.id
    set_params
  end

  def set_params
    @locale = 'en'
    zip = params.dig(:alert_request, :zip)
    @home_state ||= zip ? GeoState.for_zip_code(zip.strip) : nil
  end

  def set_up_locale
    params[:locale] = nil if !I18n.available_locales.collect(&:to_s).include?(params[:locale].to_s)
    @locale = params[:locale] || @alert_request&.locale || 'en'
    I18n.locale = @locale.to_sym
  end

  def update_partner_questions
    answer_1 = alert_request_params[:survey_answer_1]
    answer_2 = alert_request_params[:survey_answer_2]
    original_survey_question_1 = @alert_request.question_1 if answer_1.present?
    original_survey_question_2 = @alert_request.question_2 if answer_2.present?
    @alert_request.assign_attributes(
      original_survey_question_1: original_survey_question_1,
      original_survey_question_2: original_survey_question_2
    )
  end
end
