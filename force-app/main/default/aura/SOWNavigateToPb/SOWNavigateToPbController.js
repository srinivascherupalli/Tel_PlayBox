({
    doInit : function(component, event, helper){
    },
    recordUpdate : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");                     
        navEvt.setParams({
            "recordId": component.get("v.sowRecord").Basket__c,
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})