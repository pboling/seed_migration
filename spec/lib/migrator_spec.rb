require 'spec_helper'

describe SeedMigration::Migrator do
  before :each do
    # Generate test migrations
    2.times do |i|
      Rails::Generators.invoke("seed_migration:migration", ["TestMigration#{i}"])
      sleep 1 # For file uniqueness
    end
  end

  after :each do
    # Delete fixtures from folder
    FileUtils.rm(SeedMigration::Migrator.get_migration_files)
  end

  let(:test_migration_path) {
    SeedMigration::Migrator.get_migration_files.sort.first
  }
  let(:migrator) { SeedMigration::Migrator.new(test_migration_path) }

  describe "#up" do
    it "should load the migration and call up on it" do
      require test_migration_path
      TestMigration0.any_instance.should_receive(:up)
      expect { migrator.up }.to change { SeedMigration::DataMigration.count }.by(1)
      SeedMigration::DataMigration.order("version DESC").reload.first.destroy
    end
  end

  describe "#down" do
    it "should not work if the initial migration hasn't been run" do
      require test_migration_path
      expect { migrator.down }.to raise_error(/hasn't been migrated/)
    end

    it "should load the migration and call down on it do" do
      require test_migration_path
      # Run migration first
      TestMigration0.any_instance.should_receive(:up)
      expect { migrator.up }.to change { SeedMigration::DataMigration.count }.by(1)

      # Now rollback
      TestMigration0.any_instance.should_receive(:down)
      expect { migrator.down }.to change { SeedMigration::DataMigration.count }.by(-1)
    end
  end

  describe '.get_new_migrations' do
    before(:each) do
      SeedMigration::Migrator.run_new_migrations
      Rails::Generators.invoke("seed_migration:migration", ["TestMigrationBefore"])
      # rename to file as it was generated before others
      File.open(SeedMigration::Migrator.get_migration_files.last) do |file|
        splitted_timestamped_name = File.basename(file).split('_')
        splitted_timestamped_name[0] = 5.days.ago.utc.strftime("%Y%m%d%H%M%S")
        new_file_name = splitted_timestamped_name.join('_')
        File.rename(file, File.dirname(file) + "/" + new_file_name)
      end
    end

    it 'runs all non ran migrations' do
      expect{SeedMigration::Migrator.run_new_migrations}.to change{SeedMigration::DataMigration.count}.by(1)
    end
  end

  describe "rake tasks" do
    describe "rake migrate" do
      it "should run migrations and insert a record into the data_migrations table" do
        expect { SeedMigration::Migrator.run_new_migrations }.to change { SeedMigration::DataMigration.count }.by(2)
        SeedMigration::DataMigration.order("version DESC").limit(2).destroy_all
      end
    end

    describe "rake rollback" do
      it "should by default roll back one step" do
        # Run migrations
        SeedMigration::Migrator.run_new_migrations

        # Rollback
        expect { SeedMigration::Migrator.rollback_migrations }.to change { SeedMigration::DataMigration.count }.by(-1)
        SeedMigration::DataMigration.order("version DESC").first.destroy
      end

      it "should roll back more than one if specified" do
        # Run migrations
        SeedMigration::Migrator.run_new_migrations

        # Rollback
        expect { SeedMigration::Migrator.rollback_migrations(2) }.to change { SeedMigration::DataMigration.count }.by(-2)
      end
    end
  end

  describe 'seeds.rb generation' do
    before(:all) do
      2.times { |i| User.create :username => i }
      2.times { |i| Product.create }
      2.times { |i| UselessModel.create }
    end

    after(:all) do
      User.delete_all
      Product.delete_all
      UselessModel.delete_all
    end

    before(:each) { SeedMigration::Migrator.run_new_migrations }
    let(:contents) { File.read(SeedMigration::Migrator::SEEDS_FILE_PATH) }

    context 'models' do
      before(:all) do
        SeedMigration.register User
        SeedMigration.register Product
      end

      it 'creates seeds.rb file' do
        File.exists?(File.join(Rails.root, 'db', 'seeds.rb')).should be_true
      end

      it 'outputs models creation in seeds.rb file' do
        contents.should_not be_nil
        contents.should_not be_empty
        contents.should include("User.create")
        contents.should include("Product.create")
      end

      it 'only outputs registered models' do
        contents.should_not include("SeedMigration::DataMigration.create")
        contents.should_not include("UselessModel.create")
      end

      it 'should output all attributes' do
        contents.should match(/(?=.*User\.create)(?=.*"id"=>)(?=.*"username"=>).*/)
        contents.should match(/(?=.*Product\.create)(?=.*"id"=>)(?=.*"created_at"=>)(?=.*"updated_at"=>).*/)
      end
    end

    context 'attributes' do
      before(:all) do
        SeedMigration.register User do
          exclude :id
        end
      end
      it 'only outputs selected attributes' do
        contents.should match(/(?=.*User\.create)(?!.*"id"=>)(?=.*"username"=>).*/)
      end
    end
  end

end
