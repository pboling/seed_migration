# frozen_string_literal: true

require_relative 'environments'

module SeedMigration
  class Migration
    include Environments

    class << self
      attr_accessor :disable_transaction
      # Disable the transaction wrapping this migration.
      # You can still create your own transactions even after
      # calling #disable_ddl_transaction!
      def disable_transaction!
        @disable_transaction = true
      end
    end

    def disable_transaction
      self.class.disable_transaction
    end

    def up
      raise NotImplementedError
    end

    def down
      raise NotImplementedError
    end
  end
end
