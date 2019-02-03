class EcoIndicatorController < ApplicationController
  def index
    update_nea()
    @db_catlists = CategoryList.all
  end
  
  def show
    @db_catlists = CategoryList.all
  end


end

# APIアドレスの作成（全共通）
  def get_api_url(stats_id)
    api_url = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsData"
    api_appid = "bb86c86ee575b3adfa4930ee0f17a74de14e57e6"
    @req_url = api_url +"?appId=" + api_appid +"&statsDataId=" + stats_id
    pp @req_url
  end

# CategoryListの作成，更新（全共通）
  def update_category_list(stats_id)
    get_api_url(stats_id)

    # データの取得
    req_uri = URI.parse(@req_url)
    data_json = Net::HTTP.get(req_uri)
    data_all = JSON.parse(data_json, symbolize_names: true)

    update_date = data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:UPDATED_DATE]
    category_code = data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:@id]
    category_name = data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:"$"]
    table_name = data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:TITLE] 
    
    db_catlists = CategoryList.all
    catlist = db_catlists.find_by(category_code:category_code)

    if db_catlists.count == 0 or catlist == nil
      puts "test"
      db_catlists.create(category_code:category_code, category_name:category_name, table_name:table_name, update_date:update_date)
    else
      catlist.category_code = category_code
      catlist.category_name = category_name
      catlist.table_name = table_name
      catlist.last_date = catlist.update_date
      catlist.update_date = update_date
      catlist.save
    end
  end

#国民経済計算（ＧＤＰなど）
  def update_nea
    nea_id = ["0003109741","0003109766","0003109785","0003109786"] #国民経済計算(NationalEconomicAccounting)
      nea_id.each do |id|
        update_category_list(id)
      end
  end