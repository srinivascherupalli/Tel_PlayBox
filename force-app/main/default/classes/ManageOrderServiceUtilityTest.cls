/* 
Author : Vimal Verma
Company : Telstra
Description : EDGE-1145 - Manage Order interface structure component 
Tests Executed : test_getAccountData() : Checks account in order
: test_getOrderData() : Checks order structure
: test_getServiceData() : Checks Service structure
: test_getSiteData() : Checks site in order
: test_putOrderData() : Checks consolidated order structure
: test_booleanManageOrderServicesDTO() : Checks service DTO structure
: test_UCE() : Checks UCE
History : Initail Version Mon Oct 16 09:56:44 2017
: 14 Mar 2019 - Kiran Sattikar - Changes for EDGE-53797
: 18 Mar 2019 - Nikhil Gupta - Changes for EDGE-65707,EDGE-53797
: 01 Apr 2020 - Gnana - Changes for EDGE-138020
*/
@isTest
public class ManageOrderServiceUtilityTest {
    
    @testsetup public static void dataSetup(){
        ManageOrderTestDataSetup.testdataSetup();
        
        Profile profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        List<User> listOfUser = new List<User>();
        User user1 = ManageOrderTestDataSetup.generateUser(orgId,'FirstName1','LastName1',profId.Id);
        user1.MobilePhone = '0424289156';
        user1.Phone = '0444444444';
        listOfUser.add(user1);
        User user2 = ManageOrderTestDataSetup.generateUser(orgId,'FirstName2','LastName2',profId.Id);
        user2.Phone = '0444444444';
        listOfUser.add(user2);
        User user3 = ManageOrderTestDataSetup.generateUser(orgId,'FirstName3','LastName3',profId.Id);
        listOfUser.add(user3);
        insert listOfUser;
        
        Account acc = [Select Id from Account where Name = 'test Account'];
        
        List<csord__Order_Request__c> listOfOrdReq = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        listOfOrdReq.add(ordReq);
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        listOfOrdReq.add(ordReq2);
        insert listOfOrdReq;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.Id);
        insert primaryOrd;
        
        List<csord__Order__c> listOfOrders = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Primary_Order__c = primaryOrd.Id;
        ord.PM_Required__c = true;
        listOfOrders.add(ord);
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder2', acc.id, 'Created', ordReq2.id);
        ord2.csord__Primary_Order__c = primaryOrd.Id;
        ord2.PM_Required__c = true;
        listOfOrders.add(ord2);
        
        csord__Order__c ord3 = ProductTestFactory.buildOrder('TestOrder3', acc.id, 'Created', ordReq2.id);
        ord3.csord__Primary_Order__c = primaryOrd.Id;
        ord3.PM_Required__c = true;
        ord3.ownerid = user1.Id;
        listOfOrders.add(ord3);
        
        csord__Order__c ord4 = ProductTestFactory.buildOrder('TestOrder4', acc.id, 'Created', ordReq2.id);
        ord4.csord__Primary_Order__c = primaryOrd.Id;
        ord4.PM_Required__c = true;
        ord4.ownerid = user2.Id;
        ord4.Tactical_Handling_Type__c = 'Tactical'; //Added for Tactical Handling Type attribute under getOrderCharacteristics function
        listOfOrders.add(ord4);
        
        csord__Order__c ord5 = ProductTestFactory.buildOrder('TestOrder5', acc.id, 'Created', ordReq2.id);
        ord5.csord__Primary_Order__c = primaryOrd.Id;
        ord5.PM_Required__c = true;
        ord5.ownerid = user3.Id;
        listOfOrders.add(ord5);
        insert listOfOrders;
        
        List<csord__Subscription__c> listOfSubs = new List<csord__Subscription__c>();
        csord__Subscription__c subscrip = ProductTestFactory.buildSubscription('SubscriptionProd', acc.id, ord.Id, ordReq.id);
        listOfSubs.add(subscrip);
        csord__Subscription__c subscrip2 = ProductTestFactory.buildSubscription('SubscriptionProd2', acc.id, ord2.Id, ordReq2.id);
        listOfSubs.add(subscrip);
        insert subscrip;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Nikhil3');
        insert contact;
        
        cscrm__Address__c address = AccountTestFactory.buildAddress('ADR-00003');
        insert address;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Definition', 'Plan');
        prodDef.product_Specification__c = Label.MobilitySpecCode;
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.Type__c='cancel';
        insert prodConfig;
        
        csord__Service__c serv = ProductTestFactory.buildService('ServiceProd', ord.Id, subscrip.Id, ordReq.id);
        serv.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv.Site_Delivery_Contact__c = contact.Id;
        serv.TenancyPrimaryContact__c= contact.Id;
        serv.csord__status__c = 'Disconnect';
        serv.Scenario_Type__c = 'Transition';
        serv.Delivery_Address__c = address.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        insert serv;
        
        csord__Service__c serv1 = ProductTestFactory.buildService('ServiceProd1', ord.Id, subscrip.Id, ordReq.id);
        serv1.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv1.TenancyPrimaryContact__c= contact.Id;
        serv1.Site_Delivery_Contact__c = contact.Id;
        serv1.csord__status__c = 'Modified';
        serv1.Scenario_Type__c = 'Port In';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Delivery_Address__c = address.Id;
        insert serv1;
        
        csord__Subscription__c subWithoutOrd = ProductTestFactory.buildSubscription('SubscriptionWithoutOrder', acc.id, null, null);
        subWithoutOrd.csordtelcoa__Replacement_Subscription__c = subscrip.id;
        insert subWithoutOrd;
        
        csord__Service__c servSubs = ProductTestFactory.buildService('ServiceforSubscriptionWithoutOrder', null, subWithoutOrd.Id, null);
        insert servSubs;
        /*
//AccountTestFactory
cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
insert addr;
Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
contact.Phone = '04499993456';
insert contact;
cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
//site.Primary_Contact__c = contact.Id;
insert site;

Site_Contact_Role__c siteRole = new Site_Contact_Role__c();
siteRole.Contact_Type__c = 'Technical Contact';
siteRole.Contact__c = contact.Id;
siteRole.Site__c = site.Id;
insert siteRole;

csord__Order__c ord = new csord__Order__c();
ord.csord__Identification__c = 'test identification';
ord.csord__Account__c = acc.id;
ord.csord__Order_Type__c = 'test order' ;
insert ord;

csord__Subscription__c subs=new csord__Subscription__c();
subs.name  = 'test subs';
subs.csord__Identification__c = 'test identity';
subs.csord__Order__c = ord.Id;
subs.Site__c = site.Id;
insert subs;

csord__Service__c serv = new csord__Service__c();
serv.name ='tst service';
serv.csord__Identification__c  = 'test identify';
serv.csord__Subscription__c  = subs.id;
serv.csord__Order__c = ord.id;
serv.csord__Status__c = 'Service created';
serv.csordtelcoa__Service_Number__c = '3';
insert serv;

List<Attachment> atts = new List<Attachment>();
Attachment att1 = new Attachment();
att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"80577323-8623-d45a-8041-f6a3134c55f7","productConfigurationId":"Config_ID","name":"Device Management","instanceId":"","guid":"ef2af0e2-e668-a8e5-e889-ddc868fdbc11","endDate":"","description":"Device Management","code":"CF_00020","attributes":{"parentSpec":"CF_00051","ProductModuleInstanceId":"MODULE_INSTANCE_ID","ProductModuleId":""},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"25a45c3e-f49c-c83f-fdb4-e59e8005c7ab","productConfigurationId":"Config_ID","name":"Managed Device","instanceId":"","guid":"46ef0d1a-323b-271a-0706-84df9ee8d0c0","endDate":"","description":"Managed Device","code":"CF_000051","attributes":{"childSpec":"CF_00020, CF_00019","ModuleGUID":"xyz","ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"8fcc67fc-feb4-2ae9-79a5-b8a3c42e22b0","productConfigurationId":"Config_ID","name":"Maintenance","instanceId":"","guid":"da1c712f-8764-c7c3-acd4-c3121bdc446d","endDate":"","description":"Maintenance","code":"CF_00019","attributes":{"parentSpec":"CF_00051","ProductModuleInstanceId":"xyz","ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
att1.Name = 'ServiceSpecifications.json';
att1.ParentId = serv.Id;
insert att1;

/*Attachment att2 = new Attachment();
att2.Body = Blob.valueOf('{"subscriptions":[{"subscriptionId":"a4g2O0000000O1lQAE","services":[{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"1dc6e0f9-b1f3-151d-da28-1b52c66cf55c","productConfigurationId":"a3T2O0000000yJUUAY","name":"Managed Device","instanceId":"1234","guid":"92b54a6b-1bbd-2bd5-ce7c-8a15a96f52bd","endDate":"","description":"Managed Device","code":"CFS_00005","attributes":{"ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"a4e2O0000000IGoQAM","legacyAttributes":[]}]}],"orderId":"a4b2O0000000GQPQA2"}');
att2.Name = 'OrderSpecifications.json';
att2.ParentId = ord.id;
insert att2;*/
        
        
    }
    
    
    @isTest
    static void test_getAccountData(){
        Test.startTest();
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        
        Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
        Map<Id, csord__Service__c> srvMap = ManageOrderServiceHelper.getOderDetails(orderIds,orderToReplacedSubscriptionsMap);
        Test.stopTest();
        Map<Id, ManageOrderServiceUtility.AccountData> accountData = ManageOrderServiceUtility.getAccountData(subOrderMap);
        System.assertNotEquals(null, accountData);
        System.assertEquals(accountData.get(orderIds[0]).accountType, 'Competitor');
        System.assertEquals(accountData.get(orderIds[0]).name, 'test Account');
        System.assertEquals(accountData.get(orderIds[0]).cidn, null);
    }
    
    @isTest
    static void test_getOrderData(){
        Test.startTest();
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        //test get order details
        
        List<csord__Subscription__c> subsList = [SELECT ID, Name, csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where csord__Order__c IN :orderIds];
        csord__Subscription__c subToReplace = [SELECT ID from csord__Subscription__c where Name = 'SubscriptionWithoutOrder'];
        csord__order__c order = [SELECT ID, csord__Primary_Order__c from csord__order__c where Name = 'TestOrder'];
        List<csord__Subscription__c> ordetedToReplaceSub = [SELECT ID from csord__Subscription__c where csord__order__c = :order.Id];
        List<Id> ordetedToReplaceId = new List<Id>();
        for(csord__Subscription__c sub :ordetedToReplaceSub){
            ordetedToReplaceId.add(sub.Id);
        }
        subsList.add(subToReplace);
        subsList[0].csordtelcoa__Replaced_Subscription__c = subToReplace.Id;
        update subsList; 
        if(order.csord__Primary_Order__c != null){ 
            Id pord = order.csord__Primary_Order__c;
            orderToReplacedSubscriptionsMap.put(pord,ordetedToReplaceId );
        }
        else{
            orderToReplacedSubscriptionsMap.put(order.Id,ordetedToReplaceId );
        }
        //till here
        Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
        Map<Id, csord__Service__c> srvMap = ManageOrderServiceHelper.getOderDetails(orderIds,orderToReplacedSubscriptionsMap);
        
        
        Map<Id, ManageOrderServiceUtility.OrderData> orderData = ManageOrderServiceUtility.getOrderData(subOrderMap);
        Test.stopTest();
        System.assertNotEquals(null, orderData);
        System.assertEquals(orderData.get(orderIds[0]).orderId, orderIds[0]);
        System.assertEquals(orderData.get(orderIds[0]).orderName, orderIds[0]);
        System.assertEquals(orderData.get(orderIds[0]).orderType, 'test order');
        System.assertNotEquals(orderData.get(orderIds[0]).orderNumber, null);
        System.assertEquals(orderData.get(orderIds[0]).requestedDate, null);
    }
    
    @isTest
    static void test_getServiceData(){
        Test.startTest();
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        Map<Id, csord__Service__c> srvMap = ManageOrderServiceHelper.getOderDetails(orderIds,orderToReplacedSubscriptionsMap);
        Test.stopTest();
        Map<Id, List<ManageOrderServicesDTO>> serviceData = ManageOrderServiceUtility.getServiceData(srvMap);
        System.assertNotEquals(null, serviceData); 
        System.assertNotEquals(serviceData.get(orderIds[0])[0].svcId, null);
        //System.assertEquals(serviceData.get(orderIds[0])[0].svcName, 'tst service');
        System.assertNotEquals(serviceData.get(orderIds[0])[0].svcNumber, null);
        System.assertNotEquals(serviceData.get(orderIds[0])[0].svcSubscriptionId, null);
    }
    
    
    @isTest
    static void test_getSiteData(){
        Test.startTest();
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
        //Fetch parent and sub orders
        Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
        srvcMap = ManageOrderServiceHelper.getOderDetails(new List<Id>(subOrderMap.keySet()),orderToReplacedSubscriptionsMap);
        
        Test.stopTest();
        Map<Id, List<ManageOrderServicesDTO>> servicesMap = new Map<Id, List<ManageOrderServicesDTO>>();
        servicesMap     = ManageOrderServiceUtility.getServiceData(srvcMap);
        Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> sitesData = ManageOrderServiceUtility.getSitesData(srvcMap, servicesMap);
        
        Id orderId = (new List<Id>(sitesData.keySet()))[0];
        Id svcId = (new List<Id>(sitesData.get(orderId).keySet()))[0];
        System.assertNotEquals(null, sitesData.get(orderId)); 
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].role, 'Installation');
        System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].address.street1, 'tst service');
        //System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].svcNumber, null);
        //System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].svcSubscriptionId, null);
        System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].address.id, null);
        //System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.href, '');
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.type, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.street1, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.street2, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.city, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.stateOrProvince, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.postCode, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.country, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.room, null);
        System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].address.apartment, null);
        System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].address.floor, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.buildingName, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.streetType, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.streetName, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.streetNr, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.streetSuffix, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.locality, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.town, null);
        System.assertEquals(sitesData.get(orderId).get(svcId)[0].address.county, null);
        //System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].contact, null);
        //System.assertEquals(sitesData.get(orderId).get(svcId)[0].contact[0].name, null);
        //System.assertEquals(sitesData.get(orderId).get(svcId)[0].contact[0].type, 'Full Authority');
        //System.assertEquals(sitesData.get(orderId).get(svcId)[0].contact[0].gender, null);
        //System.assertNotEquals(sitesData.get(orderId).get(svcId)[0].contact[0].contactmedium[0], null);
    }
    
    @isTest
    static void test_putOrderData(){
        Test.startTest();
        Account acc = [Select Id from Account where Name = 'test Account'];
        Contact contact1 = AccountTestFactory.buildContact(acc, 'Nikhil31');
        insert contact1;
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<Id> pId = new List <Id>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c ];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        List<csord__Order__c> POrd = [select ID , csord__Primary_Order__c from csord__Order__c];
        for(csord__Order__c order :POrd){
            pId.add(order.csord__Primary_Order__c);
        }
        
        Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
        Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
        //test
        List<csord__service__c> serviceList = [SELECT ID, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Site_Delivery_Contact__r.id,Site_Delivery_Contact__r.Title, Site_Delivery_Contact__r.FirstName, Site_Delivery_Contact__r.LastName, Site_Delivery_Contact__r.Email, Site_Delivery_Contact__r.Phone, Site_Delivery_Contact__r.MobilePhone,csord__Order__c, Site_Delivery_Contact__c from csord__service__c where csord__Order__c IN :orderIds];
        serviceList[0].csord__status__c ='Modified';
        serviceList[0].TenancyPrimaryContact__c= contact1.Id;
        //serviceList[0].csord__status__c ='Cancel';
        serviceList[0].Site_Delivery_Contact__c = contact1.Id;
        serviceList[0].Scenario_Type__c = 'Port In';
        update serviceList;
        srvcMap = ManageOrderServiceHelper.getOderDetails(new List<Id>(subOrderMap.keySet()),orderToReplacedSubscriptionsMap);
       
        
        
        //decompose svcMap into individual component maps
        Map<Id, ManageOrderServiceUtility.AccountData> accountsMap = new Map<Id, ManageOrderServiceUtility.AccountData>();
        Map<Id, ManageOrderServiceUtility.OrderData> ordersMap = new Map<Id, ManageOrderServiceUtility.OrderData>();
        Map<Id, List<ManageOrderServicesDTO>> servicesMap = new Map<Id, List<ManageOrderServicesDTO>>();
        Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> orderSitesMap = new Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> ();
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> cfsMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> ordspec = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();  
        
        accountsMap     = ManageOrderServiceUtility.getAccountData(subOrderMap);
        ordersMap       = ManageOrderServiceUtility.getOrderData(subOrderMap);
        servicesMap     = ManageOrderServiceUtility.getServiceData(srvcMap);
        cfsMap          = ManageOrderServiceHelper.getOrderSpecs(subOrderMap,orderToReplacedSubscriptionsMap);
        orderSitesMap   = ManageOrderServiceUtility.getSitesData(srvcMap, servicesMap);
        ordspec         = ManageOrderServiceHelper.getOrderSpecs(subOrderMap);
        //map CS & SFDC data into ManageOrder DTO
        
        ManageOrderDataObject.ProductOrder orderDTO = new ManageOrderDataObject.ProductOrder();
        ManageOrderServiceUtility.putOrderData(orderIds[0], orderDTO, ordersMap);
        ManageOrderServiceUtility.putAccountData(orderIds[0], orderDTO, accountsMap);
        Map<String,String> serviceCancelDateMap = ManageOrderServiceUtilityHelper.getRequestedServiceCancellationDate(orderIds);
        //65707
        Map<String,Contact> serviceDeliveryContactMap = ManageOrderServiceUtilityHelper.getDeliveryContactsForMobility(orderIds);
        String tranSientJSONStr = ' { "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        Map<String,Map<String,String>> guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(tranSientJSONStr);
        system.debug('65707::::::::::::::::::::::::::::::::::::::::;'+serviceDeliveryContactMap);
        ManageOrderServiceUtility.putServiceData(serviceCancelDateMap,ordersMap.get(orderIds[0]), orderDTO, servicesMap.get(orderIds[0]), cfsMap.get(orderIds[0]), orderSitesMap.get(orderIds[0]),serviceDeliveryContactMap,guidToTransientAttributesMap);
        String timeZone = ManageOrderServiceUtilityHelper.getTimeZone(DateTime.now());
        Test.stopTest();
        //assery order 
        System.assertNotEquals(orderDTO.externalId, null);
        System.assertEquals(orderDTO.version, 1);
        //assert account
        System.assertEquals(orderDTO.relatedParty[0].type, 'Competitor');
        System.assertEquals(orderDTO.relatedParty[0].name, 'test Account');
        System.assertEquals(orderDTO.relatedParty[0].role, 'customer');
        System.assertEquals(orderDTO.relatedParty[0].Id, 'CIDN1234');
        //assert order item/products
        if(orderDTO.orderItem.size() > 0){
            System.assertEquals(orderDTO.orderItem[0].id.split('\\|')[1], (servicesMap.get(orderIds[0]))[0].svcNumber);
            System.assertEquals(orderDTO.orderItem[0].version, 1);
            System.assertEquals(orderDTO.orderItem[0].requestedCompletionDate, null);
            System.assertEquals(orderDTO.orderItem[0].action, 'Create');
            //System.assertEquals(orderDTO.orderItem[0].Product.id, 'ef2af0e2-e668-a8e5-e889-ddc868fdbc11');
            System.assertEquals(orderDTO.orderItem[0].Product.action, 'add');
            //assert sites/contact
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].role, 'Installation');
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.street1, 'tst service');
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.id, null);
            //System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.href, '');
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.type, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street1, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street2, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.city, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.stateOrProvince, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.postCode, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.country, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.room, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.apartment, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.floor, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.buildingName, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetType, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetName, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetNr, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetSuffix, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.locality, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.town, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.county, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0], null);
            /*System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].name, null);
System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].type, 'Full Authority');
System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].gender, null);
System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].contact[0].contactmedium[0], null);*/
        }
    }
    
    @isTest
    static void test_putOrderDataNegative(){
        Test.startTest();
        Account acc = [Select Id from Account where Name = 'test Account'];
        Contact contact1 = AccountTestFactory.buildContact(acc, 'Nikhil31');
        insert contact1;
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<Id> pId = new List <Id>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c ];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        List<csord__Order__c> POrd = [select ID , csord__Primary_Order__c from csord__Order__c];
        for(csord__Order__c order :POrd){
            pId.add(order.csord__Primary_Order__c);
        }
        
        Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
        Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
        //test
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Definition', 'Plan');
        prodDef.product_Specification__c = Label.MobilitySpecCode;
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.Type__c='cancel';
        insert prodConfig;
        List<csord__service__c> serviceList = [SELECT ID, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Site_Delivery_Contact__r.id,Site_Delivery_Contact__r.Title, Site_Delivery_Contact__r.FirstName, Site_Delivery_Contact__r.LastName, Site_Delivery_Contact__r.Email, Site_Delivery_Contact__r.Phone, Site_Delivery_Contact__r.MobilePhone,csord__Order__c, Site_Delivery_Contact__c from csord__service__c where csord__Order__c IN :orderIds];
        serviceList[0].csord__status__c ='Modified';
        serviceList[0].TenancyPrimaryContact__c= contact1.Id;
         serviceList[0].csordtelcoa__Product_Configuration__c= prodConfig.Id;
        //serviceList[0].csord__status__c ='Cancel';
        serviceList[0].Site_Delivery_Contact__c = contact1.Id;
        serviceList[0].Scenario_Type__c = 'Port In';
        //serviceList[0].toBeCancelled__c = 'true';
         serviceList[0].Cust_Req_Disconn_Date__c = System.today();
        update serviceList;
        srvcMap = ManageOrderServiceHelper.getOderDetails(new List<Id>(subOrderMap.keySet()),orderToReplacedSubscriptionsMap);
        
        
        
        //decompose svcMap into individual component maps
        Map<Id, ManageOrderServiceUtility.AccountData> accountsMap = new Map<Id, ManageOrderServiceUtility.AccountData>();
        Map<Id, ManageOrderServiceUtility.OrderData> ordersMap = new Map<Id, ManageOrderServiceUtility.OrderData>();
        Map<Id, List<ManageOrderServicesDTO>> servicesMap = new Map<Id, List<ManageOrderServicesDTO>>();
        Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> orderSitesMap = new Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> ();
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> cfsMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> ordspec = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();  
        
        accountsMap     = ManageOrderServiceUtility.getAccountData(subOrderMap);
        ordersMap       = ManageOrderServiceUtility.getOrderData(subOrderMap);
        servicesMap     = ManageOrderServiceUtility.getServiceData(srvcMap);
        cfsMap          = ManageOrderServiceHelper.getOrderSpecs(subOrderMap,orderToReplacedSubscriptionsMap);
        orderSitesMap   = ManageOrderServiceUtility.getSitesData(srvcMap, servicesMap);
        ordspec         = ManageOrderServiceHelper.getOrderSpecs(subOrderMap);
        //map CS & SFDC data into ManageOrder DTO
        
        ManageOrderDataObject.ProductOrder orderDTO = new ManageOrderDataObject.ProductOrder();
        ManageOrderServiceUtility.putOrderData(orderIds[0], orderDTO, ordersMap);
        ManageOrderServiceUtility.putAccountData(orderIds[0], orderDTO, accountsMap);
        Map<String,String> serviceCancelDateMap = ManageOrderServiceUtilityHelper.getRequestedServiceCancellationDate(orderIds);
        //65707
        Map<String,Contact> serviceDeliveryContactMap = ManageOrderServiceUtilityHelper.getDeliveryContactsForMobility(orderIds);
        String tranSientJSONStr = ' { "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        Map<String,Map<String,String>> guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(tranSientJSONStr);
        system.debug('65707::::::::::::::::::::::::::::::::::::::::;'+serviceDeliveryContactMap);
        ManageOrderServiceUtility.putServiceData(serviceCancelDateMap,ordersMap.get(orderIds[0]), orderDTO, servicesMap.get(orderIds[0]), cfsMap.get(orderIds[0]), orderSitesMap.get(orderIds[0]),serviceDeliveryContactMap,guidToTransientAttributesMap);
        Test.stopTest();
        //assery order 
        System.assertNotEquals(orderDTO.externalId, null);
        System.assertEquals(orderDTO.version, 1);
        //assert account
        System.assertEquals(orderDTO.relatedParty[0].type, 'Competitor');
        System.assertEquals(orderDTO.relatedParty[0].name, 'test Account');
        System.assertEquals(orderDTO.relatedParty[0].role, 'customer');
        System.assertEquals(orderDTO.relatedParty[0].Id, 'CIDN1234');
        //assert order item/products
        if(orderDTO.orderItem.size() > 0){
            System.assertEquals(orderDTO.orderItem[0].id.split('\\|')[1], (servicesMap.get(orderIds[0]))[0].svcNumber);
            System.assertEquals(orderDTO.orderItem[0].version, 1);
            //System.assertEquals(orderDTO.orderItem[0].requestedCompletionDate, null);
            System.assertEquals(orderDTO.orderItem[0].action, 'Create');
            //System.assertEquals(orderDTO.orderItem[0].Product.id, 'ef2af0e2-e668-a8e5-e889-ddc868fdbc11');
            System.assertEquals(orderDTO.orderItem[0].Product.action, 'add');
            //assert sites/contact
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].role, 'Installation');
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.street1, 'tst service');
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.id, null);
            //System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.href, '');
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.type, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street1, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street2, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.city, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.stateOrProvince, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.postCode, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.country, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.room, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.apartment, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.floor, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.buildingName, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetType, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetName, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetNr, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetSuffix, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.locality, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.town, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.county, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0], null);
            /*System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].name, null);
System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].type, 'Full Authority');
System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].gender, null);
System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].contact[0].contactmedium[0], null);*/
        }
    }


@isTest
    static void test_UCE(){
        Test.startTest();
        Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
        List<Id> pId = new List <Id>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
        List<Id> orderIds = new List<Id>();
        for(csord__Order__c ord: orders){
            orderIds.add(ord.Id);
        }
        List<csord__Order__c> POrd = [select csord__Primary_Order__c from csord__Order__c LIMIT 1];
        for(csord__Order__c order :POrd){
            pId.add(order.id);
        }
        
        //======= to populate orderToReplacedSubscriptionsMap
        Id ordId = orderIds[0];
        List<csord__Subscription__c> subList = [SELECT ID from csord__Subscription__c where csord__Order__c =:ordId];
        List<Id> subId = new List<Id>();
        for (csord__Subscription__c sub : subList){
            subId.add(sub.Id);
        }
        orderToReplacedSubscriptionsMap.put(ordId, subId);  
        //=======
        Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
        Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
        srvcMap = ManageOrderServiceHelper.getOderDetails(new List<Id>(subOrderMap.keySet()),orderToReplacedSubscriptionsMap);
        for(csord__Service__c ser : srvcMap.values()){
            ser.Scenario_Type__c = System.Label.Device_Replacement;
            srvcMap.put(ser.Id,ser);
        }
        update srvcMap.values();
        
        
        //decompose svcMap into individual component maps
        Map<Id, ManageOrderServiceUtility.AccountData> accountsMap = new Map<Id, ManageOrderServiceUtility.AccountData>();
        Map<Id, ManageOrderServiceUtility.OrderData> ordersMap = new Map<Id, ManageOrderServiceUtility.OrderData>();
        Map<Id, List<ManageOrderServicesDTO>> servicesMap = new Map<Id, List<ManageOrderServicesDTO>>();
        Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> orderSitesMap = new Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> ();
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> cfsMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        
        accountsMap     = ManageOrderServiceUtility.getAccountData(subOrderMap);
        ordersMap       = ManageOrderServiceUtility.getOrderData(subOrderMap);
        servicesMap     = ManageOrderServiceUtility.getServiceData(srvcMap);
        cfsMap          = ManageOrderServiceHelper.getOrderSpecs(subOrderMap,orderToReplacedSubscriptionsMap);
        orderSitesMap   = ManageOrderServiceUtility.getSitesData(srvcMap, servicesMap);
        //map CS & SFDC data into ManageOrder DTO
        
        ManageOrderDataObject.ProductOrder orderDTO = new ManageOrderDataObject.ProductOrder();
        ManageOrderServiceUtility.putOrderData(orderIds[0], orderDTO, ordersMap);
        ManageOrderServiceUtility.putAccountData(orderIds[0], orderDTO, accountsMap);
        Map<String,String> serviceCancelDateMap = ManageOrderServiceUtilityHelper.getRequestedServiceCancellationDate(orderIds);
        //65707
        Map<String,Contact> serviceDeliveryContactMap = ManageOrderServiceUtilityHelper.getDeliveryContactsForMobility(pId);
        
        String tranSientJSONStr = ' { "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        Map<String,Map<String,String>> guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(tranSientJSONStr);
        ManageOrderServiceUtility.putServiceData(serviceCancelDateMap,ordersMap.get(orderIds[0]), orderDTO, servicesMap.get(orderIds[0]), cfsMap.get(orderIds[0]), orderSitesMap.get(orderIds[0]),serviceDeliveryContactMap,guidToTransientAttributesMap);
        //String json =  '[additionalAttributes=(SimpleAttributes:[name=DMCAT_ProductSpecification_000322_CPEDeliveryDate, value=2019-02-19T10:00:00], SimpleAttributes:[name=BSServiceTypeProductInstanceID, value=2e5b4089-e00c-e817-232d-f3bd8f32d640]), code=DMCAT_ProductSpecification_000322_Fulfilment, complexAttributes={Number=(ComplexAttributes:[productConfigurationId=null, simpleAttributes=(SimpleAttributes:[name=FNN, value=8282345561], SimpleAttributes:[name=listCode, value=LE], SimpleAttributes:[name=rangeFrom, value=null], SimpleAttributes:[name=rangeTo, value=null], SimpleAttributes:[name=status, value=RESERVED])], ComplexAttributes:[productConfigurationId=null, simpleAttributes=(SimpleAttributes:[name=FNN, value=8282345562], SimpleAttributes:[name=listCode, value=No Entry Line], SimpleAttributes:[name=rangeFrom, value=null], SimpleAttributes:[name=rangeTo, value=null], SimpleAttributes:[name=status, value=RESERVED])], ComplexAttributes:[productConfigurationId=null, simpleAttributes=(SimpleAttributes:[name=FNN, value=8282345563], SimpleAttributes:[name=listCode, value=No Entry Line], SimpleAttributes:[name=rangeFrom, value=null], SimpleAttributes:[name=rangeTo, value=null], SimpleAttributes:[name=status, value=RESERVED])], ComplexAttributes:[productConfigurationId=null, simpleAttributes=(SimpleAttributes:[name=FNN, value=8282345564], SimpleAttributes:[name=listCode, value=No Entry Line], SimpleAttributes:[name=rangeFrom, value=null], SimpleAttributes:[name=rangeTo, value=null], SimpleAttributes:[name=status, value=RESERVED])], ComplexAttributes:[productConfigurationId=null, simpleAttributes=(SimpleAttributes:[name=FNN, value=8282345564], SimpleAttributes:[name=listCode, value=No Entry Line], SimpleAttributes:[name=rangeFrom, value=null], SimpleAttributes:[name=rangeTo, value=null], SimpleAttributes:[name=status, value=RESERVED])])}, description=, endDate=, guid=3d0ab061-1daf-b6c9-358b-396287401a5c, identifier=null, instanceId=, name=UC Site_Fulfilment, productConfigurationId=a3T2O000000B0t8UAC, replacedSpecification=null, serviceId=a4e2O0000004rvIQAQ, simpleAttributes=(SimpleAttributes:[name=BSServiceTypeProductInstanceID, value=DMCAT_ProductSpecification_000312_Fulfilment], SimpleAttributes:[name=__targetSystem, value=FULFILMENT], SimpleAttributes:[name=CustomerFacingServiceId, value=], SimpleAttributes:[name=CustomerPreferredName, value=], SimpleAttributes:[name=DMCAT_ProductSpecification_000322_CPEDeliveryDate, value=]), startDate=, status=Created, subscriptionId=null, version=1]';
        //List<CS_SpecificationDTO.ServiceSpecification> svcSpec = new List<CS_SpecificationDTO.ServiceSpecification>();
        //svcSpec = CS_SpecificationDTO.parseServiceSpec(json);
        //String json1 =  'ProductDataObject:[action=add, id=3d0ab061-1daf-b6c9-358b-396287401a5c, place=null, productCharacteristic=(CharacteristicDataObject:[name=BSServiceTypeProductInstanceID, value=2e5b4089-e00c-e817-232d-f3bd8f32d640], CharacteristicDataObject:[name=__targetSystem, value=FULFILMENT], CharacteristicDataObject:[name=CustomerFacingServiceId, value=], CharacteristicDataObject:[name=CustomerPreferredName, value=]), productRelationship=null, productSpecification=ProductSpecificationDataObject:[code=DMCAT_ProductSpecification_000322]]';
        // ManageOrderDataObject.ProductOrder moDTO = new ManageOrderDataObject.ProductOrder();
        //moDTO = (ManageOrderDataObject.ProductOrder) System.JSON.deserialize(json, ManageOrderDataObject.ProductOrder.class);
        // ManageOrderServiceUtilityHelper.transformNumbertToProductCharacteristic(svcSpec[0],new ManageOrderDataObject.ProductDataObject());
        //assery order 
        Test.stopTest();
        System.assertNotEquals(orderDTO.externalId, null);
        System.assertEquals(orderDTO.version, 1);
        //assert account
        System.assertEquals(orderDTO.relatedParty[0].type, 'Competitor');
        System.assertEquals(orderDTO.relatedParty[0].name, 'test Account');
        System.assertEquals(orderDTO.relatedParty[0].role, 'customer');
        System.assertEquals(orderDTO.relatedParty[0].Id, 'CIDN1234');
        //assert order item/products
        if(orderDTO.orderItem.size() > 0){
            System.assertEquals(orderDTO.orderItem[0].id.split('\\|')[1], (servicesMap.get(orderIds[0]))[0].svcNumber);
            System.assertEquals(orderDTO.orderItem[0].version, 1);
            System.assertEquals(orderDTO.orderItem[0].requestedCompletionDate, null);
            System.assertEquals(orderDTO.orderItem[0].action, 'Create');
            //System.assertEquals(orderDTO.orderItem[0].Product.id, 'ef2af0e2-e668-a8e5-e889-ddc868fdbc11');
            System.assertEquals(orderDTO.orderItem[0].Product.action, 'add');
            //assert sites/contact
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].role, 'Installation');
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.street1, 'tst service');
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.id, null);
            //System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.href, '');
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.type, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street1, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street2, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.city, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.stateOrProvince, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.postCode, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.country, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.room, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.apartment, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.floor, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.buildingName, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetType, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetName, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetNr, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetSuffix, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.locality, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.town, null);
            System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.county, null);
            System.assertNotEquals(orderDTO.orderItem[0].Product.place[0], null);
            /*System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].name, null);
System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].type, 'Full Authority');
System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].gender, null);
System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].contact[0].contactmedium[0], null);*/
        }
    }  
    
    
    @isTest
    static void test_booleanManageOrderServicesDTO(){
        Test.startTest();
        csord__Service__c serv = [select id,name,csordtelcoa__Service_Number__c,csord__Status__c, csord__Subscription__c from csord__Service__c  
        //where name ='tst service'];
        Limit 1];
        Object o = new ManageOrderServicesDTO(serv.id,serv.name,serv.csordtelcoa__Service_Number__c,serv.csord__Subscription__c, serv.csord__Status__c);
        System.assertEquals(true, o instanceof ManageOrderServicesDTO);
        ManageOrderServicesDTO mosDTO = new ManageOrderServicesDTO(serv.id,serv.name,serv.csordtelcoa__Service_Number__c,serv.csord__Subscription__c, serv.csord__Status__c);
        System.assertEquals(true, mosDTO.equals(o));
        mosDTO.hashCode();
        Test.stopTest();
    }
    
    
    @istest
    static void test_getTimeZone(){
        string dt = ManageOrderServiceUtilityHelper.getTimeZone(system.now());
        System.assertNotEquals(null, dt); 
    }
    @istest
    static void test_createProd(){
        csord__service__c serviceProd = [Select Id from csord__service__c where Name = 'ServiceProd'];    
        String json =  '[{"serviceId":null,"version":"1","status":"RESERVED","startDate":"","simpleAttributes":[{"value":"Zone 3","name":"Zone"},{"value":"1500.00","name":"TotalMRC"},{"value":"5","name":"Seat"},{"value":"contantValue","name":"constantName"}],"replacedSpecification":"","productConfigurationId":"ConfigId","name":"CWPSpec","instanceId":"","identifier":"30a0f36c-b496-185e-6330-c7a9c317d22c","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","complexAttributes":{"complexIPAccess":[{"simpleAttributes":[{"value":"8080","name":"complexAttrPort"},{"value":"Fibre","name":"complexAttrTech"}, {"value":"ACTIVE","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId1"},{"simpleAttributes":[{"value":"9090","name":"complexAttrPort"},{"value":"Ethernet","name":"complexAttrTech"},{"value":"RESERVED","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId2"},{"simpleAttributes":[{"value":"8080","name":"complexAttrPort"},{"value":"Fibre","name":"complexAttrTech"}, {"value":"IN TRANSITION","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId3"},{"simpleAttributes":[{"value":"9090","name":"complexAttrPort"},{"value":"Ethernet","name":"complexAttrTech"},{"value":"ACTIVE","name":"status"},{"value":null,"name":"rangeTo"},{"value":null,"name":"rangeFrom"}],"productConfigurationId":"ConfigId4"},{"simpleAttributes":[{"value":"9090","name":"complexAttrPort"},{"value":"Ethernet","name":"complexAttrTech"},{"value":"IN TRANSITION","name":"status"},{"value":"","name":"rangeTo"},{"value":"","name":"rangeFrom"}],"productConfigurationId":"ConfigId5"}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment"}]';
        
        
        String tranSientJSONStr = ' { "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        Map<String,Map<String,String>> guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(tranSientJSONStr);
        
        List<CS_SpecificationDTO.ServiceSpecification> svcSpec = new List<CS_SpecificationDTO.ServiceSpecification>();
        svcSpec = CS_SpecificationDTO.parseServiceSpec(json);
        for (CS_SpecificationDTO.ServiceSpecification servSpec : svcSpec) {
            servSpec.serviceId = serviceProd.Id;
        }
        
        List<csord__Service__c> service = [select Id, Name, csordtelcoa__Service_Number__c, csord__Subscription__c, csord__Status__c from csord__Service__c];
        ManageOrderServicesDTO serv = new ManageOrderServicesDTO(service[0].Id, service[0].Name, service[0].csordtelcoa__Service_Number__c, service[0].csord__Subscription__c, service[0].csord__Status__c);
        list<String> subsIds = new List<String>();
        subsIds.add(serv.svcSubscriptionId);
        Map<String, Task__c> taskAppointmentMap = AppointmentServiceHelper.getAppointmentsDetails(subsIds);
        Test.startTest();
        Map<String, ManageOrderDataObject.ProductDataObject> ordersMap = ManageOrderServiceUtility.createProd(svcSpec, taskAppointmentMap,guidToTransientAttributesMap);
        System.assertNotEquals(ordersMap,null);
        Test.stopTest();
    }
  
  @istest
    static void test_createProdDeviceReplacement(){
        csord__service__c serviceProd = [Select Id from csord__service__c where Name = 'ServiceProd'];  
    serviceProd.Scenario_Type__c = System.Label.Device_Replacement;
    update   serviceProd;  
        String json =  '[{"serviceId":null,"version":"1","status":"RESERVED","startDate":"","simpleAttributes":[{"value":"Zone 3","name":"Zone"},{"value":"1500.00","name":"TotalMRC"},{"value":"5","name":"Seat"},{"value":"contantValue","name":"constantName"}],"replacedSpecification":"","productConfigurationId":"ConfigId","name":"CWPSpec","instanceId":"","identifier":"30a0f36c-b496-185e-6330-c7a9c317d22c","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","complexAttributes":{"complexIPAccess":[{"simpleAttributes":[{"value":"8080","name":"complexAttrPort"},{"value":"Fibre","name":"complexAttrTech"}, {"value":"ACTIVE","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId1"},{"simpleAttributes":[{"value":"9090","name":"complexAttrPort"},{"value":"Ethernet","name":"complexAttrTech"},{"value":"RESERVED","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId2"},{"simpleAttributes":[{"value":"8080","name":"complexAttrPort"},{"value":"Fibre","name":"complexAttrTech"}, {"value":"IN TRANSITION","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId3"},{"simpleAttributes":[{"value":"9090","name":"complexAttrPort"},{"value":"Ethernet","name":"complexAttrTech"},{"value":"ACTIVE","name":"status"},{"value":null,"name":"rangeTo"},{"value":null,"name":"rangeFrom"}],"productConfigurationId":"ConfigId4"},{"simpleAttributes":[{"value":"9090","name":"complexAttrPort"},{"value":"Ethernet","name":"complexAttrTech"},{"value":"IN TRANSITION","name":"status"},{"value":"","name":"rangeTo"},{"value":"","name":"rangeFrom"}],"productConfigurationId":"ConfigId5"}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment"}]';
        
        
        String tranSientJSONStr = ' { "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        Map<String,Map<String,String>> guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(tranSientJSONStr);
        
        List<CS_SpecificationDTO.ServiceSpecification> svcSpec = new List<CS_SpecificationDTO.ServiceSpecification>();
        svcSpec = CS_SpecificationDTO.parseServiceSpec(json);
        for (CS_SpecificationDTO.ServiceSpecification servSpec : svcSpec) {
            servSpec.serviceId = serviceProd.Id;
        }
        
        List<csord__Service__c> service = [select Id, Name, csordtelcoa__Service_Number__c, csord__Subscription__c, csord__Status__c from csord__Service__c];
        ManageOrderServicesDTO serv = new ManageOrderServicesDTO(service[0].Id, service[0].Name, service[0].csordtelcoa__Service_Number__c, service[0].csord__Subscription__c, service[0].csord__Status__c);
        list<String> subsIds = new List<String>();
        subsIds.add(serv.svcSubscriptionId);
        Map<String, Task__c> taskAppointmentMap = AppointmentServiceHelper.getAppointmentsDetails(subsIds);
        Test.startTest();
        Map<String, ManageOrderDataObject.ProductDataObject> ordersMap = ManageOrderServiceUtility.createProd(svcSpec, taskAppointmentMap,guidToTransientAttributesMap);
        List<Id> parentIds = new List<Id>();
        for(csord__Service__c objservice : service){
            parentIds.add(objservice.id);
        }
        
        ManageOrderServiceUtilityHelper.getTransientDTOJSON(parentIds);
        System.assertNotEquals(ordersMap,null);
        Test.stopTest();
    }
    
    // Test method to check user mobile number (added as part of EDGE-138020)
    @istest
    static void test_salesUserMobileNumberCheck(){
        Test.startTest();
        csord__Order__c order = [SELECT Id,Project_Manager_Email__c,Project_Manager_Contact_Number__c,Project_Manager_User_ID__c,Project_ID__c,Project_Complexity__c ,CreatedDate ,ModelChange__c ,PM_Required__c ,csord__Account__c,OwnerId ,Tactical_Handling_Type__c ,csord__Account__r.Business_Unit__c from csord__Order__c WHERE Name = 'TestOrder3' LIMIT 1];
        List<ManageOrderDataObject.CharacteristicDataObject> result = ManageOrderServiceUtilityHelper.getOrderCharacteristics(order);
        String contNumber;
        for(ManageOrderDataObject.CharacteristicDataObject r : result){
            if(r.Name == 'SalesUserContactNumber'){
                contNumber = r.value;
            }
        }
        System.assertEquals(contNumber,'0424289156');
        Test.stopTest();
    }
    
    // Test method to check user phone number (added as part of EDGE-138020)
    @istest
    static void test_salesUserPhoneNumberCheck(){
        Test.startTest();
        csord__Order__c order = [SELECT Id,Project_Manager_Email__c,Project_Manager_Contact_Number__c,Project_Manager_User_ID__c,Project_ID__c,Project_Complexity__c ,CreatedDate ,ModelChange__c ,PM_Required__c ,csord__Account__c,OwnerId ,Tactical_Handling_Type__c ,csord__Account__r.Business_Unit__c from csord__Order__c WHERE Name = 'TestOrder4' LIMIT 1];
        List<ManageOrderDataObject.CharacteristicDataObject> result = ManageOrderServiceUtilityHelper.getOrderCharacteristics(order);
        String contNumber;
        for(ManageOrderDataObject.CharacteristicDataObject r : result){
            if(r.Name == 'SalesUserContactNumber'){
                contNumber = r.value;
            }
        }
        System.assertEquals(contNumber,'0444444444');
        Test.stopTest();
    }
    
    // Test method to check user phone/mobile number (added as part of EDGE-138020)
    @istest
    static void test_salesUserNoMobileOrPhoneNumberCheck(){
        Test.startTest();
        csord__Order__c order = [SELECT Id,Project_Manager_Email__c,Project_Manager_Contact_Number__c,Project_Manager_User_ID__c,Project_ID__c,Project_Complexity__c ,CreatedDate ,ModelChange__c ,PM_Required__c ,csord__Account__c,OwnerId ,Tactical_Handling_Type__c ,csord__Account__r.Business_Unit__c from csord__Order__c WHERE Name = 'TestOrder5' LIMIT 1];
        List<ManageOrderDataObject.CharacteristicDataObject> result = ManageOrderServiceUtilityHelper.getOrderCharacteristics(order);
        String contNumber;
        for(ManageOrderDataObject.CharacteristicDataObject r : result){
            if(r.Name == 'SalesUserContactNumber'){
                contNumber = r.value;
            }
        }
        System.assertEquals(contNumber,'');
        Test.stopTest();
    }
    
}