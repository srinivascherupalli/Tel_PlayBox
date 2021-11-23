@isTest
public class ordInjAPISkipContractTest {

     @TestSetup static void dataSetup()
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
            testConfig.cssdm__solution_association__c=sol.Id;
            prodconfigList.add(testConfig);
            insert prodconfigList;
            
            csord__Order__c testOrder = new csord__Order__c();
            testOrder.csord__Account__c = testAccount.Id;
            testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
            testOrder.Name = 'TestOrderNameForTest';
            testOrder.csord__Identification__c = 'test';
            testOrder.isMSISDNHeld__c = false;
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
            session.TLS_PayLoad__c = '{"herokuMACDSolution":"Success","TonGUID":"325726c1-1c6e-646b-f584-680f809d4c5e","secondayMSDIDN":"2255667789","Service MSIDN":"61436974052","validateData": "Success", "AccountId__c":"'+ testAccount.Id +'","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"Opportunity Less Basket","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '", "createBasket": "Success", "targetBasketId" : "'+ testBasket.Id +'", "oldsolutionId":"'+ sol.Id + '", "services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session;

            TLS_Session__c session1  = new TLS_Session__c();
            session1.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde5g';
            session1.TLS_PayLoad__c = '{"TonGUID":"325726c1-1c6e-646b-f584-680f809d4c5e","secondayMSDIDN":"2255667789","ActionType__c":"Opportunity Less Basket","validateData":"Success","Subscription Number":"SN-000158021","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde5g","Service MSIDN":"61436974052","AccountId__c":"0015P000004o88JQAQ","code":"200","description":"Validation successful for all the services","status":"Success","flowName":"validationController","createBasket":"Success","targetBasketId":"'+ testBasket.Id +'", "oldsolutionId":"a4f5P0000002REqQAM","targetSolutionId":"'+ sol.Id + '", "targetMainConfigurationId":"a3T5P00000070bsUAA"}';
            insert session1;
            
            TLS_Session__c session2  = new TLS_Session__c();
            session2.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838ddekjkj';
            session2.TLS_PayLoad__c = '{"TonGUID":"325726c1-1c6e-646b-f584-680f809d4c5e","secondayMSDIDN":"2255667789","Service MSIDN":"61436974052","validateData": "Success", "createOrder":"Success", "AccountId__c":"'+ testAccount.Id +'","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838ddekjkj","ActionType__c":"SIM Replacement", "orderRequest":"test", "orderNumber":"test", "services":"test","id":"test","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '"}';
            insert session2;
        }
    }
    
   
    
    @isTest
    public static void skipContractTest(){
        TLS_session__c tls = [Select TLS_PayLoad__c from TLS_Session__c where TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d'];
        system.debug('tls:'+tls);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/skipContract';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c": "008415e6-f785-66b8-811b-bc94838dde4d","solutions": [{"solutionId": "a4f5P0000001uVeQAI","action": "noChange","mainComponentConfigGUID": "70dcd247-605d-8255-8209-c2fcac4ba158","components": [{"componentName": "Enterprise Mobility","action": "noChange","configurations": [{"guid": ["70dcd247-605d-8255-8209-c2fcac4ba158"],"action": "noChange","quantity": 1,"relatedProducts": [{"guid": "325726c1-1c6e-646b-f584-680f809d4c5e","relatedProductName": "Telstra One Number","action": "add"}]}]}]}]}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        OrderInjectionAPIController.doPost();
        
        OC_SessionPayloadValidation.stepResult('008415e6-f785-66b8-811b-bc94838dde4d', 'herokuMACDSolution' , true);
              
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();    
        req1.requestURI = '/services/apexrest/v1/orderInjectionAPI/skipContract';  //Request URL
        req1.httpMethod = 'POST';//HTTP Request Type
        req1.addHeader('Content-Type', 'application/json'); 
        string jsonMsg1 = '{"CorrelationId__c": "008415e6-f785-66b8-811b-bc94838dde4d","solutions": [{"solutionId": "a4f5P0000001uVeQAI","action": "noChange","mainComponentConfigGUID": "70dcd247-605d-8255-8209-c2fcac4ba158","components": [{"componentName": "Enterprise Mobility","action": "noChange","configurations": [{"guid": ["70dcd247-605d-8255-8209-c2fcac4ba158"],"action": "noChange","quantity": 1,"relatedProducts": [{"guid": "325726c1-1c6e-646b-f584-680f809d4c5e","relatedProductName": "Telstra One Number","action": "add"}]}]}]}]}';
        req1.requestBody = Blob.valueOf(jsonMsg1);
        RestContext.request = req1;
        RestContext.response= res1;
       
        OrderInjectionAPIController.doPost();
      
        system.debug('response:'+res1);
        system.assertNotEquals(null,res1);      
        
    }
    
    
    @isTest
    public static void skipContractTest3(){
        cscfga__Product_Basket__c testBasket = [Select Id from cscfga__Product_Basket__c limit 1];
        testBasket.cscfga__Opportunity__c = null;
        update testBasket;
        system.debug('testBasket:'+testBasket);
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();    
        req1.requestURI = '/services/apexrest/v1/orderInjectionAPI/skipContract';  //Request URL
        req1.httpMethod = 'POST';//HTTP Request Type
        req1.addHeader('Content-Type', 'application/json'); 
        string jsonMsg1 = '{"CorrelationId__wrong":"008415e6-f785-66b8-811b-bc94838dde4d","solutions": [{"solutionId": "a4f5P0000001uVeQAI","action": "noChange","mainComponentConfigGUID": "70dcd247-605d-8255-8209-c2fcac4ba158","components": [{"componentName": "Enterprise Mobility","action": "noChange","configurations": [{"guid": ["70dcd247-605d-8255-8209-c2fcac4ba158"],"action": "noChange","quantity": 1,"relatedProducts": [{"guid": "325726c1-1c6e-646b-f584-680f809d4c5e","relatedProductName": "Telstra One Number","action": "add"}]}]}]}]}}';
        req1.requestBody = Blob.valueOf(jsonMsg1);
        RestContext.request = req1;
        RestContext.response= res1;
         
       
        OrderInjectionAPIController.doPost();


    }
    
     public static void skipContractTest2(){
        cscfga__Product_Basket__c testBasket = [Select Id from cscfga__Product_Basket__c limit 1];
        testBasket.cscfga__Basket_Status__c = 'Commercial Configuration';
        update testBasket;
        system.debug('testBasket:'+testBasket);
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();    
        req1.requestURI = '/services/apexrest/v1/orderInjectionAPI/skipContract';  //Request URL
        req1.httpMethod = 'POST';//HTTP Request Type
        req1.addHeader('Content-Type', 'application/json'); 
        string jsonMsg1 = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d,"solutions": [{"solutionId": "a4f5P0000001uVeQAI","action": "noChange","mainComponentConfigGUID": "70dcd247-605d-8255-8209-c2fcac4ba158","components": [{"componentName": "Enterprise Mobility","action": "noChange","configurations": [{"guid": ["70dcd247-605d-8255-8209-c2fcac4ba158"],"action": "noChange","quantity": 1,"relatedProducts": [{"guid": "325726c1-1c6e-646b-f584-680f809d4c5e","relatedProductName": "Telstra One Number","action": "add"}]}]}]}]}}';
        req1.requestBody = Blob.valueOf(jsonMsg1);
        RestContext.request = req1;
        RestContext.response= res1;         
       
        OrderInjectionAPIController.doPost();

    }
        @isTest
        public static void createHerokuMACDSolution(){
            TLS_session__c tls = [Select TLS_PayLoad__c from TLS_Session__c where TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde5g'];
            system.debug('tls:'+tls);
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();    
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/herokuMACDSolution';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.addHeader('Content-Type', 'application/json'); 
            string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde5g"}';
            req.requestBody = Blob.valueOf(jsonMsg);
            RestContext.request = req;
            RestContext.response= res;
           
            OrderInjectionAPIController.doPost();
            
            /*OC_SessionPayloadValidation.stepResult('008415e6-f785-66b8-811b-bc94838dde5g', 'createBasket' , true);
                  
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();    
            req1.requestURI = '/services/apexrest/v1/orderInjectionAPI/herokuMACDSolution';  //Request URL
            req1.httpMethod = 'POST';//HTTP Request Type
            req1.addHeader('Content-Type', 'application/json'); 
            string jsonMsg1 = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde5g"}';
            req1.requestBody = Blob.valueOf(jsonMsg1);
            RestContext.request = req1;
            RestContext.response= res1;
           
            OrderInjectionAPIController.doPost();*/
        }
        
        
        @isTest
        public static void testUpdateServices(){
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();    
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/updateServices';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.addHeader('Content-Type', 'application/json'); 
            string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838ddekjkj}';
            req.requestBody = Blob.valueOf(jsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            OrderInjectionAPIController.doPost();
        }

        //DIGI-34844
        @isTest
        public static void skipContractTest4(){
            cscfga__Product_Basket__c testBasket = [Select Id from cscfga__Product_Basket__c limit 1];
            testBasket.cscfga__Opportunity__c = null;
            update testBasket;
            system.debug('testBasket:'+testBasket);
            
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();    
            req1.requestURI = '/services/apexrest/v1/orderInjectionAPI/skipContract';  //Request URL
            req1.httpMethod = 'POST';//HTTP Request Type
            req1.addHeader('Content-Type', 'application/json'); 
            string jsonMsg1 = '{"CorrelationId__c": "008415e6-f785-66b8-811b-bc94838dde4d","solutions": [{"solutionId": "a4f5P0000001uVeQAI","action": "noChange","mainComponentConfigGUID": "70dcd247-605d-8255-8209-c2fcac4ba158","components": [{"componentName": "Enterprise Mobility","action": "noChange","configurations": [{"guid": ["70dcd247-605d-8255-8209-c2fcac4ba158"],"action": "noChange","quantity": 1,"relatedProducts": [{"guid": "325726c1-1c6e-646b-f584-680f809d4c5e","relatedProductName": "Telstra One Number","action": "add"}]}]}]}]}';
            
            req1.requestBody = Blob.valueOf(jsonMsg1);
            RestContext.request = req1;
            RestContext.response= res1;
             
           
            OrderInjectionAPIController.doPost();
    
    
        }
}