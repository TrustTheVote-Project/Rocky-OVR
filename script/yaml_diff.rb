# ruby script/yaml_diff.rb config/locales/states/en.yml config/locales/states/en-new.yml

require 'rubygems'
require 'yaml'
require 'pp'

l1 = ARGV[0]
l2 = ARGV[1]
first = YAML.load_file(l1)
second = YAML.load_file(l2)

def diff(root, compared, structure = [])
  root.each_key do |key|
    next_root     = root[key]
    next_compared = compared.nil? ? nil : compared[key]
    new_structure = structure.dup << key
    if next_root.kind_of? Hash
      diff(next_root, next_compared, new_structure)
    else
      if next_root.to_s.strip != next_compared.to_s.strip
        puts "#{new_structure.join(".")}"
        puts "<<<<<"
        puts next_root
        puts "====="
        puts next_compared
        puts ">>>>>\n"
      end
    end
    
  end
end

puts "#{l1} vs #{l2}"
diff(first, second, [])

