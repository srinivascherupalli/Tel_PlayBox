({
	initHelper : function(component, event) {
		
        var action = component.get("c.enqueueQLI");
         action.setParams({
            'caseId': component.get("v.caseId")
        });
        
               // set call back
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 console.log(response.getReturnValue()); 
                component.set("v.isSuccess",response.getReturnValue());
            } 
        });
        // enqueue the server side action
        $A.enqueueAction(action);
	}
})