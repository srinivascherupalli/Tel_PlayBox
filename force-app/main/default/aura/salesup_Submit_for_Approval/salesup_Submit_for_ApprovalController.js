({
    doInit : function(component, event, helper) {
        debugger;
		
        var action = component.get("c.getCaseValue");
        var caseId = component.get("v.recordId"); 
        console.log("caseId=>"+caseId);
        action.setParams({
            
            "caseId": caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //debugger;
            if (state === "SUCCESS") {
                //debugger;
                console.log("state=>"+state);
                var caseData = response.getReturnValue();
                if(caseData == "Approval Pending" || caseData == "Remediation In Progress" || caseData == "Closed"){ //Add further conditions here with an 'OR,||'
                    component.set("v.showSubmitBtn", false);
                }
                component.set("v.cases", caseData);
            }
        });
        $A.enqueueAction(action);
    },
    FlowCall : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        
        var inputVariables = [
            {
                name : "caseRecordId",
                type : "SObject",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        component.set("v.showSubmitBtn",false);
        flow.startFlow("Covid_19_Financial_Hardship_Approval_Process_Submission",inputVariables);
        console.log("Flow Called123");
    },
    
    handleStatusChange : function(component, event){
        if(event.getParam("status") === "FINISHED"){
            
            var showSubmitBtn = component.get("v.showSubmitBtn");
            console.log("showSubmitBtn>>"+showSubmitBtn);
            var outputVar = component.get("v.recordId");
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
                
                "recordId" : outputVar
            });
            urlEvent.fire();
        }
    }
})