module SeedMigration
  class RegisterEntry
    attr_reader :model_name

    def initialize(model)
      @model_name = model.to_s
      @excluded_attributes = []
    end

    def exclude(*attrs)
      attrs.map(&:to_s).each { |attr| @excluded_attributes << attr }
      @attributes = nil
    end

    def eql?(other)
      other.class == self.class && other.model_name == model_name
    end

    def hash
      model_name.hash
    end

    def model
      @model ||= Object.const_get(@model_name)
    end

    def attributes
      @attributes ||= model.attribute_names.reject { |attr| @excluded_attributes.include?(attr) }
    end
  end
end
