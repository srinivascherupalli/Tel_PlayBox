({
	initialize : function(component,event,helper) {
     console.log('get User theme');
     var action = component.get("c.getUserTheme");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('User Theme >>>');
                console.log(storeResponse);
                var inputVariables = [{ name : "varSourceOfFlow", type : "String", value: 'aura' },
                                      { name : "varUITheme", type : "String", value: storeResponse }];
                console.log('inputVariables');  
    			console.log(inputVariables);  
                var flow = component.find("flowData");
     			flow.startFlow("salesup_Create_Sales_Service_Certitude_support_request_Dup",inputVariables);
            } 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
})