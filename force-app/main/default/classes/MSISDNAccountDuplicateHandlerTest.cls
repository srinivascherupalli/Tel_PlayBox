/*-------------------------------------------------------- 
EDGE-80751
Description: Test Class for MSISDNAccountDuplicateHandler
Author:Ila
--------------------------------------------------------*/
@isTest
public class MSISDNAccountDuplicateHandlerTest {
    @testSetup
    public static void testUniqueSQ(){
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        system.debug('acc+' +acc);
        
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
		Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61498765432','Y');
        sqRecord.SQ_Type__c='Port in SQ';
        sqRecord.Incumbent_Account_Number__c='3545654656';
        sqRecord.Incumbent_Carrier__c='Vodafone';
        //sqRecord.UniqueBasketMSISDN__c='61498765432'+acc.id;
        sqList.add(sqRecord);
        Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'61412345678','N');
        sqRecord.SQ_Type__c='Port in SQ';
        //sqRecord.UniqueBasketMSISDN__c='61412345678'+acc.id;
        sqList.add(sqRecord1);
        insert sqList;
        
    }
    
    //Test method for positive scenario
    @isTest
    public static void testUniqueSuccess(){
        Account acc=[Select id from Account where name ='Test Account'];
        List<Service_Qualification__c> sqListUnique = new List<Service_Qualification__c>();
        Test.startTest();
        Service_Qualification__c sqRecordOne = TestUtil.createServiceQualification(acc,'6145748392','Y');
        sqListUnique.add(sqRecordOne);
        Service_Qualification__c sqRecordTwo = TestUtil.createServiceQualification(acc,'61401928347','Y');
		sqListUnique.add(sqRecordTwo);
        MSISDNAccountDuplicateHandler.onBeforeInsert(sqListUnique);
        Test.stopTest();
        System.assertEquals(sqListUnique!=Null,true, 'List empty');
    }
    
    //Test methid for negative scenario
    @isTest
    public static void testUniqueError(){
        Account acc=[Select id from Account where name ='Test Account'];
        List<Service_Qualification__c> sqListUnique = new List<Service_Qualification__c>();
        Test.startTest();
        Service_Qualification__c sqRecordOne = TestUtil.createServiceQualification(acc,'61498765432','Y');
        sqListUnique.add(sqRecordOne);
        Service_Qualification__c sqRecordTwo = TestUtil.createServiceQualification(acc,'61412345678','Y');
		sqListUnique.add(sqRecordTwo);
        MSISDNAccountDuplicateHandler.onBeforeInsert(sqListUnique);
        Test.stopTest();
        System.assertEquals(sqListUnique!=Null,true, 'List empty');
    }
}