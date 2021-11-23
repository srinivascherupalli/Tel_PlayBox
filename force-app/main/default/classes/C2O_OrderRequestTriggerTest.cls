@isTest
public class C2O_OrderRequestTriggerTest {
    @testSetup
    static void setupTestData() {
        csord__Order_Request__c ors = new csord__Order_Request__c();
        ors.name = 'Test';
        ors.csord__Module_Name__c = 'Test1';
        ors.csord__Module_Version__c = 'Test2';
        ors.csord__Process_Status__c = 'Test3';
        ors.csord__Request_DateTime__c = Datetime.now();
        insert ors;
    }
        @isTest static void testC2O_OrderRequestTrigger() {
            test.starttest();
            BypassTrigger.bypassTriggerAtOG = true;
            BypassTrigger.isRunningTestCheck = true;

            csord__Order_Request__c orReq = [SELECT Id,name,csord__Process_Status__c FROM csord__Order_Request__c WHERE name = 'Test' LIMIT 1];
            orReq.csord__Process_Status__c = 'Testing';
            update orReq;
            test.stoptest();
        }
    }