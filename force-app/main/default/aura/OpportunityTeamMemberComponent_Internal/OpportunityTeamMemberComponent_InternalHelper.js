({
    /**
    Created By : Team SFO
    Description : Cloned from OpportunityTeamMemberComponent(Team Hawaii P2OB-4164) and revamped to accomodate internal changes , This component is invoked from Opportunity team member related list URL button on opportunity layouts.
    Jira No : P2OB-13741
    Date : 01/06/2021
    */
    init: function (component, event, helper) {
        // P2OB-13741 : START
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__OpportunityId;
        var Accid = myPageRef.state.c__AccountId;
        component.set("v.OpportunityId", id);
        component.set("v.AccountId", Accid);
        // P2OB-13741 : END

        //call apex class method
        var action = component.get('c.checkCondition');
        var rec = component.get("v.OpportunityId");
        //DIGI-8538	
        var partnererrMsg = $A.get("$Label.c.PRM_Opportunity_Team_Member_Insufficient_Access");

        action.setParams({ OpptyID: component.get("v.OpportunityId"), LoggedinUserId: $A.get("$SObjectType.CurrentUser.Id") });
        action.setCallback(this, function (response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var errorMsg = response.getReturnValue();
                if (errorMsg.length > 1) {
                    //DIGI-8538	 internal users accessing partner owned opps scenario should see add me and remove me buttons fix 
                    if (errorMsg == 'Not an Owner' || (errorMsg == partnererrMsg && $A.get("$SObjectType.CurrentUser.UserType") != 'PowerPartner')) {
                        component.set("v.isOppOwner", false);
                        component.set("v.showNonOppOwnerFooter", true);
                        component.set("v.disableSaveButton", true);
                        this.getExistingTeamMember(component, event, helper);
                    } else {
                        component.set("v.ErrorMsg", errorMsg);
                    }
                } else {
                    this.getExistingTeamMember(component, event, helper);
                }
            }
            component.set("v.isSpinnerOn", false);

        });
        $A.enqueueAction(action);
    },

    // helper function for check if User is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allTeamRows = component.get("v.TeamMemberList");
        //P2OB-15629 save when empty rows are present
        var teamMemberList = allTeamRows.filter(function (e) {return e.UserId != '';});
		component.set("v.TeamMemberList",teamMemberList);
        return isValid;
    },

    // Create Object data
    createObjectData: function (component, event) {
        // get the TeamMemberList from component and add(push) New Object to List  
        var RowItemList = component.get("v.TeamMemberList");
        RowItemList.push({
            'sobjectType': 'OpportunityTeamMember',
            'OpportunityAccessLevel': '',
            'TeamMemberRole': '',
            'UserId': '',
            'OpportunityId': ''
        });
        // set the updated list to attribute (TeamMemberList) again    
        component.set("v.TeamMemberList", RowItemList);
    },

    //This function get all the existing team member associated to opportunity
    getExistingTeamMember: function (component, event, helper) {
        var loggedinUserId = $A.get("$SObjectType.CurrentUser.Id");
        var loggedinUserExists = false;

        //call apex class method
        var actionNew = component.get('c.displayTeam');
        var rec = component.get("v.OpportunityId");
        actionNew.setParams({ OpptyID: rec });
        actionNew.setCallback(this, function (response) {
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
                        if (loggedinUserId == row.UserId) {
                            loggedinUserExists = true;
                        }
                    }

                    component.set("v.OpportunityTeamMember", oppTeamMemberList);
                }
                if (loggedinUserExists) {
                    component.set("v.disableAddMeButton", true);
                    component.set("v.disableRemoveMeButton", false);
                } else {
                    component.set("v.disableAddMeButton", false);
                    component.set("v.disableRemoveMeButton", true);
                }
            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(actionNew);
    },
    // SFO Changes P2OB-11748 ,P2OB-11378 Get Logged in User Type , P2OB-12585  for account team button functionality saving account team list to attribute
    getAccDataUserType: function (component) {
        var loggedinUserId = $A.get("$SObjectType.CurrentUser.Id");

        var recId = component.get("v.OpportunityId");
        var action = component.get('c.getAccDataUserType');
        action.setParams({ userId: $A.get("$SObjectType.CurrentUser.Id"), accId: component.get("v.AccountId"), oppId: recId });
        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var existingUserIds = [];
                var accTeamList = result.accTeamMemberList;
                var oppAccTeam = [];
                var accountTeamMemExists = 0;
                var accountTeamInactive = 0;

                if (result.userType == 'Standard') {
                    component.set("v.standardUser", true);
                }
                if (result.oppTeamMemberList) {
                    result.oppTeamMemberList.forEach(element => {
                        existingUserIds.push(element.UserId);

                    });
                }

                if (accTeamList) {
                    accTeamList.forEach(element => {
                        if (!existingUserIds.includes(element.UserId) && (element.User != null && element.User.IsActive == true)) {
                            oppAccTeam.push({
                                'sobjectType': 'OpportunityTeamMember',
                                'OpportunityAccessLevel': element.OpportunityAccessLevel,
                                'TeamMemberRole': element.TeamMemberRole,
                                'UserId': element.UserId,
                                'OpportunityId': recId
                            });
                        }
                        else if (existingUserIds.includes(element.UserId)) {
                            accountTeamMemExists = accountTeamMemExists + 1;
                        }
                        else if (element.User != null && element.User.IsActive == false) {
                            accountTeamInactive = accountTeamInactive + 1;
                        }

                        //to check whether the current user is already part of the account team or not 
                        if (loggedinUserId == element.UserId) {
                            component.set("v.currentUserAccTeamMemberId", element.Id);
                        }
                    });

                    accountTeamMemExists = accountTeamMemExists + accountTeamInactive;
                    if (accountTeamMemExists == accTeamList.length && !(accTeamList.length == 0)) {
                        component.set("v.accountTeamAlreadyPresent", true);
                    }
                    else {
                        component.set("v.accountTeamMemberList", oppAccTeam);
                        component.set("v.accountTeamAlreadyPresent", false);
                    }
                }
            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action);
    },
    // P2OB-13741 : START
    navigateToOpportunity: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.OpportunityId')
        });
        navEvt.fire();
    },
    // P2OB-13741 : END

    //handle remove from account team & opportunity team for non opp owner 
    handleRemoveMeFromAccTeam: function (component, event, helper) {
        var oppId = component.get("v.OpportunityId");
        var selectedOptionValue = component.get("v.removeMeToAccTeamValue");
        var accTeamMemberId = "";
        //if removeMeToAccTeam picklist value is yes, need to pass accTeamMemberId to removeMeFromOppTeam apex method
        //if accTeamMemberId is having value removeMeFromOppTeam apex method remove user from account and opp teams
        //if accTeamMemberId is not having value("") removeMeFromOppTeam apex method remove user from opp team only
        if (selectedOptionValue == "Yes") {
            accTeamMemberId = component.get("v.currentUserAccTeamMemberId");
        }


        var action = component.get('c.removeMeFromOppTeam');
        action.setParams({ opportunityId: oppId, accTeamMemberId: accTeamMemberId });
        action.setCallback(this, function (response) {
            //store state of response

            var state = response.getState();
            if (state === "SUCCESS") {
                if(selectedOptionValue == "Yes"){
                var sucessMsg = $A.get("$Label.c.AddmeToOppFlow");
                }
                else{
                    var sucessMsg = $A.get("$Label.c.AddmeToOppFlowOppTeamRemovalMessage");

                }
                
                component.set("v.ErrorMsg", sucessMsg);
            }
            else {

            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action);
    },
    //handle remove from opportunity team for non opp owner 

    handleRemoveMeFromOppTeam: function (component, event, helper) {
        var oppId = component.get("v.OpportunityId");
        var action = component.get('c.removeMeFromOppTeam');
        action.setParams({ opportunityId: oppId, accTeamMemberId: "" });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var sucessMsg = $A.get("$Label.c.AddmeToOppFlowOppTeamRemovalMessage");
                component.set("v.ErrorMsg", sucessMsg);
            }
            else {

            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action);
    },
    //handle add me to opp team for non opp owner
    handleAdd: function (component, event, helper) {
      
        var oppId = component.get("v.OpportunityId");
        var action = component.get('c.updateOppTeam');
        action.setParams({ opportunityId: oppId, selectedRole: component.get("v.selectedRole") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === "SUCCESS") {
                // helper.navigateToOpportunity(component, event, helper);
                var sucessMsg = $A.get("$Label.c.OppteammemberAdditionSuccessMessage");
                component.set("v.ErrorMsg", sucessMsg);

            }
            else {

            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action);
    },
    // handle add me to opp team to check whether account is offshore restricted
    checkUserValidation: function (component, event, helper) {
        var oppId = component.get("v.OpportunityId");
        var action = component.get('c.checkUserValidation');
        action.setParams({ OpptyID: oppId, userId_selected: $A.get("$SObjectType.CurrentUser.Id") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isOffShoreRestricted = response.getReturnValue();
                if (isOffShoreRestricted) {
                    var errorMsg = $A.get("$Label.c.OppteammemberAdditionOffshorerole");
                    component.set("v.ErrorMsg", errorMsg);

                } else {
                    component.set("v.addMeToOppTeam", true);
                    component.set("v.saveLabel", 'Add');
                    component.set("v.disableSaveButton", false);

                }
            }
            else {

            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action);
    },
    //handle delete confirmation message set
    deleteConfirmation: function (component, event, helper) {
        component.set('v.showConfirmAlert', true);
        component.set("v.oppTeamIdToBeDeleted", event.getSource().get('v.value'));

        component.set('v.showConfirmAlertHeader', 'Record Delete Confirmation');
        component.set('v.showConfirmAlertContent', 'Are you sure you want to delete this record?');
        component.set('v.showConfirmAlertRemove', 'Delete');
    },
    //handle confirmation of delete of non opp owner
    handleConfirmDialogRemove: function (component, event, helper) {
        let oppTeamtoDelete = [];

        component.get("v.OpportunityTeamMember").forEach(element => {
            oppTeamtoDelete.push(element.Id);
        });
        var action1 = component.get("c.deleteAllTeamMember");
        action1.setParams({ OppTeamIdList: oppTeamtoDelete, OppId: component.get("v.OpportunityId") });
        action1.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been deleted successfully.",
                    "type": "success",
                    "duration": 5000,
                    "mode": "pester"
                });
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.OpportunityId")
                });
                navEvt.fire();
                // P2OB-13741 : START
                helper.navigateToOpportunity(component, event, helper);
                // P2OB-13741 : END
                $A.get('e.force:refreshView').fire();

            }
            else {
                console.log('ERROR');
                console.error(response.getError() + 'Error');
            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action1);
    },
    //handle confirmation of delete of team member by opp owner
    handleConfirmDialogYes: function (component, event, helper) {
        component.set("v.UserErrorList", []);
        // call the apex class method for deletion of team member record
        var action1 = component.get("c.deleteTeamMember");
        action1.setParams({ OppTeamId: component.get("v.oppTeamIdToBeDeleted"), OppId: component.get("v.OpportunityId") });
        action1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                for (var i = 0; i < res.length; i++) {
                    var row = res[i];
                    row.OpportunityAccessLevel = row.OpportunityAccessLevel;
                    row.TeamMemberRole = row.TeamMemberRole;
                    if (row.UserId) {
                        row.UserName = row.User.Name;
                    }
                }
                component.set("v.OpportunityTeamMember", res);
                // Show success message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been deleted successfully.",
                    "type": "success",
                    "duration": 5000,
                    "mode": "pester"
                });
                toastEvent.fire();
                component.set('v.showConfirmAlert', false);
                var opptyTList = component.find("slds-oppty--teamList");
                $A.util.removeClass(opptyTList, 'slds-show--wrapper');
            }
            component.set("v.isSpinnerOn", false);
        });
        $A.enqueueAction(action1);
        var standardUser = component.get("v.standardUser");
        if (standardUser) {
            helper.getAccDataUserType(component);
        }
        component.set('v.showConfirmDialog', false);
    },

    // function for save the Records 
    Save: function (component, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "User" will not be blank on each row.
        if (helper.validateRequired(component, event)) {
            // call the apex class method for creation and update of team members
            // with pass the opportunity team List attribute to method param.  
            var ne = component.get("v.TeamMemberList");
            var ne1 = component.get("v.OpportunityTeamMemberUpdated");
            var recordNeedsUpdate = component.get("v.OpportunityTeamMemberUpdated");
            var action3 = component.get("c.saveTeamMember");

            action3.setParams({
                "teamMemberList": component.get("v.TeamMemberList"),
                "updateMemberList": component.get("v.OpportunityTeamMemberUpdated")
            });
            // set call back 
            action3.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // if response if success then reset/blank the 'TeamMemberList','OpportunityTeamMemberUpdated' Attribute 
                    // and call the common helper method for create a default Object Data to Contact List 
                    component.set("v.TeamMemberList", []);
                    component.set("v.OpportunityTeamMemberUpdated", []);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been saved successfully.",
                        "type": "success",
                    });
                    toastEvent.fire();
                    /* var navigate = component.get('v.navigateFlow');
                    navigate('FINISH');
                    $A.get('e.force:refreshView').fire(); */
                    helper.navigateToOpportunity(component, event, helper);
                }
                component.set("v.isSpinnerOn", false);
            });
            // enqueue the server side action  
            $A.enqueueAction(action3);
        }
    },

})