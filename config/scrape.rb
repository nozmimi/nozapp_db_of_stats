def Scrape_gdp
        url = 'https://www.esri.cao.go.jp/jp/news/2018/index.html#lst12'
    
        charset = nil
        
        html = open(url) do |f|
            charset = f.charset
            f.read
        end
        
        doc = Nokogiri::HTML.parse(html, nil, charset)
        
    def gdp_inf
        doc.xpath('//a[@name="lst10"]/preceding-sibling::dl[@class = "topicsList"]').each do |node|
          node.xpath("dt").each do |text|
            pp text.inner_text
          end
          
          node.xpath("dd").each do |text|
            pp text.inner_text
          end  
        end
    end
end