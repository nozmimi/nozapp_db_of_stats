class CreateExpenditureOfHouseholds < ActiveRecord::Migration[5.2]
  def change
    create_table :expenditure_of_households do |t|
      t.string :table_code
      t.string :date_code
      t.string :category_code
      t.integer :data
      t.string :data_unit
      t.string :update_date

      t.timestamps
    end
  end
end
