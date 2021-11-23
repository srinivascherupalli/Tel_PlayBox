/*
===============================================================================================================================
Class : UpdateFixedSeatCountOnIPNetwork
Test Class : UpdateFixedSeatCountOnIPNetwork_Test
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia 9/4/2018       EDGE-79472 (bug fix)

===============================================================================================================================
*/@isTest
public class UpdateFixedSeatCountOnIPNetwork_Test {
    @testSetup public static void testMethod1() {
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='enableMSISDN', Value__c = 'true');
        insert envrn;
        List<Account> lstAccount = new List<Account>();
        for(Integer i=0;i<5; i++){
            Account testAccount = new Account();
            testAccount.Name = 'TestAccount-'+i;
            lstAccount.add(testAccount);
        }
        
        insert lstAccount;
        
        List<Contact> contactInsertList = new List<Contact>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        for(Account acc: lstAccount){
            Contact pconctact = AccountTestFactory.buildContact(acc, 'testPC', 'testabc122@test.com');
            contactInsertList.add(pconctact);
            
            Opportunity testOpp = new Opportunity();
            testOpp.Account = acc;
            testOpp.Name = 'Test Account Opportunity';
            testOpp.StageName = 'Define';
            testOpp.CloseDate = System.Date.today();
            lstOpp.add(testOpp);
        }
        
        insert contactInsertList;
        insert lstOpp;
        
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        Integer acc =0;
        for(Integer i=0 ;i < 100 ; i++){
            cscrm__Address__c address = new cscrm__Address__c();
            address.Address_ID__c = lstAccount[acc]+'--' + i;
            address.cscrm__Street__c  = lstAccount[acc]+ 'Street'+ i;
            lstAddress.add(address);
            if(acc == 4)
                acc = 0;
            else
                acc++;
        }   
        insert lstAddress;
        Integer con =0;
        List<cscrm__Site__c> lstSite = new List<cscrm__Site__c>();
        for(cscrm__Address__c address: lstAddress){
            cscrm__Site__c  site = new cscrm__Site__c();
            site.cscrm__Floor__c = 'L-T'+address.Address_ID__c;
            site.cscrm__Installation_Address__c = address.id;
            site.cscrm__Account__c = lstAccount[con].id;
            site.Primary_Contact__c = contactInsertList[con].id;
            
            lstSite.add(site);
            
            if(con == 4)
                con = 0;
            else
                con++;
        }   
        insert lstSite;
        
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c'
        );
        insert pd;
        
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            
            cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site name 2',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test1'
            );
            
            cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site Address 2',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test2'
            );
            cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site Address 23',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test3'
            );
            cscfga__Attribute_Definition__c ad4 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site Address 4',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test4'
            );
           
            lstAttributeDef.add(ad);
            lstAttributeDef.add(ad1);
            lstAttributeDef.add(ad2);
            lstAttributeDef.add(ad3);
            lstAttributeDef.add(ad4);
            
            insert lstAttributeDef;
            
        List<cscfga__Product_Basket__c> lstProductbasket = new List<cscfga__Product_Basket__c>();
        Integer acop = 0;
        for(Integer i=0; i< lstAccount.size(); i++){
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
                Name = 'Test Account Opportunity Basket',
                OwnerId = UserInfo.getUserId(),
                cscfga__Opportunity__c = lstOpp[i].Id,
                csbb__Account__c = lstAccount[i].Id,
                csordtelcoa__Basket_Stage__c = 'Enriched',
                csbb__Synchronised_with_Opportunity__c = true
            );
            lstProductbasket.add(basket);
        }
            insert lstProductbasket;
            
        //List<cscfga__Product_Configuration__c> lstpc = new List<cscfga__Product_Configuration__c>();
         List<cscfga__Product_Configuration__c> lstpc = new List<cscfga__Product_Configuration__c>();
        List<String> lstconfName = new List<String>{'IP Site','Connected Workplace','IP Site','Connected Workplace','IP Site'};
        for(Integer i=0; i< lstProductbasket.size(); i++){
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = lstProductbasket[i].Id,
                Quantity_Product_Configuration__c = 5,
                Name = lstconfName[i]
            );
            lstpc.add(pc);
        }
        insert lstpc;
        
        
        List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
        for(Integer i=0; i< lstAttributeDef.size(); i++){
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = lstpc[i].Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[i].Id
            );
            lstAttribute.add(att);
        }
        insert lstAttribute;
        
        
        List<Basket_To_Order_Field_Map__c> lstBasketMap = new List<Basket_To_Order_Field_Map__c>();
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Service_Number__c',Name='Service_Number__c',Order_Field_Api_Name__c='Service_Number__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Billing_Account__c',Name='Billing_Account__c',Order_Field_Api_Name__c='Billing_Account__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Maxim_Opportunity_ID__c',Name='Maxim_Opportunity_ID__c',Order_Field_Api_Name__c='Maxim_Opportunity_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Hot_Cutover__c',Name='Hot_Cutover__c',Order_Field_Api_Name__c='Hot_Cutover__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Project_Manager_Contact_Number__c',Name='Project_Manager_Contact_Number__c',Order_Field_Api_Name__c='Project_Manager_Contact_Number__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='PM_Required__c',Name='PM_Required__c',Order_Field_Api_Name__c='PM_Required__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Project_Complexity__c',Name='Project_Complexity__c',Order_Field_Api_Name__c='Project_Complexity__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Project_ID__c',Name='Project_ID__c',Order_Field_Api_Name__c='Project_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Project_Manager_User_ID__c',Name='Project_Manager_User_ID__c',Order_Field_Api_Name__c='Project_Manager_User_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Hot_Cutover_Comments__c',Name='Hot_Cutover_Comments__c',Order_Field_Api_Name__c='Hot_Cutover_Comments__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c='Project_Manager_Email__c',Name='Project_Manager_Email__c',Order_Field_Api_Name__c='Project_Manager_Email__c'));
       
        insert lstBasketMap;        
        
        List<csord__Order_Request__c> lstOrderReq = new List<csord__Order_Request__c>();
        for(Integer i = 0; i<5; i++){
            csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
            lstOrderReq.add(ordReq);
        }
        insert lstOrderReq;
        List<csord__Order__c> lstOrder = new List<csord__Order__c>();
        for(Integer i = 0; i<lstOrderReq.size(); i++){
            csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', lstAccount[i].id, 'Created', lstOrderReq[i].id);
            ord.csord__Order_Request__c = lstOrderReq[i].Id;
            ord.csordtelcoa__Opportunity__c = lstOpp[i].id;
            lstOrder.add(ord);
        }
        insert lstOrder;
        List<csord__Subscription__c> lstSubscription = new List<csord__Subscription__c>();
        for(Integer i = 0; i<lstOrder.size(); i++){
            csord__Subscription__c subs=new csord__Subscription__c();
            subs.name  = 'testSubscription'+lstOrder[0].Name;
            subs.csord__Identification__c = 'testIdentity';
            subs.csord__Order__c = lstOrder[0].Id;
            subs.Sub_status__c = 'Active';
            subs.csord__Account__c = lstAccount[i].id;
            subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
            lstSubscription.add(subs);
        }
        insert lstSubscription;
        List<String> lstconfName1 = new List<String>{'User - Fixed Seat','User - Fixed Seat','User - Fixed Seat','User - Fixed Seat','IP Network'};
        List<csord__Service__c> lstservs = new List<csord__Service__c>();
        for(Integer i = 0; i<lstSubscription.size(); i++){
            csord__Service__c serv = new csord__Service__c();
            serv.name =lstconfName1[i];
            serv.csord__Identification__c  = 'testIdentify_1';
            serv.csordtelcoa__Service_Number__c = '7';
            serv.csord__Subscription__c = lstSubscription[i].Id;
            serv.csord__Status__c = 'Service Created';
            serv.substage__c = 'Product Activation and Testing';
            serv.stage__c = 'Being Fulfilled';
            serv.csord__Order_Request__c = lstOrderReq[i].Id;
            serv.csord__Order__c = lstOrder[i].Id;
            serv.csordtelcoa__Product_Configuration__c=lstpc[i].id;
            lstservs.add(serv);
        }
        insert lstservs;
        List<String> lstconfName2 = new List<String>{'IP Network','IP Network','IP Network','IP Network','IP Network'};
        List<csord__Service__c> lstservs2 = new List<csord__Service__c>();
        for(Integer i = 0; i<lstSubscription.size(); i++){
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name =lstconfName2[i];
            serv1.csord__Identification__c  = 'testIdentify_1';
            serv1.csordtelcoa__Service_Number__c = '7';
            serv1.csord__Subscription__c = lstSubscription[i].Id;
            serv1.csord__Status__c = 'Service Created';
            serv1.substage__c = 'Product Activation and Testing';
            serv1.stage__c = 'Being Fulfilled';
            serv1.csord__Order_Request__c = lstOrderReq[i].Id;
            serv1.csord__Order__c = lstOrder[i].Id;
            serv1.csordtelcoa__Product_Configuration__c=lstpc[i].id;
            lstservs2.add(serv1);
        }
        insert lstservs2;
        
        List<Attachment> atts = new List<Attachment>();
        for(csord__Service__c lstserv: lstservs){
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+lstserv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","CPEDeliveryDate":"","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = lstserv.Id;
            atts.add(att1);
        }
        for(csord__Service__c lstserv2: lstservs2){
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+lstserv2.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","CPEDeliveryDate":"","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
            att.Name = 'ServiceSpecifications.json';
            att.ParentId = lstserv2.Id;
            atts.add(att);
        }
        insert atts;
        
    }
    
    @isTest static void testMethod2() {
        List<Account> lstacc = [Select id from Account WHERE name like '%TestAccount%'];
        system.debug('lstacc>>>>'+lstacc.size());
        List<Opportunity> lstOpp = [Select id FROM Opportunity WHERE name like '%Test%'];
        List<cscfga__Product_Configuration__c> lstpc = [SELECT id FROM  cscfga__Product_Configuration__c];
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setOpporunityIds = new Set<Id>();
        for(Account acc: lstacc){
            setAccountIds.add(acc.id);
        }
        for(Opportunity opp: lstOpp){
            setOpporunityIds.add(opp.id);
        }
        UpdateFixedSeatCountOnIPNetwork.getTotalFixedUsersOnAccount(setAccountIds,setOpporunityIds);
        system.assert(!setAccountIds.isEmpty());
        system.assert(!setOpporunityIds.isEmpty());
    }
}