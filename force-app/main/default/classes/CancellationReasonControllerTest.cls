@isTest
public class CancellationReasonControllerTest {
    @testsetup 
    static void testdata() {
        //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        System.assertNotEquals(null,acc);
        
        Contact con = new Contact(LastName = 'Sam');
        con.AccountId=acc.id;
        insert con;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Name = 'TestOpp';
        opp.Cancel_Opp_Automatically_closed__c=true;
        insert opp;
        System.assertNotEquals(null,opp);       
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId =con.Id;
        ocr.OpportunityId =opp.Id;
        insert ocr;
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'TestBasket';
        insert basket;
        System.assertNotEquals(null,basket);
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(IPNet_PD);
        cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility');
        pdList.add(Mob_PD);
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.Type__c = 'Cancel';
        testConfig.cscfga__Product_Basket__c = basket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.Type__c = 'Cancel';
        testConfig1.cscfga__Product_Basket__c = basket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.Type__c = 'Cancel';
        testConfig2.cscfga__Product_Basket__c = basket.Id;
        testConfig2.cscfga__Product_Definition__c=IPNet_PD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.Type__c = 'Cancel';
        testConfig3.cscfga__Product_Basket__c = basket.Id;
        testConfig3.cscfga__Product_Definition__c=Mob_PD.id;
        prodconfigList.add(testConfig3); 
        insert prodconfigList;

        CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration');
        customSetting2.Name = 'CommercialConfiguration';
        customSetting2.External_Id__c = 'CCO4';
        insert customSetting2;

        CustomConfigurationOptions__c customSetting3 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote');
        customSetting3.Name = 'Quote';
        customSetting3.External_Id__c = 'CCO8';
        insert customSetting3;
        
        //EDGE-151654 start
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
       insert sales;
		//EDGE-151654 end

    }
    
    @isTest
    static void testGetOpportunityId(){
        cscfga__Product_Basket__c basket = [SELECT  Id,
                                                    cscfga__Opportunity__c 
                                            FROM    cscfga__Product_Basket__c];
        Test.startTest();
        Id returnedOppId = CancellationReasonController.getOpportunityId(basket.Id);
        Test.stopTest();   
        System.assertEquals(basket.cscfga__Opportunity__c, returnedOppId, 'Opportunity Id\'s are not matching');
    }
    
        @isTest
    static void createContactInOpportunity(){
        Opportunity opp = [Select Id From Opportunity where Name = 'TestOpp'];  
        Contact con = [Select Id From Contact where LastName = 'Sam'];
        
        Test.startTest();
        CancellationReasonController.createContactInOpportunity(opp.Id,con.Id);
        Test.stopTest();   
        System.assert(opp != null);
    }
    
         @isTest
    static void testGetAccountDetailsWithAccountId()
    {
        Account resultAccount = new Account();
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        cscfga__Product_Basket__c basket = [SELECT  Id,
                                                    cscfga__Opportunity__c 
                                            FROM    cscfga__Product_Basket__c];
        Test.startTest();
            resultAccount = CancellationReasonController.getAccountDetails(basket.Id, '');
        Test.stopTest();
        System.assertEquals(testAccount.Id, resultAccount.Id, 'Tested Account Id\'s are not equal');
    }
             @isTest
    static void testGetAccountDetailsWithAccountId1()
    {
        Account resultAccount = new Account();
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        cscfga__Product_Basket__c basket = [SELECT  Id,
                                                    cscfga__Opportunity__c 
                                            FROM    cscfga__Product_Basket__c];
        Test.startTest();
            resultAccount = CancellationReasonController.getAccountDetails('', testAccount.Id);
        Test.stopTest();
        System.assertEquals(testAccount.Id, resultAccount.Id, 'Tested Account Id\'s are not equal');
    }

    @isTest
    static void testIsCancelationNBN()
    {
        cscfga__Product_Basket__c basket = [SELECT Id FROM cscfga__Product_Basket__c LIMIT 1];
        Test.startTest();
            Boolean res = CancellationReasonController.isCancelationNBN(String.valueOf(basket.Id));
        Test.stopTest();

        System.assertEquals(false, res);

    }
    @isTest
        static void testGetACRId()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'TestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        Test.startTest();
        AccountContactRelation acr1 = CancellationReasonController.getACRId(testBasket.Id);
        Test.stopTest();
        System.assert( testBasket != null);   
    }
    
    
    
        @isTest
        static void testupdateOpportunityTypeDisconnect()
    {
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        List<cscfga__Product_Basket__c> basket = [SELECT    Id,
                                                    cscfga__Opportunity__c 
                                            FROM    cscfga__Product_Basket__c];
        Test.startTest();
        CancellationReasonController.updateOpportunityTypeDisconnect(testOpp.Id,basket[0].Id);
        Test.stopTest();
        System.assert( basket != null);   
    }
    //EDGE-151654 added by shubhi
    @isTest
    public static void UserAndOrgDetailsTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where  email='salesuser@testsales.com' limit 1];     
        system.runas(sales){
            String orgDetail = CancellationReasonController.organizationInfo();
        	String site = CancellationReasonController.GetSiteId();
        	System.assert(String.isBlank(site));
        }
 		
        Test.stopTest();
    }
}