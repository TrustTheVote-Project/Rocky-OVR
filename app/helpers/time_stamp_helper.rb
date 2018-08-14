module TimeStampHelper
  
  def eastern_time(timestamp)
    Time.parse(timestamp).in_time_zone('America/New_York')
  rescue
    return timestamp
  end
  
end