({
	 doInit: function(component,event,helper) {
    	var action=component.get("c.getData");
        console.log('--- rec id'+component.get("v.recordId"));
        action.setParams({"fieldSetname":component.get("v.FieldsetName"),
                          "recordid":component.get("v.recordId")
                          });
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.queAndAns",response.getReturnValue());
                console.log('chec vals--'+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
            
    myAction : function(component, event, helper) {
		
	},
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        alert(changeValue);
    },
    handleUpdateRecord: function(component, event, helper) {
        component.find("ApplicantOperation").saveRecord($A.getCallback(function(saveResult) {
            
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type":"success"
                    
                });
                toastEvent.fire();
            
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult.error));
                component.set("v.recordError",JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
       
    },
    navigateToMyComponent : function(component, event, helper) {
   		helper.validateForm(component, event, helper);
    },
    
    
})