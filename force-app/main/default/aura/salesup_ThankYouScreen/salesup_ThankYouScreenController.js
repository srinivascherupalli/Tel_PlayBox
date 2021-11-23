/*
Modified By : Team Hawaii
Date : 16/12/2020
Sprint : 20.16(P20B-9929)
Description : Display srvsup_Categories__c,salesup_Work_Required__c value only if fields are not blank
*/
({
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
        var isCallFromCPEFlowComp = component.get('v.isCallFromCPEFlowComp');
        if(isCallFromCPEFlowComp){
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get('v.opportunityId'),
              "slideDevName": "detail"
            });
            navEvt.fire();
        }else{
            var navigate = component.get('v.navigateFlow');
            navigate('FINISH');
            //$A.get('e.force:refreshView').fire();
            
            var appEvent = $A.get("e.c:closeParentPopupFromThankYouScreen");
            appEvent.setParams({
                "message" : true });
            appEvent.fire();
        }
        console.log('firing event to close parent component*******');
    },
    init : function (component, event) { 
        /*var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();*/
        var cmpTarget = component.find('cpeFlowScreen');
        var cmpBack = component.find('cpeFlowBackdrop');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpBack, 'slds-backdrop_open'); 

        var childCaseList = component.get("v.varChildCaseList");
        var parentCaseList = component.get("v.varParentIdList");
        var action = component.get("c.getCaseDetails");  
        action.setParams({"jsonString" : JSON.stringify(childCaseList), "parentIdList" : parentCaseList,"partner":component.get("v.blnPartner")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listCase = response.getReturnValue();
                component.set('v.childCaseList', response.getReturnValue()); 
            } 
            else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.returnBaseUrl");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('RETURNED BASE URL*****'+response.getReturnValue());
                component.set('v.communityBaseURL',response.getReturnValue()+'/s');
            }
        });
        $A.enqueueAction(action);
    }
})