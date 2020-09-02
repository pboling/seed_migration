# frozen_string_literal: true

#
# Define instance and class methods to manage migration environments
# on the seed migration files
#
# This module is included by SeedMigration::Migration, so its
# methods are available to all seed migration files.
#
module Environments
  # Class methods
  module ClassMethods
    attr_reader :environment_names_array

    # Define environments to apply the seed migration
    #
    # class MyMigration < SeedMigration::Migration
    #
    #   environments :production-us, :production-eu
    #
    #   def up
    #   end
    #
    #   def down
    #   end
    # end
    #
    def environments(*environment_names)
      @environment_names_array = environment_names
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
