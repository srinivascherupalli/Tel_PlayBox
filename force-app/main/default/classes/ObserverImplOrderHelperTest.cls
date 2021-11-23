@IsTest
public with sharing class ObserverImplOrderHelperTest{

@testsetup public static void dataSetup() {
    
    Account acc = new Account();
        acc.Name = 'testAccount' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
         csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
    insert ordReq;
        
    csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;

    cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
        pc.name='IP Network';
        pc.Quantity_Product_Configuration__c = 10;
        insert pc;
        
    Service_Specification__c srvSpec = new Service_Specification__c();
        srvSpec.name='Srv Spec 1';
        srvSpec.Code__c='DMCAT_ProductSpecification_000163_Fulfilment';
        insert srvSpec;                
        
    csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
      subs.csordtelcoa__Product_Configuration__c =pc.id;
      subs.csord__Account__c = acc.id;
        insert subs;

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
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);

        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000008D0IUAU","name":"Unified Communication Enterprise_Fulfilment","instanceId":"","guid":"cf0159c5-997f-f39b-5233-dbedc2cecdbf","endDate":"","description":"","code":"DMCAT_ProductSpecification_000163_Fulfilment","attributes":{"DomainName":"","OverviewofProposedSolution":"","CustomerPreferredName":"","CustomerFacingServiceId":"","ModuleGroupType":"","EnterpriseExtensionDialling":"TRUE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv.Id;
        atts.add(att2);
        insert atts;
        
}

    static testMethod void createGetTotalFixedUsersOnAccount() {
    Test.startTest();
    
    csord__Service__c svc2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'IP Network' limit 1][0];
        
    String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc2.Id);
    system.debug('svcSpecsJSON -- ' + svcSpecsJSON  );
    List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');
    for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
    if(spec.guid == '1fba066a-4e7d-bb28-7bfe-495fae2b2066'){
        for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
          if(attr.name == 'CustomerFacingServiceId'){
            System.assertEquals('CustomerFacingServiceId', attr.name); 
            System.assertEquals('N1111', attr.value); 
          }
        }
      }
    }
    
    List<csord__Subscription__c> sublst = [select id from csord__Subscription__c];
    List<String> SubscriptionIds = new List<String>();
    for(csord__Subscription__c sub : sublst)
    {
       SubscriptionIds.add(sub.Id);   
    }
    ObserverImplOrderHelper.getTotalFixedUsersOnAccount(SubscriptionIds);
    
    Test.stopTest();
        
    }
}