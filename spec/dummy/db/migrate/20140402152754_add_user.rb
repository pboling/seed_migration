class AddUser < ActiveRecord::Migration[4.2]
  def up
    create_table :users do |t|
      t.string :username
      t.string :a
    end
  end

  def down
    drop_table :users
  end
end
