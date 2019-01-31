# frozen_string_literal: true

# https://devcenter.heroku.com/articles/language-runtime-metrics-ruby#add-the-barnes-gem-to-your-application
require 'barnes'

before_fork do
  # worker specific setup

  Barnes.start
end

# straight from the Heroku documentation:
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
workers Integer(ENV['WEB_CONCURRENCY'] || 2) unless Gem.win_platform?
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/
  # deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
