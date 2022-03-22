Rails.application.routes.draw do
  mount SeedMigration::Engine => "/seed_migration"
end
