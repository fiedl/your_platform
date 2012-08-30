root = "/var/wingolfsplattform/"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.wingolfsplattform.sock"
worker_processes 10
timeout 30
