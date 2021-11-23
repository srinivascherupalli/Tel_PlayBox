/*****************************************************************************
@Name: RestrictAccountCreation.cmp
@Author: Sri
@CreateDate: 08/01/2019
@Description: P2OB-4278. This component is used for restrict Users to create accounts in Phoenix directly.
@LastModified:
*******************************************************************************/
({
    //This Method will be called OnLoad to check whether the user have ADMIN permission
	init : function(component, event, helper) {
        var action = component.get("c.loggedInAsSysAdmin");
        action.setCallback(this, function(response) {
            var state = response.getState();                                     
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue()){
					//calling helper method to launch new account record form                    
                    helper.createAccountRecord(component, event, helper);
                }else{
					//calling helper method to show error message                    
                    helper.showToast(component, event, helper);
					//calling helper method to navigate AccountHomePage                    
                    helper.navHome(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
   }
})