class ChangeColumnDate < ActiveRecord::Migration[5.2]
  def change
    change_column :expenditure_of_households, :update_date, 'date USING CAST(update_date AS date)'
    change_column :real_national_economic_accountings, :update_date, 'date USING CAST(update_date AS date)'
    change_column :nominal_national_economic_accountings, :update_date, 'date USING CAST(update_date AS date)'
    change_column :statistics_lists, :update_date, 'date USING CAST(update_date AS date)'
    change_column :statistics_lists, :last_date, 'date USING CAST(last_date AS date)'
  end
end
