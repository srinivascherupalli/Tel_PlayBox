/*********************************************************************************************************************************
Class Name : orderRequesterCustomLookUpController
Test Class : orderRequesterCustomLookUpControllerTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        Vaibhav Deshpande     26/05/2020      EDGE-138655 Enhance search criteria and provide Subscription list view for a Solution during MACD Order flow
2.        Jawahar               21/07/2020      Added roles in filter condition for production defect. INC000093468695
3.         Nikhil Kumar         22/10/2021      <Ops> To display restricted Contacts on MACD Journey
*********************************************************************************************************************************
*/
public with sharing class orderRequesterCustomLookUpController {
    // This class is created as Controller class for CustomContactRolelookup Lightning Component
       @AuraEnabled
   public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
       String searchKey = '%' +searchKeyWord + '%';
       
       List < AccountContactRelation > returnList = new List < AccountContactRelation > ();
     
       // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
       List < AccountContactRelation > lstOfRecords = new List < AccountContactRelation >
               ([select id ,ContactId ,AccountId ,Contact_Name__c , Roles
                 from AccountContactRelation where AccountId = :ObjectName and Contact_Name__c LIKE :searchKey and Contact.Contact_Status__c = 'Active' and Contact.Create_Requests__c = true]);//updated where condition as part of EDGE-138655 and Updated Query as part of DIGI-1933
       
       for (AccountContactRelation obj: lstOfRecords) {
        
           returnList.add(obj);
       }
       return returnList;
   }
   
     @AuraEnabled
   public static List < sObject > fetchLookUpValuesForOpportunityContactRole(String searchKeyWord, String ObjectName) {
       String searchKey = '%' +searchKeyWord + '%';
       
       List < OpportunityContactRole > returnList = new List < OpportunityContactRole > ();
     
       // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
       List < OpportunityContactRole > lstOfRecords = new List < OpportunityContactRole >
               ([select id ,ContactId ,OpportunityId ,Contact_Name__c , Role
                 from OpportunityContactRole where OpportunityId = :ObjectName and Contact_Name__c LIKE :searchKey]);//updated where condition as part of EDGE-138655
       for (OpportunityContactRole obj: lstOfRecords) {
        
           returnList.add(obj);
       }
       return returnList;
   }
}