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

  describe "#association" do
    let(:entry) { SeedMigration::RegisterEntry.new(Assembly) }

    context 'habtm' do
      context 'unexisting association' do
        it "raises an error" do
          expect { entry.add_associations 'foo' }.to raise_error
        end
      end

      context 'existing association' do
        it "registers the association" do
          entry.add_associations 'parts'
          associations = entry.associations
          expect(associations.length).to eq(1)
          expect(associations[0].class).to eq(ActiveRecord::Reflection::HasAndBelongsToManyReflection)
          expect(associations[0].name).to eq(:parts)
        end
      end
    end
  end
end
