@IsTest
public class ManageOrderTestDataSetup {

  public static void testdataSetup(){

    Account acc = new Account();
    acc.Name = 'test Account' ;
    acc.Type = 'Competitor' ;
    acc.CIDN__c = 'CIDN1234';
    insert acc;

    //AccountTestFactory
    cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
    insert addr;
    Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
    contact.Phone = '04499993456';
    insert contact;
    cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
    //site.Primary_Contact__c = contact.Id;
    insert site;

    Functional_Contact_Role__c siteRole = new Functional_Contact_Role__c();
    siteRole.Role_Type__c = 'Site';
    siteRole.Role__c = 'Technical Contact';
    siteRole.ContactID__c = contact.Id;
    siteRole.SiteID__c = site.Id;
    insert siteRole;
    
    List<csord__Order_Request__c> oreqList = new List<csord__Order_Request__c>();
    csord__Order_Request__c oreq = ProductTestFactory.buildOrderRequest();
    csord__Order_Request__c or2 = ProductTestFactory.buildOrderRequest();
    oreqList.add(oreq);
    oreqList.add(or2);
    insert oreqList;

    List<csord__Order__c> ordList = new List<csord__Order__c>();
    csord__Order__c ord = new csord__Order__c();
    ord.csord__Identification__c = 'test identification';
    ord.csord__Account__c = acc.id;
    ord.csord__Order_Type__c = 'test order';    
    ord.csord__Order_Request__c = oreqList[0].id;
    
    csord__Order__c ord2 = new csord__Order__c();
    ord2.csord__Identification__c = 'test identification';
    ord2.csord__Account__c = acc.id;
    ord2.csord__Order_Type__c = 'test order';    
    ord2.csord__Order_Request__c = oreqList[1].id;
    
    csord__Order__c ord3 = new csord__Order__c();
    ord3.csord__Identification__c = 'test identification';
    ord3.csord__Account__c = acc.id;
    ord3.csord__Order_Type__c = 'test order';    
    ord3.csord__Order_Request__c = oreqList[1].id;

    ordList.add(ord);
    ordList.add(ord2);
    ordList.add(ord3);
    insert ordList;

    Functional_Contact_Role__c orderRole = new Functional_Contact_Role__c();
    orderRole.Role_Type__c = 'Order';
    orderRole.Role__c = 'Technical Contact';
    orderRole.ContactID__c = contact.Id;
    orderRole.OrderID__c = ordList[0].Id;
    insert orderRole;

    List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
    csord__Subscription__c subs=new csord__Subscription__c();
    subs.name  = 'test subs';
    subs.csord__Identification__c = 'test identity';
    subs.csord__Order__c = ordList[0].Id;
    subs.csord__Account__c =acc.id;
    subs.Site__c = site.Id;
    subList.add(subs);

    csord__Subscription__c subs2=new csord__Subscription__c();
    subs2.name  = 'IP Network';
    subs2.csord__Identification__c = 'test identity';
    subs2.csord__Order__c = ordList[1].Id;
    subs2.csord__Account__c =acc.id;
    subs2.Site__c = site.Id;
    subList.add(subs2);
    
    csord__Subscription__c subs3=new csord__Subscription__c();
    subs3.name  = 'IP Network';
    subs3.csord__Identification__c = 'test identity';
    subs3.csord__Order__c = ordList[0].Id;
    subs3.csord__Account__c =acc.id;
    subs3.Site__c = site.Id;
    subList.add(subs3) ;

    insert subList;
    
    List<Appointment__c> applst= new List<Appointment__c>();
    Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=subList[0].id,StartDate__c=System.today(),EndDate__c=System.today());
        applst.add(appt);
    Appointment__c appt1= new Appointment__c(SlotId__c='123456',Category__c='Test1',Subscription__c=subList[1].id,StartDate__c=System.today(),Status__c ='Partial Complete');
        applst.add(appt1);
    insert applst;
    
    List<Task__c> taskList = new List<Task__c>();
    Task__c task1 =  new Task__c(Appointment__c =applst[0].Id, TaskId__c= '6b53aa2b-8769-ed63-b11a-e6555c03e074');    
    taskList.add(task1);
    Task__c task2 =  new Task__c(Appointment__c =applst[1].Id, TaskId__c= 'd5f9c51b-f91c-fef7-8756-8c2504c57a35');    
    taskList.add(task2);
      
    Task__c task3 =  new Task__c(Appointment__c =applst[0].Id, TaskId__c= 'e9acb5c4-1077-5edc-63cc-42dfaab608ec');    
    taskList.add(task3);
    insert taskList;
    
    List<csord__Service__c> serList = new List<csord__Service__c>();
    csord__Service__c serv = new csord__Service__c();
    serv.name ='tst service ----';
    serv.Model__c = 'tst service ----';
    serv.csord__Identification__c = 'test identify';
    serv.csord__Subscription__c  = subList[0].id;
    serv.csord__Order__c = ordList[0].id;
    serv.csord__Status__c = 'Service created';
    serv.csordtelcoa__Service_Number__c = '3';
    serv.Not_Before_CRD__c = system.today();
    serv.Preferred_CRD__c = system.today();
    serv.Notes__c = 'test';
    serList.add(serv);

    csord__Service__c serv2 = new csord__Service__c();
    serv2.name ='IP Network';
    serv2.csord__Identification__c  = 'test identify';
    serv2.csord__Subscription__c  = subList[1].id;
    serv2.csord__Order__c = ordList[1].id;
    serv2.csord__Status__c = 'Service created';
    serv2.csordtelcoa__Service_Number__c = '3';
    serList.add(serv2);
      
    csord__Service__c serv3 = new csord__Service__c();
    serv3.name ='IP Site';
    serv3.csord__Identification__c  = 'test identify';
    serv3.csord__Subscription__c  = subList[1].id;
    serv3.csord__Order__c = ordList[1].id;
    serv3.csord__Status__c = 'Service created';
    serv3.csordtelcoa__Service_Number__c = '3';
    serList.add(serv3);
    insert serList;

    List<Attachment> attList = new List<Attachment>();
    Attachment att1 = new Attachment();
    /* NOTE:
     * EDMRelationshipServiceTest class use the sring values as its here. 
     * Pls update and check tests in EDMRelationshipServiceTest class beforupdate the string 
    */
    //att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"80577323-8623-d45a-8041-f6a3134c55f7","productConfigurationId":"a3T2O0000002CCjUAM","name":"Telstra Fibre","instanceId":"ef2af0e2-e668-a8e5-e889-ddc868fdbc11","guid":"ef2af0e2-e668-a8e5-e889-ddc868fdbc11","endDate":"","description":"","code":"DMCAT_ProductSpecification_000027","attributes":{"DMCAT_ProductSpecification_000027_feasibilityNumber":22,"Appointment_EndDateTime":"2018-03-05 12:00:00","Appointment_StartDateTime":"2018-03-05 09:00:00","Appointment_Category":"TelstraConnectivity","Appointment_ID":"007","parentSpec":"DMCAT_ProductSpecification_000095","ModuleInstanceId":"1001"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"25a45c3e-f49c-c83f-fdb4-e59e8005c7ab","productConfigurationId":"a3T2O0000002CCjUAM","name":"Port","instanceId":"46ef0d1a-323b-271a-0706-84df9ee8d0c0","guid":"46ef0d1a-323b-271a-0706-84df9ee8d0c0","endDate":"","description":"","code":"DMCAT_ProductSpecification_000030","attributes":{"parentSpec":"DMCAT_ProductSpecification_000028"},"additionalAttributes":{"parentSpec":"ef2af0e2-e668-a8e5-e889-ddc868fdbc11"}},{"version":"1","status":"Created","startDate":"","specification":"8fcc67fc-feb4-2ae9-79a5-b8a3c42e22b0","productConfigurationId":"a3T2O0000002CCjUAM","name":"Unified Communication Site","instanceId":"da1c712f-8764-c7c3-acd4-c3121bdc446d","guid":"da1c712f-8764-c7c3-acd4-c3121bdc446d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000095","attributes":{"Service Assurance Level":"EndOfNextBusinessDay","IPVPNInstanceId":"DMCAT_ProductSpecification_000028","Customer Preferred Name":"","Customer Facing Service Id":"","childSpec":"DMCAT_ProductSpecification_000074"},"additionalAttributes":{}}],"serviceId":"'+serList[0].Id+'","legacyAttributes":[]}');
    //att1.Body = Blob.valueOf('{"specifications" : [ {"version" : "1","status" : "In Progress","startDate" : "","specification" : "DMCAT_ProductSpecification_000163_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "Internet Protection Solution_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "e9acb5c4-1077-5edc-63cc-42dfaab608ec","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000163_Fulfilment","attributes" : {  "TotalNumberofUsers" : "",  "EnterpriseInternetProductInstanceID" : "",  "CustomerFacingServiceId" : "",  "InternetProtectionSolutionType" : "Web and Mail",  "__targetSystem" : "FULFILMENT"},"additionalAttributes" : { }}, {"version" : "1","status" : "In Progress","startDate" : "","specification" : "DMCAT_ProductSpecification_000028_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "IP VPN_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000028_Fulfilment","attributes" : {  "CustomerPreferredName" : "",  "CustomerFacingServiceId" : "",  "MulticastEnabled" : "FALSE",  "__targetSystem" : "FULFILMENT"},"additionalAttributes" : { }}, {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000053_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "Managed Radius_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "6b53aa2b-8769-ed63-b11a-e6555c03e074","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000053_Fulfilment","attributes" : {  "RADIUSServerType" : "Basic Telstra Managed RADIUS",  "AuthenticationType" : "Username/Password Authentication",  "RadiusUsers" : "TRUE",  "__targetSystem" : "FULFILMENT",  "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment"},"additionalAttributes" : {  "parentSpec" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000018_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "IP Wireless_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "5c0633d9-b11a-0043-dd19-d357d6753006","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000018_Fulfilment","attributes" : {  "ManagedRadiusProductInstanceID" : "DMCAT_ProductSpecification_000053_Fulfilment",  "CustomerFacingServiceId" : "",  "RequiredPoolTypes" : "Static",  "APNtype" : "Shared",  "GlobalRoaming" : "FALSE",  "__targetSystem" : "FULFILMENT",  "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment"},"additionalAttributes" : {  "ManagedRadiusProductInstanceID" : "6b53aa2b-8769-ed63-b11a-e6555c03e074",  "parentSpec" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35"}}, {"version" : "1","status" : "In Progress","startDate" : "","specification" : "DMCAT_ProductSpecification_000338_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "Firewall_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "74285315-ef60-038f-2095-aad64cc3295d","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000338_Fulfilment","attributes" : {  "NetworkServiceId" : "",  "IPVPNProductInstanceID" : "DMCAT_ProductSpecification_000028_Fulfilment",  "CustomerFacingServiceId" : "",  "LicenseSize" : "VM-50",  "Bandwidth" : "100 Mbps",  "Latency" : "Best Effort",  "__targetSystem" : "FULFILMENT"},"additionalAttributes" : {  "IPVPNProductInstanceID" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35"}} ],"serviceId" : "'+serList[0].Id+'","legacyAttributes" : [ ]}');
    //att1.Body = Blob.valueOf('{ "specifications": [ { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000163_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Internet Protection Solution_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "e9acb5c4-1077-5edc-63cc-42dfaab608ec", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000163_Fulfilment", "attributes": { "TotalNumberofUsers": "", "EnterpriseInternetProductInstanceID": "", "CustomerFacingServiceId": "", "InternetProtectionSolutionType": "Web and Mail", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000028_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP VPN_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "d5f9c51b-f91c-fef7-8756-8c2504c57a35", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000028_Fulfilment", "attributes": { "CustomerPreferredName": "", "CustomerFacingServiceId": "", "MulticastEnabled": "FALSE", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000053_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Managed Radius_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000053_Fulfilment", "attributes": { "RADIUSServerType": "Basic Telstra Managed RADIUS", "AuthenticationType": "Username/Password Authentication", "RadiusUsers": "TRUE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000018_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP Wireless_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "5c0633d9-b11a-0043-dd19-d357d6753006", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000018_Fulfilment", "attributes": { "ManagedRadiusProductInstanceID": "DMCAT_ProductSpecification_000053_Fulfilment", "CustomerFacingServiceId": "", "RequiredPoolTypes": "Static", "APNtype": "Shared", "GlobalRoaming": "FALSE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "ManagedRadiusProductInstanceID": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000322_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Firewall_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "74285315-ef60-038f-2095-aad64cc3295d", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000322_Fulfilment", "attributes": { "NetworkServiceId": "", "IPVPNProductInstanceID": "DMCAT_ProductSpecification_000028_Fulfilment", "CustomerFacingServiceId": "", "LicenseSize": "VM-50", "Bandwidth": "100 Mbps", "Latency": "Best Effort", "Number": [ { "schemaId": "8b36e021-8454-f3bf-b99a-3beaa632f494", "attributes": { "FNN": "0882524106", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "LE" } }, { "schemaId": "bf94a542-c4c7-c4e9-af15-6d1541b98f82", "attributes": { "FNN": "0882552705", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "No Entry Line" } }, { "schemaId": "92dc7092-5708-cc05-ee6a-e8f791d183e4", "attributes": { "FNN": "0734090819", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "184093a4-707b-2694-ae49-d62be4ed0a1a", "attributes": { "FNN": "0734090820", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "e130f349-9eb2-f9ad-852a-373fdb206a07", "attributes": { "FNN": "0734090904", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "1e9016c5-6d37-429e-cc9d-ff231a60428d", "attributes": { "FNN": "0734093304", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } } ], "__targetSystem": "FULFILMENT" }, "additionalAttributes": { "IPVPNProductInstanceID": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } } ], "serviceId": "'+serList[0].Id+'", "legacyAttributes": [] } ');
    att1.Body = Blob.valueOf('{ "specifications": [ { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000163_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Internet Protection Solution_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "e9acb5c4-1077-5edc-63cc-42dfaab608ec", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000163_Fulfilment", "attributes": { "TotalNumberofUsers": "", "EnterpriseInternetProductInstanceID": "", "CustomerFacingServiceId": "", "InternetProtectionSolutionType": "Web and Mail", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000028_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP VPN_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "d5f9c51b-f91c-fef7-8756-8c2504c57a35", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000028_Fulfilment", "attributes": { "CustomerPreferredName": "", "CustomerFacingServiceId": "", "MulticastEnabled": "FALSE", "__targetSystem": "FULFILMENT" }, "additionalAttributes": {} }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000053_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Managed Radius_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000053_Fulfilment", "attributes": { "RADIUSServerType": "Basic Telstra Managed RADIUS", "AuthenticationType": "Username/Password Authentication", "RadiusUsers": "TRUE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "Created", "startDate": "", "specification": "DMCAT_ProductSpecification_000018_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "IP Wireless_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "5c0633d9-b11a-0043-dd19-d357d6753006", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000018_Fulfilment", "attributes": { "ManagedRadiusProductInstanceID": "DMCAT_ProductSpecification_000053_Fulfilment", "CustomerFacingServiceId": "", "RequiredPoolTypes": "Static", "APNtype": "Shared", "GlobalRoaming": "FALSE", "__targetSystem": "FULFILMENT", "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes": { "ManagedRadiusProductInstanceID": "6b53aa2b-8769-ed63-b11a-e6555c03e074", "parentSpec": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } }, { "version": "1", "status": "In Progress", "startDate": "", "specification": "DMCAT_ProductSpecification_000313_Fulfilment", "productConfigurationId": "a3T2O0000009RusUAE", "name": "Firewall_Fulfilment", "instanceId": "", "includeBilling": false, "guid": "74285315-ef60-038f-2095-aad64cc3295d", "endDate": "", "description": "", "code": "DMCAT_ProductSpecification_000322_Fulfilment", "attributes": { "NetworkServiceId": "", "IPVPNProductInstanceID": "DMCAT_ProductSpecification_000028_Fulfilment", "CustomerFacingServiceId": "", "LicenseSize": "VM-50", "Bandwidth": "100 Mbps", "Latency": "Best Effort", "Number": [ { "schemaId": "8b36e021-8454-f3bf-b99a-3beaa632f494", "attributes": { "FNN": "0882524106", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "LE" } }, { "schemaId": "bf94a542-c4c7-c4e9-af15-6d1541b98f82", "attributes": { "FNN": "0882552705", "rangeFrom": null, "rangeTo": null, "status": "IN TRANSITION", "listCode": "No Entry Line" } }, { "schemaId": "92dc7092-5708-cc05-ee6a-e8f791d183e4", "attributes": { "FNN": "0734090819", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "184093a4-707b-2694-ae49-d62be4ed0a1a", "attributes": { "FNN": "0734090820", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "e130f349-9eb2-f9ad-852a-373fdb206a07", "attributes": { "FNN": "0734090904", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "1e9016c5-6d37-429e-cc9d-ff231a60428d", "attributes": { "FNN": "0734093304", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } } ], "__targetSystem": "FULFILMENT" }, "additionalAttributes": { "IPVPNProductInstanceID": "d5f9c51b-f91c-fef7-8756-8c2504c57a35" } } ], "serviceId": "'+serList[0].Id+'", "legacyAttributes": [] } ');

      att1.Name = 'ServiceSpecifications.json';
    att1.ParentId = serList[0].Id;
    attList.add(att1);

    Attachment att2 = new Attachment();
    att2.Body = Blob.valueOf('{"subscriptions":[{"subscriptionId":"a4g2O0000000O1lQAE","services":[{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"1dc6e0f9-b1f3-151d-da28-1b52c66cf55c","productConfigurationId":"a3T2O0000000yJUUAY","name":"Managed Device","instanceId":"1234","guid":"92b54a6b-1bbd-2bd5-ce7c-8a15a96f52bd","endDate":"","description":"Managed Device","code":"CFS_00005","attributes":{"ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"a4e2O0000000IGoQAM","legacyAttributes":[]}]}],"orderId":"a4b2O0000000GQPQA2"}');
    att2.Name = 'OrderSpecifications.json';
    att2.ParentId = ordList[0].Id;
    attList.add(att2);

    Attachment att3 = new Attachment();
    //att3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"80577323-8623-d45a-8041-f6a3134c55f7","productConfigurationId":"a3T2O0000002CCjUAM","name":"IP VPN","instanceId":"ef2af0e2-e668-a8e5-e889-ddc868fdbc99","guid":"ef2af0e2-e668-a8e5-e889-ddc868fdbc99","endDate":"","description":"","code":"DMCAT_ProductSpecification_000028","attributes":{},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"25a45c3e-f49c-c83f-fdb4-e59e8005c7ab","productConfigurationId":"a3T2O0000002CCjUAM","name":"IP VAS Internet Port","instanceId":"46ef0d1a-323b-271a-0706-84df9ee8d080","guid":"46ef0d1a-323b-271a-0706-84df9ee8d080","endDate":"","description":"","code":"DMCAT_ProductSpecification_000106","attributes":{},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"8fcc67fc-feb4-2ae9-79a5-b8a3c42e22b0","productConfigurationId":"a3T2O0000002CCjUAM","name":"Enterprise Internet","instanceId":"da1c712f-8764-c7c3-acd4-c3121bdc44oo","guid":"da1c712f-8764-c7c3-acd4-c3121bdc44oo","endDate":"","description":"","code":"DMCAT_ProductSpecification_000114","attributes":{},"additionalAttributes":{}}],"serviceId":"'+serList[1].Id+'","legacyAttributes":[]}');
    att3.Body = Blob.valueOf('{"specifications" : [ {"version" : "1","status" : "In Progress","startDate" : "","specification" : "DMCAT_ProductSpecification_000163_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "Internet Protection Solution_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "e9acb5c4-1077-5edc-63cc-42dfaab608ec","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000163_Fulfilment","attributes" : {  "TotalNumberofUsers" : "",  "EnterpriseInternetProductInstanceID" : "",  "CustomerFacingServiceId" : "",  "InternetProtectionSolutionType" : "Web and Mail",  "__targetSystem" : "FULFILMENT"},"additionalAttributes" : { }}, {"version" : "1","status" : "In Progress","startDate" : "","specification" : "DMCAT_ProductSpecification_000028_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "IP VPN_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000028_Fulfilment","attributes" : {  "CustomerPreferredName" : "",  "CustomerFacingServiceId" : "",  "MulticastEnabled" : "FALSE",  "__targetSystem" : "FULFILMENT"},"additionalAttributes" : { }}, {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000053_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "Managed Radius_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "6b53aa2b-8769-ed63-b11a-e6555c03e074","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000053_Fulfilment","attributes" : {  "RADIUSServerType" : "Basic Telstra Managed RADIUS",  "AuthenticationType" : "Username/Password Authentication",  "RadiusUsers" : "TRUE",  "__targetSystem" : "FULFILMENT",  "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment"},"additionalAttributes" : {  "parentSpec" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000018_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "IP Wireless_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "5c0633d9-b11a-0043-dd19-d357d6753006","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000018_Fulfilment","attributes" : {  "ManagedRadiusProductInstanceID" : "DMCAT_ProductSpecification_000053_Fulfilment",  "CustomerFacingServiceId" : "",  "RequiredPoolTypes" : "Static",  "APNtype" : "Shared",  "GlobalRoaming" : "FALSE",  "__targetSystem" : "FULFILMENT",  "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment"},"additionalAttributes" : {  "ManagedRadiusProductInstanceID" : "6b53aa2b-8769-ed63-b11a-e6555c03e074",  "parentSpec" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35"}}, {"version" : "1","status" : "In Progress","startDate" : "","specification" : "DMCAT_ProductSpecification_000338_Fulfilment","productConfigurationId" : "a3T2O0000009RusUAE","name" : "Firewall_Fulfilment","instanceId" : "","includeBilling" : false,"guid" : "74285315-ef60-038f-2095-aad64cc3295d","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000338_Fulfilment","attributes" : {  "NetworkServiceId" : "",  "IPVPNProductInstanceID" : "DMCAT_ProductSpecification_000028_Fulfilment",  "CustomerFacingServiceId" : "",  "LicenseSize" : "VM-50",  "Bandwidth" : "100 Mbps",  "Latency" : "Best Effort",  "__targetSystem" : "FULFILMENT"},"additionalAttributes" : {  "IPVPNProductInstanceID" : "d5f9c51b-f91c-fef7-8756-8c2504c57a35"}} ],"serviceId" : "'+serList[1].Id+'","legacyAttributes" : [ ]}');
    att3.Name = 'ServiceSpecifications.json';
    att3.ParentId = serList[1].Id;
    attList.add(att3);

    Attachment att4 = new Attachment();
    att4.Body = Blob.valueOf('{"subscriptions":[{"subscriptionId":"a4g2O0000000O1lQAE","services":[{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"1dc6e0f9-b1f3-151d-da28-1b52c66cf55c","productConfigurationId":"a3T2O0000000yJUUAY","name":"Managed Device","instanceId":"1234","guid":"92b54a6b-1bbd-2bd5-ce7c-8a15a96f52bd","endDate":"","description":"Managed Device","code":"CFS_00005","attributes":{"ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"a4e2O0000000IGoQAM","legacyAttributes":[]}]}],"orderId":"a4b2O0000000GQPQA2"}');
    att4.Name = 'OrderSpecifications.json';
    att4.ParentId = ordList[1].Id;
    attList.add(att4);
    
     Attachment att5 = new Attachment();
    //att3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"80577323-8623-d45a-8041-f6a3134c55f7","productConfigurationId":"a3T2O0000002CCjUAM","name":"IP VPN","instanceId":"ef2af0e2-e668-a8e5-e889-ddc868fdbc99","guid":"ef2af0e2-e668-a8e5-e889-ddc868fdbc99","endDate":"","description":"","code":"DMCAT_ProductSpecification_000028","attributes":{},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"25a45c3e-f49c-c83f-fdb4-e59e8005c7ab","productConfigurationId":"a3T2O0000002CCjUAM","name":"IP VAS Internet Port","instanceId":"46ef0d1a-323b-271a-0706-84df9ee8d080","guid":"46ef0d1a-323b-271a-0706-84df9ee8d080","endDate":"","description":"","code":"DMCAT_ProductSpecification_000106","attributes":{},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"8fcc67fc-feb4-2ae9-79a5-b8a3c42e22b0","productConfigurationId":"a3T2O0000002CCjUAM","name":"Enterprise Internet","instanceId":"da1c712f-8764-c7c3-acd4-c3121bdc44oo","guid":"da1c712f-8764-c7c3-acd4-c3121bdc44oo","endDate":"","description":"","code":"DMCAT_ProductSpecification_000114","attributes":{},"additionalAttributes":{}}],"serviceId":"'+serList[1].Id+'","legacyAttributes":[]}');
    //att5.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "a4e2O0000004cLPQAY", "specifications" : [ { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "FULFILMENT", "id" : "", "CustomerFacingServiceId" : "", "NetworkServiceRef" : "" }, "code" : "DMCAT_ProductSpecification_000311_Fulfilment", "description" : "", "endDate" : "", "guid" : "c6bc7900-0fd4-0836-2374-5646a688c075", "includeBilling" : false, "instanceId" : "", "name" : "BS Tenancy_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000311", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "BSTenancyProductInstanceID" : "c6bc7900-0fd4-0836-2374-5646a688c075" }, "attributes" : { "BSTenancyProductInstanceID" : "DMCAT_ProductSpecification_000311_Fulfilment", "__targetSystem" : "FULFILMENT", "UsageModel" : "User Based", "UCService" : "CWP", "ConcurrencyLimit" : "", "id" : "", "CustomerFacingServiceId" : "", "NetworkServiceRef" : "" }, "code" : "DMCAT_ProductSpecification_000312_Fulfilment", "description" : "", "endDate" : "", "guid" : "e599848c-9c73-e904-b4a6-060909159f32", "includeBilling" : false, "instanceId" : "", "name" : "BS Service Type_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000312", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "e599848c-9c73-e904-b4a6-060909159f32", "BSTenancyProductInstanceID" : "c6bc7900-0fd4-0836-2374-5646a688c075" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "Quantity" : 6 }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "7119c989-e494-74d6-5b4c-9ba1a7731458", "includeBilling" : false, "instanceId" : "", "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "e599848c-9c73-e904-b4a6-060909159f32", "BSTenancyProductInstanceID" : "c6bc7900-0fd4-0836-2374-5646a688c075" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "Number" : [ { "schemaId" : "8b36e021-8454-f3bf-b99a-3beaa632f494", "attributes" : { "FNN" : "0882524106", "rangeFrom" : null, "rangeTo" : null, "status" : "IN TRANSITION", "listCode" : "LE" } }, { "schemaId" : "bf94a542-c4c7-c4e9-af15-6d1541b98f82", "attributes" : { "FNN" : "0882552705", "rangeFrom" : null, "rangeTo" : null, "status" : "IN TRANSITION", "listCode" : "No Entry Line" } }, { "schemaId" : "92dc7092-5708-cc05-ee6a-e8f791d183e4", "attributes" : { "FNN" : "0734090819", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "184093a4-707b-2694-ae49-d62be4ed0a1a", "attributes" : { "FNN" : "0734090820", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "e130f349-9eb2-f9ad-852a-373fdb206a07", "attributes" : { "FNN" : "0734090904", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "1e9016c5-6d37-429e-cc9d-ff231a60428d", "attributes" : { "FNN" : "0734093304", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "de50fbc3-541b-49e9-449b-6b802442ec64", "includeBilling" : false, "instanceId" : "", "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "In Progress", "version" : "1" } ] }');
    att5.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "a4e2O0000004cLPQAY", "specifications" : [ { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "FULFILMENT", "id" : "", "CustomerFacingServiceId" : "", "NetworkServiceRef" : "" }, "code" : "DMCAT_ProductSpecification_000311_Fulfilment", "description" : "", "endDate" : "", "guid" : "c6bc7900-0fd4-0836-2374-5646a688c075", "includeBilling" : false, "instanceId" : "", "name" : "BS Tenancy_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000311", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "BSTenancyProductInstanceID" : "c6bc7900-0fd4-0836-2374-5646a688c075" }, "attributes" : { "BSTenancyProductInstanceID" : "DMCAT_ProductSpecification_000311_Fulfilment", "__targetSystem" : "FULFILMENT", "UsageModel" : "User Based", "UCService" : "CWP", "ConcurrencyLimit" : "", "id" : "", "CustomerFacingServiceId" : "", "NetworkServiceRef" : "" }, "code" : "DMCAT_ProductSpecification_000312_Fulfilment", "description" : "", "endDate" : "", "guid" : "e599848c-9c73-e904-b4a6-060909159f32", "includeBilling" : false, "instanceId" : "", "name" : "BS Service Type_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductOffering_000323DMCAT_ProductSpecification_000312", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "e599848c-9c73-e904-b4a6-060909159f32", "BSTenancyProductInstanceID" : "c6bc7900-0fd4-0836-2374-5646a688c075" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "Quantity" : 6 }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "7119c989-e494-74d6-5b4c-9ba1a7731458", "includeBilling" : false, "instanceId" : "", "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "e599848c-9c73-e904-b4a6-060909159f32", "BSTenancyProductInstanceID" : "c6bc7900-0fd4-0836-2374-5646a688c075" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "Number" : [ { "schemaId" : "8b36e021-8454-f3bf-b99a-3beaa632f494", "attributes" : { "FNN" : "0882524106", "rangeFrom" : null, "rangeTo" : null, "status" : "IN TRANSITION", "listCode" : "LE" } }, { "schemaId" : "bf94a542-c4c7-c4e9-af15-6d1541b98f82", "attributes" : { "FNN" : "0882552705", "rangeFrom" : null, "rangeTo" : null, "status" : "IN TRANSITION", "listCode" : "No Entry Line" } }, { "schemaId" : "92dc7092-5708-cc05-ee6a-e8f791d183e4", "attributes" : { "FNN" : "0734090819", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "184093a4-707b-2694-ae49-d62be4ed0a1a", "attributes" : { "FNN" : "0734090820", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "e130f349-9eb2-f9ad-852a-373fdb206a07", "attributes" : { "FNN" : "0734090904", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "1e9016c5-6d37-429e-cc9d-ff231a60428d", "attributes" : { "FNN" : "0734093304", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "de50fbc3-541b-49e9-449b-6b802442ec64", "includeBilling" : false, "instanceId" : "", "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000AT4BUAW", "specification" : "DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "In Progress", "version" : "1" } ] }');
    //att5.Body = Blob.valueOf('{ "specifications" : [ { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "productConfigurationId" : "a3T2O000000ATTCUA4", "name" : "Mobile Access_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "6c2d78a6-ecad-75b3-1d7b-7da1fd3f559a", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "attributes" : { "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "AccessRole" : "Primary", "SERVICEID" : "", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "IMSI" : "", "Plan" : "Backup", "ShippingRequired" : "TRUE", "SERVICEPROFILE" : "DATA_BACKUP", "__targetSystem" : "FULFILMENT", "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment" }, "additionalAttributes" : { "IPWirelessProductInstanceID" : "69e6fee0-fdab-f2f7-7ec8-6871ebefe6cd", "SERVICEID" : "61474841913" } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "productConfigurationId" : "a3T2O000000ATTCUA4", "name" : "UC Site_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "aa2dcc4c-681d-982f-a9ea-8bd49517fc0d", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "attributes" : {"Number" : [ { "schemaId" : "b089351a-2c05-6bbd-a40f-61f02f65e678", "attributes" : { "status" : "RESERVED", "rangeTo" : null, "rangeFrom" : null, "listCode" : "LE", "FNN" : "8282345561" } }, { "schemaId" : "c4345f44-27d0-8f84-2276-964cdd9c491e", "attributes" : { "status" : "RESERVED", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345562" } }, { "schemaId" : "20004f77-45fa-8381-ee99-c1cb2edb0602", "attributes" : { "status" : "RESERVED", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345563" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "RESERVED", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "c9217257-420b-ab83-3dd9-0bff332455a4", "attributes" : { "status" : "RESERVED", "rangeTo" : null, "rangeFrom" : null, "listCode" : "No Entry Line", "FNN" : "8282345564" } }, { "schemaId" : "9d2c2535-fc29-0079-dc05-38f4787c4985", "attributes" : { "status" : "RESERVED", "rangeTo" : "20", "rangeFrom" : "1", "listCode" : "No Entry Line", "FNN" : null } } ], "CustomerPreferredName" : "", "CustomerFacingServiceId" : "", "__targetSystem" : "FULFILMENT", "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment" }, "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "c94c6e5a-305d-caa1-515f-387da01d9c1b" } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "productConfigurationId" : "a3T2O000000ATTCUA4", "name" : "Web and Mail Internet Protection User_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "70f63267-2df5-3463-635e-0fa437190001", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "attributes" : { "Quantity" : "3", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "UserProtectionType" : "Web and Mail", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "657f6d89-5912-d469-c2f3-af75b2ead1c4" } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "productConfigurationId" : "a3T2O000000ATTCUA4", "name" : "Telstra Managed Service Option 1_Assurance", "instanceId" : "", "includeBilling" : false, "guid" : "ca6f05d5-3242-b3d1-f047-98cfef02ab6b", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000326_Assurance", "attributes" : { "ServiceManagementOption " : "1", "__targetSystem" : "ASSURANCE" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "productConfigurationId" : "a3T2O000000ATTCUA4", "name" : "Incident Management_Assurance", "instanceId" : "", "includeBilling" : false, "guid" : "3c00f20e-568f-3d52-0a6d-73b6ce1d761d", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000151_Assurance", "attributes" : { "RestoreTarget" : "12 Hours", "ResponseTarget" : "2 Hours", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "__targetSystem" : "ASSURANCE" }, "additionalAttributes" : { "parentSpec" : "ca6f05d5-3242-b3d1-f047-98cfef02ab6b" } } ], "serviceId" : "a4e2O0000004c2TQAQ", "legacyAttributes" : [ ] }');

    att5.Name = 'ServiceSpecifications.json';
    att5.ParentId = serList[2].Id;
    attList.add(att5); 
      
    insert attList;
  }
    
    @isTest
  public static void testdataSetupTest(){
      Test.startTest();
      testdataSetup();
      Test.stopTest();
    Account acc = [SELECT Id, Name, CIDN__c from Account limit 1][0];
    System.assert(acc.CIDN__c == 'CIDN1234');

  }
  
  // method to generate account (added as part of EDGE-138020)
    public static User generateUser(String orgId, String fname, String lname, Id ProfileId){
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User();
        u.firstname = fname;
        u.lastName = lname;
        u.email = uniqueName + '@test' + orgId + '.org';
        u.Username = uniqueName + '@test' + orgId + '.org';
        u.EmailEncodingKey = 'UTF-8';
        u.Alias = uniqueName.substring(18, 23);
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.LanguageLocaleKey = 'en_US'; 
        u.ProfileId = ProfileId;
        return u;
    }
  
}