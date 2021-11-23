@isTest  
private class CS_BasketSnapshotManagerTest 
{   
    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', 'http://mocksandbox.getsandbox.com/MockService');
        
        Interface_Activation__c iActivation=new Interface_Activation__c(name='Manage Contact');
        iActivation.Status__c=false;
        insert iActivation;
        Interface_Activation__c iActivation2=new Interface_Activation__c(name='Manage Customer');
        iActivation2.Status__c=false;
        insert iActivation2;
        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        iSettings.EnableManageInterfaces__c=true;
        insert iSettings;
    }
    
    //EDGE-144008
    @isTest
    private static void testClassConstructor()
    {       
        
    }
    
    testMethod static void cs_BasketSnapshotManagerTest1() {
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        List<Profile> pList = [select Id, Name from Profile where Name = 'System Administrator' LIMIT 1];
        List<UserRole> roleList = [select Id, Name, DeveloperName From UserRole u where ParentRoleId = null];
        ID rId = roleList[0].Id;
        ID pId = pList[0].Id;
        
        User simpleUser = new User(
            UserRoleId = rId,
            ProfileId = pId,
            Alias = 'standard', 
            Email='standarduser@testorg.com',  
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testUserA@testorganise.com'
        );
        insert simpleUser;
        
        System.runAs (simpleUser) {
            /*Account account = new Account(
OwnerId = UserInfo.getUserId(),
Name = 'Account',
Type = 'End Customer'
);
*/
            //Insted of creating separate test data, using existing TestUtil factory method for creating Account. 
            //Sprint 19.17 P2OB-4149
            Account account=TestUtil.createAccount('Account');
            account.OwnerId = UserInfo.getUserId();
            account.Type = 'End Customer';
            insert account;
            
            Contact contact = new Contact(
                AccountId = account.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '0423456789',
                Email = 'test@tele2.com'   
            );
            insert contact;
            
            Opportunity opportunity = new Opportunity(
                Name = 'New Opportunity',
                OwnerId = UserInfo.getUserId(),
                StageName = 'Qualification',
                Probability = 0,
                CloseDate = system.today(),
                //ForecastCategoryName = 'Pipeline',
                AccountId = account.id
            );
            insert opportunity;
            
            cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
                Name = 'PD1',
                cscfga__Description__c = 'PD1 Desc',
                Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c'
            );
            insert pd;
            
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad;
            
            cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site name',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad1;
            
            cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site Address',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad2;
            
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
                Name = 'New Basket',
                OwnerId = UserInfo.getUserId(),
                cscfga__Opportunity__c = opportunity.Id,
                //csordtelcoa__Synchronised_with_Opportunity__c = false,
                Used_Snapshot_Objects__c = '[CS_Basket_Snapshot_Transactional__c]'
            );
            insert basket;
            
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='PC1'
            );
            insert pc;
            
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att;
            
            
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='Site'
            );
            insert pc1;
            
            cscfga__Attribute__c att0 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'Site name',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att0;
            
            cscfga__Attribute__c att1 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'Site Address',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att1;
            
            
            
            List<Id> basketList = new List<Id>{basket.Id};
                List<cscfga__Product_Basket__c> basketList2 = new List<cscfga__Product_Basket__c>{basket};
                    Test.startTest();
            CS_BasketSnapshotManager.TakeBasketSnapshotById(basket.Id,true);
            CS_BasketSnapshotManager.TakeBasketsSnapshotById(basketList,true);
            CS_BasketSnapshotManager.TakeBasketSnapshot(basket,true);
            
            //CS_BasketSnapshotManager.TakeBasketSnapshotData(basketList2);
            
            List<CS_Basket_Snapshot_Settings__c> i = [SELECT id FROM CS_Basket_Snapshot_Settings__c];
            if(!i.isEmpty()){
                CS_Basket_Snapshot_Settings__c customSetting1 = i.get(0);
                customSetting1.Output_Strategy__c = 'Attribute';
                customSetting1.Cleanup_Process__c = 'In Batch';
                update customSetting1;
            }else{
                CS_Basket_Snapshot_Settings__c customSetting1 = new CS_Basket_Snapshot_Settings__c();
                customSetting1.Output_Strategy__c = 'Attribute';
                customSetting1.Cleanup_Process__c = 'In Batch';
                insert customSetting1;
            }
            
            
            CS_BasketSnapshotManager.TakeBasketsSnapshot(basketList2,true);
            //List<sObject> objs = CS_BasketSnapshotManager.TakeBasketSnapshotData(basketList2);
            Test.stopTest();
            system.assert(i != null);
        }
    }
    
    //EDGE-144008
    testMethod static void cs_BasketSnapshotManagerTest2() {
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        List<Profile> pList = [select Id, Name from Profile where Name = 'System Administrator' LIMIT 1];
        List<UserRole> roleList = [select Id, Name, DeveloperName From UserRole u where ParentRoleId = null];
        ID rId = roleList[0].Id;
        ID pId = pList[0].Id;
        
        User simpleUser = new User(
            UserRoleId = rId,
            ProfileId = pId,
            Alias = 'standard', 
            Email='standarduser@testorg.com',  
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testUserA@testorganise.com'
        );
        insert simpleUser;
        
        System.runAs (simpleUser) {
            /*Account account = new Account(
OwnerId = UserInfo.getUserId(),
Name = 'Account',
Type = 'End Customer'
);
*/
            //Insted of creating separate test data, using existing TestUtil factory method for creating Account. 
            //Sprint 19.17 P2OB-4149
            Account account=TestUtil.createAccount('Account');
            account.OwnerId = UserInfo.getUserId();
            account.Type = 'End Customer';
            insert account;
            
            Contact contact = new Contact(
                AccountId = account.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '0423456789',
                Email = 'test@tele2.com'   
            );
            insert contact;
            
            Opportunity opportunity = new Opportunity(
                Name = 'New Opportunity',
                OwnerId = UserInfo.getUserId(),
                StageName = 'Qualification',
                Probability = 0,
                CloseDate = system.today(),
                //ForecastCategoryName = 'Pipeline',
                AccountId = account.id
            );
            insert opportunity;
            
            cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
                Name = 'PD1',
                cscfga__Description__c = 'PD1 Desc',
                Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c'
            );
            insert pd;
            
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad;
            
            cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site name',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad1;
            
            cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'Site Address',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad2;
            
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
                Name = 'New Basket',
                OwnerId = UserInfo.getUserId(),
                cscfga__Opportunity__c = opportunity.Id,
                //csordtelcoa__Synchronised_with_Opportunity__c = false,
                Used_Snapshot_Objects__c = '[CS_Basket_Snapshot_Transactional__c]'
            );
            insert basket;
            
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='PC1'
            );
            insert pc;
            
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att;
            
            
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='Site'
            );
            insert pc1;
            
            cscfga__Attribute__c att0 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'Site name',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att0;
            
            cscfga__Attribute__c att1 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'Site Address',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att1;
            
            
            
            List<Id> basketList = new List<Id>{basket.Id};
                List<cscfga__Product_Basket__c> basketList2 = new List<cscfga__Product_Basket__c>{basket};
                    Test.startTest();
            CS_BasketSnapshotManager.TakeBasketSnapshotById(basket.Id,true);
            CS_BasketSnapshotManager.TakeBasketsSnapshotById(basketList,true);
            CS_BasketSnapshotManager.TakeBasketSnapshot(basket,true);
            
            //CS_BasketSnapshotManager.TakeBasketSnapshotData(basketList2);
            
            List<CS_Basket_Snapshot_Settings__c> i = [SELECT id FROM CS_Basket_Snapshot_Settings__c];
            if(!i.isEmpty()){
                CS_Basket_Snapshot_Settings__c customSetting1 = i.get(0);
                customSetting1.Output_Strategy__c = 'Product Configuration';
                customSetting1.Cleanup_Process__c = 'In Batch';
                update customSetting1;
            }else{
                CS_Basket_Snapshot_Settings__c customSetting1 = new CS_Basket_Snapshot_Settings__c();
                customSetting1.Output_Strategy__c = 'Product Configuration';
                customSetting1.Cleanup_Process__c = 'In Batch';
                insert customSetting1;
            }
            
             CS_BasketSnapshotManager controller = new CS_BasketSnapshotManager() ;
            CS_BasketSnapshotManager.TakeBasketsSnapshot(basketList2,true);
            //List<sObject> objs = CS_BasketSnapshotManager.TakeBasketSnapshotData(basketList2);
            Test.stopTest();
            system.assert(i != null);
        }
    }
}