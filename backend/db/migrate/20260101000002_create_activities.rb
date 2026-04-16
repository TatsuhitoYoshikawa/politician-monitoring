class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references  :politician,    null: false, foreign_key: true
      t.string      :activity_type, null: false  # speech / sns / committee / vote / other
      t.text        :description,   null: false
      t.string      :source_url
      t.datetime    :occurred_at,   null: false

      t.timestamps
    end

    add_index :activities, :activity_type
    add_index :activities, :occurred_at
    add_index :activities, [:politician_id, :occurred_at]
  end
end
