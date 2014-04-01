class SeedMigration::DataMigration < ActiveRecord::Base
  self.table_name = SeedMigration.migration_table_name

  validates :version, :runtime, :migrated_on, :presence => true
end
