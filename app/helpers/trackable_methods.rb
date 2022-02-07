module TrackableMethods
  extend ActiveSupport::Concern

  included do
    has_many :tracking_params, as: :query_param_trackable
  end

  def query_parameters
    qp = {}
    tracking_params.each do |rtp|
      qp[rtp.name.to_s] = rtp.value
    end
    return qp
  end

  def query_parameters=(val)
    if val && val.keys && val.keys.length
      val.keys.each do |key|
        self.tracking_params.build({
          name: key.to_s,
          value: val[key].to_s
        })
      end
    end
  end

  def utm_source
    (self.query_parameters || {})["utm_source"]
  end

  def utm_medium
    (self.query_parameters || {})["utm_medium"]
  end

  def utm_campaign
    (self.query_parameters || {})["utm_campaign"]
  end

  def utm_term
    (self.query_parameters || {})["utm_term"]
  end

  def utm_content
    (self.query_parameters || {})["utm_content"]
  end

  def other_parameters
    extra_query_params = (self.query_parameters || {}).clone
    extra_query_params.delete("utm_source")
    extra_query_params.delete("utm_medium")
    extra_query_params.delete("utm_campaign")
    extra_query_params.delete("utm_term")
    extra_query_params.delete("utm_content")
    
    extra_query_params.collect {|k,v| "#{k}=#{v}"}.join("&")
  end


end