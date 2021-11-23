/*****
Code Coverage for Classes : CheckAsyncJobDetails
CreatedBy : Kamlesh Kumar
CreatedDate : 15 Dec 2020
******/
@IsTest
public class CheckAsyncJobDetailsTest {
    @testSetup static void createTestData() {
        
        Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'cwp');
        Sync_Control_and_Constants__c s2 = new Sync_Control_and_Constants__c(Name = 'Telstra Collaboration');
        Sync_Control_and_Constants__c s3 = new Sync_Control_and_Constants__c(Name = 'Corporate Mobile Plus');
        Sync_Control_and_Constants__c s4 = new Sync_Control_and_Constants__c(Name = 'Basket_Not_Valid_For_Sync',value__c = 'test');
        
        list<Sync_Control_and_Constants__c> slist = new list<Sync_Control_and_Constants__c>{s1,s2,s3,s4};
            insert slist;
        
        Account acc = ProductTestService.getNewAccount('Test Account');
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Account__c = acc.id;
        billingAccount.Status__c = 'final';
        insert billingAccount;
        
        Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id,Phone='');
        insert cont;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        
        List<cscfga__Product_Basket__c> basketLists = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'IoT Basket';
        basket.Device_Care_Contact__c = cont.Id;
        basket.cscfga__Basket_Status__c = 'valid';
        basket.Order_Requester__c =cont.Id;
        basket.csordtelcoa__Basket_Stage__c ='Draft';
        basket.sync_job_Id__c = '[{"name":"syncJobId","id":"123"}]';
        basket.csbb__Synchronised_with_Opportunity__c =false;
        basketLists.add(basket);
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'IoT Basket';
        basket1.Device_Care_Contact__c = cont.Id;
        basket1.cscfga__Basket_Status__c = 'valid';
        basket1.Order_Requester__c =cont.Id;
        basket1.csordtelcoa__Basket_Stage__c ='Draft';
        basket1.csbb__Synchronised_with_Opportunity__c =false;
        basket1.sync_job_Id__c = '{"name":"syncJobId","id":"123"}';
        basketLists.add(basket1);
        insert basketLists;
        CustomConfigurationOptions__c customConfig = new CustomConfigurationOptions__c(Name='ContractInitiate',Enrichment_Basket_Stage__c='Contract Initiated',External_Id__c='7842',MarketableOfferList__c='');
        insert customConfig;
    }
    @isTest
    static void toCheckSyncJobCompletionTest() {
        
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        Set<String> setProductBasketId = new Set<String>();
        setProductBasketId.add(basket.id);
        
        Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.id = basket.id;
        basket1.sync_job_Id__c = '[{"name":"syncJobId","id":"'+jobId+'"}]'; //EDGE-199074
        update basket1;
        
        System.Test.startTest();
        Map <String,AsyncApexJob> asyncApexPositiveMap = new Map <String,AsyncApexJob>();
        Map <String,AsyncApexJob> asyncApexNegativeMap = new Map <String,AsyncApexJob>();
        try {
            asyncApexPositiveMap = CheckAsyncJobDetails.toCheckSyncJobCompletion(new List<String>{jobId});
            asyncApexNegativeMap = CheckAsyncJobDetails.toCheckSyncJobCompletion(new List<String>{null});
        }catch(Exception e) {
            
        }
        system.assertEquals(true,asyncApexPositiveMap.size()>0);
        system.assertEquals(false,asyncApexNegativeMap.size()>0);
        System.Test.stopTest();
    }
    
    @isTest
    static void getJobIdTest() {
        List<cscfga__Product_Basket__c> basketList = [select id,cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 2];
        Set<String> setProductBasketId = new Set<String>();
        setProductBasketId.add(basketList[0].id);
        
        Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.id = basketList[0].id;
        basket1.sync_job_Id__c = '[{"name":"syncJobId","id":"'+jobId+'"}]'; //EDGE-199074
        update basket1;
        
        System.Test.startTest();
        Map <String,CheckAsyncJobDetails.AsyncJobIdWrapper> oppSyncJobIdMap = new Map <String,CheckAsyncJobDetails.AsyncJobIdWrapper>();
        Map <String,CheckAsyncJobDetails.AsyncJobIdWrapper> syncJobIdIdMap = new Map <String,CheckAsyncJobDetails.AsyncJobIdWrapper>();
        Map <String,CheckAsyncJobDetails.AsyncJobIdWrapper> JobIdIdMap = new Map <String,CheckAsyncJobDetails.AsyncJobIdWrapper>();
        try {
            oppSyncJobIdMap = CheckAsyncJobDetails.getJobId('oppSyncJobId',basket1.id);
            syncJobIdIdMap = CheckAsyncJobDetails.getJobId('syncJobId',basket1.id);
            JobIdIdMap = CheckAsyncJobDetails.getJobId('syncJobId',basketList[1].id);
        }catch(Exception e) {
            
        }
        
        system.assertEquals(true,oppSyncJobIdMap.size()>0);
        system.assertEquals(true,syncJobIdIdMap.size()>0);
        system.assertEquals(false,JobIdIdMap.size()>0);
        System.Test.stopTest();
    }
    
    @isTest
    static void checkLastRunningApexJobStatusTest() {
        List<cscfga__Product_Basket__c> basketList = [select id,cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 2];
        Set<String> setProductBasketId = new Set<String>();
        setProductBasketId.add(basketList[0].id);
        
        Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.id = basketList[0].id;
        basket1.sync_job_Id__c = '[{"name":"syncJobId","id":"'+jobId+'"}]'; //EDGE-199074
        update basket1;
        
        System.Test.startTest();
        Boolean lastStatus1;
        Boolean lastStatus2;
        Boolean lastStatus3;
        try {
            lastStatus1 = CheckAsyncJobDetails.checkLastRunningApexJobStatus('','syncJobId');
            lastStatus2 = CheckAsyncJobDetails.checkLastRunningApexJobStatus(basket1.sync_job_Id__c,'syncJobId');
            lastStatus3 = CheckAsyncJobDetails.checkLastRunningApexJobStatus('{"name":"syncJobId","id":"'+jobId+'"}','syncJobId');
        }catch(Exception e) {
            
        }
        
        system.assertEquals(false,lastStatus1);
        system.assertEquals(false,lastStatus2);
        system.assertNotEquals(true,lastStatus3);
        System.Test.stopTest();
    }
    
    @isTest
    static void fetchBasketDetailsTest() {
        List<cscfga__Product_Basket__c> basketList = [select id,cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 2];
        Set<String> setProductBasketId = new Set<String>();
        setProductBasketId.add(basketList[0].id);
        
        Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.id = basketList[0].id;
        basket1.sync_job_Id__c = '[{"name":"syncJobId","id":"'+jobId+'"}]'; //EDGE-199074
        basket1.Primary_Basket__c = true; // adding for DIGI-24328
        update basket1;

        // adding for DIGI-24328
        Opportunity opp = [Select Id from Opportunity limit 1 ];
        
        System.Test.startTest();
        Map <String,cscfga__Product_Basket__c> basketMap = new Map <String,cscfga__Product_Basket__c>();
        try {
            basketMap = CheckAsyncJobDetails.fetchBasketDetails(new List<String>{basket1.id});
            // adding for DIGI-24328
            cscfga__Product_Basket__c primaryBasket = CheckAsyncJobDetails.fetchPrimaryBasketDetails(opp.Id);
            system.assertEquals(primaryBasket.Id,basket1.Id); 
            // adding for DIGI-24328
        }catch(Exception e) {
            
        }
        
        system.assertEquals(true,basketMap.size()>0);
        System.Test.stopTest();
    }
    
    @isTest
    static void fetchSyncControlMessageTest() {    
        System.Test.startTest();
        Map <String,Sync_Control_and_Constants__c> messageMap = new Map <String,Sync_Control_and_Constants__c>();
        try {
            messageMap = CheckAsyncJobDetails.fetchSyncControlMessage();
        }catch(Exception e) {
            
        }
        
        system.assertEquals(true,messageMap.size()>0);
        System.Test.stopTest();
    }
    
    @isTest
    static void handleExceptionTest() {    
        System.Test.startTest();
        String response;
        try {
            response = CheckAsyncJobDetails.handleException('getJobId','Error','Error');
        }catch(Exception e) {
            system.assertEquals(true,response=='success');    
        }
        System.Test.stopTest();
    }
    
}