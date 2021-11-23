@isTest
public class TARManagerV2Test {
    
    @isTest
    public static void fetchStartDateForSiteAPV2Test(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        csord__Service__c serv = ProductTestFactory.buildService('TestOrder', ord.id, sub.id, ordReq.id);
        insert serv;
        
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022_Fulfilment';
        insert spec1;
        csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033_Fulfilment';
        insert spec2;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        insert met1;
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec2.id;
        met2.Appointment_Required__c = true;
        met2.Installation_Lead_Time__c = 22;
        insert met2;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        String s1 = '{ "legacyAttributes" : [ ],"serviceId" : "a4e2O00000034lYQAQ","specifications" : [ {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : {"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT","MaintainerOnSite" : "Telstra","HardwareReplacementProvider" : "CISCO","MaintenanceCoverageHours" : "8x5xNBD","VendorSupportOnSite" : "","BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8"},';
        String s2 = '"code" : "PS_0022_Fulfilment","description" : "","endDate" : "",    "guid" : "9e77d4b1-55fb-3aeb-611c-9aee05202a2c","instanceId" : "","name" : "Maintenance_Fulfilment","productConfigurationId" : "a3T2O0000006ZWQUA2","specification" : "7e667b64-485d-4b20-a715-93bd1770c123","startDate" : "",    "status" : "Created","version" : "1"}, {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : ';
        String s3 = '{"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT",      "ManagementServiceHours" : "24x7",      "ManagementType" : "Proactive"    },    "code" : "PS_000077_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "bb7aff54-ba1e-2986-ed4b-4748bb0d2c90",    "instanceId" : "",    "name" : "Device Management_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "eea28b0a-b41c-4b56-919a-679923e96d10",    "startDate" : "",';
        String s4 = '"status" : "Created",    "version" : "1"  }, {    "additionalAttributes" : {      "RouterProductInstanceID" : "7d3a247b-6388-3adb-b70b-abccac488513"    },    "attributes" : {      "__targetSystem" : "FULFILMENT",      "ShippingRequired" : "TRUE",      "Country" : "Australia",      "CustomerFacingServiceId" : "",      "CustomerPreferredName" : "",      "RouterProductInstanceID" : "PS_000073_Fulfilment",      "SwitchModel" : "MS120-8 FP",      "Size" : "Small",';
        String s5 = '"EquipmentOwnershipCode" : "Customer Owned Telstra Provided",      "BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8",      "Vendor" : "CISCO",      "PS_000092_CPEDeliveryDate" : ""    },    "code" : "PS_000092_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "42b28dad-b151-3803-5988-5168d7ff92a3",    "instanceId" : "",    "name" : "Managed Switch_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689",    "startDate" : "",    "status" : "Created",    "version" : "1"  },';
        String s6 = '{    "additionalAttributes" : { },    "attributes" : {      "__targetSystem" : "BILLING",      "units" : "1",      "unitPrice" : 60.00,      "type" : "RC",      "currency" : "AUD",      "frequency" : "Monthly",      "billingSpecId" : "BSRC001_CB",      "billInAdvance" : "true",      "prorate" : "false",      "description" : "CISCO (MS120-8FP) Bundle 36 Month",      "SwitchModel" : "MS120-8 FP"    },    "code" : "PS_000092_Billing",    "description" : "",    "endDate" : "",    "guid" : "86bef2a8-cd97-3398-b1d9-4ae694084889",    "instanceId" : "",    "name" : "Managed Switch_Billing",';
        String s7 = '"productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689_chrgRC",    "startDate" : "",    "status" : "Created",    "version" : "1"  } ]}';
        att1.Body = Blob.valueOf(s1+s2+s3+s4+s5+s6+s7);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        update serv;

        Test.startTest();
        Double leadDays = tarManager.fetchStartDateForSiteAPV2(''+sub.id);
        system.debug('lead days ' + leadDays);
        Test.stopTest();
        system.assertEquals(0, leadDays);
    }

    @isTest
    public static void fetchStartDateForSiteAPV22Test(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        csord__Service__c serv = ProductTestFactory.buildService('TestOrder', ord.id, sub.id, ordReq.id);
        serv.TechnologyType__c = 'Mobile Access';
        insert serv;
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022_Fulfilment';
        insert spec1;

        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = false;
        met1.Installation_Lead_Time__c = 20;
        met1.access_type__c = 'Telstra Fibre Access';
        insert met1;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        String s1 = '{ "legacyAttributes" : [ ],"serviceId" : "a4e2O00000034lYQAQ","specifications" : [ {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : {"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT","MaintainerOnSite" : "Telstra","HardwareReplacementProvider" : "CISCO","MaintenanceCoverageHours" : "8x5xNBD","VendorSupportOnSite" : "","BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8"},';
        String s2 = '"code" : "PS_0022_Fulfilment","description" : "","endDate" : "",    "guid" : "9e77d4b1-55fb-3aeb-611c-9aee05202a2c","instanceId" : "","name" : "Maintenance_Fulfilment","productConfigurationId" : "a3T2O0000006ZWQUA2","specification" : "7e667b64-485d-4b20-a715-93bd1770c123","startDate" : "",    "status" : "Created","version" : "1"}, {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : ';
        String s3 = '{"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT",      "ManagementServiceHours" : "24x7",      "ManagementType" : "Proactive"    },    "code" : "PS_000077_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "bb7aff54-ba1e-2986-ed4b-4748bb0d2c90",    "instanceId" : "",    "name" : "Device Management_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "eea28b0a-b41c-4b56-919a-679923e96d10",    "startDate" : "",';
        String s4 = '"status" : "Created",    "version" : "1"  }, {    "additionalAttributes" : {      "RouterProductInstanceID" : "7d3a247b-6388-3adb-b70b-abccac488513"    },    "attributes" : {      "__targetSystem" : "FULFILMENT",      "ShippingRequired" : "TRUE",      "Country" : "Australia",      "CustomerFacingServiceId" : "",      "CustomerPreferredName" : "",      "RouterProductInstanceID" : "PS_000073_Fulfilment",      "SwitchModel" : "MS120-8 FP",      "Size" : "Small",';
        String s5 = '"EquipmentOwnershipCode" : "Customer Owned Telstra Provided",      "BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8",      "Vendor" : "CISCO",      "PS_000092_CPEDeliveryDate" : ""    },    "code" : "PS_000092_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "42b28dad-b151-3803-5988-5168d7ff92a3",    "instanceId" : "",    "name" : "Managed Switch_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689",    "startDate" : "",    "status" : "Created",    "version" : "1"  },';
        String s6 = '{    "additionalAttributes" : { },    "attributes" : {      "__targetSystem" : "BILLING",      "units" : "1",      "unitPrice" : 60.00,      "type" : "RC",      "currency" : "AUD",      "frequency" : "Monthly",      "billingSpecId" : "BSRC001_CB",      "billInAdvance" : "true",      "prorate" : "false",      "description" : "CISCO (MS120-8FP) Bundle 36 Month",      "SwitchModel" : "MS120-8 FP"    },    "code" : "PS_000092_Billing",    "description" : "",    "endDate" : "",    "guid" : "86bef2a8-cd97-3398-b1d9-4ae694084889",    "instanceId" : "",    "name" : "Managed Switch_Billing",';
        String s7 = '"productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689_chrgRC",    "startDate" : "",    "status" : "Created",    "version" : "1"  } ]}';
        att1.Body = Blob.valueOf(s1+s2+s3+s4+s5+s6+s7);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        update serv;

        Test.startTest();
        Double leadDays = tarManager.fetchStartDateForSiteAPV2(''+sub.id);
        system.debug('lead days ' + leadDays);
        Test.stopTest();
        system.assertEquals(0, leadDays);
    }

    @isTest
    public static void fetchStartDateForSiteAPV222Test(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        sub.csordtelcoa__Replaced_Subscription__c = null;
        insert sub;
        csord__Service__c serv = ProductTestFactory.buildService('TestOrder', ord.id, sub.id, ordReq.id);
        serv.TechnologyType__c = 'Mobile Access';
        insert serv;
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022_Fulfilment';
        insert spec1;

        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = false;
        met1.Installation_Lead_Time__c = 20;
        met1.access_type__c = 'Mobile Access';
        insert met1;
        
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec1.id;
        met2.Appointment_Required__c = true;
        met2.Installation_Lead_Time__c = 20;
        met2.access_type__c = 'Mobile Access';
        insert met2;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        String s1 = '{ "legacyAttributes" : [ ],"serviceId" : "a4e2O00000034lYQAQ","specifications" : [ {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : {"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT","MaintainerOnSite" : "Telstra","HardwareReplacementProvider" : "CISCO","MaintenanceCoverageHours" : "8x5xNBD","VendorSupportOnSite" : "","BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8"},';
        String s2 = '"code" : "PS_0022_Fulfilment","description" : "","endDate" : "",    "guid" : "9e77d4b1-55fb-3aeb-611c-9aee05202a2c","instanceId" : "","name" : "Maintenance_Fulfilment","productConfigurationId" : "a3T2O0000006ZWQUA2","specification" : "7e667b64-485d-4b20-a715-93bd1770c123","startDate" : "",    "status" : "Created","version" : "1"}, {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : ';
        String s3 = '{"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT",      "ManagementServiceHours" : "24x7",      "ManagementType" : "Proactive"    },    "code" : "PS_000077_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "bb7aff54-ba1e-2986-ed4b-4748bb0d2c90",    "instanceId" : "",    "name" : "Device Management_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "eea28b0a-b41c-4b56-919a-679923e96d10",    "startDate" : "",';
        String s4 = '"status" : "Created",    "version" : "1"  }, {    "additionalAttributes" : {      "RouterProductInstanceID" : "7d3a247b-6388-3adb-b70b-abccac488513"    },    "attributes" : {      "__targetSystem" : "FULFILMENT",      "ShippingRequired" : "TRUE",      "Country" : "Australia",      "CustomerFacingServiceId" : "",      "CustomerPreferredName" : "",      "RouterProductInstanceID" : "PS_000073_Fulfilment",      "SwitchModel" : "MS120-8 FP",      "Size" : "Small",';
        String s5 = '"EquipmentOwnershipCode" : "Customer Owned Telstra Provided",      "BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8",      "Vendor" : "CISCO",      "PS_000092_CPEDeliveryDate" : ""    },    "code" : "PS_000092_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "42b28dad-b151-3803-5988-5168d7ff92a3",    "instanceId" : "",    "name" : "Managed Switch_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689",    "startDate" : "",    "status" : "Created",    "version" : "1"  },';
        String s6 = '{    "additionalAttributes" : { },    "attributes" : {      "__targetSystem" : "BILLING",      "units" : "1",      "unitPrice" : 60.00,      "type" : "RC",      "currency" : "AUD",      "frequency" : "Monthly",      "billingSpecId" : "BSRC001_CB",      "billInAdvance" : "true",      "prorate" : "false",      "description" : "CISCO (MS120-8FP) Bundle 36 Month",      "SwitchModel" : "MS120-8 FP"    },    "code" : "PS_000092_Billing",    "description" : "",    "endDate" : "",    "guid" : "86bef2a8-cd97-3398-b1d9-4ae694084889",    "instanceId" : "",    "name" : "Managed Switch_Billing",';
        String s7 = '"productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689_chrgRC",    "startDate" : "",    "status" : "Created",    "version" : "1"  } ]}';
        att1.Body = Blob.valueOf(s1+s2+s3+s4+s5+s6+s7);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        update serv;

        Test.startTest();
        Double leadDays = tarManager.fetchStartDateForSiteAPV2(''+sub.id);
        system.debug('lead days ' + leadDays);
        Test.stopTest();
        system.assertEquals(20, leadDays);
    }

    @isTest
    public static void getServiceSpecificationListTest(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        csord__Service__c serv = ProductTestFactory.buildService('TestOrder', ord.id, sub.id, ordReq.id);
        insert serv;
        
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022_Fulfilment';
        insert spec1;
        csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033_Fulfilment';
        insert spec2;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        insert met1;
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec2.id;
        met2.Appointment_Required__c = true;
        met2.Installation_Lead_Time__c = 22;
        insert met2;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        String s1 = '{ "legacyAttributes" : [ ],"serviceId" : "a4e2O00000034lYQAQ","specifications" : [ {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : {"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT","MaintainerOnSite" : "Telstra","HardwareReplacementProvider" : "CISCO","MaintenanceCoverageHours" : "8x5xNBD","VendorSupportOnSite" : "","BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8"},';
        String s2 = '"code" : "PS_0022_Fulfilment","description" : "","endDate" : "",    "guid" : "9e77d4b1-55fb-3aeb-611c-9aee05202a2c","instanceId" : "","name" : "Maintenance_Fulfilment","productConfigurationId" : "a3T2O0000006ZWQUA2","specification" : "7e667b64-485d-4b20-a715-93bd1770c123","startDate" : "",    "status" : "Created","version" : "1"}, {"additionalAttributes" : {"parentSpec" : "42b28dad-b151-3803-5988-5168d7ff92a3"},"attributes" : ';
        String s3 = '{"parentSpec" : "PS_000092_Fulfilment","__targetSystem" : "FULFILMENT",      "ManagementServiceHours" : "24x7",      "ManagementType" : "Proactive"    },    "code" : "PS_000077_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "bb7aff54-ba1e-2986-ed4b-4748bb0d2c90",    "instanceId" : "",    "name" : "Device Management_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "eea28b0a-b41c-4b56-919a-679923e96d10",    "startDate" : "",';
        String s4 = '"status" : "Created",    "version" : "1"  }, {    "additionalAttributes" : {      "RouterProductInstanceID" : "7d3a247b-6388-3adb-b70b-abccac488513"    },    "attributes" : {      "__targetSystem" : "FULFILMENT",      "ShippingRequired" : "TRUE",      "Country" : "Australia",      "CustomerFacingServiceId" : "",      "CustomerPreferredName" : "",      "RouterProductInstanceID" : "PS_000073_Fulfilment",      "SwitchModel" : "MS120-8 FP",      "Size" : "Small",';
        String s5 = '"EquipmentOwnershipCode" : "Customer Owned Telstra Provided",      "BillofMaterialID" : "8c3c7820-fce4-45b4-b1b1-a3c3d54bf9e8",      "Vendor" : "CISCO",      "PS_000092_CPEDeliveryDate" : ""    },    "code" : "PS_000092_Fulfilment",    "description" : "",    "endDate" : "",    "guid" : "42b28dad-b151-3803-5988-5168d7ff92a3",    "instanceId" : "",    "name" : "Managed Switch_Fulfilment",    "productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689",    "startDate" : "",    "status" : "Created",    "version" : "1"  },';
        String s6 = '{    "additionalAttributes" : { },    "attributes" : {      "__targetSystem" : "BILLING",      "units" : "1",      "unitPrice" : 60.00,      "type" : "RC",      "currency" : "AUD",      "frequency" : "Monthly",      "billingSpecId" : "BSRC001_CB",      "billInAdvance" : "true",      "prorate" : "false",      "description" : "CISCO (MS120-8FP) Bundle 36 Month",      "SwitchModel" : "MS120-8 FP"    },    "code" : "PS_000092_Billing",    "description" : "",    "endDate" : "",    "guid" : "86bef2a8-cd97-3398-b1d9-4ae694084889",    "instanceId" : "",    "name" : "Managed Switch_Billing",';
        String s7 = '"productConfigurationId" : "a3T2O0000006ZWQUA2",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689_chrgRC",    "startDate" : "",    "status" : "Created",    "version" : "1"  } ]}';
        att1.Body = Blob.valueOf(s1+s2+s3+s4+s5+s6+s7);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        update serv;
        
        Test.startTest();
        List<String> specCodeList = tarManager.getAppointmentRequiredSpecCodeList();
        List<TARManagerV2.ServiceSpecificationWrapper> servSpecWrapperList = tarManager.getServiceSpecificationList(sub.id,specCodeList);
        Test.stopTest();
        system.debug('Wrapper List ' + servSpecWrapperList);
        system.debug('Wrapper List size ' + servSpecWrapperList.size());
        system.assert(servSpecWrapperList!=null && servSpecWrapperList.size()>0);
    } 
    
    @isTest
    public static void populateSlotSiteAddressAPV2Test(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        cscrm__Address__c addr = AccountTestFactory.buildAddress('AD12345');
        addr.Address_Status__c = 'CONFIRMED';
        insert addr;
        cscrm__Site__c site = AccountTestFactory.buildSite(addr.id,acc.id);
        insert site;
        sub.Site__c = site.id;
        update sub;
        Test.startTest();
        AppointmentSlotRequestDTO.SlotSiteAddress slotSiteAddress = tarManager.populateSlotSiteAddressAPV2(sub.id);
        Test.stopTest();
        system.assertEquals('AD12345', slotSiteAddress.id);
    }
    
    @isTest
    public static void populateSlotTasksAPV2Test(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        csord__Service__c serv = ProductTestFactory.buildService('TestOrder', ord.id, sub.id, ordReq.id);
        serv.TechnologyType__c = 'test';
        insert serv;
        
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022_Fulfilment';
        insert spec1;
        csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033_Fulfilment';
        insert spec2;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        insert met1;
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec1.id;
        met2.Appointment_Required__c = true;
        met2.Installation_Lead_Time__c = 22;
        met2.name='Telstra Fibre Access';
        met2.Product_TAR_Name__c = 'FTTP';
        met2.access_type__c = 'Telstra Fibre Access';
        insert met2;
        
        
        Specification_Metadata__c met3 = new Specification_Metadata__c();
        met3.Type__c = 'Appointment';
        met3.Specification__c = spec1.id;
        met3.Appointment_Required__c = true;
        met3.Installation_Lead_Time__c = 20;
        met3.name = 'Mobile Access';
        met3.access_type__c = 'Mobile Access';
        insert met3;
        
        
        
        TAR_Metadata__c tar1 = new TAR_Metadata__c();
        
        tar1.Type__c = 'Resource';
        tar1.Weight__c = 1;
        tar1.IsReference__c = true;
        tar1.Specification_Metadata__c = met1.id;
        tar1.Attribute_TAR_Value__c = 'Switch';
        tar1.Attribute_Name__c = 'SwitchModel';
        insert tar1;
        
        TAR_Metadata__c tar2 = new TAR_Metadata__c();
        TAR_Metadata__c tar3 = new TAR_Metadata__c();
        TAR_Metadata__c tar4 = new TAR_Metadata__c();
        TAR_Metadata__c tar5 = new TAR_Metadata__c();
        
        tar2.Type__c = 'Job Description';
        tar2.Weight__c = 1;
        tar2.IsReference__c = true;
        tar2.Specification_Metadata__c = met1.id;
        tar2.Attribute_Name__c = 'Vendor';
        tar2.Attribute_TAR_Value__c = 'Meraki';
        insert tar2;
        
        tar3.Type__c = 'Job Description';
        tar3.Weight__c = 2;
        tar3.IsReference__c = false;
        tar3.Specification_Metadata__c = met1.id;
        tar3.Attribute_Name__c = 'SwitchModel';
        insert tar3;
        
        tar4.Type__c = 'Technology';
        tar4.Weight__c = 1;
        tar4.IsReference__c = false;
        tar4.Specification_Metadata__c = met2.id;
        tar4.name='Telstra Fibre Access';
        insert tar4;
        
        tar5.Type__c = 'Resource';
        tar5.Weight__c = 2;
        tar5.IsReference__c = false;
        tar5.Specification_Metadata__c = met1.id;
        tar3.Attribute_Name__c = 'SwitchModel';
        insert tar5;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        String s1 = '{  "specifications" : [ {    "version" : "1",    "status" : "Created",    "startDate" : "",    "specification" : "7e667b64-485d-4b20-a715-93bd1770c123",';
        String s2 = '"productConfigurationId" : "a3T2O0000006zm0UAA",    "name" : "Maintenance_Fulfilment",    "instanceId" : "",    "guid" : "4f9eb7ed-4972-8b6c-3a42-53ab2f3ad4d4",';
        String s3 = '"endDate" : "",    "description" : "",    "code" : "PS_000076_Fulfilment",    "attributes" : {      "BillofMaterialID" : "0a143b55-6b1c-4755-926b-6416809b65d3",';     
        String s4 = '"VendorSupportOnSite" : "",      "MaintenanceCoverageHours" : "8x5xNBD",      "HardwareReplacementProvider" : "CISCO",      "MaintainerOnSite" : "Telstra",';
        String s5 = '"__targetSystem" : "FULFILMENT",      "parentSpec" : "PS_000092_Fulfilment"    },    "additionalAttributes" : {      "parentSpec" : "def25a9c-afd9-37f2-dc26-4f0fc013bf35"}';
        String s6 = '}, {    "version" : "1",    "status" : "Created",    "startDate" : "",    "specification" : "eea28b0a-b41c-4b56-919a-679923e96d10",    "productConfigurationId" : "a3T2O0000006zm0UAA",';
        String s7 = '"name" : "Device Management_Fulfilment",    "instanceId" : "",    "guid" : "b6a64e60-a943-479e-56ed-2b972ec0a848",    "endDate" : "",    "description" : "",';
        String s8 = '"code" : "PS_000077_Fulfilment",    "attributes" : {      "ManagementType" : "Proactive",      "ManagementServiceHours" : "24x7",      "__targetSystem" : "FULFILMENT",';
        String s9 = '"parentSpec" : "PS_000092_Fulfilment"    },    "additionalAttributes" : {      "parentSpec" : "def25a9c-afd9-37f2-dc26-4f0fc013bf35"    }  }, {    "version" : "1",';
        String s10 = '"status" : "Created",    "startDate" : "",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689",    "productConfigurationId" : "a3T2O0000006zm0UAA",';
        String s11 = '"name" : "Managed Switch_Fulfilment",    "instanceId" : "",    "guid" : "def25a9c-afd9-37f2-dc26-4f0fc013bf35",    "endDate" : "",    "description" : "",' ;
        String s12 = '"code" : "PS_0022_Fulfilment",    "attributes" : {      "Vendor" : "MERAKI",      "BillofMaterialID" : "0a143b55-6b1c-4755-926b-6416809b65d3",';
        String s13 = '"EquipmentOwnershipCode" : "Customer Owned Telstra Provided",      "Size" : "Large",      "SwitchModel" : "MS120-48LP",      "RouterProductInstanceID" : "PS_000073_Fulfilment",';
        String s14 = '"CustomerPreferredName" : "",      "CustomerFacingServiceId" : "",      "Country" : "Australia",      "ShippingRequired" : "TRUE",      "__targetSystem" : "FULFILMENT"    },';
        String s15 = '"additionalAttributes" : { }  }, {    "version" : "1",    "status" : "Created",    "startDate" : "",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689_chrgRC",';
        String s16 = '"productConfigurationId" : "a3T2O0000006zm0UAA",    "name" : "Managed Switch_Billing",    "instanceId" : "",    "guid" : "d298e16d-7317-6b8c-4ce5-391eafd168c2",    "endDate" : "",';
        String s17 = '"description" : "",    "code" : "PS_000092_Billing",    "attributes" : {      "__targetSystem" : "BILLING"    },    "additionalAttributes" : { }  } ],  "serviceId" : "a4e2O0000003IG8QAM",';
        String s18 = '"legacyAttributes" : [ ]}';
        att1.Body = Blob.valueOf(s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        update serv;
        Test.startTest();
        List<AppointmentSlotRequestDTO.SlotTask> slotTaskList = tarManager.populateSlotTasksAPV2(sub.id);
        Test.stopTest();
        system.debug('slotTASKLIST size ' + slotTaskList);
        system.assert(slotTaskList!=null);
    }

    @isTest
    public static void populateSlotTasksAPV2LessThan2TarTest(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        csord__Service__c serv = ProductTestFactory.buildService('TestOrder', ord.id, sub.id, ordReq.id);
        serv.TechnologyType__c = 'test';
        insert serv;
        
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022_Fulfilment';
        insert spec1;
        csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033_Fulfilment';
        insert spec2;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        insert met1;

        TAR_Metadata__c tar1 = new TAR_Metadata__c();
        tar1.Type__c = 'Resource';
        tar1.Weight__c = 1;
        tar1.IsReference__c = true;
        tar1.Specification_Metadata__c = met1.id;
        tar1.Attribute_TAR_Value__c = 'Switch';
        tar1.Attribute_Name__c = 'SwitchModel';
        insert tar1;
        
        TAR_Metadata__c tar2 = new TAR_Metadata__c();
        TAR_Metadata__c tar3 = new TAR_Metadata__c();
        TAR_Metadata__c tar4 = new TAR_Metadata__c();
        TAR_Metadata__c tar5 = new TAR_Metadata__c();
        
        tar2.Type__c = 'Job Description';
        tar2.Weight__c = 1;
        tar2.IsReference__c = true;
        tar2.Specification_Metadata__c = met1.id;
        tar2.Attribute_Name__c = 'Vendor';
        tar2.Attribute_TAR_Value__c = 'Meraki';
        insert tar2;
        
        tar3.Type__c = 'Job Description';
        tar3.Weight__c = 2;
        tar3.IsReference__c = false;
        tar3.Specification_Metadata__c = met1.id;
        tar3.Attribute_Name__c = 'SwitchModel';
        insert tar3;
        
        tar4.Type__c = 'Technology';
        tar4.Weight__c = 1;
        tar4.IsReference__c = false;
        tar4.Specification_Metadata__c = met1.id;
        tar4.name='Telstra Fibre Access';
        insert tar4;
        
        tar5.Type__c = 'Resource';
        tar5.Weight__c = 2;
        tar5.IsReference__c = false;
        tar5.Specification_Metadata__c = met1.id;
        tar3.Attribute_Name__c = 'SwitchModel';
        insert tar5;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        String s1 = '{  "specifications" : [ {    "version" : "1",    "status" : "Created",    "startDate" : "",    "specification" : "7e667b64-485d-4b20-a715-93bd1770c123",';
        String s2 = '"productConfigurationId" : "a3T2O0000006zm0UAA",    "name" : "Maintenance_Fulfilment",    "instanceId" : "",    "guid" : "4f9eb7ed-4972-8b6c-3a42-53ab2f3ad4d4",';
        String s3 = '"endDate" : "",    "description" : "",    "code" : "PS_000076_Fulfilment",    "attributes" : {      "BillofMaterialID" : "0a143b55-6b1c-4755-926b-6416809b65d3",';     
        String s4 = '"VendorSupportOnSite" : "",      "MaintenanceCoverageHours" : "8x5xNBD",      "HardwareReplacementProvider" : "CISCO",      "MaintainerOnSite" : "Telstra",';
        String s5 = '"__targetSystem" : "FULFILMENT",      "parentSpec" : "PS_000092_Fulfilment"    },    "additionalAttributes" : {      "parentSpec" : "def25a9c-afd9-37f2-dc26-4f0fc013bf35"}';
        String s6 = '}, {    "version" : "1",    "status" : "Created",    "startDate" : "",    "specification" : "eea28b0a-b41c-4b56-919a-679923e96d10",    "productConfigurationId" : "a3T2O0000006zm0UAA",';
        String s7 = '"name" : "Device Management_Fulfilment",    "instanceId" : "",    "guid" : "b6a64e60-a943-479e-56ed-2b972ec0a848",    "endDate" : "",    "description" : "",';
        String s8 = '"code" : "PS_000077_Fulfilment",    "attributes" : {      "ManagementType" : "Proactive",      "ManagementServiceHours" : "24x7",      "__targetSystem" : "FULFILMENT",';
        String s9 = '"parentSpec" : "PS_000092_Fulfilment"    },    "additionalAttributes" : {      "parentSpec" : "def25a9c-afd9-37f2-dc26-4f0fc013bf35"    }  }, {    "version" : "1",';
        String s10 = '"status" : "Created",    "startDate" : "",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689",    "productConfigurationId" : "a3T2O0000006zm0UAA",';
        String s11 = '"name" : "Managed Switch_Fulfilment",    "instanceId" : "",    "guid" : "def25a9c-afd9-37f2-dc26-4f0fc013bf35",    "endDate" : "",    "description" : "",' ;
        String s12 = '"code" : "PS_0022_Fulfilment",    "attributes" : {      "Vendor" : "MERAKI",      "BillofMaterialID" : "0a143b55-6b1c-4755-926b-6416809b65d3",';
        String s13 = '"EquipmentOwnershipCode" : "Customer Owned Telstra Provided",      "Size" : "Large",      "SwitchModel" : "MS120-48LP",      "RouterProductInstanceID" : "PS_000073_Fulfilment",';
        String s14 = '"CustomerPreferredName" : "",      "CustomerFacingServiceId" : "",      "Country" : "Australia",      "ShippingRequired" : "TRUE",      "__targetSystem" : "FULFILMENT"    },';
        String s15 = '"additionalAttributes" : { }  }, {    "version" : "1",    "status" : "Created",    "startDate" : "",    "specification" : "c2887569-6b7f-4286-8229-694ec5b60689_chrgRC",';
        String s16 = '"productConfigurationId" : "a3T2O0000006zm0UAA",    "name" : "Managed Switch_Billing",    "instanceId" : "",    "guid" : "d298e16d-7317-6b8c-4ce5-391eafd168c2",    "endDate" : "",';
        String s17 = '"description" : "",    "code" : "PS_000092_Billing",    "attributes" : {      "__targetSystem" : "BILLING"    },    "additionalAttributes" : { }  } ],  "serviceId" : "a4e2O0000003IG8QAM",';
        String s18 = '"legacyAttributes" : [ ]}';
        att1.Body = Blob.valueOf(s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        update serv;
        Test.startTest();
        List<AppointmentSlotRequestDTO.SlotTask> slotTaskList = tarManager.populateSlotTasksAPV2(sub.id);
        Test.stopTest();
        system.assert(slotTaskList!=null);
    }

    @isTest
    public static void populateContactForReserveAppointmentAPV2Test(){
        TARManagerV2 tarManager = new TARManagerV2();
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c sub = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert sub;
        cscrm__Address__c addr = AccountTestFactory.buildAddress('AD12345');
        addr.Address_Status__c = 'CONFIRMED';
        insert addr;
        cscrm__Site__c site = AccountTestFactory.buildSite(addr.id,acc.id);
        insert site;
        sub.Site__c = site.id;
        update sub;
        
        Contact cntct1 = new Contact();
        cntct1.LastName = 'Primary';
        cntct1.Phone = '111222';
        insert cntct1;
        Contact cntct2 = new Contact();
        cntct2.LastName = 'Secondary';
        cntct2.Phone = '22223333';
        insert cntct2;
        Contact cntct3 = new Contact();
        cntct3.LastName = 'Site';
        cntct3.Phone = '33334444';
        insert cntct3;

        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cntct1.Id;
        serv.Technical_Contact__c = cntct1.Id;
        serv.Project_Contact__c = cntct1.Id;
        insert serv;
        
        Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
        
        fcRole1.Role__c = 'Primary Site Contact';
        fcRole2.Role__c = 'Technical Contact';
        fcRole3.Role__c = 'Project Contact';
        
        fcRole1.ContactID__c = cntct1.id;
        fcRole2.ContactID__c = cntct2.id;
        fcRole3.ContactID__c = cntct3.id;
        
        fcRole1.SiteID__c = site.id;
        fcRole2.SiteID__c = site.id;
        fcRole3.SiteID__c = site.id;
        insert fcRole1;
        insert fcRole2;
        insert fcRole3;
        
        Test.startTest();
        List<AppointmentReserveRequestDTO.Contacts> contactList = tarManager.populateContactForReserveAppointmentAPV2(sub.id);
        Test.stopTest();
        system.assertEquals(1, contactList.size());
        system.debug('contact List ' + contactList);
    }
}