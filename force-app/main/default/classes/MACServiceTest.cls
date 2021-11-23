@isTest
public class MACServiceTest {
    @Testsetup static void dataSetup(){
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
        
        //20/12/2019 Added by BRAM for SOMOpenAir Professional Service Products: EDGE-127047
        
        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
            
        Marketable_Offer__c momdm = new Marketable_Offer__c();
        momdm.OfferDefinationName__c ='Enterprise Mobility Managed Service' ;
        momdm.Name = 'Test MOdfs';
        momdm.Offer_ID__c = 'D12sd333s';
        momdm.Config__c='{"SOMOpenAir":true,"isSOWrequired":true,"noLineItem":true,"isConsumptionBasedCharge":"true","skipBasketSyncValidations":"true"}';
        listOfOffers.add(momdm);
       
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Professional Services-MDM Config' ;
        moMob.Name = 'Professional Services-MDM Config';
        moMob.Offer_ID__c = 'D12sd337s';
        moMob.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}';
        listOfOffers.add(moMob);
        
        insert listOfOffers;
        
        //End EDGE-127047
        
        //20/12/2019 Added by BRAM for SOMOpenAir Professional Service Products: EDGE-127047
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
        PCNewMdm.ConfigurationType1__c = 'Solution Component';
        productconfiglistEMPS.add(PCNewMdm); 
        
        //End Of EDGE-127047
        
        List<csord__Order__c> ordList = new List<csord__Order__c>();
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.Name = 'test order';
        ord.csord__Status2__c = 'In Progress';
        //insert ord;
        ordList.add(ord);
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification';
        ord1.Name = 'test order1';
        ord1.csord__Status2__c = 'In Progress';
        //insert ord1;
        ordList.add(ord1);
        
        
        csord__Order__c subord1 = new csord__Order__c();
        subord1.csord__Identification__c = 'test identification sub1';
        subord1.Name = 'sub order 1';
        subord1.csord__Primary_Order__c = ord.Id;
        subord1.csord__Status2__c = 'order created';
        //insert subord1;
        ordList.add(subord1);
        
        csord__Order__c subord2 = new csord__Order__c();
        subord2.csord__Identification__c = 'test identification sub2';
        subord2.Name = 'sub order 2';
        subord2.csord__Primary_Order__c = ord.Id;
        subord2.csord__Status2__c = 'order created';
        //insert subord2;
        ordList.add(subord2);
        insert ordList;
        
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;
        //insert subs;
        subsList.add(subs);
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs1';
        subs1.csord__Identification__c = 'test identity1';
        subs1.csord__Status__c = 'NA';
        subs1.csord__Order__c = ord1.id;
        //insert subs;
		 csord__Subscription__c subs2=new csord__Subscription__c();
        subs2.name  = 'test subs2';
        subs2.csord__Identification__c = 'test identity2';
        subs2.csord__Status__c = 'NA';
        subs2.csord__Order__c = ord1.id;
        subsList.add(subs2);
        insert subsList;
        
        /*csord__Subscription__c sub=new csord__Subscription__c();
sub.name  = 'test subs1';
sub.csord__Identification__c = 'test identity1';
sub.csord__Status__c = 'Cancellation In Progress';
sub.csord__Order__c = ord.id;
insert sub;*/
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c prodconfig = new cscfga__Product_Configuration__c();
        prodconfig.Type__c ='Cancel';
        prodConfigList.add(prodconfig);
        
        cscfga__Product_Configuration__c prodconfig1 = new cscfga__Product_Configuration__c();
        prodconfig1.Type__c ='Cancel';
        prodConfigList.add(prodconfig1);
        
        cscfga__Product_Configuration__c prodconfig2 = new cscfga__Product_Configuration__c();
        prodconfig2.Type__c ='Cancel';
        prodConfigList.add(prodconfig2);
        
        cscfga__Product_Configuration__c prodconfig3 = new cscfga__Product_Configuration__c();
        prodconfig3.Type__c ='New';
        prodConfigList.add(prodconfig3);
        
        insert prodConfigList;
        
        csord__Subscription__c replacedsubs = new csord__Subscription__c();
        replacedsubs.name  = 'replaced test subs1';
        replacedsubs.csord__Identification__c = 'test identity';
        replacedsubs.csordtelcoa__Replaced_Subscription__c = subs.Id;
        insert replacedsubs;
        
         //20/12/2019 Added by BRAM for SOMOpenAir Professional Service Products: EDGE-127047
       List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        csord__Subscription__c subEMPS=new csord__Subscription__c();
      
/*        csord__Subscription__c subEMPS=new csord__Subscription__c();
        subEMPS.name  = '12test subEMPS';
        subEMPS.csord__Identification__c = '12test subEMPS';
        subEMPS.csord__Status__c = 'Pending';
       // subList.add(subs1);
        insert subEMPS;
      */
        
        subEMPS.name  = 'test subs';
        subEMPS.MarketableOffer__c=listOfOffers[0].Id;
        subEMPS.csord__Identification__c = 'test identity';
        subEMPS.csord__Status__c = 'Pending';
        subEMPS.Suspension_reason__c='Requested by Customer';
        subEMPS.csord__Order__c = ord.id;
       // subList.add(subs1);
      //subList.add(subs1);
        insert subEMPS;
    //End of change EDGE-127047
    
    
        
        csord__Service__c replacedserv = new csord__Service__c();
        replacedserv.name ='replaced service1';
        replacedserv.csord__Identification__c  = 'test identify2';
        replacedserv.csordtelcoa__Service_Number__c = '5';
        replacedserv.csord__Subscription__c = replacedsubs.Id;
        replacedserv.csord__Status__c = 'In Progress';
        insert replacedserv;
        
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Cancellation In Progress';       
        serv.csordtelcoa__Product_Configuration__c = prodconfig.id;
        serv.csordtelcoa__Replaced_Service__c = replacedserv.id;
        servs.add(serv);       
        
           //20/12/2019 Added by BRAM for SOMOpenAir Professional Service Products: EDGE-127047
      
         csord__Service__c servEMPS = new csord__Service__c();
        servEMPS.name ='tst EMPS';
        servEMPS.csord__Identification__c  = 'test identifysubEMPS';
        servEMPS.csordtelcoa__Service_Number__c = '5';
        servEMPS.csord__Subscription__c = subEMPS.Id;
        servEMPS.csord__Status__c = 'Connected';
        servEMPS.csordtelcoa__Product_Configuration__c = productconfiglistEMPS.get(0).id;
        servs.add(servEMPS);
    //   End of change   EDGE-127047
    
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '4';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Cancellation In Progress';       
        serv1.csordtelcoa__Product_Configuration__c = prodconfig1.id;
        serv1.csordtelcoa__Replaced_Service__c = replacedserv.id;
        servs.add(serv1);      
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '5';
        serv2.csord__Subscription__c = subs.Id;
        serv2.csord__Status__c = 'Cancellation In Progress';       
        serv2.csordtelcoa__Product_Configuration__c = prodconfig2.id;
        serv2.csordtelcoa__Replaced_Service__c = replacedserv.id;
        servs.add(serv2);      
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='tst service3';
        serv3.csord__Identification__c  = 'test identify3';
        serv3.csordtelcoa__Service_Number__c = '1';
        serv3.csord__Subscription__c = subs.Id;
        //serv3.csord__Status__c = 'Cancellation In Progress';       
        serv3.csordtelcoa__Product_Configuration__c = prodconfig3.id;
        serv3.csordtelcoa__Replaced_Service__c = replacedserv.id;
        servs.add(serv3);
    
    // Test Data EDGE-110172
    csord__Service__c serv4 = new csord__Service__c();
        serv4.name ='tst service4';
        serv4.csord__Identification__c  = 'test identify3';
        serv4.csordtelcoa__Service_Number__c = '1';
        serv4.csord__Subscription__c = subs.Id;
        serv4.Payment_Type__c = 'Rental';       
        serv4.csordtelcoa__Product_Configuration__c = prodconfig3.id;
        serv4.csordtelcoa__Replaced_Service__c = replacedserv.id;
        servs.add(serv4);
		
		csord__Service__c serv5 = new csord__Service__c();
        serv5.name ='tst service5';
        serv5.csord__Identification__c  = 'test identify5';
        serv5.csordtelcoa__Service_Number__c = '1';
        serv5.csord__Subscription__c = subs2.Id;
        serv5.csordtelcoa__Product_Configuration__c = prodconfig3.id;
        servs.add(serv5);
                    
                    
        insert servs;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{ "specifications": [ { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000163_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Internet Protection Solution_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "e9acb5c4-1077-5edc-63cc-42dfaab608ec", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000163_Fulfilment", "attributes": { "TotalNumberofUsers": "", "EnterpriseInternetProductInstanceID": "", "CustomerFacingServiceId": "", "InternetProtectionSolutionType": "Web and Mail", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000028_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP VPN_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "d5f9c51b-f91c-fef7-8756-8c2504c57a35", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000028_Fulfilment", "attributes": { "CustomerPreferredName": "", "CustomerFacingServiceId": "", "MulticastEnabled": "FALSE", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000053_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Managed Radius_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000053_Fulfilment", "attributes": { "RADIUSServerType": "Basic Telstra Managed RADIUS", "AuthenticationType": "Username/Password Authentication", "RadiusUsers": "TRUE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000018_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP Wireless_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "5c0633d9-b11a-0043-dd19-d357d6753006", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000018_Fulfilment", "attributes": { "ManagedRadiusProductInstanceID": "DMCAT_ProductSpecification_000053_Fulfilment", "CustomerFacingServiceId": "", "RequiredPoolTypes": "Static", "APNtype": "Shared", "GlobalRoaming": "FALSE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "ManagedRadiusProductInstanceID": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000322_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Firewall_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "74285315-ef60-038f-2095-aad64cc3295d", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000322_Fulfilment", "attributes": { "NetworkServiceId": "", "IPVPNProductInstanceID": "DMCAT_ProductSpecification_000028_Fulfilment", "CustomerFacingServiceId": "", "LicenseSize": "VM-50", "Bandwidth": "100 Mbps", "Latency": "Best Effort", "Number": [ { "schemaId": "8b36e021-8454-f3bf-b99a-3beaa632f494", "attributes": { "FNN": "0882524106", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "LE" } }, { "schemaId": "bf94a542-c4c7-c4e9-af15-6d1541b98f82", "attributes": { "FNN": "0882552705", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "No Entry Line" } }, { "schemaId": "92dc7092-5708-cc05-ee6a-e8f791d183e4", "attributes": { "FNN": "0734090819", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "184093a4-707b-2694-ae49-d62be4ed0a1a", "attributes": { "FNN": "0734090820", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "e130f349-9eb2-f9ad-852a-373fdb206a07", "attributes": { "FNN": "0734090904", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "1e9016c5-6d37-429e-cc9d-ff231a60428d", "attributes": { "FNN": "0734093304", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } } ], "__targetSystem": "FULFILMENT" }, "additionalAttributes": { "IPVPNProductInstanceID": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } } ], "serviceId": "'+serv.Id+'", "legacyAttributes": [] } ');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications" : [ { "additionalAttributes" : { "parentSpec" : "4846af25-e338-20dc-4645-3781e5641b51" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "Zone" : "1", "Quantity" : 3, "UserType" : "Fixed Seat" }, "code" : "DMCAT_ProductSpecification_000074_Fulfilment", "description" : "", "endDate" : "", "guid" : "9fefd2c7-ab9b-d86a-98b3-4b6fa30538e8", "includeBilling" : false, "instanceId" : "", "name" : "User_Fulfilment", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "rateExcludeGST" : 150.00, "quantity" : 3, "type" : "Fixed Seat", "currency" : "AUD", "frequency" : "Monthly", "billingSpecId" : "BSRC001_CB", "billInAdvance" : "true", "prorate" : "false", "billDescription" : "Fixed Seat (Zone 3)" }, "code" : "DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033", "description" : "", "endDate" : "", "guid" : "306bc09c-fa98-0ea0-8637-fa964a7c4307", "includeBilling" : false, "instanceId" : "", "name" : "User_Billing_RecurringCharge_000033", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING" }, "code" : "DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508", "description" : "", "endDate" : "", "guid" : "14b9fcb9-1c3d-4d60-3eb7-67baef691a7d", "instanceId" : "", "name" : "User_Billing_NonRecurringCharge_000508", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING" }, "code" : "DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509", "description" : "", "endDate" : "", "guid" : "f30e8111-93cf-aa5a-d3d4-6be246651134", "instanceId" : "", "name" : "User_Billing_NonRecurringCharge_000509", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509", "startDate" : "", "status" : "Created", "version" : "1" } ], "serviceId": "'+serv1.Id+'", "legacyAttributes": [] } ');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        atts.add(att2);
        
        Attachment att3 = new Attachment();
        att3.Body = Blob.valueOf('{"specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "460aaceb-8903-d235-a0d7-dd08cb19fadf", "SERVICEID" : "61459010139" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "IMSI" : "", "Voice2Text" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61459010139", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "448f77ea-c7a9-3617-54fa-4749774b66a6", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "3c6b2d1c-d354-f3bc-5a0f-e97630a3cb00", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "985f9885-f519-021e-3def-fb69b3e7b86b" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "0523907e-b8d3-ae3a-8287-8f0073a3697c", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "a3ec01bd-d0ea-b575-c5d5-6014b1946b87" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "121ed59d-cd84-fff8-b54a-be5d5dc918d9", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "7df3c0e0-cfb0-fe69-3c2b-cf6be7e9abd0" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "f5f1edb6-7b86-179d-cee7-08a07a8d5a2a", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "269ba693-335b-092e-4c57-42bd31551471" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "Quantity" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "1e7e139d-0f10-984e-620c-87b72f770869", "includeBilling" : false, "instanceId" : "", "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "269ba693-335b-092e-4c57-42bd31551471" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "77ce702a-b3f5-3d53-935a-0a6d847e6e4a", "attributes" : { "FNN" : "1111111111", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "7993a504-5199-6740-bec2-45b2ed95eaec", "attributes" : { "FNN" : "2222222222", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "44d7221d-3085-1d53-05b4-450a40b3e8e8", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "1d957cac-e0de-48fd-6797-9e045cdbf82d", "attributes" : { "FNN" : "8282345567", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "cc5cb00d-918e-186d-a035-c505d2cb9400", "attributes" : { "FNN" : "8282345566", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "d2854e9f-564a-26b7-c397-f651ef22d855", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "9a551aa3-341f-4f98-7f33-3af2465d95f8", "attributes" : { "FNN" : "8282345569", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "246edb9f-4d2f-9993-7b95-5c9260a9ea2a", "attributes" : { "FNN" : "8282345516", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "e797493d-7d91-cba4-c4e2-f7b0bdd28d93", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "7dd52a47-83ff-65ae-4fd4-62bfc2929974", "attributes" : { "FNN" : "8282345536", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "ec790155-a486-6a35-5167-041f3793098c", "attributes" : { "FNN" : "8282345546", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "27bf6bfa-acbc-888b-b2f4-35a64a627b81", "includeBilling" : false, "instanceId" : "", "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000F9ynUAC", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "Complete", "version" : "1" } ] , "serviceId": "'+serv2.Id+'", "legacyAttributes": [] } ');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = serv2.Id;
        atts.add(att3);
        
        Attachment att4 = new Attachment();
        att4.Body = Blob.valueOf('{"specifications" : [ { "additionalAttributes" : { "parentSpec" : "4846af25-e338-20dc-4645-3781e5641b51" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "Zone" : "1", "Quantity" : 3, "UserType" : "Fixed Seat" }, "code" : "DMCAT_ProductSpecification_000074_Fulfilment", "description" : "", "endDate" : "", "guid" : "9fefd2c7-ab9b-d86a-98b3-4b6fa30538e8", "includeBilling" : false, "instanceId" : "", "name" : "User_Fulfilment", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "rateExcludeGST" : 150.00, "quantity" : 3, "type" : "Fixed Seat", "currency" : "AUD", "frequency" : "Monthly", "billingSpecId" : "BSRC001_CB", "billInAdvance" : "true", "prorate" : "false", "billDescription" : "Fixed Seat (Zone 3)" }, "code" : "DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033", "description" : "", "endDate" : "", "guid" : "306bc09c-fa98-0ea0-8637-fa964a7c4307", "includeBilling" : false, "instanceId" : "", "name" : "User_Billing_RecurringCharge_000033", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING" }, "code" : "DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508", "description" : "", "endDate" : "", "guid" : "14b9fcb9-1c3d-4d60-3eb7-67baef691a7d", "instanceId" : "", "name" : "User_Billing_NonRecurringCharge_000508", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING" }, "code" : "DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509", "description" : "", "endDate" : "", "guid" : "f30e8111-93cf-aa5a-d3d4-6be246651134", "instanceId" : "", "name" : "User_Billing_NonRecurringCharge_000509", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509", "startDate" : "", "status" : "Created", "version" : "1" } ], "serviceId": "'+serv3.Id+'", "legacyAttributes": [] } ');
        att4.Name = 'ServiceSpecifications.json';
        att4.ParentId = serv3.Id;
        atts.add(att4);
    
    // Test data EDGE-110172
        Attachment att5 = new Attachment();
        att5.Body = Blob.valueOf('{"specifications" : [ { "additionalAttributes" : { "parentSpec" : "4846af25-e338-20dc-4645-3781e5641b51" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "Zone" : "1", "Quantity" : 3, "UserType" : "Fixed Seat" }, "code" : "DMCAT_ProductSpecification_000622", "description" : "", "endDate" : "", "guid" : "9fefd2c7-ab9b-d86a-98b3-4b6fa30538e8", "includeBilling" : false, "instanceId" : "", "name" : "User_Fulfilment", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000622", "startDate" : "", "status" : "Complete", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "FULFILMENT", "rateExcludeGST" : 150.00, "quantity" : 3, "type" : "Fixed Seat", "currency" : "AUD", "frequency" : "Monthly", "billingSpecId" : "BSRC001_CB", "billInAdvance" : "true", "prorate" : "false", "billDescription" : "Fixed Seat (Zone 3)" }, "code" : "DMCAT_ProductSpecification_000622", "description" : "", "endDate" : "", "guid" : "306bc09c-fa98-0ea0-8637-fa964a7c4307", "includeBilling" : false, "instanceId" : "", "name" : "User_Billing_RecurringCharge_000033", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "FULFILMENT" }, "code" : "DMCAT_ProductSpecification_000622", "description" : "", "endDate" : "", "guid" : "14b9fcb9-1c3d-4d60-3eb7-67baef691a7d", "instanceId" : "", "name" : "User_Billing_NonRecurringCharge_000508", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "FULFILMENT" }, "code" : "DMCAT_ProductSpecification_000622", "description" : "", "endDate" : "", "guid" : "f30e8111-93cf-aa5a-d3d4-6be246651134", "instanceId" : "", "name" : "User_Billing_NonRecurringCharge_000509", "productConfigurationId" : "a3T2O000000FJkGUAW", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509", "startDate" : "", "status" : "Created", "version" : "1" } ], "serviceId": "'+serv3.Id+'", "legacyAttributes": [] } ');
        att5.Name = 'ServiceSpecifications.json';
        att5.ParentId = serv4.Id;
        atts.add(att5);
		
		Attachment att6 = new Attachment();
        att6.Body = Blob.valueOf('{"specifications":[{"additionalAttributes":{"parentSpec":"4846af25-e338-20dc-4645-3781e5641b51"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","Zone":"1","Quantity":3,"UserType":"Fixed Seat"},"code":"DMCAT_ProductSpecification_000074_Fulfilment","description":"","endDate":"","guid":"9fefd2c7-ab9b-d86a-98b3-4b6fa30538e8","includeBilling":false,"instanceId":"","name":"User_Fulfilment","productConfigurationId":"a3T2O000000FJkGUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","rateExcludeGST":150,"quantity":3,"type":"Fixed Seat","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Fixed Seat (Zone 3)"},"code":"DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033","description":"","endDate":"","guid":"306bc09c-fa98-0ea0-8637-fa964a7c4307","includeBilling":false,"instanceId":"","name":"User_Billing_RecurringCharge_000033","productConfigurationId":"a3T2O000000FJkGUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_RecurringCharge_000033","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING"},"code":"DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508","description":"","endDate":"","guid":"14b9fcb9-1c3d-4d60-3eb7-67baef691a7d","instanceId":"","name":"User_Billing_NonRecurringCharge_000508","productConfigurationId":"a3T2O000000FJkGUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000508","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING"},"code":"DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509","description":"","endDate":"","guid":"f30e8111-93cf-aa5a-d3d4-6be246651134","instanceId":"","name":"User_Billing_NonRecurringCharge_000509","productConfigurationId":"a3T2O000000FJkGUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_Billing_NonRecurringCharge_000509","startDate":"","status":"Complete","version":"1"}],"serviceId":"'+serv5.Id+'","legacyAttributes":[]}');
        att6.Name = 'ServiceSpecifications.json';
        att6.ParentId = serv5.Id;
        atts.add(att6);
        
        insert atts;
        
        
        
    }
    
    static testMethod void testupdateServiceStatusFULFILMENT(){
        List<csord__Service__c> servlist = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Service__c WHERE Name =:'tst service'];
        List<Id> servId = new List<Id>();
        for(csord__Service__c srv : servlist){
            servId.add(srv.id);
        }
        Test.startTest();
        MACService.updateServiceStatus(servId);
        Test.stopTest();
        System.assertnotEquals(servlist, null);
        
    }
  // Test Method for EDGE-110172
  static testMethod void testServiceFULFILMENT1(){
        List<csord__Service__c> servlist = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Service__c WHERE Name =:'tst service4'];
        List<Id> servId = new List<Id>();
        for(csord__Service__c srv : servlist){
            servId.add(srv.id);
        }
        Test.startTest();
        MACService.updateServiceStatus(servId);
        Test.stopTest();
        System.assertnotEquals(servlist, null);
        
    }
    
    
    static testMethod void testupdateServiceStatusBILLING(){
        List<csord__Service__c> servlist = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Service__c WHERE Name =:'tst service1'];
        List<Id> servId = new List<Id>();
        for(csord__Service__c srv1 : servlist){
            servId.add(srv1.id);
        }
        Test.startTest();
        MACService.updateServiceStatus(servId);
        Test.stopTest();
        System.assertnotEquals(servlist, null);
        
    }
    
    static testMethod void testupdateServiceStatusASSURANCE(){
        List<csord__Service__c> servlist = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Service__c WHERE Name =:'tst service2'];
        List<Id> servId = new List<Id>();
        for(csord__Service__c srv1 : servlist){
            servId.add(srv1.id);
        }
        Test.startTest();
        MACService.updateServiceStatus(servId);
        Test.stopTest();
        System.assertnotEquals(servlist, null);
        
    }
    
    static testMethod void testupdateServiceStatusServiceNotCancelled(){
        List<csord__Service__c> servlist = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Service__c WHERE Name =:'tst service3'];
        List<Id> servId = new List<Id>();
        for(csord__Service__c srv1 : servlist){
            servId.add(srv1.id);
        }
        Test.startTest();
        MACService.updateServiceStatus(servId);
        Test.stopTest();
        System.assertnotEquals(servlist, null);
        
    }
    
    static testMethod void testupdateServiceStatusMobileAccess(){
        List<csord__Order__c> ordList = [Select id,name from csord__Order__c where name = 'test order']; 
        List<Id> ordIdList = new List<Id>();
        for(csord__Order__c ord :ordList){
            ordIdList.add(ord.id);
        }
        Test.startTest();
        MACService.updateServiceStatusMobileAccess(ordIdList);
        Test.stopTest();
        System.assertNotEquals(ordList, null);
    }
    //Added for EDGE-127047 to check for PS SOMOpenAir Products, this Positive cases, Negitive Case is covered in the above cases
     static testMethod void testupdateServiceStatusMobileAccessPS(){
        List<csord__Order__c> ordList = [Select id,name from csord__Order__c where name = 'test order']; 
                 
        List<Id> ordIdList = new List<Id>();
        for(csord__Order__c ord :ordList){
            ordIdList.add(ord.id);
        }
        Test.startTest();
       	
        MACService.updateServiceStatusMobileAccess(ordIdList);
        Test.stopTest();
        System.assertNotEquals(ordList, null);
       // Get the Status of the Service after the code is executed.
         List<csord__Service__c> servlistaf = [SELECT Id, Name, csord__Status__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c from csord__Service__c WHERE Name =:'tst EMPS'];
         System.assertEquals('Connected',servlistaf[0].csord__Status__c);
    }
    
    // Added as part of EDGE-146358
    static testMethod void testupdateOrderToSkipFullfillmentFalse(){
        List<csord__Order__c> ordList = [Select id, name from csord__Order__c where name = 'test order']; 
        List<Id> ordIdList = new List<Id>();
        for(csord__Order__c ord :ordList){
            ordIdList.add(ord.id);
        }
        Test.startTest();
        MACService.updateOrderToSkipFullfillment(ordIdList);
        Test.stopTest();
        csord__Order__c ord = [Select id,skipFulfillment__c from csord__Order__c where name = 'test order' LIMIT 1];
        System.assertEquals(ord.skipFulfillment__c, false);
    }
    
    // Added as part of EDGE-146358
    static testMethod void testupdateOrderToSkipFullfillmentTrue(){
        List<csord__Order__c> ordList = [Select id,name from csord__Order__c where name = 'test order1']; 
        List<Id> ordIdList = new List<Id>();
        for(csord__Order__c ord :ordList){
            ordIdList.add(ord.id);
        }
        Test.startTest();
        MACService.updateOrderToSkipFullfillment(ordIdList);
        Test.stopTest();
        csord__Order__c ord = [Select id,skipFulfillment__c from csord__Order__c where name = 'test order1' LIMIT 1];
        System.assertEquals(ord.skipFulfillment__c, true);
    }
	
	static testMethod void testupdateServiceStatusMobileAccessNew(){
        List<csord__Order__c> ordList = [Select id,name from csord__Order__c where name = 'test order1']; 
        List<Id> ordIdList = new List<Id>();
        for(csord__Order__c ord :ordList){
            ordIdList.add(ord.id);
        }
        Test.startTest();
        MACService.updateServiceStatusMobileAccess(ordIdList);
        Test.stopTest();
        System.assertNotEquals(ordList, null);
    }
    
    
}