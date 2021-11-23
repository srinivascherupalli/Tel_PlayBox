@isTest(SeeAllData=false)
public class APTPS_FundTriggerTest {
       
    @isTest static void fundAnnualAccural(){
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
        Fund__c fundRecord = APTPS_TestClassData.fundRecord(agreementRecord.Id,'Growth');
        Product2 productRecord = new Product2(IsActive = true, Name='demo' , ProductCode='1234');
        Upsert productRecord;
        Fund_Product__c fundProductRecord = APTPS_TestClassData.fundProductRecord(fundRecord.Id,productRecord.Id);
        fundProductRecord.APTPS_Year_1__c = 2000;
        fundProductRecord.APTPS_Year_2__c = 3000;
        fundProductRecord.APTPS_Year_3__c = 4000;
        Upsert fundProductRecord;
        Fund_Transaction__c fundTransactionRecord = new Fund_Transaction__c(Fund__c = fundRecord.Id,RecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Initial Credit').getRecordTypeId(),APTPS_Transaction_Amount__c=1000.00);
        Upsert fundTransactionRecord;
        Test.startTest();
        fundRecord.APTPS_Accrual_Method__c = 'Annual';
        fundRecord.APTPS_Payment__c = 'Annually';
        fundRecord.APTPS_Fund_Status__c = 'Active';
        fundRecord.APTPS_Start_Date__c=system.today().addYears(-1);
        fundRecord.APTPS_Expiry_Date__c=system.today().addYears(3);
        system.debug('Fund Trigger test APTPS_Start_Date__c'+fundRecord.APTPS_Start_Date__c);
        system.debug('Fund Trigger test APTPS_Expiry_Date__c'+fundRecord.APTPS_Expiry_Date__c);
        Update fundRecord;
        fundProductRecord.APTPS_Year_1__c = 4000;
        Upsert fundProductRecord;
        fundRecord.APTPS_Fund_Status__c = 'Active';
        Upsert fundRecord;
        system.debug('Fund Trigger test fundRecord'+fundRecord);
        system.assertEquals(fundRecord.Agreement__c, agreementRecord.Id);
        Test.stopTest();
    }
    
    @isTest static void fundtUpFrontAccural(){
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
        Fund__c fundRecord = APTPS_TestClassData.fundRecord(agreementRecord.Id,'Growth');
        fundRecord.APTPS_Accrual_Method__c = 'Upfront';
        fundRecord.APTPS_Payment__c = 'Lump Sum';
        fundRecord.APTPS_Fund_Status__c = 'Active';
        fundRecord.APTPS_Start_Date__c=system.today().addYears(-1);
        fundRecord.APTPS_Expiry_Date__c=system.today().addYears(3);
        update fundRecord;
        List<Product2> productList = new List<Product2>();
        Product2 productRecord1 = new Product2(IsActive = true, Name='demo' , ProductCode='1234');
        Product2 productRecord2 = new Product2(IsActive = true, Name='demo1' , ProductCode='12345');
        productList.add(productRecord1);
        productList.add(productRecord2);
        Upsert productList;
        Fund_Product__c fundProductRecord = APTPS_TestClassData.fundProductRecord(fundRecord.Id,productRecord1.Id);
        fundProductRecord.APTPS_Year_1__c = 2000;
        fundProductRecord.APTPS_Year_2__c = 3000;
        fundProductRecord.APTPS_Year_3__c = 4000;
        Upsert fundProductRecord;
        Fund_Transaction__c fundTransactionRecord = new Fund_Transaction__c(Fund__c = fundRecord.Id,RecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Initial Credit').getRecordTypeId(),APTPS_Transaction_Amount__c=1000.00);
        Upsert fundTransactionRecord;
        Test.startTest();
        Fund_Product__c fundProductRecord1 = APTPS_TestClassData.fundProductRecord(fundRecord.Id,productRecord2.Id);
        fundProductRecord1.APTPS_Year_1__c = 2000;
        fundProductRecord1.APTPS_Year_2__c = 3000;
        fundProductRecord1.APTPS_Year_3__c = 4000;
        Upsert fundProductRecord1;
        system.debug('Fund Trigger test fundRecord'+fundRecord);
        system.assertEquals(fundRecord.Agreement__c, agreementRecord.Id);
        Test.stopTest();
    }
    

}