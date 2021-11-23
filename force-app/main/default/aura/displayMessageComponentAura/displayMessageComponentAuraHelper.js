/******************************************************************************************************************************************
Component Name  :   displayMessageComponentAuraHelper.js
Created Date    :   5/July/2021
******************************************************** Change Log ***********************************************************************
SL.NO.      Name            Date            Description
1.          Pooja Bhat      5/July/2021     EDGE-221053: B2B-1179 Case Attachment size to be aligned as per T-Connect
*******************************************************************************************************************************************/

({
    checkFileInfo : function(component, event, helper) {
        var recId   =   component.get("v.recordId");
        var action  =   component.get("c.fectchContentVersion");
        action.setParams({
            "contentDocumentId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var message = response.getReturnValue();
                if(message!=='' && message!==null && message!==undefined) {
                    component.set("v.message", message);
                    component.set("v.messageType", "Information");
                    component.set("v.showMessage", true);
                    component.set("v.showError", false);
                } else {
                    component.set("v.showMessage", false);
                }
            } else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                if(errorMsg){
                    component.set("v.message", errorMsg);
                    component.set("v.messageType", "Error");
                    component.set("v.showMessage", false);
                    component.set("v.showError", true);
                } else {
                    component.set("v.showError", false);
                }
            }
        });
        $A.enqueueAction(action);
    }
})