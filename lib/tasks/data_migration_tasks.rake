namespace :data do
    desc "Run new data migrations."
    task :migrate => :environment do
        filename = ENV["MIGRATION"]
        if filename.blank?
            # Run any outstanding migrations
            HarrysData::Migrator.run_new_migrations
        else
            path = HarrysData::Migrator.migration_path(filename)
            HarrysData::Migrator.new(path).up
        end
    end

    desc "Revert last data migration."
    task :rollback => :environment do
        filename = ENV["MIGRATION"]
        if filename.blank?
            steps = ENV["STEP"] || 1
            HarrysData::Migrator.rollback_migrations(steps)
        else
            path = HarrysData::Migrator.migration_path(filename)
            HarrysData::Migrator.new(path).down
        end
    end

    desc "Import old data migrations"
    task :bootstrap => :environment do
        path = HarrysData::Migrator.migration_path("20140313133343_insert_prior_data_migrations.rb")
        HarrysData::Migrator.new(path).up
    end
end
