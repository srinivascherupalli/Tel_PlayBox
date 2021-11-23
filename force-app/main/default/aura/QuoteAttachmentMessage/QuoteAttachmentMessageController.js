({
    doInit : function(component, event, helper) {
        
       var actionUserInfo = component.get("c.userInfoPRM");
      actionUserInfo.setCallback(this, function(response) {
          var state = response.getState();
          if(component.isValid() && state === "SUCCESS") {
              if(response.getReturnValue()){
                  component.set("v.timeInterval", 1000);
              }
               else
                   component.set("v.timeInterval", 10);
          }
          else if(state === "ERROR"){

          }
      });
      $A.enqueueAction(actionUserInfo);

        var action = component.get("c.displayError");
        if(action!=undefined)
       {component.set("v.ShowSpinner",true);
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
           var state = response.getState();
            helper.getMessageOnStatus(component, event, helper, state)
           if (state === "SUCCESS") {
                 //  alert('******> '+response.getReturnValue())
                component.set("v.displayError",response.getReturnValue());
                component.set("v.ShowSpinner",false);
           }
           else if (state === "INCOMPLETE") {
                console.log("Processing...");
               component.set("v.ShowSpinner",false);
           }
           else if (state === "ERROR") {
               component.set("v.ShowSpinner",false);
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       console.log("Error message: " +
                                errors[0].message);
                   }
               } else {
                   console.log("Unknown error");
               }
           }
       });
       $A.enqueueAction(action);
      }
       window.setInterval(
           $A.getCallback(function() {
               helper.getQuoteStatus(component,  event, helper);
           }), component.get("v.timeInterval")
       );
    },
   waiting: function(component, event, helper) {
    // component.set("v.HideSpinner", true);
},
    doneWaiting: function(component, event, helper) {
     //component.set("v.HideSpinner", false);
}
})