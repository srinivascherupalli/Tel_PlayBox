@isTest
public class OrderEmailServiceHelperTest {
    
  @isTest  public static void dataSetup(){
        
        // Account
        Account acc=new Account();
        acc.name='Testaccount';
        acc.Type='Company';
        acc.Title__c='';
        acc.CIDN__c='65432213';
        acc.Email__c='abc@gmail.com';
        acc.Customer_Status__c='Active';
        insert acc;
        
        //basket details
        
        //Opportunity
        Opportunity opp = new Opportunity();
        opp.name='TestOpportunity';
        opp.StageName='Closed Won';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'NewOrderTest';
        testBasket.cscfga__Opportunity__c = opp.Id;
        insert testBasket;
        
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.Type__c = 'New'; 
        insert testConfig1;
        
        Contact orderRequestor = AccountTestFactory.buildContact(acc, 'Contact');
        orderRequestor.FirstName = 'Test';
        orderRequestor.Pref_Comm_Method__c='eMail';
        orderRequestor.MobilePhone='+61123456789';
        orderRequestor.email='test@gmail.com';
        orderRequestor.AccountId = acc.id;
        insert orderRequestor;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=orderRequestor.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        insert ocr;
        
        csord__Order_Request__c ordRequest = ProductTestFactory.buildOrderRequest();
        insert ordRequest;
        
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'primaryOrder';
        ord.csord__Order_Request__c = ordRequest.Id;
        ord.csord__Identification__c = 'testIdentification';
        ord.csord__Account__c=acc.Id;
        ord.csord__Start_Date__c=Date.today();
        ord.Telstra_Committed_Date__c=Date.today();
        ord.csord__Customer_Order_Number__c='7654387';
        ord.csordtelcoa__Opportunity__c =opp.id;
        ord.csord__Status2__c='Complete';
        insert ord;
        
        csord__Order__c secOrd = new csord__Order__c();
        secOrd.name = 'SecondaryOrder';
        secOrd.csord__Order_Request__c = ordRequest.Id;
        secOrd.csord__Identification__c = 'test identification1';
        secOrd.csord__Account__c=acc.Id;
        secOrd.csord__Start_Date__c=Date.today();
        secOrd.Telstra_Committed_Date__c=Date.today();
        secOrd.csord__Customer_Order_Number__c='7654388';
        secOrd.csordtelcoa__Opportunity__c =opp.id;
        secOrd.csord__Primary_Order__c=ord.Id;
        insert secOrd;
        
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
        FCR.ContactID__c =orderRequestor.id;
        insert FCR;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        insert subs;
        
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'IP Site';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csord__Order_Request__c = ordRequest.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Order__c = secOrd.Id;
        
        insert serv;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{ "specifications" : [ { "version" : "1", "status" : "In Progress", "startDate" : "", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000311", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "BS Tenancy_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000311_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "id" : "", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000312", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "BS Service Type_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "c94c6e5a-305d-caa1-515f-387da01d9c1b", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000312_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "id" : "", "ConcurrencyLimit" : "", "UCService" : "CWP", "UsageModel" : "User Based", "__targetSystem" : "FULFILMENT", "BSTenancyProductInstanceID" : "DMCAT_ProductSpecification_000311_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210" } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000315", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "Feature Packs_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "cc137861-9402-742a-1e80-0c65ab6ae5ee", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "attributes" : { "Quantity" : 6, "id" : "", "CustomerFacingServiceId" : "", "name" : "Hosted UC", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "parentSpec" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "UC Numbers_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "a3b49183-4104-9c45-7cbe-d98c3ffb3f97", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "attributes" : { "Number" : [ { "schemaId" : "b089351a-2c05-6bbd-a40f-61f02f65e678", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "LE", "FNN" : "8282345561" } }, { "schemaId" : "c4345f44-27d0-8f84-2276-964cdd9c491e", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345562" } }, { "schemaId" : "20004f77-45fa-8381-ee99-c1cb2edb0602", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345563" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "9d2c2535-fc29-0079-dc05-38f4787c4985", "attributes" : { "status" : "IN TRANSITION", "rangeTo" : "20", "rangeFrom" : "1", "listCode" : "No Entry Line", "FNN" : null } } ], "id" : "", "VoicePlan" : "Complete Premium", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "parentSpec" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } } ], "serviceId" : "a4e2O0000004c2RQAQ", "legacyAttributes" : [ ] }');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        system.assertEquals('Complete', ord.csord__Status2__c);
    }
    
  
}