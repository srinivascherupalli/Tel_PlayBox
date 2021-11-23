({
    //Check for Existing Bid Record for Case on Page Load and Display button accordingly
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.onLoad",true);
        component.set("v.contextVar","onLoad");
        helper.validateData(component, event, helper);
    },
    //handle flow call and set the input parameters on button click
    flowCall : function (component, event, helper) {
        component.set("v.onLoad",false);
        component.set("v.contextVar","onClick");
        
        helper.validateData(component, event, helper);
    },
    createCli : function (component, event, helper) {
        component.set("v.onLoad",false);
        component.set("v.contextVar","onClickModifySol");
        component.set("v.spinner",true);
        helper.validateData(component, event, helper);
        // component.set("v.showOrbBtn1",true);
    },
    //handle callback from flow
    handleStatusChange : function (component, event) {
        var errorMsg = component.get("v.errorMessage");
        component.set("v.spinner",false);
        component.set("v.showFlowMsg",false);
        if(event.getParam("status") === "FINISHED_SCREEN") {
            
            component.set("v.showOrbBtn",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Success!",            
                "message": errorMsg,
                "type": "Success",
                "duration":" 4000"
            });
            toastEvent.fire();
        }
        else{
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
})