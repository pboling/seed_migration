require 'spec_helper'

describe SeedMigration::RegisterEntry do
  let(:entry) { SeedMigration::RegisterEntry.new(User) }

  describe '#model' do
    it 'builds from model name' do
      entry = SeedMigration::RegisterEntry.new('User')
      expect(entry.model).to eq User
    end
  end

  describe '#attributes' do
    it 'exists' do
      entry.attributes.should be_a_kind_of Array
    end

    it 'defaults to model attributes' do
      entry.attributes.should eq(User.attribute_names)
    end

    it 'copied the attributes list' do
      entry.attributes.should_not be(User.attribute_names)
    end
  end

  describe '#exclude' do
    context 'single value' do
      it 'removes attribute' do
        entry.exclude 'id'
        entry.attributes.should_not include('id')
      end
    end

    context 'single value symbol' do
      it 'removes attribute' do
        entry.attributes.should eq(User.attribute_names)
        entry.exclude :id
        entry.attributes.should_not include('id')
      end
    end

    context 'array value' do
      it 'removes attributes' do
        entry.exclude 'id', 'username'
        entry.attributes.should_not include('id')
        entry.attributes.should_not include('username')
      end
    end
  end
end
