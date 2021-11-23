({  
    loadAgainHelper : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        urlEvent.fire();
    
	},
    
	saveClickHelper : function(component, event, helper) {
        var action = component.get("c.saveRecord");
        action.setParams({
            "acrId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
           
            if(response.getState()=="SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration : 2500,
                    "message": "The Record Is Successfully Saved.",
                    type: "success" 
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                
               
            } else if(response.getState()=="ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration : 2500,
                    "message": "Failed To Save The Record",
                    type: "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
         });
        $A.enqueueAction(action);
		
	},
    cancel :function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
           
        });
        navEvt.fire();
        
       
    }
})