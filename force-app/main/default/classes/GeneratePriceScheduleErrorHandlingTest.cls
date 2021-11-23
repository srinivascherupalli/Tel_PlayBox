/*************************************************************************************************
Name : GeneratePriceScheduleErrorHandlingTest 
Description : EDGE-123581 : Test Class for GeneratePriceScheduleErrorHandling
===============================================================================================================================
Sr.No.    Developer Name      Date          Story        Description
1.        Gnana               26-Mar-2020   Created
===============================================================================================================================
***************************************************************************************************/
@isTest
public class GeneratePriceScheduleErrorHandlingTest {

    @testSetup
    public static void testdatasetup(){
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c='Active';
        subs.csordtelcoa__Subscription_Number__c='SN-123456';
        subs.Suspension_reason__c='Requested by Customer';
        insert subs;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPCold = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPCold;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site',csordtelcoa__Replaced_Product_Configuration__c=userPCold.id, cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.csordtelcoa__Product_Configuration__c = userPC.id;
        serv.Telstra_Committed_Date__c = Date.today() + 30;
        insert serv;
        
        Charge_Line_Item__c chargeLineItem = new Charge_Line_Item__c();
        chargeLineItem.CorrelationId__c = 'COR234';
        chargeLineItem.status__c = 'New';
        chargeLineItem.basketId__c = basket.Id;
        chargeLineItem.serviceId__c = serv.Id;
        Insert chargeLineItem;
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        parentOrchProcess.Order__c = ord.Id;
        parentOrchProcess.csordtelcoa__Subscription__c = subs.Id;
        parentOrchProcess.CSPOFA__Status__c = 'In Progress';
        update parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        step.Name = 'Generate Price Schedule';
        step.CSPOFA__Status__c  = 'Waiting';
        update step;
    }
    
    @isTest
    private static void insertJeopardyCaseTest(){
        
        Set<String> listOfCorrelationIds = new Set<String>();       
        listOfCorrelationIds.add('COR234');
         Map<String,String> corelationIdSubIdError = new Map<String,String>();
         corelationIdSubIdError.put('COR234', null);
     
        Test.StartTest();
        GeneratePriceScheduleErrorHandling.insertJeopardyCase(listOfCorrelationIds , corelationIdSubIdError);        //Updated type of argument
        Test.StopTest();
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();
        Case c = [SELECT Id, Feedback_Related_Record_ID__c FROM Case WHERE RecordTypeId = :devRecordTypeId];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        System.assertEquals(c.Feedback_Related_Record_ID__c, opp.Id);
        CSPOFA__Orchestration_Step__c step = [SELECT Id,CSPOFA__Status__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        System.assertEquals(step.CSPOFA__Status__c, 'Error');
    }
}