require "bundler/gem_tasks"
require "rake/testtask"
require 'rom/sql/rake_task'

namespace :db do
  task :setup do
    ROM::SQL::RakeSupport.env = ROM::Configuration.new(
      :sql,
      'sqlite://test.db',
      adapter: :sqlite
    )
  end
end