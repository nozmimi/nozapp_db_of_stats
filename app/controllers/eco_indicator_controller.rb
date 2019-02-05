class EcoIndicatorController < ApplicationController

  def index
  end
  
  def nea_data
    gon.db_stat = StatisticsList.all
    gon.db_date = DateList.all
    gon.db_cat = CategoryList.all
    gon.db_nominal = NominalNationalEconomicAccounting.all
  end

  def update_data
      #国民経済計算（名目）
      update_nea(NominalNationalEconomicAccounting.all,["0003109741","0003109786","0003109742"])
      
      #国民経済計算（実質）
      update_nea(RealNationalEconomicAccounting.all,["0003109766","0003109751","0003109767"])
      
  end

helper_method :update_data

end


  def update_statistics_list(stats_id)
    
    # APIアドレスの作成してJsonデータを取得し、parseしてグローバル変数へ代入
    api_url = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsData"
    api_appid = "bb86c86ee575b3adfa4930ee0f17a74de14e57e6"
    @req_url = api_url +"?appId=" + api_appid +"&statsDataId=" + stats_id
    pp @req_url

    # データの取得
    req_uri = URI.parse(@req_url)
    data_json = Net::HTTP.get(req_uri)
    @data_all = JSON.parse(data_json, symbolize_names: true)    

    @stat_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:@code]
    @stat_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:"$"]
    @table_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:@id]
    @table_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:TITLE]
    @update_date = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:UPDATED_DATE]
    
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
  end



  def update_nea(db_datas,nea_id)
    #国民経済計算(NationalEconomicAccounting)のID
    
    nea_id.each do |id|
      update_statistics_list(id)
      
      db_statlists = StatisticsList.all
        statlist = db_statlists.find_by(table_code:id)
      
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
                  if db_catlists.find_by(category_code:cat01[:@code]) == nil
                     db_catlists.create(
                         category_code:cat01[:@code],
                         category_name:cat01[:@name]
                      )
                  end
                end
            end
          end
          
          data_value.each do |data|
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
