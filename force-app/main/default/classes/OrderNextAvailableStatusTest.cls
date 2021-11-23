/**********************************************************************************************
Name          : OrderNextAvailableStatusTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of OrderNextAvailableStatus
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods processTest
**********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class OrderNextAvailableStatusTest {
    
    /************************************************************************************************
    * Method Name : processTest
    * Description : Used to simulate and test the logic of process method in OrderNextAvailableStatus
    * Parameters  : NA
    * Return      : NA                      
    ************************************************************************************************/
    static testmethod void processTest() {
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.Name = 'test order';
        ord.csord__Status2__c = 'Pending';
        INSERT ord;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.name  = 'test subs';
        sub.csord__Identification__c = 'test identity';
        sub.csord__Status__c = 'Pending';
        sub.csord__Order__c = ord.id;
        INSERT sub;
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service2';
        serv.csord__Identification__c  = 'test identify2';
        serv.csordtelcoa__Service_Number__c = '5';
        serv.csord__Subscription__c = sub.Id;
        serv.csord__Status__c = 'In Progress';
        INSERT serv;
        parentOrchProcess.Order__c = ord.Id;
        UPDATE parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        List<SObject> result = new List<SObject>();
        Test.startTest();
            OrderNextAvailableStatus onas = new OrderNextAvailableStatus();
            result = onas.process((List<SObject>)steps);
        Test.stopTest();
    }
}