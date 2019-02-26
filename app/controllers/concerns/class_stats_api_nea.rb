require_relative "./class_stats"

#国民経済計算(NationalEconomicAccounting)
class Api_nea < Estat_api
  
  def initialize(stats_id:,database:)
    super(stats_id: stats_id)
    @database = database
    @db_statlists = StatisticsList.all
    
    #get_meta_dataメソッドからメタデータを取得
    @meta_data = get_meta_data
    
    #不要なデータを取り込まないために、エンドポイントをセット
    @read_end_cat01 = "23"     
  end
  
  #コントローラーで呼び出すメソッド
  def create_database_nea
    get_require_item
    create_or_update_statslists
    create_or_update_statsdatabase
  end
  
  def get_require_item
    # 必要な項目をそれぞれ変数に代入
    @stat_code = @meta_data[:GET_META_INFO][:METADATA_INF][:TABLE_INF][:STAT_NAME][:@code]
    @stat_name = @meta_data[:GET_META_INFO][:METADATA_INF][:TABLE_INF][:STAT_NAME][:"$"]
    @table_code = @meta_data[:GET_META_INFO][:METADATA_INF][:TABLE_INF][:@id]
    @table_name = @meta_data[:GET_META_INFO][:METADATA_INF][:TABLE_INF][:TITLE]

    get_update_date = @meta_data[:GET_META_INFO][:METADATA_INF][:TABLE_INF][:UPDATED_DATE]
    @update_date = Date.strptime(get_update_date, '%Y-%m-%d')
  end


  def create_or_update_statslists
    # 統計リストＤＢの作成
    statlist = @db_statlists.find_by(table_code:@table_code)

    if statlist == nil
      @db_statlists.create(
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
  end

  def create_or_update_statsdatabase
    statlist = @db_statlists.find_by(table_code:@stats_id)
    
    # 統計リストの前回更新日が空欄、もしくは更新日が前回更新日と一致しない場合に
    # 統計ＤＢを作成、更新する
    if statlist.last_date == nil or statlist.last_date != statlist.update_date
        
      #get_all_dataメソッドから全データを取得
      @data_all = get_all_data
      
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
              pp cat01[:@code]
              if cat01[:@code] <= @read_end_cat01 and db_catlists.find_by(category_code:cat01[:@code]) == nil 
                  db_catlists.create(
                      category_code:cat01[:@code],
                      category_name:cat01[:@name]
                  )
              end
            end
        end
      end
      
      data_value.each do |data|
        if data[:@cat01] <= @read_end_cat01
          @database.create(
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