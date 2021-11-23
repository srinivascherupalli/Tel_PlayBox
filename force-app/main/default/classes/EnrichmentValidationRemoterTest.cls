/*
EDGE-92626
Name : EnrichmentValidationRemoterTest 
Description :UI validation for notbeforeCRD selection on enrichment screen

*/

@isTest
public class EnrichmentValidationRemoterTest{
    
    @isTest 
    static void testMethod2()
    {
        Account testAccount = new Account();
        testAccount.Name = 'TestAccount';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        insert basket;
        
        Customer_Authority_Form__c caf= new Customer_Authority_Form__c(Name = 'Test CAF',OwnerId = UserInfo.getUserId(),Opportunity__c = testOpp.Id,Customer_Authorised_date__c =System.today() - 5);
        insert caf;
       
        Map<String, Object> inputmap = new Map<String, Object>();
        
        inputmap.put('NotBefCRD','2019-07-14');
        inputmap.put('basketId',basket.id);
        system.debug('input map'+inputmap);
        Test.startTest();
        EnrichmentValidationRemoter.getData(inputmap);
        Test.stopTest();
         system.assert(!inputmap.isEmpty());
    }
}