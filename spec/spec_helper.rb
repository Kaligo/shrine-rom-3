require 'dotenv'
Dotenv.load!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'shrine/plugins/rom'
require 'shrine'
require 'shrine/storage/file_system'
require 'rom'
require 'rom/sql'
require_relative 'database_helper'
require_relative 'rom_setup/all'
require_relative 'persistence/all'

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new(Dir.tmpdir),
  store: Shrine::Storage::FileSystem.new("spec/tmp", prefix: 'uploads')
}


