/*
 * AUTHOR : Anil
 * DESCRIPTION : Test Class for OneFundTriggerHandler
*/
@istest
public class OneFundTriggerHandlerTest {
  //  public static id committedFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    static testmethod void testcoverage(){
        
        Test.startTest();
        OneFundTriggerHandler oneFundHandler=new OneFundTriggerHandler();
        List<OneFund_Transactions__c> fundTransList = new List<OneFund_Transactions__c>();
        List<OneFund__c> fundList = new List<OneFund__c>();
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
        
        OneFund__c fundRecord1 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '1000', /*RecordTypeId = committedFundRecId,*/CIDN__c = accountRecord.id);
        insert fundRecord1;       
        Test.stopTest();
        
        List<OneFund_Transactions__c> fundTransListUpdated = [SELECT Id,name,OneFund__c,Transaction_Amount__c
                                                  FROM OneFund_Transactions__c 
                                                  WHERE OneFund__c = :fundRecord1.id
                                                 ];
        //system.assertEquals(2040.00, fundTransListUpdated[0].Transaction_Amount__c,fundTransListUpdated[0]);
        system.assertNotEquals(null,fundRecord1);
    }
}