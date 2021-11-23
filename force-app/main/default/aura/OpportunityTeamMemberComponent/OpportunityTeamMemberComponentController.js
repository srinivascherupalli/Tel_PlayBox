({
    // This function invoke on load of component
    doInit : function(component, event, helper) {
        //get Error msg
        var UserError = $A.get("$Label.c.PRM_User_Should_Present");
        component.set("v.UserError", UserError);
        var rec = component.get("v.OpportunityId");
        helper.init(component,event,helper);
        // call the common "createObjectData" helper method
        helper.createObjectData(component, event);
        // SFO Changes P2OB-11748 ,P2OB-11378 Get Logged in User Type 

        helper.getAccDataUserType(component);

        
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
    
    deleteConfirmation : function(component, event) {
        component.set('v.showConfirmDialog', true);
        var findId = component.find("confirmationbox");
        $A.util.addClass(findId, 'slds-show');
        component.set("v.oppTeamIdToBeDeleted",event.getSource().get('v.value'));
        var opptyTList = component.find("slds-oppty--teamList");
        $A.util.addClass(opptyTList, 'slds-show--wrapper');  
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
                    "message": "The record has been Deleted successfully.",
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
    
    // function for save the Records 
    Save: function(component, event, helper) {
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
                "updateMemberList" : component.get("v.OpportunityTeamMemberUpdated")
            });
            // set call back 
            action3.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // if response if success then reset/blank the 'TeamMemberList','OpportunityTeamMemberUpdated' Attribute 
                    // and call the common helper method for create a default Object Data to Contact List 
                    component.set( "v.TeamMemberList" , []);
                    component.set("v.OpportunityTeamMemberUpdated",[]);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been Saved successfully.",
                        "type" : "success",
                    });
                    toastEvent.fire();
                    var navigate = component.get('v.navigateFlow');
                    navigate('FINISH');
                    $A.get('e.force:refreshView').fire();
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action3);
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
    Cancel : function(component, event, helper) {
        var navigate = component.get('v.navigateFlow');
        navigate('FINISH');     
        
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
        if(oppTeamToDelete.length !==0){
            var findId = component.find("confirmationboxforRemoveAll");
            $A.util.addClass(findId, 'slds-show');
            component.set("v.RemovaAllSelected", true);
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
        let oppTeamtoDelete =[];
        
        component.get("v.OpportunityTeamMember").forEach(element => {
            oppTeamtoDelete.push(element.Id);
        });
        var action1 = component.get("c.deleteAllTeamMember");
        action1.setParams({ OppTeamIdList: oppTeamtoDelete, OppId: component.get("v.OpportunityId") });
        action1.setCallback(this, function (response) {
            var state = response.getState();
            
            console.log(state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been Deleted successfully.",
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
                var navigate = component.get('v.navigateFlow');
                navigate('FINISH');
                $A.get('e.force:refreshView').fire();

            }
            else{
                console.log('ERROR');
                console.error(response.getError() + 'Error');
            }
        });
        $A.enqueueAction(action1);
    },
     //SFO P2OB-12585 on click of cancel button it closes the pop up
    handleConfirmDialogRemoveallCancel: function (component, event, helper) {
        var findId = component.find("confirmationboxforRemoveAll");
        $A.util.removeClass(findId, 'slds-show');
        component.set("v.RemovaAllSelected", false);

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
                        "message": "The record has been Saved successfully.",
                        "type": "success",
                    });
                    toastEvent.fire();
                    var navigate = component.get('v.navigateFlow');
                    navigate('FINISH');
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
    }
})