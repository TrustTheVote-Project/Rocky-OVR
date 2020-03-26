class MiCensor

  def self.protect(params, registrant)
    sensitive_data = StateRegistrants::MIRegistrant::SENSITIVE_ATTRIBUTES.map do |key|
      registrant.send(key)
    end

    params.transform_values do |value|
      value = value.dup
      if value.instance_of? String
        sensitive_data.each do |secret|
          value.gsub!(secret, '')
        end
      end

      value
    end
  end
end
