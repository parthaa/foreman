class CreateUserColumns < ActiveRecord::Migration[5.1]
  def change
    create_table :user_columns do |t|
      t.column :resource, :string, :limit => 255, :null => false
      t.text :columns
      t.timestamps :null => false
      t.integer :user_id, :null => false
    end
    add_foreign_key :user_columns, :users, :name => "user_columns_user_id_fk"
    add_index :user_columns, :user_id
    add_index :user_columns, [:user_id, :resource], :unique => true
  end
end
