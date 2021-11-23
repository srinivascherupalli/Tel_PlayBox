/**================================================================
* Name: Orchestration_LinkPctoReplacedPCChownTest
* Main Class : Orchestration_LinkPctoReplacedPCChown
* Created Date: March 8, 2021
* Created By: Vaibhav Deshpande
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_LinkPctoRepPCChownTest{
  @Testsetup
  static void dataSetup() {
    //Declare different list to store data
    List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
    List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
    List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    List<account> accountList = new List<account>();
    list<Attachment> attachmentList = new List<Attachment>();
    List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
    List<csord__Order__c> orderList = new List<csord__Order__c>();
    list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
    list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
    List<csord__Service__c> servlist = new List<csord__Service__c>();
    Governor_Limits__c governerLimit = new Governor_Limits__c();
    List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
    List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
    List<Opportunity> oppList = new List<Opportunity>();
    List<Case> caseList = new List<Case>();
    csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();

    //Creating data for process
    offerList = Orchestration_TestUtility.buildMarkertableOffer(false, 2);
    offerList[0].Name = OrchestratorConstants.ProductConfigMarketableOffer.DeviceOutrightPurchase;
    offerList[0].Config__c = '{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
    insert offerList;
    subsSettings = Orchestration_TestUtility.buildsubOption();
    governerLimit = Orchestration_TestUtility.buildLimits();
    accountList = Orchestration_TestUtility.buildAccount(true, 1);
    oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
    caseList = Orchestration_TestUtility.buildCase(false, 1, oppList, accountList);
    caseList[0].subject = null;
    insert caseList;
    orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);

    csord__Order__c ord = new csord__Order__c();
    ord.name = 'Primary Order';
    ord.csord__Account__c = accountList[0].id;
    ord.csord__Status2__c = 'Complete';
    ord.csord__Order_Request__c = orderReqList[0].id;
    ord.csord__Identification__c = 'IDE1322';
    ord.stage__c = 'Being Fulfilled';
    ord.isTransientComplete__c = false;
    ord.csord__Start_Date__c = Date.newInstance(2016, 12, 9);
    insert ord;

    csord__Order__c ord1 = new csord__Order__c(); // not related to any sub
    ord1.name = 'Primary Order';
    ord1.csord__Account__c = accountList[0].id;
    ord1.csord__Status2__c = 'Complete';
    ord1.csord__Order_Request__c = orderReqList[0].id;
    ord1.csord__Identification__c = 'IDE1322';
    ord1.stage__c = 'Being Fulfilled';
    ord1.isTransientComplete__c = false;
    ord1.csord__Start_Date__c = Date.newInstance(2016, 12, 9);
    insert ord1;

    orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, false, 8);
    orderList[0].csord__Primary_Order__c = ord.id;
    orderList[1].csord__Primary_Order__c = ord.id;
    insert orderList;
    processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
    prdList = Orchestration_TestUtility.buildProductDefination(false, 1);
    prdList[0].product_Specification__c = OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000623;
    insert prdList;

    cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
    pcNewMdm.name = 'Enterprise Mobility Managed Service ';
    pcNewMdm.Type__c = 'Cancel';
    pcNewMdm.Quantity_Product_Configuration__c = 111;
    pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
    pcNewMdm.Remaining_Term__c = 0;
    insert pcNewMdm;

    productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 2);
    productconfiglistList[1].ConfigurationType1__c = 'Product Component';
    productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
    productconfiglistList[1].cscfga__Product_Definition__c = prdList[0].id;
    productconfiglistList[1].Remaining_Term__c = 0;
    productconfiglistList[0].Remaining_Term__c = 0;
    productconfiglistList[0].Type__c = 'Cancel';
    productconfiglistList[0].cscfga__Root_Configuration__c = pcNewMdm.id;
    productconfiglistList[0].Marketable_Offer__c = offerList[1].id;

    insert productconfiglistList;

    solutionList = Orchestration_TestUtility.buildSolution(true, 1);

    subscriptionList = Orchestration_TestUtility.buildSubscription(false, 8, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
    subscriptionList[5].csord__order__c = null;
    subscriptionList[1].csord__order__c = orderList[2].id;
    subscriptionList[2].csord__order__c = orderList[2].id;
    subscriptionList[3].csord__order__c = orderList[3].id;
    subscriptionList[4].csord__order__c = orderList[4].id;
    subscriptionList[7].csord__order__c = orderList[1].id;
    subscriptionList[0].csord__order__c = ord.id;
    subscriptionList[0].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
    subscriptionList[1].csord__Status__c = OrchestratorConstants.SubscriptionStatus.ProvisioningInProgress;
    subscriptionList[2].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectPending;
    subscriptionList[3].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectInProgress;
    subscriptionList[4].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectInProgress;
    subscriptionList[5].csord__Status__c = 'Cancellation In Progress';
    subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    subscriptionList[0].MarketableOffer__c = offerList[0].id;
    subscriptionList[1].MarketableOffer__c = offerList[0].id;
    subscriptionList[2].MarketableOffer__c = offerList[0].id;
    subscriptionList[3].MarketableOffer__c = offerList[0].id;
    subscriptionList[4].MarketableOffer__c = offerList[0].id;
    insert subscriptionList;

    servlist = Orchestration_TestUtility.buildService(false, 9, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
    servlist[1].csord__Subscription__c = subscriptionList[1].id;
    servlist[1].csordtelcoa__Replaced_Service__c = null;
    servlist[2].csord__Subscription__c = subscriptionList[2].id;
    servlist[3].csord__Subscription__c = subscriptionList[0].id;
    servlist[0].csord__Order__c = ord.id;
    servlist[1].csord__Order__c = ord.id;
    servlist[2].csord__Order__c = ord.id;
    servlist[3].csord__Order__c = ord.id;
    servlist[4].csord__Order__c = ord.id;
    servlist[5].csord__Order__c = ord.id;
    servlist[6].csord__Order__c = ord.id;
    servlist[7].csord__Order__c = ord.id;
    servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[5].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[6].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[7].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[0].Action_Type__c = 'Modify';
    servlist[1].Action_Type__c = OrchestratorConstants.ServiceActionType.None;
    servlist[2].Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut;
    servlist[3].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
    servlist[4].Action_Type__c = 'Modify';
    servlist[5].Action_Type__c = OrchestratorConstants.ServiceActionType.None;
    servlist[6].Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut;
    servlist[7].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
    servlist[0].Payment_Type__c = 'Not Rental';
    servlist[4].Payment_Type__c = 'Not Rental';
    servlist[8].csord__Order__c = ord.id;

    insert servlist;

    processList = Orchestration_TestUtility.buildProcess(false, 8, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
    processList[4].csordtelcoa__Subscription__c = null;
    processList[0].Order__c = ord.id; // process whose orderId is primary order id of a order
    processList[1].Order__c = ord.id;
    processList[5].Order__c = null;
    processList[6].Order__c = ord1.id; // process whose order doesnot have any subscription
    processList[7].Order__c = orderList[1].id; // process whose order doesnot have any subscription
    insert processList;
    orchStepList = Orchestration_TestUtility.buildOrchStep(false, 8, processList);

    for (CSPOFA__Orchestration_Step__c step : orchStepList) {
      step.JSON__c = null;
    }
    insert orchStepList;

    
  
  }

  static testMethod void ProcessTest() {
    List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    List<csord__Order__c> orderList = new List<csord__Order__c>();
    Test.startTest();
    orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.Order__c != null LIMIT 1];
    Orchestration_LinkPctoReplacedPCChown orderLinkPctoRep = new Orchestration_LinkPctoReplacedPCChown();
    orchStepList = orderLinkPctoRep.process(orchStepList);
    System.assert(orchStepList.size() > 0);
    Test.stopTest();
  }
   
    static testMethod void breakingLimits() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_LinkPctoReplacedPCChown orderLinkPctoRep = new Orchestration_LinkPctoReplacedPCChown();
        orchStepList = orderLinkPctoRep.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;

        System.assertEquals(orchStepList.isEmpty(), true);
        Test.stopTest();
    }

    
     static testMethod void ProcessTestwithAlreadyProcessed() {
    List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    List<Id> subscriptionIds = new List<Id>();
    // Query form datasetup

    orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c limit 1];
    List<csord__Subscription__c> sublist = new List<csord__Subscription__c>([SELECT Id,Name,changeType__c,csord__Order__c,csordtelcoa__Product_Configuration__r.id,csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Product_Configuration__c FROM csord__Subscription__c WHERE csord__Order__c =:orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c]);
    system.debug('sublist206'+sublist);
    Governor_Limits__c governerLimit = new Governor_Limits__c();
    governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
    governerLimit.DML_Rows_limit__c = '3';
    update governerLimit;
    Orchestration_ProcessedRecords processRecords = new Orchestration_ProcessedRecords();
    processRecords.skipRecordsIds = new Set<String>();
    processRecords.pcIds = new Set<String>();

      processRecords.pcIds.add(sublist[0].csordtelcoa__Product_Configuration__r.id);
   
    for (CSPOFA__Orchestration_Step__c step : orchStepList) {
        processRecords.StepId = step.id;
      step.json__c = JSON.serialize(processRecords);
    }
    update orchStepList;
    Test.startTest();
    Orchestration_LinkPctoReplacedPCChown pcChown = new Orchestration_LinkPctoReplacedPCChown();
    orchStepList = pcChown.process(orchStepList);
    // Assert to check message status
    System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Records processed');

    Test.stopTest();
  }
    
 
}