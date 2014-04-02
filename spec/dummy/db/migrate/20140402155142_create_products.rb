class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.timestamps
    end
  end
end
