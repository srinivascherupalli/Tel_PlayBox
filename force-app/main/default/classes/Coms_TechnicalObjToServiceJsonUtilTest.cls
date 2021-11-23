/*************************************************************************************************************
 * @name			Coms_TechnicalObjToServiceJsonUtilTest
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			27 / 09 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-27		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
@isTest
public with sharing class Coms_TechnicalObjToServiceJsonUtilTest {
    @testSetup
    static void setupTestData() {
         //create Accounts
        List<Account> lstOfAccount =Coms_TestDataFactory.createAccount();
        insert lstOfAccount;
        System.assertEquals(10,lstOfAccount.size());
        //create opportunities
        List<Opportunity> lstOpp=Coms_TestDataFactory.createOpportunity(lstOfAccount);
        insert lstOpp;
        System.assertEquals(10,lstOpp.size());
        //create orders
        List<csord__Order__c> lstOrder=Coms_TestDataFactory.createOrder(lstOfAccount,lstOpp);
        insert lstOrder;
        System.assertEquals(10,lstOrder.size());
        //create subscriptions
        List<csord__Subscription__c> lstSubscription=Coms_TestDataFactory.createSubscription(lstOfAccount,lstOrder);
        insert lstSubscription;
        System.assertEquals(10,lstSubscription.size());
        //create services
        List<csord__Service__c> lstServices=Coms_TestDataFactory.createServicesWithOrders(lstSubscription,lstOrder);
        insert lstServices;
        System.assertEquals(10,lstServices.size());
        //create orchestration
        List<Orchestration_Technical__c> lstOrchestration=Coms_TestDataFactory.createOrchestration(lstServices);
        insert lstOrchestration;
        System.assertEquals(10,lstOrchestration.size());
        // create Technical_Child_Attribute__c
        List<Technical_Child_Attribute__c> lsttestOrchestrationChild=Coms_TestDataFactory.createOrchestrationChild(lstOrchestration);
        insert lsttestOrchestrationChild;
        System.assertEquals(50,lsttestOrchestrationChild.size());
    }
    @isTest
    static  void testgenerateAttachmentJSON(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            Id serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service' limit 1].Id;
            Coms_TechnicalObjToServiceJsonUtil returnValue=Coms_TechnicalObjToServiceJsonUtil.generateAttachmentJSON(serviceId);
            Test.stopTest();
            System.assertEquals(serviceId,returnValue.serviceId);
        }
    }
    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    **/
    @isTest
    static  void testparse(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            String json='{"specifications":[{"version":"test field 1","status":null,"startDate":null,"specification":null,"productConfigurationId":null,"name":null,"metadata":null,"instanceId":null,"includeBilling":null,"guid":null,"endDate":"test field 10","description":null,"code":null,"attributes":{"type":"","taxTreatment":"","targetSystem":"","strNumber":[{"schemaId":"","attributes":[{"status":null,"rangeTo":null,"rangeFrom":"test field 10","listCode":null,"FNN":"test field 1"}]},{"schemaId":"","attributes":[{"status":null,"rangeTo":null,"rangeFrom":"test field 10","listCode":null,"FNN":"test field 1"}]},{"schemaId":"","attributes":[{"status":null,"rangeTo":null,"rangeFrom":"test field 10","listCode":null,"FNN":"test field 1"}]},{"schemaId":"","attributes":[{"status":null,"rangeTo":null,"rangeFrom":"test field 10","listCode":null,"FNN":"test field 1"}]},{"schemaId":"","attributes":[{"status":null,"rangeTo":null,"rangeFrom":"test field 10","listCode":null,"FNN":"test field 1"}]}],"externalId":"","currency1":"","chargeId":"","billingSubtype":"","billingSpecId":"","billDescription1":""},"additionalAttributes":null}],"serviceId":"a4e2N0000006skNQAQ","legacyAttributes":null}';
            Coms_TechnicalObjToServiceJsonUtil returnValue=Coms_TechnicalObjToServiceJsonUtil.parse(json);
            Test.stopTest();
            System.assertEquals('a4e2N0000006skNQAQ',returnValue.serviceId);
        }
    }
    
    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    **/
    @isTest
    static  void testgetOrchestrationObjectLabelValueMap(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            Id serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service' limit 1].Id;
            Map<id,string> maptogetOrchestrationObjectLabelValueMap=new Map<id,string>{serviceId => 'Status,productConfigurationId,code'};
            Map<Id,  Map<string,string>> returnValue = Coms_TechnicalObjToServiceJsonUtil.getOrchestrationObjectLabelValueMap(maptogetOrchestrationObjectLabelValueMap);
            Test.stopTest();
            System.assertEquals(1,returnValue.size());
        }
    }
    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    **/
    @isTest
    static  void testgetTechnicalChildAttributeObjectLabelValueMap(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
        Test.startTest();
        Id serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service' limit 1].Id;
        Map<id,string> maptogetOrchestrationObjectLabelValueMap=new Map<id,string>{serviceId => 'Status,productConfigurationId,code'};
        Map<id , List<Technical_Child_Attribute__c>> returnValue = Coms_TechnicalObjToServiceJsonUtil.getTechnicalChildAttributeObjectLabelValueMap(maptogetOrchestrationObjectLabelValueMap);
        Test.stopTest();
        System.assertEquals(1,returnValue.size());
        }
    }
}