require 'rails'

module SeedMigration

  DEFAULT_TABLE_NAME = 'seed_migration_data_migrations'

  mattr_accessor :extend_native_migration_task
  mattr_accessor :migration_table_name
  mattr_accessor :ignore_ids
  mattr_accessor :update_seeds_file
  mattr_accessor :migrations_path
  mattr_accessor :use_strict_create
  mattr_accessor :use_activerecord_import

  self.migration_table_name = DEFAULT_TABLE_NAME
  self.extend_native_migration_task = false
  self.ignore_ids = false
  self.update_seeds_file = true
  self.migrations_path = 'data'
  self.use_strict_create = false
  self.use_activerecord_import = false

  def self.config
    yield self
    after_config
  end

  def self.after_config
    if self.extend_native_migration_task
      require_relative '../extra_tasks.rb'
    end
  end

  def self.use_strict_create?
    use_strict_create
  end

  def self.use_activerecord_import?
    use_activerecord_import
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
