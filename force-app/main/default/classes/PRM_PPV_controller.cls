/**
* Description : Handler Class for supporting LWC - prm_PPV_SelectAuthContact                   
* Jira        : P2OB - 11853
* Author      : Team Hawaii : Ritika Jaiswal


* Date        : 15-Jan-2021 
**/
public without sharing class PRM_PPV_controller {
    
    //P2OB - 11853 : Method to return list of related-contacts whose name match the given search-string


    @AuraEnabled(cacheable=true)
    public static List<Contact> retrieveContactData(string keySearch,string accountInput){       
        List<Contact> contactList = new List<Contact>();
        string tempInput = '%' + keySearch + '%';


        if(String.isNotBlank(keySearch)){
            //P2OB - 11853 : Return list of related contacts which match search-string
            contactList = [Select id,name,Authority__c,MobilePhone,Phone from contact where AccountId =:accountInput and Authority__c = 'Full Authority' and Contact_Status__c ='Active' and Name like :tempInput];
        }else{
            //P2OB - 11853 : If search-string given is empty, return list of all related contacts
            contactList = [Select id,name,Authority__c,MobilePhone,Phone from contact where AccountId =:accountInput and Authority__c = 'Full Authority' and Contact_Status__c ='Active'];
        }return contactList;


    }
}