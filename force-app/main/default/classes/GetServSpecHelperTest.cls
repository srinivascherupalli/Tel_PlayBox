/********************************************************
Class Name : GetServSpecHelperTest
===============================================================================================================================
Change.No. Developer Name        	 Date   		Story        Description
1.         Kunal Dixit    		  					EDGE-66222		Changes done for test class coverage
2.		   Shreya					24/11/2019	 	EDGE-117980		addded plan field to service & class description
3.         Vaibhav Deshpande        20/12/2019      EDGE-98388     Changed logic to populate fixed numbers from number object
**********************************************************
*/
@isTest(SeeAllData=false)
public class GetServSpecHelperTest {
    @testSetup 
    static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        insert ordReq1;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = acc;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'CancelOrderTest';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = System.Label.IP_Network;
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.Type__c = 'New'; 
        insert testConfig;
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrderNew', acc.id, 'Created', ordReq1.id);
        
        ord1.stage__c = 'Ready for Use';
        insert ord1;
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrderNewww', acc.id, 'Created', ordReq1.id);
        ord2.csord__Order_Request__c = ordReq1.Id;
        ord2.Forecasted_Delivery_Date__c = Date.today()-1;
        ord2.Telstra_Committed_Date__c = Date.today()-1;
        ord2.stage__c = 'Ready for Use';
        ord2.csord__Primary_Order__c = ord1.Id;
        insert ord2;
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subscrip';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord2.Id;
        subs1.csordtelcoa__Subscription_Number__c='SN-0000012563';
        subs1.Sub_status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs1.stage__c = 'Ready for Use';
        
        insert subs1;
        //EDGE-117980 plan field added 
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tesst service';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c='SVC-000067679';
        serv1.csord__Subscription__c = subs1.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq1.Id;
        serv1.csord__Order__c = ord2.Id;
        serv1.Forecasted_Delivery_Date__c = Date.today();
        serv1.Telstra_Committed_Date__c = Date.today();
        serv1.Plan__c ='Local';
        insert serv1;
        
        List<Number__c> numList=new List<Number__c>();
        Number__c num=new Number__c();
        num.Service_Id__c=serv1.csordtelcoa__Service_Number__c;
        num.Service_Number__c='6532589526';
        num.Status__c='RESERVED';
        num.is_Part_of_Range__c=true;
        num.Start_Range__c='6532589524';
        num.End_range__c='6532589528';
        num.Mobile__c='Fixed'; 
        num.Subscription_number__c=subs1.csordtelcoa__Subscription_Number__c;
        numList.add(num);
        
        Number__c num2=new Number__c();
        num2.Service_Id__c=serv1.csordtelcoa__Service_Number__c;
        num2.Service_Number__c='6532589516';
        num2.Status__c='RESERVED';
        num2.is_Part_of_Range__c=false;
        num2.Start_Range__c='6532589514';
        num2.End_range__c='6532589518';
        num2.Mobile__c='Fixed'; 
        num2.Subscription_number__c=subs1.csordtelcoa__Subscription_Number__c;
        numList.add(num2);
        
        Number__c num3=new Number__c();
        num3.Service_Id__c=serv1.csordtelcoa__Service_Number__c;
        num3.Service_Number__c='6532589585';
        num3.Status__c='RESERVED';
        num3.is_Part_of_Range__c=false;
        num3.Start_Range__c='6532589514';
        num3.End_range__c='6532589518';
        num3.Mobile__c='Fixed'; 
        num3.Subscription_number__c=subs1.csordtelcoa__Subscription_Number__c;
        numList.add(num3);
        
        
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.Forecasted_Delivery_Date__c = Date.today()-1;
        ord.Telstra_Committed_Date__c = Date.today()-1;
        ord.stage__c = 'Ready for Use';
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csordtelcoa__Subscription_Number__c='SN-005635625';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.stage__c = 'Ready for Use';
        
        insert subs;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'SVC-000123564';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.stage__c = 'Ready for Use';
        serv.subStage__c = 'Product Activation And Testing';
        serv.Forecasted_Delivery_Date__c = Date.today();
        serv.Telstra_Committed_Date__c = Date.today();
        insert serv;
        
        Number__c num1=new Number__c();
        num1.Service_Id__c=serv.csordtelcoa__Service_Number__c;
        num1.Service_Number__c='6532589526';
        num1.Status__c='RESERVED';
        num1.is_Part_of_Range__c=true;
        num1.Start_Range__c='6532589524';
        num1.End_range__c='6532589528';
        num1.Mobile__c='Fixed'; 
        insert num1;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"version" : "1","status" : "Complete","startDate" : "","specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","productConfigurationId" : "a3T2O000000H5NcUAK",     "name" : "UC Numbers_Fulfilment",     "metadata" : { },     "instanceId" : "",     "includeBilling" : false,     "guid" : "2be51bf7-bc48-33e0-d69a-861298664e56",     "endDate" : "",     "description" : "",     "code" : "DMCAT_ProductSpecification_000313_Fulfilment",     "attributes" : {       "Number" : [ {         "attributes" : {           "listCode" : "LE",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "1111111111"         },         "schemaId" : "f3ca1b40-7c70-2b5f-ddbd-4f16f5e380da"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "2222222222"         },         "schemaId" : "475e1d1e-5881-60af-41c2-09b5ccf9ae80"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "3333333333"         },         "schemaId" : "566ccd58-d0e2-9afb-eaf9-968d9d096f19"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345567"         },         "schemaId" : "7f0349b4-1e72-d8d4-2129-f054dd338ea3"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345566"         },         "schemaId" : "903a9718-22d5-1a68-f623-c1d56838fc37"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345568"         },         "schemaId" : "a19282e4-d504-1adb-6bac-d385f8f9b695"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345569"         },         "schemaId" : "29295407-a1d6-98e4-2be8-02b3cad09c92"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345516"         },         "schemaId" : "e6ab2983-ddcd-975d-4101-a98ba7f6585f"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345526"         },         "schemaId" : "a09cd21e-425b-6096-7602-f25904deeb13"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345536"         },         "schemaId" : "e4afc8f6-c2e5-8171-1ce7-f9e243a46f74"       }, {         "attributes" : {           "listCode" : "No Entry Line",           "status" : "RESERVED",           "rangeTo" : null,           "rangeFrom" : null,           "FNN" : "8282345546"         },         "schemaId" : "e87f0329-4c27-b624-5342-723982825b93"       } ],       "CustomerFacingServiceId" : "",       "id" : "",       "VoicePlan" : "Complete Premium",       "__targetSystem" : "FULFILMENT",       "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment"     },     "additionalAttributes" : {       "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-04-29T08:00:00",       "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-04-29T08:00:00"     }   },{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000073_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;        
    }
    
    @isTest 
    public static void ServiceSpecDetailsTest(){
        csord__Service__c serv = [select id,name,csord__Subscription__c,modelChange__c,csordtelcoa__Service_Number__c FROM csord__service__c Where Name='tst service'];
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = ServiceSpecificationUtils.getAllServSpecsByServId(serv.id,'FULFILMENT'); 
        
        String guid1 = '3072dad2-2911-eb71-8e13-bd04b7f9824a';
        String guid ='2be51bf7-bc48-33e0-d69a-861298664e56';

        
        String CorrelationID = serv.csordtelcoa__Service_Number__c+':'+guid;
        String CorrelationID1 ='3:'+guid1;

        Test.startTest();
        GetServSpecHelper.ServiceSpecDetails(CorrelationID);
        GetServSpecHelper.BadRequestdto(CorrelationID1);
        GetServSpecHelper.InternalErrordto(CorrelationID1);
         system.assertNotEquals(null, CorrelationID);
        Test.stopTest();  
    }
    
    @isTest 
    public static void ServiceSingleFixedNumberTest(){
        csord__Service__c serv = [select id,name,csord__Subscription__c,modelChange__c,csordtelcoa__Service_Number__c,csord__Identification__c FROM csord__service__c Where csord__Identification__c  = 'test identify1'];
        List<Number__c> ucNumList=[Select id,Service_Id__c,Service_Number__c,Status__c,is_Part_of_Range__c,Start_Range__c,End_range__c,Mobile__c From Number__c Where Mobile__c='Fixed'];
        system.debug('serv'+serv);
        system.debug('serv.csordtelcoa__Service_Number__c'+serv.csordtelcoa__Service_Number__c);
        system.debug('ucNumList'+ucNumList);
        String guid ='2be51bf7-bc48-33e0-d69a-861298664e56';
        String CorrelationID ='SVC-000123564'+':'+guid;

        Test.startTest();
        GetServSpecHelper.ServiceSpecDetails(CorrelationID);
         system.assertNotEquals(null, CorrelationID);
        Test.stopTest();  
    }
    
    
        @isTest 
        public static void ServiceBulkFixedNumberTest(){
        csord__Service__c serv = [select id,name,csord__Subscription__c,modelChange__c,csordtelcoa__Service_Number__c,csord__Identification__c FROM csord__service__c Where csord__Identification__c  = 'test identify1'];
        List<Number__c> ucNumList=[Select id,Service_Id__c,Service_Number__c,Status__c,is_Part_of_Range__c,Start_Range__c,End_range__c,Mobile__c From Number__c Where Mobile__c='Fixed'];
        system.debug('serv'+serv);
        system.debug('serv.csordtelcoa__Service_Number__c'+serv.csordtelcoa__Service_Number__c);
        system.debug('ucNumList'+ucNumList);
        String guid ='2be51bf7-bc48-33e0-d69a-861298664e56';
        String CorrelationID ='SVC-000067679'+':'+guid;

        Test.startTest();
        GetServSpecHelper.ServiceSpecDetails(CorrelationID);
        system.assertNotEquals(null, CorrelationID);
        Test.stopTest();  
    }
    @isTest 
    public static void NumbersDTOTest(){
        GetServSpecHelper.Numbers nums=new GetServSpecHelper.Numbers();
        nums.endRange='123456789';
        nums.isPartofRange='Y';
        nums.numbers='123456787';
        nums.startRange='123456785';
        nums.status='RESERVED';
        nums.GUID='123456';
        system.assertNotEquals(null, nums);
    
    }
    
        @isTest 
        public static void ServiceBulkFixedNumberTest1(){
        csord__Service__c serv = [select id,name,csord__Subscription__c,modelChange__c,csordtelcoa__Service_Number__c,csord__Identification__c FROM csord__service__c Where csord__Identification__c  = 'test identify1'];
        List<Number__c> ucNumList=[Select id,Service_Id__c,Service_Number__c,Status__c,is_Part_of_Range__c,Start_Range__c,End_range__c,Mobile__c From Number__c Where Mobile__c='Fixed'];
        
        String guid ='2be51bf7-bc48-33e0-d69a-861298664e56';
        String CorrelationID ='SVC-000067679'+':'+guid;
        ServiceSpecDetailsResponseDTO sdr=new ServiceSpecDetailsResponseDTO();
        Test.startTest();
        sdr=GetServSpecHelper.ServiceSpecDetails(CorrelationID);
        system.assertNotEquals(null, sdr);
        Test.stopTest();  
    }
    
}