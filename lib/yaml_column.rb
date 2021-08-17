require "yaml"

module ActiveRecord
  module Coders # :nodoc:
    class YAMLColumn # :nodoc:
      def assert_valid_value(obj, action:)
        unless obj.nil? || obj.is_a?(object_class)
          if object_class == Hash && obj.is_a?(ActionController::Parameters)
            # OK
          else
            raise SerializationTypeMismatch,
              "can't #{action} `#{@attr_name}`: was supposed to be a #{object_class}, but was a #{obj.class}. -- #{obj.inspect}"
          end
        end
      end
    end
  end
end