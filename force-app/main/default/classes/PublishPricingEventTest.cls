/*************************************************************************************************
Name : PublishPricingEventTest 
Description : EDGE-169456 :  One fund Redemption
TestClass for:  PublishPricingEvent
Created by: Jagadeswary
*************************************************************************************************
Change.No.    	Developer Name          Date          	Story Description  
1.              Shashidhar Kumar	10-08-2021       DIGI-2161 : Enhance order orchestration process steps to trigger Pricing MS requests only for subscriptions that has any promotion/discount/redemption applied

*/

@isTest
public class PublishPricingEventTest {

    static testMethod void testMethod1() {
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
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '6';
        serv.csord__Subscription__c = sub.Id;
        serv.csord__Status__c = 'In Progress';
        serv.csordtelcoa__Product_Configuration__c = productConfig.id;
        serv.Redemption_Amount__c = 20;//DIGI-2161
        INSERT serv;
        
        parentOrchProcess.csordtelcoa__Subscription__c = sub.id;
        UPDATE parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        
        List<CSPOFA__Orchestration_Step__c> steplist = [select id,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c from CSPOFA__Orchestration_Step__c where id =:step.id];
        System.assertNotEquals(steplist , null);
        PublishPricingEvent pe = new PublishPricingEvent();
        pe.process(steplist);
         System.assertNotEquals(steplist , null);
    }
	
	static testMethod void testMethod2() {
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
    
         csord__Subscription__c sub1 = new csord__Subscription__c();
        sub1.name  = 'test subs1';
        sub1.csord__Identification__c = 'test identity1';
        sub1.csord__Status__c = 'Pending';
        sub1.csord__Order__c = ord.id;
        sub1.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT sub1;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '6';
        serv1.csord__Subscription__c = sub1.Id;
        serv1.csord__Status__c = 'In Progress';
        serv1.csordtelcoa__Product_Configuration__c = productConfig.id;
        serv1.Redemption_Amount__c = 40;//DIGI-2161
        INSERT serv1;
        
        parentOrchProcess.csordtelcoa__Subscription__c = sub1.id;
        UPDATE parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        
        List<CSPOFA__Orchestration_Step__c> steplist = [select id,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c from CSPOFA__Orchestration_Step__c where id =:step.id];
        System.assertNotEquals(steplist , null);
        PublishPricingEvent pe = new PublishPricingEvent();
        pe.process(steplist);
         System.assertNotEquals(steplist , null);
    }
    
    static testMethod void testMethod3() {
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
    
         csord__Subscription__c sub2 = new csord__Subscription__c();
        sub2.name  = 'test subs1';
        sub2.csord__Identification__c = 'test identity1';
        sub2.csord__Status__c = 'Pending';
        sub2.csord__Order__c = ord.id;
        sub2.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT sub2;
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service1';
        serv2.csord__Identification__c  = 'test identify1';
        serv2.csordtelcoa__Service_Number__c = '6';
        serv2.csord__Subscription__c = sub2.Id;
        serv2.csord__Status__c = 'In Progress';
        serv2.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT serv2;
        
        parentOrchProcess.csordtelcoa__Subscription__c = sub2.id;
        UPDATE parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        
        List<CSPOFA__Orchestration_Step__c> steplist = [select id,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c from CSPOFA__Orchestration_Step__c where id =:step.id];
        System.assertNotEquals(steplist , null);
        PublishPricingEvent pe = new PublishPricingEvent();
        pe.process(steplist);
         System.assertNotEquals(steplist , null);
    }
    
}