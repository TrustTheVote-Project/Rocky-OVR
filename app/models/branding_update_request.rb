class BrandingUpdateRequest
  attr_reader :partner
  STATUS = OpenStruct.new(not_found: "not_found", open: "open", rejected: "rejected", done: "done").freeze

  ALLOWED_TRANSITIONS = {
      STATUS.not_found => [STATUS.open],
      STATUS.open => [STATUS.not_found, STATUS.done, STATUS.rejected],
      STATUS.done => [STATUS.open],
      STATUS.rejected => [STATUS.open]
  }

  def initialize(partner)
    @partner = partner
    request = @partner.branding_update_request
    @data = request.status.nil? ? default_request_data : request
  end

  def status
    @data.status
  end

  def date
    @data.date.try(:to_s) || ""
  end

  def open
    update_status(STATUS.open)
    begin
      AdminMailer.open_branding_request(self).deliver
    rescue
    end
  end

  def delete
    update_status(STATUS.not_found)
  end

  def done
    update_status(STATUS.done)
    begin
      AdminMailer.approve_branding_request(self).deliver
    rescue
    end
  end

  def reject
    update_status(STATUS.rejected)
    begin
      AdminMailer.reject_branding_request(self).deliver
    rescue
    end
  end

  def can_be_opened
    can_be STATUS.open
  end

  def can_be_done
    can_be STATUS.done
  end

  def can_be_closed
    can_be STATUS.not_found
  end

  def open?
    status == STATUS.open
  end

  def done?
    status == STATUS.done
  end

  def self.all
    Partner.where("NOT branding_update_request IS NULL").map { |p| BrandingUpdateRequest.new(p) }
  end

  def self.recently_closed
    Partner.order("updated_at DESC")
        .limit(100)
        .map { |p| BrandingUpdateRequest.new(p) }
        .select(&:done?)
        .sort_by(&:date)
        .reverse!
        .last(10)
  end

  private

  def default_request_data
    OpenStruct.new(
        "status" => STATUS.not_found,
        "date" => nil
    )
  end

  def update_status(status)
    raise "Invalid operation" unless can_be(status)
    @data.status = status
    @data.date = Date.today
    save!
  end

  def can_be(status)
    !!ALLOWED_TRANSITIONS[@data.status].find { |v| v == status }
  end

  def save!
    @partner.branding_update_request= @data
    @partner.save!
  end
end