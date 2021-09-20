# frozen_string_literal: true

require_relative 'environments'

module SeedMigration
  class Migration
    include Environments

    class << self
      attr_accessor :transaction_disabled
      # Disable the transaction wrapping this migration.
      # You can still create your own transactions even after
      # calling #disable_transaction!
      def disable_transaction!
        @transaction_disabled = true
      end
    end

    def transaction_disabled?
      self.class.transaction_disabled
    end

    def up
      raise NotImplementedError
    end

    def down
      raise NotImplementedError
    end
  end
end
