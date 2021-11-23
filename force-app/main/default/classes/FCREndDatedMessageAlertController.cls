/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 28/07/2018
@Story: EDGE-30036
@Description: FCREndDatedMessageAlertController class for holding bussiness logic related to FCREndDatedMessageAlert lightning component created for showing alert message when fcr is end dated.
@TestCoverageClass: FCREndDatedMessageAlertControllerTest
@ChangeLog: v1: Created
********************************************************************************/
public with Sharing class FCREndDatedMessageAlertController {
    
    //EDGE-35520(AC5)
    @auraEnabled
    public static Boolean isFCREndDatedHavingActiveACR(String fcrId){
        Functional_Contact_Role__c fcr =  [SELECT id,ContactID__c,Billing_Account_Number__r.Account__c,OrderID__r.csord__Account__c,SiteID__r.cscrm__Account__c,SubscriptionID__r.csord__Account__c,Relationship_End_Date__c FROM Functional_Contact_Role__c WHERE id = :fcrId];
        AccountContactRelation acr;
        System.debug('FCR: '+fcr);
        if(fcr.Relationship_End_Date__c!=null){
            acr = [SELECT id,Relationship_End_Date__c FROM AccountContactRelation WHERE ContactId = :fcr.ContactID__c AND (AccountId = :fcr.Billing_Account_Number__r.Account__c OR AccountId = :fcr.OrderID__r.csord__Account__c OR AccountId = :fcr.SiteID__r.cscrm__Account__c OR AccountId = :fcr.SubscriptionID__r.csord__Account__c)];
            System.debug('acr: '+acr);
            if(acr!=null && acr.Relationship_End_Date__c==null){
                return true;
            }
            else{
                return false;
            }   
        }
        else{
        	return false;
        }
    }
}