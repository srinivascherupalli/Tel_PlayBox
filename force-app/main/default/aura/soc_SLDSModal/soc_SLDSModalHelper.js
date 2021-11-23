({
	fetchClonedCaseRecord : function(component, event, helper) {        
        var recordId = component.get('v.recordId');        
        var action = component.get("c.fetchClonedCase");
        action.setParams({ Id : recordId});   
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === "SUCCESS") {    
                console.log('Cloned Case >>>>>>>>>>>');
                console.log(response.getReturnValue());
                var data=response.getReturnValue();
                component.set('v.parentRecord',data);
                console.log(data.Subject);
            }                     
        });
        $A.enqueueAction(action);		
	}
})