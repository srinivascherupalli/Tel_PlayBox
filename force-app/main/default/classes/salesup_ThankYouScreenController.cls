/*
* Owner: Sandeep Soni
* Created Date: 29 July 2019
* Description: This apex class will fetch case details based on caseid.

Version    Author            Last Modified Date     Description
v1.1       Vivian (Hawaii)   17 Oct 2019            Added another getCaseDetails paramaterised method
                                                    added processRecords common method
                                                    added returnBaseUrl method
v1.2       Vivian (Hawaii)   01 Apr 2021            Added returnUserInfo method
*/
public without sharing class salesup_ThankYouScreenController {

    @AuraEnabled
    public static List<Case> getCaseDetails(String jsonString, String[] parentIdList, boolean partner){
        return processRecords(jsonString,parentIdList,partner);
    }

    @AuraEnabled
    public static List<Case> getCaseDetails(String jsonString, String[] parentIdList){
       return processRecords(jsonString,parentIdList,false);
    }

    public static list<Case> processRecords(String jsonString, String[] parentIdList, boolean partner){
        List<Case> lstCase = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        
        if(parentIdList!=null && parentIdList.size()>0){
            for(Integer i = 0 ;i<parentIdList.size();i++){
                caseIdSet.add(parentIdList[i]);
            }
        }
        if(jsonString!=null){
            List<caseWrapper> lstCaseWrapper = (List<caseWrapper>)JSON.deserialize(jsonString, List<caseWrapper>.class);
            for(CaseWrapper cw : lstCaseWrapper){
                caseIdSet.add(cw.id);
            }
        }

        if(caseIdSet!=null){
             if(partner != null && partner){
                lstCase = [SELECT ID, CaseNumber, tolabel(Work_Required_PRM__c), Category_PRM__c FROM Case WHERE ID = :caseIdSet];
            }else{
                lstCase = [SELECT ID, CaseNumber, tolabel(salesup_Work_Required__c), srvsup_Categories__c FROM Case WHERE ID = :caseIdSet];
            }
        }
        return lstCase;
        }

    @auraEnabled
    public static String returnBaseUrl(){
        String returnUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        list<Network> lstNetwork = [Select Id, UrlPathPrefix
                                    From Network
                                    Where Name =:Label.PRM_Partner_Community_Name
                                    LIMIT 1];
        if(lstNetwork != null && !lstNetwork.isEmpty() && !String.isEmpty(lstNetwork[0].UrlPathPrefix)){
            returnUrl = returnUrl + '/'+lstNetwork[0].UrlPathPrefix;
        }
        return returnUrl;
    }
    
    // v1.2
    @auraEnabled
    public static String returnUserInfo(){
        system.debug('***UserInfo.getUserType()*****'+UserInfo.getUserType());
        return UserInfo.getUserType();
    }

    public class caseWrapper{
        public String id {get;set;}
    }

}