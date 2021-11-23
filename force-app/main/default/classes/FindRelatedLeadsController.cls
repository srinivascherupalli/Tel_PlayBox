/********************************************************************************************************************************************
@Class Name:FindRelatedLeadsController
@Description:Sprint 19.04 , EDGE-71679
@Date:19-03-2019
@Author:SFO Team (Sravanthi)
@Comments:To Fetch all the leads with same account/contact/email into lightning component RelatedListLead.And Update on click of a button for leads owned by queue.

@Last Modified By: Amar Chakka ,Pallavi B                
@Last Modified Date: 10-06-2020 , 16-03-2021             
@Last Modified Comments: Sprint 20.08, P2OB-6755. Changed as per New Vantage Lead Routing. Assine Me functionality on this component should work from Any queue.              
                         Sprint 21.04, P2OB-12075. As part of Tech Debt (Removed References for the Label of Enterprise Record Type)
**************************************************************************************************************************************************/

public without sharing class FindRelatedLeadsController {
    //This method fetches the related leads list and returns it to lightning component RelatedListLead
    @AuraEnabled  
    public static String getData(Id recordId) {  
        Lead openedLead = [Select Email, CIDN__c,Contact_Name__c from Lead where Id =: recordId LIMIT 1];
        //P2OB-6755 Incorporated RecordType Check
        List<Lead> data = [Select Id, Name, Email, Customer_Name__r.Name, Contact_Name__r.Name,Status, ownerId, owner.Name from Lead where ((Email = :openedLead.Email AND Email !=null) OR (Contact_Name__c =:openedLead.Contact_Name__c AND Contact_Name__c!=null) OR (CIDN__c = :openedLead.CIDN__c AND CIDN__c != null )) AND Id != :openedLead.Id AND IsConverted = False AND Recordtype.DeveloperName =: System.Label.Lead_Recordtype_Enterprise];//Replaced with Developer Name of Enterprise Lead Record Type
        return JSON.serialize(data);
        
    }
    //This method fetches the related leads list and changes the lead owners when the lead is owned by queue.Invoked from RelatedListLead lightning component
    @AuraEnabled  
    public static Boolean changeOwner(Id recordId) {
        Boolean success=false;
        try{
            String leadQueue = System.Label.Lead_EnterpriseQueue;
            List<Lead> toBeUpdatedList = new List<Lead>();
            Lead openedLead = [Select Email, CIDN__c,Contact_Name__c from Lead where Id =: recordId LIMIT 1];
            list<QueueSobject> q = [select Id, QueueId from QueueSobject WHERE SobjectType = 'Lead' AND Queue.Name = :leadQueue LIMIT 1];
            //P2OB-6755 Modified Below Query, Removed LDR Queue Filter as LDR Queue functionality is been changed. Assign to me Functionality should work from Any queue not only from LDR Queue. 
            for(Lead ld : [Select Id, Name, Email, Customer_Name__r.Name, Contact_Name__r.Name,Status, ownerId, owner.Name from Lead where ((Email = :openedLead.Email AND Email!=null)  OR (Contact_Name__c =:openedLead.Contact_Name__c AND Contact_Name__c!=null) OR (CIDN__c = :openedLead.CIDN__c AND CIDN__c != null )) AND Id != :openedLead.Id AND IsConverted = False and Recordtype.DeveloperName =: System.Label.Lead_Recordtype_Enterprise]){ //Replaced with Developer Name of Enterprise Lead Record Type
                if(String.valueOf(ld.ownerId).startswith('00G')){
                    ld.ownerId = UserInfo.getUserId();
                    toBeUpdatedList.add(ld);
                }
            }
            
            if(toBeUpdatedList != null && !toBeUpdatedList.isEmpty()){
                Database.SaveResult[] srLeadList=Database.update(toBeUpdatedList, false);
                success=true;
            }
            else if(toBeUpdatedList.isEmpty()){
                success=false;
            }
            return success;
        }catch(DMLException e){
            
            return false;
        }
    }
}