environment "staging2"
app_dir = File.expand_path("../..", __dir__)
shared_dir = "/var/www/rocky-shared"

bind "unix://#{shared_dir}/sockets/puma.sock"
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
stdout_redirect "#{shared_dir}/log/puma.stdout.log","#{shared_dir}/log/puma.stderr.log", true

workers 2
threads 1, 4
plugin :tmp_restart

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
