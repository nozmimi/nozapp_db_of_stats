class CreateStatisticsLists < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics_lists do |t|
      t.string :stat_code
      t.string :stat_name
      t.string :table_code
      t.string :table_name
      t.string :update_date
      t.string :last_date
      
      t.timestamps
    end
  end
end
