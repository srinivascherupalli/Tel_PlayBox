@isTest
public class NewBasketRedirectController_ButtonTest {
    
    public static testMethod void unitTest(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
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
        
        //CREATE Custom Setting
        PRM_Default__c newP=new PRM_Default__c(SetupOwnerId=UserInfo.getProfileId(),Valid_Opportunity_Basket_Verification__c='Approved');
        insert newP;
        set<string> validValues=new set<string>();
        validValues.addAll(newP.Valid_Opportunity_Basket_Verification__c.split(','));
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Opportunity_Source__c = 'Partner';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //CREATE OPPORTUNITY 2
        Opportunity opp2   = ProductTestFactory.getOpportunityBasic(acc);
        opp2.Opportunity_Source__c = 'Other';
        insert opp2;
        System.assertNotEquals(null,opp2);
        //Create Basket
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        //basket.csbb__Account__c = acc.id;
        //basket.cscfga__Opportunity__c = opp.id;
        //basket.Name = 'basket1';
        //insert basket;
        //String s = JSON.serialize(basket,true);
        //system.debug('basket: '+ s);
       
        string s='{"csbb__Account__c":"'+acc.id+'","cscfga__Opportunity__c":"'+opp.id+'","Name":"basket1"}';
        Test.startTest();
        string bid=NewBasketRedirectController_Button.createBasketRecord(s);
        cscfga__Product_Basket__c basket12=new cscfga__Product_Basket__c(id=bid);
        ApexPages.StandardController con=new ApexPages.StandardController(basket12);
        NewBasketRedirectController_Button newCon=new NewBasketRedirectController_Button(con);
        String path = NewBasketButtonController.getPathPrefix();
        NewBasketButtonController.caseRecordId();
        NewBasketButtonController.getValidOpportunity(opp.id);
        NewBasketButtonController.getValidOpportunity(opp2.id);
        Test.stopTest();
        System.assertNotEquals(null,path);

    }
    
}