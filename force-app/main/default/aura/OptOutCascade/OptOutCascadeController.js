({
    doInit : function(component, event, helper,sortFieldName) {
        helper.onLoad(component, event, helper,sortFieldName);
    },
    sortByName : function(component, event, helper) {
       helper.sortHelper(component, event,helper, 'Account.name'); 
    },
    selectAllRecords : function(component, event, helper) {      
        helper.selectAllRecordsOfHelper(component, event, helper); 
    },
    checkSingleRecords : function(component, event, helper) {
        helper.checkSingleRecordsHelper(component, event, helper);
    },
    continueButton : function(component, event, helper) {
        helper.continueButtonHelper(component, event, helper);
    },
    sortByEndDate : function(component, event, helper) {
       helper.sortHelper(component, event,helper, 'Relationship_End_Date__c'); 
    }
})