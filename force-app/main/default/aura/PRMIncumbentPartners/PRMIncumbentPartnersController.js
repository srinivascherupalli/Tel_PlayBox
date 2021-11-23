({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        if(component.get("v.PartnerResults")!=undefined) {
            component.set("v.spinner", false);
            return;
        }
         var action = component.get("c.findIncumbentPartners");
        //component.set("v.PartnerResults",response.getReturnValue());
        action.setParams({ OpptyID : component.get("v.OpportunityId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                //alert("From server: " + response.getReturnValue());
                console.log(response.getReturnValue());
                component.set("v.PartnerResults",response.getReturnValue());
                component.set("v.spinner", false);
            }
            console.log("PartnerResults Incumbent");
        });
        $A.enqueueAction(action);
    }
})