class PartnerFakeS3
  def self.wrap(partner, file_list)
    FakeS3.new(file_list.map{|file_path| File.join(partner.assets_path, file_path) })
  end
end