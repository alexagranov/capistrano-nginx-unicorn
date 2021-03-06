require 'capistrano/nginx_unicorn/helpers'

include Capistrano::NginxUnicorn::Helpers

namespace :unicorn do
  desc "Setup Unicorn initializer"
  task :setup_initializer do
    on roles(:app) do
      template "unicorn_init.erb", "/tmp/unicorn_init"
      execute :chmod, "+x", "/tmp/unicorn_init"
      sudo :mv, "/tmp/unicorn_init /etc/init.d/#{fetch(:unicorn_service_name)}"
      sudo "update-rc.d -f #{fetch(:unicorn_service_name)} defaults"
    end
  end

  desc "Setup Unicorn app configuration"
  task :setup_app_config do
    on roles(:app) do
      execute :mkdir, "-p", shared_path.join("config")
      execute :mkdir, "-p", shared_path.join("log")
      execute :mkdir, "-p", shared_path.join("pids")
      template "unicorn.rb.erb", fetch(:unicorn_config)
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles(:app) do
        sudo "service #{fetch(:unicorn_service_name)} #{command}"
      end
    end
  end
end

namespace :deploy do
  after :publishing, "unicorn:restart"
end
