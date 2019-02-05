function nea_data(tableTitle,tableData){

    var date = gon.db_date;
    var cat = gon.db_cat;
    var stat = gon.db_stat;
    var data = gon.db_nominal;
    
    var text
    
    var colName = ["11","12","16","19"];

    for( i=0; i<cat.length; i++){
        for(j=0; j<colName.length; j++){
            switch (cat[i]["category_code"]) {
                case colName[j]:
                    console.log(colName[j]);
                    console.log(cat[i]["category_name"]);

                    var tHead = document.createElement("th");
                        console.log(i);
                         tHead.appendChild(document.createTextNode(cat[i]["category_name"]));
                         tableTitle.appendChild(tHead);
            }    
        }
    };  

    
    for(i=0; i<date.length; i++){
        var tRow = tableData.insertRow( -1 );
            tRow.classList.add("text-right");
        
        var tHead = document.createElement("th");
            tHead.classList.add("text-left");
    
        tRow.appendChild(tHead).appendChild(document.createTextNode(date[i]["date_name"]));
        }
    }
