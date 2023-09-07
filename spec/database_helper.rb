module ROM
  module SQL
    module RakeSupport
      MissingEnv = Class.new(StandardError)

      class << self
        def run_migrations(options = {})
          gateway.run_migrations(options)
        end

        def create_migration(*args)
          gateway.migrator.create_file(*args)
        end

        # Global environment used for running migrations. You normally
        # set in the `db:setup` task with `ROM::SQL::RakeSupport.env = ROM.container(...)`
        # or something similar.
        #
        # @api public
        attr_accessor :env

        private

        def gateway
          if env.nil? # rubocop:disable Style/GuardClause
            Gateway.instance ||
              raise(MissingEnv, 'Set up a configutation with ROM::SQL::RakeSupport.env= in the db:setup task')
          else
            env.gateways[:default]
          end
        end
      end

      @env = nil
    end
  end
end

class DatabaseHelper
  def setup!
    ROM::SQL::RakeSupport.env = ROM::Configuration.new(
      :sql,
      'sqlite://test.db',
      adapter: :sqlite,
      path: '12'
    ).tap do |config|
      config.gateways[:default].migrator.instance_variable_set(:@path, 'spec/support/db/migrate')
    end
  end

  def migrate
    setup!
    ROM::SQL::RakeSupport.run_migrations
  end
end
