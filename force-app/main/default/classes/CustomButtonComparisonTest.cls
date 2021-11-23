@isTest
global class CustomButtonComparisonTest {
    @testsetup static void CustomButtonComparisonDataSetup()
    {
        Profile pf = [select Id,Name from profile where name ='Sales Manager - Enterprise'];
        //CREATE USER
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pf.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com');
        
        insert usr;
        System.runAs(usr){
            Test.startTest();
            
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Migrated_Customer__c = true;
            acc.Customer_Status__c='Active';
			//Modified by Sri, team SFO on 16/01/2020
			//P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
            acc.Imported__c = true;
            insert acc;
            System.assertNotEquals(null,acc);
            
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            insert opp;
            System.assertNotEquals(null,opp);
            
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            insert basket;
            System.assertNotEquals(null,basket);
            /*
            //create Product Definition
            cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product','Test Product');
            insert prodDef;
            System.assertNotEquals(null,prodDef);
            
            //create Product Configuration
            List<cscfga__Product_Configuration__c> lstProdConfig = new List<cscfga__Product_Configuration__c>();
           
            cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
            prodConfig.cscfga__Product_Basket__c = basket.id;
            prodConfig.cscfga__Description__c = 'test Description';
            prodConfig.cscfga__Contract_Term__c = 36;
            lstProdConfig.add(prodConfig);
            
            cscfga__Product_Configuration__c prodConfig1 = ProductTestFactory.buildProductConfig(prodDef.Id);
            prodConfig1.cscfga__Product_Basket__c = basket.id;
            prodConfig1.cscfga__Description__c = 'test Description 1';
            prodConfig1.cscfga__Contract_Term__c = 36;
            lstProdConfig.add(prodConfig1);
            
            cscfga__Product_Configuration__c prodConfig2 = ProductTestFactory.buildProductConfig(prodDef.Id);
            prodConfig2.cscfga__Product_Basket__c = basket.id;
            prodConfig2.cscfga__Description__c = 'test Description 2';
            prodConfig2.cscfga__Contract_Term__c = 36;
            lstProdConfig.add(prodConfig2);
            
            cscfga__Product_Configuration__c prodConfig3 = ProductTestFactory.buildProductConfig(prodDef.Id);
            prodConfig3.cscfga__Product_Basket__c = basket.id;
            prodConfig3.cscfga__Description__c = 'test Description 3';
            prodConfig3.cscfga__Contract_Term__c = 36;
            lstProdConfig.add(prodConfig3);
            System.assertNotEquals(null,lstProdConfig);
            insert lstProdConfig;
            
            
            List<csbb__Product_Configuration_Request__c> lstProdConfigReq = new List<csbb__Product_Configuration_Request__c>();
            for(cscfga__Product_Configuration__c prodConfigration : lstProdConfig)
            {
                lstProdConfigReq.add(ProductTestFactory.buildConfigRequest(basket.id,prodConfigration.Id));
            }
            System.assertNotEquals(null,lstProdConfigReq);
            insert lstProdConfigReq;
            
            */
            EnvironmentVariable__c env_var=	 new EnvironmentVariable__c();
            env_var.name='TransitionVersion';
            env_var.value__c='2';
            insert env_var;
            //EnvironmentVariable__c env_var1= new EnvironmentVariable__c();
            //env_var1.name=TransitionVersion;
            //env_var1.value=3;
            Test.stopTest();
            
        }
    }
    
    
    static testmethod void checkTestForSalesEnterprise()
    {   
        Profile pf = [select Id,Name from profile where name ='Sales - Enterprise'];
        User usr = [select Id,UserName from User where UserName = 'standarduser@telestra.com'];
        usr.ProfileId = pf.Id;
        update usr;
        System.runAs(usr)
        {
            Test.startTest();
            CustomButtonComparison obj=new CustomButtonComparison();
            List<cscfga__Product_Basket__c> basket = [Select Id,Name from cscfga__Product_Basket__c];
            /*List<csbb__Product_Configuration_Request__c> lstProdConfigReq = [Select Id,Name from csbb__Product_Configuration_Request__c];
            for(csbb__Product_Configuration_Request__c prodConfigReq : lstProdConfigReq)
            {
                sProdConfigReqIds += prodConfigReq.Id + ',';
            }*/
            String result = obj.performAction(string.valueOf(basket[0].Id), null);
			System.assert(String.isNotBlank(result));	
			EnvironmentVariable__c env_var=	EnvironmentVariable__c.getValues('TransitionVersion');
            env_var.value__c='3';
            update env_var;
			String result1 = obj.performAction(string.valueOf(basket[0].Id), null);
            Map<String, Object> inputMap = new Map<String, Object> ();
            inputMap.put('GetBasket',basket[0].Id);
            CustomButtonComparison.getData(inputMap);
			System.assert(String.isNotBlank(result1));
            String result2 = obj.performAction(string.valueOf(basket[0].Id));
            system.assertEquals(null, result2);
            Test.stopTest();
        }            
        
    }
    
}