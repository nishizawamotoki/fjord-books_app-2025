class AddProfileToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :postal_code, :string
    add_column :users, :address, :string
    add_column :users, :biography, :text
  end
end
