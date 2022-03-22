require "spec_helper"

describe SeedMigration do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  it "has a method #registrar that is a Set" do
    expect(described_class.registrar).to be_a_kind_of Set
  end

  describe ".register" do
    it "accepts a block" do
      SeedMigration.register User do
        exclude :id
      end
    end
  end

  describe "registrar" do
    it "doesn't include duplicates" do
      SeedMigration.register User
      expect { SeedMigration.register User }.to change { SeedMigration.registrar.size }.by(0)
    end
  end

  describe "#unregister" do
    it "removes the entry" do
      SeedMigration.register User
      expect { SeedMigration.unregister User }.to change { SeedMigration.registrar.size }.by(-1)
    end

    it "keeps other registered entries" do
      SeedMigration.register User
      SeedMigration.register Product
      SeedMigration.unregister User
      expect(SeedMigration.registrar.map(&:model)).to include(Product)
    end
  end

  module Foo
    mattr_accessor :migration_table_name
    # class << self
    # end
  end

  describe "configuration variables" do
    after do
      SeedMigration.migration_table_name = SeedMigration::DEFAULT_TABLE_NAME
    end

    it "does not conflict with variables in other modules" do
      Foo.migration_table_name = "foos"
      SeedMigration.migration_table_name = "bars"

      expect(Foo.migration_table_name).to eq "foos"
      expect(SeedMigration.migration_table_name).to eq "bars"
    end
  end
end
