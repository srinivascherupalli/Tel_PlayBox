/*****************************************************************************
@Author: Shamikh Hassan  
@Modified By: Sandeep Soni
@CreateDate: 24-MAY-2019
@ModifiedByandDate: 27 May 2019: Created Methods for positive, negative, bulk record and also created record by requestor profile.
@Description: This Test class contains Test methods for salesup_CertitudeLookupController class. 
@References
Epic :EDGE-53259
Story:EDGE-75828

02/10/2019 Hawaii added new test method fetchSelectedRecord_testPositive
@LastModified:  Modified by Sri, team SFO on 16/01/2020 
                P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation  
Version    Author            Last Modified Date     Description
1.1       Vivian (Hawaii)        21 Apr 2020      Call to partner search method
1.2       RaviTeja(Alexandria)   29 Jun 2020      EDGE-150892 Adding additional SOQL to filter records
1.3       Manish Berad(Amsterdam)27-Oct-2020      EDGE-178650 added changes to search Billing_Account__c,OneFund__c,ContractJunction__c
1.4		  Mofit Pathan(Jaipur)   27-08-2021		  DIGI-13806 Query to accommodate csord__Order__c, ContractJunction__c and Partner_of_Record__c custom object


*******************************************************************************/
@isTest(seeAllData=False)
public class salesup_CertitudeLookupControllerTest {
    
        /*
    * Method Name: fetchLookUpValues_testPositive
    * Description: This method is for bulk request case scenario
    */
    static testMethod void fetchLookUpValues_testBulkData(){
        List <sObject> returnList = new List<sObject>();
        List<Contact> lstContact = new List<Contact>();
        Account acc = soc_TestUtility.CreateAccount();
        for(integer i=0;i<7;i++){
            lstContact.add(new Contact(lastName='test'+i,firstName='test',accountId=acc.Id,email='a12'+i+'@test.com'));
        }
        insert lstContact;
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('test','Contact',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
        System.assert(returnList.size()>4);
    }
    
        /*
    * Method Name: fetchLookUpValues_testPositive
    * Description: This method is for negative test case scenario
    */
    static testMethod void fetchLookUpValues_testNegative(){
        List <sObject> returnList = new List <sObject>();
        Account acc = soc_TestUtility.CreateAccount();
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('Sandeep','Contact',acc.Id,null);
        test.stopTest();
        system.assert(returnList.size()==0);
    }
        /*
    * Method Name: fetchLookUpValues_testPositive
    * Description: This method is for positive test case scenario
    */
    static testMethod void fetchLookUpValues_testPositive(){
        List <sObject> returnList = new List<sObject>();
        Account acc = soc_TestUtility.CreateAccount();
        Contact con=new Contact(lastName='test1',firstName='test1',accountId=acc.Id,email='a123@test.com');
        insert con;
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('Test1','Contact',acc.Id,null);
        
        test.stopTest();
        system.assert(returnList!=null);
        System.assert(returnList.size()==1);
    }
   

    

    //Manish Berad (Amsterdam) EDGE-178650
    static testMethod void fetchLookUpValues(){
        Account acc = soc_TestUtility.CreateAccount();
        Contact con=new Contact(lastName='test1',firstName='test1',accountId=acc.Id,email='a123@test.com');
        insert con;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000501234';
        billAcc.Account__c = acc.id;
        insert billAcc;
        OneFund__c OneFundRecord  = new OneFund__c();
        OneFundRecord.Billing_Account__c = billAcc.id ;
        OneFundRecord.CIDN__c = acc.id ;
        insert OneFundRecord;
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c =con.Email;
        record.Phone__c =con.MobilePhone;
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = acc.id;
        record.Related_Opportunity__c = opp.Id;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN';
        insert record;

		try {
            test.startTest();
            List<Billing_Account__c> lstOfBillingAccount = salesup_CertitudeLookupController.fetchLookUpValues(billAcc.Name,'Billing_Account__c',acc.Id,null);
            salesup_CertitudeLookupController.getOneFundType(OneFundRecord.Id);

            test.stopTest();
            system.assert(lstOfBillingAccount!=null);
            System.assert(lstOfBillingAccount.size()==1);  
       		 } catch (QueryException e) {
        }    
    }
    //Manish Berad (Amsterdam) EDGE-178650
    static testMethod void fetchLookUpValuesOneFund(){
        Account acc = soc_TestUtility.CreateAccount();
        Contact con=new Contact(lastName='test1',firstName='test1',accountId=acc.Id,email='a123@test.com');
        insert con;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000501234';
        billAcc.Account__c = acc.id;
        insert billAcc;
        OneFund__c OneFundRecord  = new OneFund__c();
        OneFundRecord.Billing_Account__c = billAcc.id ;
        OneFundRecord.CIDN__c = acc.id ;
        insert OneFundRecord;
        try {
            test.startTest();
            List<OneFund__c> lstOfOneFund = salesup_CertitudeLookupController.fetchLookUpValues(OneFundRecord.Name,'OneFund__c',acc.Id,null);
            test.stopTest();
            system.assert(lstOfOneFund!=null);
            system.assert(lstOfOneFund.size()==1);
        } catch (QueryException e) {
            
        }    
    }
    
    //Manish Berad (Amsterdam) EDGE-178650
    static testMethod void fetchLookUpValuesCJ(){
        Account acc = soc_TestUtility.CreateAccount();
        Contact con=new Contact(lastName='test1',firstName='test1',accountId=acc.Id,email='a123@test.com');
        insert con;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c =con.Email;
        record.Phone__c =con.MobilePhone;
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = acc.id;
        record.Related_Opportunity__c = opp.Id;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN';
        insert record;
        
        try {
            test.startTest();
            List<ContractJunction__c> lstOfContractJunction = salesup_CertitudeLookupController.fetchLookUpValues(record.Name,'ContractJunction__c',acc.Id,null);
            test.stopTest();
            system.assert(lstOfContractJunction!=null);
            System.assert(lstOfContractJunction.size()==1);
        } catch (QueryException e) {
            
        }    
    }


        /*
    * Method Name: fetchLookUpValues_testPositive
    * Description: This method is for positive test case scenario
    */
    static testMethod void fetchSelectedRecord_testPositive(){
        Account acc = soc_TestUtility.CreateAccount();
        Contact con=new Contact(lastName='test1',firstName='test1',accountId=acc.Id,email='b12@test.com');
        insert con;
        test.startTest();
        sObject returnList = salesup_CertitudeLookupController.fetchSelectedRecord(con.Id,'Contact');
        
        test.stopTest();
        system.assert(returnList!=null);
    }
        /*
    * Method Name: fetchLookUpValues_testPositive
    * Description: This method is for positive test case scenario
    */
    static testMethod void fetchLookUpValues_testByRequestor(){
        List <sObject> returnList = new List<sObject>();
        Profile pf = [select Id,Name from profile where name ='Sales Manager - Enterprise'];
        //CREATE USER
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pf.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com');
        
        insert usr;
        System.runAs(usr){
            test.startTest();
            Account acc = new Account();
            acc.name = 'TestAccount';
            acc.Pref_Comm_Method__c = 'B2B';
            //Modified by Sri, team SFO on 16/01/2020
            //P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
            acc.Imported__c = true; 
            insert acc; 
            
            Contact cnt = new Contact();
            cnt.AccountId = acc.id;
            cnt.LastName = 'Test';
            cnt.Title = 'Ttest';
            cnt.Email = 'test@test.com';
            cnt.Pref_Comm_Method__c = 'Phone';
            cnt.Phone='0456789076';
            cnt.Contact_Status__c = 'Active';
            cnt.Salutation = 'Mr.';
            cnt.FirstName = 'Test Contact';
            cnt.Birthdate = Date.newInstance(1980, 1, 1);
            cnt.Authority__c = 'Full Authority';
            insert cnt; 
            returnList = salesup_CertitudeLookupController.fetchLookUpValues('Test Contact','Contact',acc.Id,null);
            
            test.stopTest();
        }
        system.assert(returnList!=null);
    } 
    
        /*
    * Method Name: fetchAccountLookUpValues_testByRequestor
    * Description: This method is for positive test case scenario
    * Created By : Shamikh Hassan
    * Created Date : 4-JULY-2019
    */
    static testMethod void fetchAccountLookUpValues_testByRequestor(){
        List <sObject> returnList = new List<sObject>();
        Profile pf = [select Id,Name from profile where name ='Sales Manager - Enterprise'];
        //CREATE USER
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pf.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com');
        
        //insert usr;
        
        System.runAs(usr){
            test.startTest();
            Account acc = new Account();
            acc.name = 'TestAccount';
            acc.Pref_Comm_Method__c = 'B2B';
            //Modified by Sri, team SFO on 16/01/2020
            //P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
            acc.Imported__c = true; 
            insert acc; 
            try {
                returnList = salesup_CertitudeLookupController.fetchAccountLookUpValues('TestAccount','account',null);
                
                List <sObject> returnList1 = salesup_CertitudeLookupController.fetchPartnerAccount('TestAccount','account',acc.Id); // v1.1
                test.stopTest();
            } catch (QueryException e) {
                
            }  
        }
        system.assert(returnList!=null);
        System.assert(returnList.size()==1);
    }  
    
        /*
        * Method Name: fetchAccountLookUpValues_testByRequestor
        * Description: This method is for positive test for getUserTheme
        * Created By : Shamikh Hassan
        * Created Date : 4-JULY-2019
        */
     static testMethod void getUserTheme(){
         String theme=salesup_CertitudeLookupController.getUserTheme();
          system.assert(theme!=null);
         system.assert(theme.contains('Theme'));
     }
    
    /*
    * Method Name: fetchLookUpValues_addfiltersTest
    * Description:  EDGE-150892: This method is for test case scenario for handling additional SOQL filter 
    */
    static testMethod void fetchLookUpValues_addfiltersTest(){
        List <sObject> returnList = new List<sObject>();
        Account acc = soc_TestUtility.CreateAccount();
        Contact con=new Contact(lastName='test1',firstName='test1',accountId=acc.Id,Contact_Status__c='Active',Authority__c='Full Authority',email='a124@test.com');
        insert con;
        try {
            test.startTest();
            returnList = salesup_CertitudeLookupController.fetchLookUpValues('Test1','Contact',acc.Id,'( Authority__c= \'Full Authority\' OR Authority__c = \'Legal Lessee\') AND Contact_Status__c=\'Active\'');
            test.stopTest();
            system.assert(returnList!=null);
            //System.assert(returnList.size()==1);
        } catch (QueryException e) {
            
        } 
    }
    
    /*
    * Method Name: fetchLookUpCaseValues_test
    * Description: This method is for positive test case scenario for case object
    * Created By : Mofit Pathan
    * Created Date : 27th-08-2021
    * Jira : DIGI-13806
    */
    static testMethod void fetchLookUpCaseValues_test()
      {
        String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        List <sObject> returnList = new List<sObject>();
        Account acc = TestUtil.createAccount('Testacc');
        insert acc;  
        Case caseObj = new Case();
            caseObj.subject = 'Test Case Record';
            caseObj.Status = 'New';
            caseObj.description = 'Test Case description';
            caseObj.salesup_No_of_sites_or_services__c= 1;
            caseObj.AccountId=acc.id;
            caseObj.RecordTypeId = recId_salesSupportChild;
        insert caseObj;    
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('00','Case',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
    }
    /*
    * Method Name: fetchLookUpPORValues_test
    * Description: This method is for positive test case scenario for Partner_of_Record__c object
    * Created By : Mofit Pathan
    * Created Date : 27th-08-2021
    * Jira : DIGI-13806
    */
    static testMethod void fetchLookUpPORValues_test()
      {
        List <sObject> returnList = new List<sObject>();
        Account acc = TestUtil.createAccount('Testacc');
        insert acc;
        Partner_of_Record__c porObj = new Partner_of_Record__c();
        porObj.Customer__c=acc.id;
        insert porObj;    
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('POR','Partner_of_Record__c',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
    }
    
    /*
    * Method Name: fetchLookUpOrderValues_test
    * Description: This method is for positive test case scenario for Order object
    * Created By : Mofit Pathan
    * Created Date : 27th-08-2021
    * Jira : DIGI-13806
    */
    static testMethod void fetchLookUpOrderValues_test()
      {
        String recId_appointmentRequired=csord__Order__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Appointment_Required').getRecordTypeId();
        List <sObject> returnList = new List<sObject>();
        Account acc = TestUtil.createAccount('Testacc');
        insert acc;
        csord__Order__c ordObj = new csord__Order__c();
        ordObj.csord__Account__c=acc.id;
        ordObj.Name= 'Test Order';
        ordObj.csord__Identification__c = '12345';
        ordObj.RecordTypeId=recId_appointmentRequired;
        insert ordObj;    
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('Test Order','csord__Order__c',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
    }
	
	/*
    * Method Name: fetchLookUpContractValues_test
    * Description: This method is for positive test case scenario for Contract object
    * Created By : Mofit Pathan
    * Created Date : 27th-08-2021
    * Jira : DIGI-13806
    */
    static testMethod void fetchLookUpContractValues_test()
      {
        String recId_orderForm=ContractJunction__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_Form').getRecordTypeId();
        List <sObject> returnList = new List<sObject>();
        Account acc = TestUtil.createAccount('Testacc');
        insert acc;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;  
        ContractJunction__c conObj = new ContractJunction__c();
        conObj.Account__c=acc.id;
        conObj.Name= 'Test Contract';
        conObj.Related_Opportunity__c = opp.Id;
        conObj.RecordTypeId=recId_orderForm;
        insert conObj;    
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues('Test Contract','ContractJunction__c',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
    }    
    /*
    * Method Name: fetchLookUpOrderNumber_test
    * Description: This method is for positive test case scenario for Order object
    * Created By : Durga
    * Created Date : 20th-09-2021
    * Jira : DIGI-21813
    */
    static testMethod void fetchLookUpOrderNumber_test()
      {
        String recId_appointmentRequired=csord__Order__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Appointment_Required').getRecordTypeId();
        List <sObject> returnList = new List<sObject>();
        Account acc = TestUtil.createAccount('Testacc');
        insert acc;
        csord__Order__c ordObj = new csord__Order__c();
        ordObj.csord__Account__c=acc.id;
        ordObj.Name= 'Order';
        ordObj.csord__Identification__c = '12345';
        ordObj.RecordTypeId=recId_appointmentRequired;
        insert ordObj;    
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues(ordObj.csord__Order_Number__c,'csord__Order__c',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
    }
    /*
    * Method Name: fetchLookUpopportunityNumber_test
    * Description: This method is for positive test case scenario for opportunity object
    * Created By : Durga
    * Created Date : 20th-09-2021
    * Jira : DIGI-21813
    */
    static testMethod void fetchLookUpopportunityNumber_test()
      {
        List <sObject> returnList = new List<sObject>();
        Account acc = TestUtil.createAccount('Testacc');
        insert acc;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;    
        test.startTest();
        returnList = salesup_CertitudeLookupController.fetchLookUpValues(opp.Opportunity_Number__c,'Opportunity',acc.id,null);
        test.stopTest();
        system.assert(returnList!=null);
    }
}