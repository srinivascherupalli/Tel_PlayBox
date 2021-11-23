({
    AddNewRow : function(component, event, helper){
       // fire the AddNewRowEvt Lightning Event 
        component.getEvent("AddRowEvt").fire();   
        
    },
    
    removeRow : function(component, event, helper){
       var instarnce = component.get("v.OpptyTeamMemberInstance");
       var id=instarnce.UserId;
       // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
       component.getEvent("RowDeleteEvt").setParams({"indexVar" : component.get("v.rowIndex") ,
                                                      "userError": component.get("v.inValid_selectedUser"),
                                                     "userId":id
                                                    }).fire();
       component.set("v.inValid_selectedUser",false); 
    }, 
    
    doInit : function(component, event, helper){
        //get Error msg label
        var ErroMsg = $A.get("$Label.c.PRM_Offshore_Restricted_User_Error");
        //set error msg in attribute
	    component.set("v.OffshoreRestrictedError", ErroMsg);
        //call apex class method
        var action2 = component.get('c.getselectOptions');
        action2.setParams({objObject : component.get("v.objInfo"),fld : "TeamMemberRole"});
        var opts = [];
        action2.setCallback(this,function(response){
        //store state of response
        var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                for (var i = 0; i < allValues.length; i++) {
                   opts.push({
                       label: allValues[i],
                       value: allValues[i]
                   });
               }
               component.set("v.OpptyTeamMemberInstance.TeamMemberRole",allValues[0]);
               component.set("v.TeamMemberRoleList", opts);
               helper.getOpportunityAccessLevel(component, event, helper)
               
            }
        });
    	$A.enqueueAction(action2);
    }, 
    
    handleComponentEvent1 : function(component, event, helper) {
        var newwww = component.get("v.OpptyId");
    	var selectedUserGetFromEvent = event.getParam("recordByEvent");
        var userIdValue = selectedUserGetFromEvent["Id"];
        component.set("v.OpptyTeamMemberInstance.UserId",userIdValue);
        component.set("v.OpptyTeamMemberInstance.OpportunityId",component.get("v.OpptyId"));
        var valuesAre = component.get("v.OpptyTeamMemberInstance");
        // call for user-validation
    	var action1 = component.get("c.checkUserValidation");
    	action1.setParams({OpptyID:component.get("v.OpptyId"),userId_selected:userIdValue});
    	action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.inValid_selectedUser",res);
                component.getEvent("User_ErrorEvt").setParams({
                    "userError" : component.get("v.inValid_selectedUser"),
                    "indexVar" : component.get("v.rowIndex"),
                    "userId":userIdValue
                     }).fire();
            		
            }
        });
     	$A.enqueueAction(action1);        
        
    	},

    clearInstanceVariable : function(component, event, helper) {
    	component.set("v.OpptyTeamMemberInstance.UserId","");
        var valuesAre = component.get("v.OpptyTeamMemberInstance");
    },
    
    
    EnableSaveButton : function(component, event, helper) {
        component.set("v.inValid_selectedUser",false);
        var newValue = component.get("v.inValid_selectedUser");
        var userRecord = event.getParam("userRecordSelected");
        var userId = userRecord["Id"];
        component.getEvent("EventOnClear").setParams({"userError" : false,
                                                       "indexVar" : component.get("v.rowIndex"),
                                                      "userId":userId
                                                     }).fire();
    }
})