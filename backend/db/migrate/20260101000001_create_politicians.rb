class CreatePoliticians < ActiveRecord::Migration[7.1]
  def change
    create_table :politicians do |t|
      t.string :name,           null: false
      t.string :name_kana,      null: false
      t.string :party,          null: false
      t.string :chamber,        null: false   # "衆院" or "参院"
      t.string :constituency
      t.string :photo_url
      t.string :twitter_handle
      t.string :homepage_url

      t.timestamps
    end

    add_index :politicians, :party
    add_index :politicians, :chamber
    add_index :politicians, :name_kana
  end
end
