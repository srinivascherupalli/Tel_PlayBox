/**================================================================
 * Name: Orchestration_GenPriSch_Handler_Test
 * Class: Orchestration_GeneratePriceSch_Handler
 * Created Date: 
 * Created By: 
 ==================================================================*/
@isTest
public class Orchestration_GenPriSch_Handler_Test {
@Testsetup
    static void dataSetup() {
        //Orchestration Processes list
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        //Process Templates for Processes
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        //List of Orchestration Steps which needs to be executed
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List of Accounts for order
        List<account> accountList = new List<account>();
        //Order request on Order
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        //List of Subscription
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        // List of Orders
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<Marketable_Offer__c> marketableOffer = new List<Marketable_Offer__c>();
        //Product Configuration List
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList = new List<Attachment>();
        // records for chargeLine Item
        List<Charge_Line_Item__c> cliList = new List<Charge_Line_Item__c>();
        // PricingMSResponseObject__c list
        List<PricingMSResponseObject__c> pmsList = new List<PricingMSResponseObject__c>();
        List<Orchestration_Technical__c>technicalObj= new List<Orchestration_Technical__c>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);

        //Build Marketbale Offer
        marketableOffer = Orchestration_TestUtility.buildMarkertableOffer(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'Primary Order';
        ord.csord__Account__c = accountList[0].id;
        ord.csord__Status2__c = 'Complete';
        ord.csord__Order_Request__c = orderReqList[0].id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';
        ord.isTransientComplete__c = false;
        insert ord;

        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 4);
        //orderList[0].csord__Primary_Order__c = ord.id;
       // orderList[1].csord__Primary_Order__c = ord.id;
        insert orderList;

        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        
        csord__Subscription__c leagcySub = new csord__Subscription__c();
        leagcySub.Name = 'legacySubscription';
        leagcySub.csord__Order__c = orderList[1].id; 
        leagcySub.csord__Identification__c = 'IDE1322';
        leagcySub.triggerBill_RTB__c = false;
        insert leagcySub;

        csord__Subscription__c testSubscriptionReplacement = new csord__Subscription__c();
        testSubscriptionReplacement.Name = 'testSubscriptionReplaced';
        testSubscriptionReplacement.csord__Order__c = orderList[1].id;
        testSubscriptionReplacement.csord__Identification__c = 'IDE1322';
        testSubscriptionReplacement.triggerBill_RTB__c = false;
        insert testSubscriptionReplacement;

        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 4, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        //subscriptionList[1].csordtelcoa__Replaced_Subscription__c = testSubscriptionReplacement.id;
        //subscriptionList[2].legacy_subscription__c = leagcySub.Id;
        for(csord__Subscription__c sub : subscriptionList){
        sub.MarketableOffer__c=marketableOffer[0].Id;
           // sub.csord__Order__c=orderList[2].Id;
        }
        
        insert subscriptionList;
        //subscriptionList[1].csordtelcoa__Replaced_Subscription__c = testSubscriptionReplacement.id;
       // update subscriptionList;

        servlist = Orchestration_TestUtility.buildServiceWOReplace(false, 4, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[2].csord__Subscription__c = subscriptionList[2].id; //serviceIdsToFetchModify
        servlist[2].Scenario_Type__c = 'Change in keypad';
        servlist[3].csord__Subscription__c = subscriptionList[3].id; //serviceIdsToFetchModify
        servlist[0].csord__Subscription__c = subscriptionList[0].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        //for(Integer i=0;i<=3;i++){
        //   servlist[i].csordtelcoa__Replaced_Service__r.csord__Order__c=orderList[0].id; 
       // }
        insert servlist;

        cliList = Orchestration_TestUtility.buildCLIs(false, 4, servlist);
        cliList[0].serviceId__c = servlist[0].Id; //mapchargeLineItemToInsert , CLI2 will be in chargeLineItemMapModifyData
        cliList[3].serviceId__c = servlist[3].Id; //isCompleteModifyOrchestration = false
        cliList[3].status__c = 'Pricing Records Created';//Label.Pricing_Records_Created;
       // cliList[4].serviceId__c = servlist[4].Id; //mapchargeLineItemToInsert
       // cliList[5].serviceId__c = servlist[5].Id;
        cliList[1].serviceId__c = servlist[1].Id;
        cliList[2].serviceId__c = servlist[2].Id;
        insert cliList;
        
        Discount_Line_Item__c dis = new Discount_Line_Item__c();
        insert dis;
        pmsList = Orchestration_TestUtility.buildPMSs(false, 4, cliList);
        
        pmsList[0].CLI_Instance_ID__c = String.valueOf(CLIList[0].Id);
        pmsList[1].CLI_Instance_ID__c = String.valueOf(CLIList[1].Id);
        pmsList[2].CLI_Instance_ID__c = String.valueOf(CLIList[2].Id);
      //  pmsList[4].CLI_Instance_ID__c = String.valueOf(CLIList[3].Id);
      //  pmsList[5].CLI_Instance_ID__c = String.valueOf(CLIList[4].Id);
        pmsList[3].CLI_Instance_ID__c = String.valueOf(CLIList[3].Id);
        pmsList[0].ResponsePayload__c =
        '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI10", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "' +
        dis.id +
        '", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "' +
        dis.id +
        '", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
        pmsList[1].ResponsePayload__c =
        '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI11", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "' +
        dis.id +
        '", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "' +
        dis.id +
        '", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953"  } ] } ] } }';
        pmsList[2].ResponsePayload__c =
        '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI21", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "' +
        dis.id +
        '", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "' +
        dis.id +
        '", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
        pmsList[3].ResponsePayload__c =
        '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI31", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "' +
        dis.id +
        '", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "' +
        dis.id +
        '", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
        
        insert pmsList;
        
        for(Integer i=0;i<=3;i++){
            Orchestration_Technical__c techObj = new Orchestration_Technical__c();
            techObj.Field_5__c=String.valueOf(servlist[i].id);            
            techObj.Service__c=servlist[i].id;
            techObj.Field_14__c='DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3';
            techObj.Field_11__c='Attach0GUID';
            technicalObj.add(techObj);
        }
        insert technicalObj;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false, 4, servlist, productconfiglistList[0].id);
        attachmentList[0].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[0].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        attachmentList[0].Name = 'ServiceSpecifications.json';
    attachmentList[0].ParentId = servlist[0].id;
        attachmentList[1].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[1].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
         attachmentList[1].Name = 'ServiceSpecifications.json';
    attachmentList[1].ParentId = servlist[1].id;
        attachmentList[2].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[2].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
         attachmentList[2].Name = 'ServiceSpecifications.json';
    attachmentList[2].ParentId = servlist[2].id;
        attachmentList[3].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[3].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        attachmentList[3].Name = 'ServiceSpecifications.json';
    attachmentList[3].ParentId = servlist[3].id;
       // attachmentList[4].body = Blob.valueOf(
        //    '{"legacyAttributes":[],"serviceId":"' +
       //     servlist[4].Id +
         //   '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        //);
        insert attachmentList;
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[2].id);
        processList[3].csordtelcoa__Subscription__c = null;
        //processList[0].Order__c = ord.id;
        //processList[3].csordtelcoa__service__c=servlist[3].id;
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        orchStepList[0].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[1].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[2].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[3].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        insert orchStepList;
        
    }
  /*  static testMethod void ProcessInsertSubsTest(){
        List<csord__Order__c>orderList=[SELECT Id from csord__Order__c];
        system.debug('OrderIds### '+orderList);
        Test.startTest();
        for(csord__Order__c ord:orderList){        
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ord.Id,false);
        }  
        Test.stopTest();
    }
    static testMethod void ProcessInsertCLITest(){
        List<csord__Order__c>orderList=[SELECT Id from csord__Order__c];
        system.debug('OrderIds### '+orderList);
        Test.startTest();
        for(csord__Order__c ord:orderList){        
            Coms_PlatformCacheUtil.insertChargeLineItemsToCache(ord.Id);
        }  
        Test.stopTest();
    }
    static testMethod void ProcessInsertTechObjTest(){
        Set<Id>serviceIds = new Set<Id>();
        Id ord;
        List<csord__Service__c>servList=[SELECT Id,csord__Order__c from csord__Service__c];
        system.debug('serviceIds### '+servList);
        Test.startTest();
        for(csord__Service__c srv:servList){ 
            if(ord!=srv.csord__Order__c){
            serviceIds.add(srv.Id);
            ord=srv.csord__Order__c; 
            }
        } 
        Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(serviceIds,ord);
        Test.stopTest();
    }*/
static testMethod void ProcessTest() {
        String str='';
    List<Id>orderIds=new List<Id>();
    Set<Id>serviceIds = new Set<Id>();
    Id orderId;
    List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        Map<String,Object>payloadMap=new Map<String,Object>();
    
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replaced_Subscription__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            ////subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);            
              //  orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c);
            //orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
               // serviceIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c);
            }
        }
   system.debug('subscriptionIds '+subscriptionIds);
   // List<csord__Order__c>orderList=[SELECT Id from csord__Order__c];
 //   system.debug('OrderIds### '+orderList);
       // for(csord__Order__c ord:orderList){  
          //  if(orderId!=ord){
                //Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ord.Id,true);
           // Coms_PlatformCacheUtil.insertChargeLineItemsToCache(ord.Id);
            //Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(serviceIds,ord.Id);
            
               // orderId=ord;
           // }
       // }
       //List<Attachment>att = [Select Id,ParentId,Name from Attachment];
      ///  for(Attachment attItem:att){
      //  serviceIds.add(attItem.ParentId);
   // }
   Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,false);
    Coms_PlatformCacheUtil.insertChargeLineItemsToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c);
    Test.startTest();
    serviceIds.add(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c);
    system.debug('serviceIds### '+serviceIds);
    system.debug('OrderIds### '+orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
    
   // Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(serviceIds,orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c);
   // for (CSPOFA__Orchestration_Step__c step : orchStepList) {
        payloadMap.put('StepId',orchStepList[0].Id);
        payloadMap.put('subscriptionIds',subscriptionIds);
        payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        str=(String)JSON.serialize(payloadMap);
        system.debug('Str### '+str);
        
        Orchestration_GeneratePriceSch_Handler handler = new Orchestration_GeneratePriceSch_Handler();
        handler.processUpdate(str);
   // }
    Test.stopTest();
       /* Attachment attach = new Attachment();
        Charge_Line_Item__c CLI = new Charge_Line_Item__c();
        CLI = [SELECT ID, billingSpecIdentifier__c, serviceId__c, serviceId__r.name FROM Charge_Line_Item__c WHERE billingSpecIdentifier__c != null LIMIT 1];

        System.assertEquals(CLI.billingSpecIdentifier__c, 'Attach0GUID');

        // Assert to check Tier_Line_Item__c and Price_Schedule_Line_Item__c size
        List<Price_Schedule_Line_Item__c> psls = [SELECT ID FROM Price_Schedule_Line_Item__c];
        System.assertEquals(psls.size() > 0, true);

        List<Tier_Line_Item__c> tlI = [SELECT ID FROM Tier_Line_Item__c];
        System.assertEquals(tlI.size() > 0, true);*/
    }
}