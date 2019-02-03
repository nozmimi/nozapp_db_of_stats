class CreateDateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :date_lists do |t|
      t.string :date_code
      t.string :date_name
      t.string :date_unit

      t.timestamps
    end
  end
end
