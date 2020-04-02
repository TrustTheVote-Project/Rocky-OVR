class PACensor

  def self.protect(original_params, registrant=nil)
    begin
      params = original_params.deep_dup
      values = JSON.parse(params[:request_body])
      values["ApplicationData"] = values["ApplicationData"].gsub(/<ssn4>.+<\/ssn4>/i, "<ssn4>*redacted*<\/ssn4>")
      values["ApplicationData"] = values["ApplicationData"].gsub(/<drivers-license>.+<\/drivers-license>/i, "<drivers-license>*redacted*<\/drivers-license>")
      params[:request_body] = values.to_json
      return params
    rescue
      return original_params
    end
  end
end
