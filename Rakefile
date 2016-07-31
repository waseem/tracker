#!/usr/bin/env rake

require File.join(File.expand_path(File.dirname(__FILE__)), 'boot')
require 'resque/tasks'
require 'post_processor_queue'

namespace :db do
  desc "Run the migration in a particular environment"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
end

desc 'loads up the environment'
task :environment do
  require 'database'
end
