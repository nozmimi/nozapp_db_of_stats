class CreateRealNationalEconomicAccountings < ActiveRecord::Migration[5.2]
  def change
    create_table :real_national_economic_accountings do |t|
      t.string :date_code
      t.string :category_code
      t.integer :data
      t.string :data_unit
      t.string :update_date
      
      t.timestamps
    end
  end
end
