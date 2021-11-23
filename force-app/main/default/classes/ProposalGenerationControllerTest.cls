/*
* @Author :  Ravi Dodiya
* @Date   :  27 April 2021
* @Desc   :  TestClass for ProposalGenerationController
* @Jira   :  P2OB-13423 and P2OB-13422 
*/
@IsTest
public class ProposalGenerationControllerTest {
    /* 
     * This method will setup product basket with stage = 'Commercial Configuration' , 
     * as per the proposal generation requirement 'Closed Won','Cancelled','Draft' stage should not be available 
	*/
    @isTest 
    static void getbasketforProposal(){
        
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
        //opp.Conga_Status__c = 'InProgress';
        insert opp;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
        

        Test.startTest();
		List<cscfga__Product_Basket__c> availableBasket = ProposalGenerationController.getProductBasket(opp.Id);
        Test.stopTest();
        System.assertNotEquals(availableBasket, null, 'Available Basket should not be null');
    }
    /* 
     * This method will setup product basket with stage = 'Draft' , 
     * as per the proposal generation requirement 'Closed Won','Cancelled','Draft' stage should not be available 
	*/
	@isTest 
    static void getNobasketforProposal(){
        
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
        //opp.Conga_Status__c = 'InProgress';
        insert opp;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Draft';
        insert prodbasket;
        

        Test.startTest();
		List<cscfga__Product_Basket__c> availableBasket = ProposalGenerationController.getProductBasket(opp.Id);
        Test.stopTest();
        System.assertEquals(availableBasket.size(), 0, 'Available Basket Should be Null,Draft is out of scope');
    }
    /* 
     * This method will fetch available Template for Proposal Generation. 
     * Available Templates are setup inside Custom MetaData : Proposal_Templates__mdt 
	*/
	@isTest 
    static void getTemplateForProposal(){
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
    
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        //opp.Conga_Status__c = 'InProgress';
        insert opp;
          
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
        
        cscfga__Product_Configuration__c testPC1 = new cscfga__Product_Configuration__c();
        testPC1.cscfga__Product_Basket__c = prodbasket.Id;
        cscfga__Product_Configuration__c testPC2 = new cscfga__Product_Configuration__c();
        testPC2.cscfga__Product_Basket__c = prodbasket.Id;
        cscfga__Product_Configuration__c testPC3 = new cscfga__Product_Configuration__c();
        testPC3 .cscfga__Product_Basket__c = prodbasket.Id;
        cscfga__Product_Configuration__c testPC4 = new cscfga__Product_Configuration__c();
        testPC4.cscfga__Product_Basket__c = prodbasket.Id;
        List<cscfga__Product_Configuration__c> listOfPCs = new List<cscfga__Product_Configuration__c>();
        listOfPCs.add(testPC1);
        listOfPCs.add(testPC2);
        listOfPCs.add(testPC3);
        listOfPCs.add(testPC4);
        insert listOfPCs;
        
        cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
        testPriceItem.Domain__c = 'DATA & IP';
        testPriceItem.Product_Family__c = 'ADAPTIVE NETWORKS';
        
        cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
        testPriceItem2.Domain__c = 'DATA & IP';
        testPriceItem2.Product_Family__c = '';
        
        cspmb__Price_Item__c testPriceItem3 = new cspmb__Price_Item__c();
        testPriceItem3.Domain__c = 'UNIFIED COMMUNICATIONS';
        cspmb__Price_Item__c testPriceItem4 = new cspmb__Price_Item__c();
        testPriceItem4.Domain__c = 'CLOUD SERVICES';
        
        List<cspmb__Price_Item__c> listOfPriceItem = new List<cspmb__Price_Item__c>();
        listOfPriceItem.add(testPriceItem);
        listOfPriceItem.add(testPriceItem2);
        listOfPriceItem.add(testPriceItem3);
        listOfPriceItem.add(testPriceItem4);
        insert listOfPriceItem;
        
        cscfga__Attribute__c testAttribute1 = new cscfga__Attribute__c();
        testAttribute1.Name = 'Product_SC';
        testAttribute1.cscfga__Value__c = testPriceItem.Id;
        testAttribute1.cscfga__Product_Configuration__r = testPC1;
        testAttribute1.cscfga__Product_Configuration__c = testPC1.Id;
        
        cscfga__Attribute__c testAttribute2 = new cscfga__Attribute__c();
        testAttribute2.Name = 'Product_SC';
        testAttribute2.cscfga__Value__c = testPriceItem2.Id;
        testAttribute2.cscfga__Product_Configuration__r = testPC2;
        testAttribute2.cscfga__Product_Configuration__c = testPC2.Id;
        
        cscfga__Attribute__c testAttribute3 = new cscfga__Attribute__c();
        testAttribute3.Name = 'Product_SC';
        testAttribute3.cscfga__Value__c = testPriceItem3.Id;
        testAttribute3.cscfga__Product_Configuration__r = testPC3;
        testAttribute3.cscfga__Product_Configuration__c = testPC3.Id;

        cscfga__Attribute__c testAttribute4 = new cscfga__Attribute__c();
        testAttribute4.Name = 'Product_SC';
        testAttribute4.cscfga__Value__c = testPriceItem4.Id;
        testAttribute4.cscfga__Product_Configuration__r = testPC4;
        testAttribute4.cscfga__Product_Configuration__c = testPC4.Id;
        
        List<cscfga__Attribute__c> listOfAttribute = new List<cscfga__Attribute__c>();
        listOfAttribute.add(testAttribute1);
        listOfAttribute.add(testAttribute2);
        listOfAttribute.add(testAttribute3);  
        listOfAttribute.add(testAttribute4);  
        insert listOfAttribute;
        
        Test.startTest();
		List<Proposal_Templates__mdt> availableTemplate = ProposalGenerationController.getProposalTemplate(prodbasket.Id);
        Test.stopTest();
        System.assertNotEquals(availableTemplate, null, 'Available Template should not be null.Check your metadata setup');
    }
}