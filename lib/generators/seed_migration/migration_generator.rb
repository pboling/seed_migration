require 'rails/generators'
require 'rails/generators/named_base'

module SeedMigration
  module Generators
    class MigrationGenerator < Rails::Generators::NamedBase

      desc "Creates a data migration"
      class_option :migration_name, :type => :string, :default => nil
      argument :timestamp, :type => :string, :required => false, :default => Time.now.utc.strftime("%Y%m%d%H%M%S")

      def create_data_migration_file
        path = SeedMigration::Migrator::DATA_MIGRATION_DIRECTORY
        create_file path.join("#{timestamp}_#{file_name.gsub(/([A-Z])/, '_\1').downcase}.rb"),"class #{file_name.camelize} < SeedMigration::Migration\n    def up\n        \n    end\n\n    def down\n        \n    end\nend"
      end
    end
  end
end
