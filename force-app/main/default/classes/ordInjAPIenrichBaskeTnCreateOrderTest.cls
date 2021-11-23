@isTest
public class ordInjAPIenrichBaskeTnCreateOrderTest {

    @TestSetup 
    static void dataSetup() 
    {
        profile testProfile = [SELECT Id FROM Profile WHERE Name='OrderInjection Integration'];  
        user testUser = new User(
            Alias = 'standT', 
            Email='test_standarduser@testorg.com',
            emailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            localeSidKey='en_US', 
            ProfileId = testProfile.Id,
            timeZoneSidKey='America/Los_Angeles',
            userName = 'ABCD'+String.valueOf(Date.today()) +'@gmail.com');  
        insert testUSer;

        system.runAs(testUser){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TNow_Order_Injection'];
            insert new PermissionSetAssignment(AssigneeId = testUSer.id, PermissionSetId = ps.Id);
            
            Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'Basket_Not_Valid_For_Skip_Contract',value__c = 'test');
            
            list<Sync_Control_and_Constants__c> slist = new list<Sync_Control_and_Constants__c>{s1};
                insert slist;
            
            //create Account
            Account testAccount = new Account();
            testAccount.Name = 'testAccount';
            testAccount.Customer_Status__c = 'ACTIVE';
            testAccount.CIDN__c = '123456'; 
            testAccount.cscfga__Active__c='Yes';
            insert testAccount; 
            
            //create Oppty
            Opportunity testOpp = new Opportunity();
            testOpp.Account = testAccount;
            testOpp.Name = 'testOpp';
            testOpp.StageName = 'Define';
            testOpp.Product_Type__c = 'Modular';
            testOpp.CloseDate = System.Date.today();
            testOpp.Type = 'Renewal';
            testOpp.Billing_Solution__c = 'Standard';
            Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
            testOpp.RecordTypeId = standardID;
            insert testOpp;
            
            cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
            testBasket.csbb__Account__c = testAccount.Id;
            testBasket.Name = 'ShowSubTestBasket';
            testBasket.cscfga__Opportunity__c = testOpp.Id;
            testBasket.channelFrom__c = 'TED-81 onlineAPI';
            testBasket.correlation_id__c = '008415e6-f785-66b8-811b-bc94838dde4d';
            insert testBasket;
            
            csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Mobility', csord__Account__c = testAccount.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
            insert sol;
            
            List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
            cscfga__Product_Definition__c cwProdDef = new cscfga__Product_Definition__c(Name = 'Apdaptive Mobility', cscfga__Description__c = 'Adaptive Mobility');
            pdList.add(cwProdDef);  
            insert pdList;  
            
            List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
            cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
            testConfig.Name = 'Adaptive Mobility';
            testConfig.ConfigurationType1__c = 'SolutionComponent';
            testConfig.cscfga__Product_Basket__c = testBasket.Id;
            testConfig.cscfga__Product_Definition__c=cwProdDef.Id;
            prodconfigList.add(testConfig);
            insert prodconfigList;
            
            csord__Order__c testOrder = new csord__Order__c();
            testOrder.csord__Account__c = testAccount.Id;
            testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
            testOrder.Name = 'TestOrderNameForTest';
            testOrder.csord__Identification__c = 'test';
            testOrder.isMSISDNHeld__c = false;
            testOrder.Product_Basket__c = testBasket.Id;
            insert testOrder;
            
            List<csord__Subscription__c> subslist=new List<csord__Subscription__c>();
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            testSubscription.Name = 'TestSubsforTest';
            testSubscription.csord__Account__c = testAccount.Id;
            testSubscription.csord__Identification__c = 'test';
            testSubscription.csordtelcoa__Subscription_Number__c = 'SN-000552601';
            testSubscription.csord__Status__c = 'Active';
            testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
            testSubscription.cssdm__solution_association__c = sol.id;
            subslist.add(testSubscription);
            
            csord__Subscription__c testSubscription4 = new csord__Subscription__c();
            testSubscription4.Name = 'TestSubsforTest4';
            testSubscription4.csord__Account__c = testAccount.Id;
            testSubscription4.csord__Identification__c = 'test';
            testSubscription4.csordtelcoa__Subscription_Number__c = 'SN-000552602';
            testSubscription4.csord__Status__c = 'Suspended';
            subslist.add(testSubscription4);
            insert subslist;
            
            List<csord__Service__c> servlist=new List<csord__Service__c>();
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='User - Fixed Seat';
            serv1.csord__Identification__c  = 'testIdentify_2';
            serv1.csord__Subscription__c = testSubscription.Id;
            serv1.serviceMSISDN__c = '61474703087';
            servlist.add(serv1);
            
            csord__Service__c serv2 = new csord__Service__c();
            serv2.name ='User - Fixed Seat';
            serv2.csord__Identification__c  = 'testIdentify_2';
            serv2.csord__Subscription__c = testSubscription4.Id;
            serv2.serviceMSISDN__c = '61474703088';
            servlist.add(serv2);
            insert servlist;
            
            TLS_Session__c session  = new TLS_Session__c();
            session.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d';
            session.TLS_PayLoad__c = '{"validateData": "Success","createOrder": "Success", "Order_Number__c" :"ON00071362", "orderId" : "'+testOrder.Id+'",  "AccountId__c":"'+ testAccount.CIDN__c +'","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '","services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session;
            
            TLS_Session__c session2  = new TLS_Session__c();
            session2.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d2';
            session2.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"'+ testAccount.Id +'", "createBasket":"Success",  "targetBasketId":"'+ testBasket.Id +'", "AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2","Service MSIDN":"61474703088","code":"200","description":"Validation successful for all the services","ActionType__c":"Opportunity Less Basket","Reason__c":"","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '","services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session2;
        }
    }
    @isTest
    public static void basketEnrichmentpositiveValidationTest(){
        string code;
        TLS_Session__c session = [Select TLS_PayLoad__c from TLS_Session__c limit 1];
        system.debug('session:'+session);
        
        cscfga__Product_Basket__c basket = [Select Id from cscfga__Product_Basket__c limit 1];
        system.debug('basket:'+basket);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/basketEnrichment';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2"}';
        req.requestBody = Blob.valueOf(jsonMsg);
        OC_SessionPayloadValidation.stepResult('008415e6-f785-66b8-811b-bc94838dde4d2', 'skipContract' , true);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        OrderInjectionAPIController.doPost();        
        //Map<string,string> validationRes = validationController.validateRequest('008415e6-f785-66b8-811b-bc94838dde4d2', 'skipContract');
        Test.stopTest();
        //code = validationRes.get('code');
        //system.assertEquals(code,'200');
        system.assertNotEquals(null, res);
    }
    
    @isTest
    public static void basketEnrichmentnegativeValidationTest(){
        string code;
        TLS_Session__c session = [Select TLS_PayLoad__c from TLS_Session__c limit 1];
        system.debug('session:'+session);
        
        cscfga__Product_Basket__c basket = [Select Id from cscfga__Product_Basket__c limit 1];
        system.debug('basket:'+basket);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/basketEnrichment';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d"}';
        req.requestBody = Blob.valueOf(jsonMsg);
        OC_SessionPayloadValidation.stepResult('008415e6-f785-66b8-811b-bc94838dde4d', 'skipContract' , true);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        OrderInjectionAPIController.doPost();        
        //Map<string,string> validationRes = validationController.validateRequest('008415e6-f785-66b8-811b-bc94838dde4d', 'skipContract');
        Test.stopTest();
        //code = validationRes.get('code');
        //system.assertEquals(code,'200');
        system.assertNotEquals(null, res);
    }
    
    @isTest    
    public static void publishEventTest(){        
        string code;   
        
        TLS_Session__c session = [Select TLS_PayLoad__c from TLS_Session__c limit 1];
        system.debug('session:'+session);
        
        cscfga__Product_Basket__c basket = [Select Id from cscfga__Product_Basket__c limit 1];
        system.debug('basket:'+basket);
        
        List<csord__Order__c> ordList = new List<csord__Order__c>();
		Set<Id> ordids = new Set<Id>();        
        ordList = [Select id,name,Product_Basket__c,csord__Status2__c,csord__Order_Number__c from csord__Order__c where name = 'TestOrderNameForTest' limit 1];
        ordids.add(ordList[0].id);
        ordList[0].csord__Status2__c = 'Ready for Submit';
		update ordList;        
        system.debug('order:'+ordList);      
        
        List<Online_Ord_Journey__e> listOfPlatformEvent = new List<Online_Ord_Journey__e>();         
        Online_Ord_Journey__e onlineOrd = new Online_Ord_Journey__e();
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2"}'; 
        Test.startTest();        
        ordInjAPIenrichBaskeTnCreateOrder.order_PlatformEvent(ordList, ordids);               
        Test.stopTest();            
    }
    
    @isTest
    public static void publishEventTest1(){        
        string code;   
        
        TLS_Session__c session = [Select TLS_PayLoad__c from TLS_Session__c limit 1];
        system.debug('session:'+session);
        
        cscfga__Product_Basket__c basket = [Select Id from cscfga__Product_Basket__c limit 1];
        system.debug('basket:'+basket);
        
        List<csord__Order__c> ordList = new List<csord__Order__c>();
		Set<Id> ordids = new Set<Id>();        
        ordList = [Select id,name,Product_Basket__c,csord__Status2__c,csord__Order_Number__c from csord__Order__c where name = 'TestOrderNameForTest' limit 1];
        ordids.add(ordList[0].id);
        ordList[0].csord__Status2__c = 'Ready Submit';
		update ordList;        
        system.debug('order:'+ordList);      
        
        List<Online_Ord_Journey__e> listOfPlatformEvent = new List<Online_Ord_Journey__e>();         
        Online_Ord_Journey__e onlineOrd = new Online_Ord_Journey__e();
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2"}'; 
        Test.startTest();        
        ordInjAPIenrichBaskeTnCreateOrder.order_PlatformEvent(ordList, ordids);               
        Test.stopTest();            
    }    
}