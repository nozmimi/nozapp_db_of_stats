function nea_data(date_unit,database,tableTitle,tableData){

    var date = gon.db_date;
    var cat = gon.db_cat;
    var stat = gon.db_stat;
    var data = database;
    
    var text
    
    var colName = ["11","12","13","14","15","16","17","18","19","20","21","22","23"];

    for( i=0; i<cat.length; i++){
        for(j=0; j<colName.length; j++){
            switch (cat[i]["category_code"]) {
                case colName[j]:
                    var tHead = document.createElement("th");
                        tHead.appendChild(document.createTextNode(cat[i]["category_name"]));
                        tableTitle.appendChild(tHead);
            }
        }
    };  

    
    for(i=0; i<date.length; i++){
        switch (date[i]["date_unit"]) {
            case date_unit:
                var tRow = tableData.insertRow( -1 );
                    tRow.classList.add("text-right");
        
                var tHead = document.createElement("th");
                    tHead.classList.add("text-left");
        
                tRow.appendChild(tHead).appendChild(document.createTextNode(date[i]["date_name"]));
                
                for(j=0; j<data.length; j++){
                    for(k=0; k<colName.length; k++){
                        if(data[j]["date_code"]==date[i]["date_code"] && data[j]["category_code"]==colName[k]){
                            tRow.insertCell( -1 ).appendChild(document.createTextNode((data[j]["data"]*10).toLocaleString()));
                        }
                    }
                }
                break;

        }
    }
}