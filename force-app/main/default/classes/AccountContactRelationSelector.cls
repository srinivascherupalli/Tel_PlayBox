/**
 * (c) Telstra
 * Encapsulates the logic for querying Account object 
 * 08 Jul 2019	Amitabh Basu Original
 
 Prajakta    19/07/2021         DIGI-855 Enhance billing account create/update flow to filter out digitally ineligible customer contacts so that it can't be assigned as a billing contact
 */ 
public with sharing class AccountContactRelationSelector extends fflib_SObjectSelector{

    public List<Schema.SObjectField> getSObjectFieldList(){ return new List<Schema.SObjectField>{
            	AccountContactRelation.Id,
                Account.Name,
                Contact.Name,
                Contact.Email };
    }    
    public Schema.SObjectType getSObjectType(){return 	AccountContactRelation.sObjectType;
    }
    
    /**
     * SOQL query to return IDs for AccountContactRelation records
     * @param acctParentIds List
     * @param secondaryContactListId List
     * @return lstOfContact List
     */ 
    public static List<AccountContactRelation> getAccountContactRelation(List<Id> acctParentIds, List<Id> secondaryContactListId){
         return [SELECT Roles, Account.Name, Contact.Name, 
                                                      Contact.Email,Contact.Sales_Contact_Status__c,Contact.Raise_Billing_Disputes__c FROM AccountContactRelation 
                                                      where AccountId IN: acctParentIds and  Contact.Sales_Contact_Status__c ='Eligible' and Contact.Raise_Billing_Disputes__c = true and Roles != 'Non-Authorised' and ID NOT IN: secondaryContactListId];// DIGI-855   
                       								 
    }
    
    /**
     * SOQL query to return IDs for AccountContactRelation records
     * @param acctParentIds List
     * @param secondaryContactListId List
     * @param searchKey String
     * @return lstOfContact List
     */ 
    public static List<AccountContactRelation> getAccountContactRelation(List<Id> acctParentIds, 
                                                    List<Id> secondaryConListId, String searchKey){                                                         
        return [SELECT Id, AccountId, ContactId, StartDate, IsActive, Roles, 
              Contact.Account.Name, Contact_Type__c, Contact_Usage__c, Account.Name, 
              Account.Account_UUID__c, Contact.Name, Contact.Email,Contact.Sales_Contact_Status__c,Contact.Raise_Billing_Disputes__c
              FROM AccountContactRelation where Contact.Name LIKE: searchKey 
              and AccountId IN: acctParentIds and  Contact.Sales_Contact_Status__c ='Eligible' and Contact.Raise_Billing_Disputes__c = true and Roles != 'Non-Authorised' and ID NOT IN: secondaryConListId]; //DIGI-855
        	  
    
      
                                                        
    }
}