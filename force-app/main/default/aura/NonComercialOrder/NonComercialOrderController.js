({
	doInit : function(cmp, event, helper) {
        console.log('inside init...');
        var action = cmp.get("c.checkEligibleUser");
        action.setParams({ accountId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Inside Success...'+response.getReturnValue());
                if(response.getReturnValue()){
                    cmp.set("v.enableNonCommercialOrder", response.getReturnValue());
                }
                else{
                    console.log('display error...');
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "mode": "sticky",
                        "type": "error",
                        "message": "You must be a Partner of Record for this Account to raise a non-commercial order."
                    });
                    resultsToast.fire();

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
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
    },
    
    closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	} 
})