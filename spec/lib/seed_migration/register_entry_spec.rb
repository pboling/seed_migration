require "spec_helper"

describe SeedMigration::RegisterEntry do
  let(:entry) { SeedMigration::RegisterEntry.new(User) }

  describe "#attributes" do
    it "exists" do
      expect(entry.attributes).to be_a_kind_of Array
    end

    it "defaults to model attributes" do
      expect(entry.attributes).to eq(User.attribute_names)
    end

    it "copied the attributes list" do
      expect(entry.attributes).not_to be(User.attribute_names)
    end
  end

  describe "#exclude" do
    context "single value" do
      it "removes attribute" do
        entry.exclude "id"
        expect(entry.attributes).not_to include("id")
      end
    end

    context "single value symbol" do
      it "removes attribute" do
        expect(entry.attributes).to eq(User.attribute_names)
        entry.exclude :id
        expect(entry.attributes).not_to include("id")
      end
    end

    context "array value" do
      it "removes attributes" do
        entry.exclude "id", "username"
        expect(entry.attributes).not_to include("id")
        expect(entry.attributes).not_to include("username")
      end
    end
  end
end
