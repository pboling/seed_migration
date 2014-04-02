class AddUselessModel < ActiveRecord::Migration
  def up
    create_table :useless_models do |t|
      t.timestamps
    end
  end

  def down
    drop_table :useless_models
  end
end
