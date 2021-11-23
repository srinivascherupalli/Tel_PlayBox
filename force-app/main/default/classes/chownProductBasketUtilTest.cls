/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-30-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class chownProductBasketUtilTest {
    @TestSetup 
    static void testDataSetup() {
        
        Profile pf = [select id from profile where name ='Assurance Service Agent'];
        User agent= new User(alias = 'agent',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='agent', languagelocalekey='en_US',localesidkey='en_US',
                                      profileid = pf.id,
                                      timezonesidkey='Australia/Sydney',
                                      username='agentuser@testagent.com',phone='+121231231234');
        insert agent;
        system.debug('user'+  agent);

        Account acc = ProductTestService.getNewAccount('Test Account');
            Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
            billingAccount.Account__c = acc.id;
            billingAccount.Status__c = 'final';
            insert billingAccount;
            
        System.runas(agent) {
            Opportunity opp1 = ProductTestFactory.getOpportunityBasic(acc);
            opp1.StageName = 'Develop';
            opp1.Product_Type__c = 'Modular';
            opp1.Name = 'TestingOpp1';
            insert opp1;
            
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp1.id;
            basket.Name = 'OutgoingBasket';
            basket.cscfga__Basket_Status__c = 'valid';
            basket.csordtelcoa__Basket_Stage__c ='Draft';
            insert basket;
            
            cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
            basket2.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
            basket2.cscfga__Opportunity__c = opp1.id;
            basket2.csbb__Account__c = acc.Id;
            basket2.Name = 'IncomingBasket';
            basket2.cscfga__Basket_Status__c = 'Valid';
            basket2.csordtelcoa__Previous_Product_Basket__c = basket.Id;
            insert basket2;
        }
    }
    
    
    @isTest static void changeBasketStageForChownTest(){
        User agent= [Select id from user LIMIT 1];
        System.runas(agent) {
        cscfga__Product_Basket__c basket = [SELECT id, csordtelcoa__Previous_Product_Basket__c, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' and csordtelcoa__Basket_Stage__c = 'Commercial Configuration' LIMIT 1];
        Test.startTest();
        chownProductBasketUtil.changeBasketStageForChown(basket.csordtelcoa__Previous_Product_Basket__c);
        Test.stopTest();
        cscfga__Product_Basket__c basket1 = [SELECT id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' and csordtelcoa__Previous_Product_Basket__c = null LIMIT 1];
        System.assert(basket.csordtelcoa__Basket_Stage__c != 'Contract Accepted');
        }
    }
    
    @isTest static void changeBasketStageForChownExceptionTest(){
        User agent = [Select id from user LIMIT 1];
        System.runas(agent) {
        cscfga__Product_Basket__c basket = [SELECT id, csordtelcoa__Previous_Product_Basket__c, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' and csordtelcoa__Basket_Stage__c = 'Commercial Configuration' LIMIT 1];
        basket.csordtelcoa__Previous_Product_Basket__c = null;
        Test.startTest();
        chownProductBasketUtil.changeBasketStageForChown('23456789');
        Test.stopTest();
        System.assert(basket != null);
        }
    }
}