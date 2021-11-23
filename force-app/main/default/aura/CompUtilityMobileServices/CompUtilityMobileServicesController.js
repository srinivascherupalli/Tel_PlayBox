({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
    },      
    onClickMobile: function(component, event, helper) {
        helper.fireGetServicesEvent(component, event, helper);
    },
    onClickNGUC: function(component, event, helper) {
        helper.fireGetServicesNGUCEvent(component, event, helper);
    },  
    handleGetServicesEvent: function(component, event, helper) {
        /*  alert('event --->sitesMap_V2 '+alert(JSON.stringify(event.getParam("sitesMap_V2"))));
        alert('event --->callFrom '+alert(JSON.stringify(event.getParam("callFrom"))));
        alert('event --->adborid '+alert(JSON.stringify(event.getParam("adborid"))));
        */
  },
    mobileDisplayAction: function(component, event, helper) {
        helper.mobileDisplayAction(component, event, helper);
    },
    mobileSelectionCompleted: function(component, event, helper) {
        helper.mobileSelectionCompleted(component, event, helper);
    },
});