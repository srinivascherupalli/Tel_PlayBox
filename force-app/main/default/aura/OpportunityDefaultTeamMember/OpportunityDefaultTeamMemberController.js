({
    /* P2OB-11748 ,P2OB-11378 TEAM SFO OpportunityDefaultTeamMemberController
        Modified for P2OB-13741 to add spinner*/
    //fetch  User Default Opportunity Team
    doInit: function (component, event, helper) {
        helper.getUserOppTeam(component, event, helper);

    },
    // function for save the Selected Records , added spinner
    Save: function (component, event, helper) {
        component.set("v.isloading",true);
        var teamMem = component.get("v.DefaultTeamMemberList");
        var rec = component.get("v.OpportunityId");
        var teamUpdate = [];

        var atleastOneUserErr = $A.get("$Label.c.AtleastOneUserErr");


        teamMem.forEach(element => {
            if (element.checkboxIsSelect == true) {
                teamUpdate.push({
                    "sobjectType": "OpportunityTeamMember",
                    'OpportunityAccessLevel': element.OpportunityAccessLevel,
                    'TeamMemberRole': element.TeamMemberRole,
                    'UserId': element.UserId,
                    'OpportunityId': rec
                });
            }
        });
        if (teamUpdate.length < 1) {
            component.set("v.ErrorSelectOne", atleastOneUserErr);
            //P2OB-15629 spinner off when displaying error message
            component.set("v.isloading",false);
        }
        else {
            var action3 = component.get("c.saveTeamMember");

            action3.setParams({
                "teamMemberList": teamUpdate,
                "updateMemberList": null
            });

            action3.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.DefaultTeamMemberList", []);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "You have successfully added to this opportunity team.",
                        "type": "success",
                    });
                    toastEvent.fire();
                    
                    var oppId = component.get("v.OpportunityId");
                    helper.navtoSObj(oppId);
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    console.log("ERROR" + JSON.stringify(response.getError()));
                }
                component.set("v.isloading",false);

            });
            $A.enqueueAction(action3);
        }
    },
    // This function invokes on cancel button
    Cancel: function (component, event, helper) {
        var oppId = component.get("v.OpportunityId");
        helper.navtoSObj(oppId);

    },
    //this function invokes on click of user name hyperlink and redirects to user record
    userRedirect: function (component, event, helper) {
        var userId = event.target.getAttribute("id");
        helper.navtoSObj(userId);
    },
    // On click of selectall
    onselectAll: function (component, event, helper) {
        var isChecked = component.get("v.selectAll");
        var teamList =component.get("v.DefaultTeamMemberList");
        if(isChecked){
            teamList.forEach(element =>{
                if(!element.exists){
                    element.checkboxIsSelect = true;
                }
            });
        }
        else if(isChecked == false){
            teamList.forEach(element =>{
                if(!element.exists){
                    element.checkboxIsSelect = false;
                }
            });
        }
        component.set("v.DefaultTeamMemberList",teamList);
    },

    //SFO Changes P2OB-13700 START
    onFlowActionPressed: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    //SFO Changes P2OB-13700 END
    
    })