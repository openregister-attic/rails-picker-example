class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :code
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
