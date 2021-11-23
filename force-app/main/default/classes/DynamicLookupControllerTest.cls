/*************************************************************************************************
EDGE : EDGE-143860
Name:DynamicLookupControllerTest
Description: Test class for DynamicLookupController
Author:Pradeep Bhumi
Modified: Shresth Dixit(DPG-3510 : Added extra parameter filter in method calling for fetchLookUpValues)
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207867         18/05/2021
***************************************************************************************************/

@isTest
public class DynamicLookupControllerTest
{
    
    @testSetup
    public static void setupdata() {
        
        Account accountData = new Account();
        accountData.Customer_Status__c='ACTIVE'; 
        accountData.Name='Test';
        insert accountData;
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'eMail');
        contactData.Email='testacc@sfdc.com';
        contactData.Authority__c='Full Authority';
        insert contactData;
        cspmb__Price_Item__c commerpro=TestUtil.createPriceItem();
        commerpro.Colour__c='Black';
        commerpro.ProdSpecId__c='DMCAT_ProductSpecification_000423';
        commerpro.Type__c='Mobile Handset';
        commerpro.Manufacturer__c='Apple';
        insert commerpro;
        
        //Added by Aman Soni for 207867 || Start
        Profile billConsultantPF = [select id from profile where name = 'Billing Consultant'];
        Profile asaPF = [select id from profile where name = 'Assurance Service Agent'];
        List<User> userList = new List<User>();
        User billConsUser = new User(alias = 'standt',email='billinguser@testbc.com',emailencodingkey='UTF-8',IsActive =true,
            lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
            profileid = billConsultantPF.id,
            timezonesidkey='Australia/Sydney',
            username='billinguser@testbc.com',phone='+121231231234');
        userList.add(billConsUser);

        User asaUser = new User(alias = 'standt',email='assuranceuser@testasa.com',emailencodingkey='UTF-8',IsActive =true,
            lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
            profileid = asaPF.id,
            timezonesidkey='Australia/Sydney',
            username='assuranceuser@testasa.com',phone='+121231231234');
        userList.add(asaUser);
        insert userList;

        Billing_Account__c billingAcc = TestUtil.createBillingAccount('700000006512');
        insert billingAcc;

        Case caseRec = new Case();
        caseRec.Subject = 'Test Case';
        caseRec.Description = 'Test Case Description';
        caseRec.Billing_Account__c = billingAcc.Id;
        caseRec.Contact = contactData;
        caseRec.salesup_Support_Type__c = 'Billing Support';
        caseRec.Status = 'New';
        insert caseRec;
        //Added by Aman Soni for 207867 || End
        
    }
    
    @isTest
    public static void fetchLookUpValuesPostive()
    {       
       //setupdata();//Commented by Aman Soni for 207867 as it is throwing duplicate data error
        String listResult;
        String searchKeyWord='Test FirstName';
        String searchKeyWords='';
        String ObjectName='Contact';
        String Objects='cspmb__Price_Item__c';
        String identifierPrice='cspmb__Price_Item__c.Type__c';
        String recordId='';
        String identifier='Contact.Name';
        Map<String,Object> resultLookUpMap = new Map<String,Object> ();
        resultLookUpMap.put('Type__c','Mobile Handset');
        resultLookUpMap.put('Manufacturer__c','Apple');
        resultLookUpMap.put('Model__c','Apple iphone 64GB');
        resultLookUpMap.put('Colour__c','Black');
        Test.startTest();
        List <sObject> lookUpValues=DynamicLookupController.fetchLookUpValues(searchKeyWord,ObjectName,recordId,identifier,resultLookUpMap,NULL);
        List <sObject> lookUpPrice=DynamicLookupController.fetchLookUpValues(searchKeyWords,Objects,recordId,identifierPrice,resultLookUpMap,NULL);
        Test.stopTest();
        for (sObject resultData:lookUpPrice){
        listResult=String.valueOf(resultData.get('Type__c'));    }
        system.assertEquals(listResult == 'Mobile Handset',true); 
    }
    
    @isTest
    public static void fetchLookUpValuesNegative()
    {
        //setupdata();//Commented by Aman Soni for 207867 as it is throwing duplicate data error
        String searchKeyWord='';
        String ObjectName='cspmb__Price_Item__c';
        String identifier='cspmb__Price_Item__c.Manufacturer__c';
        Map<String,Object> resultSearchMap = new Map<String,Object> ();
        resultSearchMap.put('Type__c','');
        List <sObject> result=DynamicLookupController.fetchLookUpValues(searchKeyWord, ObjectName,'',identifier,resultSearchMap,NULL);
        System.assertEquals(result.size()==0,true);    
    }
    
    /*************************************************************************************************
    EDGE : EDGE-148587
    Name:getUserInfoTestPositive
    Description: Test class for running user as partner user
    Author: Manjunath Ediga
    ***************************************************************************************************/
    @isTest
    public static void getUserInfoTestPositive()
    {
      User partnerUser;  
      UserRole usrRole = new UserRole(Name = 'CEO');
      insert usrRole;
      profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User adminUser = new User(Alias = 'admUsr',Country='Australia',UserRoleId=usrRole.id,Email='admintest@partneruser.com',EmailEncodingKey='UTF-8', LastName='Admin Test', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = adminProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='adminprofileusr@telstra.com');
      insert adminUser;
      System.runAs(adminUser) {
      Account acc = new Account (Name = 'newAcc1');   
      insert acc;
      Contact con = new Contact (AccountId = acc.id,LastName = 'portalTestUser',Pref_Comm_Method__c ='eMail',Authority__c='Full Authority');
      con.Email='testcon@sfdc.com';
      insert con;
      Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='PRM Admin - Australia'];
      partnerUser = new User(Alias = 'pnrUsr',contactId =con.id,Country='Australia',Email='test@partneruser.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = partnerProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='partnerprofileusr@telstra.com');
      insert partnerUser;
      }
      System.runAs(partnerUser){
           Test.startTest();         
           Boolean partnerTrue = DynamicLookupController.getUserInformation();
           system.assertEquals(true, partnerTrue);
           Test.stopTest();
        }
    }
    
    /*************************************************************************************************
    EDGE : EDGE-148587
    Name:getUserInfoTestPositive
    Description: Test class for running user as other than partner user
    Author: Manjunath Ediga
    ***************************************************************************************************/
    @isTest
    public static void getUserInfoTestNegative()
    {
       Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User partnerUser = new User(Alias = 'pnrUsr',Country='Australia',Email='test@partneruser.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = partnerProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='partnerprofileusr@telstra.com');
       insert partnerUser;
       System.runAs(partnerUser){
           Test.startTest();         
           Boolean partnerfalse = DynamicLookupController.getUserInformation();
           system.assertEquals(false, partnerfalse);
           Test.stopTest();
       }       
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207867(21.06)
    Method        : fetchLookUpValuesPosTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void fetchLookUpValuesPosTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Test.startTest();
            List<Billing_Account__c> billingAcc = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c];
            Map<String,Object> resultSearchMap = new Map<String,Object> ();
            String searchKeyWord='Test Case';
            String ObjectName='Case';
            String billingAccountId=billingAcc[0].id;
            System.runAS(billUser){
                List<sObject> lookUpValues=DynamicLookupController.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId,'',resultSearchMap,'');
                System.assertEquals(lookUpValues.isEmpty(),false); 
            }
            System.runAS(asaUser){
                List<sObject> lookUpValues=DynamicLookupController.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId,'',resultSearchMap,'');
                System.assertEquals(lookUpValues.isEmpty(),false); 
            }
        Test.stopTest();
    } 

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207867(21.06)
    Method        : fetchLookUpValuesNegTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void fetchLookUpValuesNegTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Map<String,Object> resultSearchMap = new Map<String,Object> ();
        String searchKeyWord='Test Case';
        String ObjectName='Case';
        String billingAccountId='';
        Test.startTest();
            System.runAS(billUser){
                List<sObject> lookUpValues=DynamicLookupController.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId,'',resultSearchMap,'');
                System.assertEquals(lookUpValues.isEmpty(),true);
            }
            System.runAS(asaUser){
                List<sObject> lookUpValues=DynamicLookupController.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId,'',resultSearchMap,'');
                System.assertEquals(lookUpValues.isEmpty(),true);
            }
        Test.stopTest();
       
    }
}