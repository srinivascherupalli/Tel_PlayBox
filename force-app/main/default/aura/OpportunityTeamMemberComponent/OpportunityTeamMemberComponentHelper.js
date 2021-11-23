({
	init : function(component, event,helper) {
        
        //call apex class method
        var action = component.get('c.checkCondition');
        var rec = component.get("v.OpportunityId");
        action.setParams({OpptyID : component.get("v.OpportunityId"),LoggedinUserId : $A.get("$SObjectType.CurrentUser.Id")});
        action.setCallback(this,function(response){
        //store state of response
        var state = response.getState();
            if (state === "SUCCESS") {
            	var errorMsg = response.getReturnValue();
                if(errorMsg.length > 1){
                    component.set("v.ErrorMsg", errorMsg);
                }else{
                	this.getExistingTeamMember(component,event,helper);
                }
            }
        });
    	$A.enqueueAction(action);
    },
    
    // helper function for check if User is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allTeamRows = component.get("v.TeamMemberList");
        var errorList = component.get("v.UserErrorList");
        component.set("v.UserErrorList",[]);
        for (var indexVar = 0; indexVar < allTeamRows.length; indexVar++) {
            if (allTeamRows[indexVar].UserId == '') {
                isValid = false;
                var error = component.get("v.UserError")
                errorList.push(error);
            }else{
                errorList.push("");
            }
        }
        component.set("v.UserErrorList",errorList);
        return isValid;
 	},
    
    // Create Object data
    createObjectData: function(component, event) {
        // get the TeamMemberList from component and add(push) New Object to List  
        var RowItemList = component.get("v.TeamMemberList");
        RowItemList.push({
            'sobjectType': 'OpportunityTeamMember',
            'OpportunityAccessLevel': '',
            'TeamMemberRole': '',
            'UserId': '',
            'OpportunityId':''
        });
        // set the updated list to attribute (TeamMemberList) again    
        component.set("v.TeamMemberList", RowItemList);
    },
    
    //This function get all the existing team member associated to opportunity
    getExistingTeamMember : function(component, event,helper) {
        
        //call apex class method
        var actionNew = component.get('c.displayTeam');
        var rec = component.get("v.OpportunityId");
        actionNew.setParams({OpptyID :rec});
        actionNew.setCallback(this,function(response){
        //store state of response
        
        var state = response.getState();
            if (state === "SUCCESS") {
            	var oppTeamMemberList = response.getReturnValue();
				for (var i = 0; i < oppTeamMemberList.length; i++) {
                    var row = oppTeamMemberList[i];
					row.AccessLevel = row.OpportunityAccessLevel;
                    row.MemberRole = row.TeamMemberRole;
					if (row.UserId) {
							row.UserName = row.User.Name;
					}
                  
					component.set("v.OpportunityTeamMember", oppTeamMemberList);
				}
                
            }
        });
    	$A.enqueueAction(actionNew);
    },

    // SFO Changes P2OB-11748 ,P2OB-11378 Get Logged in User Type , P2OB-12585  for account team button functionality saving account team list to attribute
    getAccDataUserType: function (component) {
        var recId = component.get("v.OpportunityId");
        var action = component.get('c.getAccDataUserType');
        action.setParams({ userId: $A.get("$SObjectType.CurrentUser.Id"), accId: component.get("v.AccountId") , oppId : recId});

        action.setCallback(this,function(response){
        
        var state = response.getState();
            if (state === "SUCCESS") {
            	var result=response.getReturnValue();

                var existingUserIds = [];
                var accTeamList = result.accTeamMemberList;
                var oppAccTeam =[];
                var accountTeamMemExists =0 ;
                var accountTeamInactive =0 ;

                if (result.userType == 'Standard'){
                    component.set("v.standardUser", true);
                }
                 if (result.oppTeamMemberList) {
                        result.oppTeamMemberList.forEach(element => {
                            existingUserIds.push(element.UserId);
                            
                        });
                    }

                if (accTeamList) {
                    accTeamList.forEach(element => {
                        if (!existingUserIds.includes(element.UserId) && (element.User != null && element.User.IsActive == true)){
                            oppAccTeam.push({
                                'sobjectType': 'OpportunityTeamMember',
                                'OpportunityAccessLevel': element.OpportunityAccessLevel,
                                'TeamMemberRole': element.TeamMemberRole,
                                'UserId': element.UserId,
                                'OpportunityId': recId
                            });
                        }
                        
                        else if(existingUserIds.includes(element.UserId)){
                            accountTeamMemExists=accountTeamMemExists+1;
                        }
                        else if(element.User != null && element.User.IsActive == false){
                            accountTeamInactive =accountTeamInactive +1;
                        }
                    });
                    
                    accountTeamMemExists =accountTeamMemExists +accountTeamInactive;
                    if(accountTeamMemExists == accTeamList.length && !(accTeamList.length == 0) ){
                        component.set("v.accountTeamAlreadyPresent",true);
                    }
                    else{
                        component.set("v.accountTeamMemberList",oppAccTeam);
                        component.set("v.accountTeamAlreadyPresent",false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }

})