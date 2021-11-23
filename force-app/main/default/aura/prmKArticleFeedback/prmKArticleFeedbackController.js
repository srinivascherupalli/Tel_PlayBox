({ 
	//Handler for init
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
        let pubsubCmp = component.find("pubSub");
        //Register to pubSub for listening to events for changes in Article selection 
        pubsubCmp.registerListenerwithURL("KArticleLevels",  helper.handleEvent, component, window.location.href);
        //helper.handleCaseStudyVisibility(component, helper);
    },
    //Handler for Up Vote lightning-button
    addVote : function(component, event, helper) {
        helper.handleVoteButton(component, event, helper,1);
    },
    //Handler for Down Vote of close button
    subtractVote : function(component, event, helper) {
        helper.handleVoteButton(component, event, helper,-1);
    },
     //Handler for onClick of close button
    closeFlowModal : function(component, event, helper) {
        component.set("v.launchFlow", false);
    },
    //Handler for Close-button of flow
    closeModalOnFinish : function(component, event, helper) {
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
            component.set("v.launchFlow", false);
        }
    },
    
})