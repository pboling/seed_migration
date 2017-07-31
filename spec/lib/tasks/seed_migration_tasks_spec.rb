require 'spec_helper'
require 'rake'
load Rails.root.join('Rakefile')

describe 'Rake Tasks' do
  it 'should define rake seed:migrate' do
    Rake::Task['seed:migrate'].should_not be_nil
  end

  it 'should define rake seed:rollback' do
    Rake::Task['seed:rollback'].should_not be_nil
  end

  it 'rake seed:migrate:status' do
    Rake::Task['seed:migrate:status'].should_not be_nil
  end

  context 'extending rake db:migrate' do
    before(:each) do
      Rake::Task["db:migrate"].clear
      SeedMigration.extend_native_migration_task = extend_native_migration_task
      load 'lib/extra_tasks.rb'
    end
    context 'option disabled' do
      let(:extend_native_migration_task) { false }

      it 'should not extend rake db:migrate' do
        SeedMigration.extend_native_migration_task.should eq(false)
        Rake::Task['seed:migrate'].should_not_receive(:invoke)
        Rake::Task["db:migrate"].execute
      end
    end
    context 'option enabled' do
      let(:extend_native_migration_task) { true }

      it 'should extend rake db:migrate' do
        SeedMigration.extend_native_migration_task.should eq(true)
        Rake::Task['seed:migrate'].should_receive(:invoke)
        Rake::Task["db:migrate"].execute
      end
    end
  end

  context 'raw task' do
    before { Dir.chdir 'spec/dummy' }
    after { Dir.chdir '../..' }
    it 'works' do
      output = system("bundle exec rake seed:migrate")
      output.should eq(true)
    end
  end
end
