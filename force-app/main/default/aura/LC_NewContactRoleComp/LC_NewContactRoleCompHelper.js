({
	initialize : function(component, event, helper) {
       var action = component.get("c.picklist_values");        
        action.setParams({ object_name : 'OpportunityContactRole',field_name : 'Role'});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {  
                var data=response.getReturnValue(); 
                console.log('doInit -- Role --PICKLIST  RESPONSE');
                console.log(data);
          	    var seltedrole = component.get("v.Opptyconrole.Role");
                component.set('v.options',data);
                component.set('v.selectedval',seltedrole);
            }    
        });        
        $A.enqueueAction(action);		
	}
})