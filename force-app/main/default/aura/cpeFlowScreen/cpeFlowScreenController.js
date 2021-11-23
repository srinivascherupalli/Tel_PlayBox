({
	doInit : function(component, event, helper) {
		var flow = component.find("flowData");
           var inputVariables = [
               {
                    name : "varOpportunityId",
                    type : "String",
                    value : component.get('v.recordId')
               },
               {
                    name : "varIsCalledFromOpportunity",
                    type : "Boolean",
                    value : true
               },{   
                	name : "varShowProductDomain",
                    type : "Boolean",
                    value : component.get('v.varShowProductDomain')
               }  
           ];           
           //start the flow
           flow.startFlow("Create_CPE_Request_Cases", inputVariables );
	},
    
    handleStatusChange : function (component, event) {
        
        component.set("v.showSpinner",false);
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
            
            var outputVariables = event.getParam("outputVariables");
            var varChildCaseUpdateList;
			var outputVar;
         	for(var i = 0; i < outputVariables.length; i++) {
            outputVar = outputVariables[i];
            // Pass the values to the component's attributes
            if(outputVar.name === "varChildCaseUpdateList") {
               varChildCaseUpdateList = outputVar.value;
            }
         }

            component.set('v.showFlowScreen', true);
             var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:salesup_ThankYouScreen",
                componentAttributes: {
                    varChildCaseList : varChildCaseUpdateList,
                    opportunityId: component.get('v.recordId'),
                    isCallFromCPEFlowComp: true
                }
            });
            evt.fire();
        }
        else if(event.getParam("status") === "ERROR") {
           
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Error!",            
                "message": "Please review and try again",
                "type": "error",
                "duration":" 4000"
            });
            toastEvent.fire();
        }
    },    
   
    closeModel : function(component, event, helper){
        component.set('v.isOpenModal', false);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get('v.recordId'),
          "slideDevName": "detail"
        });
        navEvt.fire();
	}
})