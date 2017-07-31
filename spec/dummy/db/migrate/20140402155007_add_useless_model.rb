class AddUselessModel < ActiveRecord::Migration[4.2]
  def up
    create_table :useless_models do |t|
      t.timestamps
    end
  end

  def down
    drop_table :useless_models
  end
end
