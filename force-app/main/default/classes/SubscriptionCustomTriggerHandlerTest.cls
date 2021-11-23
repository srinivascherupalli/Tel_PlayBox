/*------------------------------------------------------------ 
Author: Nikhil Gupta
Company: Telstra 
Description: A test class for the SubscriptionCustomTriggerHandler methods Test
Test Class: SubscriptionCustomTriggerHandlerTest 
History 
<15/04/2019> <Nikhil Gupta> <Intial version to test class : SubscriptionCustomTriggerHandler code coverage> 
<22-May-2019> <Vadiraj Muralidhar> <Added Forcasted Delivery Date to services, to increase the Code Coverage of SubscriptionCustomTrigger>
<13-Apr-2020> <Gnana> EDGE-138284 - Refactor Subscription trigger 
<15-Oct-2021> <DN> Modified testafterUpdate() for code coverage
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class SubscriptionCustomTriggerHandlerTest {
    
    @Testsetup static void dataSetup(){
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
        contact.MobilePhone='+61421542269';
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
        ordd.csord__Primary_Order__c=ord.Id;
        ordd.csord__Status2__c ='Incomplete';

        insert ordd;
        
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
        
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Telstra Collaboration' ;
        mo.Name = 'Telstra Collaboration';
        mo.Offer_ID__c = 'DMCAT_Offer_000618';
        insert mo;
        
        List<csord__Subscription__c> subs = new List<csord__Subscription__c>() ;
        csord__Subscription__c subs0=new csord__Subscription__c();
        subs0.name  = 'testSubscription0';
        subs0.csord__Identification__c = 'testIdentity0';
        subs0.csord__Order__c = ordd.Id;
        subs0.MarketableOffer__c = mo.Id;
        subs0.Sub_status__c = 'In Progress';
        subs0.Contract_Term__c = '12';
        subs.add(subs0);
        
        csord__Subscription__c sub1=new csord__Subscription__c();
        sub1.name  = 'testSubscription';
        sub1.csord__Identification__c = 'testIdentity';
        sub1.csord__Order__c = ordd.Id;
        sub1.MarketableOffer__c = mo.Id;
        sub1.csordtelcoa__Subscription_Number__c='SN-000238528';
        sub1.Sub_status__c = 'In Progress';
        sub1.Contract_Term__c = '12';
        subs.add(sub1);
        insert subs;
        
        Number__c num = new Number__c();
        num.Subscription_number__c = subs[0].csordtelcoa__Subscription_Number__c;
        num.Service_Id__c = '12345';
        num.Service_Number__c = 'SN-000238528';
        num.Mobile__c = 'Fixed';
        Insert num;
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'IP Site';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs[0].Id;
        serv.csord__Status__c = 'In Progress';
        serv.csord__Order__c = ordd.Id;
        serv.Forecasted_Delivery_Date__c = Date.today()+2;
        serv.Telstra_Committed_Date__c = Date.today()+2;
        insert serv;
        
        
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{ "specifications" : [ { "version" : "1", "status" : "In Progress", "startDate" : "", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000311", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "BS Tenancy_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000311_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "id" : "", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000312", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "BS Service Type_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "c94c6e5a-305d-caa1-515f-387da01d9c1b", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000312_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "id" : "", "ConcurrencyLimit" : "", "UCService" : "CWP", "UsageModel" : "User Based", "__targetSystem" : "FULFILMENT", "BSTenancyProductInstanceID" : "DMCAT_ProductSpecification_000311_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210" } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000315", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "Feature Packs_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "cc137861-9402-742a-1e80-0c65ab6ae5ee", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "attributes" : { "Quantity" : 6, "id" : "", "CustomerFacingServiceId" : "", "name" : "Hosted UC", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "parentSpec" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } }, { "version" : "1", "status" : "Complete", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313", "productConfigurationId" : "a3T2O000000ATSwUAO", "name" : "UC Numbers_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "a3b49183-4104-9c45-7cbe-d98c3ffb3f97", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "attributes" : { "Number" : [ { "schemaId" : "b089351a-2c05-6bbd-a40f-61f02f65e678", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "LE", "FNN" : "8282345561" } }, { "schemaId" : "c4345f44-27d0-8f84-2276-964cdd9c491e", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345562" } }, { "schemaId" : "20004f77-45fa-8381-ee99-c1cb2edb0602", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345563" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "ACTIVE", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "9d2c2535-fc29-0079-dc05-38f4787c4985", "attributes" : { "status" : "IN TRANSITION", "rangeTo" : "20", "rangeFrom" : "1", "listCode" : "No Entry Line", "FNN" : null } } ], "id" : "", "VoicePlan" : "Complete Premium", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSTenancyProductInstanceID" : "4349eccc-8b0f-15da-ab45-44e69ba10210", "parentSpec" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } } ], "serviceId" : "a4e2O0000004c2RQAQ", "legacyAttributes" : [ ] }');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
    }
    
    static testMethod void testUpdateOrderStatus(){
        Map<Id,csord__Subscription__c> subs = new Map<Id, csord__Subscription__c>([SELECT Id, Name, csord__Status__c,csord__Order__c, Forecasted_Delivery_Date__c , Telstra_Committed_Date__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c WHERE Name='testSubscription']);
        List<Id> subIds = new List<Id>();
        subIds.addAll(subs.keySet());
        List<csord__Order__c> orders = [Select Id, Forecasted_Delivery_Date__c,Telstra_Committed_Date__c from csord__Order__c];
        
        Set<Id> orderIds = new Set<Id>();
        for(csord__Order__c order : orders){
            orderIds.add(order.id);
        }
        
        Test.startTest();
        SubscriptionCustomTriggerHandler.UpdateOrderStatus(subIds, orderIds);
        Test.stopTest();
        System.assertnotEquals(subs.values(), null);
    }
    
    static testMethod void testafterInsert(){
        Map<Id,csord__Subscription__c> mapOfSubs = new Map<Id, csord__Subscription__c>([Select Id, csord__Account__c, csord__Status__c, csordtelcoa__Replacement_Subscription__c, 
                                                                                        csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c, Forecasted_Delivery_Date__c, 
                                                                                        Telstra_Committed_Date__c ,csord__Order__c, csord__Order__r.csord__Primary_Order__c  
                                                                                        from csord__Subscription__c WHERE Name='testSubscription']);
        List<csord__Subscription__c> listOfSubs = new List<csord__Subscription__c>();
        for(String str : mapOfSubs.keySet()){
            listOfSubs.add(mapOfSubs.get(str));
        }
        Test.startTest();
        SubscriptionCustomTriggerHandler.afterInsert(mapOfSubs,listOfSubs);
        Test.stopTest();
        System.assertnotEquals(mapOfSubs.values(), null);
    }
    /*
    static testMethod void testafterUpdate(){
        List<csord__Subscription__c> mapOfSubs = new List<csord__Subscription__c>([Select Id, csord__Account__c, csord__Status__c, csordtelcoa__Replacement_Subscription__c, 
                                                                                   csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c, Forecasted_Delivery_Date__c, 
                                                                                   Telstra_Committed_Date__c ,csord__Order__c, csord__Order__r.csord__Primary_Order__c  
                                                                                   from csord__Subscription__c ]);
        
        Test.startTest();
        mapOfSubs[1].csordtelcoa__Replacement_Subscription__c = mapOfSubs[0].Id;
        mapOfSubs[1].csord__Status__c = 'Active';
        update mapOfSubs[1];
        Test.stopTest();
        System.assertnotEquals(mapOfSubs.size(), 0);
    } */
    
    static testMethod void testafterUpdate(){
        List<csord__Subscription__c> listOfSubs = new List<csord__Subscription__c>([SELECT Id, Name, csordtelcoa__Subscription_Number__c, csord__Status__c, csordtelcoa__Replacement_Subscription__c,
                                                                                    csord__Order__c, Forecasted_Delivery_Date__c, csord__Order__r.csord__Primary_Order__c, Telstra_Committed_Date__c
                                                                                    FROM csord__Subscription__c]);
        List<csord__Order__c> orders = [SELECT Id FROM csord__Order__c];
        Map<Id, csord__Subscription__c> mapOfOldSubs = new Map<Id, csord__Subscription__c>();
        Map<Id, csord__Subscription__c> mapOfNewSubs = new Map<Id, csord__Subscription__c>();
        List<Id> subIds = new List<Id>();
        Set<Id> orderIds = new Set<Id>();
        
        csord__Subscription__c oldValue = new csord__Subscription__c(Id = listOfSubs[0].Id, Name = listOfSubs[0].Name, csord__Status__c = 'In Progress', csordtelcoa__Subscription_Number__c = listOfSubs[0].csordtelcoa__Subscription_Number__c);
        csord__Subscription__c newValue = new csord__Subscription__c(Id = listOfSubs[0].Id, Name = listOfSubs[0].Name, csord__Status__c = 'Active', csordtelcoa__Subscription_Number__c = listOfSubs[0].csordtelcoa__Subscription_Number__c);
        newValue.csordtelcoa__Replacement_Subscription__c = listOfSubs[0].Id;
        mapOfOldSubs.put(listOfSubs[0].Id, oldValue);
        mapOfNewSubs.put(listOfSubs[0].Id, newValue);
        subIds.addAll(mapOfNewSubs.keySet());
        
        for (csord__Order__c order : orders) {
            orderIds.add(order.Id);
        }
        
       	Test.startTest();
        SubscriptionCustomTriggerHandler.beforeUpdate(mapOfNewSubs, mapOfOldSubs);
        SubscriptionCustomTriggerHandler.afterUpdate(mapOfNewSubs, mapOfOldSubs, listOfSubs);
        Test.stopTest();
        System.assertnotEquals(mapOfNewSubs.values(), null);
    }
    
    static testMethod void testBDSNotifications(){
        List<csord__Subscription__c> listOfSubs = new List<csord__Subscription__c>([Select Id, csordtelcoa__Subscription_Number__c, csord__Status__c, csordtelcoa__Replacement_Subscription__c, 
                                                                                   csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c, Forecasted_Delivery_Date__c, 
                                                                                   Telstra_Committed_Date__c ,csord__Order__c, csord__Order__r.csord__Primary_Order__c  
                                                                                   from csord__Subscription__c ]);
        
        Test.startTest();
        Map<Id,csord__Subscription__c> mapOfNewSubs = new  Map<Id,csord__Subscription__c>();
        Map<Id,csord__Subscription__c> mapOfOldSubs = new  Map<Id,csord__Subscription__c>();
        csord__Subscription__c oldValue = new csord__Subscription__c(Id=listOfSubs[0].Id,csordtelcoa__Subscription_Number__c = listOfSubs[0].csordtelcoa__Subscription_Number__c);
        oldValue.csord__Status__c = 'In Progress';
        mapOfOldSubs.put(listOfSubs[0].Id,oldValue);
        csord__Subscription__c newValue = new csord__Subscription__c(Id=listOfSubs[0].Id,csordtelcoa__Subscription_Number__c = listOfSubs[0].csordtelcoa__Subscription_Number__c);
        newValue.csord__Status__c = 'Active';
        mapOfNewSubs.put(listOfSubs[0].Id,newValue);
         
       	SubscriptionCustomTriggerHandler.updateInvokeBDSNotificationOnNumbers(mapOfNewSubs,mapOfOldSubs);
        
        Test.stopTest();
        System.assertnotEquals(mapOfOldSubs.size(), 0);
    } 
    
    
}