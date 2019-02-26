class EcoIndicatorController < ApplicationController
require_relative "./concerns/class_stats_api_nea"

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
    gon.db_date = DateList
    gon.db_cat = CategoryList.all
    gon.db_nominal = NominalNationalEconomicAccounting.all
    gon.db_real = RealNationalEconomicAccounting.all
  end
  
  def update_data

      #名目原系列＿四半期
      nea_data = Api_nea.new(stats_id: "0003109741",database: NominalNationalEconomicAccounting.all)
      nea_data.create_database_nea
      
      #名目原系列＿暦年
      nea_data = Api_nea.new(stats_id: "0003109786",database: NominalNationalEconomicAccounting.all)
      nea_data.create_database_nea
      
      #名目原系列＿年度
      nea_data = Api_nea.new(stats_id: "0003109742",database: NominalNationalEconomicAccounting.all)
      nea_data.create_database_nea
      
      #実質原系列＿四半期
      nea_data = Api_nea.new(stats_id: "0003109766",database: RealNationalEconomicAccounting.all)
      nea_data.create_database_nea

      #実質原系列＿暦年
      nea_data = Api_nea.new(stats_id: "0003109751",database: RealNationalEconomicAccounting.all)
      nea_data.create_database_nea

      #実質原系列＿年度      
      nea_data = Api_nea.new(stats_id: "0003109767",database: RealNationalEconomicAccounting.all)
      nea_data.create_database_nea
      
      # update_eoh_calyear(ExpenditureOfHousehold.all,["0002070009"])
      # update_eoh_quarter(ExpenditureOfHousehold.all,["0002070002"])
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