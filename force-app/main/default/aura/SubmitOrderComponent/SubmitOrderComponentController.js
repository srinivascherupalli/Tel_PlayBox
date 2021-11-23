({
    doInit : function(component, event, helper) {


    helper.checkifNotifiactionPreferenceCreated(component,event,helper);//EDGE-170965   

    },
	caValidation : function(component, event, helper) {//EDGE-88033 added for CA Form validation


        //EDGE-165481,EDGE-171843. Kalashree Borgaonkar. Moving this validation to Enriched button
        //helper.checkPortOutReversalOrderCustomerAuthorityForm(component, event, helper);/* EDGE-150285-Dheeraj Bhatt-Ability to regenerate CA form */




		helper.checkifPpvApprovedforPortinOrder(component,event,helper);  /* EDGE-149259-Aishwarya-Ability to regenerate CA form */
		var action = component.get("c.isPortInValid");
        action.setParams({
            optyId : component.get("v.ordRecord.csordtelcoa__Opportunity__c"),
        });
        action.setCallback(this, function(response) {
            if(response.getState()=='SUCCESS'){                
				if(response.getReturnValue() === true){




                     //helper.checkifPpvApprovedforPortinOrder(component,event,helper);




                    /* EDGE-150285-Dheeraj Bhatt-Ability to regenerate CA form */
                    if(component.get("v.isPpvApproved")==true){
                        console.log("in here");
					$A.enqueueAction(component.get('c.createOrchestrationProcess'));
                    }
                    // Commented out below lines as part of EDGE-141110
                    //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    //dismissActionPanel.fire();
				}
				else{
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title:'Error!',
                        mode: 'dismissible',
                        type:'error',
                        message: 'This is a required message',
                        messageTemplate: $A.get("$Label.c.CAExpiryValidation"),
                        messageTemplateData: [ {
                            url: window.location.origin+'/'+component.get("v.ordRecord.csordtelcoa__Opportunity__c"),
                            label: component.get("v.ordRecord.csordtelcoa__Opportunity__r.Name"),
                            }
                        ]
                    });
                    toastEvent.fire();
				}
            }
        });
		$A.enqueueAction(action);
	},
	createOrchestrationProcess : function(component, event, helper) {
        var action = component.get("c.createOrderOrchestrationProcess");
        var orderid = component.get("v.recordId");
        component.set("v.isButtonDisabled", true); 
        action.setParams({'orderIds': orderid});
        action.setCallback(this, function(response) {
            if(response.getState()=='SUCCESS')
            {
                location.reload();
            }
        });
        $A.enqueueAction(action);
    },
	cancelBack : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	},
})