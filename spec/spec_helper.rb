require 'dotenv'
Dotenv.load!

require 'pry'
require 'rom'
require 'rom/sql'
require 'rom-repository'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'shrine'
require 'shrine/storage/file_system'

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new(Dir.tmpdir),
  store: Shrine::Storage::FileSystem.new("spec/tmp", prefix: 'uploads')
}

require_relative 'database_helper'
require 'support/persistence/all'

DatabaseHelper.new.migrate

binding.pry

RSpec.configure do |config|
  config.after(:each) do |_example|
    Repositories::KittenRepository.new.clear
    Repositories::MultiCatRepository.new.clear
    Repositories::PluginsModelRepository.new.clear
  end
end