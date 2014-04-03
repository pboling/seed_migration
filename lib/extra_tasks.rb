# This task is manually loaded after the engine has been initialized
require 'rake'

DATA_MIGRATE_TASK_NAME = 'data:migrate'

if ENV['RAILS_ENV'] == 'test'
  DATA_MIGRATE_TASK_NAME = "app:#{DATA_MIGRATE_TASK_NAME}"
end

if SeedMigration.extend_native_migration
  Rake::Task['db:migrate'].enhance do
    Rake::Task[DATA_MIGRATE_TASK_NAME].invoke
  end
end
