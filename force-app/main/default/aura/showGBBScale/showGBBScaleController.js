({
    doInit : function(component, event, helper) {
        helper.getGBBScaleHelper(component, event);
    },
	getOfferGBBScale : function(component, event, helper) {
        //component.set("v.showSpinner",true);
        var action = component.get("c.Samplemethod");
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
                    var responsenew =response.getReturnValue();
					helper.getGBBScaleHelper(component, event);
                    component.set("v.showSpinner",false);
                }else if (state === "INCOMPLETE"){}
                    else if (state === "ERROR"){
                        var errors = response.getError();
                        if (errors){
                            if (errors[0] && errors[0].message){
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
        }); 
        $A.enqueueAction(action);
	}
})