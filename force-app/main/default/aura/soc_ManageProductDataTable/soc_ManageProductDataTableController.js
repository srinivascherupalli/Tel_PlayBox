({
    init: function (component, event, helper) {  
        debugger;
        helper.initialize(component,event,helper);        
        component.set('v.columns', [
            {label: 'Product Name', fieldName: 'productName', type: 'text'},
            {label: 'Order Number', fieldName: 'OrderNumber', type: 'text'}            
        ]);        
    },
    
    updateSelectedText: function (component, event) {        
        var selectedProducts=component.get('v.selectedRows');        
        var selectedRows = event.getParam('selectedRows');
        var totalRows = component.get('v.data');
        component.set('v.selectedRows',selectedRows);          
        if(selectedRows.length > 0){
            	component.set('v.buttonDisabled',false); 
        }
        else{
            component.set('v.buttonDisabled',true);
        }
    },
    
    next : function(component, event, helper) { 
        component.set('v.pageType','caseEditForm');
    },
    
    closeModal : function(component, event, helper) {        
        component.set("v.openDataTable", false);
        component.set("v.isOpen", false);
    }     
    
})