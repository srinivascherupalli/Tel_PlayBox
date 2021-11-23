/*****************************************************************************
@Author: Team Hawaii
@CreateDate: 09-18-2019	
@Description:
@References
Story:P2OB-3086 

*******************************************************************************/


public with sharing class PRM_CreateCaseFromOpportunityController {
    
    // valid oppty 
    @AuraEnabled
    public static map<string,string> getValidOpportunity(id oppId){
        Map<String,String> responseMap = NewBasketButtonController.getValidOpportunity(oppId);
        if(responseMap.containsKey('status') && responseMap.get('status') != 'error'){
            responseMap.put('uiTheme', UserInfo.getUiThemeDisplayed());
            responseMap.put('userType', UserInfo.getUserType());
            // check Pilot User permission
            if(FeatureManagement.checkPermission('PRM_Channel_Care_Pilot') != null){
            	responseMap.put('isPilotUser', String.valueOf(FeatureManagement.checkPermission('PRM_Channel_Care_Pilot')));
            }else{
                responseMap.put('isPilotUser', 'false');
            }
        }
        return responseMap; 
    }
}