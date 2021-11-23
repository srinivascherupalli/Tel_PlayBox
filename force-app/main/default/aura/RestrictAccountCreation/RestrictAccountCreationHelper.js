/*****************************************************************************
@Name: RestrictAccountCreation.cmp
@Author: Sri
@CreateDate: 08/01/2019
@Description: P2OB-4278. This component is used for restrict Users to create accounts in Phoenix directly.
@LastModified:
*******************************************************************************/
({
    //method to navigate AccountHomePage 
    navHome : function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Account"
        });
        homeEvent.fire();
    },
    
    //method to show error message
    showToast : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var errorMsg = $A.get("$Label.c.RestrictActCreation_Error_Message");
        toastEvent.setParams({
        "title": "Error",
        "message": errorMsg,
        "type" : "Error"
        });
        toastEvent.fire(); 
	},
    
    //method to launch new account record form
    createAccountRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Account"
            });
        createRecordEvent.fire();
    }

})