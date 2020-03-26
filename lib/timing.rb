class Timing
  Result = Struct.new(:duration, :error)

  def self.measure
    error = nil
    start = Time.now
    duration = 0

    begin
      yield      
    rescue StandardError => e
      error = e
    ensure
      duration = Time.now - start
    end

    Result.new(duration, error)
  end
end
