class VoterSignature < ActiveRecord::Base
  
  DEVICE_METHOD="device".freeze
  UPLOAD_METHOD="upload".freeze
  PRINT_METHOD="print".freeze
  DESKTOP_METHOD="desktop".freeze
  
  
  def self.resize_signature_url(sig_url)
    regexp = /\Adata:(.+);base64,(.+)\z/
    if sig_url =~ regexp
      type = $1
      data = $2
      return "data:#{type};base64,#{process_signature(data)[0]}"
    else
      return sig_url
    end
  end
  
  
  SIG_WIDTH = 180
  SIG_HEIGHT = 60
  RESOLUTION =  100
  def self.process_signature(base64data, mods=[])
    image_blob = Base64.decode64(base64data)
    src = Tempfile.new('src')
    dst = Tempfile.new('dst')
    begin
      src.binmode
      src.write(image_blob)
      src.close
      wh = `identify -format "%wx%h" #{src.path}`
      if wh.to_s.strip !="#{SIG_WIDTH}x#{SIG_HEIGHT}"
        dst.close
        #  -background skyblue -extent 100x60
        cmd = "convert #{src.path} -background white -extent #{SIG_WIDTH}x#{SIG_HEIGHT} -density #{RESOLUTION} #{dst.path}"
        `#{cmd}`
        dst.open
        dst.binmode
        converted = dst.read
        converted64 = Base64.encode64(converted)
        mods << "Converted #{wh} image to #{SIG_WIDTH}x#{SIG_HEIGHT}"
        return converted64.gsub("\n",''), mods
      else
        return base64data, mods
      end
    ensure
       src.close
       src.unlink   # deletes the temp file
       dst.close
       dst.unlink   # deletes the temp file
    end
  end
  
end
