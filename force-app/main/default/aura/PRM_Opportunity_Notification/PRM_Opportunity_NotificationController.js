({
    redirectTo: function(component, event, helper) {

        var opptyId = component.get("v.recordId"); // Opportunity Id
        var action = component.get("c.getValidOpportunity");
        //var warning = component.get("c.getValidOpportunity");

        action.setParams({
            "oppId": opptyId
        });
        
        var p = helper.executeAction(component, action);
        p.then($A.getCallback(function(result) {
           
            //alert(result);
            console.log('result: ' + result);
            if(result.warning == 'true') {
                component.set('v.warning', true);
                //EDGE-177925 added by team amsterdam
                if(result.isDelegatedPricing=='true'){
                    component.set('v.isDelegatedPricing',true);
                    component.set('v.approvalPendingMessage', result.message);
                }

                //P2OB-11846 added by team Hawaii
                if(result.isInitialApproval=='true'){
                    component.set('v.approvalPendingMessage', result.submittedWarningMessage);
                }

                return;
            }
           //Added by Ayush(Hawaii) for P2OB-8462
            if (result.approvalPending == 'true') {
                component.set('v.approvalPending', true);
                //Updated by Hawaii for P2OB-11846
                //var approvalMessageLabel = $A.get("$Label.c.PRM_Opportunity_Pending_For_Closure");
                component.set('v.approvalPendingMessage',result.approvalPendingMsg);
                return;
            }
            
            else {
               
            }
        })).catch(
            $A.getCallback(function(error) {
                alert('An error occurred : ' + error.message);
            })
       
        );
    }
})