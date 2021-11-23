@isTest
public class CS_TransientMetadataHelperTest {

    @testsetup public static void dataSetup(){
                
        //creating Product Attribute Metadata record
        Product_Attribute_Metadata__c metadata=new Product_Attribute_Metadata__c();
        metadata.Name='Mobile Access';
        metadata.Offer_Name__c='Connected Workplace';
        metadata.Offer_Id__c='DMCAT_Offer_000303';
        metadata.Metadata_Type__c='IsAssetable';
        metadata.Metadata_Value__c='False';
        metadata.Product_Name__c='Mobile Access';
        metadata.Product_ID__c='DMCAT_ProductSpecification_000263';
        metadata.Attribute_Name__c='INTROAM';
        metadata.Change_Type__c='New';
        metadata.Change_SubType__c='';
        metadata.IsReference__c=true;
        metadata.ReferenceField__c='International_Calling__c';
        metadata.Identifier__c='DMCAT_ProductSpecification_000303_INTROAM'; 
        insert metadata;
        
        Account acc=new Account();
        acc.name='Testaccount';
        acc.Type='Company';
        acc.Title__c='';
        acc.CIDN__c='65432213';
        acc.Email__c='abc@gmail.com';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Closed Won';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp; 
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='+61123456789';
        contact.email='k@gmail.com';
        contact.AccountId = acc.id;
        insert contact;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        insert ocr;
         
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.name = 'TestOrder1';
        ord1.csord__Order_Request__c = ordReq.Id;
        ord1.csord__Identification__c = 'test1 identification';
        ord1.csord__Account__c=acc.Id;
        ord1.csord__Start_Date__c=Date.today();
        ord1.Telstra_Committed_Date__c=Date.today();
        ord1.csord__Customer_Order_Number__c='7654383';
        ord1.csordtelcoa__Opportunity__c =opp.id;
        ord1.isTransientComplete__c = true;
        insert ord1;
        
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c=acc.Id;
        ord.csord__Start_Date__c=Date.today();
        ord.Telstra_Committed_Date__c=Date.today();
        ord.csord__Customer_Order_Number__c='7654387';
        ord.csordtelcoa__Opportunity__c =opp.id;
        ord.csord__Primary_Order__c =   ord1.id;
       // ord.isTransientComplete__c = true;
        insert ord;
        
         
        cscrm__Address__c address =new cscrm__Address__c();
        address.Address_ID__c='675439';
        address.cscrm__Account__c=acc.id;  
        insert address;
         
         cscrm__Account_Address_Relationship__c add= new cscrm__Account_Address_Relationship__c();
         add.cscrm__Address__c=address.id;
         add.cscrm__Account__c=acc.id;
         add.cscrm__Active__c=true;
         add.cscrm__Address_Type__c='Primary Address';
         insert add;
         
         Functional_Contact_Role__c FCR = new Functional_Contact_Role__c();
         FCR.OrderID__c = ord.id;
         FCR.Role_Type__c = 'Order';
         FCR.ContactID__c =contact.id;
         
         insert FCR;
        
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = 'Connected Workplacer';
        offer.Offer_Spec_Id__c = 'DMCAT_Offer_000303';
        insert offer;
         
         csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.Offer__c=offer.id;
        insert subs;
         
        List<csord__Service__c> servList = new List<csord__Service__c>();
      csord__Service__c serv = new csord__Service__c();
        serv.name = 'IP Site';
        serv.csord__Identification__c  = 'Service_a3T2O000000HTzTUAW_0';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Service_Number__c = 'SVC-000029249';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Order__c = ord.Id;    
        servList.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name = 'User - Fixed Seat - Zone 1';
        serv1.csord__Identification__c  = 'Service_a3T2O000000HTzTUAW_1';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csordtelcoa__Service_Number__c = 'SVC-000029243';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Order__c = ord.Id;         
        //insert serv1;        
            servList.add(serv1);
        insert servList;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{   "legacyAttributes" : [ ],   "serviceId" : "'+serv.id+'",   "specifications" : [ {     "additionalAttributes" : {       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-04-12T19:00:00",       "SERVICEID" : "61459011456",       "IPWirelessProductInstanceID" : "1f6a794a-8107-ba8b-901f-cae7ead44689"     },     "attributes" : {       "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment",       "__targetSystem" : "FULFILMENT",       "SERVICEPROFILE" : "DATA_BACKUP",       "MESSAGEBANK" : "NA",       "CONTEXT" : "NA",       "SIMSKU" : "NA",       "AccessRole" : "Primary",       "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b",       "SERVICEID" : "",       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "",       "ShippingRequired" : "TRUE",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "e17a5bc2-2d12-c430-34cb-b91ee511bbbc",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "ServiceManagementOption " : "1"     },     "code" : "DMCAT_ProductSpecification_000326_Assurance",     "description" : "",     "endDate" : "",     "guid" : "6fece338-858f-c129-d8d3-ae5898468c1a",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Telstra Managed Service Option 1_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "T22E_MIA_DATPLAN",       "type" : "Domestic Data",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Mobile",       "billDescription" : "Mobile Interim Access Allowance",       "SERVICEID" : "",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "description" : "",     "endDate" : "",     "guid" : "617b7a9d-6811-23f8-e190-aff052f3638f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "ocsProd3",       "type" : "Dummy ngUC",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Voice",       "billDescription" : "ngUC Dummy Usage Specification Allowance"     },     "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "description" : "",     "endDate" : "",     "guid" : "5d09d6e2-8b48-9e52-9047-69cc0bbe9c44",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "BSServiceTypeProductInstanceID" : "555e5492-fbc0-5ff0-4cb4-38906242cf82",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-04-12T19:00:00"     },     "attributes" : {       "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment",       "__targetSystem" : "FULFILMENT",       "CustomerFacingServiceId" : "",       "CustomerPreferredName" : "",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : ""     },     "code" : "DMCAT_ProductSpecification_000322_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Site_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "InternetProtectionSolutionProductInstanceID" : "e8dfbe07-3a1e-690a-43b8-9ba25628b707"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "UserProtectionType" : "Web and Mail",       "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000162_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "f4f53cd3-df4b-4a72-e01f-6875abcdf050",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Web and Mail Internet Protection User_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "6fece338-858f-c129-d8d3-ae5898468c1a"     },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance",       "ResponseTarget" : "SLA0010001",       "RestoreTarget" : "SLA0010002"     },     "code" : "DMCAT_ProductSpecification_000151_Assurance",     "description" : "",     "endDate" : "",     "guid" : "1319c518-3d8b-b975-e121-d2034c66d68f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Incident Management_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "name" : "Hosted UC",       "CustomerFacingServiceId" : "",       "id" : "",       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000315_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "1286f986-8eb4-c178-d6b5-fafd7d3f3ff0",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Feature Packs_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "__targetSystem" : "FULFILMENT",       "VoicePlan" : "Complete Premium",       "id" : "",       "CustomerFacingServiceId" : "",       "Number" : [ {         "schemaId" : "6958a9b0-b4b4-d8ed-aee0-95809f71fae5",         "attributes" : {           "FNN" : "1111111111",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "LE"         }       }, {         "schemaId" : "2ed10109-e96c-ea34-9d08-fa32974bd41c",         "attributes" : {           "FNN" : "2222222222",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9b532ac9-1b5b-52bf-77b9-09c56dd32a78",         "attributes" : {           "FNN" : "3333333333",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "aad74447-1fb5-aff3-8adb-be166daac227",         "attributes" : {           "FNN" : "8282345567",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "80ffa07e-2a80-e2af-d583-eef7447dcdcb",         "attributes" : {           "FNN" : "8282345566",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "ba722761-6c24-ee82-7d58-d24fe7f6029e",         "attributes" : {           "FNN" : "8282345568",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9587c470-3aa0-e25d-b8fc-187aa7055459",         "attributes" : {           "FNN" : "8282345569",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "796fc1d9-c440-bff5-f239-6b73a2f74cc8",         "attributes" : {           "FNN" : "8282345516",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "5324f75d-cbf8-86a1-43b1-e356b47fd71d",         "attributes" : {           "FNN" : "8282345526",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "97b1603a-1999-1aea-c017-f110bc34cdd2",         "attributes" : {           "FNN" : "8282345536",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "8f5a5678-1f44-c310-a540-bf66c83389ee",         "attributes" : {           "FNN" : "8282345546",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       } ]     },     "code" : "DMCAT_ProductSpecification_000313_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "7b1b0cd6-0684-96e6-54cf-69387aad4589",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   } ] }');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
        Attachment att2 = new Attachment();
       att2.Body = Blob.valueOf('{ "specifications" : [ { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074", "productConfigurationId" : "a3T2O000000Ay1eUAC", "name" : "User_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "001c23ab-355b-5645-44ce-1de93a83aba1", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000074_Fulfilment", "attributes" : { "UserType" : "Fixed Seat", "Quantity" : 3, "Zone" : "1", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000074_chrgRC", "productConfigurationId" : "a3T2O000000Ay1eUAC", "name" : "User_Billing", "instanceId" : "", "includeBilling" : false, "guid" : "18cd9f21-ad1a-b9f4-6293-2477c5735792", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000074_Billing", "attributes" : { "billDescription" : "Fixed Seat (Zone 4)", "prorate" : "false", "billInAdvance" : "true", "billingSpecId" : "BSRC001_CB", "frequency" : "Monthly", "currency" : "AUD", "type" : "Fixed Seat", "quantity" : 3, "rateExcludeGST" : 150.00, "__targetSystem" : "BILLING" }, "additionalAttributes" : { } } ], "serviceId" : "'+serv1.id+'", "legacyAttributes" : [ ] }');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        insert att2;
        
    }
         @isTest
         static void testfetchTransientDataFromService(){
             Set<String> serviceIDSet = new Set<String>();
            List<String> fieldAPINameList = new List<String>();
            CS_TransientMetadataHelper obj  = new CS_TransientMetadataHelper();
             List<String> specCodeForTransientList = new CS_TransientMetadataHelper().getSpecCodeListForNonAssetableProducts();
            List<Product_Attribute_Metadata__c> productMetadataList = new CS_TransientMetadataHelper().getAttributeReferenceForNonAssetableProducts();            
            Map<String,List<String>> specCodeChangeTypeMap = new CS_TransientMetadataHelper().getSpecCodeChangeTypeForNonAssetableProducts();
            fieldAPINameList = new CS_TransientMetadataHelper().getTransientReferenceAPINameList();
            Set<String> sepcOfferSet = new CS_TransientMetadataHelper().getOfferListForNonAssetableProducts();
            csord__Service__c ser = [Select id, name from csord__Service__c where name = 'IP Site'];
            serviceIDSet.add(ser.Id);
            Test.startTest();
            Map<Id,csord__Service__c> test1 = obj.fetchTransientDataFromService(serviceIDSet,fieldAPINameList);
            Test.stopTest();
            System.assertNotEquals(serviceIDSet, null);
            
         }
    
   
    
}