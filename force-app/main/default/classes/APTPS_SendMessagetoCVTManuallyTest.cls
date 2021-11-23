/*****************************************************************
@Name: APTPS_SendMessagetoCVTManuallyTest
@Author: Akanksha Trivedi
@CreateDate:22/03/2017 
@Description: This is the Test class for APTPS_SendMessagetoCVTManually
******************************************************************/ 
@isTest
public with sharing class APTPS_SendMessagetoCVTManuallyTest {
    @testSetup static void testSetupData() {
      Account acc = new Account(Name = 'Test Account',Type = 'Customer', ABN__c = '1234', CIDN__c = '1237778898',Pref_Comm_Method__c='Phone', Phone='0400000000',Customer_Status__c='ACTIVE');
      insert acc;
      Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
      Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = acc.Id, RecordTypeId =recordtypeID);
      insert AgreementRecord;
      Id fundRrecordtypeID = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get('TIF').getRecordTypeId();
      Fund__c fundRecord = new Fund__c(Agreement__c = AgreementRecord.Id, RecordTypeId = fundRrecordtypeID);
      insert fundRecord;
      Product2 productRecord = new Product2(Name = 'prodName', Description = 'test', Family = 'test');
      insert productRecord;
      Fund_Product__c fundProductRecord = new Fund_Product__c(Fund__c = fundRecord.Id, Product__c = productRecord.Id);
      insert fundProductRecord;
    }
     static testMethod void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
                
        Account acct = [Select Id,Name,Type,ABN__c,CIDN__c,Pref_Comm_Method__c,Customer_Status__c,Phone from Account where Name='Test Account' LIMIT 1];
        Apttus__APTS_Agreement__c agmt = [Select Id,Name,Apttus__Account__c,RecordTypeId,Apttus__Agreement_Number__c,Apttus__Company_Signed_Date__c from Apttus__APTS_Agreement__c LIMIT 1];
       // agmt.Apttus__Account__c =acct.id;
        agmt.Apttus__Agreement_Number__c = '2323';
       // agmt.Apttus__Status_Category__c = 'In Signatures';
       // agmt.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        system.assertEquals(Date.today(), agmt.Apttus__Company_Signed_Date__c);//EDGE-69042 Sonar Fix
        Fund__c fund=[Select Id,Name,APTPS_Start_Date__c,APTPS_Accrual_Method__c,APTPS_Expiry_Date__c from Fund__c LIMIT 1];
        fund.APTPS_Start_Date__c = (system.today()).addYears(-1);
        Id growthTypeId = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get('Growth').getRecordTypeId();
        fund.APTPS_Accrual_Method__c='Annual';
        fund.APTPS_Expiry_Date__c = (system.today()).addYears(4);
        fund.RecordTypeId =growthTypeId;
        upsert fund;
        Product2 p=[Select Id,Name,Description,Family from Product2 where Name='prodName' LIMIT 1];
        Fund_Product__c fundP =[Select Id,Fund__c,Product__c from Fund_Product__c LIMIT 1];
         fundP.APTPS_Year_1__c =100;
         fundP.APTPS_Year_2__c =200;
         fundP.APTPS_Year_3__c=300;
         fundP.APTPS_Year_4__c =400;
         fundP.APTPS_Year_5__c =500;
        update fundP;

    }
     static testMethod void testAPTPS_SendMessagetoCVTManually(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];
        
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(fund);
        APTPS_SendMessagetoCVTManually controller = new APTPS_SendMessagetoCVTManually(stdCon);
        controller.updateFundForManualCVTNotification();  
        system.assertEquals(controller.fundRecordId, fund.id);
        Test.stopTest();
    }
    
    static testMethod void testNegateAPTPS_SendMessagetoCVTManually(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];        
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(fund);
        APTPS_SendMessagetoCVTManually controller = new APTPS_SendMessagetoCVTManually(stdCon);
        controller.fundRecord = null;
        controller.updateFundForManualCVTNotification();       
        system.assert(controller.fundRecord == null);
        Test.stopTest();
    }
}