#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
class PartnerAssetsFolder

  attr_reader :connection
  
  def initialize(partner)
    @partner = partner
    @connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY']
    })
    
  end
  
  def directory
    connection.directories.get(@partner.partner_assets_bucket, prefix: @partner.assets_path + '/')
  end
  
  def old_directory
    connection.directories.get(@partner.partner_assets_bucket, prefix: @partner.absolute_old_assets_path)
  end
    
  def self.sync_all
    Partner.all.each do |p|
      PartnerAssetsFolder.new(p).sync_from_local
    end
  end
  
  def sync_from_local
    Dir.glob(Rails.root.join("public", @partner.assets_path, '*.*')).each do |fn|
      update_asset(File.basename(fn), File.open(fn))
    end
  end
  

  # Updates the css
  def update_css(name, file, group = nil)
    update_path(css_path(name, group), file)
  end
  
  def write_css(name, content)
    write_path(css_path(name), content)
  end

  # Updates asset
  def update_asset(name, file, group = nil)
    path = path_from_name(name, group)
    update_path(path, file)
  end

  def write_asset(name, content, group = nil)
    write_path(path_from_name(name, group), content)
  end
  
  def path_from_name(name, group = nil)
    File.join(@partner.assets_path, group.to_s, File.basename(name))
  end

  def list_named_urls
    files.collect {|f| cached_public_url(f).nil? ?  nil : f }.compact.map { |f| [f.key.gsub( @partner.assets_path + '/', ''), cached_public_url(f)]}
  end

  # Returns the list of all assets in the folder
  def list_assets
    is_partner2_css = ->(file) do
      ["partner2"].each do |name|
        return true if file.key.ends_with? "/#{name}.css"
      end
      false
    end

    filter = ->(file) do
      cached_public_url(file).nil? || is_partner2_css.call(file)
    end

    formatter = ->(file) do
      file.key.gsub( @partner.assets_path + '/', '')
    end

    files.reject(&filter).map(&formatter)
  end

  def files_by_folder(folder)
    files_to_hash(
      files.select do |file|
        v = parse_file_key(file.key)
        v.folder == folder && v.basename.present?
      end
    )
  end

  # returns { "base_file_name" => "content" }
  def files_to_hash(files)
    {}.tap do |result|
      files.each do |file|
        result[File.basename(file.key)] = file.body
      end
    end
  end


  def parse_file_key(key)
    # allow only "root/folder/file.ext" and "root/file.ext", any deeper structure is ignored
    folder, basename = *key.scan(%r(^#{@partner.assets_path}(/[^/]+)?(/[^/]+)$))[0]
    formatter = ->(x){ x.to_s.sub(/^\//, '') }
    OpenStruct.new(folder: formatter.(folder), basename: formatter.(basename))
  end

  # now only archive copies are private, so expiration is not needed
  # when a file is deleted its public_url is not available but cached value affects nothing
  # b/c file list is not cached
  def cached_public_url(fog_file)
    Rails.cache.fetch("#{fog_file.key}/public_url", expires_in: 3.days) { fog_file.public_url } if fog_file
  end

  def delete_assets(names)
    names.each { |name| delete_asset(name)}
  end

  # Deletes the asset
  def delete_asset(name, group = nil)
    (f = existing(File.join(@partner.assets_path, group.to_s, File.basename(name)))) && f.destroy
  end

  def s3_assets_key
    "partners/#{@partner.id}/assets"
  end

  def files
    # iteration over original files causes additional S3 requests (Fog's behaviour)
    @files ||= Rails.cache.fetch(s3_assets_key, expires_in: 1.hour) {
      directory.files.to_a
    }
  end

  def file_names
    files.collect {|f| cached_public_url(f).nil? ?  nil : f }.compact.map { |n| n.key }
  end

  def asset_url(name, group = nil)
    cached_public_url(asset_file(name, group))
  end

  def asset_file(name, group = nil)
    files.detect {|f| f.key == path_from_name(name, group) }
  end

  def asset_file_exists?(name, group = nil)
    asset_file(name, group).present?
  end

  def publish_sub_assets(group)
    source_folder = "#{group}/"
    # get all assets (including system app.css and reg.css)
    assets = list_named_urls.map(&:first)
    sub_assets = assets.select { |a| a.starts_with? source_folder }
    sub_assets_names = sub_assets.map { |a| File.basename(a) }
    # don't delete new files and preview sub files:
    delete_assets_list = assets - sub_assets - sub_assets_names

    sub_assets_names.each do |name|
      src = File.join(group.to_s, name)
      dst = name
      copy(src, dst)
    end

    delete_assets(delete_assets_list)
  end

  private

  def css_path(name, group = nil)
    @partner.send("#{name}_css_path", group)
  end

  def ensure_dir(path)
    FileUtils.mkdir_p File.dirname(path)
  end

  def update_file(path, file)
    write_file(path, file)
  end

  def write_file(path, content, is_public = true)
    directory.files.create(
      :key    => path,
      :body   => content,
      :content_type => mime_from_path(path),
      :public => is_public
    )
    Rails.cache.delete(s3_assets_key)
  end

  def update_path(path, file)
    if file.respond_to?(:read)
      create_version(path)
      update_file(path, file)
    end
  end
  def write_path(path, content)
    create_version(path)
    write_file(path, content)
  end

  def existing(path)
     directory.files.get(path)
  end
  

  def create_version(path)
    return unless (file = existing(path))

    ext  = File.extname(path)
    name = File.basename(path, ext)
    ts   = Time.now.strftime("%Y%m%d%H%M%S")

    archive_path = File.join(@partner.absolute_old_assets_path, "#{name}-#{ts}#{ext}")

    directory.files.create(
      :key => archive_path, 
      :body => file.body, 
      :content_type => mime_from_path(archive_path),
      :public=>false
    )
    Rails.cache.delete(s3_assets_key)
    #FileUtils.cp path, archive_path
  end

  def copy(from, to)
    source = File.join(@partner.assets_path, from)
    destination = File.join(@partner.assets_path, to)

    create_version(destination) if existing(destination)
    source_file = existing(source)

    write_file(destination, source_file.body)
  end
  
  def mime_from_path(path)
    MIME::Types.type_for(path.to_s).first.content_type
  rescue
    ""
  end

end
