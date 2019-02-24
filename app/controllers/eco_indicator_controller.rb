class EcoIndicatorController < ApplicationController

  def index
    scrape_gdp
    scrape_mhlw
    scrape_meti
  end

  def database
    gon.db_stat = StatisticsList.all
    gon.db_date = DateList.order('date_code DESC')
    gon.db_cat = CategoryList.all
    gon.db_nominal = NominalNationalEconomicAccounting.all
    gon.db_real = RealNationalEconomicAccounting.all
    gon.db_eof = ExpenditureOfHousehold.all
  end

  def statistics_data
    gon.db_stat = StatisticsList.all
    gon.db_date = DateList.order('date_code DESC')
    gon.db_cat = CategoryList.all
    gon.db_nominal = NominalNationalEconomicAccounting.all
    gon.db_real = RealNationalEconomicAccounting.all
  end
  
  def update_data
      #国民経済計算（名目）
      update_nea(NominalNationalEconomicAccounting.all,["0003109741","0003109786","0003109742"])
      
      #国民経済計算（実質）
      update_nea(RealNationalEconomicAccounting.all,["0003109766","0003109751","0003109767"])
      
      update_eoh_calyear(ExpenditureOfHousehold.all,["0002070009"])
      update_eoh_quarter(ExpenditureOfHousehold.all,["0002070002"])
  end

  def admini_controller
  end

  def show
    @db_stat = StatisticsList.all
    @db_date = DateList.order(:category_code)
    @db_cat = CategoryList.all    
    @db_test = ExpenditureOfHousehold.all
  end

#  helper_method :update_data
end

  # 統計ＩＤからＵＲＬを作成し、統計ＤＢリストを作成する（全共通）
  def update_statistics_list(stats_id)
    
    # APIアドレスの作成してJsonデータを取得し、parseして変数へ代入
    api_url = "https://api.e-stat.go.jp/rest/2.1/app/json/getStatsData"
    api_appid = "bb86c86ee575b3adfa4930ee0f17a74de14e57e6"
    @req_url = api_url +"?appId=" + api_appid +"&statsDataId=" + stats_id
    pp @req_url

    # データの取得
    req_uri = URI.parse(@req_url)
    data_json = Net::HTTP.get(req_uri)
    @data_all = JSON.parse(data_json, symbolize_names: true)    
  end

  
  #国民経済計算(NationalEconomicAccounting)
  def update_nea(db_datas,nea_id)
    read_cat01_code = "23"
    
    nea_id.each do |id|
      # ＵＲＬ作成～統計リスト作成のメソッドを呼び出し
      update_statistics_list(id)
      
      # 必要な項目をそれぞれ変数に代入
      @stat_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:@code]
      @stat_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:STAT_NAME][:"$"]
      @table_code = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:@id]
      @table_name = @data_all[:GET_STATS_DATA][:STATISTICAL_DATA][:TABLE_INF][:TITLE]
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
                  pp cat01[:@code]
                  if cat01[:@code] <= read_cat01_code and db_catlists.find_by(category_code:cat01[:@code]) == nil 
                     db_catlists.create(
                         category_code:cat01[:@code],
                         category_name:cat01[:@name]
                      )
                  end
                end
            end
          end
          
          data_value.each do |data|
            if data[:@cat01] <= read_cat01_code
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


  #家計消費支出＿年次(expenditure of households)　※年次，四半期はデータ構成が違うので注意！
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




  # 内閣府(Cabinet Office)
  def scrape_gdp
      url = 'https://www.esri.cao.go.jp/jp/news/index.html'
      link_url = "https://www.esri.cao.go.jp"

      charset = nil
      
      html = open(url) do |f|
          charset = f.charset
          f.read
      end
      
      doc = Nokogiri::HTML.parse(html, nil, charset)
  
      doc.xpath('//dl[@class = "topicsList"]').each do |node|
        @doc_dt = node.xpath("dt")
        @doc_dd = node.xpath("dd")
        @doc_a = node.xpath("dd/a")
      end
      
      @doc_href = []
      @doc_a.each do |a|
        a_href = a[:href]
        a_href[0..4] = link_url
        @doc_href.push(a_href)
      end

  end
  
  # 厚生労働省（Ministry of Health, Labour and Welfare）
  def scrape_mhlw
      url = "https://www.mhlw.go.jp/toukei/saikin/"
      html = open(url, "r:utf-8").read
      
      doc = Nokogiri::HTML.parse(html, nil)
      
      @mhlw_href = []
      @mhlw_time = []
      @mhlw_span = []
      
      doc.xpath('//ul[@class = "m-listNews"]/li').each do |node|
        node_a = node.xpath("a")
        node_a.each do |a|
          a_href = a[:href]
          @mhlw_href.push(a_href)
        end
        
        time = node.xpath("a/div/time").inner_text
        @mhlw_time.push(time)
        
        span = node.xpath("a/div/span").inner_text
        @mhlw_span.push(span)
      end
  end
  
  # 経済産業省(Ministry of Economy, Trade and Industry)
  def scrape_meti
      url = "http://www.meti.go.jp/statistics/index.html"
      html = open(url, "r:utf-8").read
      
      doc = Nokogiri::HTML.parse(html, nil)
      @meti_time = []      
      @meti_href = []
      @meti_text = []
      
      doc.xpath('//div[@class = "NewsList"]/ul[1]/li').each do |node|
        time = node.xpath("text()")
        @meti_time.push(time)
        
        node_a = node.xpath("a")
        node_a.each do |a|
          a_href = a[:href]
          if !a_href.include?("meti.go.jp")
            a_href.insert(0,"http://www.meti.go.jp/statistics/")  
          end

          a_text = a.xpath("text()")
          
          @meti_href.push(a_href)
          @meti_text.push(a_text)
        end
      end
  end