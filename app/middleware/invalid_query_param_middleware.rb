# app/middleware/invalid_query_param_middleware.rb
class InvalidQueryParamMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if invalid_query_param?(request.query_string)
      [400, { 'Content-Type' => 'text/plain' }, ['Bad Request - Check your url for nasty characters']]
    else
      @app.call(env)
    end
  end

  private

  def invalid_query_param?(query_string)
    # List of explicitly disallowed percent-encoded sequences.
    disallowed_sequences = [
      '%AE', '%3C', '%3E', '%25', '%7B', '%7D', '%7C', '%5C',
      '%5E', '%7E', '%5B', '%5D', '%00', '%01', '%02', '%03', '%04', '%05',
      '%06', '%07', '%08', '%09', '%0A', '%0B', '%0C', '%0D', '%0E', '%0F',
      '%10', '%11', '%12', '%13', '%14', '%15', '%16', '%17', '%18', '%19',
      '%1A', '%1B', '%1C', '%1D', '%1E', '%1F', '%7F'
    ]
    # Construct a regex to match any of the disallowed sequences.
    disallowed_sequences_regex = disallowed_sequences.join('|')

    # Allow valid URL characters, percent-encoded sequences, and Spanish accented characters.
    # Explicitly disallow sequences in disallowed_sequences_regex and �.
    invalid_characters = /[^A-Za-z0-9\-._~!*\(\);:@&=+\/?\[\]%áéíóúÁÉÍÓÚ]|%(?![0-9A-Fa-f]{2})|#{disallowed_sequences_regex}|�/
    query_string.match?(invalid_characters)
  end
end
