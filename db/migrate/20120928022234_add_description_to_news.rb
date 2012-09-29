class AddDescriptionToNews < ActiveRecord::Migration
  def change
    add_column :news, :description, :text
  end
end
