/*
===============================================================================================================================
Class : EDMMACServiceTest
Developer Name :
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
  1.      Vaibhav Deshpande    30/04/20      EDGE-144539 : Upgrade Delta Handler Logic to check Non Commercial Attributes of Generated Spec
===============================================================================================================================
*/

@isTest
private class EDMMACServiceTest {
    
    @testsetup
    public static void testDataSetup(){
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.CIDN__c = 'CIDN1234';
        insert acc;
        
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.Phone = '04499993456';
        insert contact;
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        insert site;
        
        /*
Functional_Contact_Role__c siteRole = new Functional_Contact_Role__c();
siteRole.Role_Type__c = 'Site';
siteRole.Role__c = 'Technical Contact';
siteRole.ContactID__c = contact.Id;
siteRole.SiteID__c = site.Id;
insert siteRole;
*/
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'old test identification';
        ord1.csord__Account__c = acc.id;
        ord1.csord__Order_Type__c = 'test order';   
        insert ord1;
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord1.Id;
        subs1.Site__c = site.Id;
        insert subs1;
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name = 'Replaced config';
        replacedConfig.csordtelcoa__Replaced_Product_Configuration__c = rootConfig.id;
        insert replacedConfig;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='old tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs1.id;
        serv.csord__Order__c = ord1.id;
        serv.csord__Status__c = 'Service created';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csordtelcoa__Product_Configuration__c = rootConfig.id;
        insert serv;
        List<Attachment> att = new List<Attachment>();
        Attachment att1 = new Attachment();
        //att1.Body = Blob.valueOf('{"removed":[],'+ '"oldServiceId":"oldServiceId_XXX",'+ '"newServiceId":"newServiceId_YYY",'+ '"changed":[{"instanceId":"","guid":"91573e8a-1952-d9c4-83da-9c6f940c3351","changedNonCommercialAttributes":[],"changedAttributes":["Bandwidth","Appointment_EndDateTime","Appointment_StartDateTime","Appointment_ID"]},'+ '{"instanceId":"","guid":"0dc3082a-a09b-7969-386e-a079cd315c5d","changedNonCommercialAttributes":[],"changedAttributes":["UCEnterpriseProductInstanceID","PrimaryAccessProductInstanceID"]},'+ '{"instanceId":"","guid":"6be16f33-edf3-380b-2e9a-5aed4286b7ac","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"17159a2f-fade-ecb1-219c-1b862f059889","changedNonCommercialAttributes":[{'+ '"removedNonCommercialProductConfigurations":["a3T2O0000003ZntUAE"],"name":"Voice Numbers","changedNonCommercialProductConfigurations":[],"addedNonCommercialProductConfigurations":[]}],'+ '"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"08c370d7-75c6-6728-2eca-8ef69553ee6b","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]}],"added":[]}');
        //att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Completed","startDate":"2018-03-13","name":"IP Network","guid":"a4a8e497-6a4b-a284-6c60-2aee8ae67851","attributes":{"PrimaryFNN":"00315045","ServiceType":"ISDN-BRA","TIPTGroupProductInstance ID":""},"additionalAttributes" : {"CPEDeliveryDate":"2018-08-23T05:05:05+11:00"}},{"version":"1","status":"Completed","startDate":"2018-03-13","name":"IP Network","guid":"a4a8e497-6a4b-a284-6c60-2aee8ae12345","attributes":{"PrimaryFNN":"0031501","ServiceType":"ISDN-BRA","TIPTGroupProductInstance ID":""}}]}');
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.id+'","specifications":[{"additionalAttributes":{"IPWirelessProductInstanceID":"f7be2ddf-42b9-9991-49a9-854635dfed2b","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"2019-02-05T08:00:00","SERVICEID":"61474831854"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","ShippingRequired":"TRUE","IMSI":"","Voice2Text":"","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"","DMCAT_ProductSpecification_000263_CPEDeliveryDate":""},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"37e10cfe-29ec-f974-372d-5c8793594df5","includeBilling":false,"instanceId":"","name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption ":"1"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"","endDate":"","guid":"9dde57c9-19cc-db87-2562-f8246ef7e11a","includeBilling":false,"instanceId":"","name":"Telstra Managed Service Option 1_Assurance","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"BSServiceTypeProductInstanceID":"6b3c2441-cfb4-7820-fffb-f188fa5bb1e5","DMCAT_ProductSpecification_000322_CPEDeliveryDate":"2019-02-05T08:00:00"},"attributes":{"BSServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000312_Fulfilment","__targetSystem":"FULFILMENT","CustomerFacingServiceId":"","CustomerPreferredName":"","DMCAT_ProductSpecification_000322_CPEDeliveryDate":""},"code":"DMCAT_ProductSpecification_000322_Fulfilment","description":"","endDate":"","guid":"fdfdbe73-e107-7308-2f46-c2e6705ed88d","includeBilling":false,"instanceId":"","name":"UC Site_Fulfilment","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"InternetProtectionSolutionProductInstanceID":"2f4ac4e3-5cf0-1cf2-293c-111c9c03f3b1"},"attributes":{"__targetSystem":"FULFILMENT","UserProtectionType":"Web and Mail","InternetProtectionSolutionProductInstanceID":"DMCAT_ProductSpecification_000163_Fulfilment","Quantity":"3"},"code":"DMCAT_ProductSpecification_000162_Fulfilment","description":"","endDate":"","guid":"f0433f72-6552-9824-2780-2f94f9b40438","includeBilling":false,"instanceId":"","name":"Web and Mail Internet Protection User_Fulfilment","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"parentSpec":"9dde57c9-19cc-db87-2562-f8246ef7e11a"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010002"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"","endDate":"","guid":"e4c4e3f6-11ad-6aad-1bb6-45bf4dfad87c","includeBilling":false,"instanceId":"","name":"Incident Management_Assurance","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"fdfdbe73-e107-7308-2f46-c2e6705ed88d"},"attributes":{"__targetSystem":"FULFILMENT","name":"Hosted UC","CustomerFacingServiceId":"","id":"","Quantity":"","parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment"},"code":"DMCAT_ProductSpecification_000315_Fulfilment","description":"","endDate":"","guid":"1025365c-2ab1-af5d-87bb-e2ffb4c07b4a","includeBilling":false,"instanceId":"","name":"Feature Packs_Fulfilment","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"parentSpec":"fdfdbe73-e107-7308-2f46-c2e6705ed88d"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"412c3714-2137-126e-31b6-3dbea99efc03","attributes":{"FNN":"1111111111","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"6323f795-83f1-a646-e0e1-29c4892b6ebe","attributes":{"FNN":"2222222222","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"1c3c678c-eca8-e5f5-106c-ef0f9e7bda42","attributes":{"FNN":"3333333333","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"ca4cdae1-6489-319a-26a5-66e7c7237bd8","attributes":{"FNN":"8282345567","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"ebecb282-bc81-abe4-f01e-cbe4390a9619","attributes":{"FNN":"8282345566","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"fc78c2db-f1ee-d2b0-315f-6460941822e8","attributes":{"FNN":"8282345568","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"43bafa61-872c-c838-626b-4f7794676621","attributes":{"FNN":"8282345569","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"b67d9cb3-b3d6-99e0-8573-a8ad1c6d54a4","attributes":{"FNN":"8282345516","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"2ca9c472-b5c4-d20a-c352-eefc896ac5fa","attributes":{"FNN":"8282345526","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"52273078-448a-e5e2-d0bd-1c1bffa63992","attributes":{"FNN":"8282345536","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"eb236578-3a39-daa7-5eca-57c255d6deac","attributes":{"FNN":"8282345546","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"","endDate":"","guid":"12942d2f-3a7d-836d-30cd-cd0eadf0fc88","includeBilling":false,"instanceId":"","name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000FBb3UAG","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"Complete","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        att.add(att1);
        
        Attachment att11 = new Attachment();
        //att1.Body = Blob.valueOf('{"removed":[],'+ '"oldServiceId":"oldServiceId_XXX",'+ '"newServiceId":"newServiceId_YYY",'+ '"changed":[{"instanceId":"","guid":"91573e8a-1952-d9c4-83da-9c6f940c3351","changedNonCommercialAttributes":[],"changedAttributes":["Bandwidth","Appointment_EndDateTime","Appointment_StartDateTime","Appointment_ID"]},'+ '{"instanceId":"","guid":"0dc3082a-a09b-7969-386e-a079cd315c5d","changedNonCommercialAttributes":[],"changedAttributes":["UCEnterpriseProductInstanceID","PrimaryAccessProductInstanceID"]},'+ '{"instanceId":"","guid":"6be16f33-edf3-380b-2e9a-5aed4286b7ac","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"17159a2f-fade-ecb1-219c-1b862f059889","changedNonCommercialAttributes":[{'+ '"removedNonCommercialProductConfigurations":["a3T2O0000003ZntUAE"],"name":"Voice Numbers","changedNonCommercialProductConfigurations":[],"addedNonCommercialProductConfigurations":[]}],'+ '"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"08c370d7-75c6-6728-2eca-8ef69553ee6b","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]}],"added":[]}');
        att11.Body = Blob.valueOf('{"configurations":[{"guid":"412c3714-2137-126e-31b6-3dbea99efc03","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"1111111111"},{"guid":"6323f795-83f1-a646-e0e1-29c4892b6ebe","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"2222222222"},{"guid":"1c3c678c-eca8-e5f5-106c-ef0f9e7bda42","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"3333333333"},{"guid":"ca4cdae1-6489-319a-26a5-66e7c7237bd8","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345567"},{"guid":"ebecb282-bc81-abe4-f01e-cbe4390a9619","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345566"},{"guid":"fc78c2db-f1ee-d2b0-315f-6460941822e8","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345568"},{"guid":"43bafa61-872c-c838-626b-4f7794676621","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345569"},{"guid":"b67d9cb3-b3d6-99e0-8573-a8ad1c6d54a4","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345516"},{"guid":"2ca9c472-b5c4-d20a-c352-eefc896ac5fa","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345526"},{"guid":"52273078-448a-e5e2-d0bd-1c1bffa63992","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345536"},{"guid":"eb236578-3a39-daa7-5eca-57c255d6deac","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345546"}],"schema":{"name":"NumberManagementv1","id":"a792O00000000DEQAY","attributes":[{"type":"String","showInUI":true,"required":false,"name":"FNN"},{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}]}}');
        att11.Name = 'NumberManagementv1_Schema.json';
        att11.ParentId = rootConfig.id;
        att.add(att11);
        
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order';  
        ord.name  ='testing ord';
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Site__c = site.Id;
        insert subs;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csord__Status__c = 'Service created';
        serv1.csord__Subscription__c  = subs.id;
        serv1.csord__Order__c = ord.id;
        serv1.csordtelcoa__Replaced_Service__c = serv.Id;
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csordtelcoa__Product_Configuration__c = replacedConfig.id;
        insert serv1;
        Attachment att2 = new Attachment();
        //att2.Body = Blob.valueOf('{"removed":[],'+ '"oldServiceId":"oldServiceId_XXX",'+ '"newServiceId":"newServiceId_YYY",'+ '"changed":[{"instanceId":"","guid":"91573e8a-1952-d9c4-83da-9c6f940c3351","changedNonCommercialAttributes":[],"changedAttributes":["Bandwidth","Appointment_EndDateTime","Appointment_StartDateTime","Appointment_ID"]},'+ '{"instanceId":"","guid":"0dc3082a-a09b-7969-386e-a079cd315c5d","changedNonCommercialAttributes":[],"changedAttributes":["UCEnterpriseProductInstanceID","PrimaryAccessProductInstanceID"]},'+ '{"instanceId":"","guid":"6ba16f33-edf3-380b-2e9a-5aed4286b7ac","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"17159a2f-fade-ecb1-219c-1b862f059889","changedNonCommercialAttributes":[{'+ '"removedNonCommercialProductConfigurations":["a3T2O0000003ZntUAE"],"name":"Voice Numbers","changedNonCommercialProductConfigurations":[],"addedNonCommercialProductConfigurations":[]}],'+ '"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"08c370d7-75c6-6728-2eca-8ef69553ee6b","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]}],"added":[]}');
        //att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Service created","startDate":"2018-03-13","name":"IP Network","guid":"a4a8e497-6a4b-a284-6c60-2aee8ae67851","attributes":{"PrimaryFNN":"00315045","ServiceType":"ISDN-BRA","TIPTGroupProductInstance ID":"","AuxillaryFNN":"0435453","Number" : [ {"schemaId" : "b089351a-2c05-6bbd-a40f-61f02f65e678","attributes" : {"status" : "ACTIVE","rangeTo" : null,"rangeFrom" : null,"listCode" : "LE","FNN" : "8282345561"}}, {"schemaId" : "c4345f44-27d0-8f84-2276-964cdd9c491e","attributes" : {"status" : "ACTIVE","rangeTo" : null,"rangeFrom" : null,"listCode" : "No Entry Line","FNN" : "8282345562"}}]}},{"version":"1","status":"Service created","startDate":"2018-03-13","name":"IP Network","guid":"a4a8e497-6a4b-a284-6c60-2aee8ae12345","attributes":{"PrimaryFNN":"0031520","ServiceType":"ISDN-BRA","TIPTGroupProductInstance ID":""}}]}');
        att2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv1.id+'","specifications":[{"additionalAttributes":{"IPWirelessProductInstanceID":"f7be2ddf-42b9-9991-49a9-854635dfed2b","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"2019-02-12T08:00:00","SERVICEID":"61474831854"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","ShippingRequired":"TRUE","IMSI":"","Voice2Text":"","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61474831854","DMCAT_ProductSpecification_000263_CPEDeliveryDate":""},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"37e10cfe-29ec-f974-372d-5c8793594df5","includeBilling":false,"instanceId":"","name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption ":"1"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"","endDate":"","guid":"9dde57c9-19cc-db87-2562-f8246ef7e11a","includeBilling":false,"instanceId":"","name":"Telstra Managed Service Option 1_Assurance","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"BSServiceTypeProductInstanceID":"6b3c2441-cfb4-7820-fffb-f188fa5bb1e5","DMCAT_ProductSpecification_000322_CPEDeliveryDate":"2019-02-12T08:00:00"},"attributes":{"BSServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000312_Fulfilment","__targetSystem":"FULFILMENT","CustomerFacingServiceId":"","CustomerPreferredName":"","DMCAT_ProductSpecification_000322_CPEDeliveryDate":""},"code":"DMCAT_ProductSpecification_000322_Fulfilment","description":"","endDate":"","guid":"fdfdbe73-e107-7308-2f46-c2e6705ed88d","includeBilling":false,"instanceId":"","name":"UC Site_Fulfilment","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"InternetProtectionSolutionProductInstanceID":"2f4ac4e3-5cf0-1cf2-293c-111c9c03f3b1"},"attributes":{"__targetSystem":"FULFILMENT","UserProtectionType":"Web and Mail","InternetProtectionSolutionProductInstanceID":"DMCAT_ProductSpecification_000163_Fulfilment","Quantity":"4"},"code":"DMCAT_ProductSpecification_000162_Fulfilment","description":"","endDate":"","guid":"f0433f72-6552-9824-2780-2f94f9b40438","includeBilling":false,"instanceId":"","name":"Web and Mail Internet Protection User_Fulfilment","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"parentSpec":"9dde57c9-19cc-db87-2562-f8246ef7e11a"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"","RestoreTarget":""},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"","endDate":"","guid":"e4c4e3f6-11ad-6aad-1bb6-45bf4dfad87c","includeBilling":false,"instanceId":"","name":"Incident Management_Assurance","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"fdfdbe73-e107-7308-2f46-c2e6705ed88d"},"attributes":{"__targetSystem":"FULFILMENT","name":"Hosted UC","CustomerFacingServiceId":"","id":"","Quantity":"","parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment"},"code":"DMCAT_ProductSpecification_000315_Fulfilment","description":"","endDate":"","guid":"1025365c-2ab1-af5d-87bb-e2ffb4c07b4a","includeBilling":false,"instanceId":"","name":"Feature Packs_Fulfilment","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"parentSpec":"fdfdbe73-e107-7308-2f46-c2e6705ed88d"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"412c3714-2137-126e-31b6-3dbea99efc04","attributes":{"FNN":"1111111111","rangeFrom":null,"rangeTo":null,"status":"Replaced","listCode":"No Entry Line"}},{"schemaId":"412c3714-2137-126e-31b6-3dbea99efc04","attributes":{"FNN":"1111111152","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"6323f795-83f1-a646-e0e1-29c4892b6ebe","attributes":{"FNN":"2222222222","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"1c3c678c-eca8-e5f5-106c-ef0f9e7bda42","attributes":{"FNN":"3333333333","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"ca4cdae1-6489-319a-26a5-66e7c7237bd8","attributes":{"FNN":"8282345567","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"ebecb282-bc81-abe4-f01e-cbe4390a9619","attributes":{"FNN":"8282345566","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"fc78c2db-f1ee-d2b0-315f-6460941822e8","attributes":{"FNN":"8282345568","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"43bafa61-872c-c838-626b-4f7794676621","attributes":{"FNN":"8282345569","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"b67d9cb3-b3d6-99e0-8573-a8ad1c6d54a4","attributes":{"FNN":"8282345516","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"2ca9c472-b5c4-d20a-c352-eefc896ac5fa","attributes":{"FNN":"8282345526","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"52273078-448a-e5e2-d0bd-1c1bffa63992","attributes":{"FNN":"8282345536","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"eb236578-3a39-daa7-5eca-57c255d6deac","attributes":{"FNN":"8282345546","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"No Entry Line"}},{"schemaId":"bd3d9ef1-79ed-975d-4116-d4a3812f241a","attributes":{"FNN":"1111111111","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"dd6850b4-7ea7-f792-ceb2-2031035a7652","attributes":{"FNN":"2222222222","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"00c5e606-6157-7e20-c1ca-c12c954654b7","attributes":{"FNN":"3333333333","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"87da6b19-57e3-27b4-9406-f0cf38fef8c9","attributes":{"FNN":"8282345567","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"9d05dba6-1468-2db6-1fe7-53203f842088","attributes":{"FNN":"8282345566","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"4da75390-5449-896c-5265-1045118225aa","attributes":{"FNN":"8282345568","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"0dce42ce-62e5-e6f3-a919-6cde1b20fd0d","attributes":{"FNN":"8282345569","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"bd91ff44-06a7-1194-3ff2-701f24683801","attributes":{"FNN":"8282345516","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"79ff78af-21c1-32db-5cad-523c0c18f8f2","attributes":{"FNN":"8282345526","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"a550ae1a-bea7-3370-dca3-11d4ab439960","attributes":{"FNN":"8282345536","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"4ce5f690-e6a3-9dcc-628d-8cd3638d2313","attributes":{"FNN":"5689554574","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"","endDate":"","guid":"12942d2f-3a7d-836d-30cd-cd0eadf0fc88","includeBilling":false,"instanceId":"","name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000FBe2UAG","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"Complete","version":"1"}]}');
                                 att2.Name = 'ServiceSpecifications.json';
                                 att2.ParentId = serv1.Id;
                                 att.add(att2);
                                 
                                 Attachment att22 = new Attachment();
                                 //att1.Body = Blob.valueOf('{"removed":[],'+ '"oldServiceId":"oldServiceId_XXX",'+ '"newServiceId":"newServiceId_YYY",'+ '"changed":[{"instanceId":"","guid":"91573e8a-1952-d9c4-83da-9c6f940c3351","changedNonCommercialAttributes":[],"changedAttributes":["Bandwidth","Appointment_EndDateTime","Appointment_StartDateTime","Appointment_ID"]},'+ '{"instanceId":"","guid":"0dc3082a-a09b-7969-386e-a079cd315c5d","changedNonCommercialAttributes":[],"changedAttributes":["UCEnterpriseProductInstanceID","PrimaryAccessProductInstanceID"]},'+ '{"instanceId":"","guid":"6be16f33-edf3-380b-2e9a-5aed4286b7ac","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"17159a2f-fade-ecb1-219c-1b862f059889","changedNonCommercialAttributes":[{'+ '"removedNonCommercialProductConfigurations":["a3T2O0000003ZntUAE"],"name":"Voice Numbers","changedNonCommercialProductConfigurations":[],"addedNonCommercialProductConfigurations":[]}],'+ '"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"08c370d7-75c6-6728-2eca-8ef69553ee6b","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]}],"added":[]}');
                                 att22.Body = Blob.valueOf('{"configurations":[{"guid":"412c3714-2137-126e-31b6-3dbea99efc03","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"1111111111"},{"guid":"6323f795-83f1-a646-e0e1-29c4892b6ebe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"2222222222"},{"guid":"1c3c678c-eca8-e5f5-106c-ef0f9e7bda42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"3333333333"},{"guid":"ca4cdae1-6489-319a-26a5-66e7c7237bd8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345567"},{"guid":"ebecb282-bc81-abe4-f01e-cbe4390a9619","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345566"},{"guid":"fc78c2db-f1ee-d2b0-315f-6460941822e8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345568"},{"guid":"43bafa61-872c-c838-626b-4f7794676621","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345569"},{"guid":"b67d9cb3-b3d6-99e0-8573-a8ad1c6d54a4","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345516"},{"guid":"2ca9c472-b5c4-d20a-c352-eefc896ac5fa","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345526"},{"guid":"52273078-448a-e5e2-d0bd-1c1bffa63992","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345536"},{"guid":"eb236578-3a39-daa7-5eca-57c255d6deac","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345546"},{"guid":"bd3d9ef1-79ed-975d-4116-d4a3812f241a","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"1111111111"},{"guid":"dd6850b4-7ea7-f792-ceb2-2031035a7652","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"2222222222"},{"guid":"00c5e606-6157-7e20-c1ca-c12c954654b7","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"3333333333"},{"guid":"87da6b19-57e3-27b4-9406-f0cf38fef8c9","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345567"},{"guid":"9d05dba6-1468-2db6-1fe7-53203f842088","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345566"},{"guid":"4da75390-5449-896c-5265-1045118225aa","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345568"},{"guid":"0dce42ce-62e5-e6f3-a919-6cde1b20fd0d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345569"},{"guid":"bd91ff44-06a7-1194-3ff2-701f24683801","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345516"},{"guid":"79ff78af-21c1-32db-5cad-523c0c18f8f2","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345526"},{"guid":"a550ae1a-bea7-3370-dca3-11d4ab439960","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345536"},{"guid":"4ce5f690-e6a3-9dcc-628d-8cd3638d2313","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345546"}],"schema":{"name":"NumberManagementv1","id":"a792O00000000DEQAY","attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}]}}');
                                 att22.Name = 'NumberManagementv1_Schema.json';
                                 att22.ParentId = replacedConfig.id;
                                 att.add(att22);
                                 
                                 insert att;
                                 
                                 csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
                                 subsSettings.csordtelcoa__Service_Initial_State__c = 'Service created';
                                 insert subsSettings;
                                 Excluded_Spec_Attributes__mdt excludeattr = new Excluded_Spec_Attributes__mdt();
                                 excludeattr.MasterLabel = 'IPWirelessProductInstanceID';
                                 excludeattr.Exclusion_Type__c = 'DeltaCheck';
                                 excludeattr.DeveloperName = 'IPWirelessProductInstanceID';
                                 excludeattr.Exclusion_Name__c = 'IPWirelessProductInstanceID';                        
                                 //insert excludeattr;
                                 }
                                 
                                 @isTest static void testEDMMACUpdateStatus() {
                                     // Implement test code
                                     List<csord__Order__c> orders = [SELECT Id, Name, csord__Identification__c from csord__Order__c where name ='testing ord'];
                                     List<Id> orderIds = new List<Id>();
                                     for(csord__Order__c ord: orders){
                                         orderIds.add(ord.Id);
                                     }
                                     
                                     //System.debug('llServices[0]:::'+allServices[0].Id);
                                     //System.debug('llServices[0]:::'+csedm.API_1.getServiceSpecificationsById(allServices[0].Id));
                                     //System.debug('allServices::'+allServices);
                                     
                                     Test.startTest();
                                     EDMMACService.updateStatus(orderIds);
                                     Test.stopTest();
                                     List<csord__Service__c> allServices = [SELECT Id, Name, csord__Order__c, csordtelcoa__Replaced_Service__c from csord__Service__c WHERE name ='tst service1'];
                                     csord__Service__c serv = allServices[0];
                                     system.debug('serviceID tested in test method testEDMMACUpdateStatus ' + serv.id );
                                     String status = '';
                                     List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
                                     for(CS_SpecificationDTO.ServiceSpecification spec : srvspecList){
                                         if(spec.guid.contains('12942d2f-3a7d-836d-30cd-cd0eadf0fc88')){
                                             status = spec.status;
                                         }
                                     }
                                     system.assertNotEquals( null,allServices);
                                     //List<csord__Service__c> svcs = [SELECT Id, csord__Order__c, csord__Status__c from csord__Service__c where csord__Order__c IN: orderIds];
                                     //List<CS_SpecificationDTO.ServiceSpecification> cfsAttrList = new List<CS_SpecificationDTO.ServiceSpecification>();
                                     //String servSpecs = csedm.API_1.getServiceSpecificationsById(svcs[0].Id);
                                     
                                 }
                                 
                                 @isTest static void testgetAllModifySpecs() {
                                     csord__Service__c service1 = [SELECT id,name,csord__Order__c,csordtelcoa__Replaced_Service__c from csord__Service__c where name = 'tst service1'];         
                                     //EDMMACServiceUtils.serviceSpecDelta testSpecDelta = new EDMMACServiceUtils.serviceSpecDelta();
                                     EDMMACServiceUtilsV2.serviceSpecDelta testSpecDelta = new EDMMACServiceUtilsV2.serviceSpecDelta();
                                     String testJsondelta =   csedm.API_1.createServiceSpecificationsDelta(service1.Id, service1.csordtelcoa__Replaced_Service__c);
                                     Test.startTest();
                                     //testSpecDelta= EDMMACServiceUtils.parse(testJsondelta);
                                     testSpecDelta= EDMMACServiceUtilsV2.parse(testJsondelta);
                                     List<String> addedGUIDList = new List<String>{'7e10cfe-29ec-f974-372d-5c8793594df5'};
                                         //EDMMACService.getAllModifySpecs(service1.Id,testSpecDelta.added,service1.csordtelcoa__Replaced_Service__c);
                                         List<EDMMACService.specList> specsList = EDMMACService.getAllModifySpecs(service1.Id,addedGUIDList,service1.csordtelcoa__Replaced_Service__c);
                                     Test.stopTest();
                                     system.debug('serviceID tested in test method testEDMMACUpdateStatus ' + service1.Id );
                                     String status = '';
                                     for(EDMMACService.specList spec : specsList){
                                         status = spec.status;
                                     }
                                     List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(service1.Id),'FULFILMENT');
                                     for(CS_SpecificationDTO.ServiceSpecification spec : srvspecList){
                                         if(spec.guid.contains('7e10cfe-29ec-f974-372d-5c8793594df5')){
                                             //status = spec.status;
                                         }
                                     }
                                     system.assertEquals(Label.Service_Spec_MAC_Initial_Status, status);
                                     
                                     //System.debug('testSpecDelta.added===>'+testSpecDelta.added);
                                 }
                                 
                                 @isTest static void testupdateStatusMobileAccess() {    
                                     List<csord__Order__c> ordList = [Select id,name from csord__Order__c where name = 'test order']; 
                                     List<Id> ordIdList = new List<Id>();
                                     for(csord__Order__c ord :ordList){
                                         ordIdList.add(ord.id);
                                     }
                                     Test.startTest();
                                     EDMMACService.updateStatusMobileAccess(ordIdList);
                                     Test.stopTest();
                                     System.assertNotEquals(ordList, null);     
                                 }
    
                           @isTest static void testNonCommercial() {  
                                     Test.startTest();
                                     csord__Service__c service1 = [SELECT id,name,csord__Order__c,csordtelcoa__Replaced_Service__c from csord__Service__c where name = 'tst service1'];         
                                     EDMMACServiceUtilsV2.serviceSpecDelta testSpecDelta = new EDMMACServiceUtilsV2.serviceSpecDelta();
                                     String testJsondelta =   csedm.API_1.createServiceSpecificationsDelta(service1.Id, service1.csordtelcoa__Replaced_Service__c);
                                     testSpecDelta= EDMMACServiceUtilsV2.parse(testJsondelta);  
                                     List<EDMMACServiceUtilsV2.NonCommercialAttr> changedNonComercialAttList = new List<EDMMACServiceUtilsV2.NonCommercialAttr>();
                                    List<EDMMACServiceUtilsV2.deltaDTO> specs=testSpecDelta.changed;
                               		for(EDMMACServiceUtilsV2.deltaDTO spc: specs){
                                      changedNonComercialAttList=spc.changedNonCommercialAttributes;
                                    }
                                    List<csord__Order__c> ordList = [Select id,name from csord__Order__c where name = 'testing ord']; 
                                     List<Id> ordIdList = new List<Id>();
                                     for(csord__Order__c ord :ordList){
                                         ordIdList.add(ord.id);
                                     }
                                    
                                     EDMMACService.updateStatus(ordIdList);
                                     Test.stopTest();
                                     System.assertNotEquals(changedNonComercialAttList, null);     
                                 }
                                 }