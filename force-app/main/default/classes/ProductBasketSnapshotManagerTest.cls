//updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
@isTest
public class ProductBasketSnapshotManagerTest {
	testMethod static void CS_BasketSnapshotManagerTest1() {
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
            Account account = new Account(
                OwnerId = UserInfo.getUserId(),
                Name = 'Account',
                Type = 'End Customer',
                Customer_Status__c = 'ACTIVE'											 
            );
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
			
			cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'ServiceabilityLocation',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad3;
			
			cscfga__Attribute_Definition__c ad4 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'ResponseTime',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad4;
			
			cscfga__Attribute_Definition__c ad5 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'RestorationTime',
                Snapshot_Attribute_Value_Field__c = 'Text__c',
                Snapshot_Attribute_Fields__c = 'Test'
            );
            insert ad5;

            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
                Name = 'New Basket',
                OwnerId = UserInfo.getUserId(),
                cscfga__Opportunity__c = opportunity.Id,
                //csordtelcoa__Synchronised_with_Opportunity__c = false,
                Used_Snapshot_Objects__c = '[CS_Basket_Snapshot_Transactional__c]'
            );
            insert basket;
            
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='IP Site'
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

            cscfga__Attribute__c att2 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'ServiceabilityLocation',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att2;

            cscfga__Attribute__c att3 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'ResponseTime',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att3;

            cscfga__Attribute__c att4 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pc1.Id,
                Name = 'RestorationTime',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = ad.Id
            );
            insert att4;
            
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                cscfga__Parent_Configuration__c = pc1.Id,
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
            
            
            
            
            
            
            
            List<Id> basketList = new List<Id>{basket.Id};
            List<cscfga__Product_Basket__c> basketList2 = new List<cscfga__Product_Basket__c>{basket};
            Test.startTest();
            //CS_BasketSnapshotManager.TakeBasketSnapshotById(basket.Id,true);
            //CS_BasketSnapshotManager.TakeBasketsSnapshotById(basketList,true);
            //CS_BasketSnapshotManager.TakeBasketSnapshot(basket,true);
           
            ProductBasketSnapshotManager.TakeBasketSnapshotData(basketList2,new Map<String,String> ());
            
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
            
            
            //CS_BasketSnapshotManager.TakeBasketsSnapshot(basketList2,true);
            List<sObject> objs = ProductBasketSnapshotManager.TakeBasketSnapshotData(basketList2,new Map<String,String> ());
            Test.stopTest();
            system.assert(!objs.isEmpty());
        }
    }
    
    testMethod static void ProductBasketSnapshotManagerTest() {
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
            Account account = new Account(
                OwnerId = UserInfo.getUserId(),
                Name = 'Account',
                Type = 'End Customer',
                Customer_Status__c = 'ACTIVE'
            );
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
            
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='IP Site'
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
            

            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                cscfga__Parent_Configuration__c = pc1.id,
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
            
            
            
            
            
            
            
            List<Id> basketList = new List<Id>{basket.Id};
            List<cscfga__Product_Basket__c> basketList2 = new List<cscfga__Product_Basket__c>{basket};
            Test.startTest();
            //CS_BasketSnapshotManager.TakeBasketSnapshotById(basket.Id,true);
            //CS_BasketSnapshotManager.TakeBasketsSnapshotById(basketList,true);
            //CS_BasketSnapshotManager.TakeBasketSnapshot(basket,true);
           
            ProductBasketSnapshotManager.TakeBasketSnapshotData(basketList2,new Map<String,String> ());
            
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
            
            
            //CS_BasketSnapshotManager.TakeBasketsSnapshot(basketList2,true);
            List<sObject> objs = ProductBasketSnapshotManager.TakeBasketSnapshotData(basketList2,new Map<String,String> ());
            Test.stopTest();
            system.assert(!objs.isEmpty());
        }
    }
    
        
    //US - 10811
    testMethod static void PBSnapshotManagerCommercialConfigTest() {
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
            Account account = new Account(
                OwnerId = UserInfo.getUserId(),
                Name = 'Account',
                Type = 'End Customer',
                Customer_Status__c = 'ACTIVE'											 
            );
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
            
            
            cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                Name='IP Site'
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
            

            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
                cscfga__Product_Definition__c = pd.Id,   
                cscfga__Product_Basket__c = basket.Id,
                cscfga__Parent_Configuration__c = pc1.id,
                Commercial_Config__c = 'Yes',
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
            
            
            
            
            
            
            
            List<Id> basketList = new List<Id>{basket.Id};
            List<cscfga__Product_Basket__c> basketList2 = new List<cscfga__Product_Basket__c>{basket};
            Test.startTest();
            //CS_BasketSnapshotManager.TakeBasketSnapshotById(basket.Id,true);
            //CS_BasketSnapshotManager.TakeBasketsSnapshotById(basketList,true);
            //CS_BasketSnapshotManager.TakeBasketSnapshot(basket,true);
           
            ProductBasketSnapshotManager.TakeBasketSnapshotData(basketList2,new Map<String,String> ());
            
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
            Map<String,String> subfilters = new Map<String,String> ();
			subfilters.put('Commercial_Config','Yes');
            
            //CS_BasketSnapshotManager.TakeBasketsSnapshot(basketList2,true);
            List<sObject> objs = ProductBasketSnapshotManager.TakeBasketSnapshotData(basketList2,subfilters);
            Test.stopTest();
            system.assert(!objs.isEmpty());
        }
    }
    
}