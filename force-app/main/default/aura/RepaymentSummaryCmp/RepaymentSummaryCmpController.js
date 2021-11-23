({
	doInit : function(component, event, helper) {
        
        helper.getdoInit(component, event);
		//Setting columns for lightning data table
        component.set('v.columns', [  
            {label: 'Purchase Date', fieldName: 'purchaseDate', type: 'text',sortable:true},
            {label: 'Repayment Number', fieldName: 'installment', type: 'text',sortable:true},
            {label: 'Repayment', fieldName: 'unitPrice', type: 'text',sortable:true},
            {label: 'Charged So Far', fieldName: 'chargedSoFar', type: 'text',sortable:true},
            {label: 'Total Remaining', fieldName: 'totalRemaining', type: 'text',sortable:true },
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
    	helper.SearchUsageData(component, event);
    },
})