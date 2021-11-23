/*
* @Author   :   Honey Mehta
* @Date     :   25 june 2020
* @Desc     :   Test class related to EDGE-153347  Apex class linked to "Customer Pre-Authorisation" button on CS Basket to capture Pre-Authorisation details for MACD Orders
* @MainClass:   CustomButtonContractAuthorisation
*/

@isTest
public class CustomButtonContractAuthorisationTest {
   
    @testsetup static void setupTestData(){
        Account acc = new Account(Name = 'Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
        insert acc;
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        opp.accountId = acc.id;
        insert opp;
        
        Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        INSERT c;
        

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
    }
    
    @isTest static void testPerformAction(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c 
                                            WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
        Test.startTest();
        CustomButtonContractAuthorisation cbcAuth = new CustomButtonContractAuthorisation();
        String ret = cbcAuth.performAction(basket.Id);
        Test.stopTest();
        system.assert(ret.contains('c__ContractPreauthUploadPage'));
    }
}