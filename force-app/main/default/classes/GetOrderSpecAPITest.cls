/********************************************************************************************************
*This Test class is to handle request for Custom wrapper API to support high volume orders.
* Developer: Vanita Mude
* Date: 11 June 2019
* Description: EDGE-86669 expose OrderSpecs via Custom wrapper API to support high volume orders
********************************************************************************************************/
@isTest
public class GetOrderSpecAPITest {
    
    @testsetup 
    public static void dataSetup(){       
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        insert contact;
        
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name='Unit 1 1234 Lostmy Way';
        address.Address_Line_1__c='Unit 4 Mahatma';
        address.Locality__c='Sydney';
        address.cscrm__Zip_Postal_Code__c='2000';
        address.cscrm__State_Province__c='NSW';
        address.cscrm__Country__c='Australia';
        address.cscrm__Street_Name__c ='Melbourne';
        
        insert address;
        
        Billing_Account__c billingAccount=new Billing_Account__c();
        billingAccount.Billing_Account_Number__c='123456789322';
        billingAccount.Billing_Address__c=address.id;
        billingAccount.Billing_Account_Owner__c=contact.Id;
        billingAccount.Account__c=acc.Id;
        insert billingAccount;
        
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;
        insert site;
        
        cscrm__Site__c  site1 = new cscrm__Site__c();
        site1.cscrm__Floor__c = 'L-T';
        site1.name='testSite';
        site1.cscrm__Installation_Address__c = address.Id;
        site1.cscrm__Account__c = acc.Id;
        insert site1;
        
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'Connected Workplace';
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.Billing_Account__c = billingAccount.id;
        insert ord;
        
        csord__Order__c secOrd = new csord__Order__c();
        secOrd.csord__Identification__c = 'test identification';
        secOrd.csord__Account__c = acc.id;
        secOrd.csord__Order_Type__c = 'test order' ;
        secOrd.Billing_Account__c = billingAccount.id;
        secOrd.csord__Primary_Order__c = ord.id;
        insert secOrd;
        
        cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');
        insert OriginatingOffer;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.Offer_Reference__c = OriginatingOffer.id;
        insert productConfig;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subs.csord__Order__c = secOrd.id;
        subs.csordtelcoa__Product_Configuration__c = productConfig.id;
        insert subs;
        
        List<csord__Service__c> servList = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        servList.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csord__Subscription__c  = subs.id;
        serv1.csord__Order__c = ord.id;
        serv1.csordtelcoa__Service_Number__c = '4';
        servList.add(serv1);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csord__Subscription__c  = subs.id;
        serv2.csord__Order__c = ord.id;
        serv2.csordtelcoa__Service_Number__c = '5';
        servList.add(serv2);    
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='tst service2';
        serv3.csord__Identification__c  = 'test identify2';
        serv3.csord__Subscription__c  = subs.id;
        serv3.csord__Order__c = ord.id;
        serv3.csordtelcoa__Service_Number__c = '5';
        servList.add(serv3);
        insert servList;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att = new Attachment();
        att.Name = 'ServiceSpecifications.json';
        att.ParentId = serv.id;
        att.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId":"'+serv.Id+'", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61459010001", "IPWirelessProductInstanceID" : "5456314b-ae56-f852-f3ed-804e2c94261b" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "SIMSerialNumber": "123", "RoutingServiceType": "Mobile", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "ff1cf829-b2b3-1809-ed61-848dd786e315", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "fcffec90-b549-fa6a-1eb3-3a8267575295" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "d100fd96-8ff9-bdc7-ce53-eeabe786e921", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "93c6a8e1-e15c-3449-aa2a-62980d57bcd8" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "9bd2bd28-03b3-c844-96c0-0dd2f9e7c2ed", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "f44edec9-a496-40f7-938b-33fd8dcb83d2", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "f44edec9-a496-40f7-938b-33fd8dcb83d2" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "f472a8b0-8b75-e650-3123-dc5541b8ce35", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
        atts.add(att);
        
        Attachment att1 = new Attachment();
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv1.id;
        att1.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId":"'+serv1.Id+'", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61459010001", "IPWirelessProductInstanceID" : "5456314b-ae56-f852-f3ed-804e2c94261b" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "SIMSerialNumber": "123", "RoutingServiceType": "Mobile", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "ff1cf829-b2b3-1809-ed61-848dd786e315", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "fcffec90-b549-fa6a-1eb3-3a8267575295" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "d100fd96-8ff9-bdc7-ce53-eeabe786e921", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "93c6a8e1-e15c-3449-aa2a-62980d57bcd8" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "9bd2bd28-03b3-c844-96c0-0dd2f9e7c2ed", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "f44edec9-a496-40f7-938b-33fd8dcb83d2", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "f44edec9-a496-40f7-938b-33fd8dcb83d2" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "f472a8b0-8b75-e650-3123-dc5541b8ce35", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
        atts.add(att1);
        
        Attachment att2 = new Attachment();
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv2.id;
        att2.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId":"'+serv2.Id+'", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61459010001", "IPWirelessProductInstanceID" : "5456314b-ae56-f852-f3ed-804e2c94261b" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "SIMSerialNumber": "123", "RoutingServiceType": "Mobile", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "ff1cf829-b2b3-1809-ed61-848dd786e315", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "fcffec90-b549-fa6a-1eb3-3a8267575295" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "d100fd96-8ff9-bdc7-ce53-eeabe786e921", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "93c6a8e1-e15c-3449-aa2a-62980d57bcd8" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "9bd2bd28-03b3-c844-96c0-0dd2f9e7c2ed", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "f44edec9-a496-40f7-938b-33fd8dcb83d2", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "f44edec9-a496-40f7-938b-33fd8dcb83d2" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "f472a8b0-8b75-e650-3123-dc5541b8ce35", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
        atts.add(att2);
        
        Attachment att3 = new Attachment();
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = serv3.id;
        att3.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId":"'+serv3.Id+'", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61459010001", "IPWirelessProductInstanceID" : "5456314b-ae56-f852-f3ed-804e2c94261b" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "SIMSerialNumber": "123", "RoutingServiceType": "Mobile", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "ff1cf829-b2b3-1809-ed61-848dd786e315", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "fcffec90-b549-fa6a-1eb3-3a8267575295" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "d100fd96-8ff9-bdc7-ce53-eeabe786e921", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "93c6a8e1-e15c-3449-aa2a-62980d57bcd8" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "9bd2bd28-03b3-c844-96c0-0dd2f9e7c2ed", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "f44edec9-a496-40f7-938b-33fd8dcb83d2", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "f44edec9-a496-40f7-938b-33fd8dcb83d2" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "f472a8b0-8b75-e650-3123-dc5541b8ce35", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GV9xUAG", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
        atts.add(att3);
        
        
    }
    public final static Integer ERR_422 = 422;
    public final static Integer ERR_500 = ffrest_ICustomRESTAPI.ERR_500;
    public final static Integer CODE_1000 = 1000;
    public final static Integer CODE_1001 = 1001;
    public final static string ERR_MSG_VALIDATIONFAILED = 'Validation failed'; 
    public final static string ERR_MSG_CORIDNOTPRESENT = 'CorrelationId__c does not exist in CS'; 
    public final static string ERR_MSG_ORDERIDNOTPRESENT = 'OrderID__c does not exist in CS'; 
    public final static string CORID = 'CorrelationId__c'; 
    public final static string ORDID = 'OrderID__c'; 
    
    @isTest
    static void handleRequestInsertPositive(){
        try{
            csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
            String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
            Test.startTest();
            GetOrderSpecAPIRequestDTO reqDTO = GetOrderSpecAPIRequestDTO.parse(reqBody);
            
            GetOrderSpecAPIPostHandler handler = new GetOrderSpecAPIPostHandler(reqBody);
            RestRequest restRequest=new RestRequest();
            //  RestResponse restResponse=new RestResponse();
            RestResponse response=RestContext.response;
            restRequest.httpMethod='POST';
            restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
            restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
            // restRequest.requestBody=Blob.valueOf(json);
            // RestContext.request=restRequest;
            //RestContext.response=restResponse;
            
            String orderId = reqDTO.OrderID;
            String targetSystem = reqDTO.targetSystem;
            String orderNum = reqDTO.Order_Number;//EDGE: 105942
            ffrest_CustomRESTAPI.doRequest();
            GetOrderSpecAPI apiObject=new GetOrderSpecAPI();       
            apiObject.handlePost(); 
            String result = handler.getOrderSpecs(reqDTO.OrderID,reqDTO.targetSystem,reqDTO.Order_Number);//EDGE: 105942
            System.assertNotEquals(Null, result);
            test.stopTest();
        }catch(Exception e)
        {
            
        }        
        
    }
    
    
    
    @isTest
    static void handleRequestInsertPositive_1(){
        
        try{
            csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
            String reqBody='{"Order_Number__c":"'+ord.csord__Order_Number__c+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
            
            Test.startTest();
            GetOrderSpecAPIRequestDTO reqDTO = GetOrderSpecAPIRequestDTO.parse(reqBody);
            
            GetOrderSpecAPIPostHandler handler = new GetOrderSpecAPIPostHandler(reqBody);
            RestRequest restRequest=new RestRequest();
            //  RestResponse restResponse=new RestResponse();
            RestResponse response=RestContext.response;
            restRequest.httpMethod='POST';
            restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
            restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
            // restRequest.requestBody=Blob.valueOf(json);
            // RestContext.request=restRequest;
            //RestContext.response=restResponse;
            
            String orderId = reqDTO.OrderID;
            String targetSystem = reqDTO.targetSystem;
            String Order_Number = reqDTO.Order_Number;//EDGE: 105942
            ffrest_CustomRESTAPI.doRequest();
            GetOrderSpecAPI apiObject=new GetOrderSpecAPI();       
            apiObject.handlePost(); 
            String result = handler.getOrderSpecs(reqDTO.OrderID,reqDTO.targetSystem,reqDTO.Order_Number);//EDGE: 105942
            System.assertNotEquals(Null, result);
            test.stopTest();
        }catch(Exception e)
        {
            
        }        
    }
    
    @isTest
    static void handleRequestInsertPositive_2(){
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        String json=        '{'+
            '"OrderID__c":"a4b2O0000004RLr",'+
            '"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d",'+
            '"targetSystem":"ASSURANCE"'+
            '}'+
            '';
        Test.startTest();
        RestRequest restRequest=new RestRequest();
        RestResponse restResponse=new RestResponse();
        restRequest.httpMethod='POST';
        restRequest.requestURI='https://telstrab2b--copadomun1.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
        restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
        restRequest.requestBody=Blob.valueOf(json);
        RestContext.request=restRequest;
        RestContext.response=restResponse;
        
        ffrest_CustomRESTAPI.doRequest();
        GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
        GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_500,ERR_500,ffrest_ICustomRESTAPI.ERR_MSG_500,ERR_500,ORDID,ffrest_ICustomRESTAPI.ERR_MSG_500);
        
        apiObject.handlePost();       
        System.assertEquals(422, restResponse.statusCode, 'Invalid Error');
        test.stopTest();
        
    }
    
    @isTest
    static void handleRequestInsertNegative_1(){
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        String json=        '{'+
            '"OrderID__c":"a4b2O0000004RLr",'+
            '"targetSystem":"FULFILMENT"'+
            '}'+
            '';
        Test.startTest();
        RestRequest restRequest=new RestRequest();
        RestResponse restResponse=new RestResponse();
        restRequest.httpMethod='POST';
        restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
        restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
        restRequest.requestBody=Blob.valueOf(json);
        RestContext.request=restRequest;
        RestContext.response=restResponse;
        
        ffrest_CustomRESTAPI.doRequest();
        GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
        // GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1000,CORID,ERR_MSG_CORIDNOTPRESENT);
        
        apiObject.handleRequest();       
        System.assertEquals(ERR_422, restResponse.statusCode, 'Invalid Error');
        test.stopTest();
        
    }
    
    
    @isTest
    static void handleRequestInsertNegative_2(){
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        String json=        '{'+
            '"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d",'+
            '"targetSystem":"FULFILMENT"'+
            '}'+
            '';
        Test.startTest();
        RestRequest restRequest=new RestRequest();
        RestResponse restResponse=new RestResponse();
        restRequest.httpMethod='POST';
        restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
        restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
        restRequest.requestBody=Blob.valueOf(json);
        RestContext.request=restRequest;
        RestContext.response=restResponse;
        
        ffrest_CustomRESTAPI.doRequest();
        GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
        //GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1001,ORDID,ERR_MSG_ORDERIDNOTPRESENT);
        
        apiObject.handleRequest();       
        System.assertEquals(ERR_422, restResponse.statusCode, 'Invalid Error');
        test.stopTest();
        
    }
    
    
    @isTest
    static void handleRequestInsertNegative_5(){
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        String json=        '{'+
            '"OrderID__c":"a4b2N000000kXV4",'+
            '"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d",'+
            '"targetSystem":"FULFILMENT"'+
            '}'+
            '';
        Test.startTest();
        RestRequest restRequest=new RestRequest();
        RestResponse restResponse=new RestResponse();
        restRequest.httpMethod='POST';
        restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
        restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
        restRequest.requestBody=Blob.valueOf(json);
        RestContext.request=restRequest;
        RestContext.response=restResponse;
        
        ffrest_CustomRESTAPI.doRequest();
        GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
        //GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1001,ORDID,ERR_MSG_ORDERIDNOTPRESENT);
        
        apiObject.handleRequest();       
        System.assertEquals(422, restResponse.statusCode, 'Invalid Error');
        test.stopTest();
        
    }
    
    @isTest
    static void handleRequestInsertNegative_3(){
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        
        
        Test.startTest();
        RestRequest restRequest=new RestRequest();
        RestResponse restResponse=new RestResponse();
        restRequest.httpMethod='PATCH';
        restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
        restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
        restRequest.requestBody=Blob.valueOf(reqBody);
        RestContext.request=restRequest;
        RestContext.response=restResponse;
        
        ffrest_CustomRESTAPI.doRequest();
        GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
        //GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1001,ORDID,ERR_MSG_ORDERIDNOTPRESENT);
        
        apiObject.handlePost();       
        System.assertnotEquals(200, restResponse.statusCode, 'Invalid Error');
        test.stopTest();
        
    }
    
    @isTest
    static void handleRequestInsertNegative_4(){
        
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        
        try{
            
            Test.startTest();
            RestRequest restRequest=new RestRequest();
            RestResponse restResponse=new RestResponse();
            restRequest.httpMethod='PATCH';
            restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSepccAPI';
            //restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
            //RestRequest.addHeader('Accept', 'application/json');
            restRequest.requestBody=Blob.valueOf(reqBody);
            RestContext.request=restRequest;
            RestContext.response=restResponse;
            
            ffrest_CustomRESTAPI.doRequest();
            GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
            //GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1001,ORDID,ERR_MSG_ORDERIDNOTPRESENT);
            
            apiObject.handleRequest();       
            System.assertEquals(500, restResponse.statusCode, 'Invalid Error');
            test.stopTest();
            
        }catch(Exception e){
            //
        }
    }
    
    @isTest
    static void handleRequestInsertPositive_3(){
        
        csord__Order__c ord = [Select id,name from csord__Order__c where  Name = 'Connected Workplace'];
        String reqBody='{"OrderID__c":"'+ord.id+'", "CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d", "targetSystem":"FULFILMENT" }';
        
        Test.startTest();
        RestRequest restRequest=new RestRequest();
        RestResponse restResponse=new RestResponse();
        restRequest.httpMethod='POST';
        restRequest.requestURI='https://telstrab2b--eagle5.cs116.my.salesforce.com/services/apexrest/customservices/v1.0/GetOrderSpecAPI';
        restRequest.addHeader('Content-Type', 'application/json;charset=UTF-8');
        restRequest.requestBody=Blob.valueOf(reqBody);
        RestContext.request=restRequest;
        RestContext.response=restResponse;
        
        ffrest_CustomRESTAPI.doRequest();
        GetOrderSpecAPI apiObject=new GetOrderSpecAPI();
        GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_500,ERR_500,ffrest_ICustomRESTAPI.ERR_MSG_500,ERR_500,ORDID,ffrest_ICustomRESTAPI.ERR_MSG_500);
        
        apiObject.handlePost();       
        System.assertnotEquals(200, restResponse.statusCode, 'Invalid Error');
        test.stopTest();
        
    }
}