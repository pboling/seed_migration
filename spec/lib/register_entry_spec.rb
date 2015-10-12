require 'spec_helper'

describe SeedMigration::RegisterEntry do
  let(:entry) { SeedMigration::RegisterEntry.new(User) }

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

  describe '#ordering' do
    context 'given no arguments' do
      it 'sets the ordering to the default' do
        entry.order.should eq('id')
      end
    end

    context 'given ordering arguments' do
      it 'sets the ordering to the passed ordering' do
        entry.order :example
        entry.order.should eq(:example)
      end
    end
  end
end
