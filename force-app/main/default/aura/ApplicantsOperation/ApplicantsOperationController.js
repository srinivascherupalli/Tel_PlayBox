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
    handleUpdateRecord: function(component, event, helper) {
    	helper.updateRecord(component, event);
    },
})