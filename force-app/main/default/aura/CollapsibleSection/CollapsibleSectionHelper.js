({
	helperMethod : function() {
		
	},
     generateAppErrorScen : function(component, event, helper){
             component.set("v.loadingSpinner", true);
        var action = component.get("c.generateAppointmentForErrorScenario");
           //action.setParams({"ordId": component.get("v.orderId")});
           action.setParams({"SubscriptionId": component.get("v.subID")});
           action.setCallback(this, function(response) {
		
            var state = response.getState();
            if(state === "SUCCESS") {
                //component.set("v.order", response.getReturnValue());
                  component.set("v.loadingSpinner", false);
                
            } else {
                  component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
           
    }
})