module SeedMigration
  class RegisterEntry
    attr_reader :model, :associations
    attr_accessor :attributes

    def initialize(model)
      @model = model
      @attributes = model.attribute_names.dup
      @associations = []
    end

    def exclude(*attrs)
      attrs.map(&:to_s).each { |attr| exclude_single_attributes attr }
    end

    def add_associations(*names)
      names.each do |name|
        # TODO: is this rails 4 specific?
        association_reflection = @model.reflect_on_association(name.to_sym)
        if association_reflection.nil?
          raise
        else
          @associations << association_reflection
        end
      end
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
