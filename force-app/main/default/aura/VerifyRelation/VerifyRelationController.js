({  
    loadAgain : function(component, event, helper){
        helper.loadAgainHelper(component, event, helper);
    },
    
    saveClick : function(component, event, helper) {
        helper.saveClickHelper(component, event, helper);
    },
    cancelClick : function(component, event, helper) {
        helper.cancel(component, event, helper);
    }
})