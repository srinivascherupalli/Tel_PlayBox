/*****************************************************************
@Name: APTPS_YearlyFundTransactionBatchTest
@Author: Akanksha Trivedi
@CreateDate: 8/02/2017 
@Description: This is the Test class for APTPS_YearlyFundTransactionBatch
******************************************************************/ 
@isTest
public with sharing class APTPS_YearlyFundTransactionBatchTest {
    static void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
       // agmt.Apttus__Account__c =acct.id;
        agmt.Apttus__Agreement_Number__c = '2323';
       // agmt.Apttus__Status_Category__c = 'In Signatures';
       // agmt.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        Fund__c fund=APTPS_TestClassData.fundRecord(agmt.id,'Growth');
        fund.APTPS_Start_Date__c = (system.today()).addYears(-1);
        Id growthTypeId = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get('Growth').getRecordTypeId();
        fund.APTPS_Accrual_Method__c='Annual';
        fund.APTPS_Expiry_Date__c = (system.today()).addYears(4);
        fund.RecordTypeId =growthTypeId;
        upsert fund;
        Product2 p=APTPS_TestClassData.productRecord('prodName');
        Fund_Product__c fundP =APTPS_TestClassData.fundProductRecord(fund.Id, p.id);
         fundP.APTPS_Year_1__c =100;
         fundP.APTPS_Year_2__c =200;
         fundP.APTPS_Year_3__c=300;
         fundP.APTPS_Year_4__c =400;
         fundP.APTPS_Year_5__c =500;
        update fundP;

    }
    

    static testMethod void testYear1(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
        
        Test.startTest();
       
        APTPS_YearlyFundTransactionBatch controller = new APTPS_YearlyFundTransactionBatch();
        Database.executeBatch(controller, 1);
        Fund_Transaction__c fundT = [SELECT Id, name from Fund_Transaction__c limit 1];
        system.assert(fundT!= null);
        Test.stopTest();
    }
  
    static testMethod void testYear2(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];
        fund.APTPS_Start_Date__c = (system.today()).addYears(-2);
        update fund;
        Test.startTest();       
        APTPS_YearlyFundTransactionBatch controller = new APTPS_YearlyFundTransactionBatch();
        Database.executeBatch(controller, 1);
        Fund_Transaction__c fundT = [SELECT Id, name from Fund_Transaction__c limit 1];
        system.assert(fundT!= null);
        Test.stopTest();
    }
    
       static testMethod void testYear3(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];
        fund.APTPS_Start_Date__c = (system.today()).addYears(-3);
        update fund;
        Test.startTest();
       
        APTPS_YearlyFundTransactionBatch controller = new APTPS_YearlyFundTransactionBatch();
        Database.executeBatch(controller, 1);
        Fund_Transaction__c fundT = [SELECT Id, name from Fund_Transaction__c limit 1];
        system.assert(fundT!= null);   
        Test.stopTest();
    }
    
     static testMethod void testYear4(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];
        fund.APTPS_Start_Date__c = (system.today()).addYears(-4);
        update fund;
        Test.startTest();
       
        APTPS_YearlyFundTransactionBatch controller = new APTPS_YearlyFundTransactionBatch();
        Database.executeBatch(controller, 1);
        Fund_Transaction__c fundT = [SELECT Id, name from Fund_Transaction__c limit 1];
        system.assert(fundT!= null); 
        Test.stopTest();
    }
     static testMethod void testYear5(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];
        fund.APTPS_Start_Date__c = (system.today()).addYears(-5);
        update fund;
        Test.startTest();
       
        APTPS_YearlyFundTransactionBatch controller = new APTPS_YearlyFundTransactionBatch();
        Database.executeBatch(controller, 1);
        Fund_Transaction__c fundT = [SELECT Id, name from Fund_Transaction__c limit 1];
        system.assert(fundT!= null); 
        Test.stopTest();
    }
    static testMethod void testYear6(){
        testData();
        Fund__c fund= [SELECT Id, name from Fund__c limit 1];
    Id growthTypeId1 = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get('Growth').getRecordTypeId();

        fund.APTPS_Start_Date__c = (system.today()).addYears(-5);
        fund.RecordTypeId=growthTypeId1;
       fund.APTPS_Expiry_Date__c= (system.today()).addDays(31);
        update fund;
        Test.startTest();
    APTPS_FundTransactionUtil.createFundTransaction(fund);
        system.assert(fund!= null);
      Test.stopTest();
    }

}