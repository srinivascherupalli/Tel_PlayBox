({
    getRecurringData : function(component, event, helper) {
        helper.makeCallout(component, event, helper);
    },
    
    sectionRecurring : function(component, event, helper) {
        var sectionValue = event.currentTarget.dataset.value;
        if(sectionValue){
            helper.helperRecurring(component,event,sectionValue);
        }
    }    
    
})