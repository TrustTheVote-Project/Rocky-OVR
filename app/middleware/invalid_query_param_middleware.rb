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
    # Check for characters that are not standard in URLs and should be percent-encoded
    invalid_characters = /[^A-Za-z0-9\-._~!*\(\);:@&=+\/?\[\]%áéíóúÁÉÍÓÚ]/ # Added Spanish accented characters
    query_string.match?(invalid_characters)
  end
end
