require 'spec_helper'

describe SeedMigration do
  it { SeedMigration.should be_a_kind_of Module }
  it { SeedMigration::Migrator.should be_a_kind_of Class }
  it { SeedMigration::Migration.should be_a_kind_of Class }
end
