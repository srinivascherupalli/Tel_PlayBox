/*****************************************************************************
@Author: Team Hawaii
@CreateDate: 09-25-2019
@Description:
@References
Story:P2OB-3087

*******************************************************************************/
public with sharing class PRM_CreateSupportButtonController {

    /* Get User Details */
    @AuraEnabled
    public static String getUserDetails(){
        UserDetailWrapper usrDetails = new  UserDetailWrapper();
		usrDetails.uiTheme = UserInfo.getUiThemeDisplayed();
		usrDetails.userType = UserInfo.getUserType();
        // check Pilot permission
        usrDetails.isPilotUser = FeatureManagement.checkPermission('PRM_Channel_Care_Pilot');
        system.debug('isPilotUser value is '+usrDetails.isPilotUser);
        return JSON.serialize(usrDetails);
    }
    public class UserDetailWrapper {
		public String uiTheme{get;set;}
		public String userType {get;set;}
        public Boolean isPilotUser {get;set;}
	}
	/*
	 * Date : 24/11/2019
	 * Added logic to generate base url for opportunity as part of Jira story P2OB-3890
	*/
    @AuraEnabled
    public static String globalActionNavigateUrl(){

        String returnUrl = PRMBaseURLUtility.getBaseURLForCommunityUser();
        User u = [select id,Name,ContactId,Profile.Name,Contact.AccountId,Contact.Account.CWP_Eligible_Partner__c from User where id =: userInfo.getUserId()];
        if(u.ContactId != Null && u.Contact.AccountId != Null && Label.PRM_Community_User_Profile.contains(u.Profile.Name)){
            if(u.Contact.Account.CWP_Eligible_Partner__c){
         	 	returnUrl = returnUrl + Label.PRM_Partner_URL_CWP_Enabled;
            }else if(!u.Contact.Account.CWP_Eligible_Partner__c){
            	returnUrl = returnUrl + Label.PRM_Partner_URL_New_Opp;
            }

        }
        RETURN returnUrl;
	}

    /*
	 * Date : 24/11/2019
	 * Added logic to generate base url for case as part of Jira story P2OB-3890
	*/
    @AuraEnabled
    public static String getCaseUrl(){
    	String returnUrl = PRMBaseURLUtility.getBaseURLForCommunityUser()+Label.PRM_Partner_Case_URL;
        return returnUrl;
    }
    @AuraEnabled
    public static String getCSMPortalDetails() {
		return TNOW_CSM_URL__c.getInstance().PortalUrl__c;
    }     
}