({
    //Call this function to get picklist values of fields Opportunity Access Level and Team Member role
	getOpportunityAccessLevel : function(component, event, helper){	
    	var action3 = component.get('c.getselectOptions');
    	action3.setParams({objObject : component.get("v.objInfo"),fld : "OpportunityAccessLevel"});
        var opts1 = [];
        action3.setCallback(this,function(response){
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
 	       var allValues = response.getReturnValue();
           for (var i = 0; i < allValues.length; i++) {
           		if(allValues[i] === "Edit"){
                    opts1.push({
                        label: "Read/Write",
                        value: allValues[i]
                    });
                }else if(allValues[i] === "Read"){
                    opts1.push({
                        label: "Read Only",
                        value: allValues[i]
                    });
                }
            }
            //set default value in instance
            component.set("v.OpptyTeamMemberInstance.OpportunityAccessLevel",allValues[1]);
            component.set("v.OpportunityAccessList", opts1);
            var opplist = component.get("v.OpportunityAccessList");
            //fire event to provide these values to parent component
            component.getEvent("GetAccessLevelAndRole").setParams({"accessLevel" : component.get("v.OpportunityAccessList"),"teamMemberRole": component.get("v.TeamMemberRoleList")}).fire();
                    
        }
        });
        $A.enqueueAction(action3);
    }
})