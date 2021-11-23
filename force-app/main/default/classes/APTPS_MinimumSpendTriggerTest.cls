@isTest
public class APTPS_MinimumSpendTriggerTest {
 static testMethod void MinimumSpendTriggerTest(){
     Test.startTest();
    APTPS_Minimum_Spend_Entry__c minspend1 = new APTPS_Minimum_Spend_Entry__c();
        minspend1.Name='test';
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237178898');
        Id prodId = null;
         Apttus__APTS_Agreement__c agmt1  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        minspend1.APTPS_Agreement_Line_Item__c=APTPS_TestClassData.agreementLineItemRecord(agmt1.Id, prodId).id;

    minspend1.APTPS_Current_Minimum_Spend__c=12;
    insert minspend1;
    minspend1.APTPS_Current_Minimum_Spend__c=15;
    update minspend1;
     system.assertEquals(minspend1.APTPS_Current_Minimum_Spend__c,15.0);
     Test.stopTest();
  
  }  
}