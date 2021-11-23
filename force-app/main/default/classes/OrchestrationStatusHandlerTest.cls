/*

Class : OrchestrationStatusHandlerTest

Sr.No.    Developer Name      Date          Story Description
  1.        Shreya jaiswal          13/12/19        EDGE-125031
  2.        Purushottama Sahu       26/05/20        EDGE-146794
  3.       Pawan                   02/07/2020      EDGE-156046  
*/
@isTest
public class OrchestrationStatusHandlerTest {
    @Testsetup static void dataSetup(){
        
        
        List<BDS_Notify_Settings__c> bdsNotifySettings = new List<BDS_Notify_Settings__c>();
        bdsNotifySettings.add(createCustomSettings('Feature Level', 'FeatureLevelShadow', false));
        bdsNotifySettings.add(createCustomSettings('Platform Management', 'Platform Management', false));
        bdsNotifySettings.add(createCustomSettings('Technical Support', 'TechnicalSupportShadow', true));
        insert bdsNotifySettings;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.Name = 'test order';  
        ord.csord__Status2__c = 'Active';
        insert ord;
      
        Billing_Account__c ban = new Billing_Account__c();
        ban.Billing_Account_Number__c = '700000000000';
        ban.Status__c = 'Created';
        insert ban;
        //20/11/2019 Added by BRAM for  isConsumptionBasedCharge for "Enterprise Mobility Managed Service"
        
        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
            
        Marketable_Offer__c momdm = new Marketable_Offer__c();
        momdm.OfferDefinationName__c ='Enterprise Mobility Managed Service' ;
        momdm.Name = 'Test MOdfs';
        momdm.Offer_ID__c = 'D12sd333s';
        momdm.Config__c='{"SOMOpenAir":true,"isSOWrequired":true,"noLineItem":true,"isConsumptionBasedCharge":"true","skipBasketSyncValidations":"true"}';
       // listOfOffers.add(momdm);
     
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Professional Services-MDM Config' ;
        moMob.Name = 'Professional Services-MDM Config';
        moMob.Offer_ID__c = 'D12sd337s';
        moMob.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}';
        listOfOffers.add(moMob);
        
        insert listOfOffers;
    
        //  csordtelcoa__Product_Configuration__c 
        
        cscfga__Configuration_Offer__c offername1= new cscfga__Configuration_Offer__c();
        offername1.name='Enterprise Mobility Managed Service';
        offername1.cscfga__Active__c=true;
        offername1.cscfga__Description__c='Enterprise Mobility Managed Service';
        insert offername1;
        
       list<cscfga__Product_Configuration__c> productconfiglistEMPS= new list<cscfga__Product_Configuration__c>();
         cscfga__Product_Configuration__c PCNewMdm = new cscfga__Product_Configuration__c();
        PCNewMdm.name='Enterprise Mobility Managed Service';
        PCNewMdm.Type__c='New';
        PCNewMdm.cscfga__originating_offer__c=offername1.id;
       //PCNewMdm.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCNewMdm.Marketable_Offer__c = momdm.id;
        //PCNewMdm.ConfigurationType1__c = 'Solution Component';  // EDGE-146794 >>-
        PCNewMdm.ConfigurationType1__c = 'SolutionComponent';    // EDGE-146794 >>+
        productconfiglistEMPS.add(PCNewMdm); 

        //EDGE-125031
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c ();
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000871';
        prodDef.cscfga__Description__c ='NgVoice Transition';
        insert prodDef;
        cscfga__Product_Configuration__c PCNguc = new cscfga__Product_Configuration__c();
        PCNguc.name='NGVoice';
        PCNguc.Type__c='New';
        PCNguc.cscfga__Product_Definition__c = prodDef.id;
        productconfiglistEMPS.add(PCNguc);
    insert productconfiglistEMPS; 
        
        //End of create Data for "Enterprise Mobility Managed Service"
        
        List<csord__Order__c> listOfOrders = new List<csord__Order__c>();
        csord__Order__c subord1 = new csord__Order__c();
        subord1.csord__Identification__c = 'test identification sub1';
        subord1.Name = 'sub order 1';
        subord1.csord__Primary_Order__c = ord.Id;
        subord1.csord__Status2__c = 'order created';
        listOfOrders.add(subord1);
        
        csord__Order__c subord2 = new csord__Order__c();
        subord2.csord__Identification__c = 'test identification sub2';
        subord2.Name = 'sub order 2';
        subord2.csord__Primary_Order__c = ord.Id;
        subord2.csord__Status2__c = 'order created';
        listOfOrders.add(subord2);
        insert listOfOrders;
        
        
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.Offer_ID__c = 'offerId';
        marketableOffer.Name = 'offerName';
        insert marketableOffer;
        
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.Suspension_reason__c='Requested by Customer';
        subs.csord__Order__c = ord.id;
        subs.Billing_Account__c =  ban.id;
        subs.MarketableOffer__c = marketableOffer.Id;
        subs.MarketableOffer__r = marketableOffer;
        subList.add(subs);
        
        csord__Subscription__c subs12=new csord__Subscription__c();
        subs12.name  = '12test subs12';
        subs12.csord__Identification__c = '12test identity12';
        subs12.csord__Status__c = 'Pending';
        subs12.csord__Order__c = ord.id;
        subs12.Billing_Account__c =  ban.id;
        subList.add(subs12);
        //Added By Purushottam EDGE-146794 - Start
        csord__Subscription__c subEMPSAssociation=new csord__Subscription__c();
        subEMPSAssociation.name  = '12test subEMPSAssociation';
        subEMPSAssociation.csord__Identification__c = '12test subEMPSAssociation';
        subEMPSAssociation.csord__Status__c = 'Pending';
        subEMPSAssociation.csordtelcoa__Product_Configuration__c=productconfiglistEMPS.get(0).id;
        subList.add(subEMPSAssociation);
        
        csord__Subscription__c subEMPSLegacy=new csord__Subscription__c();
        subEMPSLegacy.name  = '12test subEMPSLegacy1';
        subEMPSLegacy.csord__Identification__c = '12test subEMPSLegacy1';
        subEMPSLegacy.csordtelcoa__Product_Configuration__c =productconfiglistEMPS.get(0).id;
        subEMPSLegacy.csord__Status__c = 'Pending';  
        subList.add(subEMPSLegacy);
        
        csord__Subscription__c subEMPSLegacy2=new csord__Subscription__c();
        subEMPSLegacy2.name  = '12test subEMPSLegacy2';
        subEMPSLegacy2.csord__Identification__c = '12test subEMPSLegacy2';
        subEMPSLegacy2.csordtelcoa__Product_Configuration__c =productconfiglistEMPS.get(0).id;
        subEMPSLegacy2.csord__Status__c = 'Pending';  
        subList.add(subEMPSLegacy2);
        //Added By Purushottam EDGE-146794 - End
        
        //20/11/2019 Added by BRAM for  isConsumptionBasedCharge for "Enterprise Mobility Managed Service"
      
        csord__Subscription__c subEMPS=new csord__Subscription__c();
        subEMPS.name  = '12test subEMPS';
        subEMPS.csord__Identification__c = '12test subEMPS';
        subEMPS.csord__Status__c = 'Pending';
        subEMPS.cssdm__solution_association__c=subEMPSAssociation.id; //Added by Purushottam EDGE-146794
        subs12.Billing_Account__c =  ban.id;
        subList.add(subEMPS);
        //End of change
        //EDGE-125031
        csord__Subscription__c subNGUC=new csord__Subscription__c();
        subNGUC.name  = 'testNgUc Transition';
        subNGUC.csordtelcoa__Product_Configuration__c = PCNguc.id;
        subNGUC.csord__Identification__c = 'test subNGUC';
        subNGUC.csord__Status__c = 'Pending';
        subList.add(subNGUC);
        
    csord__Subscription__c legacySub=new csord__Subscription__c();
        legacySub.name  = 'testNgUc Transition legacy';
        legacySub.csordtelcoa__Product_Configuration__c = PCNguc.id;
        legacySub.csord__Identification__c = 'test legacySub';
        legacySub.csord__Status__c = 'Pending';
        legacySub.legacy_subscription__c = subNGUC.id;
        subList.add(legacySub);
        
        csord__Subscription__c legacySub2=new csord__Subscription__c();
        legacySub2.name  = 'testNgUc Transition legacy 2';
        legacySub2.csordtelcoa__Product_Configuration__c = PCNguc.id;
        legacySub2.csord__Identification__c = 'test legacySub2';
        legacySub2.csord__Status__c = 'Pending';
        legacySub2.legacy_subscription__c = subNGUC.id;
        legacySub2.Billing_Account__c =  ban.id;
        subList.add(legacySub2);
        insert subList;
        
        /*csord__Subscription__c sub=new csord__Subscription__c();
sub.name  = 'test subs1';
sub.csord__Identification__c = 'test identity1';
sub.csord__Status__c = 'Cancellation In Progress';
sub.csord__Order__c = ord.id;
insert sub;*/
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '5';
        serv2.csord__Subscription__c = subs.Id;
        serv2.csord__Status__c = 'In Progress';
        servs.add(serv2);
       //EDGE-125031
         csord__Service__c servNgUc = new csord__Service__c();
        servNgUc.name ='test transition';
        servNgUc.csord__Identification__c  = 'test identify6';
        servNgUc.csordtelcoa__Service_Number__c = '6';
        servNgUc.csord__Subscription__c = subNGUC.Id;
        servNgUc.csord__Status__c = 'In Progress';
        servs.add(servNgUc);
        
        
        
           //20/11/2019 Added by BRAM for  isConsumptionBasedCharge for "Enterprise Mobility Managed Service"
      
         csord__Service__c servEMPS = new csord__Service__c();
        servEMPS.name ='tst EMPS';
        servEMPS.csord__Identification__c  = 'test identifysubEMPS';
        servEMPS.csordtelcoa__Service_Number__c = '5';
        servEMPS.csord__Subscription__c = subEMPS.Id;
        servEMPS.csord__Status__c = 'In Progress';
        servEMPS.Action_Type__c = 'PaidOut';    //EDGE-156046
        servEMPS.csordtelcoa__Product_Configuration__c = productconfiglistEMPS.get(0).id;
        servs.add(servEMPS);
    //   End of change     

        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '4';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Failed';
        
        servs.add(serv1);
        
        csord__Service__c serv12 = new csord__Service__c();
        serv12.name ='12tst service12';
        serv12.csord__Identification__c  = 'test identify1';
        serv12.csordtelcoa__Service_Number__c = '4';
        serv12.csord__Subscription__c = subs12.Id;
        serv12.csord__Status__c = 'Failed';
        
        servs.add(serv12);
        
        cscfga__Product_Configuration__c prodconfig = new cscfga__Product_Configuration__c();
        prodconfig.Type__c ='Cancel';
        insert prodconfig;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Cancellation In Progress';
        serv.Action_Type__c = 'PaidOut';    //EDGE-156046
        
        serv.csordtelcoa__Product_Configuration__c = prodconfig.id;
        servs.add(serv);       
        insert servs;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{ "specifications": [ { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000163_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Internet Protection Solution_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "e9acb5c4-1077-5edc-63cc-42dfaab608ec", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000163_Fulfilment", "attributes": { "TotalNumberofUsers": "", "EnterpriseInternetProductInstanceID": "", "CustomerFacingServiceId": "", "InternetProtectionSolutionType": "Web and Mail", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000028_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP VPN_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "d5f9c51b-f91c-fef7-8756-8c2504c57a35", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000028_Fulfilment", "attributes": { "CustomerPreferredName": "", "CustomerFacingServiceId": "", "MulticastEnabled": "FALSE", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000053_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Managed Radius_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000053_Fulfilment", "attributes": { "RADIUSServerType": "Basic Telstra Managed RADIUS", "AuthenticationType": "Username/Password Authentication", "RadiusUsers": "TRUE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000018_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP Wireless_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "5c0633d9-b11a-0043-dd19-d357d6753006", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000018_Fulfilment", "attributes": { "ManagedRadiusProductInstanceID": "DMCAT_ProductSpecification_000053_Fulfilment", "CustomerFacingServiceId": "", "RequiredPoolTypes": "Static", "APNtype": "Shared", "GlobalRoaming": "FALSE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "ManagedRadiusProductInstanceID": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000322_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Firewall_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "74285315-ef60-038f-2095-aad64cc3295d", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000322_Fulfilment", "attributes": { "NetworkServiceId": "", "IPVPNProductInstanceID": "DMCAT_ProductSpecification_000028_Fulfilment", "CustomerFacingServiceId": "", "LicenseSize": "VM-50", "Bandwidth": "100 Mbps", "Latency": "Best Effort", "Number": [ { "schemaId": "8b36e021-8454-f3bf-b99a-3beaa632f494", "attributes": { "FNN": "0882524106", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "LE" } }, { "schemaId": "bf94a542-c4c7-c4e9-af15-6d1541b98f82", "attributes": { "FNN": "0882552705", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "No Entry Line" } }, { "schemaId": "92dc7092-5708-cc05-ee6a-e8f791d183e4", "attributes": { "FNN": "0734090819", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "184093a4-707b-2694-ae49-d62be4ed0a1a", "attributes": { "FNN": "0734090820", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "e130f349-9eb2-f9ad-852a-373fdb206a07", "attributes": { "FNN": "0734090904", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "1e9016c5-6d37-429e-cc9d-ff231a60428d", "attributes": { "FNN": "0734093304", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } } ], "__targetSystem": "FULFILMENT" }, "additionalAttributes": { "IPVPNProductInstanceID": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } } ], "serviceId": "'+serv.Id+'", "legacyAttributes": [] } ');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
        
        csord__Subscription__c replacedsubs = new csord__Subscription__c();
        replacedsubs.name  = 'replaced test subs1';
        replacedsubs.csord__Status__c = 'In Progress';
        replacedsubs.csord__Identification__c = 'test identity';
        replacedsubs.csordtelcoa__Replaced_Subscription__c = subs.Id;
        insert replacedsubs;
        
        
        csord__Service__c replacedserv = new csord__Service__c();
        replacedserv.name ='replaced service1';
        replacedserv.csord__Identification__c  = 'test identify2';
        replacedserv.csordtelcoa__Service_Number__c = '5';
        replacedserv.csord__Subscription__c = replacedsubs.Id;
        replacedserv.csord__Status__c = 'In Progress';
        insert replacedserv;
        
    }
    
    
    
    private static BDS_Notify_Settings__c createCustomSettings(String name, String value, boolean isSI5Offer) {
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = name;
        bds.Value__c = value;
        bds.Is_SI5_Offer__c = isSI5Offer;
        return bds;
        
    }
    
   static testMethod void subscriptionProcessTest() {
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Subscription__c> subs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE Name='test subs'];
        parentOrchProcess.csordtelcoa__Subscription__c = subs[0].Id;
        
        //update parentOrchProcess;
        
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        Test.startTest();
        OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertEquals(value.CSPOFA__Status__c,'Complete');
        
        Test.stopTest();
    }
    
    static testMethod void subscriptionOrchProcessTest() {
        //dataSetup();
        
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
        subsSettings.csordtelcoa__Service_Initial_State__c = 'Service created';
        insert subsSettings;
        Excluded_Spec_Attributes__mdt excludeattr = new Excluded_Spec_Attributes__mdt();
        excludeattr.MasterLabel = 'CPEDeliveryDate';
        excludeattr.Exclusion_Type__c = 'DeltaCheck';
        excludeattr.DeveloperName = 'deltaCPEDeliveryDate';
        excludeattr.Exclusion_Name__c = 'deltaCPEDeliveryDate';
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Subscription__c> subs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,Trigger_RTS__c,Is_Bill_Stopped__c   from csord__Subscription__c WHERE Name='test subs'];
        parentOrchProcess.csordtelcoa__Subscription__c = subs[0].Id;
        
        update parentOrchProcess;
        
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        Test.startTest();
        OrchestrationStatusHandler.OrchestrationOrderDeltaHandler  orderClass = new OrchestrationStatusHandler.OrchestrationOrderDeltaHandler ();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertNotEquals(value.CSPOFA__Status__c,null);
        
        Test.stopTest();
    }
    
    @isTest static void UpdateOrderStatus() {
        List<csord__Subscription__c> sub = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE csord__Identification__c LIKE 'test identity%'];
        sub[0].csord__Status__c = 'Active';
        sub[1].csord__Status__c = 'Inactive';
        update sub;
        OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
        String orderStatus = orderClass.getOrderStatus(sub);
        System.assertEquals('Completed', orderStatus);
    }
    
    @isTest static void UpdateOrderStatusCancellation() {
        List<csord__Subscription__c> sub = [SELECT Id, Name, csord__Status__c,Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE csord__Identification__c LIKE 'test identity%'];
        sub[0].csord__Status__c = 'Cancellation In Progress';
        sub[1].csord__Status__c = 'Cancellation In Progress';
        update sub;
        OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
        String orderStatus = orderClass.getOrderStatus(sub);
        System.assertEquals('Cancellation In Progress', orderStatus);
    }
    
    @isTest static void UpdateOrderStatusFailed() {
        List<csord__Subscription__c> sub = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE csord__Identification__c LIKE 'test identity%'];
        sub[0].csord__Status__c = 'Failed';
        sub[1].csord__Status__c = 'Failed';
        update sub;
        OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
        String orderStatus = orderClass.getOrderStatus(sub);
        System.assertEquals('Failed', orderStatus);
    }
    
    
    @isTest static void UpdateOrderStatusCancelled() {
        List<csord__Subscription__c> sub = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE csord__Identification__c LIKE 'test identity%'];
        sub[0].csord__Status__c = 'Cancelled';
        sub[1].csord__Status__c = 'Cancelled';
        update sub;
        OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
        String orderStatus = orderClass.getOrderStatus(sub);
        System.assertEquals('Cancelled', orderStatus);
    }
    
    
    @isTest static void UpdateOrderStatusCancelledFailed() {
        List<csord__Subscription__c> sub = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE csord__Identification__c LIKE 'test identity%'];
        sub[0].csord__Status__c = 'Cancelled';
        sub[1].csord__Status__c = 'Failed';
        update sub;
        OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
        String orderStatus = orderClass.getOrderStatus(sub);
        System.assertEquals('In Progress', orderStatus);
    }
    
    @isTest static void testcalculateSubscriptionStatus() {
        Test.startTest();
        List<csord__Service__c> servs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c, csord__Order__r.name from csord__Service__c WHERE Name LIKE 'tst service%'];
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(servs,servs[0].csord__Subscription__r.toBeCancelled__c,servs[0].csord__Subscription__r.Is_Bill_Stopped__c);
        System.assertEquals('Provisioning In Progress', statusMap.get('status'));
        Test.stopTest();
    }
    
    @isTest static void testUpdateSubscriptionStatusActive() {
        Test.startTest();
        List<csord__Service__c> servs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c from csord__Service__c WHERE Name LIKE 'tst service%'];
        servs[0].csord__Status__c = 'Connected';
        servs[1].csord__Status__c = 'Disconnected';
        servs[2].csord__Status__c = 'Cancelled';
        update servs;
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(servs,servs[0].csord__Subscription__r.toBeCancelled__c,servs[0].csord__Subscription__r.Is_Bill_Stopped__c);
        System.assertEquals('Active', statusMap.get('status'));
        Test.stopTest();
    }
    
    
    @isTest static void testUpdateSubscriptionStatusFailed() {
        Test.startTest();
        List<csord__Service__c> servs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c  from csord__Service__c WHERE Name LIKE 'tst service%'];
        servs[0].csord__Status__c = 'Failed';
        servs[1].csord__Status__c = 'Failed';
        servs[2].csord__Status__c = 'Failed';
        update servs;
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(servs,servs[0].csord__Subscription__r.toBeCancelled__c,servs[0].csord__Subscription__r.Is_Bill_Stopped__c);
        Test.stopTest();
        System.assertEquals('Failed', statusMap.get('status'));
    }
    
    
    @isTest static void testUpdateSubscriptionStatusInactive() {
        Test.startTest();
        List<csord__Service__c> servs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c from csord__Service__c WHERE Name LIKE 'tst service%'];
        servs[0].csord__Status__c = 'Cancelled';
        servs[1].csord__Status__c = 'Disconnected';
        servs[2].csord__Status__c = 'Cancelled';
        update servs;
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(servs,servs[0].csord__Subscription__r.toBeCancelled__c,servs[0].csord__Subscription__r.Is_Bill_Stopped__c);
        Test.stopTest();
        System.assertEquals('Provisioning In Progress', statusMap.get('status'));
    }
    
    @isTest static void testUpdateSubscriptionStatusCancelled() {
        Test.startTest();
        List<csord__Service__c> servs = [SELECT Id, Name, csord__Status__c,Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c from csord__Service__c WHERE Name LIKE 'tst service%'];
        servs[0].csord__Status__c = 'Cancelled';
        servs[1].csord__Status__c = 'Cancelled';
        servs[2].csord__Status__c = 'Cancelled';
        update servs;
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(servs,servs[0].csord__Subscription__r.toBeCancelled__c,servs[0].csord__Subscription__r.Is_Bill_Stopped__c);
        Test.stopTest();
        System.assertEquals('Cancelled', statusMap.get('status'));
    }
    
    @isTest static void testUpdateSubscriptionStatusCancellation() {
        Test.startTest();
        List<csord__Service__c> serv = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c from csord__Service__c WHERE Name LIKE 'tst service%'];
        serv[0].csord__Status__c = 'Cancellation In Progress';
        serv[1].csord__Status__c = 'Cancellation In Progress';
        serv[2].csord__Status__c = 'Cancellation In Progress';
        update serv;
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(serv,serv[0].csord__Subscription__r.toBeCancelled__c,serv[0].csord__Subscription__r.Is_Bill_Stopped__c);
        Test.stopTest();
        System.assertEquals('Cancellation In Progress', statusMap.get('status'));
    }
    //EDGE-125031
    @isTest static void testUpdateSubscriptionStatustransition() {
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Service__c> serv = [SELECT Id, Name, csord__Status__c from csord__Service__c WHERE Name='test transition'];
        parentOrchProcess.csordtelcoa__Service__c = serv[0].Id;
        update parentOrchProcess;
        
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        Test.startTest();
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orchClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        List<SObject> result = orchClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        Test.stopTest();
        System.assertNotEquals(null,value.CSPOFA__Status__c);
        
    }
    
    
    @isTest static void testUpdateSubscriptionStatusReplaced() {
        Test.startTest();
        List<csord__Service__c> servs = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Subscription__r.toBeCancelled__c,csord__Subscription__r.Is_Bill_Stopped__c from csord__Service__c WHERE Name LIKE 'replaced service%'];
        servs[0].csord__Status__c = 'Connected';
        update servs;
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        Map<String,String> statusMap = orderClass.getSubscriptionStatus(servs,servs[0].csord__Subscription__r.toBeCancelled__c,servs[0].csord__Subscription__r.Is_Bill_Stopped__c);
        Test.stopTest();
        System.assertEquals('Active', statusMap.get('status'));
    }
    
    static testMethod void testserviceProcess() {
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c from csord__Service__c WHERE Name='tst service1'];
        parentOrchProcess.csordtelcoa__Service__c = subs[0].Id;
        update parentOrchProcess;
        
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        Test.startTest();
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertEquals(value.CSPOFA__Status__c,'Complete');
        
        Test.stopTest();
    }
    
    static testMethod void testOrderSubOrderProcess() {
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Order__c> ords = [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE Name='test order'];
        parentOrchProcess.Order__c = ords[0].Id;
        update parentOrchProcess;
        
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        Test.startTest();
        OrchestrationStatusHandler.UpdateSubOrderStatus orderClass = new OrchestrationStatusHandler.UpdateSubOrderStatus();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertNotEquals(null,value.CSPOFA__Status__c);
        
        Test.stopTest();
    }
    
    static testMethod void testupdateorderStatustt() {
  List<csord__Subscription__c> sub = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Subscription__c WHERE Name='test subs'];
  List<Id> subId=new List<Id>();
    for(csord__Subscription__c subs:sub)
    {
       
        subId.add(subs.Id);
    }
  
  Test.startTest();
    OrchestrationStatusHandler.EvaluateOrderStatus orderClass = new OrchestrationStatusHandler.EvaluateOrderStatus();
  orderClass.updateOrderStatus(subId);
    orderClass.getDeliveryDate(sub,'Forecasted Delivery Date');   
     System.assertEquals('test subs',sub[0].Name);
  Test.stopTest();
  
  }
    
     static testMethod void testserviceProcess12() {
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c from csord__Service__c WHERE Name='12tst service12'];
        parentOrchProcess.csordtelcoa__Service__c = subs[0].Id;
        update parentOrchProcess;
        
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        Test.startTest();
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertEquals(value.CSPOFA__Status__c,'Complete');
        
        Test.stopTest();
    }
    
    // BRAM 20/11/2019 New Method for Enterprise Modility Product billing test
    static testMethod void testserviceProcess14() {
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c,csord__Subscription__c from csord__Service__c WHERE Name='tst EMPS'];
        parentOrchProcess.csordtelcoa__Service__c = subs[0].Id;
        update parentOrchProcess;
        //Added by Purushottam EDGE-146794 - Start
        List<csord__Subscription__c> updateSubList= new List<csord__Subscription__c>();
        for(csord__Subscription__c legacySub : [SELECT Id, Name, csord__Status__c,legacy_subscription__c from csord__Subscription__c WHERE Name IN ('12test subEMPSLegacy1','12test subEMPSLegacy2')])
            {
            legacySub.legacy_subscription__c=subs[0].csord__Subscription__c;
            updateSubList.add(legacySub);
            }
        update updateSubList;
        //Added by Purushottam EDGE-146794 - End
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        Test.startTest();
        OrchestrationStatusHandler.EvaluateSubscriptionStatus orderClass = new OrchestrationStatusHandler.EvaluateSubscriptionStatus();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertEquals(value.CSPOFA__Status__c,'Complete');
        
        Test.stopTest();
    }
    
    @isTest static void getSubOrderstoUpdateTest() {
         List<csord__Order__c> ords = [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE Name='test order'];
       
        OrchestrationStatusHandler.UpdateSubOrderStatus orderClass = new OrchestrationStatusHandler.UpdateSubOrderStatus();
        orderClass.getSubOrderstoUpdate('In Progress',ords);
        System.assertNotEquals(null, ords);
    }
    
    //EDGE-156046
    @isTest static void updateSvcSubsStatusOnPaidOutTestWithSingleService() {
         Map<Id, csord__Service__c> mapServIdService = new Map<Id, csord__Service__c>([Select id,name,Action_Type__c, csord__Status__c, csord__Subscription__r.id, csord__Subscription__r.csord__Status__c,csordtelcoa__Service_Number__c,csord__Order__c,csord__Order__r.csord__Order_Number__c from csord__Service__c where name = 'tst EMPS']);

         Test.startTest();
         OrchestrationStatusHandler.OrchestrationOrderDeltaHandler  orchDeltahndlr = new OrchestrationStatusHandler.OrchestrationOrderDeltaHandler ();
         orchDeltahndlr.updateSvcSubsStatusOnPaidOut(mapServIdService);
         Test.stopTest();
         csord__Service__c svcActual = [Select id,name,csordtelcoa__Service_Number__c,csord__Subscription__r.csord__Status__c,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Status__c from csord__Service__c where name = 'tst EMPS'];
         
        System.assertEquals(svcActual.csord__Status__c, 'Paid Out');
        System.assertEquals(svcActual.csord__Subscription__r.csord__Status__c, 'Paid Out');
    }

    //EDGE-156046
    @isTest static void updateSvcSubsStatusOnPaidOutTestWithMultipleService() {
         Map<Id, csord__Service__c> mapServIdService = new Map<Id, csord__Service__c>([Select id,name,Action_Type__c, csord__Status__c, csord__Subscription__r.id, csord__Subscription__r.csord__Status__c,csordtelcoa__Service_Number__c,csord__Order__c,csord__Order__r.csord__Order_Number__c from csord__Service__c where name = 'tst service']);

         Test.startTest();
         OrchestrationStatusHandler.OrchestrationOrderDeltaHandler  orchDeltahndlr = new OrchestrationStatusHandler.OrchestrationOrderDeltaHandler ();
         orchDeltahndlr.updateSvcSubsStatusOnPaidOut(mapServIdService);
         Test.stopTest();
         csord__Service__c svcActual = [Select id,name,csordtelcoa__Service_Number__c,csord__Subscription__r.csord__Status__c,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Status__c from csord__Service__c where name = 'tst service'];
         
        System.assertEquals(svcActual.csord__Status__c, 'Paid Out');
        System.assertEquals(svcActual.csord__Subscription__r.csord__Status__c, 'Pending');  
    }   
    
}