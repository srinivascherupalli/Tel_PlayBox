/*************************************************************************************************
Name : UpdateFnnDetailsTest
Description : Test class for UpdateFnnDetails
Author: Kalashree Borgaonkar
Story: EDGE-108230
***************************************************************************************************/
@isTest
public class UpdateFnnDetailsTest {
    
    /*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-108230 
Descripton : Create Data
-------------------------------------------------------------------------------------*/
    @testSetup 
    public static void setupdata(){
        TestDataFactory.generateProductConfiguration();
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        cscfga__Product_Configuration__c productConfig  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];    
        productConfig.cscfga__Product_Basket__c=basket.Id;
        update productConfig;
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
        sub.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT sub;
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service2';
        serv.csord__Identification__c  = 'test identify2';
        serv.csordtelcoa__Service_Number__c = '5';
        serv.csord__Subscription__c = sub.Id;
        serv.csord__Status__c = 'In Progress';
        serv.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT serv;
        parentOrchProcess.Order__c = ord.Id;
        UPDATE parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        //List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        //steps.add(step);
        List<Number__c> numList=new List<Number__c>();
        Number__c fnnNumber1 = Testutil.createNumber('61359816905',basket.id,null);
        fnnNumber1.Product_Configuration__c =productConfig.id;
        fnnNumber1.Type__c='FNN';
        fnnNumber1.Status__c = 'RESERVED';
        fnnNumber1.Mobile__c='Fixed';
        numList.add(fnnNumber1);
        Number__c fnnNumber2 = Testutil.createNumber('61359816906',basket.id,null);
        fnnNumber2.Product_Configuration__c =productConfig.id;
        fnnNumber2.Type__c='FNN';
        fnnNumber2.Status__c = 'RESERVED';
        fnnNumber2.Mobile__c='Fixed';
        numList.add(fnnNumber2);
        insert numList;
    }
    static testmethod void processTest() {
        List<CSPOFA__Orchestration_Step__c> steps = [SELECT id,CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c];
        List<SObject> result = new List<SObject>();
        Test.startTest();
        UpdateFnnDetails onas = new UpdateFnnDetails();
        result = onas.process((List<SObject>)steps);
        Test.stopTest();
        System.assertEquals(result!=null,true, 'Success');
    }
}