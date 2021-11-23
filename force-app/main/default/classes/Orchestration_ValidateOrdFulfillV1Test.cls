/*
* Name: Orchestration_ValidateOrdFulfillV1_Test
* Main Class : Orchestration_ValidateOrderFulfillmentV1
==================================================================*/
 @isTest(SeeAllData=false)
public class Orchestration_ValidateOrdFulfillV1Test {

     @Testsetup     static void dataSetup() {
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
		        list<Attachment> attachmentList1 = new List<Attachment>();

        // records for chargeLine Item
        List<Charge_Line_Item__c> cliList = new List<Charge_Line_Item__c>();
        // PricingMSResponseObject__c list
        List<PricingMSResponseObject__c> pmsList = new List<PricingMSResponseObject__c>();
        List<Orchestration_Technical__c>technicalObj= new List<Orchestration_Technical__c>();
 FCR_Settings__c fcr = new FCR_Settings__c();
        List<User> newUser = new List<User>();
        //Build Data to Perform Actions on
         newUser = Orchestration_TestUtility.buildUser(true,1);
	 System.runAs(newUser[0]){ 
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);

   
        fcr = Orchestration_TestUtility.buildFCR();
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

        servlist = Orchestration_TestUtility.buildServiceWOReplace(false, 6, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[2].csord__Subscription__c = subscriptionList[2].id; //serviceIdsToFetchModify
        servlist[2].Scenario_Type__c = 'Change in keypad';
        servlist[3].csord__Subscription__c = subscriptionList[3].id; //serviceIdsToFetchModify
        servlist[0].csord__Subscription__c = subscriptionList[0].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        //for(Integer i=0;i<=3;i++){
        //   servlist[i].csordtelcoa__Replaced_Service__r.csord__Order__c=orderList[0].id; 
       // }
        insert servlist;

        
       
        
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
       // processList[3].csordtelcoa__Subscription__c = null;
        processList[0].Order__c = ord.id;
        //processList[3].csordtelcoa__service__c=servlist[3].id;
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        orchStepList[0].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[1].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[2].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[3].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        insert orchStepList;
        
     /*attachmentList1 = Orchestration_TestUtility.buildAttachment(false,5,servlist,productconfiglistList[0].id);
        //attachmentList1[1].ParentId = productconfiglistList[0].id; // attachment's parent id is product config id//
        //attachmentList1[2].ParentId = productconfiglistList[0].id; // attachment's parent id is product config id 
        //attachmentList1[3].ParentId = productconfiglistList[0].id; // attachment's parent id is product config id
        //attachmentList1[4].ParentId = servlist[2].id; // attachment's parent id is product config id
        attachmentList1[1].Name = 'Operations User_schema.json';
        attachmentList1[2].Name = 'Operations User_schema.json';
        attachmentList1[3].Name = 'Operations User_schema.json';
        //attachmentList[3].Name = 'ServiceSpecifications.json';
        attachmentList1[1].Body = Blob.valueOf('{ "configurations":[ { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" }, { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" } ] }'); 
        attachmentList1[2].Body = Blob.valueOf('{ "configurations":[ { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" }, { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" } ] }'); 
        attachmentList1[3].Body = Blob.valueOf('{ "configurations":[ { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" }, { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" } ] }'); 
        //attachmentList1[4].Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[2].id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","description":"Adaptive Care","id":"a3u5P000000A5eFQAS","currency":"AUD","type":"NEW","billingSpecId":"BSUSG005_CB","billDescription":"Support fee","taxTreatment":"GST Applicable","rateCardId":"7889"},"code":"DMCAT_ProductSpecification_001252_Billing_RecurringCharge_001268","description":"Adaptive Care_Billing_RecurringCharge_001268","endDate":"","guid":"ebf616fa-51ca-369d-4657-ae85a9fa819f","includeBilling":false,"instanceId":"","metadata":{},"name":"1252_RC_1268","productConfigurationId":"a3T5P0000003Ya2UAE","specification":"98042a16-e857-b35d-6bac-ae9f760c732e","startDate":"","status":"Created","version":"1"}]}');
             
        insert attachmentList1;*/
            // system.debug('attachmentList+' +attachmentList[4]);
     
        
     }   
     }
    
    static testMethod void ProcessTestActive() {
         //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<Functional_Contact_Role__c> fcrList = new List<Functional_Contact_Role__c>();
        List<FulfillmentLineItem__c> fliList = new List<FulfillmentLineItem__c>();
        List<Case> caseList = new List<Case>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
         Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c];
        
          orderList = [SELECT ID, skipFulfillment__c FROM csord__Order__c];

       
         subscriptionList = [SELECT id, MarketableOffer__r.Type__c,csord__Status__c,triggerBill_RTB__c,//
                            (SELECT Id, Tenancy_Id__c, Purchase_Order_No__c, csord__Status__c FROM csord__Services__r)
                            FROM csord__Subscription__c
                            ];
        
        Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(orderList[0].id,false);

        Orchestration_ValidateOrderFulfillmentV1
 validateOrderFulfillment = new Orchestration_ValidateOrderFulfillmentV1();
        orchStepList = validateOrderFulfillment.process(orchStepList);
        //Query Updated Data for Assertion 
        
     //   System.assertEquals(orderList[4].skipFulfillment__c, true);
              // System.debug('subscriptionList '+subscriptionList);
        //System.assertEquals(subscriptionList[0].csord__Status__c, 'Provisioned');
        //System.assertEquals(subscriptionList[0].triggerBill_RTB__c, true);
        
        fcrList = [SELECT id FROM Functional_Contact_Role__c];
        fliList = [SELECT id FROM FulfillmentLineItem__c];
        //caseList = [SELECT id FROM Case];
        
       // System.assertEquals(caseList.size() > 0 ? true :false ,true);
      //  System.assertEquals(fliList.size() > 0 ? true :false ,true);
        System.assertEquals(fcrList.size() == 0 ? true :false ,true);
        
        
        Test.stopTest();
    }
    
     // Limits got hit
   /* static testMethod void breakingLimits(){
         //Query to get the Data for Processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
       
          Orchestration_ValidateOrderFulfillmentV1 validateOrderFulfillment = new Orchestration_ValidateOrderFulfillmentV1();
        orchStepList = validateOrderFulfillment.process(orchStepList);
        //Assert to check if the Step is in progress as the Limits were reached.
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }
    //Run class without any limits left
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Custom Limits to check no updation is done
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
          Orchestration_ValidateOrderFulfillmentV1 validateOrderFulfillment = new Orchestration_ValidateOrderFulfillmentV1();
        orchStepList = validateOrderFulfillment.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(isNull, true);
        Test.stopTest();
    }
    
    // Limits got hit : Partial records processed
    static testMethod void breakingLimitsDML1(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Status__c, 
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
               
      Orchestration_ValidateOrderFulfillmentV1 validateOrderFulfillment = new Orchestration_ValidateOrderFulfillmentV1();
        orchStepList = validateOrderFulfillment.process(orchStepList);
     //  System.assertEquals(orchStepList[0].CSPOFA__Message__c ,'Success: Partial records processed');
       
             System.assertNotEquals(orchStepList[0] ,null);

        Test.stopTest();
    }
    //covering innerCatch by bad Json (Error condition)
    static testMethod void breakingLimitsInnerCatch(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
        for(CSPOFA__Orchestration_Step__c step : orchStepList){
           step.JSON__C = OrchestratorConstants.SystemConstant.AttachmentMsg;
        }
        update orchStepList;
              
      Orchestration_ValidateOrderFulfillmentV1 validateOrderFulfillment = new Orchestration_ValidateOrderFulfillmentV1();
        orchStepList = validateOrderFulfillment.process(orchStepList);
       
        System.assertEquals(orchStepList[0].CSPOFA__Status__c ,OrchestratorConstants.OrchestratorStep.Error);
       
        Test.stopTest();
    }*/
    
    public static testmethod void performCalloutsTestSuccess(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
          Test.startTest();

        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      List<csord__Subscription__c> subscriptionList = [SELECT id, MarketableOffer__r.Type__c,csord__Status__c,triggerBill_RTB__c,//
                            (SELECT Id, Tenancy_Id__c, Purchase_Order_No__c, csord__Status__c FROM csord__Services__r)
                            FROM csord__Subscription__c
                            ];
        List<sObject> result = new List<sObject>();
        
        List<cscfga__Product_Configuration__c> pc=[Select Id from cscfga__Product_Configuration__c Limit 1];//DIGI-5635 Change
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new MockProductConfigOEdata('Test'));
        Orchestration_ValidateOrderFulfillmentV1
 validateOrderFulfillment = new Orchestration_ValidateOrderFulfillmentV1
();
        Boolean result1=validateOrderFulfillment.performCallouts(orchStepList);
        result=validateOrderFulfillment.process(orchStepList);
        
        cssmgnt.ProductProcessingUtility.Attribute attr = new cssmgnt.ProductProcessingUtility.Attribute();
        attr.displayValue='8b07bcaa-9c22-92c5-39b8-6d286bb20978';
        attr.name='Test';
        attr.value='GUID';
        attr.showInUI=false;
        attr.value='8b07bcaa-9c22-92c5-39b8-6d286bb20978';


        list<cssmgnt.ProductProcessingUtility.Attribute> attrlist= new list<cssmgnt.ProductProcessingUtility.Attribute>();
        attrlist.add(attr);

        cssmgnt.ProductProcessingUtility.Configuration config= new cssmgnt.ProductProcessingUtility.Configuration();
        config.attributes=attrlist;
        config.configurationName='test comp';
        config.guid='Test config';


        List<cssmgnt.ProductProcessingUtility.Configuration> listconfig= new list<cssmgnt.ProductProcessingUtility.Configuration>();
        listconfig.add(config);


        cssmgnt.ProductProcessingUtility.Component comp= new cssmgnt.ProductProcessingUtility.Component();
        comp.changeType='Test';
        comp.description='Test';
        comp.configurations=listconfig;
        comp.guid='Test';

        list<cssmgnt.ProductProcessingUtility.Component> complist= new list<cssmgnt.ProductProcessingUtility.Component>();
        complist.add(comp);



        Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap = new Map<Id,List<cssmgnt.ProductProcessingUtility.Component>>();
        oeMap.put(pc[0].id,complist);//Fix to remove hardcoded Id for Telstra Collaboration PS

        Map<id,Map<String,String>> calloutResults=validateOrderFulfillment.parseResponse(oeMap);
   
        Test.stopTest();
        
        System.assertEquals(True,result1);
    }
    
}