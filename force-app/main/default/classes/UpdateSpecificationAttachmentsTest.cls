/*****************
Author: Kunal Dixit
Company: Telstra
Description:Test Class for UpdateSpecificationAttachment
EDGE-77677 changes to reflect CPE delivery date in payload for PRM order
to see changes made, refer development tab in Jira
History : Manish Jha 10-01-2019
Sr.No.    Developer Name          Date          Story Description
1.        Rohit  Tripathi       24/10/2019     EDGE-118261 --> Create Order in First Wave failed with System_Error
2.        Vaibhav Deshpande     03/06/2020     EDGE-121235  
*************/

@isTest
public class UpdateSpecificationAttachmentsTest {
    
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic(testAccount);
        testOpp.name='testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification';
        ord1.Name = 'test order';
        ord1.csord__Status2__c = 'Pending';
        ord1.csord__Order_Request__c=ordReq.id;
        ord1.csordtelcoa__Opportunity__c = testOpp.id;
        insert ord1;
        
        EnvironmentVariable__c setting = new EnvironmentVariable__c();
        setting.Name = 'engageSNRMFallout';
        setting.Value__c = 'FALSE';
        insert setting;
        
        cscrm__Address__c add=new cscrm__Address__c();
        add.Name='Test address';
        insert add;
        
        cscrm__Site__c site=new cscrm__Site__c();
        site.Name='Test';
        site.cscrm__Installation_Address__c=add.Id;
        site.cscrm__Account__c=testAccount.Id;
        
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.Name = 'sub';
        sub.csord__Account__c = testAccount.Id;
        sub.csord__Order__c = ord1.Id;
        sub.csord__Identification__c = 'test6';
        sub.csord__Status__c = 'Active'; 
        sub.Site__c=site.id;
        insert sub;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService_4';
        serv1.csord__Identification__c  = 'testIdentify_4';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = sub.Id;
        serv1.csord__Status__c = 'Created';
        serv1.substage__c = 'Product Requirements Validation';
        serv1.TechnologyType__c= 'Mobile Access';
        serv1.csord__Order__c= ord1.Id;
        insert serv1;
        
    }
    
    static testMethod void processTest() {
        
        csord__Order__c ord=[select id,name from csord__Order__c where name='test order' Limit 1];
        Opportunity opp=[select id,name from Opportunity where name='testOpp' Limit 1];
        Account acc=[select id,name from Account where name='testAccount' Limit 1];
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        
        parentOrchProcess.Order__c= ord.id;
        parentOrchProcess.CSPOFA__Opportunity__c=opp.id;
        parentOrchProcess.CSPOFA__Account__c=acc.id;
        update parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        
        
        
        Test.startTest();
        UpdateSpecificationAttachments objClsaa2 = new UpdateSpecificationAttachments();
        system.debug('steps'+steps);
        List<SObject> result = objClsaa2.process((List<SObject>)steps);
        if(!result.isEmpty()){        
            CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
            System.assertNotEquals(null,value.CSPOFA__Status__c);
        }
        Test.stopTest(); 
    }
}