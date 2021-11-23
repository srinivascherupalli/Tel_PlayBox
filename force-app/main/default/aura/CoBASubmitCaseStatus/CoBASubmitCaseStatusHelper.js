({
 //Display the toast message using the tost type and message provided by the developer.
 showToastMessage : function(type,message) {
         var toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams({
         Title:'title',
         type:type,
         message:message
         });
         $A.get("e.force:closeQuickAction").fire();
         toastEvent.fire();
         $A.get('e.force:refreshView').fire();
    }
})