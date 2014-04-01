class CreateDataMigrations < ActiveRecord::Migration
    def up
        create_table SeedMigration.migration_table_name do |t|
            t.string :version
            t.integer :runtime
            t.datetime :migrated_on
        end
    end

    def down
        drop_table SeedMigration.migration_table_name
    end
end
