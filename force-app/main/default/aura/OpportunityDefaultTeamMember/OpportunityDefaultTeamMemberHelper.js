({
    /* P2OB-11748 ,P2OB-11378 TEAM SFO OpportunityDefaultTeamMemberHelper 
        Modified for P2OB-13741 to add spinner*/
    // gets All User Default Opportunity Team and appropriate errors set
    getUserOppTeam: function (component, event, helper) {

        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getUserDefaultTeam");
        var oppId = component.get("v.OpportunityId");

        var nodefaultOppTeamError = $A.get("$Label.c.DefaultOppTeamError");
        var DefOppTeamAlreadyPresentError = $A.get("$Label.c.DefOppTeamAlreadyPresentError");


        action.setParams({
            userId: userId,
            OppId: oppId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {

                    var teamMemList = [];
                    var existingUserIds = [];
                    var newDefaultMemExists =0 ;
                    var newDefaultMemNotExists =0 ;

                    //var rec = component.get("v.OpportunityId");
                    //all Users present in existing Opp Team
                    if (result.oppTeamMemberList) {
                        result.oppTeamMemberList.forEach(element => {
                            existingUserIds.push(element.UserId);
                            
                        });
                    }
                    //Populate Team Member list and check if already present
                    if (result.userTeamMemberList) {
                        result.userTeamMemberList.forEach(element => {
                            if (!existingUserIds.includes(element.UserId)) {
                                teamMemList.unshift({
                                    'OpportunityAccessLevel': element.OpportunityAccessLevel,
                                    'TeamMemberRole': element.TeamMemberRole,
                                    'UserId': element.UserId,
                                    'User': { 'Name': element.User.Name },
                                    'OpportunityId': oppId,
                                    'checkboxIsSelect': false,
                                    'exists': false
                                });
                                newDefaultMemNotExists =newDefaultMemNotExists+1;
                            }
                            else if(existingUserIds.includes(element.UserId)){
                                teamMemList.push({
                                    'OpportunityAccessLevel': element.OpportunityAccessLevel,
                                    'TeamMemberRole': element.TeamMemberRole,
                                    'UserId': element.UserId,
                                    'User': { 'Name': element.User.Name },
                                    'OpportunityId': oppId,
                                    'checkboxIsSelect': false,
                                    'exists': true
                                });
                                newDefaultMemExists =newDefaultMemExists+1;
                            }
                        });
                        //Error Message populate when all default members are already part of Opp team
                        //Error Message when there are no User Default Opp team configured
                        if(result.userTeamMemberList.length <=0){
                            component.set("v.ErrorMsg",nodefaultOppTeamError);
                        }
                        else if(result.userTeamMemberList.length === newDefaultMemExists){
                            component.set("v.ErrorMsg",DefOppTeamAlreadyPresentError);
                        }
                        
                        component.set("v.DefaultTeamMemberList", teamMemList);
                    }
                    //Error Message when there are no User Default Opp team configured
                    else{
                        component.set("v.ErrorMsg",nodefaultOppTeamError);
                    }
                }
            }
            else {
                console.log('ERROR');
                console.log("response " + response.getError());
            }
        });
        $A.enqueueAction(action);


    },
    //Navigate to record helper method
    navtoSObj: function (Id) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": Id
        });
        navEvt.fire();
        
    }

})