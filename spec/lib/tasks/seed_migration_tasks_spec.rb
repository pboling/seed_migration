require 'spec_helper'
load 'Rakefile'

describe 'Rake Tasks' do
  it 'should define rake data:migrate' do
    Rake::Task['app:data:migrate'].should_not be_nil
  end

  it 'should define rake data:rollback' do
    Rake::Task['app:data:rollback'].should_not be_nil
  end

  context 'extending rake db:migrate' do
    before(:each) do
      Rake::Task["db:migrate"].clear
      SeedMigration.extend_native_migration = extend_native_migration
      load 'lib/extra_tasks.rb'
    end
    context 'option disabled' do
      let(:extend_native_migration) { false }

      it 'should not extend rake db:migrate' do
        SeedMigration.extend_native_migration.should be_false
        Rake::Task['app:data:migrate'].should_not_receive(:invoke)
        Rake::Task["db:migrate"].execute
      end
    end
    context 'option enabled' do
      let(:extend_native_migration) { true }

      it 'should extend rake db:migrate' do
        SeedMigration.extend_native_migration.should be_true
        Rake::Task['app:data:migrate'].should_receive(:invoke)
        Rake::Task["db:migrate"].execute
      end
    end
  end
end
