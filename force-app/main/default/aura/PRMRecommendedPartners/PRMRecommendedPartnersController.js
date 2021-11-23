({
    doInit : function(component, event, helper) {  
        console.log("inside Init of PRMReco");
        component.set("v.spinner",true);
        if(component.get("v.PartnerResults")!=undefined){
            component.set("v.spinner", false);
            return;
        }
        var action = component.get("c.findRecommedation");
        action.setParams({ OpptyID : component.get("v.OpportunityId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set("v.PartnerResults",response.getReturnValue());
                console.log("v.PartnerResults"+response.getReturnValue());
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
        var toastEvent = $A.get("e.force:showToast");
        //this is recommended partner screen. wrong error message
        //// showcase feedback isnt taken care of. This is not a toast message but a message that appears on the 
        //top of componnet like a toast type message 
        toastEvent.setParams({
            //"message": "There are no incumbent Partners."
            "message": "There are no recommended Partners."
        });
        toastEvent.fire();
    }
})