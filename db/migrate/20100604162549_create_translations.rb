class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.integer :asset_id
      t.string :locale
      t.string :source_locale # for fallback
      t.string :title
      t.string :short_title
      t.text :abstract
      t.string :thumbnail_s
      t.string :thumbnail_m
      t.string :thumbnail_l
      t.timestamps
    end
  end
  
  def self.down
    drop_table :translations
  end
end
