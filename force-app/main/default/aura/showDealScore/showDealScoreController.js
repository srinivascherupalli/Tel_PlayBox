({  
    // Start EDGE-219478 EDGE-219744
    doInit : function(component, event, helper) {
        helper.getGBBScaleHelper(component, event);
     },
     //EDGE-219478 EDGE-219744 End
	getGBBScale : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.Samplemethod");
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
                    var responsenew =response.getReturnValue();
					helper.getGBBScaleHelper(component, event);
                    component.set("v.showSpinner",false);
                }else if (state === "INCOMPLETE"){}
                    else if (state === "ERROR"){
                        var errors = response.getError();
                        if (errors){
                            if (errors[0] && errors[0].message){
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
        }); 
        $A.enqueueAction(action);
	},
    openGbbScale : function(component, event, helper){ 
        console.log("Open console <>"+component.get("v.showScale"));
        component.set("v.showScale",true);
        helper.getGBBReportDetails(component,event);
    },
     closeModal : function(component, event, helper){
        component.set("v.showScale",false);
    }
})