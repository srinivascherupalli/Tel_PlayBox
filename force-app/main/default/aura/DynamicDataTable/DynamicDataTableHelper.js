({
    getTabledetails : function(component,event, helper){
        var action = component.get("c.getdataTable");
        action.setParams({
            "tableId": component.get("v.tableId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Inside getTabledetails>>>>'+state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log("getTabledetails",data);
                if(data != null && data != undefined){
                    component.set("v.pageSize", data.Page_Size__c);
                    component.set("v.keyvalue", data.key_Value__c);
                    component.set("v.header", data.Header__c);
                    component.set("v.hidecheckbox", data.hidecheckbox__c);
                    
                    component.set("v.IsShowCSV", data.IsShowCSV__c); 
                    component.set("v.tabledata",data);
                    console.log('Keyvalue>>>>'+ component.get("v.keyvalue"));
                    helper.doInitHelper(component);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    processSelectedrecords : function(component,event, helper){
        var current = component.get("v.currentPage");  
        console.log('current>>>'+current);
        var dTable = component.find("tableId");
        var selectedRows = dTable.getSelectedRows();
        var pgName = "page" + current;
        component.get("v.SelectedRecords")[pgName] = selectedRows;
        current = current +1;
        pgName = "page" + current;
        var selectedRows = component.get("v.SelectedRecords")[pgName];
        var dTable = component.find("tableId");
        var selectedRows = dTable.getSelectedRows();
        var keyvalue = component.get("v.keyvalue");
        console.log('selectedRows>>>'+selectedRows);
        var selectRowsIds =[];
        var selectRowsIndex =[];
        var pageSize = component.get("v.pageSize");
        var data = component.get("v.data");
        var totalpage = Math.ceil(data.length / pageSize);
        component.set("v.totalPages",totalpage);
        for(var i=0; i<= totalpage; i++){
            var cpage = "page" + i;
            var selectedPagerows = component.get("v.SelectedRecords")[cpage];
            console.log(selectedPagerows);
            if(selectedPagerows != undefined){
                for(var j = 0 ; selectedPagerows.length > j; j++){
                    selectRowsIds.push(selectedPagerows[j]);
                    selectRowsIndex.push(selectedPagerows[j][keyvalue]);
                }
            }
        }
          //new start
         if(component.get("v.showFirstLast")){
           
            //helper.updateSelected(component, event,selectRowsIndex);//EDGE-144140 - Kalashree - Pre-select rows
        }
        //new end
        var dTable = component.find("tableId");
        dTable.set("v.selectedRows", selectRowsIndex);
        var cmpEvent = component.getEvent("tableevent");
        cmpEvent.setParams({
            "tableName" : component.get("v.tableId"),
            "selectedrecords" : selectRowsIds
        });
        cmpEvent.fire();
    },
    doInitHelper : function(component) {
        var preselectRows=[];
        var pageSize = component.get("v.pageSize");
        var data = component.get("v.data");
        console.log('number data list ',data);
        // get size of all the records and then hold into an attribute "totalRecords"
        if(data != null){
            component.set("v.totalRecords", data.length);
            //Set the current Page as 0
            component.set("v.currentPage",0);
            // set star as 0
            component.set("v.startPage",0);
            component.set("v.endPage",pageSize-1);
            var dataWithForError = [];
            var dataWithOutError = [];
            var containsError = false;
            for(var i=0;i<data.length;i++){
                if(data[i].status==='Error'){
                    console.log('found one error');
                    dataWithForError.push(data[i]);
                    containsError = true;
                }else{
                    dataWithOutError.push(data[i]);
                }
            }
            if(containsError){
                var sortedDataList = dataWithForError.concat(dataWithOutError);
                data = sortedDataList;
                console.log('error when data is loading '+data);
               
            }
            
            var PaginationList = [];
            //new start DIGI 868
            var showPreselect = true;
             for(var i=0; i< pageSize; i++){
                 if(component.get("v.data").length> i){
                     if(data[i].isIncluded=='Yes'){
                         showPreselect=false;
                         break;
                     }
                     else{
                         showPreselect=true;
                     }
                 }
             }
            for(var i=0; i< pageSize; i++){
                if(component.get("v.data").length> i){
                    PaginationList.push(data[i]);
                    if(showPreselect==true){
                        data[i].isSelected=true;
                    	preselectRows.push(data[i].qualifiedMsisdn);
                    }
                }
            }
             //new end DIGI 868
            var totalpage = Math.ceil(data.length / pageSize);
            component.set("v.totalPages",totalpage);
            component.set("v.selectedRows",preselectRows);
            component.set('v.PaginationList', PaginationList);


            
            if(containsError){
                debugger;
                console.log('dataWithForError',dataWithForError);
                var action = component.get("c.resetErrorCheckBoxOnNumbers");
                action.setParams({
                    numberListObject : dataWithForError
                });
                action.setCallback(this, function(response){
                    debugger;
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        console.log('error data recieved '+response);
                    }else{
                        console.log('cannot recieve error data');
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    next : function(component, event){
        var current = component.get("v.currentPage");    
        var dTable = component.find("tableId");
        var selectedRows = dTable.getSelectedRows();
        var pgName = "page" + current;
        component.get("v.SelectedRecords")[pgName] = selectedRows;
        current = current +1;
        pgName = "page" + current;
        var selectedRows = component.get("v.SelectedRecords")[pgName];
        component.set("v.currentPage",current);
        console.log("Next selectedAccount "+JSON.stringify(component.get("v.SelectedRecords")));        
        var sObjectList = component.get("v.data");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
                 console.log('sObjectList[i]: ',sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        
        console.log('>>>>'+component.get("v.keyvalue"));
        var keyvalue = component.get("v.keyvalue");
        if (typeof selectedRows != 'undefined' && selectedRows) {
            var selectedRowsIds = [];
            for(var i=0;i<selectedRows.length;i++){
                selectedRowsIds.push(selectedRows[i][keyvalue]);  
            }         
            var dTable = component.find("tableId");
            console.log('Next >>>>'+selectedRowsIds);
            dTable.set("v.selectedRows", selectedRowsIds); 
        }
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);      
    },
    /*-------------------------------------------------------- 
EDGE		-144140
Method		-first
Description	-show first set of records
Author		-Kalashree
--------------------------------------------------------*/
    first: function(component, event){  
        var sObjectList = component.get("v.data");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        for(var i=0; i< pageSize; i++)
        {
            paginationList.push(sObjectList[i]);
        }
        component.set('v.PaginationList', paginationList);
        component.set("v.startPage",0); 
        component.set("v.endPage",pageSize-1);
        
    },
    /*-------------------------------------------------------- 
EDGE		-144140
Method		-updateSelected
Description	-preselect rows
Author		-Kalashree
--------------------------------------------------------*/
     updateSelected: function(component, event,selectRowsIndex){  
        var data = component.get("v.PaginationList");
        var lst = [];
        var selectedRows = component.get("v.selectedRows");
        for(var i=0;i<data.length;i++){
            if(selectRowsIndex.includes(data[i].qualifiedMsisdn)){
                data[i].isIncluded = 'No';//DIGI-868
                data[i].isSelected = true;
                selectedRows.push(data[i].qualifiedMsisdn);
            }
            else{
                data[i].isIncluded = 'No';
                data[i].isSelected = false;
            }
        }
        component.set("v.selectedRows",selectedRows);
        component.set("v.PaginationList",data); 
    },
/*-------------------------------------------------------- 
EDGE		-144140
Method		-last
Description	-show last set of rows
Author		-Kalashree
--------------------------------------------------------*/
    last: function(component, event){  
        var sObjectList = component.get("v.data");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalPages");
        var totalRecords = component.get("v.totalRecords");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var paginationList = [];
        var counter=0;
        //var iteratior = (totalSize*pageSize)-pageSize;
        var iteratior = totalRecords-(totalRecords%pageSize);
        for(var i=iteratior; i< totalRecords; i++){
            paginationList.push(sObjectList[i]);
            console.log('sObjectList[i]',sObjectList[i]);
            counter++;
        }
        //end = totalRecords -  (totalRecords%pageSize) - pageSize;
        start = totalRecords -  (totalRecords%pageSize) ;
        //end = end + counter; 
        //end = totalRecords + (totalRecords%pageSize) + 1; 
        end = (pageSize*totalSize)-1;
        component.set("v.PaginationList", paginationList); 
		component.set("v.endPage",end);
		component.set("v.startPage",start);
    },
    previous : function(component, event){   
        var current = component.get("v.currentPage");
        console.log("current page: ",current);
        var dTable = component.find("tableId");
        var selectedRows = dTable.getSelectedRows();
        var pgName = "page" + current;
        component.get("v.SelectedRecords")[pgName] = selectedRows;
        current = current - 1; 
        pgName = "page" + current;
        var selectedRows = component.get("v.SelectedRecords")[pgName];
        component.set("v.currentPage",current);
        console.log("Prev SelectedRecords "+JSON.stringify(component.get("v.SelectedRecords")));        
        var sObjectList = component.get("v.data");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        
        var keyvalue = component.get("v.keyvalue");
        if (typeof selectedRows != 'undefined' && selectedRows) {
            var selectedRowsIds = [];
            
            for(var i=0;i<selectedRows.length;i++){
                console.log(selectedRows[i]); 
                console.log('keyValue>>>>' + selectedRows[i][keyvalue]); 
                selectedRowsIds.push(selectedRows[i][keyvalue]);  
            }         
            var dTable = component.find("tableId");
            dTable.set("v.selectedRows", selectedRowsIds);
            console.log('selectedRowsIds>>>'+selectedRowsIds);
        }
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        console.log('>>>>'+component.get("v.keyvalue"));
    },
    sortData : function(component,fieldName,sortDirection){
        
        var data = component.get("v.data");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'NumberOfEmployees'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        var selectedRowsList = [];
        console.log('data: ',data);
        for(var i=0;i<data.length;i++){
            if(data[i].isSelected==true){
                selectedRowsList.push(data[i].qualifiedMsisdn);
            }     
        }
        console.log('selectedRowsList: ',selectedRowsList);
        component.set("v.selectedRows",selectedRowsList);
        component.set("v.data",data);
        
    },
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, columnDivider, lineDivider;
        var keys=[];
        var header=[];
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        var columns = component.get("v.columns");
        for(var i=0; i<columns.length>0;i++){
            header.push(columns[i].label);// this labels use in CSV file header  
            keys.push(columns[i].fieldName);// in the keys valirable store fields API Names as a key
        }
        csvStringResult = '';
        csvStringResult += header.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) { 
                var skey = keys[sTempkey] ;
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                
                csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    }
})