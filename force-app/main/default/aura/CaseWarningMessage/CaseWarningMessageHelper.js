({
	getValueFromApex : function(component, event, param, setResponseValue, recordId) {
        var action = component.get(param);
        action.setParams({
            "id": component.get(recordId)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set(setResponseValue, response.getReturnValue());

                //console.log(component.get(setResponseValue));
            }
            else if (state === "ERROR") {
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
})