({
    /**
    Created By : Team SFO
    Description : Cloned from OpportunityTeamMemberComponent(Team Hawaii P2OB-4164) and revamped to accomodate internal changes , This component is invoked from Opportunity team member related list URL button on opportunity layouts.
    Jira No : P2OB-13741
    Date : 01/06/2021
    */
    // This function invoke on load of component
    doInit : function(component, event, helper) {
        
        component.set("v.isSpinnerOn", true);
        //get Error msg
        var UserError = $A.get("$Label.c.PRM_User_Should_Present");
        component.set("v.UserError", UserError);
        helper.init(component,event,helper);
        // call the common "createObjectData" helper method
        helper.createObjectData(component, event);
        // SFO Changes P2OB-11748 ,P2OB-11378 Get Logged in User Type 
        helper.getAccDataUserType(component); 
    },
    onPageReferenceChange : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
    },
    // This function will invoke on click on name of user
    handleClick: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
    
    deleteConfirmation : function(component, event, helper) {
        if(component.get("v.isOppOwner")){
            helper.deleteConfirmation(component, event, helper);
        }
    },
    
    handleConfirmDialogNo :  function(component, event) {
        component.set('v.showConfirmDialog', false);
        var opptyTList = component.find("slds-oppty--teamList");
        $A.util.removeClass(opptyTList, 'slds-show--wrapper'); 
    },
    
    // This function will invoke on once user select yes for delete record
    //SFO P2OB-12585  Update AccountTeam Whenever user removed from existing team using delete icon only for standard usertype
    handleConfirmDialogYes : function(component, event,helper) {
        component.set("v.UserErrorList",[]);
        // call the apex class method for deletion of team member record
        var action1 = component.get("c.deleteTeamMember");
        action1.setParams({OppTeamId:component.get("v.oppTeamIdToBeDeleted"),OppId:component.get("v.OpportunityId")});
        action1.setCallback(this, function(response) {
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
                component.set("v.OpportunityTeamMember",res);
                // Show success message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been deleted successfully.",
                    "type" : "success",
                    "duration" : 5000,
                    "mode":"pester"
                });
                toastEvent.fire();
                var opptyTList = component.find("slds-oppty--teamList");
                $A.util.removeClass(opptyTList, 'slds-show--wrapper');
            }
        });
        $A.enqueueAction(action1);
        var standardUser = component.get("v.standardUser");
        if(standardUser){
            helper.getAccDataUserType(component);
        }
        component.set('v.showConfirmDialog', false);
    },
    
    Save: function(component, event, helper){
        component.set("v.isSpinnerOn", true);
        var saveLabel = component.get("v.saveLabel");
        if(saveLabel === 'Add'){
            helper.handleAdd(component, event, helper);

        }else if(saveLabel === 'Remove'){
            helper.handleRemoveMeFromAccTeam(component, event, helper);

        }else if(saveLabel === 'Save'){
            helper.Save(component, event, helper);
        }
    },
    
    // function for create new object Row in team member List 
    addNewRow: function(component, event, helper) {
        // call the common "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
        component.set("v.UserErrorList",[]);
    },
    // SFO Changes P2OB-11748 ,P2OB-11378 To display child component for User Default Team Member
    addDefaultTeam: function(component, event, helper) {
        component.set("v.hideDefaultTeamComponent",false);
    },
    
    // function for remove the row 
    removeDeletedRow: function(component, event, helper) {
        component.set("v.UserErrorList",[]);
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        var userId = event.getParam("userId");
        // get the all List (TeamMemberList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.TeamMemberList");
        var mapValue = component.get("v.MapOfIndexAgainstValue");
        if(Object.keys(mapValue).length > 0){
            for(var key in mapValue){
                var trueValue = mapValue[key];
                var newValue = trueValue.toString();
                var isTrue = key.includes(userId);
                if(isTrue && userId != '' && newValue == 'true'){
                    delete (mapValue[key]);
                    break;
                }
            }
        }
        var mapValue = component.get("v.MapOfIndexAgainstValue");
        if(Object.keys(mapValue).length > 0){
            for(var key in mapValue){
                var trueValue = mapValue[key];
                var newValue = trueValue.toString();
                if(newValue == 'true'){
                    component.set("v.disableSaveButton",true);
                    break;
                }else{
                    component.set("v.disableSaveButton",false);
                }
            }
        }else{
            component.set("v.disableSaveButton",false);
        }
        AllRowsList.splice(index, 1);
        // set the team member list after remove selected row element  
        component.set("v.TeamMemberList", AllRowsList);
    },   
    
    // This function handle the event fired by child component("DynamicRowItemForOpptyTeamMember")
    getAccessLevelAndRole : function(component, event, helper) {
        
        var accessLevel  = event.getParam("accessLevel");
        var memberRoles  = event.getParam("teamMemberRole");
        component.set("v.OpportunityAccessLevel",accessLevel);
        component.set("v.MemberRoleList",memberRoles);
    },
    
    // This function handle the onchange event.It Update existing team member records
    updateRecord : function(component, event, helper) {
        var getChangeValue = event.getSource().get("v.value");
        var getIndex = event.getSource().get("v.name");
        var existingList = component.get("v.OpportunityTeamMember");
        var value  = existingList[getIndex];
        var indexStore = component.get("v.IndexMatch");
        if(indexStore.indexOf(getIndex) !== -1){  
        }else{
            var updatedList = component.get("v.OpportunityTeamMemberUpdated");
            updatedList.push(value);
            component.set("v.OpportunityTeamMemberUpdated",updatedList);
            indexStore.push(getIndex);
            component.set("v.IndexMatch", indexStore);
        }
        var listst = component.get("v.OpportunityTeamMemberUpdated");
    },
    
    // This function invokes on cancel button
    Cancel: function (component, event, helper) {
        // var navigate = component.get('v.navigateFlow');
        // navigate('FINISH');
        // P2OB-13741 : START
        helper.navigateToOpportunity(component, event, helper);
        // P2OB-13741 : END   

    },
    
    // This function handles the logic once user is selected 
    userSelected : function(component, event, helper)  {
        component.set("v.UserErrorList",[]);
        var getBooleanValue = event.getParam("userError");
        var getIndex = event.getParam("indexVar");
        var userIdSelected = event.getParam("userId");
        var CheckedRecsObj = component.get("v.MapOfIndexAgainstValue");
        CheckedRecsObj[userIdSelected+getIndex] = getBooleanValue;
        component.set("v.MapOfIndexAgainstValue", CheckedRecsObj);
        for(var key in CheckedRecsObj){
            var trueValue = CheckedRecsObj[key];
            var newValue = trueValue.toString();
            if(newValue == 'true'){
                component.set("v.disableSaveButton",true);
                break;
            }else{
                component.set("v.disableSaveButton",false);
            }
        }
    },
    
    //This function invokes on clear of user record
    disableSave : function(component, event, helper)  {
        component.set("v.UserErrorList",[]);
        var getBooleanValue = event.getParam("userError");
        var getIndex = event.getParam("indexVar");
        var userId = event.getParam("userId");
        var mapValue = component.get("v.MapOfIndexAgainstValue");
        if(Object.keys(mapValue).length > 0 ){
            for(var key in mapValue){
                var trueValue = mapValue[key];
                var newValue = trueValue.toString();
                var isTrue = key.includes(userId);
                if(isTrue && userId != '' && newValue == 'true'){
                    delete (mapValue[key]);
                    break;
                }
            }
        }
        
        var mapValue = component.get("v.MapOfIndexAgainstValue");
        if(Object.keys(mapValue).length > 0){
            for(var key in mapValue){
                var trueValue = mapValue[key];
                var newValue = trueValue.toString();
                if(newValue == 'true'){
                    component.set("v.disableSaveButton",true);
                    break;
                }else{
                    component.set("v.disableSaveButton",false);
                }
            }
        }else{
            component.set("v.disableSaveButton",false);
        }
    },
    //SFO P2OB-12585 on click of Remove All Members button invokes pop up for user for confirmation
    removeAllOppTeam: function (component, event, helper) {
        var oppTeamToDelete = component.get("v.OpportunityTeamMember");
        var removeAllOppTeamHeader = 'Remove team members?';
        if(oppTeamToDelete.length !==0){
            var findId = component.find("confirmationboxforRemoveAll");
            $A.util.addClass(findId, 'slds-show');
            component.set("v.RemovaAllSelected", true);
            component.set('v.showConfirmAlert', true);

            component.set('v.showConfirmAlertHeader', removeAllOppTeamHeader);
            component.set('v.showConfirmAlertContent', "You're about to remove all members from the opportunity team");
            component.set('v.showConfirmAlertRemove', 'Remove');
    
        }
        else {
            var findId = component.find("confirmationboxforRemoveAll");
            $A.util.removeClass(findId, 'slds-show');
            component.set("v.RemovaAllSelected", false);
            var Error = $A.get("$Label.c.EditOppTeamRemoveAllErrMsg");
            component.set("v.ErrorMsg", Error);
        }
    },
    //SFO P2OB-12585 on click of Remove button in confirmation pop up , removes all team and members and redirects to opportunity
    handleConfirmDialogRemove: function (component, event, helper) {
        if(component.get('v.showConfirmAlertRemove') == 'Remove'){
            helper.handleConfirmDialogRemove(component, event, helper);
        }
        else if(component.get('v.showConfirmAlertRemove') == 'Delete'){
            helper.handleConfirmDialogYes(component, event, helper);
        }

    },
     //SFO P2OB-12585 on click of cancel button it closes the pop up
    handleConfirmDialogRemoveallCancel: function (component, event, helper) {
        var findId = component.find("confirmationboxforRemoveAll");
        $A.util.removeClass(findId, 'slds-show');
        component.set("v.RemovaAllSelected", false);
        component.set("v.showConfirmAlert", false);

    },
    //SFO P2OB-12585  on click of Add Account Team To save account team onto opportunity team members
    saveDefAccTeam: function (component, event, helper) {
        var accTeam = component.get("v.accountTeamMemberList");
        var accExists = component.get("v.accountTeamAlreadyPresent");
        
        if(accExists){
            var Error = $A.get("$Label.c.EditOppTeamAccTeamExistsErrorMsg");
			 component.set("v.ErrorMsg", Error);
        }
        else if (accTeam.length === 0) {
            var Error = $A.get("$Label.c.EditOppTeamNoAccTeamErrMsg");
            component.set("v.ErrorMsg", Error);
        }
        else {
            
            var action3 = component.get("c.saveTeamMember");
            action3.setParams({
                "teamMemberList": accTeam,
                "updateMemberList": null
            });
            // set call back 
            action3.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been saved successfully.",
                        "type": "success",
                    });
                    toastEvent.fire();

                    
                    // var navigate = component.get('v.navigateFlow');
                    // navigate('FINISH');
                    // P2OB-13741 : START
                    helper.navigateToOpportunity(component,event,helper);
                    // P2OB-13741 : END
                    
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    console.error('ERROR');
                    console.error("response " + JSON.stringify(response.getError()));
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action3);
        }
    },

    // SFO 13741 on click of add me to opp team 
    addMeToOppTeam: function(component, event, helper) {
        component.set("v.isSpinnerOn", true);
        var OpportunityId = component.get("v.OpportunityId");
        component.set("v.showNonOppOwnerFooter", false);
        helper.checkUserValidation(component, event, helper);
    },
    // SFO 13741 on click of remove me from opp team
    removeToOppTeam: function(component, event, helper) {
        component.set("v.isSpinnerOn", true);
        component.set("v.showNonOppOwnerFooter", false);
        if(component.get("v.currentUserAccTeamMemberId") != ""){
            component.set("v.removeFromOppTeam",true);
            component.set("v.saveLabel",'Remove');   
            component.set("v.disableSaveButton", false);
            component.set("v.isSpinnerOn", false);
}
        else{
            helper.handleRemoveMeFromOppTeam(component, event, helper)
        }
        
    },
    // on confirmation of remove
    handleRemove: function(component, event, helper) {
        component.set("v.isSpinnerOn", true);
        helper.handleRemoveMeFromAccTeam(component, event, helper);
    },
    // on click of Add me to opp team
    handleAdd: function(component, event, helper) {
        helper.handleAdd(component, event, helper);
    },
    //on select of role from lwc when non opp owner selects role
	getValueFromLwc : function(component, event, helper) {
		component.set("v.selectedRole",event.getParam('selRole'));
	},
    //on click of finish
    onFlowActionPressed : function(component, event, helper) {
        helper.navigateToOpportunity(component, event, helper);
    }
})