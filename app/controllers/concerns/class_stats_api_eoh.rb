 require_relative "./class_stats"

#家計消費支出(expenditure of households)
class Api_eoh < Estat_api

  #家計消費支出＿年次 ※年次，四半期はデータ構成が違うので注意！
  def update_eoh_calyear(db_datas,stats_id)
    read_cat01_code = "059"
    read_cat02_code = "03"
    read_cat03_code = "00"
    read_area_code = "00000"

    stats_id.each do |id|
      # ＵＲＬ作成～統計リスト作成のメソッドを呼び出し
      update_statistics_list(id)

      # 必要な項目をそれぞれ変数に代入
      @stat_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:@code]
      @stat_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:"$"]
      @table_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:@id]
      @table_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STATISTICS_NAME]
      @update_date = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:UPDATED_DATE]


      # 統計リストＤＢの作成
      db_statlists = StatisticsList.all
      statlist = db_statlists.find_by(table_code:@table_code)

      if statlist == nil
        db_statlists.create(
          stat_code:@stat_code,
          stat_name:@stat_name,
          table_code:@table_code,
          table_name:@table_name,
          update_date:@update_date
          )
      else
        statlist.stat_code = @stat_code
        statlist.stat_name = @stat_name
        statlist.table_code = @table_code
        statlist.table_name = @table_name
        statlist.last_date = statlist.update_date
        statlist.update_date = @update_date
        statlist.save
      end

      db_statlists = StatisticsList.all
        statlist = db_statlists.find_by(table_code:id)

      # 統計リストの前回更新日が空欄、もしくは更新日が前回更新日と一致しない場合に
      # 統計ＤＢを作成、更新する
      if statlist.last_date == nil or statlist.last_date != statlist.update_date

          data_value = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:DATA_INF][:VALUE]
          data_classobj = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:CLASS_INF][:CLASS_OBJ]

          db_datelists = DateList.all
          db_catlists = CategoryList.all

          data_classobj.each do |obj|
            case obj[:@id]
              when "time" then
                data_time = obj[:CLASS]
                date_unit = obj[:@name]

                data_time.each do |time|
                  if  db_datelists.find_by(date_code:time[:@code]) == nil
                      db_datelists.create(
                        date_code:time[:@code],
                        date_name:time[:@name],
                        date_unit:date_unit
                      )
                  end
                end
              when "cat01" then
                data_cat01 = obj[:CLASS]

                data_cat01.each do |cat01|
                  if cat01[:@code] == read_cat01_code and db_catlists.find_by(category_code:cat01[:@code]) == nil
                     db_catlists.create(
                         category_code:cat01[:@code],
                         category_name:cat01[:@name]
                      )
                  end
                end
            end
          end

          data_value.each do |data|
            if data[:@cat01] == read_cat01_code and data[:@cat02] == read_cat02_code and data[:@cat03] == read_cat03_code and data[:@area] == read_area_code
              db_datas.create(
                  table_code:@table_code,
                  date_code:data[:@time],
                  category_code:data[:@cat01],
                  data:data[:"$"],
                  data_unit:data[:@unit],
                  update_date:@update_date
                )
            end
          end
      end
    end
  end

  #家計消費支出＿四半期(expenditure of households)　※年次，四半期はデータ構成が違うので注意！
  def update_eoh_quarter(db_datas,stats_id)
    read_cat01_code = "059"
    read_cat02_code = "03"
    read_area_code = "00000"

    stats_id.each do |id|
      # ＵＲＬ作成～統計リスト作成のメソッドを呼び出し
      update_statistics_list(id)

      # 必要な項目をそれぞれ変数に代入
      @stat_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:@code]
      @stat_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:"$"]
      @table_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:@id]
      @table_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STATISTICS_NAME]
      @update_date = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:UPDATED_DATE]


      # 統計リストＤＢの作成
      db_statlists = StatisticsList.all
      statlist = db_statlists.find_by(table_code:@table_code)

      if statlist == nil
        db_statlists.create(
          stat_code:@stat_code,
          stat_name:@stat_name,
          table_code:@table_code,
          table_name:@table_name,
          update_date:@update_date
          )
      else
        statlist.stat_code = @stat_code
        statlist.stat_name = @stat_name
        statlist.table_code = @table_code
        statlist.table_name = @table_name
        statlist.last_date = statlist.update_date
        statlist.update_date = @update_date
        statlist.save
      end

      db_statlists = StatisticsList.all
        statlist = db_statlists.find_by(table_code:id)

      # 統計リストの前回更新日が空欄、もしくは更新日が前回更新日と一致しない場合に
      # 統計ＤＢを作成、更新する
      if statlist.last_date == nil or statlist.last_date != statlist.update_date

          data_value = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:DATA_INF][:VALUE]
          data_classobj = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:CLASS_INF][:CLASS_OBJ]

          db_datelists = DateList.all
          db_catlists = CategoryList.all

          data_classobj.each do |obj|
            case obj[:@id]
              when "time" then
                data_time = obj[:CLASS]
                date_unit = obj[:@name]

                data_time.each do |time|
                  if  db_datelists.find_by(date_code:time[:@code]) == nil
                      db_datelists.create(
                        date_code:time[:@code],
                        date_name:time[:@name],
                        date_unit:date_unit
                      )
                  end
                end
              when "cat01" then
                data_cat01 = obj[:CLASS]

                data_cat01.each do |cat01|
                  if cat01[:@code] == read_cat01_code and db_catlists.find_by(category_code:cat01[:@code]) == nil
                     db_catlists.create(
                         category_code:cat01[:@code],
                         category_name:cat01[:@name]
                      )
                  end
                end
            end
          end

          data_value.each do |data|
            if data[:@cat01] == read_cat01_code and data[:@cat02] == read_cat02_code and data[:@area] == read_area_code
              db_datas.create(
                  table_code:@table_code,
                  date_code:data[:@time],
                  category_code:data[:@cat01],
                  data:data[:"$"],
                  data_unit:data[:@unit],
                  update_date:@update_date
                )
            end
          end
      end
    end
  end
end
