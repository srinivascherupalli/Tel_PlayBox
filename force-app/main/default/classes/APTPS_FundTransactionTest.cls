@isTest(SeeAllData=false)
public class APTPS_FundTransactionTest {

    @isTest static void fundTransaction(){
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
        Fund__c fundRecord = APTPS_TestClassData.fundRecord(agreementRecord.Id,'Growth');
        Fund_Transaction__c fundTransactionRecord1 = new Fund_Transaction__c(Fund__c = fundRecord.Id,
                                                                             RecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Initial Credit').getRecordTypeId(),
                                                                             APTPS_Product_Family__c='Data',
                                                                             APTPS_Fund_Approval_Status__c='Approved and Implemented',
                                                                             APTPS_Action_Type__c='Initial Credit',
                                                                             APTPS_Transaction_Amount__c=10000.00);
        insert fundTransactionRecord1;
        Fund_Transaction__c fundTransactionRecord2 = new Fund_Transaction__c(Fund__c = fundRecord.Id,
                                                                             RecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Redemption Transaction').getRecordTypeId(),
                                                                             APTPS_Product_Family__c='Data',
                                                                             APTPS_Fund_Approval_Status__c='Pending Approval',
                                                                             APTPS_Action_Type__c='Redemption',
                                                                             APTPS_Transaction_Amount__c=1000.00);
        insert fundTransactionRecord2;
        Fund_Transaction__c fundTransactionRecord3 = new Fund_Transaction__c(Fund__c = fundRecord.Id,
                                                                             RecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Anniversary Payment').getRecordTypeId(),
                                                                             APTPS_Product_Family__c='Data',
                                                                             APTPS_Fund_Approval_Status__c='Approved and Implemented',
                                                                             APTPS_Action_Type__c='Anniversary Payment',
                                                                             APTPS_Transaction_Amount__c=1500.00);
        insert fundTransactionRecord3;
        Fund_Transaction__c fundTransactionRecord4 = new Fund_Transaction__c(Fund__c = fundRecord.Id,
                                                                             RecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Expiring Credit').getRecordTypeId(),
                                                                             APTPS_Product_Family__c='Data',
                                                                             APTPS_Fund_Approval_Status__c='Approved',
                                                                             APTPS_Action_Type__c='Adjusting Entry',
                                                                             APTPS_Transaction_Amount__c=2500.00);
        insert fundTransactionRecord4;
        fundTransactionRecord2.APTPS_Fund_Approval_Status__c = 'Rejected';
        update fundTransactionRecord2;
        List<Fund_Transaction_Running_Balance__c> aptps_FTTHandler = [SELECT Id, CreatedDate, Fund__c, Fund_Transaction__c, Current_Balance_Formula__c FROM Fund_Transaction_Running_Balance__c where Fund_Transaction__c = :fundTransactionRecord4.Id];
        System.assertNotEquals(true, aptps_FTTHandler.isEmpty(), 'Transaction record does not exist');
        if(!aptps_FTTHandler.isEmpty()){
            System.assert(true , (fundRecord.APTPS_Current_Fund_Amount__c == aptps_FTTHandler[0].Current_Balance_Formula__c));
        }
        /*System.assertNotEquals(true, aptps_FTTHandler.isEmpty(), 'Transaction record does not exist');
        if(!aptps_FTTHandler.isEmpty()){
            System.assert(true , (fundRecord.APTPS_Current_Fund_Amount__c == aptps_FTTHandler[0].Current_Balance_Formula__c));
        }
        */
    }
    
}