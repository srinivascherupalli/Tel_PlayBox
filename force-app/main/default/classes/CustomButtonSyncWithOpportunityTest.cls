@isTest
public class CustomButtonSyncWithOpportunityTest {

    static testMethod void Test(){
        
		
		Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;
		
		
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
		

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;


        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'testConfig';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        insert testConfig;		
		
		
        Test.startTest();
        CustomButtonSynchronizeWithOpportunity syncWithOpp = new CustomButtonSynchronizeWithOpportunity();
        cscfga__Product_Configuration__c prodConfig1 = [Select id, Name from cscfga__Product_Configuration__c where name = 'testConfig' LIMIT 1];  
        syncWithOpp.performAction(testBasket.Id);
        System.assert(prodConfig1 != null);
        Test.stopTest();
        
    }  
}