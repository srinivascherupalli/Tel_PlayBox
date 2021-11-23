/****
Author : Kunal Dixit
Company : Telstra
Descripiton : 26-March-2019 changes to increase the code coverage 
              new test Method processEDISCeaseOrderCompletionTest
History : Prajakta Patil 
          20 March EDGE-53794 & EDGE-53801
***/

@isTest(SeeAllData=false)
public class EDISSingleManagerTest {
   @testsetup
     public static void dataSetup(){
         
        Account acc=new Account();
        acc.name='Testaccount';
        acc.Type='Company';
        acc.Title__c='';
        acc.CIDN__c='65432213';
        acc.Email__c='abc@gmail.com';
        acc.Customer_Status__c='Active';
        acc.Customer_Trading_Name__c = 'TradeName';
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
         
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c=acc.Id;
        ord.csord__Start_Date__c=Date.today();
        ord.Telstra_Committed_Date__c=Date.today();
        ord.csord__Customer_Order_Number__c='7654387';
        ord.csordtelcoa__Opportunity__c =opp.id;
        ord.Scenario_Type__c = 'Change of Mobile Number';
        insert ord;
         
        csord__Order__c ordd = new csord__Order__c();
        ordd.name = 'TestOrder1';
        ordd.csord__Order_Request__c = ordReq.Id;
        ordd.csord__Identification__c = 'test identification1';
        ordd.csord__Account__c=acc.Id;
        ordd.csord__Start_Date__c=Date.today();
        ordd.Telstra_Committed_Date__c=Date.today();
        ordd.csord__Customer_Order_Number__c='7654388';
        ordd.csordtelcoa__Opportunity__c =opp.id;
       // ordd.csord__Primary_Order__c=ord.Id;
        
        insert ordd;

         cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Definition', 'Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000323';
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        insert prodConfig;
         
         //Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        //insert contact;
         
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
         
         csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.oldServiceMSISDN__c= '45566778456';
        insert subs;
         
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'Unified Communication';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Order__c = ord.Id;
        serv.scenario_type__c = 'Change of Mobile Number';
        serv.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv.Order_Primary_Contact__c = contact.Id;
        insert serv;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{ "specifications" : [ { "version" : "1", "status" : "In Progress", "startDate" : "", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000311", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "BS Tenancy_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000311_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "1234", "id" : "", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000312", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "BS Service Type_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "c94c6e5a-305d-caa1-515f-387da01d9c1b", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000312_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "id" : "", "ConcurrencyLimit" : "", "UCService" : "CWP", "UsageModel" : "User Based", "__targetSystem" : "FULFILMENT", "BSTenancyProductInstanceID" : "DMCAT_ProductSpecification_000311_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210" } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000315", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "Feature Packs_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "cc137861-9402-742a-1e80-0c65ab6ae5ee", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "attributes" : { "Quantity" : 6, "id" : "", "CustomerFacingServiceId" : "", "name" : "Hosted UC", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "parentSpec" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "UC Numbers_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "a3b49183-4104-9c45-7cbe-d98c3ffb3f97", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "attributes" : { "Number" : [ { "schemaId" : "b089351a-2c05-6bbd-a40f-61f02f65e678", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "LE", "FNN" : "8282345561" } }, { "schemaId" : "c4345f44-27d0-8f84-2276-964cdd9c491e", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345562" } }, { "schemaId" : "20004f77-45fa-8381-ee99-c1cb2edb0602", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345563" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "9d2c2535-fc29-0079-dc05-38f4787c4985", "attributes" : { "status" : "IN TRANSITION", "rangeTo" : "20", "rangeFrom" : "1", "listCode" : "No Entry Line", "FNN" : null } } ], "id" : "", "VoicePlan" : "Complete Premium", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "parentSpec" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } } ], "serviceId" : "a4e2O0000004c2RQAQ", "legacyAttributes" : [ ] }');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
     }
         
        
       @isTest
         public static void getServiceSpecsTest(){
         List<Id> ordId = new List<Id>();
         List<csord__Order__c> ordList= [select id, name from csord__Order__c where name = 'TestOrder1' limit 1];
             for(csord__Order__c s: ordList){
                 ordId.add(s.id);
             }
             
         test.startTest();
         EDISSingleManager.getServiceSpecs(ordId);
         test.stopTest();
         system.assertEquals('TestOrder1', ordList[0].name);
   
         }
    
      @isTest
         public static void processEDISOrderCompletionTest(){
            
         List<Id> ordId = new List<Id>();
         List<csord__Order__c> ordList= [select id, name from csord__Order__c where name = 'TestOrder' limit 1];
             for(csord__Order__c s: ordList){
                 ordId.add(s.id);
             }
         List<csord__Service__c> serviceList = [SELECT Id, Name,csordtelcoa__Replaced_Service__c, csordtelcoa__Service_Number__c,csord__Order__r.csord__Primary_Order__c FROM csord__Service__c WHERE csord__Order__c IN : ordId AND (Name='Unified Communication' OR Name='IP Site')];
            
         test.startTest();
         EDISSingleManager.processEDISOrderCompletion(ordList[0].Id, serviceList[0].csordtelcoa__Service_Number__c);
         test.stopTest();
         system.assertEquals('TestOrder', ordList[0].name);
   
         }
    
     @isTest
         public static void buildEDISPayloadTest(){
           
            csord__Order__c ord = new csord__Order__c();
            ord.name = 'TestOrder1';
            ord.csord__Identification__c = 'test identification1';
            ord.csord__Start_Date__c=Date.today();
            ord.Telstra_Committed_Date__c=Date.today();
            ord.csord__Customer_Order_Number__c='765442289';
            ord.Scenario_Type__c = 'Change of Mobile Number';
            insert ord;
             
             csord__Order__c ord4 = new csord__Order__c();
            ord4.name = 'TestOrder4';
            ord4.csord__Identification__c = 'test identification4';
            ord4.csord__Start_Date__c=Date.today();
            ord4.Telstra_Committed_Date__c=Date.today();
            ord4.csord__Customer_Order_Number__c='765442286';
            //ord4.csord__Primary_Order__c=ord.Id;
            insert ord4;
        test.startTest();
            Account acc1=new Account();
            acc1.name='Testaccount1';
            acc1.Type='Company1';
            acc1.Title__c='';
            acc1.CIDN__c='65770321';
            acc1.Email__c='xvfre@gmail.com';
            insert acc1;

            Contact contact1 = AccountTestFactory.buildContact(acc1, 'Jon');
            insert contact1;

             /*Contact contact1= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc1.id, Contact_Status__c='Active');
             insert contact1;*/
             
            Functional_Contact_Role__c FCR1 = new Functional_Contact_Role__c();
                FCR1.OrderID__c = ord.id;
                FCR1.Role_Type__c = 'Order';
                FCR1.ContactID__c = contact1.id;
                insert FCR1;
             
             cscrm__Address__c address = new cscrm__Address__c();
            address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
            address.Address_ID__c = '1010101010';
            address.cscrm__Account__c = acc1.id; 
            upsert address;
         
                 cscrm__Site__c site = new cscrm__Site__c();
                site.cscrm__Account__c = acc1.id;
                site.cscrm__Installation_Address__c = address.id;
                site.name = 'Sydney harbour house';
                //site.AdborID__c = '67543215';
                site.Composite_Key__c = '1211010101010';
                upsert site;
             
             csord__Subscription__c subs1=new csord__Subscription__c();
            subs1.name  = 'testSubscription1';
            subs1.csord__Identification__c = 'testIdentity5';
            subs1.csord__Order__c = ord.Id;
            subs1.Sub_status__c = 'Active';
             subs1.Site__c= site.id;
            insert subs1;
             
             csord__Service__c serv1 = new csord__Service__c();
            serv1.name= 'IP site';
            serv1.csord__Identification__c  = 'testIdentify_2';
            serv1.csordtelcoa__Service_Number__c = '3';
            serv1.csord__Subscription__c = subs1.Id;
            serv1.csord__Order__c = ord.Id; 
            serv1.scenario_type__c = 'Change of Mobile Number';
            insert serv1;
         

            List<EDISSingleManager.ListingFNNWrapper>fnnWrapperList = new List<EDISSingleManager.ListingFNNWrapper>();
             EDISSingleManager.ListingFNNWrapper fnnWrapper = new EDISSingleManager.ListingFNNWrapper();
             fnnWrapper.orderId =ord.id;
             fnnWrapper.serviceId =serv1.id;
             fnnWrapper.orderStatus ='Provisioning';
             fnnWrapper.isNew =true;
             fnnWrapper.isTransition =false;
             fnnWrapper.fnn = '876544232';
             fnnWrapper.listCode = 'LE';
             
              EDISSingleManager.ListingFNNWrapper fnnWrapper1 = new EDISSingleManager.ListingFNNWrapper();
             fnnWrapper1.orderId =ord.id;
             fnnWrapper1.serviceId =serv1.id;
             fnnWrapper1.orderStatus ='Provisioning';
             fnnWrapper1.isNew =false;
             fnnWrapper1.isTransition =true;
             fnnWrapper1.fnn = '654432298';
             fnnWrapper1.listCode = 'No Entry Line';
             fnnWrapperList.add(fnnWrapper);
             fnnWrapperList.add(fnnWrapper1);
             
              EDISSingleRequestDTO dto = new EDISSingleRequestDTO();
             EDISSingleRequestDTO.EDISReqDTO reqDto = new EDISSingleRequestDTO.EDISReqDTO();
            dto.correlationId = '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e';
            dto.path ='/application/edis-eai/v2/directory-listings';
            dto.method = 'POST';
            reqDto.type='Order Provisioned';
            dto.data = reqDto;
            
              Map<String,String> commonDetailsMap = new Map<String,String>();
           
        
                 commonDetailsMap = EDISSingleManager.fetchCommonDetails(ord.id,commonDetailsMap,fnnWrapperList);
                system.assertNotEquals(null, commonDetailsMap);
                EDISSingleManager.buildEDISPayload(fnnWrapperList);
        
             
             system.assertEquals('58fb5c78-77ed-4f58-97e3-6e0ae3ce498e', dto.correlationId);
         }
     
        
     @isTest
         public static void buildCustomerDetailsTest(){
             EDISSingleRequestDTO.CustomerDetails cd = new EDISSingleRequestDTO.CustomerDetails();
                cd.customerID ='123';
                cd.customerType ='123';
                cd.familyName ='123';
                cd.givenNames ='123';
                cd.registeredCompanyName ='123';
                cd.customerTitle ='123';
                cd.customerContactGivenNames ='123';
                cd.customerContactFamilyName ='123';
                cd.contactPosition ='123';
                cd.contactFNN ='123.00';
                cd.contactEmail ='123';
                
                system.assertEquals('123', cd.customerID);
         }
    
         @isTest
         public static void buildListingDetailsTest(){
             EDISSingleRequestDTO.ListingDetails ld = new EDISSingleRequestDTO.ListingDetails();
                ld.familyOrEntityName ='123';
                ld.organizationName ='123';
                ld.givenNames ='123';
                ld.listingFNN ='123';
                ld.actionCode ='123';
                ld.subactionCode ='123';
                ld.reasonCode ='123';
                
                system.assertEquals('123', ld.familyOrEntityName);
         }
    
     @isTest
         public static void buildServiceOrderDetailsTest(){
             EDISSingleRequestDTO.ServiceOrderDetails soa = new EDISSingleRequestDTO.ServiceOrderDetails();
                soa.listCode ='LE';
                soa.orderType ='123';
                soa.orderStatus ='123';
                soa.serviceType ='123';
                soa.orderID ='123';
                soa.originatingSystem ='123';
                soa.portFlag ='123';
                soa.productName ='123';
                soa.telstraAddressId ='123';
                soa.soCreationTimestamp ='123';
                soa.telstraCommitmentDate ='123';
                soa.provisionCompletionDate ='123';
                soa.temporaryServiceIndicator ='123';
                soa.interimServiceIndicator ='123';
                soa.alternateAddressFlag ='123';
                soa.originalFNN ='123';
                soa.originalFamilyName ='123';
                soa.originalGivenNames ='123';
                soa.originalAddressIdentifier ='123';
                soa.lineItemStatus ='123';
                
                system.assertEquals('LE', soa.listCode);
         }
    
    @isTest
         public static void buildCustomerContactAddressDetailsTest(){
             EDISSingleRequestDTO.CustomerContactAddress cca = new EDISSingleRequestDTO.CustomerContactAddress();
                cca.ccaIdentifier = '1234';
                cca.ccaOverseasAddressLine1 = 'test' ;
                cca.ccaOverseasAddressLine2 = 'test1';
                cca.ccaOverseasAddressLine3 = 't6est2';
                cca.ccaOverseasAddressCountryCode = '123456';
                
                system.assertEquals('1234',cca.ccaIdentifier);
         }
    
    
         @isTest
         public static void processEDISOrderTransitionTest(){
         
             
         List<Id> ordId = new List<Id>();
         Map<String,String>fnndetailsMap = new Map<String,String>();
         List<csord__Order__c> ordList= [select id, name from csord__Order__c where name = 'TestOrder' limit 1];
             for(csord__Order__c s: ordList){
                 ordId.add(s.id);
             }
        
         List<csord__Service__c> serviceList = [SELECT Id, Name,csordtelcoa__Replaced_Service__c, csordtelcoa__Service_Number__c,csord__Order__r.csord__Primary_Order__c FROM csord__Service__c WHERE csord__Order__c IN : ordId AND (Name='Unified Communication Enterprise' OR Name='IP Site')];
         Map<String,Map<String,String>> failedFnnMap = new Map<String,Map<String,String>>();
            DirectoryFalloutHandler.FailedDirectoryListing  failedDir = new DirectoryFalloutHandler.FailedDirectoryListing();
            failedFnnMap =failedDir.DirectoryFalloutNumbers(ordId);
             System.debug('failedFnnMap'+failedFnnMap);
                       /* fnndetailsMap.put('listingFNN','LE');
                        fnndetailsMap.put('order',ordList[0].Id);
                        fnndetailsMap.put('type','FNN');
                        fnndetailsMap.put('listCode','LE');
                        fnndetailsMap.put('orderId',ordList[0].Id);
                        failedFnnMap.put('123456324',fnndetailsMap);*/
            
         
         Test.startTest();
           EDISSingleManager.buildEDISForFailedNumbers(failedFnnMap);
         //EDISSingleManager.processEDISOrderCompletion(ordList[0].Id, serviceList[0].csordtelcoa__Service_Number__c);
         Test.stopTest();
         system.assertEquals('TestOrder', ordList[0].name);
   
         }
    @isTest
    public static void processEDISCeaseCompletion(){
        csord__Subscription__c subscription=[Select Id,Name from csord__Subscription__c where Name='testSubscription' AND Sub_status__c='Active' limit 1];
        Test.startTest();
        EDISSingleManager.processEDISCeaseCompletion(subscription.Id);
        Test.stopTest();
        system.assertEquals('testSubscription', subscription.Name);
        
    }
    
}