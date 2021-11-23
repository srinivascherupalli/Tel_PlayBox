@isTest  
private class NumberTriggerHandlerTest {
    @TestSetup 
    static void dataSetup() {
        Number_Group__c ng = new Number_Group__c();
        ng.Subscription_number__c = 'Sub5678';
        ng.Service_Instance_Id__c = 'TestServiceInstanceId';
        ng.Pattern_Type__c = 'Number';
        insert ng;
        
        Number__c num = new Number__c();
        num.Subscription_number__c = ng.Subscription_number__c;
        num.Service_Id__c = 'testServiceId';
        num.Service_Number__c = 'testServiceNumber';
        num.Status__c = 'Error';
        num.Mobile__c = 'Fixed';
        num.Number_Group__c = ng.Id;
        Insert num;
    }
    @isTest 
    static void testhandleAfterInsert(){
        Number_Group__c ng = [Select Id, Subscription_number__c from Number_Group__c];
        Test.startTest();
        Number__c num = new Number__c();
        num.Subscription_number__c = ng.Subscription_number__c;
        num.Service_Id__c = 'testServiceId';
        num.Service_Number__c = 'testServiceNumber';
        num.Status__c = 'Provisioned';
        num.Mobile__c = 'Fixed';
        num.Number_Group__c = ng.Id;
        Insert num;
        Test.stopTest();
        System.assertNotEquals(num.Id, Null, 'Id is null');
    }
    @isTest 
    static void testhandleAfterInsertMobile(){
        Number_Group__c ng = [Select Id, Subscription_number__c from Number_Group__c];
        Test.startTest();
        Number__c num = new Number__c();
        num.Subscription_number__c = ng.Subscription_number__c;
        num.Service_Id__c = 'testServiceId';
        num.Service_Number__c = 'testServiceNumber';
        num.Status__c = 'Provisioned';
        num.Mobile__c = 'Mobile';
        num.Number_Group__c = ng.Id;
        Insert num;
        Test.stopTest();
        System.assertNotEquals(num.Id, Null, 'Id is null');
    }
    
    @isTest
    static void testhandleAfterUpdate(){
        Number__c num = [Select Id, Status__c from Number__c];
        Test.startTest();
        num.Status__c = 'Active';
        update num; 
        num.Status__c = 'Disconnected';
        update num;
        Test.stopTest();
        System.assertEquals(num.Status__c, 'Disconnected', 'Status__c is not updated');
    }

     @isTest
    static void testhandleAfterDelete(){
        List<Number__c> numList = new  List<Number__c>();
        Number__c num = [Select Id, Status__c from Number__c];
        Test.startTest();
        delete num;
        Test.stopTest();
        numList = [Select Id, Status__c from Number__c];
        System.assertEquals( 0 , numList.size() , 'There will be no number');
    }
}