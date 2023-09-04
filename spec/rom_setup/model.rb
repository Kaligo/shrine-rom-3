# frozen_string_literal: true

require 'sequel'
require 'rom'
require 'rom/sql'

module Model
  def self.container
    @container ||= ROM.container(configuration)
  end

  def self.configuration
    @configuration ||= ROM::Configuration.new(:sql, 'sqlite://test.db', **options).tap do |config|
      persistence_pathname = Pathname.new(__dir__).join('persistence')

      config.auto_registration(persistence_pathname, namespace: 'Persistence')
    end
  end

  def self.options
    {
      adapter: 'sqlite'
      infer_relations: false
    }
  end
end
