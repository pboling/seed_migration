# This task is manually loaded after the engine has been initialized
require 'rake'

begin
  # If a rake task is ran from the parent applicatiom, all Rails rasks are
  # already loaded.
  # But if `rails {s|c}` is ran from the parent application, then tasks are not
  # loaded
  Rake::Task['db:migrate']
rescue RuntimeError
  Rails.application.load_tasks
end


if SeedMigration.extend_native_migration_task
  Rake::Task['db:migrate'].enhance do
    Rake::Task['seed:migrate'].invoke
  end
end
