class MICensor

  def self.protect(original_params, registrant=nil)
    begin
      params = original_params.deep_dup
      values = JSON.parse(params[:request_body])
      ((values && values["Subject"] && values["Subject"]["VoterId"]) || []).each do |id|
        id["StringValue"] = "*redacted*"
      end
      params[:request_body] = values.to_json
      return params
    rescue
      return original_params
    end
    
    # TODO use something like this to ensure consistency
    sensitive_data = StateRegistrants::MIRegistrant::SENSITIVE_ATTRIBUTES.map do |key|
      registrant.send(key)
    end
    
    
    params.transform_values do |value|
      value = value.dup
      if value.instance_of? String
        sensitive_data.each do |secret|
          value.gsub!(secret, '**redacted**')
        end
      end

      value
    end
  end
end
