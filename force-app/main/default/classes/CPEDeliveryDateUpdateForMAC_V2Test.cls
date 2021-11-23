@isTest
public class CPEDeliveryDateUpdateForMAC_V2Test {
    @isTest static void testMethod1() {
        OrderObserverManager_Test_v2.setup();
        Opportunity opp =[Select id,StageName from Opportunity WHERE Name='Test Account Opportunity'];
        opp.RetiedAccOpp__c = true;
        update opp;
        
        Account acc = [Select id from Account WHERE Name='TestAccount']; 
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        List<Id> subscriptionIds = new List<Id>();
        List<Id> orderIds = new List<Id>();
        List<Id> serviceIds = new List<Id>();
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
        subscriptionIds.add(subs.id);
        
        orderIds.add(ord.id);
        
        cscfga__Product_Configuration__c pc = [SELECT id FROM  cscfga__Product_Configuration__c WHERE Name='IP Network'];
        
        List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
        
        lstAttribute.add(new cscfga__Attribute__c(Name='ChangeType',cscfga__Product_Configuration__c = pc.id,
                                                           csexpimp1__guid__c='364b883e-2759-0bf4-8adb-96c93be01ef9',
                                                           cscfga__Value__c='2 Mbps'));
                                                           
        lstAttribute.add(new cscfga__Attribute__c(Name='IPSiteConfigurationChanged',cscfga__Product_Configuration__c = pc.id,
                                                           csexpimp1__guid__c='364b883e-2759-0bf4-8adb-96c93be01ef9'));
        insert lstAttribute;
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='IP Network';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csordtelcoa__Service_Number__c = '7';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.substage__c = 'Product Activation and Testing';
        serv.stage__c = 'Being Fulfilled';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        servs.add(serv);
    
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='User - Fixed Seat';
        serv2.csord__Identification__c  = 'testIdentify_2';
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.csord__Subscription__c = subs.Id;
        serv2.csord__Status__c = 'Service Created';
        serv2.substage__c = 'Product Activation and Testing';
        serv2.stage__c = 'Being Fulfilled';
        serv2.csord__Order_Request__c = ordReq.Id;
        serv2.csord__Order__c = ord.Id;
        serv2.csordtelcoa__Product_Configuration__c = pc.id;
        servs.add(serv2);
        insert servs;
        
        List<Attachment> atts = new List<Attachment>();
        for(csord__Service__c lstserv: servs){
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","CPEDeliveryDate":"","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = lstserv.Id;
            atts.add(att1);
            serviceIds.add(lstserv.id);
        }
        insert atts;
        CPEDeliveryDateUpdateForMAC_V2.addCPEAttr(serviceIds);
        system.assert(serviceIds.size() > 0);
    }
}