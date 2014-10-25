require 'rails/generators'
require 'rails/generators/named_base'

module SeedMigration
  module Generators
    class SeedMigrationGenerator < Rails::Generators::NamedBase
      namespace 'seed_migration'
      desc 'Creates a seed migration'
      class_option :migration_name, :type => :string, :default => nil
      argument :timestamp, :type => :string, :required => false, :default => Time.now.utc.strftime("%Y%m%d%H%M%S")

      def create_seed_migration_file
        path = SeedMigration::Migrator.data_migration_directory
        create_file path.join("#{timestamp}_#{file_name.gsub(/([A-Z])/, '_\1').downcase}.rb"), contents
      end

      private

      def contents
        <<STRING
class #{file_name.camelize} < SeedMigration::Migration
  def up

  end

  def down

  end
end
STRING
      end
    end
  end
end
