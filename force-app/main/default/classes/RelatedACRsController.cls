/*****************************************************************************
@Name: RelatedACRsController
@Author: Sri Chittoori(Team SFO)
@CreateDate: 29/05/2019
@Description: Sprint 19.07 , EDGE-85148 :: This Class is controller for ViewRelatedACR component
*******************************************************************************/
public without sharing class RelatedACRsController {
    @AuraEnabled
    public static List<AccountContactRelation> viewACRs (Id recordId){
        try{
            System.debug('In RelatedACRsController recordId : ' + recordId);
            List<AccountContactRelation> acr = [SELECT Id,Account_Name__c,CVA_Contact_Customer_Value_Analysis__c,Job_Title__c,Roles,Relationship_Verified_Date__c,Verification_Recommended__c
                                                FROM AccountContactRelation WHERE ContactId = :recordId order by IsDirect desc ] ;
            System.debug('In RelatedACRsController acr : ' + acr[0].id);
            return acr;  
        }
        catch(ListException e){
            System.debug('ListException: ' + e.getStackTraceString());
            return null;
        }
    }
}