class CatalistService

  class CatalistCensor < RequestLogSession::BaseCensor
    def self.protect(request_data=nil, registrant=nil)
      params = request_data.to_unsafe_h.deep_dup.with_indifferent_access
      begin
        values = JSON.parse(params[:request_body]).to_unsafe_h.with_indifferent_access
        if values[:client_secret]
          values[:client_secret] = " * redacted * "
        end
        if values[:client_id]
          values[:client_id] = " * redacted * "
        end
        params[:request_body] = values.to_json
      rescue
      end
      return params
    end
  end
  
  def initialize
    # call this immediately and outside of another RequestLogSession call
    get_token
  end
  
  def token
    @token ||= get_token
  end
  
  def get_token
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'catalist', censor: CatalistCensor) do
      @token = CatalistClient.get_token["access_token"]
      return @token
    end
  end
  
  
  # {"count"=>1,
  #  "mrPersons"=>
  #   [{"dwid"=>"1231231",
  #     "matchRate"=>1.0,
  #     "distanceScore"=>nil,
  #     "distance"=>nil,
  #     "matchMethod"=>nil,
  #     "firstname"=>"A",
  #     "middlename"=>"M",
  #     "lastname"=>"M",
  #     "namesuffix"=>nil,
  #     "gender"=>"male",
  #     "birthdate"=>"XXXX-XX-XX",
  #     "regaddrline1"=>"XXXX",
  #     "regaddrline2"=>"",
  #     "regaddrcity"=>"XXXX",
  #     "regaddrstate"=>"XX",
  #     "regaddrzip"=>"XXXXX",
  #     "mailaddrline1"=>"XXXXX",
  #     "mailaddrline2"=>"",
  #     "mailaddrcity"=>"XXXX",
  #     "mailaddrstate"=>"XX",
  #     "mailaddrzip"=>"XXXXX",
  #     "phone"=>nil,
  #     "voterstatus"=>"active", #active, inactive, multipleAppearances, unregistered, unmatchedMember;
  #     "additionalProperties"=>{}}],
  #  "matchMethod"=>"STANDARD", #  standard, name, name-address, distance, email, phon 
  #  "status"=>"OK"}
  # {"count"=>0, "mrPersons"=>[], "matchMethod"=>"STANDARD", "status"=>"OK"} 
  def retrieve(params:, registrant: nil, abr: nil)
    RequestLogSession.make_call_with_logging(registrant: registrant, client_id: 'catalist', censor: CatalistCensor, abr: abr) do
      return CatalistClient.retrieve(params: params, token: self.token)
    end
  end


end