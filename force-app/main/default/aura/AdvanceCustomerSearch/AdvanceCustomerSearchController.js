({
    //EDGE-31363
    doSearchCustomer : function(component, event, helper) {
        component.set("v.customers", null);
        component.set('v.resultloaded', !component.get('v.resultloaded'));
        // get the page Number if it's not define, take 1 as default
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.   
        var recordToDisply = component.find("recordSize").get("v.value");
        // call the helper function   
        helper.searchCustomers(component, page, recordToDisply);
        
    },
    
    //EDGE-31363
    navigate: function(component, event, helper) {
        component.set('v.resultloaded', !component.get('v.resultloaded'));
        // this function call on click on the previous page button  
        var page = component.get("v.page") || 1;
        // get the previous button label  
        var direction = event.getSource().get("v.label");
        // get the select option (drop-down) values.  
        var recordToDisply = component.find("recordSize").get("v.value");
        // set the current page,(using ternary operator.)  
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        // call the helper function
        helper.searchCustomers(component, page, recordToDisply);
    },
    
    //EDGE-31363
    onSelectChange: function(component, event, helper) {
        component.set('v.resultloaded', !component.get('v.resultloaded'));
        // this function call on the select opetion change,	 
        var page = 1
        var recordToDisply = component.find("recordSize").get("v.value");
        helper.searchCustomers(component, page, recordToDisply);
    },
    
    //EDGE-31363
    handleClearButton: function(component, event, helper){       
        helper.toggleClearButton(component);  
    },
    
    //EDGE-31363
    clearFilterCriteria: function(component, event, helper){
        helper.clearFilterCriteria(component);
    },
    
    //EDGE-31363
    validateString : function(component, event, helper){
        helper.validateCustomerName(component);
    },
    
    //EDGE-31363
    viewCustomerDetails : function(component, event, helper){
        helper.getCutomerDetailsURL(component,event);
    },
    
    //EDGE-31363
    handleOnCheckInputChange : function(component, event, helper){
        helper.handleCustomerSelectCheckboxButton(component, event);
    },
    
    //EDGE-31363
    handleSyncClick : function(component, event, helper){
        component.set('v.resultloaded', !component.get('v.resultloaded'));
        helper.createCaseInSFDC(component, event);
    },
    handleCreateLeadClick : function(component, event, helper){
        helper.createLead(component, event);
    }
})