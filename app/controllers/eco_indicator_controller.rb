class EcoIndicatorController < ApplicationController
require_relative "./concerns/class_stats_api_nea"
require_relative "./concerns/scrape"
require_relative "./concerns/chart_bar_gdp"

  def index
    chart_bar_gdp
    gon.date_lavels = @date_lavels
    gon.real_datas = @real_datas
    gon.nominal_datas = @nominal_datas
    
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

  def statistics_graph
    db_date = DateList.all
    db_nominal = NominalNationalEconomicAccounting.all
    db_real = RealNationalEconomicAccounting.all
    gon.test = [33, 45, 62, 55, 31, 45, 38]

    date_lavels = Array.new
    real_datas = Array.new
    nominal_datas = Array.new

    db_date.each do |date|
      if date.date_unit == "時間軸（年度）"
        date_lavels.push(date.date_name)
        real_datas.push(db_real.find_by(date_code: date.date_code).data)
        nominal_datas.push(db_nominal.find_by(date_code: date.date_code).data)
      end
    end

    gon.date_lavels = date_lavels
    gon.real_datas = real_datas
    gon.nominal_datas = nominal_datas
  end

#  helper_method :update_data
end
