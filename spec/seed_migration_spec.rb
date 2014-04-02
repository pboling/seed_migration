require 'spec_helper'

describe SeedMigration do
  it { SeedMigration.should be_a_kind_of Module }
  it { SeedMigration::Migrator.should be_a_kind_of Class }
  it { SeedMigration::Migration.should be_a_kind_of Class }
  it { SeedMigration.registrar.should be_a_kind_of Set }


  describe '.register' do
    it 'accepts a block' do
      SeedMigration.register User do
        exclude :id
      end
    end
  end

  describe 'registrar' do
    it "doesn't include duplicates" do
      SeedMigration.register User
      expect{SeedMigration.register User}.to change{SeedMigration.registrar.size}.by(0)
    end
  end

  describe '#unregister' do
    it 'removes the entry' do
      SeedMigration.register User
      expect{SeedMigration.unregister User}.to change{SeedMigration.registrar.size}.by(-1)
    end

    it 'keeps other registered entries' do
      SeedMigration.register User
      SeedMigration.register Product
      SeedMigration.unregister User
      SeedMigration.registrar.map(&:model).should include(Product)
    end
  end
end
