class Estat_api

  def initialize(stats_id:)
    req_url = "https://api.e-stat.go.jp/rest/2.1/app/json/"
    api_appid = "bb86c86ee575b3adfa4930ee0f17a74de14e57e6"
    @stats_id = stats_id
    
    @url_meta = "#{req_url}getMetaInfo?appId=#{api_appid}&statsDataId=#{@stats_id}"
    @url_data = "#{req_url}getStatsData?appId=#{api_appid}&statsDataId=#{@stats_id}"
  end

  def get_meta_data
    url = URI.parse(@url_meta)
    data_json = Net::HTTP.get(url)
    return JSON.parse(data_json, symbolize_names: true)
  end
  
  def get_all_data
    url = URI.parse(@url_data)
    data_json = Net::HTTP.get(url)
    return JSON.parse(data_json, symbolize_names: true)    
  end
  
end