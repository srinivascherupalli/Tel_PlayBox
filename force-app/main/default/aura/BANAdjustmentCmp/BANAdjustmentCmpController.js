/*EDGE -104930
Name: BanAdjustmentCmpController.js
Description: Js controller for BanAdjustmentCmp
Author:Mahima*/
({
	doInit : function(component, event, helper) {
        var enddate = new Date(); 
        component.set('v.EndDate',enddate);
        var enddatestr = helper.getDateString(enddate);
        
        component.find("edate").set("v.value", enddatestr);
        var startDate= new Date();
        component.set('v.StartDate',startDate);
        startDate.setMonth(startDate.getMonth() - 13);
        var startDatestr = helper.getDateString(startDate);
        component.find("sdate").set("v.value", startDatestr);        
        
        helper.setMaxdate(component, event);
		helper.doInit(component, event);
        
        //Setting columns for lightning data table
        component.set('v.columns', [  
            {label: 'ADJUSTMENT ID', fieldName: 'adjustmentId', type: 'text',sortable:true},
            {label: 'DESCRIPTION', fieldName: 'description', type: 'text',sortable:true},
            {label: 'DATE APPLIED', fieldName: 'dateApplied', type: 'string',sortable:true },
            {label: 'ADJUSTMENT AMOUNT', fieldName: 'adjustmentAmount', type: 'text',sortable:true},
            {label: 'AMOUNT APPLIED', fieldName: 'amountApplied', type: 'text',sortable:true},
            {label: 'AMOUNT UNAPPLIED', fieldName: 'amountUnapplied', type: 'text',sortable:true}            
        ]);
        
	},
    //Setting sorting field and direction for lightning data table
    updateColumnSorting: function (component, event, helper) {
        console.log('In Column Sort');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    // method to call controller method for getting adjustment data.
    getSearchData:function (component, event, helper) {
        helper.SearchAdjustmentData(component, event);
    },
    
    
})