
module SpecHelperMethods

  def fixture_files_path
    Rails.root.join("spec/fixtures/files")
  end
  
  def fixture_file_contents(path)
    c = ''
    File.open(fixture_files_path.join(path)) do |f|
      c = f.read
    end
    c
  end

  def fixture_files_file_upload(path, mime_type = nil)
    tempfile = File.new("#{fixture_files_path}#{path}")
    return Rack::Test::UploadedFile.new(tempfile, mime_type)
  end
  
  def silence_output
    old_stdout = $stdout
    $stdout = StringIO.new('')
    yield
  ensure
    $stdout = old_stdout
  end
  
  def clear_partner_asset_test_buckets
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY']
    })
    connection.directories.get("rocky-partner-assets-test").files.each do |f|
      print "WARNING: found test S3 file: #{f.key}. Test shouldn't upload files to live S3, FakeS3 wrapper should be used.\n"
      f.destroy
    end
  end

end