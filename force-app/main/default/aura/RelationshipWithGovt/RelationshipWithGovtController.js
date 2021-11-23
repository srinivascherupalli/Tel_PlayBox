({
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
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
    }
})