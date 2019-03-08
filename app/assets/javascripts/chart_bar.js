function bar_gdp(){

  var lavel = gon.date_lavels;
  var r_data = gon.real_datas;
  var n_data = gon.nominal_datas;
  
  var ctx = document.getElementById("gdp_bar_chart").getContext("2d");
  var gdp_bar_chart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: lavel,
      datasets: [
        {
          label: '実質',
          data: r_data,
          backgroundColor: "rgba(219,39,91,0.5)"
        },{
          label: '名目',
          data: n_data,
          backgroundColor: "rgba(130,201,169,0.5)"
        }
      ]
    },
    options: {
      title: {
        display: true,
        text: '国内総生産（ＧＤＰ）'
      },
      scales: {
        yAxes: [{
          ticks: {
            suggestedMin: 0,
            stepSize: 50000
          }
        }]
      },
    }
  });
}