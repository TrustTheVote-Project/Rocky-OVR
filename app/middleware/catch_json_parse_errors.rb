# From https://robots.thoughtbot.com/catching-json-parse-errors-with-custom-middleware
class CatchJsonParseErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['CONTENT_TYPE']&.include?('application/json') && env['rack.input']
      request = Rack::Request.new(env)
      request.body.rewind
      json = JSON.parse(request.body.read)
      
      # Iterate over JSON keys and sanitize values
      json.each do |key, value|
        json[key] = remove_emojis(value) if value.is_a?(String)
      end

      # Replace the request body with the sanitized JSON
      env['rack.input'] = StringIO.new(json.to_json)
    end

    begin
      @app.call(env)
    rescue MultiJson::LoadError => error
      if env['HTTP_ACCEPT'] =~ /application\/json/
        error_output = "There was a problem in the JSON you submitted: #{error}"
        return [
          400, { "Content-Type" => "application/json" },
          [ { status: 400, error: error_output }.to_json ]
        ]
      else
        raise "There was a problem with the format of the submitted JSON"
      end
    end
  end

  private

  def remove_emojis(text)
    text.gsub(/\p{Emoji}/, '')
  end
end
