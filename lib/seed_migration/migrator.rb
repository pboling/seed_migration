require 'pathname'

module SeedMigration
  class Migrator
    SEEDS_FILE_PATH = Rails.root.join('db', 'seeds.rb')

    def self.data_migration_directory
      Rails.root.join("db", SeedMigration.migrations_path)
    end

    def self.migration_path(filename)
      data_migration_directory.join(filename).to_s
    end

    def initialize(migration_path)
      @path = Pathname.new(migration_path)
      raise "Can't find migration at #{@path}." if !@path.exist?
    end

    def up
      # Check if we already migrated this file
      klass = class_from_path
      version = @path.basename.to_s.split("_", 2).first
      raise "#{klass} has already been migrated." if SeedMigration::DataMigration.where(version: version).first

      start_time = Time.now
      announce("#{klass}: migrating")
      ActiveRecord::Base.transaction do
        klass.new.up
        end_time = Time.now
        runtime = (end_time - start_time).to_d.round(2)

        # Create record
        migration = SeedMigration::DataMigration.new
        migration.version = version
        migration.runtime = runtime.to_i
        migration.migrated_on = DateTime.now
        begin
          migration.save!
        rescue StandardError => e
          puts e
        end
        announce("#{klass}: migrated (#{runtime}s)")
      end
    end

    def down
      klass = class_from_path
      version = @path.basename.to_s.split("_", 2).first

      # Get migration record
      migration = SeedMigration::DataMigration.where(version: version).first

      # Do not proceed without it!
      raise "#{klass} hasn't been migrated." if migration.nil?

      # Revert
      start_time = Time.now
      announce("#{klass}: reverting")
      ActiveRecord::Base.transaction do
        klass.new.down
        end_time = Time.now
        runtime = (end_time - start_time).to_d.round(2)

        # Delete record of migration
        migration.destroy
        announce("#{klass}: reverted (#{runtime}s)")
      end
    end

    # Rake methods
    def self.run_new_migrations
      # TODO : Add warning about empty registered_models
      get_new_migrations.each do |migration|
        migration = migration_path(migration)
        new(migration).up
      end
    end

    def self.run_migrations(filename = nil)
      if filename.blank?
        # Run any outstanding migrations
        run_new_migrations
      else
        path = self.migration_path(filename)
        new(path).up
      end
      create_seed_file
    end

    def self.last_migration
      return SeedMigration::DataMigration.maximum("version")
    end

    def self.rollback_migrations(filename = nil, steps = 1)
      if filename.blank?
        to_run = get_last_x_migrations(steps)
        to_run.each do |migration|
          new(migration).down
        end
      else
        path = migration_path(filename)
        new(path).down
      end
      create_seed_file
    end

    def self.bootstrap(last_timestamp = nil)
      # replace with logger ?
      p "Assume seed data migrated up to #{last_timestamp}"
      files = get_migration_files(last_timestamp.to_s)
      files.each do |file|
        name = file.split('/').last
        version = name.split('_').first
        migration = SeedMigration::DataMigration.new
        migration.version = version
        migration.runtime = 0
        migration.migrated_on = DateTime.now
        migration.save!
      end
    end

    private

    def class_from_path
      announce("Loading migration class at '#{@path}'")
      require @path.to_s
      filename = @path.basename.to_s
      classname_and_extension = filename.split("_", 2).last
      classname = classname_and_extension.split(".").first.camelize
      classname.constantize
    end

    def announce(text)
      length = [0, 75 - text.length].max
      puts "== %s %s" % [text, "=" * length]
    end

    def self.get_new_migrations
      migrations = []
      files = get_migration_files

      # If there is no last migration, all migrations are new
      if get_last_migration_date.nil?
        return files
      end

      all_migration_versions = SeedMigration::DataMigration.all.map(&:version)

      files.each do |file|
        filename = file.split('/').last
        version = filename.split('_').first
        if !all_migration_versions.include?(version)
          migrations << filename
        end
      end

      # Sort the files so they execute in order
      migrations.sort!

      return migrations
    end

    def self.get_last_x_migrations(x = 1)
      # Grab data from DB
      migrations = SeedMigration::DataMigration.order("version DESC").limit(x).pluck("version")

      # Get actual files to load
      to_rollback = []
      files = get_migration_files
      migrations.each do |migration|
        files.each do |file|
          if !file.split('/').last[migration].nil?
            to_rollback << file
          end
        end
      end

      return to_rollback
    end

    def self.get_last_migration_date
      return nil if SeedMigration::DataMigration.count == 0
      DateTime.parse(last_migration)
    end

    def self.get_migration_files(last_timestamp = nil)
      files = Dir.glob(migration_path("*_*.rb"))
      if last_timestamp.present?
        files.delete_if do |file|
          timestamp = File.basename(file).split('_').first
          timestamp > last_timestamp
        end
      end

      # Just in case
      files.sort!
    end

    def self.create_seed_file
      if !SeedMigration.update_seeds_file || !Rails.env.development?
        return
      end
      File.open(SEEDS_FILE_PATH, 'w') do |file|
        if !SeedMigration.disable_referential_integrity
          file.write <<-eos
# encoding: UTF-8
# This file is auto-generated from the current content of the database. Instead
# of editing this file, please use the migrations feature of Seed Migration to
# incrementally modify your database, and then regenerate this seed file.
#
# If you need to create the database on another system, you should be using
# db:seed, not running all the migrations from scratch. The latter is a flawed
# and unsustainable approach (the more migrations you'll amass, the slower
# it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Base.transaction do
          eos
        else
          file.write <<-eos
# encoding: UTF-8
# This file is auto-generated from the current content of the database. Instead
# of editing this file, please use the migrations feature of Seed Migration to
# incrementally modify your database, and then regenerate this seed file.
#
# If you need to create the database on another system, you should be using
# db:seed, not running all the migrations from scratch. The latter is a flawed
# and unsustainable approach (the more migrations you'll amass, the slower
# it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Base.connection.disable_referential_integrity
  ActiveRecord::Base.transaction do
          eos
        end
        SeedMigration.registrar.each do |register_entry|
          register_entry.model.order('id').each do |instance|
            file.write generate_model_creation_string(instance, register_entry)
          end

          if !SeedMigration.ignore_ids
            file.write <<-eos
  ActiveRecord::Base.connection.reset_pk_sequence!('#{register_entry.model.table_name}')
            eos
          end
        end
        if !SeedMigration.disable_referential_integrity
          file.write <<-eos
end
          eos
        else
          file.write <<-eos
  end
end
          eos
        end
        file.write <<-eos
        
SeedMigration::Migrator.bootstrap(#{last_migration})
        eos
      end
    end

    def self.generate_model_creation_string(instance, register_entry)
      attributes = instance.attributes.select {|key| register_entry.attributes.include?(key) }
      if SeedMigration.ignore_ids
        attributes.delete('id')
      end
      sorted_attributes = {}
      attributes.sort.each do |key, value|
        sorted_attributes[key] = value
      end

      if Rails::VERSION::MAJOR == 3 || defined?(ActiveModel::MassAssignmentSecurity)
        model_creation_string = "#{instance.class}.#{create_method}(#{JSON.parse(sorted_attributes.to_json)}, :without_protection => true)"
      elsif Rails::VERSION::MAJOR == 4
        model_creation_string = "#{instance.class}.#{create_method}(#{JSON.parse(sorted_attributes.to_json)})"
      end

      # With pretty indents, please.
      return <<-eos

  #{model_creation_string}
      eos
    end

    def self.create_method
      SeedMigration.use_strict_create? ? 'create!' : 'create'
    end
  end
end
