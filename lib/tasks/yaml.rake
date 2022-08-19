
namespace :yaml do
  desc "Exports YAML translations as CSV. Usage: rails yaml:export > sample.csv"
  task :export => :environment do
    YamlExport.ymls_to_csv(cli: true)
  end
end
