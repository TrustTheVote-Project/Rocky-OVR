class WACensor

  def self.protect(original_params, registrant=nil)
    begin
      params = original_params.deep_dup
      values = JSON.parse(params[:request_body])
      values["driverLicense"] = "*redacted*"
      values["ssn4"] ="*redacted*"
      params[:request_body] = values.to_json
      return params
    rescue
      return original_params
    end
  end
end
