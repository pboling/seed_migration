# frozen_string_literal: true

require_relative 'environments'

module SeedMigration
  class Migration
    include Environments

    class << self
      attr_accessor :transaction_enabled

      # Disable the transaction wrapping this migration.
      # You can still create your own transactions even after
      # calling #disable_transaction!
      def use!
        @transaction_enabled = true
      end
    end

    def transaction_enabled?
      self.class.transaction_enabled
    end

    def up
      raise NotImplementedError
    end

    def down
      raise NotImplementedError
    end
  end
end
