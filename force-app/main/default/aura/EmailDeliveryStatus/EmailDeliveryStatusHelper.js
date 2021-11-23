({
    getData : function(cmp) {
        var action = cmp.get("c.getEmailMessage");
        action.setParams({RelatedId : cmp.get("v.recordId")});
       //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
         cmp.set('v.EmailDeliveryStatus__c', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
      }
})