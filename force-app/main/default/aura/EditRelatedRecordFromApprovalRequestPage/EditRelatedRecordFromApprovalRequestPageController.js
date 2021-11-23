/****************************************************************************
@Name        :   EditRelatedRecordFromApprovalRequestPage
@Author      :   Sri,Amar (Team SFO)
@CreateDate  :   08/27/2020
@Description :   Sprint 20.12 ; P2OB-9282, 
                This componet is to edit the related record from an approval requeest page
*****************************************************************************/
({
	init : function(component, event, helper) {
        var array = [];
        array = component.get("v.fieldsToDisplay").split(',');
        component.set('v.fields', array);
        var cardHeader = component.get("v.cardHeader");
        if(cardHeader == null){
            component.set("v.cardHeader", 'Update '+component.get("v.objectApiName")+' Details');
        }

        if(component.get("v.objectApiName") === component.get("v.sObjectName")){
            component.set("v.targetRecordId", component.get("v.recordId"));            
            return;
        }

        var recId = component.get("v.recordId");  
        var filterString = component.get("v.filterString");
        var action = component.get("c.getRelatedRecord");
        action.setParams({recId : recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.targetRecordId",response.getReturnValue());
                var accrecId = component.get("v.targetRecordId.AccountId");  
                if(!$A.util.isEmpty(component.get("v.targetRecordId.AccountId")))
                {
                    filterString = filterString.replace('#ACCOUNTID#', accrecId);
					component.set("v.filterString",filterString);   //Passing Account Id as Input to Einstein Dashboard
					console.log('Value of filterstring is'+filterString);
                }
            }else if(state === "INCOMPLETE") {
                // do something
			}else if(state === "ERROR") {
				var errors = response.getError();
				if (errors){
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + 
						errors[0].message);
					}
				}else{
                console.log("Unknown error");
				}
			}
            // $A.get("e.force:refreshView").fire();
		});
        $A.enqueueAction(action);
	},

    handleSuccess : function(component, event, helper) {
		var SuccessMessage = component.get("v.SuccessMessage"); 
        $A.get('e.force:refreshView').fire();
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success",
            "message": SuccessMessage,
            "type": "Success"
        });
		toastEvent.fire();
        window.location.reload();
    },    
})