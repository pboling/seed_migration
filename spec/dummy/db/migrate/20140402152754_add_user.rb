class AddUser < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
    end
  end

  def down
    drop_table :users
  end
end
