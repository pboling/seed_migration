namespace :seed do
  desc "Run new data migrations."
  task :migrate => :environment do
    SeedMigration::Migrator.run_migrations(ENV['MIGRATION'])
  end

  desc "Revert last data migration."
  task :rollback => :environment do
    SeedMigration::Migrator.rollback_migrations(ENV["MIGRATION"], ENV["STEP"] || ENV["STEPS"] || 1)
  end
end
