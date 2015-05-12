# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete documentation
#
# This file should go in the config directory of your Rails app e.g. config/unicorn.rb

APP_ROOT = File.expand_path( File.dirname( File.dirname(__FILE__)))

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

# each process for this application takes 10-12% memory
# we have a master + worker(s) for each stage
worker_processes 16 # keep this 1 for linode-512
working_directory APP_ROOT

# # Load app into the master before forking workers for super-fast
# # worker spawn times
preload_app true

# nuke workers after 60 seconds (the default)
timeout 60

listen APP_ROOT + "/tmp/sockets/unicorn.sock", backlog: 4096 # number of clients it can serve

# pid "#{APP_DEPLOY_ROOT}/shared/pids/unicorn.pid"
pid APP_ROOT + "/tmp/pids/unicorn.pid"

stderr_path "#{APP_ROOT}/log/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn.stdout.log"

# Sat Oct 27 00:33:48 IST 2012, ram@sarvasv.in (ramonrails)
# * ActiveRecord connection management
before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?( ActiveRecord::Base)

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  # old_pid = "#{server.config[:pid]}.oldbin"
  old_pid = APP_ROOT + '/tmp/pids/unicorn.pid.oldbin'

  if File.exists?( old_pid) && ( server.pid != old_pid)
    begin
      # QUIT - graceful shutdown, waits for workers to finish their current request before finishing
      # TTOU - decrement the number of worker processes by one
      sig = 'QUIT'
      # sig = ((worker.nr + 1) >= server.worker_processes) ? 'QUIT' : 'TTOU'
      Process.kill( sig, File.read( old_pid).to_i)
      
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  # # NOTE: use this manual method to force configuration
  # #
  # # manually fetch the configuration hash
  # config = Rails.application.config.database_configuration[Rails.env]
  # #
  # # use it to establish new connection
  # ActiveRecord::Base.establish_connection( config) if defined?( ActiveRecord::Base)
  ActiveRecord::Base.establish_connection if defined?( ActiveRecord::Base)

  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")

  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket
  if defined?($redis)
    begin
      $redis.client.disconnect
      $redis = Redis.new( host: '52.11.247.197', port: 6379)
      $redis.client.reconnect
      system("echo redis with options: #{$redis.client.options.to_s}, connection status: #{$redis.client.connected?}")
    rescue
      $redis = Redis.new( host: '52.11.247.197', port: 6379)
    end
  end
end

# You may need to set or reset the BUNDLE_GEMFILE environment variable in the before_exec hook:
# 
before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{APP_ROOT}/Gemfile"
end
