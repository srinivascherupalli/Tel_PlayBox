/*
Created By : Team Hawaii
Created Date : 20/11/2019
Jira : P2OB- 3890
*/

//This class is called from PRM_CreateSupportButtonController class to generate base url for sandbox and Production
public with sharing class PRMBaseURLUtility {
    
    Public static string getBaseURLForCommunityUser(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
		String returnUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('::returnUrl'+returnUrl);
		List<Network> lstNetwork = [Select Id, UrlPathPrefix 
                                    From Network 
                                    Where Name =:Label.PRM_Partner_Network_Url_Path 
                                    LIMIT 1];
        if(isSandbox && lstNetwork != null && !lstNetwork.isEmpty() && !String.isEmpty(lstNetwork[0].UrlPathPrefix)){
            returnUrl = returnUrl + '/'+ lstNetwork[0].UrlPathPrefix;
        }
        return returnUrl;
    }
}