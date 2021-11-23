@isTest(SeeAllData=false)
public class APTPS_ScheduleWrapperTest {
    
    static testMethod void testMethod1(){
        
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '3217778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Status__c = 'Request';
        update agmt;
        
        APTPS_ScheduleWrapper sw1 = new APTPS_ScheduleWrapper(agmt);
        sw1.isInserted = false;
        sw1.displayImage = 'false';
        sw1.status = '';
        
        System.assertEquals(sw1.agreementstatus, agmt.Apttus__Status__c);
         System.assertEquals(sw1.agreementCategory, agmt.Apttus__Agreement_Category__c);
         System.assertEquals(sw1.agreementSubCategory, agmt.APTPS_Agreement_Subcategory__c);
         System.assertEquals(sw1.agreementNumber, agmt.Apttus__FF_Agreement_Number__c);
        
        Test.stopTest();
    }
    
}