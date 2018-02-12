class CreateUserColumns < ActiveRecord::Migration[5.1]
  def change
    create_table :user_columns do |t|
      t.column :resource, :string, :limit => 255
      t.text :columns
      t.timestamps :null => false
      t.references :user, :null => false, :index => true, :foreign_key => true
    end
    add_index :user_columns, [:resource, :user_id]
  end
end
