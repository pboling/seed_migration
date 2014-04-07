require 'rails'

module SeedMigration

  class << self
    mattr_accessor :extend_native_migration_task
    mattr_accessor :migration_table_name

    self.migration_table_name = 'seed_migration_data_migrations' # Hardcoded, evil!
    self.extend_native_migration_task = false
  end

  def self.config(&block)
    yield self
    after_config
  end

  def self.after_config
    if self.extend_native_migration_task
      require_relative '../extra_tasks.rb'
    end
  end

  class Engine < ::Rails::Engine
    isolate_namespace SeedMigration

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
