/*
===============================================================================================================================
Class : customLookUpDeliveryController
Developer Name : Shubhi
Test Class : customLookUpDeliveryControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia 25/3/2018  Edge-53882 MAC page for Sim Replacement for Assurance service agen Profile
2. 		  Rohit Tripathi	 14/04/2020 INC000092495296 -->ON00043027 SIM Repl :Page getting crashed while selecting Delivery Address. Does not work even with refresh or multiple retries
===============================================================================================================================
*/
public class customLookUpDeliveryController {
    //Sr1. To fetch contacts for delivery 
    @AuraEnabled
    public static List < sObject > fetchDeliveryContactLookUpValues(String searchKeyWord, String ObjectName){
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+searchKeyWord + '%';
        system.debug('searchKeyWord -->' + searchKeyWord );
        List <sObject> lstOfRecords=[SELECT id,Contact_Name__c,ContactId, Contact.Phone, Contact.MobilePhone, Contact.FirstName, Contact.LastName, Contact.Email FROM AccountContactRelation WHERE accountId = :ObjectName and (Contact.Phone like :searchKey OR Contact.MobilePhone like :searchKey OR Contact.FirstName like :searchKey OR Contact.LastName like :searchKey OR Contact.Email like :searchKey)];
        system.debug('lstOfRecords -->' + lstOfRecords);          
        return lstOfRecords;
    }
    //Sr1. to fetch addresses for delivery
    @AuraEnabled
    public static List < sObject > fetchAddressLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+searchKeyWord + '%';
        system.debug('searchKeyWord -->' + searchKeyWord );
        List <sObject> lstOfRecords=new List <sObject>(); 
        if( searchKeyWord!=null && searchKeyWord !='') {
           lstOfRecords=[Select id,Name,Street_calc__c,cscrm__Zip_Postal_Code__c,Locality__c,Address_ID__c,ESA_Code__c from cscrm__Address__c where (name like :searchKey OR Street_calc__c like :searchKey OR cscrm__Zip_Postal_Code__c like :searchKey OR cscrm__City__c like :searchKey OR Address_ID__c like :searchKey) AND Address_ID__c!=null AND Address_Status__c=:System.label.AddressStatusConfirmed limit 200]; // Changed By Rohit for INC000092495296 
        }
        else
        {
           lstOfRecords=[Select id,Name,Street_calc__c,cscrm__Zip_Postal_Code__c,cscrm__City__c,Address_ID__c,Address_Status__c,ESA_Code__c from cscrm__Address__c where Address_ID__c!=null AND Address_Status__c=:System.label.AddressStatusConfirmed limit 50];
        }
        system.debug('lstOfRecords -->' + lstOfRecords);
        return lstOfRecords;
    }
}