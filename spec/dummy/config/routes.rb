Rails.application.routes.draw do

  mount DataMigration::Engine => "/data_migration"
end
