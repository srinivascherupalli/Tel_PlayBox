({
	doInit : function(component, event, helper) {
        helper.checkForAbleToAmend(component, event, helper);
        component.set("v.recordSelected",false);
		helper.getSelectedRecord(component, event, helper);
		helper.getOpportunityRecID(component, event, helper);
		helper.getOrderNumber(component, event, helper);
		helper.getAmendTypes(component, event, helper);
		helper.checkCurrentUserProfile(component, event, helper);
        // helper.defaultFieldsIfAmendRejected(component, event, helper);
        helper.checkAmendRestriction(component, event, helper);
	},
	onCancel: function (component, event, helper) {
        // Navigate back to the record view
        var orderId = component.get('v.recordId');
        
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": orderId,
            "slideDevName": "detail",
            "isredirect": "true"
        });
        
        navigateEvent.fire();
        //helper.showCustomToast(component, "Something broke", "Error Title", "error");
    },

    handleComponentEvent : function(component, event, helper){
        console.log('event response ',event.getParam("recordByEvent"));
        component.set("v.requestorEmpty",false);
    },

    handleRequestorRemoved : function(component, event, helper){
        console.log('Requestor removed');
        component.set("v.requestorEmpty",true);
    },

    handleRequestorSelected : function(component, event, helper){
        console.log('Requestor selected');
       console.log('requestor name on change --->',event.getParams('recordByEvent'));
    },

    handleAmendType : function(component, event, helper){
        console.log("amend type selected -----> ",component.get("v.amendTypeSelected"));
    },

    checkCaseNumber : function(component, event, helper){
        console.log('case number ',component.get("v.telstraCaseNumber"));
    }
})