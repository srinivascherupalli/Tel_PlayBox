/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 24-MAY-2019
@ModifiedByandDate: 24-JUN-2019 :: Added method to support Account fetch from Global Action
                    28-JUN-2019 :: Added "With Sharing" keyword         
@Description: This Test class contains Test methods for salesup_CertitudeLookupController class. 
@References
Epic :EDGE-53259
Story:EDGE-75828
Version    Author            Last Modified Date     Description
1.1        Vivian (Hawaii)        09 Oct 2019             Added with sharing keyword and new fetchSelectedRecord method
1.2        Vivian (Hawaii)        20 Apr 2020             P2OB-5524 Added method for partner search
1.3        RaviTeja(Alexandria)   29 Jun 2020             EDGE-150892 Adding additional SOQL to filter records
1.4		   Shreyansh Sharma(Jaipur)  29 Sept 2020		  P2OB-8751 Query to accommodate Billing Account custom object

1.5        Manish Berad (Amsterdam)  27-Oct-2020          EDGE-178650,EDGE-175758,defect EDGE-190111 added changes to search Billing_Account__c,OneFund__c,ContractJunction__c
1.6		   Shreyansh Sharma (Jaipur)  5-May-2021		  P2OB-10643, Filter 'Active' Contacts in lookup
1.7		   Mofit Pathan (Jaipur)    27-08-2021			  DIGI-13806 Query to accommodate csord__Order__c, ContractJunction__c and Partner_of_Record__c custom object
1.7		   Mofit Pathan (Jaipur)    06-10-2021			  DIGI:27861 Query to accommodate Invoice 
1.8		   Mofit Pathan (Jaipur)    27-10-2021			  DIGI:27314 Added without sharing keyword
******************************************************************************/


public without sharing class salesup_CertitudeLookupController { 
    // temporarily changed to from without to with sharing
    //Method returns All opportunity for a particular accountId to be displayed as results on Flow Account Search Screen
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String accountId,String AdditionalSOQL) {
        
        String searchKey =searchKeyWord + '%';
        string accId=String.escapeSingleQuotes(accountId);
        String OneFundType='ACTIVE';        
		String SFDRecordTypeID=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('SFD_Request').getRecordTypeId();
        
        List < sObject > returnList = new List < sObject > ();
      	String sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where  accountid=:accId and Name LIKE: searchKey ';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        // SHREYANSH SHARMA P2OB:8751 Jaipur; add support for 'Billing_Account__c' custom object
        if(ObjectName == 'Billing_Account__c'){
         	sQuery =  'select id, Name, Billing_Account_Number__c from ' +String.escapeSingleQuotes(ObjectName) + ' where  Account__c=:accId';   
        }
        // Mofit Pathan DIGI:13806 Jaipur : Query to accommodate csord__Order__c, ContractJunction__c and Partner_of_Record__c custom object
        else if(ObjectName == 'csord__Order__c'){
         	sQuery =  'select id, Name, csord__Order_Number__c from ' +String.escapeSingleQuotes(ObjectName) + ' where  csord__Account__c=:accId';
        }
        else if(ObjectName == 'Partner_of_Record__c'){
         	sQuery =  'select id, Name, Customer__c from ' +String.escapeSingleQuotes(ObjectName) + ' where  Customer__c=:accId';
        }
        else if(ObjectName == 'OneFund__c'){//EDGE-175758 added by Manish B
             sQuery =  'select id, Name,OneFund_Type__c from ' +String.escapeSingleQuotes(ObjectName) + ' where OneFund_Status__c=:OneFundType and CIDN__c=:accId';
             
        }else if(ObjectName == 'ContractJunction__c'){//EDGE-178650 added by Manish B
            sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where Account__c=:accId';
        } else if(ObjectName == 'cscrm__Account_Address_Relationship__c'){// added by Durga
            sQuery =  'select id, cscrm__Address__r.Name from ' +String.escapeSingleQuotes(ObjectName) + ' where cscrm__Account__c=:accId';
        }
        else if(ObjectName == 'Case'){// added by Sanjay
            
            sQuery =  'select id, CaseNumber from ' +String.escapeSingleQuotes(ObjectName) + ' where Case.AccountId=:accId AND RecordTypeId =: SFDRecordTypeID';
        }
        else if(ObjectName == 'Contact'){// Shreyansh Sharma(Jaipur)P2OB-10643, filter 'active' Contacts to show in lookup
            
             sQuery =  'select id, Contact_Status__c,Name from ' +String.escapeSingleQuotes(ObjectName) + ' where accountid=:accId AND Contact_Status__c =\'Active\'';
        }
        // Mofit DIGI:27861 Jaipur : Query to accommodate Invoice 
        else if(ObjectName == 'Invoice__c'){
            sQuery =  'select id, Name,Issue_Date__c from ' +String.escapeSingleQuotes(ObjectName) + ' where  Billing_Account__c=:accId';
       }
        // Durga DIGI:21813 Jaipur : Query to accommodate Opportunity 
        else if(ObjectName == 'Opportunity'){
            sQuery =  'select id, Name, Opportunity_Number__c from ' +String.escapeSingleQuotes(ObjectName) + ' where  AccountId=:accId';
       }
        else sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where  accountid=:accId';// and Name LIKE: searchKey ';
        //EDGE-178650 added by Manish B
        if(String.isNotEmpty(searchKeyWord)){
            if (ObjectName == 'cscrm__Account_Address_Relationship__c') { // Added by Durga
                sQuery=sQuery+' AND cscrm__Address__r.Name LIKE: searchKey ';
            } else if (ObjectName == 'Case') { // Added by Sanjay
                sQuery=sQuery+' AND CaseNumber LIKE: searchKey ';
            } else if (ObjectName == 'Billing_Account__c') { // Added by Mofit-Team Jaipur
                sQuery=sQuery+' AND Billing_Account_Number__c LIKE: searchKey ';
            } else if (ObjectName == 'csord__Order__c') { // Added by Durga-Team Jaipur
                sQuery=sQuery+' AND csord__Order_Number__c LIKE: searchKey ';
            } else if (ObjectName == 'Opportunity') { // Added by Durga-Team Jaipur
                sQuery=sQuery+' AND ( (Opportunity_Number__c LIKE: searchKey) OR (Name  LIKE: searchKey) ) ';
            }else {
                sQuery=sQuery+' AND Name LIKE: searchKey ';
            }
        }
        
        //EDGE-150892 Added to handle additional SOQL filter on Search Results 
        if(AdditionalSOQL!=null && AdditionalSOQL !=''){            
            sQuery=sQuery+' AND '+AdditionalSOQL;
        }
        sQuery=sQuery+' order by createdDate DESC limit 50';
        
        List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery).replaceAll('\\\\', ''));//for QA2 defect EDGE-190111

        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static sObject fetchSelectedRecord(String recordId, String ObjectName){
        string recId=String.escapeSingleQuotes(recordId);
        // Create a Dynamic SOQL Query For Fetch specific Record   
        String sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where  Id=:recId limit 1';
        
        List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
        
        if(!lstOfRecords.isEmpty()){
            return lstOfRecords[0];
        }else{
            return null;
        }
    }
    
    //Method returns All accounts to be displayed as results on Flow Account Search Screen
    @AuraEnabled
    public static List < sObject > fetchAccountLookUpValues(String searchKeyWord, String ObjectName,String AdditionalSOQL) {
        
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery = 'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where  Name LIKE: searchKey ';

        //EDGE-150892 Added to handle additional SOQL filter on Search Results
        if(AdditionalSOQL!=null && AdditionalSOQL !=''){           
            sQuery=sQuery+' AND '+AdditionalSOQL;
        }
		   
		
		sQuery=sQuery+' order by createdDate DESC limit 50';
        List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery).replaceAll('\\\\', ''));//added for QA2 defect EDGE-190111
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    //Method returns All Nominates or Direct Partner accounts to be displayed as results on Flow Account Search Screen
    @AuraEnabled
    public static List < sObject > fetchPartnerAccount(String searchKeyWord, String ObjectName, Id primaryDistributorId) {
        String searchKey =searchKeyWord + '%';
        String priDistributorId=String.escapeSingleQuotes(primaryDistributorId);
        List < sObject > returnList = new List < sObject > ();
        String account_Status='Active';
        String partnerType_Partner='Partner';
        String partnerType_Nominate='Nominate';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name, Partner_Type__c, Primary_Distributor__c, Account_Status__c from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey and Account_Status__c =:account_Status and (Partner_Type__c =:partnerType_Partner or (Partner_Type__c=:partnerType_Nominate and Primary_Distributor__c =:priDistributorId)) order by createdDate DESC limit 50';
        List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
     //Method returns User Theme to set various values in case origin
     @AuraEnabled
    public static String getUserTheme(){
        return UserInfo.getUiThemeDisplayed();
    }
    
    //return oneFund type for selected OneFund
    @AuraEnabled
    public static String getOneFundType(String recordId){
        OneFund__c onefund=[select id, Name,OneFund_Type__c from OneFund__c Where Id=:String.escapeSingleQuotes(recordId)];
        return onefund.OneFund_Type__c;
    }

}