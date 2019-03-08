def chart_bar_gdp
    db_date = DateList.all
    db_nominal = NominalNationalEconomicAccounting.all
    db_real = RealNationalEconomicAccounting.all

    @date_lavels = Array.new
    @real_datas = Array.new
    @nominal_datas = Array.new

    db_date.each do |date|
      if date.date_unit == "時間軸（年度）"
        @date_lavels.push(date.date_name)
        @real_datas.push(db_real.find_by(date_code: date.date_code).data)
        @nominal_datas.push(db_nominal.find_by(date_code: date.date_code).data)
      end
    end

    cookies[:lavels] = @date_lavels
    cookies[:r_datas] = @real_datas
    cookies[:n_datas] = @nominal_datas
end