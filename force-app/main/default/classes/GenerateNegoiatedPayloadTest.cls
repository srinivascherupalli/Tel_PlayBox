/*
* @Author  : Mukta Wadhwani 
  @Team    : Apple
* @Date    : 18-05-2021
* @Desc    : This class is test class for GenerateNegoiatedPayloadTest
* @Jira    : EDGE-218386
*/
@isTest
public class GenerateNegoiatedPayloadTest{
    @Testsetup
    static void dataSetup() {
        List<Account> accountList = Orchestration_TestUtility.buildAccount(false, 2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;

        List<Opportunity> OpportunityList = Orchestration_TestUtility.buildOpp(false, 1, accountList);
        OpportunityList[0].Model_Change__c = false;
        insert OpportunityList;
        Billing_Account__c ba = new Billing_Account__c();
        ba.Account__c = accountList[0].Id;
        ba.Billing_Account_Number__c = '123123122234';
        insert ba;
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = OpportunityList[0].id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Delegation_Role__c = 'Account Executive',//EDGE-186881
                LocaleSidKey = 'en_US'

        );
        insert u;
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=OpportunityList[0].id;
        fam.Deal_Approver__c=u.Id;
        fam.csconta__Status__c = 'Draft';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); //EDGE-186881
        fam.csconta__effective_start_date__c=System.today();//EDGE-205066
        insert fam;
        cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c(Name = 'test', cscfga__Opportunity__c = OpportunityList[0].Id,csconta__Frame_Agreement__c=fam.Id);
        insert pb;
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.Auto_Expired_Entity__c = true;
        marketableOffer.Offer_ID__c = 'DMCAT_Offer_000618';
        marketableOffer.Invoice_Definition__c = 'Invoice_Def_1';
        insert marketableOffer;


        cscfga__Product_Definition__c productDefNGUC = new cscfga__Product_Definition__c(
                Name = 'User Support', // Name
                csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                cscfga__Description__c = 'User Support', // Description
                cscfga__Label__c = 'User Support', // Label
                product_Specification__c = 'DMCAT_ProductSpecification_000871' // product Specification

        );
        insert productDefNGUC;
		cscfga__Product_Definition__c productDefIOT = new cscfga__Product_Definition__c(
                Name = 'User Support', // Name
                csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                cscfga__Description__c = 'IoT Plans', // Description
                cscfga__Label__c = 'IoT Plans', // Label
                product_Specification__c = 'DMCAT_ProductSpecification_001523' // product Specification

        );
		insert productDefIOT;
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        solutionList = Orchestration_TestUtility.buildSolution(false, 2);
        solutionList[0].Name = 'TestSubsforTest0';
        insert solutionList;
        list<cscfga__Product_Configuration__c> productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 2);
        productconfiglistList[0].ConfigurationType1__c = '';
        productconfiglistList[0].cscfga__Product_Definition__c = productDefNGUC.Id;
        productconfiglistList[0].cscfga__Product_Basket__c = pb.Id;
        upsert productconfiglistList;
        System.debug('-=00=- '+productconfiglistList);
		productconfiglistList[1].ConfigurationType1__c = '';
        productconfiglistList[1].cscfga__Product_Definition__c = productDefIOT.Id;
        productconfiglistList[1].cscfga__Product_Basket__c = pb.Id;
        upsert productconfiglistList;
		
        List<csord__Order_Request__c> orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 2);
        orderList[0].Billing_Account__c = ba.Id;
        orderList[1].Billing_Account__c = ba.Id;
        insert orderList;

        //orderList[0].csord__Primary_Order__c = orderList[0].Id;
        orderList[1].csord__Primary_Order__c = orderList[0].Id;
        update orderList;
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.MarketableOffer__c = marketableOffer.id;
        testSubscription.Name = 'test Subscription for NGUC';
        testSubscription.csord__Account__c = accountList[1].id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
        testSubscription.csord__Order__c = orderList[0].id; // used in Orchestration_EvaluateOrderStatusTest
        testSubscription.csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        testSubscription.triggerBill_RTB__c = false;
        //testSubscription.Billing_Account__c = ba[0];
        testSubscription.cssdm__solution_association__c = solutionList[0].id;
        testSubscription.isAggregationPoint__c = true;
        testSubscription.oldServiceMSISDN__c = 'Testing';
        testSubscription.autoExpiry__c = true;
        testSubscription.TenancyID__c = 'T1002';
        insert testSubscription;
        csord__Service__c ngucService = new csord__Service__c();
        ngucService.csord__Order__c = orderList[0].Id;
        ngucService.csord__Status__c = 'created';
        ngucService.csord__Identification__c  = 'ngucService';
        ngucService.csord__Subscription__c = testSubscription.Id;
        ngucService.csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        ngucService.Scenario_Type__c = 'NGUC Service';
        insert ngucService;
        csord__Service__c iotService = new csord__Service__c();
        iotService.csord__Order__c = orderList[0].Id;
        iotService.csord__Status__c = 'created';
        iotService.csord__Identification__c  = 'iotService';
        iotService.csord__Subscription__c = testSubscription.Id;
        iotService.csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        iotService.Scenario_Type__c = 'IOT Service';
        insert iotService;
        cspmb__Price_Item__c featureChargeComProductObj = new cspmb__Price_Item__c(
                Name = 'User Support',
                cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
                cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
                cspmb__Is_Active__c = true,
                cspmb__Price_Item_Code__c = 'User Support',
                cspmb__Product_Definition_Name__c = 'User Support',
                External_Id__c = 'DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8331',
                BillingSpecId__c = 'BSUSG005_CB',
                Billing_Description__c = 'Feature Usage Charge',
                Plan__c = '',
                Mode__c = '',
                Offer_Id__c = 'DMCAT_Offer_000618'
        );
        insert featureChargeComProductObj;
		cspmb__Price_Item__c featureChargeComProductObj1 = new cspmb__Price_Item__c(
                Name = 'User Support',
                cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
                cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
                cspmb__Is_Active__c = true,
                cspmb__Price_Item_Code__c = 'User Support',
                cspmb__Product_Definition_Name__c = 'User Support',
                External_Id__c = 'DMCAT_Offer_001522_DMCAT_RecurringCharge_001527_9196',
                BillingSpecId__c = 'BSUSG003_CB',
                Billing_Description__c = 'Feature Usage Charge',
                Plan__c = '',
                Mode__c = '',
                Offer_Id__c = 'DMCAT_Offer_001522'
        );
        insert featureChargeComProductObj1;
        cspmb__Price_Item__c callingPlanComProductObj = new cspmb__Price_Item__c(
                Name = 'User Support',
                cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
                cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
                cspmb__Is_Active__c = true,
                cspmb__Price_Item_Code__c = 'User Support',
                cspmb__Product_Definition_Name__c = 'User Support',
                External_Id__c = 'DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8330',
                BillingSpecId__c = 'BSUSG003_CB',
                Billing_Description__c = 'User support - Standard - business hours',
                Plan__c = 'Standard',
                Mode__c = 'Individual Line',
                Offer_Id__c = 'DMCAT_Offer_000618',
                cspmb__Master_Price_item__c = featureChargeComProductObj.Id
        );
        insert callingPlanComProductObj;
        List<cspmb__Rate_Card__c> rateCardList = new List<cspmb__Rate_Card__c>();
        cspmb__Rate_Card__c rateCard_user_data = new cspmb__Rate_Card__c(
                Name = 'User Support - Standard - Bus Hrs',
                Charge_ID__c ='DMCAT_RecurringCharge_000814',
                cspmb__Rate_Card_Code__c = '7900',
                cspmb__Effective_End_Date__c = Date.today()+1,
                cspmb__Effective_Start_Date__c = Date.today()-1,
                cspmb__Is_Active__c = true);
        cspmb__Rate_Card__c featureRateCard = new cspmb__Rate_Card__c(
                Name = 'User Support - Standard - Bus Hrs',
                Charge_ID__c ='DMCAT_RecurringCharge_000810',
                cspmb__Rate_Card_Code__c = '7900',
                cspmb__Effective_End_Date__c = Date.today()+1,
                cspmb__Effective_Start_Date__c = Date.today()-1,
                cspmb__Is_Active__c = true);
        rateCardList.add(rateCard_user_data);
        rateCardList.add(featureRateCard);

        Insert rateCardList;
        List<cspmb__Price_Item_Rate_Card_Association__c> rateCardAssociationList = new List<cspmb__Price_Item_Rate_Card_Association__c>();
        cspmb__Price_Item_Rate_Card_Association__c userDataAssociation = new cspmb__Price_Item_Rate_Card_Association__c();
        userDataAssociation.cspmb__Price_Item__c = callingPlanComProductObj.id;
        userDataAssociation.cspmb__Rate_Card__c = rateCardList[0].id;
        cspmb__Price_Item_Rate_Card_Association__c featureAsooc = new cspmb__Price_Item_Rate_Card_Association__c();
        featureAsooc.cspmb__Price_Item__c = featureChargeComProductObj.id;
        featureAsooc.cspmb__Rate_Card__c = rateCardList[1].id;
        cspmb__Price_Item_Rate_Card_Association__c featureAsooc1 = new cspmb__Price_Item_Rate_Card_Association__c();
        featureAsooc1.cspmb__Price_Item__c = featureChargeComProductObj1.id;
        featureAsooc1.cspmb__Rate_Card__c = rateCardList[1].id;
        rateCardAssociationList.add(featureAsooc);
        rateCardAssociationList.add(featureAsooc1);
        rateCardAssociationList.add(userDataAssociation);

        insert rateCardAssociationList;

        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();

        cspmb__Rate_Card_Line__c rcl1 =PricingTestDataFactory.generateRateCardLine(1,499,rateCardList[0].id,'1');
        rcl1.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl1);

        cspmb__Rate_Card_Line__c rcl2 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[0].id,'1');
        rcl2.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl2);
        cspmb__Rate_Card_Line__c rcl3 =PricingTestDataFactory.generateRateCardLine(1,499,rateCardList[1].id,'1');
        rcl3.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl3);

        cspmb__Rate_Card_Line__c rcl4 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[1].id,'1');
        rcl4.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl4);

        insert rateCardLineList;
        Attachment attchFrame = new Attachment();
        attchFrame.body = Blob.valueOf('{"custom":{},"products":{"'+callingPlanComProductObj.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_addons": {},"_rateCards":{"'+rateCardLineList[0].cspmb__Rate_Card__c+'":{"'+rateCardLineList[0].id+'":'+rateCardLineList[0].cspmb__rate_value__c+',"'+rateCardLineList[1].id+'":'+rateCardLineList[1].cspmb__rate_value__c+'}}  ,"_product":{"recurring":16.18},"_allowances":{}},"'+featureChargeComProductObj.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_addons": {},"_rateCards":{"'+rateCardLineList[3].cspmb__Rate_Card__c+'":{"'+rateCardLineList[3].id+'":'+rateCardLineList[3].cspmb__rate_value__c+',"'+rateCardLineList[2].id+'":'+rateCardLineList[2].cspmb__rate_value__c+'}}  ,"_product":{"recurring":16.18},"_allowances":{}}}},"addons":{}}');
        attchFrame.name = 'FrameAgreementAttachment';
        attchFrame.ParentId = fam.Id;
        insert attchFrame;
    }

    //EDGE-218386 added positive test method for custom rate block generation for NGUC product                              
    @isTest
    private static void populateBillingSpecificationsNGUCTest(){
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c WHERE Scenario_Type__c = 'NGUC Service']);
        list<cscfga__Product_Configuration__c> productconfigList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000871'];
        list<csord__Subscription__c> subList = [select id from csord__Subscription__c where name='test Subscription for NGUC'];
        List<Attachment> attachmentRateCardList = Orchestration_TestUtility.buildAttachment(false, 1, serviceMap.values(), productconfigList[0].id);
        attachmentRateCardList[0].Body = Blob.valueOf('{"specifications" : [ {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId" : "'+productconfigList[0].id+'","name" : "871_RC_810", "metadata" : { },"instanceId" : "",'+
                '"includeBilling" : false,"guid" : "e3fb6446-8e88-f840-2d13-bcd42d478cdb","endDate" : "","description" : "Business Calling_Billing_RecurringCharge_000810","code" : "DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810", "attributes" : {"billDescription" : "Feature Usage Charges","externalId" : "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_8336","chargeId" : "DMCAT_RecurringCharge_000810","billingSpecId" : "BSUSG005_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM", "taxTreatment" : "GST Applicable","__targetSystem" : "BILLING"},"additionalAttributes" : { }},'+
                '{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId" : "'+productconfigList[0].id+'","name" : "871_RC_814","metadata" : { },"instanceId" : "","includeBilling" : false,"guid" : "3b3e5885-4d1c-90b1-4256-5ff3506425c9","endDate" : "","description" : "Business Calling_Billing_RecurringCharge_000814","code" : "DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes" : {"billDescription" : "Individual line - standard calling plan","externalId" : "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329","chargeId" : "DMCAT_RecurringCharge_000814","billingSpecId" : "BSUSG003_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM","taxTreatment" : "GST Applicable","__targetSystem" : "BILLING","sharedPlanId" : "'+productconfigList[0].id+'"},"additionalAttributes" : { }},'+
                '{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId" : "'+productconfigList[0].id+'","name" : "871_RC_814","metadata" : { },"instanceId" : "","includeBilling" : false,"guid" : "3b3e5885-4d1c-90b1-4256-5ff3506425c9","endDate" : "","description" : "Business Calling_Billing_RecurringCharge_000814","code" : "DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes" : {"billDescription" : "Individual line - standard calling plan","externalId" : "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329","concurrencyLimitMode" : "Individual Line","callingPlans" : "Standard","chargeId" : "DMCAT_RecurringCharge_000814","billingSpecId" : "BSUSG003_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM","taxTreatment" : "GST Applicable","__targetSystem" : "BILLING"},"additionalAttributes" : { }}],"serviceId" : "'+serviceMap.values()[0].id+'","legacyAttributes" : [ ]}');

        insert attachmentRateCardList;


        Test.startTest();
        //User Support Scenario
        BillingUtility controllerManagedService = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');


        List<Id> serviceList = new List<Id>();
        serviceList.addAll(serviceMap.keySet());
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controllerManagedService.getAllServSpecs(serviceList);
        BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();

        controllerManagedService.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000871', serviceList);
        System.assertEquals(true, controllerManagedService.rateCardWrapperObj.comboToLinesWrap.containsKey('Individual Line-Standard'));

        Test.stopTest();
    }
    //EDGE-218386 positive test method ends
	
	@isTest
    private static void populateBillingSpecificationsIOTTest(){
		cspmb__Price_Item__c priceItemObj = [select id from cspmb__Price_Item__c where Offer_Id__c='DMCAT_Offer_001522' limit 1];
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c WHERE Scenario_Type__c = 'IOT Service']);
        list<cscfga__Product_Configuration__c> productconfigList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_001523'];
        list<csord__Subscription__c> subList = [select id from csord__Subscription__c where name='test Subscription for NGUC'];
        List<Attachment> attachmentRateCardList = Orchestration_TestUtility.buildAttachment(false, 1, serviceMap.values(), productconfigList[0].id);
        attachmentRateCardList[0].Body = Blob.valueOf('{"specifications" : [ {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_001523_Fulfilment","productConfigurationId" : "'+productconfigList[0].id+'","name" : "IOT Plan_Fulfilment", "metadata" : { },"instanceId" : "",'+
                '"includeBilling" : false,"guid" : "e3fb6446-8e88-f840-2d13-bcd42d478cdb","endDate" : "","description" : "IOT Plan_Fulfilment","code" : "DMCAT_ProductSpecification_001523_Fulfilment", "attributes" : {"billDescription" : "Feature Usage Charges","externalId" : "DMCAT_Offer_001522_DMCAT_ProductSpecification_001523_DMCAT_Allowance_001536_49","chargeId" : "DMCAT_RecurringCharge_000810","billingSpecId" : "BSUSG005_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM", "taxTreatment" : "GST Applicable","__targetSystem" : "BILLING"},"additionalAttributes" : { }},'+
                '{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_001523_Fulfilment","productConfigurationId" : "'+productconfigList[0].id+'","name" : "Plan_Fulfilment","metadata" : { },"instanceId" : "","includeBilling" : false,"guid" : "3b3e5885-4d1c-90b1-4256-5ff3506425c9","endDate" : "","description" : "Business Calling_Billing_RecurringCharge_000814","code" : "DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes" : {"billDescription" : "Individual line - standard calling plan","externalId" : "DMCAT_Offer_001522_DMCAT_ProductSpecification_001523_DMCAT_Allowance_001536_49","chargeId" : "DMCAT_RecurringCharge_000814","billingSpecId" : "BSUSG003_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM","taxTreatment" : "GST Applicable","__targetSystem" : "BILLING","sharedPlanId" : "'+priceItemObj.id+'"},"additionalAttributes" : { }},'+
                '{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_001523_Fulfilment","productConfigurationId" : "'+productconfigList[0].id+'","name" : "Plan_Fulfilment","metadata" : { },"instanceId" : "","includeBilling" : false,"guid" : "3b3e5885-4d1c-90b1-4256-5ff3506425c9","endDate" : "","description" : "Business Calling_Billing_RecurringCharge_000814","code" : "DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes" : {"billDescription" : "Individual line - standard calling plan","externalId" : "DMCAT_Offer_001522_DMCAT_ProductSpecification_001523_DMCAT_Allowance_001536_49","concurrencyLimitMode" : "Individual Line","callingPlans" : "Standard","chargeId" : "DMCAT_RecurringCharge_000814","billingSpecId" : "BSUSG003_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM","taxTreatment" : "GST Applicable","__targetSystem" : "BILLING"},"additionalAttributes" : { }}],"serviceId" : "'+serviceMap.values()[0].id+'","legacyAttributes" : [ ]}');

        insert attachmentRateCardList;


        Test.startTest();
        //User Support Scenario
        BillingUtility controllerManagedService = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');


        List<Id> serviceList = new List<Id>();
        serviceList.addAll(serviceMap.keySet());
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controllerManagedService.getAllServSpecs(serviceList);
        BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();

        controllerManagedService.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000871', serviceList);
        System.assertEquals(true, controllerManagedService.rateCardWrapperObj.comboToLinesWrap.containsKey('Individual Line-Standard'));

        Test.stopTest();
    }



    //EDGE-218386 added negative test method for custom rate block generation for NGUC product
    @isTest
    private static void populateBillingSpecificationsNGUCNegativeTest(){
        cspmb__Price_Item__c priceItemObj = [select id from cspmb__Price_Item__c where Offer_Id__c='DMCAT_Offer_000618' limit 1];
        priceItemObj.Offer_Id__c = '';
        update priceItemObj;
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c WHERE Scenario_Type__c = 'NGUC Service']);
        list<cscfga__Product_Configuration__c> productconfigList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000871'];
        list<csord__Subscription__c> subList = [select id from csord__Subscription__c where name='test Subscription for NGUC'];
        List<Attachment> attachmentRateCardList = Orchestration_TestUtility.buildAttachment(false, 1, serviceMap.values(), productconfigList[0].id);
        attachmentRateCardList[0].Body = Blob.valueOf('{"specifications" : [ {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId" : "'+productconfigList[0].id+'","name" : "871_RC_810", "metadata" : { },"instanceId" : "",'+
                '"includeBilling" : false,"guid" : "e3fb6446-8e88-f840-2d13-bcd42d478cdb","endDate" : "","description" : "Business Calling_Billing_RecurringCharge_000810","code" : "DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810", "attributes" : {"chargeId" : "DMCAT_RecurringCharge_000810","billingSpecId" : "BSUSG005_CB","type" : "RC","currency" : "AUD","billingSubtype" : "HWM", "taxTreatment" : "GST Applicable","__targetSystem" : "BILLING"},"additionalAttributes" : { }}],"serviceId" : "'+serviceMap.values()[0].id+'","legacyAttributes" : [ ]}');

        insert attachmentRateCardList;


        Test.startTest();
        //User Support Scenario
        BillingUtility controllerManagedService = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');


        List<Id> serviceList = new List<Id>();
        serviceList.addAll(serviceMap.keySet());
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controllerManagedService.getAllServSpecs(serviceList);
        BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();

        controllerManagedService.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000871', serviceList);
        System.assertNotEquals(true, controllerManagedService.rateCardWrapperObj.comboToLinesWrap.containsKey('Individual Line-Standrad'));

        Test.stopTest();
    }
    //EDGE-218386 negative test method ends
}