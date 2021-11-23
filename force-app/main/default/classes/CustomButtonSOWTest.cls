/**************************************************************************************************************
Name          : CustomButtonSOWTest
Created By    : Purushottam Sahu
Created Date  : Sep 23 2019
Description   : EDGE-108286 - This is a test class to simulate and test the logic of CustomButtonSOW
-------
History                                                            
-------                                                            
VERSION     AUTHOR             DATE            DETAIL                   
-------     ------             -----           ---------                 
1.1         Purushottam        23-09-2019      EDGE-108286: Created
2.1			Shubhi V 			06-July-2020    EDGE-147513    BillingAcc checks
**************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class CustomButtonSOWTest {
    
    @testsetup static void setupTestData() {
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        customSetting.Opportunity_Stage__c = 'Develop';
        
        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote'); 
        customSetting1.Name = 'Quote';
        customSetting1.External_Id__c = 'CCO_T_2';
        customSetting1.Opportunity_Stage__c = 'Develop';
        List<CustomConfigurationOptions__c> csList = new List<CustomConfigurationOptions__c>{customSetting, customSetting1};
        INSERT csList;
        
        Marketable_Offer__c moPS = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services',Name = 'Professional Services-MDM Config',Offer_ID__c = 'DMCAT_ProductOffering_000716',type__c = 'Professional Service');
        insert moPS;
        
        cscfga__Product_Configuration__c pd = TestDataFactory.generateProductConfiguration();
        pd.name = 'Professional Services-MDM Config';
        pd.Type__c = 'New'; 
        pd.Marketable_Offer__c = moPS.id;
        pd.cscfga__Product_Family__c='Professional Services-MDM Config';
        update pd;
        
        cscfga__Product_Basket__c basket = [SELECT id,csordtelcoa__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        Opportunity opp = TestDataFactory.generateOpportunity();
        //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
        opp.AccountId = basket.csordtelcoa__Account__c;
        Update opp;
        //Finished
        basket.cscfga__Opportunity__c=opp.id;
        update basket;
        
        Contact con = new Contact(FirstName = 'Testing',LastName = 'Test',AccountId = basket.csordtelcoa__Account__c);
        insert con;
        
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = con.Id,OpportunityId = opp.Id,IsPrimary = TRUE,Role = 'Decision Maker');
        insert ocr;
        
        Master_Clauses__c mc = new Master_Clauses__c(Offer_Id__c='DMCAT_ProductOffering_000716',Reviewer__c= UserInfo.getUserId(),name='Professional Services-MDM Config');
        insert mc;
        
        List<Clauses__c> clList=new List<Clauses__c>();
        Clauses__c cl1=new Clauses__c(name='Clauses1',description__c='Test1');
        clList.add(cl1);
        Clauses__c cl2=new Clauses__c(name='Clauses2',description__c='Test2');
        clList.add(cl2);
        insert clList;
        
        List<Clauses_Junction__c> cj_list= new List<Clauses_Junction__c>();
        for(Clauses__c cl:clList){
            Clauses_Junction__c cj= new Clauses_Junction__c(Active__c=true,Items__c=cl.id,MasterItems__c=mc.id);
            cj_list.add(cj);
        }
        insert cj_list;
		
		//EDGE-147513 start --------------------------
		//Create Basket
		//CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;
        //CREATE CONTACT 
        Contact con1 = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61445678006',
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
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp1;
        System.assertNotEquals(null,opp1);
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp1.id;
        basket1.Project_ID__c = 'basket1';
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp1.id;
        basket2.Project_ID__c = 'basket2';
        cscfga__Product_Basket__c basket3 = ProductTestFactory.buildEmptyBasket();
        basket3.csbb__Account__c = acc.id;
        basket3.cscfga__Opportunity__c = opp1.id;
        basket3.Project_ID__c = 'basket3';
        insert new List<cscfga__Product_Basket__c>{basket1,basket2,basket3};
        csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
        insert new List<csord__Solution__c>{sol1,sol2};
        cscfga__Product_Configuration__c pc1_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket1.id,sol1.id,'');
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
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc3_sol .id);
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
    
    /*******************************************************************************************************
* Method Name : performActionNegativeTest
* Description : Used to simulate and test the logic of performAction method in CustomButtonSOW
* Parameters  : NA
* Return      : '{"status":"error","text":"' + e.getMessage() + '"}';                      
*******************************************************************************************************/
    static testmethod void performActionNegativeTest() {
        String returnStr;
        Test.startTest();
        CustomButtonSOW cbs = new CustomButtonSOW();
        returnStr = cbs.performAction('');
        Test.stopTest();
        System.assert(returnStr.contains('error'));
    }
    /*******************************************************************************************************
* Method Name : performActionNegativeTest1
* Description : Used to simulate and test the logic of performAction method in CustomButtonSOW
* Parameters  : Basket ID
* Return      : '{"status":"error","text":"' + Label.No_Contact_Role_on_Opportunity + '"}'                      
*******************************************************************************************************/
    static testmethod void performActionNegativeTest1() {
        String returnStr;
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
        OpportunityContactRole contactRole = [select id from OpportunityContactRole];
        delete contactRole;
        Test.startTest();
        CustomButtonSOW cbs = new CustomButtonSOW();
        returnStr = cbs.performAction(basket.Id);
        Test.stopTest();
        System.assert(returnStr.contains('error'));
    }
    
    /*******************************************************************************************************
* Method Name : performActionNegativeTest2
* Description : Used to simulate and test the logic of performAction method in CustomButtonSOW
* Parameters  : Basket ID
* Return      : '{"status":"error","text":"'+Label.SOW_Failed_PC+'"}'                      
*******************************************************************************************************/
    static testmethod void performActionNegativeTest2() {
        String returnStr;
        cscfga__Product_Basket__c basket = [SELECT id,csordtelcoa__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        cscfga__Product_Configuration__c prodConfig= [select id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basket.id];
        delete prodConfig;
        Test.startTest();
        CustomButtonSOW cbs = new CustomButtonSOW();
        returnStr = cbs.performAction(basket.Id);
        Test.stopTest();
        System.assert(returnStr.contains('error'));
    }
    
    /*******************************************************************************************************
* Method Name : performActionNegativeTest3
* Description : Used to simulate and test the logic of performAction method in CustomButtonSOW
* Parameters  : Basket ID
* Return      : '{"status":"error","text":"SOW failed to Initiate"}'                      
*******************************************************************************************************/
    static testmethod void performActionNegativeTest3() {
        String returnStr;
        cscfga__Product_Basket__c basket = [SELECT id,csordtelcoa__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        List<Clauses_Junction__c> clauseJun = [select id from Clauses_Junction__c];
        delete clauseJun;
        Test.startTest();        
        CustomButtonSOW cbs = new CustomButtonSOW();
        returnStr = cbs.performAction(basket.id);
        Test.stopTest();
        System.assert(returnStr.contains('error'));
    }
    
    /*******************************************************************************************************
* Method Name : performActionPositiveTest
* Description : Used to simulate and test the logic of performAction method in CustomButtonSOW
* Parameters  : Basket Id
* Return      : '{"status":"ok","text":"SOW Initiated","redirectURL":"' + ref.getUrl() + '"}'                      
*******************************************************************************************************/
    static testmethod void performActionPositiveTest() {
        String returnStr;
        cscfga__Product_Basket__c basket = [SELECT id,csordtelcoa__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        Test.startTest();
        CustomButtonSOW cbs = new CustomButtonSOW();
        returnStr = cbs.performAction(basket.id);
        Test.stopTest();
        System.assertNotEquals('', returnStr);
        SOW__c sow = [SELECT Id FROM SOW__c WHERE Basket__c = :basket.id LIMIT 1];
        System.assertNotEquals(NULL, sow);
        System.debug('Return String'+returnStr);
        System.assertEquals('{"status":"ok","text":"SOW Initiated","redirectURL":"/' + sow.Id + '"}', returnStr);
    }
    ///////////////////////////******************///////////////////////////
//EDGE-147513 start --------------------------
    
    @isTest
    public static void testBillingAccCheckValid(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c basket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket1' limit 1];
        Boolean hasinvalidBillingAcc=false;
        System.runAs(sales){
           CustomButtonSOW newCustContract = new CustomButtonSOW();
           String ret=newCustContract.performAction(basket.id);
            system.debug('ret1-->'+ret);
           System.assertEquals(false, ret.contains(System.Label.BillingAccountStatusValidation));
        }
        
        Test.stopTest();
    }
    @isTest
    public static void testBillingAccCheckValid_cancelPC(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c basket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket2' limit 1];
        Boolean hasinvalidBillingAcc=false;
        System.runAs(sales){
           CustomButtonSOW newCustContract = new CustomButtonSOW();
           String ret=newCustContract.performAction(basket.id);
            system.debug('ret1-->'+ret);
           System.assertEquals(false, ret.contains(System.Label.BillingAccountStatusValidation));
        }
        Test.stopTest();
    }
    @isTest
    public static void testBillingAccCheckInvalidMacd(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
        Boolean hasinvalidBillingAcc=false;
        System.runAs(sales){
            CustomButtonSOW newCustContract = new CustomButtonSOW();
            String ret=newCustContract.performAction(productBasket.id);
             system.debug('ret1-->'+ret);
            System.assertEquals(true, ret.contains(System.Label.BillingAccountStatusValidation));
        }
        
        Test.stopTest();
    }
//EDGE-147513 end ----------------------------
}