({  
   
	onclick : function(component, event, helper) {
		var recId = component.get('v.recordId');
        var action = component.get("c.updateCase");
        action.setParams({"recordId": recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
               
            } else {
                console.log('There was a problem : '+response.getError());
            } 
        });
        $A.enqueueAction(action);
	    $A.get('e.force:refreshView').fire();
    }
})