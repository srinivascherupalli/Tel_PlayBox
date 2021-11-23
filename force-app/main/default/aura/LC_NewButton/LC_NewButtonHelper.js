({
	executeAction: function(cmp, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var retVal=response.getReturnValue();
                    resolve(retVal);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    }
                    else {
                        reject(Error("Unknown error"));
                    }
                }
            });
        $A.enqueueAction(action);
        });
	},

    createbasket: function(component, event,basketMap,pathPrefix){
        
        var retURL = pathPrefix;
        var action = component.get("c.createBasketRecord");
        			action.setParams({
            							'jsonBasketMap': basketMap
          							 });
            action.setCallback(this, function(action) {
                var state = action.getState();
                if (state === "SUCCESS") {  
                    var basketId = action.getReturnValue();
                    var urlEncoded = encodeURIComponent("/apex/csbb__basketbuilderapp?Id=") + basketId;
                
                 window.location.href = retURL + "/s/sfdcpage/" + urlEncoded;
                    
                }
                else if (state === "ERROR") {
                    component.set('v.showError', false);
                component.set('v.ErrorMap', 'Basket record could not be created.');
                }
            })
            $A.enqueueAction(action);

    
    }
})