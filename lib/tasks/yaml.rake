require 'yaml'
require 'csv'

class YamlExport
  class << self
    def ymls_to_csv(base_dir='./config/locales')
      translations = Hash.new { |h,k| h[k] = {} }
    
      iterate_files(base_dir) do |_f, k, v|
        locale, key = k.match(/([^\.]+)\.(.+)/)[1..2]
        translations[key][locale] = v
      end
      #Add states.yml
      iterate_file('./db/bootstrap/import/states.yml') do |k, v|
        translations[k]['en'] = v
      end
      #
    
      locales = ['en'] + (translations.values.flat_map(&:keys).uniq.sort - ['en'])
    
      STDOUT.print(CSV.generate_line(['key'] + locales))
      translations.each do |key, values|
        STDOUT.print(CSV.generate_line([key] + locales.map { |loc| values[loc] } ))
      end
    end

    private

    def iterate_kv(hash, prefix=nil, &block)
      hash.each do |k,v|
        current_prefix = [prefix, k].compact.join('.')
        if v.is_a?(Hash)
            iterate_kv(v, current_prefix, &block)
        else
          yield current_prefix, v
        end
      end
    end
    
    def iterate_file(path, &block)
        iterate_kv(YAML.load_file(path), &block)
    end
    
    def iterate_files(base_dir='./config/locales')
      Dir.glob(base_dir + '/**/*.yml').sort.each do |path|
        iterate_file(path) do |k, v|
          yield path, k, v
        end
      end
    end
  end
end

namespace :yaml do
  desc "Exports YAML translations as CSV. Usage: rails yaml:export > sample.csv"
  task :export => :environment do
    YamlExport.ymls_to_csv
  end
end
