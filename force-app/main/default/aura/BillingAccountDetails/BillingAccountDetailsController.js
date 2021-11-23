({
    //EDGE -147537
    updateRecord : function(component, event, helper) {
         if(component.get("v.billingRecord.Status__c") != 'Error' ){
        helper.billingAccountDetails(component,event,helper);
         }

	},
    handleApprovalProcessInitiation : function(component, event, helper) {
        helper.handleApprovalProcessInitiation(component, event);
    }, 

})