({
     /*-------------------------------------------------------- 
EDGE-88307
Method: doInit
Description: Method to get PDF response
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    doInit: function(component, event) {
        var idrec= component.get("v.recordId");
        console.log('idrec',idrec);
        var action = component.get("c.getInvoiceRequestDetails");
        component.set("v.loadingSpinner", true);
        action.setParams({
            invoiceId : idrec
        });
            action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:", state);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log("resp message", resp.customerAccountNumber +' '+resp.invoiceNumber);
                component.set("v.custAcc",resp.customerAccountNumber);                
            	component.set("v.invoiceNum", resp.customerAccountNumber+'&invoice='+resp.invoiceNumber);
                component.set("v.loadingSpinner", false);
            } else {
                console.log("error");
                component.set("v.loadingSpinner", false);
            }
            
        });
         $A.enqueueAction(action);
    }
});