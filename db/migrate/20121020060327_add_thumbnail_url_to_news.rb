class AddThumbnailUrlToNews < ActiveRecord::Migration
  def change
    add_column :news, :thumbnail_url, :string
  end
end
