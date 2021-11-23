/*
* @Author :  Srujana Durvasula
* @Date   :  12 Jan 2021
* @Desc   :  TestClass for CustomButtonGenerateProposal
* @Jira   :  P2OB-11268 
*/
@isTest(SeeAllData=FALSE)
public class CustomButtonGenerateProposalTest {
	
		@isTest static void performActionTest() {
                     Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        //insert acc;
        System.assertNotEquals(null, acc);
    
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
    
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
    
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod, pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
          
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId=opp.id;
        otm.OpportunityAccessLevel='Read';
        otm.UserId=UserInfo.getUserId();
        insert otm;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
            
		Test.startTest();
        CustomButtonGenerateProposal newCustSendProposal = new CustomButtonGenerateProposal();
		newCustSendProposal.performAction(prodbasket.Id);
        Test.stopTest();
       // System.assertNotEquals('', basket.Id);
		}
    
     /*   @isTest static void performActionTest() {
            
               Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        //insert acc;
        System.assertNotEquals(null, acc);
    
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
    
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
    
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod, pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
          
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId=opp.id;
        otm.OpportunityAccessLevel='Read';
        otm.UserId=UserInfo.getUserId();
        insert otm;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
            
        List<APXTConga4__Conga_Template__c> templateList = new List<APXTConga4__Conga_Template__c>();
        APXTConga4__Conga_Template__c stdtemplate = new APXTConga4__Conga_Template__c();
        stdtemplate.APXTConga4__Name__c = 'Standard Product Catalog Proposal';
        stdtemplate.Type__c='None'; 
        stdtemplate.APXTConga4__Template_Type__c = 'Document'; 
        insert stdtemplate;
        templateList.add(stdtemplate);
        
        Test.startTest();
        CustomButtonGenerateProposal newCustSendProposal = new CustomButtonGenerateProposal();
        newCustSendProposal.performAction(prodbasket.Id);
        Test.stopTest();
        System.assertEquals(!templateList.isEmpty(), true);
    }    
    
      @isTest static void performActionTestWithInvalidProduct() {
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        //insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        update basket;
        
        cscfga__Product_Configuration__c config = [SELECT Id FROM cscfga__Product_Configuration__c WHERE cscfga__product_basket__c = : basket.Id];
        config.cscfga__Configuration_Status__c = 'Incomplete';
        update config;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        Test.startTest();
        CustomButtonGenerateProposal newCustSendProposal = new CustomButtonGenerateProposal();
        newCustSendProposal.performAction(basket.Id);
        Test.stopTest();
        System.assertNotEquals('', basket.Id);
    }
    
    @isTest
    static void testPerformValidations() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        
    	Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
    
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
    
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod, pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
            
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId=opp.id;
        otm.OpportunityAccessLevel='Read';
        otm.UserId=usr.Id;
        insert otm;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
            
        List<APXTConga4__Conga_Template__c> templateList = new List<APXTConga4__Conga_Template__c>();
        APXTConga4__Conga_Template__c stdtemplate = new APXTConga4__Conga_Template__c();
        stdtemplate.APXTConga4__Name__c = 'Standard Product Catalog Proposal';
        stdtemplate.Type__c='None'; 
        stdtemplate.APXTConga4__Template_Type__c = 'Document'; 
        insert stdtemplate;
        templateList.add(stdtemplate);
        
        Test.startTest();
        	Boolean bool = CustomButtonGenerateProposal.performValidations(prodbasket.Id);
        Test.stopTest();
        System.assertEquals(bool, false, 'Value should be false');   
    }
    
    @isTest
    static void testPerformValidationsNegative() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        
    	Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
    
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
    
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod, pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
            
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId=opp.id;
        otm.OpportunityAccessLevel='Read';
        otm.UserId=UserInfo.getUserId();
        insert otm;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
            
        List<APXTConga4__Conga_Template__c> templateList = new List<APXTConga4__Conga_Template__c>();
        APXTConga4__Conga_Template__c stdtemplate = new APXTConga4__Conga_Template__c();
        stdtemplate.APXTConga4__Name__c = 'Standard Product Catalog Proposal';
        stdtemplate.Type__c='None'; 
        stdtemplate.APXTConga4__Template_Type__c = 'Document'; 
        insert stdtemplate;
        templateList.add(stdtemplate);
        
        Test.startTest();
        	Boolean	bool = CustomButtonGenerateProposal.performValidations(prodbasket.Id);  	
        Test.stopTest();
        System.assertEquals(bool, True, 'Value should be True');   
    }*/
}