namespace :seed do
  if !Rake::Task.task_defined?("seed:migrate")
    desc "Run new data migrations."
    task migrate: :environment do
      SeedMigration::Migrator.run_migrations(ENV["MIGRATION"])
    end
  end

  if !Rake::Task.task_defined?("seed:rollback")
    desc "Revert last data migration."
    task rollback: :environment do
      SeedMigration::Migrator.rollback_migrations(ENV["MIGRATION"], ENV["STEP"] || ENV["STEPS"] || 1)
    end
  end

  namespace :migrate do
    if !Rake::Task.task_defined?("seed:migrate:status")
      desc "Display status of data migrations."
      task status: :environment do
        SeedMigration::Migrator.display_migrations_status
      end
    end
  end
end
