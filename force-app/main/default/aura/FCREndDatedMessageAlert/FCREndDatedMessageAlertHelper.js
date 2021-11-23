({
	processEndDatedFCR : function(component, event, helper) {
        //EDGE - 35520 AC5
        var action = component.get("c.isFCREndDatedHavingActiveACR");
		action.setParams({ fcrId : component.get("v.recordId") });
		
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.IsFCREndDatedWithNonAuthACR", response.getReturnValue())
                //alert("From server: " + response.getReturnValue());
                console.log("From server: " + response.getReturnValue());
			}
            else if (state === "INCOMPLETE") {
                console.log("Lightning Cmp-> FCREndDatedMessageAlert-> Trasaction State Incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Lightning Cmp-> FCREndDatedMessageAlert-> Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Lightning Cmp-> FCREndDatedMessageAlert-> Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})