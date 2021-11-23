/*****************************************************************************
@Name: RestrictAccountCreation
@Author: Sri
@CreateDate: 08/01/2019
@Description: P2OB-4278. This class is Controller for RestrictAccountCreation Component.
@CODECOVERAGE: By RestrictAccountCreationTest
@LastModified:
*******************************************************************************/
public without sharing class RestrictAccountCreationController {
    @auraEnabled
    //Method to check whether the user have ADMIN permission
    public static Boolean loggedInAsSysAdmin(){
        return FeatureManagement.checkPermission(Label.System_Admin_Permission);
    }
    
}