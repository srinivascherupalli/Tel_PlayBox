({
	showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case Assigned",
            "type":'success',
            "message": "Owner has been updated successfully."
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event, helper,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',            
            message: 'Mandatory Fields: '+msg,
            type: 'error',
            mode:'sticky'
        });
        toastEvent.fire();
    },
})