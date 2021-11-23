({
    /*-------------------------------------------------------------------------------
    EDGE        -150285
    Method      -checkPortOutReversalOrderCustomerAuthorityForm
    Description -To Check CA form exist or not for Port out reversal order
    Author      -Dheeraj Bhatt
    ---------------------------------------------------------------------------------*/
    checkPortOutReversalOrderCustomerAuthorityForm : function(component, event, helper) {
        var action = component.get("c.checkPortOutReversalOrderCaForm");
        action.setParams({
            opportunityId : component.get("v.ordRecord.csordtelcoa__Opportunity__c"),
        });	
        action.setCallback(this, function(response) {
            if(response.getState()=='SUCCESS'){ 
                component.set("v.isCAFormPresent",response.getReturnValue());               
                if(response.getReturnValue() === false){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title:'Error!',
                        mode: 'dismissible',
                        type:'error',
                        message: 'This is a required message',
                        messageTemplate: $A.get("$Label.c.RegeneratePortOutReversalValidation"),
                        messageTemplateData: [ {
                            url: window.location.origin+'/'+component.get("v.ordRecord.csordtelcoa__Opportunity__c"),
                            label: component.get("v.ordRecord.csordtelcoa__Opportunity__r.Name"),
                            }
                        ]
                    });
                    toastEvent.fire();
                }
            }
        })
        $A.enqueueAction(action);
    },
    /*-------------------------------------------------------------------------------
    EDGE        -149259
    Method      -checkifPpvApprovedforPortinOrder
    Description -To Check CA form signed and PPV aaproved for PortIn order
    Author      -Aishwarya Yeware
    ---------------------------------------------------------------------------------*/
    checkifPpvApprovedforPortinOrder : function(component, event, helper) {
        var action = component.get("c.isPortinPpvApproved");
        action.setParams({
            opportunityId : component.get("v.ordRecord.csordtelcoa__Opportunity__c"),
        });	
        action.setCallback(this, function(response) {
            if(response.getState()=='SUCCESS'){ 
                component.set("v.isPpvApproved",response.getReturnValue());               
                if(response.getReturnValue() === false){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title:'Error!',
                        mode: 'dismissible',
                        type:'error',
                        message: 'This is a required message',
                        messageTemplate: $A.get("$Label.c.CASignedAndPPVApprovalValidation"),
                        messageTemplateData: [ {
                            url: window.location.origin+'/'+component.get("v.ordRecord.csordtelcoa__Opportunity__c"),
                            label: component.get("v.ordRecord.csordtelcoa__Opportunity__r.Name"),
                            }
                        ]
                    });
                    toastEvent.fire();
                }
            }
        })
        $A.enqueueAction(action);
    },
      /*-------------------------------------------------------------------------------
    EDGE        -170965
    Method      -checkifNotifiactionPreferenceCreated
    Description -To Check if notification prefernces records created for order
    Author      -Aishwarya
    ---------------------------------------------------------------------------------*/
    checkifNotifiactionPreferenceCreated : function(component, event, helper) {
        var action = component.get("c.isNotificationCreated");
        action.setParams({
            orderIds :component.get("v.recordId"),
        });	
        action.setCallback(this, function(response) {
            if(response.getState()=='SUCCESS'){ 
                console.log('isNotification--',response.getReturnValue());
                component.set("v.isNotificationCreated",response.getReturnValue());               
                
            }
        })
        $A.enqueueAction(action);
    },
})