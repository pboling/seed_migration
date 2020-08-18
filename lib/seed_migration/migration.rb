# frozen_string_literal: true

require_relative 'environments'

module SeedMigration
  class Migration
    include Environments

    def up
      raise NotImplementedError
    end

    def down
      raise NotImplementedError
    end
  end
end
