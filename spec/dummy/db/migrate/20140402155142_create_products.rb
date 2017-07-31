class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.timestamps
    end
  end
end
