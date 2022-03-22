require "spec_helper"
require "rake"
load Rails.root.join("Rakefile")

describe "Rake Tasks" do
  it "should define rake seed:migrate" do
    expect(Rake::Task["seed:migrate"]).not_to be_nil
  end

  it "should define rake seed:rollback" do
    expect(Rake::Task["seed:rollback"]).not_to be_nil
  end

  it "rake seed:migrate:status" do
    expect(Rake::Task["seed:migrate:status"]).not_to be_nil
  end

  context "extending rake db:migrate" do
    before(:each) do
      Rake::Task["db:migrate"].clear
      SeedMigration.extend_native_migration_task = extend_native_migration_task
      load "lib/extra_tasks.rb"
    end
    context "option disabled" do
      let(:extend_native_migration_task) { false }

      it "should not extend rake db:migrate" do
        allow(Rake::Task["seed:migrate"]).to receive(:invoke)
        expect(SeedMigration.extend_native_migration_task).to eq(false)
        Rake::Task["db:migrate"].execute
        expect(Rake::Task["seed:migrate"]).not_to have_received(:invoke)
      end
    end
    context "option enabled" do
      let(:extend_native_migration_task) { true }

      it "should extend rake db:migrate" do
        expect(SeedMigration.extend_native_migration_task).to eq(true)
        expect(Rake::Task["seed:migrate"]).to receive(:invoke)
        Rake::Task["db:migrate"].execute
      end
    end
  end

  context "raw task" do
    before { Dir.chdir "spec/dummy" }
    after { Dir.chdir "../.." }
    it "works" do
      output = system("bundle exec rake seed:migrate")
      expect(output).to eq(true)
    end
  end
end
