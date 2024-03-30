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

  #used to change ui in the case when rocky is inside an iframe
  def iframe
    (self.query_parameters || {})["iframe"]
  end

  def other_parameters
    extra_query_params = (self.query_parameters || {}).clone
    excluded_params = ["utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"]
    extra_query_params.delete_if { |key, _| excluded_params.include?(key) }
    extra_query_params.collect { |k, v| "#{k}=#{v}" }.join("&")
  end

  def parse_url_params
    iframe_param = query_parameters["iframe"] == 'true' ? 'true' : 'false'
    new_params = "#{other_parameters}&iframe=#{iframe_param}"
    update(other_parameters: new_params)
    iframe_param
  end

end
