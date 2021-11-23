/****************************************************************************
@Author: Nikita Tiwari
@CreateDate: 18/08/2018
@Story: EDGE-30168
@Description:  update Verify relation as true.
@TestCoverageClass: AccountContactRelationshipTRGTest.cls
@ChangeLog: v1: Created
********************************************************************************/
public With Sharing class AccountContactCheckVerifiedDate {
    @AuraEnabled
    public static void saveRecord(String acrId){
        List<String> excludedRoles = new List<String>{'Non-Authorised','Legal Lessee','3rd Party'};
        List<AccountContactRelation> acrList = [SELECT Id,Verified_Relationship__c,Roles,Verification_Recommended__c,Relationship_Expiry_Date__c,Relationship_Verified_Date__c 
                                               From AccountContactRelation where Id=:acrId];
        if(!acrList.isEmpty()){
            acrList[0].Verified_Relationship__c=true;    
            acrList[0].Verification_Recommended__c = false;
            acrList[0].Relationship_Verified_Date__c = Date.today();
            acrList[0].Relationship_Expiry_Date__c = (!excludedRoles.contains(acrList[0].Roles)) ? 
                										Date.today() + Integer.valueOf(Label.Relationship_Expiry_Date_c) : null;
            update acrList[0]; 
        }
    }
}