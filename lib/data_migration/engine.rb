module DataMigration
  class Engine < ::Rails::Engine
    isolate_namespace DataMigration
  end
end
