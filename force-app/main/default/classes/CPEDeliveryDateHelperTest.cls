/*
===============================================================================================================================
Class : CPEDeliveryDateHelperTest
Developer Name : Kunal Dixit
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Kunal Dixit         17/04,2019    EDGE-77677 Urgent fix to close B2B4 SIT : CPE delivery date value is not reflecting in the payload for PRM order
2.        Vaibhav             23/12/2019    EDGE-127367 DML and SOQL inside FOR loop
===============================================================================================================================
*/

@isTest(SeeAllData=false)
public class CPEDeliveryDateHelperTest
{
@Testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'testAccount' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = acc;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'CancelOrderTest';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        
        
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.Type__c = 'Cancel'; 
        insert testConfig1;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        
        
        csord__Order__c priOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        priOrd.csordtelcoa__Opportunity__c = testOpp.Id;
        priOrd.csord__Order_Request__c = ordReq.Id;        
        insert priOrd;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csordtelcoa__Opportunity__c = testOpp.Id;
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Primary_Order__c = priOrd.Id;
        insert ord; 
        
        
        
        
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subList.add(subs);

        insert subList;
        //**EDGE-127367- Start
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=subs.id,
                                    StartDate__c=System.today(),EndDate__c=System.today());
        insert appt; //EDGE-127367 - inserted appointment record in data setup method
        //**EDGE-127367- End
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='testService_1';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Created';
        serv.substage__c = 'Product Activation and Testing';
        serv.stage__c = 'Being Fulfilled';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        servs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService_2';
        serv1.csord__Identification__c  = 'testIdentify_2';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Created';
        serv.substage__c = 'Product Requirements Validation';
        serv.stage__c = 'Received';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
       
        insert servs;
     
        List<Service_Specification__c> servSpecList = new List<Service_Specification__c>();
        Service_Specification__c servSpec = new Service_Specification__c();
        servSpec.Name = 'Mobile Access_Fulfilment';
        servSpec.Service__c = serv.id;
        servSpec.Code__c ='DMCAT_ProductSpecification_000263';
        servSpec.GUID__c = 'dabc3fdb-332e-c8ee-e853-24f41182c4d7';
        servSpecList.add(servSpec);
        
        Service_Specification__c servSpec1 = new Service_Specification__c();
        servSpec1.Name = 'UC Site_Fulfilment';
        servSpec1.Service__c = serv.id;
        servSpec1.Code__c ='DMCAT_ProductSpecification_000322';
        servSpec1.GUID__c = 'e4b35ea7-c933-80cc-f3a1-4969969dbf8b';
        servSpecList.add(servSpec1);
        
        insert servSpecList;
        
        subStageNotification__c subStageNotif = new subStageNotification__c();
        subStageNotif.Name = 'Logical Deactivation';
        subStageNotif.Service_Specification__c= servSpec.id;
        subStageNotif.Substage_Completion_Date__c=System.Date.today();
        insert subStageNotif;
        
        List<Attachment> atts = new List<Attachment>();
        
        Attachment att2 = new Attachment();
        //att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000008D0IUAU","name":"Unified Communication Enterprise_Fulfilment","instanceId":"","guid":"cf0159c5-997f-f39b-5233-dbedc2cecdbf","endDate":"","description":"","code":"DMCAT_ProductSpecification_000087_Fulfilment","attributes":{"DomainName":"","OverviewofProposedSolution":"","CustomerPreferredName":"","CustomerFacingServiceId":"","ModuleGroupType":"","EnterpriseExtensionDialling":"TRUE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv1.Id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","type":"OC","currency":"AUD","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","unitofMeasure":"each","CPE Delivery date":"","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","ocsProdID":"T22E_IR_USAGE"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"","endDate":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","includeBilling":false,"instanceId":"","metadata":{},"CPE Delivery date":"","name":"Mobile Access_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"SuspensionContext":"CUSTOMER"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"","endDate":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","includeBilling":false,"instanceId":"","metadata":{},"CPE Delivery date":"","name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000JESeUAO","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","CPE Delivery date":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","CPE Delivery date":"","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER","IMSI":"","ShippingRequired":"FALSE","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","CONTEXT":"CUSTOMER","CPE Delivery date":"","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"CPE Delivery date":"","guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"CPE Delivery date":"","description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        atts.add(att2);
        
        
        Attachment att4 = new Attachment();
        //att4.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "a4e2O0000004sO6QAI", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61474821599", "IPWirelessProductInstanceID" : "9051ae65-fe01-f77c-ab34-bf926c97288a" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "413d96f7-d8b1-84fe-9681-17f4b3b0518a", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "5b5b91d6-8afe-304b-bec8-e64b94408777", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "2de07d13-9ad0-b127-9381-06bff58e4caa" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "0fe39634-5caf-9786-5804-95623e065e39", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "74701806-0b7f-afa1-d088-7cf4012ed6dc" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "4" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "a657ffa6-5872-e96e-1c2d-93f53f2b4708", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "5b5b91d6-8afe-304b-bec8-e64b94408777" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "2 Hours", "RestoreTarget" : "12 Hours" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "098e8726-4356-4475-df5b-daaa829510fc", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "0fe39634-5caf-9786-5804-95623e065e39" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "Quantity" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c4dacc21-073c-057c-39e8-86f7f5cac50a", "includeBilling" : false, "instanceId" : "", "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "0fe39634-5caf-9786-5804-95623e065e39" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "25e92124-d637-4b90-4b1d-e5602d51c955", "attributes" : { "FNN" : "1111111111", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "298c8f72-ac0d-8352-bc4d-c16580ee9e5b", "attributes" : { "FNN" : "2222222222", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "59980903-98db-85f6-7412-295b72f2c7d2", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "12657f70-e296-8bf1-a28f-5429d9557c29", "attributes" : { "FNN" : "8282345567", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "405c8734-e4f1-27bb-080d-418df5c11b84", "attributes" : { "FNN" : "8282345566", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "de85e26d-cf15-2218-eea5-9737788de49c", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "c9999e2f-4fce-5f19-4163-9164a0608e9a", "attributes" : { "FNN" : "8282345569", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "fb2a51cc-a339-04ad-d79c-cb65fd47b50c", "attributes" : { "FNN" : "8282345516", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "59227f11-f3c5-66cc-0c63-014f99a1dcfd", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "2c524a20-853e-3964-7726-7b0bd54bc83b", "attributes" : { "FNN" : "8282345536", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "d9da20fc-288d-6f33-faa5-9d62a63e8555", "attributes" : { "FNN" : "8282345546", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "cadee771-3fdc-28fa-2df6-ef5608e8c916", "includeBilling" : false, "instanceId" : "", "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "In Progress", "version" : "1" } ] }');
        att4.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","type":"OC","currency":"AUD","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","unitofMeasure":"each","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","ocsProdID":"T22E_IR_USAGE"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"","endDate":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"SuspensionContext":"CUSTOMER"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"","endDate":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000JESeUAO","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER","IMSI":"","ShippingRequired":"FALSE","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}]}');
        att4.Name = 'ServiceSpecifications.json';
        att4.ParentId = serv.Id;
        atts.add(att4);
        
        insert atts;
        
    }
    
    @isTest
    static void testProcessNotificationRec(){
        List<csord__Subscription__c> subList= [SELECT id FROM csord__Subscription__c];
        // Modified by Aman Soni as part of Tech Debt story || EDGE-127667
         CPEDeliveryDateHelper.modifyCPEDeliveryDate(subList);  
        for(csord__Subscription__c subs:subList){
            
          CPEDeliveryDateHelper.modifyCPEDeliveryDate(subs.id);  
          CPEDeliveryDateHelper.AddBusinessDays(Date.Today(), 5);
        }
        
        System.assertEquals(1,subList.size()); 
    }
}