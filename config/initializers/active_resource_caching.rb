#based on http://lacides.heapsource.com/post/57635780540/caching-with-activeresource
require 'active_resource'
 
module ActiveResourceCaching
  extend  ActiveSupport::Concern
 
  included do
    class_attribute :cache
    self.cache = nil
  end
 
  module ClassMethods
    def cache_with(*store_option)
      self.cache = ActiveSupport::Cache.lookup_store(store_option)
      self.alias_method_chain :get, :cache
    end
  end


  def get_with_cache(path, headers = {})
    force_reload = headers.delete(:force_reload) == "true"
    response = force_reload ? nil : cache.read(path)
    if response.nil?
      response = get_without_cache(path, headers)
      cache.write(path, response)
    end
    response
  rescue
    get_without_cache(path, headers)
  end
    
  # def get_with_cache(path, headers = {})
  #   cached_resource = self.cache.read(path)
  #   response = if cached_resource && cached_etag = cached_resource["Etag"]
  #     get_without_cache(path, headers.merge("If-None-Match" => cached_etag))
  #   else
  #     get_without_cache(path, headers)
  #   end
  #   return cached_resource if response.code == "304"
  #   self.cache.write(path, response)
  #   response
  # end
end
 
module ActiveResource
  class Connection
    include ActiveResourceCaching
  end
end
 
if Rails.env.development? || Rails.env.test?
  ActiveResource::Connection.cache_with :file_store, '/tmp/cache'
else
  ActiveResource::Connection.cache_with :dalli_store,
                      (ENV["MEMCACHIER_SERVERS"] || "").split(","),
                      {:username => ENV["MEMCACHIER_USERNAME"],
                       :password => ENV["MEMCACHIER_PASSWORD"],
                       :failover => true,
                       :socket_timeout => 1.5,
                       :socket_failure_delay => 0.2,
                       :expires_in => 96.hours
                      }
end