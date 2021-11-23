/*************************************************************************************************
Name     : BulkUploadSimSerialNumbersCtrl
Description :Test class for BulkUploadSimSerialNumbersCtrl
Author    :Purushottam
Story    : DIGI-1946
***************************************************************************************************/
@isTest
public class BulkUploadSimSerialNumbersCtrlTest {
    @testSetup 
    public static void setupdata(){ 
        NumberReservationHelperTest.setupdataForMobile();
    }
    @isTest
    public static void validateMobileNumbersTest(){
        Number__c cp= [select id,Basket__r.name from Number__c where Service_Number__c='61459812342'];
        Test.startTest();
        Map<String,List<String>> validateResult=BulkUploadSimSerialNumbersCtrl.validateMobileNumbers(new List<String>{'61459812342,123,'+cp.Basket__r.name,'61459812345,123,'+cp.Basket__r.name });
        Test.stopTest();
        System.assertEquals(0, validateResult.get(cp.Basket__r.name).size());
    }
    @isTest
    public static void updateSimNumbersTest(){
        Number__c cp= [select id,Basket__r.name from Number__c where Service_Number__c='61459812342'];
        Test.startTest();
        BulkUploadSimSerialNumbersCtrl.updateSimNumbers(new List<String>{'61459812342,123,'+cp.Basket__r.name});
        Test.stopTest();
        Number__c updatedNum= [select id,Sim_Serial_Number__c from Number__c where Service_Number__c='61459812342'];
        System.assertEquals('123', updatedNum.Sim_Serial_Number__c);
    }
    @isTest
    public static void updateSimNumbersNegativeTest(){
        
        Number__c cp= [select id,Basket__r.name from Number__c where Service_Number__c='61459812342'];
        try{
            Test.startTest();
            BulkUploadSimSerialNumbersCtrl.updateSimNumbers(new List<String>{'61459812342'+cp.Basket__r.name});
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(NUll, e.getMessage());
        }
    }
}