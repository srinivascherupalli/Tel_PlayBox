({	
    getCriteria: function(component) {
        var action = component.get('c.getCriteria');
        action.setParams({
            'blueSheetId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            component.set('v.criteria', response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    saveCriteria: function(component, selectedResponses) {
        var action = component.get('c.saveCriteria');
        action.setParams({
            'selectedResponses' : selectedResponses
        });
        
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"Success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
             //   toastEvent.fire();
                $A.get("e.force:refreshView").fire();
                $A.get("e.force:closeQuickAction").fire();
            }    
        });
        $A.enqueueAction(action);
    },
    
    closeModal: function(component) {
            $A.get("e.force:closeQuickAction").fire();

    }


})