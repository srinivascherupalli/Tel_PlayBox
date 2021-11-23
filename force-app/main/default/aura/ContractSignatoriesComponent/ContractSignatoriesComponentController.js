({ 
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);   
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        //component.set("v.userId", userId);        
    },
    handleSaveClick : function(component, event, helper) {
        component.set("v.SQDisableFlag", true);
        helper.insertTransactionLogs(component, event, helper);
        helper.handleSaveClick(component, event, helper);
    },
    toggle : function(component, event, helper) {
        helper.toggle(component, event, helper);
    },
    handleLookupSelectEvent : function (component, event, helper) {
        helper.handleLookupSelectEvent(component, event, helper);
    },


})