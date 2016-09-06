class FakeS3
  class FakeS3File
    attr_reader :key, :body, :public_url

    def initialize(key, body, public_url, storage)
      @key = key
      @body = body
      @public_url = public_url
      @storage = storage
      @storage.push self
    end

    def destroy
      @storage.delete(self)
    end
  end

  class FakeS3Files

    def initialize(url_root)
      @url_root = url_root
      @storage = []
    end

    include Enumerable
    def each(&block)
      @storage.each &block
    end

    def create(attributes)
      raise 'Invalid params' unless attributes.is_a?(Hash) && attributes[:key] && attributes[:body]
      is_public = attributes.include?(:public) ? attributes[:public] : true
      public_url = is_public ? File.join(@url_root, attributes[:key]) : ''
      body = attributes[:body].respond_to?(:read) ? attributes[:body].read : attributes[:body]

      FakeS3File.new(attributes[:key],  body, public_url, @storage)
    end

    def get(path)
      find { |f| f.key == path}
    end

    def [](index)
      @storage[index]
    end
  end

  attr_reader :files
  def initialize(file_paths=[], url_root = 'https://fake-s3')
    @files = FakeS3Files.new(url_root)
    file_paths.each do |file_path|
      @files.create(key: file_path, body: file_path )
    end

  end

end