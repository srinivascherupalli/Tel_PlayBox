({
    init : function (component) {
        //var flow = component.find("flowData");
        //flow.startFlow("Create_Proposal");
        var parentId=component.get("v.opportunityRecordId");
        var action=component.get('c.getOpportunity');
        action.setParams({
            oppId : parentId
        });
        action.setCallback(this, function(response) {
         var state=response.getState();
         if (state === "SUCCESS") {


            var opportunityToPass = response.getReturnValue();
            if(opportunityToPass.SharePoint_Sync__c === undefined || opportunityToPass.SharePoint_Sync__c == null) {
               opportunityToPass.SharePoint_Sync__c = '';	     
            }
            component.set("v.opportunity", opportunityToPass);


            var flow = component.find("flowData");
            // Set the account record (sObject) variable to the value of the component's 
            // account attribute.
            var inputVariables = [
               {
                  name : "recordId",
                  type : "SObject",
                  value: component.get("v.opportunity")
               }
            ];
      
            // In the component whose aura:id is "flowData, start your flow
            // and initialize the account record (sObject) variable. Reference the flow's
            // API name.
            flow.startFlow("Create_Proposal", inputVariables);
         }
         else {
            console.log("Failed to get account date.");
         }
      });
      // Send action to be executed
      $A.enqueueAction(action);
    },
    handleStatusChange : function (component,event) {
        if(event.getParam("status")=='FINISHED')
        {
            var cmpEvent = component.getEvent("ProposalFlowEvent");
            cmpEvent.setParams({"message" : "flow finished" });
            cmpEvent.fire();
        }
    }
    
})