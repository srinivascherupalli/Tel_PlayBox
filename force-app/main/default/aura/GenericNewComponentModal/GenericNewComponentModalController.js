({
     //Handler for init event
	doInit : function(component, event, helper) {
		var flow = component.find("flowData");
        var flowName = component.get("v.flowName");
        console.log('Modal component.get("v.flowName")'+component.get("v.flowName"));
        if(flowName != undefined && flowName !=null && flowName != ''){
            console.log('starting flow');
            flow.startFlow(flowName);
        }
        	
	},
    //Handler for onClick of lightning-button
    closeModalOnFinish : function(component, event, helper) {
        console.log('FinishModal',event.getParam('status'));
        if(event.getParam('status') === "FINISHED") {
            //Read output variables from flow
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
            outputVar = outputVariables[i];
            //Called flow should have output variable of name 'Redirect_Link' having the link for redirection
            if(outputVar.name === "Redirect_Link") {
               component.set("v.redirectURL", outputVar.value);
             } 
           }
            //Navigate user to url in redirectURL
            var redirectLink = component.get("v.redirectURL");
            if(redirectLink != null && redirectLink != ''){
                var eUrl= $A.get("e.force:navigateToURL");
    			eUrl.setParams({
     				 "url": component.get("v.redirectURL")
    			});
                console.log('You will be redirected to target');
    			eUrl.fire();
                console.log('found redirection', '-- after redirect');
            }
            //Close the component    
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
            console.log('dismissal', '--after redirect');
            $A.get('e.force:refreshView').fire();
        }
    },
   
})