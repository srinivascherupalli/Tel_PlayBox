/********************************************************
Class Name      :   GenerateTransientDataHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shreya Jaiswal        24/12/19        EDGE-125552
**********************************************************
*/

@isTest
public class GenerateTransientDataHandlerTest {
    
    @isTest
    static void processTest(){
        csord__Order__c order=[select id from csord__Order__c where name='TestOrder'][0];
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        parentOrchProcess.Order__c= order.Id;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
       // TransientDataDTO transientData = new TransientDataDTO();
        
        
        Test.startTest();
        
        
                List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();

         TransientDataDTO transientData = new TransientDataDTO();
         
         TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = 'DMCAT_Offer_000303';
                            dataDTO.specCode = 'DMCAT_ProductSpecification_000263_Fulfilment';
                            dataDTO.specGUID = 'dc952b75-53c0-dfa4-e296-2e1d4ce42cfd';
                            dataDTO.changeType = 'New';
                            transDataDTOList.add(dataDTO);
                        transientData.dataDTOList =   transDataDTOList; 
        GenerateTransientDataHandler dataHandler=new GenerateTransientDataHandler();
        List<CSPOFA__Orchestration_Step__c> result=dataHandler.process(steps);
        List<Id> OrderIds = new List<Id>();
        OrderIds.add(order.id);
       GenerateTransientDataHandler.prepareTransientDataForOrder(OrderIds);
       GenerateTransientDataHandler.insertAttachmentOnOrder(order.id,transientData);

        Test.stopTest();
        system.assertEquals(result[0].CSPOFA__Message__c,'Custom Step succeeded');
        
        
    }
   /*  
     @isTest
    static void processTestModify(){
        
        Product_Attribute_Metadata__c metadata1=new Product_Attribute_Metadata__c();
        metadata1.Name='Mobile Access';
        metadata1.Offer_Name__c='Connected Workplace';
        metadata1.Offer_Id__c='DMCAT_Offer_000303';
        metadata1.Metadata_Type__c='IsAssetable';
        metadata1.Metadata_Value__c='False';
        metadata1.Product_Name__c='Mobile Access';
        metadata1.Product_ID__c='DMCAT_ProductSpecification_000263';
        metadata1.Attribute_Name__c='SIMSerialNumber';
        metadata1.Change_Type__c='Modify';
        metadata1.Change_SubType__c='Modify';
        metadata1.IsReference__c=true;
        metadata1.ReferenceField__c='Sim_Serial_Number__c';
        metadata1.Identifier__c='DMCAT_ProductSpecification_000263_SIMSerialNumber';

        insert metadata1; 
        
        Account acc=new Account();
        acc.name='Testaccount';
        acc.Type='Company';
        acc.Title__c='';
        acc.CIDN__c='65432213';
        acc.Email__c='abc@gmail.com';
        acc.Customer_Status__c='Active';
        insert acc;
        test.startTest();
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
         test.stopTest();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
         
        List<Id> OrderIds = new List<Id>();
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c=acc.Id;
        ord.csord__Start_Date__c=Date.today();
        ord.Telstra_Committed_Date__c=Date.today();
        ord.csord__Customer_Order_Number__c='7654387';
        ord.csordtelcoa__Opportunity__c =opp.id;
        insert ord;
        
        OrderIds.add(ord.id);
        
         
        cscrm__Address__c address =new cscrm__Address__c();
        address.Address_ID__c='6754391';
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
        
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.name = 'Connected Workplace';
        offer.Offer_ID__c = 'DMCAT_Offer_000303';
        insert offer;
         
         csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.MarketableOffer__c=offer.id;
        insert subs;
         
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'IP Site';
        serv.csord__Identification__c  = 'Service_a3T2O000000HTzTUAW_0';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Service_Number__c = 'SVC-000029249';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Order__c = ord.Id;
         
        insert serv;
        
        
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{   "legacyAttributes" : [ ],   "serviceId" : "'+serv.id+'",   "specifications" : [ {     "additionalAttributes" : {       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-04-12T19:00:00",       "SERVICEID" : "61459011456",       "IPWirelessProductInstanceID" : "1f6a794a-8107-ba8b-901f-cae7ead44689"     },     "attributes" : {       "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment",       "__targetSystem" : "FULFILMENT",       "SERVICEPROFILE" : "DATA_BACKUP",       "MESSAGEBANK" : "NA",       "CONTEXT" : "NA",       "SIMSKU" : "NA",       "AccessRole" : "Primary",       "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b",       "SERVICEID" : "",       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "",       "ShippingRequired" : "TRUE",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "e17a5bc2-2d12-c430-34cb-b91ee511bbbc",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263",     "startDate" : "",     "status" : "Modified",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "ServiceManagementOption " : "1"     },     "code" : "DMCAT_ProductSpecification_000326_Assurance",     "description" : "",     "endDate" : "",     "guid" : "6fece338-858f-c129-d8d3-ae5898468c1a",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Telstra Managed Service Option 1_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "T22E_MIA_DATPLAN",       "type" : "Domestic Data",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Mobile",       "billDescription" : "Mobile Interim Access Allowance",       "SERVICEID" : "",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "description" : "",     "endDate" : "",     "guid" : "617b7a9d-6811-23f8-e190-aff052f3638f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "startDate" : "",     "status" : "Modified",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "ocsProd3",       "type" : "Dummy ngUC",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Voice",       "billDescription" : "ngUC Dummy Usage Specification Allowance"     },     "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "description" : "",     "endDate" : "",     "guid" : "5d09d6e2-8b48-9e52-9047-69cc0bbe9c44",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "BSServiceTypeProductInstanceID" : "555e5492-fbc0-5ff0-4cb4-38906242cf82",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-04-12T19:00:00"     },     "attributes" : {       "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment",       "__targetSystem" : "FULFILMENT",       "CustomerFacingServiceId" : "",       "CustomerPreferredName" : "",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : ""     },     "code" : "DMCAT_ProductSpecification_000322_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Site_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "InternetProtectionSolutionProductInstanceID" : "e8dfbe07-3a1e-690a-43b8-9ba25628b707"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "UserProtectionType" : "Web and Mail",       "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000162_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "f4f53cd3-df4b-4a72-e01f-6875abcdf050",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Web and Mail Internet Protection User_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "6fece338-858f-c129-d8d3-ae5898468c1a"     },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance",       "ResponseTarget" : "SLA0010001",       "RestoreTarget" : "SLA0010002"     },     "code" : "DMCAT_ProductSpecification_000151_Assurance",     "description" : "",     "endDate" : "",     "guid" : "1319c518-3d8b-b975-e121-d2034c66d68f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Incident Management_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "name" : "Hosted UC",       "CustomerFacingServiceId" : "",       "id" : "",       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000315_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "1286f986-8eb4-c178-d6b5-fafd7d3f3ff0",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Feature Packs_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "__targetSystem" : "FULFILMENT",       "VoicePlan" : "Complete Premium",       "id" : "",       "CustomerFacingServiceId" : "",       "Number" : [ {         "schemaId" : "6958a9b0-b4b4-d8ed-aee0-95809f71fae5",         "attributes" : {           "FNN" : "1111111111",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "LE"         }       }, {         "schemaId" : "2ed10109-e96c-ea34-9d08-fa32974bd41c",         "attributes" : {           "FNN" : "2222222222",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9b532ac9-1b5b-52bf-77b9-09c56dd32a78",         "attributes" : {           "FNN" : "3333333333",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "aad74447-1fb5-aff3-8adb-be166daac227",         "attributes" : {           "FNN" : "8282345567",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "80ffa07e-2a80-e2af-d583-eef7447dcdcb",         "attributes" : {           "FNN" : "8282345566",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "ba722761-6c24-ee82-7d58-d24fe7f6029e",         "attributes" : {           "FNN" : "8282345568",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9587c470-3aa0-e25d-b8fc-187aa7055459",         "attributes" : {           "FNN" : "8282345569",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "796fc1d9-c440-bff5-f239-6b73a2f74cc8",         "attributes" : {           "FNN" : "8282345516",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "5324f75d-cbf8-86a1-43b1-e356b47fd71d",         "attributes" : {           "FNN" : "8282345526",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "97b1603a-1999-1aea-c017-f110bc34cdd2",         "attributes" : {           "FNN" : "8282345536",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "8f5a5678-1f44-c310-a540-bf66c83389ee",         "attributes" : {           "FNN" : "8282345546",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       } ]     },     "code" : "DMCAT_ProductSpecification_000313_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "7b1b0cd6-0684-96e6-54cf-69387aad4589",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   } ] }');                    
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
          
        csord__Order__c order=[select id from csord__Order__c where name='TestOrder'][0];
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        parentOrchProcess.Order__c= order.Id;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        
         
        
        List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();

         TransientDataDTO transientData = new TransientDataDTO();
         
         TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = 'DMCAT_Offer_000303';
                            dataDTO.specCode = 'DMCAT_ProductSpecification_000263_Fulfilment';
                            dataDTO.specGUID = 'dc952b75-53c0-dfa4-e296-2e1d4ce42cfd';
                            dataDTO.changeType = 'Modify';
                            transDataDTOList.add(dataDTO);
                        transientData.dataDTOList =   transDataDTOList;  
        GenerateTransientDataHandler dataHandler=new GenerateTransientDataHandler();
        List<CSPOFA__Orchestration_Step__c> result=dataHandler.process(steps);
        GenerateTransientDataHandler.prepareTransientDataForOrder(OrderIds);
        GenerateTransientDataHandler.insertAttachmentOnOrder(order.id,transientData);
        Test.stopTest();
        system.assertEquals(result[0].CSPOFA__Message__c,'Custom Step succeeded');
    } */                           
                          
    @testSetup
    static void createOrderData(){
        
        Product_Attribute_Metadata__c metadata1=new Product_Attribute_Metadata__c();
        metadata1.Name='Mobile Access';
        metadata1.Offer_Name__c='Connected Workplace';
        metadata1.Offer_Id__c='DMCAT_Offer_000303';
        metadata1.Metadata_Type__c='IsAssetable';
        metadata1.Metadata_Value__c='False';
        metadata1.Product_Name__c='Mobile Access';
        metadata1.Product_ID__c='DMCAT_ProductSpecification_000263';
        metadata1.Attribute_Name__c='SIMSerialNumber';
        metadata1.Change_Type__c='Modify';
        metadata1.Change_SubType__c='Modify';
        metadata1.IsReference__c=true;
        metadata1.ReferenceField__c='Sim_Serial_Number__c';
        metadata1.Identifier__c='DMCAT_ProductSpecification_000263_SIMSerialNumber';

        insert metadata1; 
        //EDGE-125552
        Product_Attribute_Metadata__c metadataSIM=new Product_Attribute_Metadata__c();
        metadataSIM.Name='Mobile Access';
        metadataSIM.Offer_Name__c='Corporate Mobile Plus';
        metadataSIM.Offer_Id__c='DMCAT_Offer_000646';
        metadataSIM.Metadata_Type__c='IsAssetable';
        metadataSIM.Metadata_Value__c='False';
        metadataSIM.Product_Name__c='Mobile Access';
        metadataSIM.Product_ID__c='DMCAT_ProductSpecification_000420';
        metadataSIM.Attribute_Name__c='SIMSerialNumber';
        metadataSIM.Change_Type__c='SIMReplacement';
        metadataSIM.IsReference__c=true;
        metadataSIM.ReferenceField__c='Sim_Serial_Number__c';
        metadataSIM.Identifier__c='DMCAT_ProductSpecification_000420_SIMSerialNumber';

        insert metadataSIM; 
        
        Account acc=new Account();
        acc.name='Testa ccount3';
        acc.Type='Company';
        acc.Title__c='';
        acc.CIDN__c='654322133';
        acc.Email__c='abcd@gmail.com';
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
         
        List<Id> OrderIds = new List<Id>();
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c=acc.Id;
        ord.csord__Start_Date__c=Date.today();
        ord.Telstra_Committed_Date__c=Date.today();
        ord.csord__Customer_Order_Number__c='76543875';
        ord.csordtelcoa__Opportunity__c =opp.id;
        insert ord;
        //EDGE-125552order for scenariotype SIM Replacement
        csord__Order__c ordSIM = new csord__Order__c();
        ordSIM.name = 'TestOrderSIM';
        ordSIM.csord__Identification__c = 'test identification';
        ordSIM.csord__Account__c=acc.Id;
        ordSIM.csordtelcoa__Opportunity__c =opp.id;
        ordSIM.csord__Identification__c ='Order_456';
        insert ordSIM;
        
        OrderIds.add(ord.id);
        
         
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
        //EDGE-150372. Dheeraj Bhatt. Test data creation
         cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
        //productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000423';
        insert productDefinition;
        
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        //Added productConfig.cscfga__Product_Definition__c. 
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        productConfig.Name='Device';
        pcList.add(productConfig);
        insert pcList;
        
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.name = 'Connected Workplace';
        offer.Offer_ID__c = 'DMCAT_Offer_000303';
        insert offer;
        //EDGE-125552 
        Marketable_Offer__c CMPoffer = new Marketable_Offer__c();
        CMPoffer.name = 'Corporate Mobile Plus';
        CMPoffer.Offer_ID__c = 'DMCAT_Offer_000420';
        insert CMPoffer;
         
         csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.MarketableOffer__c=offer.id;
        insert subs;
        //EDGE-125552
        csord__Subscription__c subsSIM=new csord__Subscription__c();
        subsSIM.name  = 'testSubscriptionSIM';
        subsSIM.csord__Identification__c = 'testIdentity';
        subsSIM.csord__Order__c = ordSIM.Id;
        subsSIM.Sub_status__c = 'Active';
        subsSIM.MarketableOffer__c=CMPoffer.id;
        insert subsSIM;
         
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'IP Site';
        serv.csord__Identification__c  = 'Service_a3T2O000000HTzTUAW_0';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Service_Number__c = 'SVC-000029249';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Order__c = ord.Id;
        serv.csordtelcoa__Product_Configuration__c=productConfig.id;
        insert serv;
        //EDGE-125552
        csord__Service__c servSIM = new csord__Service__c();
        servSIM.name = 'FairPlayData';
        servSIM.csord__Identification__c  = 'Service_a3T2O000230HTzTUAW_0';
        //servSIM.csord__Order_Request__c = ordReq.Id;
        servSIM.csordtelcoa__Service_Number__c = 'SVC-000029749';
        servSIM.csord__Subscription__c = subsSIM.Id;
        servSIM.csord__Order__c = ordSIM.Id;
        servSIM.Scenario_Type__c = 'SIMReplacement' ;
        insert servSIM;
        
        
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{   "legacyAttributes" : [ ],   "serviceId" : "'+serv.id+'",   "specifications" : [ {     "additionalAttributes" : {       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-04-12T19:00:00",       "SERVICEID" : "61459011456",       "IPWirelessProductInstanceID" : "1f6a794a-8107-ba8b-901f-cae7ead44689"     },     "attributes" : {       "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment",       "__targetSystem" : "FULFILMENT",       "SERVICEPROFILE" : "DATA_BACKUP",       "MESSAGEBANK" : "NA",       "CONTEXT" : "NA",       "SIMSKU" : "NA",       "AccessRole" : "Primary",       "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b",       "SERVICEID" : "",       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "",       "ShippingRequired" : "TRUE",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "e17a5bc2-2d12-c430-34cb-b91ee511bbbc",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263",     "startDate" : "",     "status" : "Modified",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "ServiceManagementOption " : "1"     },     "code" : "DMCAT_ProductSpecification_000326_Assurance",     "description" : "",     "endDate" : "",     "guid" : "6fece338-858f-c129-d8d3-ae5898468c1a",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Telstra Managed Service Option 1_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "T22E_MIA_DATPLAN",       "type" : "Domestic Data",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Mobile",       "billDescription" : "Mobile Interim Access Allowance",       "SERVICEID" : "",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "description" : "",     "endDate" : "",     "guid" : "617b7a9d-6811-23f8-e190-aff052f3638f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "startDate" : "",     "status" : "Modified",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "ocsProd3",       "type" : "Dummy ngUC",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Voice",       "billDescription" : "ngUC Dummy Usage Specification Allowance"     },     "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "description" : "",     "endDate" : "",     "guid" : "5d09d6e2-8b48-9e52-9047-69cc0bbe9c44",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "BSServiceTypeProductInstanceID" : "555e5492-fbc0-5ff0-4cb4-38906242cf82",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-04-12T19:00:00"     },     "attributes" : {       "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment",       "__targetSystem" : "FULFILMENT",       "CustomerFacingServiceId" : "",       "CustomerPreferredName" : "",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : ""     },     "code" : "DMCAT_ProductSpecification_000322_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Site_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "InternetProtectionSolutionProductInstanceID" : "e8dfbe07-3a1e-690a-43b8-9ba25628b707"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "UserProtectionType" : "Web and Mail",       "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000162_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "f4f53cd3-df4b-4a72-e01f-6875abcdf050",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Web and Mail Internet Protection User_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "6fece338-858f-c129-d8d3-ae5898468c1a"     },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance",       "ResponseTarget" : "SLA0010001",       "RestoreTarget" : "SLA0010002"     },     "code" : "DMCAT_ProductSpecification_000151_Assurance",     "description" : "",     "endDate" : "",     "guid" : "1319c518-3d8b-b975-e121-d2034c66d68f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Incident Management_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "name" : "Hosted UC",       "CustomerFacingServiceId" : "",       "id" : "",       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000315_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "1286f986-8eb4-c178-d6b5-fafd7d3f3ff0",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Feature Packs_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "__targetSystem" : "FULFILMENT",       "VoicePlan" : "Complete Premium",       "id" : "",       "CustomerFacingServiceId" : "",       "Number" : [ {         "schemaId" : "6958a9b0-b4b4-d8ed-aee0-95809f71fae5",         "attributes" : {           "FNN" : "1111111111",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "LE"         }       }, {         "schemaId" : "2ed10109-e96c-ea34-9d08-fa32974bd41c",         "attributes" : {           "FNN" : "2222222222",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9b532ac9-1b5b-52bf-77b9-09c56dd32a78",         "attributes" : {           "FNN" : "3333333333",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "aad74447-1fb5-aff3-8adb-be166daac227",         "attributes" : {           "FNN" : "8282345567",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "80ffa07e-2a80-e2af-d583-eef7447dcdcb",         "attributes" : {           "FNN" : "8282345566",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "ba722761-6c24-ee82-7d58-d24fe7f6029e",         "attributes" : {           "FNN" : "8282345568",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9587c470-3aa0-e25d-b8fc-187aa7055459",         "attributes" : {           "FNN" : "8282345569",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "796fc1d9-c440-bff5-f239-6b73a2f74cc8",         "attributes" : {           "FNN" : "8282345516",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "5324f75d-cbf8-86a1-43b1-e356b47fd71d",         "attributes" : {           "FNN" : "8282345526",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "97b1603a-1999-1aea-c017-f110bc34cdd2",         "attributes" : {           "FNN" : "8282345536",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "8f5a5678-1f44-c310-a540-bf66c83389ee",         "attributes" : {           "FNN" : "8282345546",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       } ]     },     "code" : "DMCAT_ProductSpecification_000313_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "7b1b0cd6-0684-96e6-54cf-69387aad4589",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   } ] }');                    
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        //EDGE-125552
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{   "legacyAttributes" : [ ],   "serviceId" : "'+servSIM.id+'",   "specifications" : [ {     "additionalAttributes" : {       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-04-12T19:00:00",       "SERVICEID" : "61459011456",       "IPWirelessProductInstanceID" : "1f6a794a-8107-ba8b-901f-cae7ead44689"     },     "attributes" : {       "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment",       "__targetSystem" : "FULFILMENT",       "SERVICEPROFILE" : "DATA_BACKUP",       "MESSAGEBANK" : "NA",       "CONTEXT" : "NA",       "SIMSKU" : "NA",       "AccessRole" : "Primary",       "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b",       "SERVICEID" : "",       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "",       "ShippingRequired" : "TRUE",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000263_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "e17a5bc2-2d12-c430-34cb-b91ee511bbbc",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263",     "startDate" : "",     "status" : "Modified",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "ServiceManagementOption " : "1"     },     "code" : "DMCAT_ProductSpecification_000326_Assurance",     "description" : "",     "endDate" : "",     "guid" : "6fece338-858f-c129-d8d3-ae5898468c1a",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Telstra Managed Service Option 1_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "T22E_MIA_DATPLAN",       "type" : "Domestic Data",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Mobile",       "billDescription" : "Mobile Interim Access Allowance",       "SERVICEID" : "",       "IMSI" : ""     },     "code" : "DMCAT_ProductSpecification_000420_Billing_Allowance_000494_3",     "description" : "",     "endDate" : "",     "guid" : "617b7a9d-6811-23f8-e190-aff052f3638f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Mobile Access_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3",     "startDate" : "",     "status" : "Modified",     "version" : "1"   }, {     "additionalAttributes" : { },     "attributes" : {       "__targetSystem" : "BILLING",       "billingSpecId" : "BSUSG001_CB",       "ocsProdID" : "ocsProd3",       "type" : "Dummy ngUC",       "unitofMeasure" : "GB",       "value" : "Unlimited",       "RoutingServiceType" : "Voice",       "billDescription" : "ngUC Dummy Usage Specification Allowance"     },     "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "description" : "",     "endDate" : "",     "guid" : "5d09d6e2-8b48-9e52-9047-69cc0bbe9c44",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Bill_AW",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "BSServiceTypeProductInstanceID" : "555e5492-fbc0-5ff0-4cb4-38906242cf82",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-04-12T19:00:00"     },     "attributes" : {       "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment",       "__targetSystem" : "FULFILMENT",       "CustomerFacingServiceId" : "",       "CustomerPreferredName" : "",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : ""     },     "code" : "DMCAT_ProductSpecification_000322_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Site_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "InternetProtectionSolutionProductInstanceID" : "e8dfbe07-3a1e-690a-43b8-9ba25628b707"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "UserProtectionType" : "Web and Mail",       "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000162_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "f4f53cd3-df4b-4a72-e01f-6875abcdf050",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Web and Mail Internet Protection User_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "6fece338-858f-c129-d8d3-ae5898468c1a"     },     "attributes" : {       "__targetSystem" : "ASSURANCE",       "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance",       "ResponseTarget" : "SLA0010001",       "RestoreTarget" : "SLA0010002"     },     "code" : "DMCAT_ProductSpecification_000151_Assurance",     "description" : "",     "endDate" : "",     "guid" : "1319c518-3d8b-b975-e121-d2034c66d68f",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Incident Management_Assurance",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151",     "startDate" : "",     "status" : "Created",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "__targetSystem" : "FULFILMENT",       "name" : "Hosted UC",       "CustomerFacingServiceId" : "",       "id" : "",       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "Quantity" : "3"     },     "code" : "DMCAT_ProductSpecification_000315_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "1286f986-8eb4-c178-d6b5-fafd7d3f3ff0",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "Feature Packs_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   }, {     "additionalAttributes" : {       "parentSpec" : "9d76a6d8-6e3b-2bf5-0734-c3b6c1b5ad97"     },     "attributes" : {       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment",       "__targetSystem" : "FULFILMENT",       "VoicePlan" : "Complete Premium",       "id" : "",       "CustomerFacingServiceId" : "",       "Number" : [ {         "schemaId" : "6958a9b0-b4b4-d8ed-aee0-95809f71fae5",         "attributes" : {           "FNN" : "1111111111",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "LE"         }       }, {         "schemaId" : "2ed10109-e96c-ea34-9d08-fa32974bd41c",         "attributes" : {           "FNN" : "2222222222",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9b532ac9-1b5b-52bf-77b9-09c56dd32a78",         "attributes" : {           "FNN" : "3333333333",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "aad74447-1fb5-aff3-8adb-be166daac227",         "attributes" : {           "FNN" : "8282345567",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "80ffa07e-2a80-e2af-d583-eef7447dcdcb",         "attributes" : {           "FNN" : "8282345566",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "ba722761-6c24-ee82-7d58-d24fe7f6029e",         "attributes" : {           "FNN" : "8282345568",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "9587c470-3aa0-e25d-b8fc-187aa7055459",         "attributes" : {           "FNN" : "8282345569",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "796fc1d9-c440-bff5-f239-6b73a2f74cc8",         "attributes" : {           "FNN" : "8282345516",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "5324f75d-cbf8-86a1-43b1-e356b47fd71d",         "attributes" : {           "FNN" : "8282345526",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "97b1603a-1999-1aea-c017-f110bc34cdd2",         "attributes" : {           "FNN" : "8282345536",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       }, {         "schemaId" : "8f5a5678-1f44-c310-a540-bf66c83389ee",         "attributes" : {           "FNN" : "8282345546",           "rangeFrom" : null,           "rangeTo" : null,           "status" : "RESERVED",           "listCode" : "No Entry Line"         }       } ]     },     "code" : "DMCAT_ProductSpecification_000313_Fulfilment",     "description" : "",     "endDate" : "",     "guid" : "7b1b0cd6-0684-96e6-54cf-69387aad4589",     "includeBilling" : false,     "instanceId" : "",     "metadata" : { },     "name" : "UC Numbers_Fulfilment",     "productConfigurationId" : "a3T2O000000HTzTUAW",     "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313",     "startDate" : "",     "status" : "In Progress",     "version" : "1"   } ] }');                    
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = servSIM.Id;
        insert att2;
          
        /*csord__Order__c order=[select id from csord__Order__c where name='TestOrder'][0];
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        parentOrchProcess.Order__c= order.Id;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        
                                 
        Test.startTest();
        
                List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();
TransientDataDTO transientData = new TransientDataDTO();
         
         TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = 'DMCAT_Offer_000303';
                            dataDTO.specCode = 'DMCAT_ProductSpecification_000263_Fulfilment';
                            dataDTO.specGUID = 'dc952b75-53c0-dfa4-e296-2e1d4ce42cfd';
                            dataDTO.changeType = 'Modify';
                            transDataDTOList.add(dataDTO);
                        transientData.dataDTOList =   transDataDTOList;  
        GenerateTransientDataHandler dataHandler=new GenerateTransientDataHandler();
        List<CSPOFA__Orchestration_Step__c> result=dataHandler.process(steps);
        GenerateTransientDataHandler.prepareTransientDataForOrder(OrderIds);
        GenerateTransientDataHandler.insertAttachmentOnOrder(order.id,transientData);
        Test.stopTest();
        system.assertEquals(result[0].CSPOFA__Message__c,'Custom Step succeeded');*/
    }
    @isTest
    static void poulateTransientForScenarioTypeTest(){
        csord__Order__c order=[select id from csord__Order__c where csord__Customer_Order_Number__c='76543875' AND 
        name='TestOrder'][0];
        
        Account acc=[SELECT id,Name from Account WHERE Name='Testa ccount3' limit 1];
        DeviceReplacementController.shellProductDetailsWrapper shellProduct = new DeviceReplacementController.shellProductDetailsWrapper();
        
        Contact con = [SELECT id from Contact WHERE AccountId =: acc.id];
        cscrm__Address__c address =[Select id,cscrm__Account__c FROM cscrm__Address__c WHERE cscrm__Account__c =: acc.id];
         
        
        shellProduct.replacedDeviceID='234435345345';
        shellProduct.replacementDeviceSKU = '34334534';
        shellProduct.replacementDeviceManufacturer = 'Apple';
        shellProduct.replacementDeviceModel = 'Apple 7 68GB';
        shellProduct.telstraNowCaseID = 'TNC1234';
        shellProduct.recoveryMethod = 'test';
        shellProduct.deviceCareCaseID = '534534345';
        shellProduct.returnReason ='warrenty';
        // Fetching data from metaDataType to populate on order request and order.
            csord_Order_type__mdt orderMetaData=[SELECT id,csord_Identification__c,csord_Order_Type__c,
                                                 csord_Product_Type__c,csord_Status2__c,csord_Module_Name__c,
                                                 csord_Module_Version__c,csord_Process_Status__c FROM 
                                                 csord_Order_type__mdt LIMIT 1];
            
            // New  Order Request
            csord__Order_Request__c newOrderRequest=new csord__Order_Request__c();
            newOrderRequest.csord__Request_DateTime__c=Datetime.now();
            if(orderMetaData != null){
                newOrderRequest.csord__Module_Name__c=orderMetaData.csord_Module_Name__c;
                newOrderRequest.csord__Module_Version__c=orderMetaData.csord_Module_Version__c;
                newOrderRequest.csord__Process_Status__c=orderMetaData.csord_Process_Status__c;
            }
            insert newOrderRequest;
            
            String orderName = label.Device_Replacement +'_' + ('0' + String.valueOf(Date.today().day())).right(2) + ( '0' + String.valueOf(Date.today().month())).right(2) + Date.today().year() + '_' + String.valueOf(System.now().time()).left(8);
            csord__Order__c newOrder=new csord__Order__c();
            newOrder.csord__Account__c=acc.id;
            newOrder.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted').getRecordTypeId();
            if(orderMetaData != null){
                newOrder.csord__Status2__c=orderMetaData.csord_Status2__c;
                newOrder.csord__Order_Type__c=orderMetaData.csord_Order_Type__c;
                newOrder.csord__Identification__c=orderMetaData.csord_Identification__c;
                newOrder.csord__Product_Type__c=orderMetaData.csord_Product_Type__c;
            }
            newOrder.csord__Start_Date__c=Date.today();
            newOrder.Name=orderName;
            newOrder.csord__Order_Request__c=newOrderRequest.id;
            newOrder.Scenario_Type__c=label.Device_Replacement;
            newOrder.OwnerId=UserInfo.getUserId();
            insert newOrder;

            csord__Subscription__c subscription = [SELECT id,Name,csord__Account__c,csord__Order__c,Billing_Account__c 
                                                    FROM csord__Subscription__c WHERE csord__Order__c=:order.id limit 1];
                                                    
            csord__Subscription__c newSubscription=new csord__Subscription__c();
            newSubscription.csord__Order__c=newOrder.id;
            newSubscription.csord__Status__c=Constants.Subscription_Status;
            newSubscription.csord__Identification__c= newOrder.csord__Identification__c;
            newSubscription.Name=subscription.Name;
            newSubscription.csord__Account__c=subscription.csord__Account__c;
            newSubscription.Billing_Account__c=subscription.Billing_Account__c;
            newSubscription.recoveryMethod__c=shellProduct.recoveryMethod;
            newSubscription.returnReasonType__c=shellProduct.returnReason;
            newSubscription.devicecareCaseId__c=shellProduct.deviceCareCaseID;
            newSubscription.TNowCaseId__c=shellProduct.telstraNowCaseID;
            Insert newSubscription; 
            set<Id> serviceIdSet=new set<Id>();
            Map<String,String>  oldSpecAttributeMap = new Map<String,String>();
            //Update Old Service Status to "Replaced Closed" .
            List<csord__Service__c> oldServiceList=new List<csord__Service__c>();
            for(csord__Service__c oldService:[Select id,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csord__Status__c,csord__Order__c,csord__Subscription__c 
                                              from csord__Service__c where csord__Order__c= :subscription.csord__Order__c 
                                              AND csord__Subscription__c =:subscription.id]){
                                                  serviceIdSet.add(oldService.id);
                                                  oldService.csord__Order__c=newOrder.id;
                                                  oldServiceList.add(oldService);
                                              }
            
            insert new EnvironmentVariable__c(Name = 'EnableHV',Value__c ='false');
            
            /*Modify service spec of old service and get GUID of replaced device */
          
                DeviceReplacementController.modifyOldServiceSpecsStatus(serviceIdSet,oldSpecAttributeMap, shellProduct);
            Asset assetRecord = new Asset();
            assetRecord.AssetID__c= '456456456456';
            assetRecord.Status = 'Active';
            assetRecord.OfferID__c = '4534543';
            assetRecord.accountId= acc.id;
            assetRecord.name= shellProduct.replacementDeviceManufacturer+' '+shellProduct.replacementDeviceModel;
        //Zeeshan
            
        insert assetRecord;
        /*  DeviceReplacementController.modifyOldServiceSpecsStatus(serviceIdSet,oldSpecAttributeMap, shellProduct);
            Asset replaceAssetRecord = new Asset();
            replaceAssetRecord.AssetID__c= '456456456499';
            replaceAssetRecord.Status = 'InActive';
            replaceAssetRecord.OfferID__c = '4534599';
            replaceAssetRecord.accountId= acc.id;
            replaceAssetRecord.name= shellProduct.replacementDeviceManufacturer+' '+shellProduct.replacementDeviceModel;   
        replaceAssetRecord.csordtelcoa__Replaced_Asset__c =null;
        replaceAssetRecord.Subscription__c = subs.Id;
        //replaceAssetRecord.Subscription__r.csord__Order__c=newOrder.id;
        replaceAssetRecord.csord__Order__r.Scenario_Type__c=label.Device_Replacement;
        insert replaceAssetRecord;*/
            //New services for replaced device subscription 
            csord__Service__c newService=DeviceReplacementController.createNewService(newOrder,newSubscription.Id,shellProduct,address.id,con.id);
            
              //Service specs generation for new replaced device
              //EDGE-150372. Dheeraj Bhatt. Added oldServiceList.
            GenerateServiceSpecs base=DeviceReplacementController.generateServiceSpecification(newService.Id,
            newSubscription.Id,shellProduct,oldSpecAttributeMap,oldServiceList);
            if(base !=null){
                String serviceSpecification=JSON.serialize(base);
                Attachment   newServiceSpecificationAttachment = new Attachment(  
                    Name = 'ServiceSpecifications.json',
                    body = Blob.valueOf(serviceSpecification),
                    parentId = newService.id
                );
               if(newServiceSpecificationAttachment!=null){
                insert newServiceSpecificationAttachment;
               }
            }
            if(oldServiceList.size() > 0){
                update oldServiceList;
            }
            
            //Updating Old subscription order Id to New order Id 
            if(subscription != NULL){
                subscription.csord__Order__c=newOrder.id;
                update subscription;
            }
          Test.startTest();
            GenerateTransientDataHandler.poulateTransientForScenarioType(newOrder);
            //system.assertEquals(label.Device_Replacement,newOrder.Scenario_Type__c); 
       
            Test.stopTest();
        system.assertEquals(label.Device_Replacement,newOrder.Scenario_Type__c); 
        
    }
    
                             
/*********************************************************************************************************************************
* User story#      :EDGE-100986
* Method Name      :   getReplacedAssetId
*Purpose           :   To fetch the old asset id from the new asset associated with the generated order.
* Modified by      :Zeeshan
**********************************************************************************************************************************/                                 
    //100986                             
    @isTest
    static void getReplacedAssetIdTest(){ 
        
        Account acc = [select id from Account];
        system.debug('--->Account for replaced scenario: '+acc);
        Opportunity Opp = [select id from Opportunity];
        system.debug('--->Opportunity for replaced scenario: '+acc);
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        insert offer;
        //Old order
            csord__Order__c ord = new csord__Order__c();
            ord.name = 'TestOldOrder';
            ord.csord__Order_Type__c='Order';
            //ord.csord__Order_Request__c = ordReq.Id;
            ord.csord__Identification__c = 'test identification';
            ord.csord__Account__c=acc.Id;
            ord.csord__Start_Date__c=Date.today();
            ord.Telstra_Committed_Date__c=Date.today();
            ord.csord__Customer_Order_Number__c='ON00041100';
            ord.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted').getRecordTypeId();
            ord.csordtelcoa__Opportunity__c =opp.id;
        //Basket ID
            ord.csord__Identification__c ='Order_a3Q2O0000009vVWUAY';
            //ord.Scenario_Type__c='Device Replacement';
            insert ord;
            system.debug('Old order id --->'+ord);
        
        //New order
            
            csord__Order__c ordNew = new csord__Order__c();
            ordNew.name = 'TestOrderNew';
            //ord.csord__Order_Request__c = ordReq.Id;
            ordNew.csord__Identification__c = 'test identification';
            ordNew.csord__Account__c=acc.Id;
            ordNew.csord__Start_Date__c=Date.today();
            ordNew.Telstra_Committed_Date__c=Date.today();
            ordNew.csord__Customer_Order_Number__c='76543007';
            ordNew.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted').getRecordTypeId();
            ordNew.csordtelcoa__Opportunity__c =opp.id;
            ordNew.csord__Identification__c ='Order_456';
            ordNew.Scenario_Type__c='Device Replacement';
            insert ordNew;
        
        //End new order
        
        //New Subscription
            csord__Subscription__c subs=new csord__Subscription__c();
            subs.name  = 'testSubscriptions';
            subs.csord__Identification__c = 'testIdentitys';
            subs.csord__Order__c = ord.Id;
            subs.csord__status__c = 'In progress';
            subs.MarketableOffer__c =offer.id;
            insert subs;
            system.debug('Subscription: '+subs);
            //Create Assets EDGE 100986
            system.debug('--->Opp: '+Opp);
            Asset assetRecordNew = new Asset();
            assetRecordNew.name= 'TestAsset';
            ///assetRecord.AssetID__c= '4564564564007';
            //assetRecord.Status = 'InActive';
            //assetRecord.OfferID__c = '4534500';
            assetRecordNew.accountId= acc.id;
            //assetRecord.csordtelcoa__Replaced_Asset__c = assetRecord.id;
            //assetRecord.Subscription__c =subs.id;
            insert assetRecordNew;
        
            Asset assetRecord2 = new Asset();
            assetRecord2.AssetID__c= '4564564564042';
            assetRecord2.Status = 'InActive';
            assetRecord2.OfferID__c = '4534553';
            assetRecord2.accountId= acc.id;
            assetRecord2.csordtelcoa__Replaced_Asset__c = assetRecordNew.id;
            assetRecord2.Subscription__c = subs.id ;
            //assetRecord2.Subscription__r.csord__Order__c = ord.id;
            assetRecord2.name= 'TestAsset2';
            
            insert assetRecord2;
            system.debug('--->assetRecord2'+assetRecord2);

        test.startTest();
        id orderRecID = GenerateTransientDataHandler.getReplacedAssetId(ord.id);
        system.debug('orderRecID>>>'+orderRecID);
        test.stopTest();
        system.assertEquals(orderRecID,null);
    }
  //EDGE-125552 :method added to cover SIMReplacement scenariotype                               
   @isTest
    static void processTestSIMReplacement(){
        csord__Order__c order=[select id from csord__Order__c where name='TestOrderSIM'][0];
        List<Id> orderID = new List<Id> {order.id};
        
       Test.startTest();
         GenerateTransientDataHandler.prepareTransientDataForOrder(orderID);
     Test.stopTest();
        system.assertNotEquals(null,orderID);
        
        
    }
}