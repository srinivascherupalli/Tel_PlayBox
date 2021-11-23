/* **************************************************************************
EDGE        -88306
component   -BillingAccountPaymentAndAdjustment Controller
Description -BillingAccountPaymentAndAdjustment JS controller
Author      -Dheeraj Bhatt
********************************************************************************* */
({
    doInit: function(component, event, helper) {
        component.set("v.billingAccountId",component.get("v.recordId"));
        //EDGE-162804 Start
        var action = component.get("c.checkPRMActivePOR");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resStr = response.getReturnValue();
                console.log('res::'+resStr);
                component.set("v.checkPOR",resStr);
            }			
        });
        $A.enqueueAction(action);   
        //EDGE-162804 End
    }
})