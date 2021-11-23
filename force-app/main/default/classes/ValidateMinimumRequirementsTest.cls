/*Shubhi V 			06-July-2020    EDGE-147513    BillingAcc checks
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated offer name using variable NGUC_OFFER_NAME from Telstra_Collaboration to Adaptive Collaboration
//Last Modified : updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
*/
@isTest
public class ValidateMinimumRequirementsTest {
    static String PROD_CONFIGURATION_TYPE_MODIFY = 'Modify';
    @testsetup 
    static void testdata() { 
        
        //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;
        //CREATE CONTACT 
        Contact con1 = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '0423456789',
                Email = 'test@tele2.com'   
         );
        insert con1;    
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        
        insert pbe;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Basket
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Project_ID__c = 'basket1';
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp.id;
        basket2.Project_ID__c = 'basket2';
        cscfga__Product_Basket__c basket3 = ProductTestFactory.buildEmptyBasket();
        basket3.csbb__Account__c = acc.id;
        basket3.cscfga__Opportunity__c = opp.id;
        basket3.Project_ID__c = 'basket3';
        insert new List<cscfga__Product_Basket__c>{basket1,basket2,basket3};
        
       
        //create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket1.id;
        config.Name = System.Label.Label_CWP;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
        update config;
        //EDGE-147513 start --------------------------
        csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
        insert new List<csord__Solution__c>{sol1,sol2};
        cscfga__Product_Configuration__c pc1_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent',' 	 ',basket1.id,sol1.id,'');
        cscfga__Product_Configuration__c pc1_new= PricingTestDataFactory.generateProductConfiguration('','New',basket1.id,sol1.id,'');
        cscfga__Product_Configuration__c pc2_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket2.id,sol2.id,'');
        cscfga__Product_Configuration__c pc2_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket2.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','New',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_modify= PricingTestDataFactory.generateProductConfiguration('','Modify',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_new= PricingTestDataFactory.generateProductConfiguration('','New',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket3.id,sol2.id,'');

        insert new List<cscfga__Product_Configuration__c>{pc1_sol,pc1_new,pc2_sol,pc2_cancel,pc3_sol,pc3_modify,pc3_new,pc3_cancel};
        //Biiling accs
        Billing_Account__c billAcc1=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=con1.Id, status__c='Created',Account__c=acc.id);
        Billing_Account__c billAcc2=new Billing_Account__c(Billing_Account_Number__c='123456789013',Billing_Account_Owner__c=con1.Id,status__c='Final',Account__c=acc.id);
        insert new List<Billing_Account__c>{billAcc1,billAcc2};
        //attributes
        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc1.id , pc1_sol.id);
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc2_sol.id);
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc3_sol.id);
        insert new List<cscfga__Attribute__c>{attr0,attr1,attr2};
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
         // //EDGE-147513 end --------------------------
    }
    
    //test Run Without Error 
    @isTest 
    static void testRunWithNoProduct() {
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='ValidationIPUCE';
        env_var.value__c='1';
        insert env_var;       
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        delete config;
        String result = ValidateMinimumRequirements.run(basket.Id);       
        Test.stopTest();   
        System.assertEquals('ok', result);
    } 

    @isTest 
    static void testRunWithNoProduct1() {
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='ValidationIPUCE';
        env_var.value__c='2';
        insert env_var;
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];       
        Test.startTest();
        cscfga__Product_Configuration__c config = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        delete config;
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
    }   
    
    
    //test Run With error
    @isTest static void testRunWithOneProductError() {  
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var; 
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        config1.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;     
        update config1;
        delete config;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();   
        System.assertEquals('ok', result);
    } 
 
    
     //test Run With error
    @isTest static void testRunWithOneProductError1() {  
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var; 
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36; 
        config1.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;        
        update config1;
        delete config;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();   
        System.assertEquals('ok', result);
    }  
    
    //test Run Without Error and 2 baskets
    @isTest 
    static void testRunWithTwoProducts() { 
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        update config1;
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
    } 
    
    
        @isTest 
    static void testRunWithTwoProducts1() { 
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        update config1;
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
    }
    
    //test run method with subscriptions in account
    @isTest 
    static void testRunWithSubscriptions() {
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        csord__Subscription__c subscriptionObj = new csord__Subscription__c();
        subscriptionObj  = ProductTestService.getSubscriptionObject(acc);
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
    }
    
     //test run method with subscriptions in account
    @isTest 
    static void testRunWithSubscriptions1() {
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        csord__Subscription__c subscriptionObj = new csord__Subscription__c();
        subscriptionObj  = ProductTestService.getSubscriptionObject(acc);
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
    }
    
    // test run without IP vPN products
    @isTest
    static void testRunWithoutIPVPNProduct() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];

        Test.startTest();
        csord__Subscription__c IPVPNSubObj = new csord__Subscription__c();
        IPVPNSubObj = ProductTestService.getSubscriptionObject(acc);
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c subs = ProductTestService.getNewSubscriptionForAccount(acc);
        subs.Name = System.Label.UC_Config_Name;
        lstSubs.add(subs);
        update lstSubs;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);
    }
    
    // test run without IP vPN products
    @isTest
    static void testRunWithoutIPVPNProduct1() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        Account acc = [Select id from Account];
        
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];       

        Test.startTest();
        
        csord__Subscription__c IPVPNSubObj = new csord__Subscription__c();
        IPVPNSubObj = ProductTestService.getSubscriptionObject(acc);
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c subs = ProductTestService.getNewSubscriptionForAccount(acc);
        subs.Name = System.Label.UC_Config_Name;
        lstSubs.add(subs);
        
        update lstSubs;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);
    }
    
    //Test run without UC enterprise product
    @isTest
    static void testRunWithoutUCEnterpriseProduct(){
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c subs = ProductTestService.getNewSubscriptionForAccount(acc);
        subs.Name = System.Label.IP_Network;
        lstSubs.add(subs);
        
        update lstSubs;
        
        System.debug('lstSubs ===>'+lstSubs);
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);
    }
    
    //Test run without UC enterprise product
    @isTest
    static void testRunWithoutUCEnterpriseProduct1(){
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c subs = ProductTestService.getNewSubscriptionForAccount(acc);
        subs.Name = System.Label.IP_Network;
        lstSubs.add(subs);
        
        update lstSubs;
        
        System.debug('lstSubs ===>'+lstSubs);
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);
    }
    
    //Test Run for two IPVPN products
    @isTest
    static void testRunWithTwoIPVPNProducts() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs1 = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs1.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs1);
        
        update lstSubs;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);    
    }
    
    //Test Run for two IPVPN products
    @isTest
    static void testRunWithTwoIPVPNProducts1() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs1 = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs1.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs1);
        
        update lstSubs;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);    
    }
    
    //TEST RUN for two UC Enterprise product
    
    @isTest
    static void testRunWithTwoUCEnterpriseProducts() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c UCEntersubs1 = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs1.Name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs1);
        
        update lstSubs;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);    
    }
    
    @isTest
    static void testRunWithTwoUCEnterpriseProducts1() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c UCEntersubs1 = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs1.Name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs1);
        
        update lstSubs;
        String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);    
    }
    
    //test run for one IP Site product
    @isTest
    static void testRunWithOneProductDelete() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        update config1;
        
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        update lstSubs;
        delete config1;
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
        
    }

 @isTest
    static void testRunWithOneProductDelete1() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        update config1;
        
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        update lstSubs;
        delete config1;
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
        
    }   
    //test run for ok 
    @isTest
    static void testRunWithAllProductPresent() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        update config1;
        System.debug('config1 ===>'+config1);
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basket.id;
        config2.Name = System.Label.Label_CWP;
        config2.cscfga__Description__c = 'test Description2 ';
        config2.cscfga__Contract_Term__c = 36;
        update config2;
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        update lstSubs;
        
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
        
    }
     @isTest
    static void testRunWithAllProductPresent1() {
    EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        
        Account acc = [Select id from Account];
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];
        Test.startTest();
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        update config1;
        System.debug('config1 ===>'+config1);
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basket.id;
        config2.Name = System.Label.Label_CWP;
        config2.cscfga__Description__c = 'test Description2 ';
        config2.cscfga__Contract_Term__c = 36;
        update config2;
        
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = System.Label.IP_Network;
        lstSubs.add(IpVpnsubs);
        
        csord__Subscription__c UCEntersubs = ProductTestService.getNewSubscriptionForAccount(acc);
        UCEntersubs.name = System.Label.UC_Config_Name;
        lstSubs.add(UCEntersubs);
        
        update lstSubs;
        
        
        String result = ValidateMinimumRequirements.run(basket.Id);
        
        Test.stopTest();   
        System.assertEquals('ok', result);
        
    }

    @isTest 
    static void testValidateOk(){
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        
        cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];     
   //cleanup basket
        List<cscfga__Product_Configuration__c> configList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id limit 1];
        DELETE configList;

        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        INSERT defIpSite;
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        INSERT defIpNetwork;
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        INSERT defUcEnterprise;
        
        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        for (Integer i=0; i < 10; i++){
            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            String confName = System.Label.Label_CWP;
            config.cscfga__Product_Definition__c = defIpSite.Id;
            
            if ( math.mod(i,8) == 0 ){
                confName = System.Label.IP_Network;
                config.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( math.mod(i,9) == 0) {
                confName = System.Label.UC_Enterprise;
                config.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            
            
            config.cscfga__Product_Basket__c = basket.id;
            config.Name = confName;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;

            prodConfigList.add(config);
        }
        update prodConfigList;
        
        //Create Subscriptions
        List<csord__Subscription__c> testSubscriptionList = new List<csord__Subscription__c>();
        
        for (Integer i=0; i < 10; i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            String subName = System.Label.IP_Site;
            if ( math.mod(i,8) == 0 ){
                subName = System.Label.IP_Network;
            }
            else if( math.mod(i,9) == 0) {
                subName = System.Label.UC_Enterprise;
            }
            
            testSubscription.Name = subName;
            testSubscription.csord__Account__c = basket.csbb__Account__c;
            //testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csord__Identification__c = 'test' + i;
            testSubscription.csordtelcoa__Product_Configuration__c = prodConfigList[i].id;
            testSubscription.csord__Status__c = 'Active';
            
            testSubscriptionList.add(testSubscription);
        }
        INSERT testSubscriptionList;

        Test.startTest();
            String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();

        System.assertEquals('ok', result);
    }
    
    @isTest 
    static void testSingleIpNetwork(){
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        
cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];        //cleanup basket
        List<cscfga__Product_Configuration__c> configList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id ];
        DELETE configList;

        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        INSERT defIpSite;
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        INSERT defIpNetwork;
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        INSERT defUcEnterprise;
        
        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        for (Integer i=0; i < 10; i++){
            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            String confName = System.Label.Label_CWP;
            config.cscfga__Product_Definition__c = defIpSite.Id;
            
            if ( i == 8 ){
                confName = System.Label.IP_Network;
                config.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( i == 9 ) {
                confName = System.Label.UC_Enterprise;
                config.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            
            
            config.cscfga__Product_Basket__c = basket.id;
            config.Name = confName;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;

            prodConfigList.add(config);
        }
        update prodConfigList;
        
        //Create Subscriptions
        List<csord__Subscription__c> testSubscriptionList = new List<csord__Subscription__c>();
        
        for (Integer i=0; i < 10; i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            String subName = System.Label.IP_Site;
            if ( i == 8 ){
                subName = System.Label.IP_Network;
            }
            else if( i == 9 ) {
                subName = System.Label.UC_Enterprise;
            }
            
            testSubscription.Name = subName;
            testSubscription.csord__Account__c = basket.csbb__Account__c;
            //testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csord__Identification__c = 'test' + i;
            testSubscription.csordtelcoa__Product_Configuration__c = prodConfigList[i].id;
            testSubscription.csord__Status__c = 'Active';
            
            testSubscriptionList.add(testSubscription);
        }
        INSERT testSubscriptionList;

        Test.startTest();
            String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();

        System.assertEquals('error' + '-'+ System.Label.Label_MoreThanOneIPNetwork_Error, result);
    }

    @isTest 
    static void testValidateOk1(){
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        
     cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];        //cleanup basket
        List<cscfga__Product_Configuration__c> configList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id ];
        DELETE configList;

        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        INSERT defIpSite;
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        INSERT defIpNetwork;
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        INSERT defUcEnterprise;
       
        
    //    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Telstra Collaboration Solution',cssdm__Type__c = 'Main'); DIGI-5648 
    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Adaptive Collaboration Solution',cssdm__Type__c = 'Main');
        insert cwpsol;
        cssdm__Solution_Definition__c  cwpcompsol = new cssdm__Solution_Definition__c(name='Unified Communication Tenancy Solution',cssdm__Type__c = 'Component',cssdm__main_component__c = cwpsol.id);
        insert cwpcompsol;
        
        // csord__Solution__c sol = new csord__Solution__c(name = 'Telstra Collaboration Solution', csord__Identification__c ='wetwet'); DIGI-5648 
        csord__Solution__c sol = new csord__Solution__c(name = 'Adaptive Collaboration Solution', csord__Identification__c ='wetwet');
        csord__Solution__c sol1 = new csord__Solution__c(name = 'Unified Communication Tenancy Solution', csord__Identification__c = 'tatet');
        insert sol;
        insert sol1;
        
        
        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        for (Integer i=0; i < 10; i++){
            cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
            String confName = System.Label.Label_CWP;
            config1.cscfga__Product_Definition__c = defIpSite.Id;
            
            if ( i == 8 ){
                confName = System.Label.IP_Network;
                config1.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( i == 9 ) {
                confName = System.Label.UC_Enterprise;
                config1.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            
            
            config1.cscfga__Product_Basket__c = basket.id;
            config1.Name = confName;
            config1.cscfga__Description__c = 'test Description '+i;
            config1.cscfga__Contract_Term__c = 36;
            config1.cssdm__solution_association__c = sol1.id;
             config1.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config1);
}
            
           
            //create Product Configuration
       // List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        for(Integer i=0;i<3;i++){
            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            
                String confName = System.Label.UC_Enterprise;
                config.cscfga__Product_Definition__c = defUcEnterprise.Id;
                      
            
            config.cscfga__Product_Basket__c = basket.id;
            config.Name = confName;
            config.cscfga__Description__c = 'test Description';
            config.cscfga__Contract_Term__c = 36;
            config.cssdm__solution_association__c = sol.id;
             config.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config);
             }
             cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
            
              String confName = System.Label.Label_CWP;
            config2.cscfga__Product_Definition__c = defIpSite.Id;
            config2.cscfga__Product_Basket__c = basket.id;
            prodConfigList.add(config2);
       
        update prodConfigList;
        
        //Create Subscriptions
        List<csord__Subscription__c> testSubscriptionList = new List<csord__Subscription__c>();
        
        for (Integer i=0; i < 10; i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            String subName = System.Label.IP_Site;

            if( i == 9 ) {
                subName = System.Label.UC_Enterprise;
            }
            
            testSubscription.Name = subName;
            testSubscription.csord__Account__c = basket.csbb__Account__c;
            //testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csord__Identification__c = 'test' + i;
            testSubscription.csordtelcoa__Product_Configuration__c = prodConfigList[i].id;
            testSubscription.csord__Status__c = 'Active';
            
            testSubscriptionList.add(testSubscription);
        }
        INSERT testSubscriptionList;

        Test.startTest();
            String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();

        System.assert(result!=null);
    }
    @isTest 
    static void testValidateNgUCfixTest(){
     String confName;
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        
cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];        //cleanup basket
        List<cscfga__Product_Configuration__c> configList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id ];
        DELETE configList;

        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        INSERT defIpSite;
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        INSERT defIpNetwork;
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        INSERT defUcEnterprise;
       
        
    //    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Telstra Collaboration Solution',cssdm__Type__c = 'Main'); DIGI-5648 
    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Adaptive Collaboration Solution',cssdm__Type__c = 'Main');
        insert cwpsol;
        cssdm__Solution_Definition__c  cwpcompsol = new cssdm__Solution_Definition__c(name='Unified Communication Tenancy Solution',cssdm__Type__c = 'Component',cssdm__main_component__c = cwpsol.id);
        insert cwpcompsol;
        
        // csord__Solution__c sol = new csord__Solution__c(name = 'Telstra Collaboration Solution', csord__Identification__c ='wetwet'); DIGI-5648 
        csord__Solution__c sol = new csord__Solution__c(name = 'Adaptive Collaboration Solution', csord__Identification__c ='wetwet');
        csord__Solution__c sol1 = new csord__Solution__c(name = 'Unified Communication Tenancy Solution', csord__Identification__c = 'tatet');
        insert sol;
        insert sol1;

        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        for (Integer i=0; i < 10; i++){
            cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
            confName = System.Label.Label_CWP;
            config1.cscfga__Product_Definition__c = defIpSite.Id;
            
            if ( i == 8 ){
                confName = System.Label.IP_Network;
                config1.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( i == 9 || i == 10) {
                confName = System.Label.UC_Enterprise;
                config1.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            
            
            
            config1.cscfga__Product_Basket__c = basket.id;
            config1.Name = confName;
            config1.cscfga__Description__c = 'test Description '+i;
            config1.cscfga__Contract_Term__c = 36;
            //config1.cssdm__solution_association__c = sol1.id;
             config1.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config1);
}

            /* cscfga__Product_Configuration__c config12 = ProductTestService.createProductConfiguration();
            
                confName = System.Label.UC_Enterprise;
                config12.cscfga__Product_Definition__c = defUcEnterprise.Id;
                      
            
            config12.cscfga__Product_Basket__c = basket.id;
            config12.Name = confName;
            config12.cscfga__Description__c = 'test Description';
            config12.cscfga__Contract_Term__c = 36;
            config12.cssdm__solution_association__c = sol.id;
             config12.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config12);
             
               cscfga__Product_Configuration__c config11 = ProductTestService.createProductConfiguration();
            
                confName = System.Label.UC_Enterprise;
                config11.cscfga__Product_Definition__c = defUcEnterprise.Id;
                      
            
            config11.cscfga__Product_Basket__c = basket.id;
            config11.Name = confName;
            config11.cscfga__Description__c = 'test Description';
            config11.cscfga__Contract_Term__c = 36;
            config11.cssdm__solution_association__c = sol1.id;
             config11.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config11);
             */
    upsert prodConfigList;
              List<csord__Subscription__c> testSubscriptionList = new List<csord__Subscription__c>();
        
        for (Integer i=0; i < 10; i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            String subName = System.Label.IP_Site;

            if( i == 9 || i == 8) {
                subName = System.Label.UC_Enterprise;
            }
            if(i== 10){
                subName = System.Label.IP_Network;
            }
            
            testSubscription.Name = subName;
            testSubscription.csord__Account__c = basket.csbb__Account__c;
            //testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csord__Identification__c = 'test' + i;
            testSubscription.csordtelcoa__Product_Configuration__c = prodConfigList[i].id;
            testSubscription.csord__Status__c = 'Active';
            
            testSubscriptionList.add(testSubscription);
        }
        INSERT testSubscriptionList;
        Test.startTest();
            String result = ValidateMinimumRequirements.run(basket.Id);
        Test.stopTest();
        System.assertEquals('ok', result);
    }
@isTest 
    static void testValidateNgUCfixTest1(){
     String confName;
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='2';
            insert env_var;
        
cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];        //cleanup basket
        List<cscfga__Product_Configuration__c> configList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id ];
        DELETE configList;
    cscfga__Product_Basket__c basket1 = basket.clone(false,false,false,false);
    insert basket1;
        //create Product Definition
        List<cscfga__Product_Definition__c> proddefList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        proddefList.add(defIpSite);
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        proddefList.add(defIpNetwork);
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        proddefList.add(defUcEnterprise);
        
        // cscfga__Product_Definition__c tenancy = new cscfga__Product_Definition__c (Name = 'Telstra Collaboration Tenancy', cscfga__Description__c = 'Telstra Collaboration Tenancy'); DIGI-5648 
        cscfga__Product_Definition__c tenancy = new cscfga__Product_Definition__c (Name = 'Adaptive Collaboration Tenancy', cscfga__Description__c = 'Adaptive Collaboration Tenancy');
       proddefList.add(tenancy);
       insert proddefList;
        List<cssdm__Solution_Definition__c> soldeflst = new List<cssdm__Solution_Definition__c>();
        
    //    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Telstra Collaboration Solution',cssdm__Type__c = 'Main'); DIGI-5648 
        cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Adaptive Collaboration Solution',cssdm__Type__c = 'Main');
        soldeflst.add(cwpsol);
        cssdm__Solution_Definition__c  cwpcompsol = new cssdm__Solution_Definition__c(name='Unified Communication Tenancy Solution',cssdm__Type__c = 'Component',cssdm__main_component__c = cwpsol.id);
        soldeflst.add(cwpcompsol);
        insert soldeflst;
        Marketable_Offer__c offer1 = new    Marketable_Offer__c(name='Unified Communication Tenancy',Offer_ID__c ='DMCAT_Offer_000311');
            insert offer1;
            // Marketable_Offer__c offer2 = new    Marketable_Offer__c(name='Telstra Collaboration',Offer_ID__c ='DMCAT_Offer_000312'); DIGI-5648 
            Marketable_Offer__c offer2 = new    Marketable_Offer__c(name='Adaptive Collaboration',Offer_ID__c ='DMCAT_Offer_000312');
            insert offer2;
            
        // csord__Solution__c sol = new csord__Solution__c(name = 'Telstra Collaboration Solution', csord__Identification__c ='wetwet');  DIGI-5648
        csord__Solution__c sol = new csord__Solution__c(name = 'Adaptive Collaboration Solution', csord__Identification__c ='wetwet');
        csord__Solution__c sol1 = new csord__Solution__c(name = 'Unified Communication Tenancy Solution', csord__Identification__c = 'tatet');
        insert sol;
        insert sol1;

         List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
         cscfga__Product_Configuration__c config12 = ProductTestService.createProductConfiguration();
            
                // confName = 'Telstra Collaboration'; DIGI-5648
                confName = 'Adaptive Collaboration';
                config12.cscfga__Product_Definition__c = defUcEnterprise.Id;
                      
            
            config12.cscfga__Product_Basket__c = basket.id;
            config12.Name = confName;
            config12.cscfga__Description__c = 'test Description';
            config12.cscfga__Contract_Term__c = 36;
            config12.cssdm__solution_association__c = sol.id;
            config12.Type__c = 'New';
             config12.Marketable_Offer__c = offer2.id;
        	config12.ConfigurationType1__c='SolutionComponent';
             prodConfigList.add(config12);
             
               cscfga__Product_Configuration__c config11 = ProductTestService.createProductConfiguration();
            
                confName = System.Label.UC_Enterprise;
                config11.cscfga__Product_Definition__c = tenancy.Id;
                      
            
            config11.cscfga__Product_Basket__c = basket.id;
            config11.Name = confName;
            config11.cscfga__Description__c = 'test Description';
            config11.cscfga__Contract_Term__c = 36;
            config11.cssdm__solution_association__c = sol1.id;
            config11.Marketable_Offer__c = offer1.id;
             config11.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config11);
             upsert prodConfigList;
             //2nd basket - basket1
            cscfga__Product_Configuration__c config121 = ProductTestService.createProductConfiguration();
            
                confName = System.Label.UC_Enterprise;
                config121.cscfga__Product_Definition__c = defUcEnterprise.Id;
                      
            
            config121.cscfga__Product_Basket__c = basket1.id;
            config121.Name = confName;
            config121.cscfga__Description__c = 'test Description';
            config121.cscfga__Contract_Term__c = 36;
            config121.cssdm__solution_association__c = sol.id;
             config121.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             config121.Marketable_Offer__c = offer1.id;
             upsert config121;
             
              Test.startTest();
            String result = ValidateMinimumRequirements.run(basket.Id);
            System.assertEquals('ok', result);
            String result1 = ValidateMinimumRequirements.run(basket1.Id);
            System.assertNotEquals('ok', result1);
        Test.stopTest();
        
    }
    @isTest
    static void testValidateNgUCfixTest2(){
     String confName;
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;
        
		cscfga__Product_Basket__c basket = [Select id, Name,csbb__Account__c, cscfga__Opportunity__c from cscfga__Product_Basket__c where Project_ID__c='basket1'];        //cleanup basket
        List<cscfga__Product_Configuration__c> configList = [Select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basket.id ];
        DELETE configList;
        cscfga__Product_Basket__c basket1  = basket.clone(false,false,false,false);
        insert basket1;

        //create Product Definition
        List<cscfga__Product_Definition__c> deflst = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        deflst.add(defIpSite);
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        deflst.add(defIpNetwork);
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        deflst.add(defUcEnterprise);
        insert deflst;        
        List<cssdm__Solution_Definition__c> soldeflst = new List<cssdm__Solution_Definition__c>();
        
    //    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Telstra Collaboration Solution',cssdm__Type__c = 'Main');
    cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Adaptive Collaboration Solution',cssdm__Type__c = 'Main');
        soldeflst.add(cwpsol);
        cssdm__Solution_Definition__c  cwpcompsol = new cssdm__Solution_Definition__c(name='Unified Communication Tenancy Solution',cssdm__Type__c = 'Component',cssdm__main_component__c = cwpsol.id);
        soldeflst.add(cwpcompsol);
        
        insert soldeflst;
        
        // csord__Solution__c sol = new csord__Solution__c(name = 'Telstra Collaboration Solution', csord__Identification__c ='wetwet');
        csord__Solution__c sol = new csord__Solution__c(name = 'Adaptive Collaboration Solution', csord__Identification__c ='wetwet');
        csord__Solution__c sol1 = new csord__Solution__c(name = 'Unified Communication Tenancy Solution', csord__Identification__c = 'tatet');
        insert sol;
        insert sol1;
        
            

        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        for (Integer i=0; i < 10; i++){
            cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
            confName = System.Label.Label_CWP;
            config1.cscfga__Product_Definition__c = defIpSite.Id;
            
            if ( i == 8 ){
                confName = System.Label.IP_Network;
                config1.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( i == 9 || i == 10) {
                confName = System.Label.UC_Enterprise;
                config1.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            
            
            
            config1.cscfga__Product_Basket__c = basket.id;
            config1.Name = confName;
            config1.cscfga__Description__c = 'test Description '+i;
            config1.cscfga__Contract_Term__c = 36;
            //config1.cssdm__solution_association__c = sol1.id;
             config1.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config1);
        }

             cscfga__Product_Configuration__c config12 = ProductTestService.createProductConfiguration();
            
                confName = System.Label.Label_CWP;
                config12.cscfga__Product_Definition__c = defIpSite.Id;
                      
            
            config12.cscfga__Product_Basket__c = basket1.id;
            config12.Name = confName;
            config12.cscfga__Description__c = 'test Description';
            config12.cscfga__Contract_Term__c = 36;
            config12.cssdm__solution_association__c = sol.id;
             config12.Type__c = PROD_CONFIGURATION_TYPE_MODIFY;
             prodConfigList.add(config12);
             
               
            upsert prodConfigList;
              List<csord__Subscription__c> testSubscriptionList = new List<csord__Subscription__c>();
        
        for (Integer i=0; i < 10; i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            String subName = System.Label.IP_Site;

            if( i == 9 || i == 8) {
                subName = System.Label.UC_Enterprise;
            }
            if(i== 10){
                subName = System.Label.IP_Network;
            }
            
            testSubscription.Name = subName;
            testSubscription.csord__Account__c = basket.csbb__Account__c;
            //testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csord__Identification__c = 'test' + i;
            testSubscription.csordtelcoa__Product_Configuration__c = prodConfigList[i].id;
            testSubscription.csord__Status__c = 'Active';
            
            testSubscriptionList.add(testSubscription);
        }
        INSERT testSubscriptionList;
        Test.startTest();
            String result = ValidateMinimumRequirements.run(basket.Id);
            System.assertEquals('ok', result);
       
            result = ValidateMinimumRequirements.run(basket1.Id);
        Test.stopTest();
        
    }
    ///////////////////////////******************///////////////////////////
//EDGE-147513 start --------------------------

@isTest
public static void testBillingAccCheckValid(){
    Test.startTest();
    cscfga__Product_Basket__c basket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket1' limit 1];
    Boolean hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc(basket.id,basket.csbb__Account__c);
    System.assertEquals(false, hasinvalidBillingAcc);
    Test.stopTest();
}
@isTest
public static void testBillingAccCheckValid_cancelPC(){
    Test.startTest();
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
    cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket2' limit 1];
    Boolean hasinvalidBillingAcc=false;
    System.runAs(sales){
        hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc(productBasket.id,productBasket.csbb__Account__c);
    }
    System.assertEquals(false, hasinvalidBillingAcc);
    Test.stopTest();
}
@isTest
public static void testBillingAccCheckInvalidMacd(){
    Test.startTest();
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
    cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
    Boolean hasinvalidBillingAcc=false;
    System.runAs(sales){
			hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc(productBasket.id,productBasket.csbb__Account__c);
    }
    System.assertEquals(true, hasinvalidBillingAcc);
    Test.stopTest();
}
@isTest
public static void testBillingAccCheckNegativeNoacc(){
    Test.startTest();
     User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
    cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
    Boolean hasinvalidBillingAcc=false;
    System.runAs(sales){
        hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc(productBasket.id,'');
    }
    System.assertEquals(false, hasinvalidBillingAcc);
    Test.stopTest();
}
@isTest
public static void testBillingAccCheckNegative(){
    Test.startTest();
     User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
    cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
    Boolean hasinvalidBillingAcc=false;
    System.runAs(sales){
        hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc('','');
    }
    System.assertEquals(false, hasinvalidBillingAcc);
    Test.stopTest();
}
    public static void testCheckbasketStatusInvalid(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c,cscfga__Basket_Status__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
        Boolean hasinvalidBillingAcc=false;
        System.runAs(sales){
				ValidateMinimumRequirements.makebasketInvalid(productBasket);            	
        }
        System.assertEquals('Incomplete',productBasket.cscfga__Basket_Status__c);
        Test.stopTest();
	}
    public static void testCheckbasketStatusNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c productBasket=new cscfga__Product_Basket__c();
        Boolean hasinvalidBillingAcc=false;
        System.runAs(sales){
				PageReference ref=ValidateMinimumRequirements.makebasketInvalid(productBasket);            	
       		System.assertEquals(true,ref==null);
        }
        
        Test.stopTest();
	}
//EDGE-147513 end ----------------------------
}