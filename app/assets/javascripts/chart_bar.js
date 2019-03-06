function chart_bar(){
  var ctx = document.getElementById("myBarChart");
  var myBarChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: gon.date_lavels,
      datasets: [
        {
          label: '名目',
          data: gon.nominal_datas,
          backgroundColor: "rgba(219,39,91,0.5)"
        },{
          label: '実質',
          data: gon.real_datas,
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
