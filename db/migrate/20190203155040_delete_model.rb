class DeleteModel < ActiveRecord::Migration[5.2]
  def change
    drop_table:statistics_lists
    drop_table:category_lists
  end
end
