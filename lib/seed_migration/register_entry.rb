module SeedMigration
  class RegisterEntry
    attr_reader :model
    attr_accessor :attributes

    def initialize(model)
      @model = model
      @attributes = model.attribute_names.dup
    end

    def exclude(*attrs)
      attrs.map(&:to_s).each { |attr| exclude_single_attributes attr }
    end

    def eql?(object)
      object.class == self.class && object.model == self.model
    end

    def hash
      model.hash
    end

    private

    def exclude_single_attributes(attr)
      @attributes.delete attr
    end
  end
end
