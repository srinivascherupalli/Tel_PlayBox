({
	callFlow : function(component, event, helper) {
        var recordId = component.get("v.recId");
        console.log('--here1');
        var Param1 = component.get("v.Param1");
        console.log('--here2');
        var inputParams;
        var inputVariables=[];
        if(Param1 != null && Param1 != undefined && Param1 != ''){
        	inputParams = JSON.parse(Param1);
        	console.log('PRmCustomBtnOnFlow:Input_Params:'+Param1+JSON.stringify(inputParams));
            for(var i=0; i< inputParams.params.length ; i++)
                inputVariables.push({ name : inputParams.params[i].key, type : "String", value: inputParams.params[i].value});
        }
        
        if(recordId != null && recordId != undefined ){
            inputVariables.push({ name : "recordId", type : "String", value: recordId});
                            
            console.log('PRmCustomBtnOnFlow:inputVariables:'+JSON.stringify(inputVariables));
            component.set("v.launchFlow", true);  
            console.log('--start flow--1');
            //Launch flow
            var flow = component.find("flowData");
            var flowName = component.get("v.flowName"); 
            if(flowName != undefined && flowName !=null && flowName != ''){
                flow.startFlow(flowName,inputVariables);
                console.log('--start flow--2');
            }
         }
     },
    closeFlowModal : function(component, event, helper) {
        component.set("v.launchFlow", false);
    },
    closeModalOnFinish : function(component, event, helper) {
        console.log('::event:'+JSON.stringify(event));
       if(event.getParam('status') === "FINISHED") {
           var redirectionState = component.get("v.setRedirection");
                          console.log('redirect'+redirectionState);
           if(redirectionState){
               console.log('redirect'+redirectionState);
           var urlEvent = $A.get("e.force:navigateToSObject");
           urlEvent.setParams({
               "recordId": component.get("v.recId"),
               "isredirect": "true"
           });
           urlEvent.fire();
           }
           //Read output variables from flow
          component.set("v.launchFlow", false);
         }
         
       }
    
})