({
    doInit: function (component, event, helper) {
        // Set the columns of the Table
        helper.getTabledetails(component,event, helper);
    },
    getSelectedName: function (component, event, helper) {
        console.log('Inside getSelectedName'+component.get("v.selectedRows"));
       
        helper.processSelectedrecords(component, event, helper);
    },
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    first: function (component, event, helper) {
        helper.first(component, event);
    },
    last: function (component, event, helper) {
        helper.last(component, event);
    },
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        console.log('handleSort',handleSort);
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },
    handleSorting : function(component,event,helper){
        console.log('handleSort');
        component.set("v.loadingSpinner",true);
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
        component.set("v.loadingSpinner",false);
    },
    
    downloadCsv : function(component,event,helper){
        
        // get the Records [contact] list from 'data' attribute 
        var stockData = component.get("v.data");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})