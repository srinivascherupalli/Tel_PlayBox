/************************************************************ 
* @createdBy   - Shreyansh Sharma
* @team         - JAIPUR
* @jirastoryRef - P2OB-3854
* @description: Track Changes to 'Bid Status' field on Case and update the Case record fields
* @update: Shreyansh Sharma/P2OB-11801, Code CleanUp,Removing Bid Obj reference from custom deal module
* @Date: 5/1/2021
******************************************************************/
/** START of P2OB-3854  ***/
public with sharing class CustomDealCaseTriggerHandler {
    public static String recId_CustomDeal = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
    public static void updateCustomDealCase(List<Case> newCaseList, Map<ID,Case> oldCaseMap){
        List<Case> customDealCasesToUpdate = new List<Case>();
        if(newCaseList != NULL){
            for(Case cs: newCaseList){
                //P2OB-11801, Record type check
                if(cs.RecordTypeid == recId_CustomDeal){
                    //Set Stage and Status values when case is assigned from Queue to User
                    if(string.valueOf(oldCaseMap.get(cs.Id).OwnerId).startsWith('00G') && string.valueOf(cs.OwnerId).startsWith('005') && cs.status == 'New'){
                        cs.Stage__c = 'Requirement Analysis';
                        cs.Status = 'In Progress';
                    }
                    
                    //Set Stage and Status values when related bid status values has been changed to 'Pending DRB Approval' or 'Pending ERB Approval'
                    if((cs.cusdl_Bid_Status__c == 'Pending ERB Approval' || cs.cusdl_Bid_Status__c == 'Pending DRB Approval') && (oldCaseMap.get(cs.Id).cusdl_Bid_Status__c != 'Pending ERB Approval' && oldCaseMap.get(cs.Id).cusdl_Bid_Status__c != 'Pending DRB Approval')){
                        cs.Stage__c = 'ORB Solution Review';
                        cs.Status = 'In Progress';
                    }
                    
                    //Set sub status values to 'Work Completed' once case status is set to 'Closed'
                    if(cs.status == 'Closed'){
                        cs.soc_SFD_Sub_Status__c = 'Work Completed';
                        
                    }
                }
            }
        }
    }
}