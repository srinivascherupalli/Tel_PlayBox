({
	doInit : function(component, event, helper) {
     //   helper.getContractStatusMsg(component, event, helper);
		var action = component.get("c.displayError");
        if(action!=undefined){
            action.setParams({ recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.displayError",response.getReturnValue());
                    
                }
                else if(state === "Docusign Restricted"){
                    component.set("v.displayError",response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    console.log("Processing...");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        }
		 helper.getcontractDocusignEnabled(component);
        helper.getContractName(component);
        helper.getContractStatus(component);


        setInterval(function(){helper.getContractDocumentStatus(component);}, 10000);
       setInterval(function(){helper.getcontractRestrictCongaStatus(component);}, 10000);

        setInterval(function(){helper.callDocuSignurl(component);}, 10000);
        
        
	},
    
    retryContract : function(component, event, helper) {
        helper.retryContract(component);
	},
    
    updateStatus : function(component, event, helper){
        var actionToPerform = event.getSource().getLocalId();
        var recordid = component.get("v.recordId")
        helper.updateContractStatus(component,actionToPerform,recordid);
        $A.get('e.force:refreshView').fire();
    },
    waiting: function(component, event, helper) {
 	 component.set("v.HideSpinner", true);
 },
 	doneWaiting: function(component, event, helper) {
  	component.set("v.HideSpinner", false);
 }
})