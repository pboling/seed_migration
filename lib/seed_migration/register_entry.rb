module SeedMigration
  class RegisterEntry
    DEFAULT_ORDER = 'id'

    attr_reader :model
    attr_accessor :attributes
    attr_accessor :ordering

    def initialize(model)
      @model = model
      @attributes = model.attribute_names.dup
    end

    def exclude(*attrs)
      attrs.map(&:to_s).each { |attr| exclude_single_attributes attr }
    end

    def eql?(other)
      other.class == self.class && other.model == self.model
    end

    def hash
      model.hash
    end

    def order(order=DEFAULT_ORDER)
      @order ||= order
    end

    private

    def exclude_single_attributes(attr)
      @attributes.delete attr
    end
  end
end
