/********************************************************************************
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified	: 
********************************************************************************/
@isTest
public class PortfolioCodeController_Test {
    @testSetup
    static void setup()
    {   
        Account acc =TestUtil.createAccount('test');
        insert acc;
    }
    static testMethod void PortfolioCodeTest()
    {  
        Account acc= [Select id from Account];
        Test.startTest();
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        ApexPages.currentPage().getParameters().put('id',string.valueof(acc.Id));
        PortfolioCodeController PccClass= new PortfolioCodeController(stdController);
        acc.Portfolio_Code__c='SZA01';
        Update acc;
        PortfolioCodeController PccClass_CR2= new PortfolioCodeController(stdController);
        Test.stopTest();
        system.assertEquals(PccClass.Prtfcode, False);
        system.assertEquals(PccClass_CR2.Prtfcode, True);
    }
}