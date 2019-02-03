class EcoIndicatorController < ApplicationController
  def index
    update_category_list("0003109741")
    @db_catlists = CategoryList.all
  end
  
  def show
    @db_catlists = CategoryList.all
  end

  def test
    get_api_url("0003109741")
    redirect_to :action => "index"
  end
  
  helper_method :test
end

  #（メモ）APIアドレスを作成するメソッド
  def get_api_url(stats_data_id)
    api_url = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsData"
    api_appid = "bb86c86ee575b3adfa4930ee0f17a74de14e57e6"
    @req_url = api_url +"?appId=" + api_appid +"&statsDataId=" + stats_data_id
    pp @req_url
  end
  
  def update_category_list(data_id)
    get_api_url(data_id)

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