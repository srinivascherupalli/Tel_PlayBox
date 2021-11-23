/**
* Author: Nilima Borse
* Team: Jaipur
* Sprint: 21.03
* JIRA Story: P2OB-10399
* Date: 18/02/2021
* Class Name: csGetCaseConfigurationsCtrlTest 
* Description: This test class will test all test scenario of getting all custom metadata config functionality.
* 04th Oct 2021 : Vivian : DIGI-29138 : Fixing mobilephone format as per SFO's DIGI-4056
**/

@IsTest
public class csGetCaseConfigurationsCtrlTest {

    // test method to cover csGetCaseConfigurationsCtrl.getGetCaseConfigurations functionaliy
    @IsTest
    static void testGetCaseConfiguration() {

        csGetCaseConfigurationsCtrl csTest = new csGetCaseConfigurationsCtrl();

        csGetCaseConfigurationsCtrl.cs_ResponseWrapper csWrapper = csGetCaseConfigurationsCtrl.getGetCaseConfigurations('Large', '', '');

        System.debug('csWrapper++++'+csWrapper);        
        System.assert(csWrapper!=null);
        
    }
    
    // test method to cover csGetCaseConfigurationsCtrl.getGetCaseConfigurations functionaliy
    @IsTest
    static void testGetCaseConfigurationSmall() {

        csGetCaseConfigurationsCtrl csTest = new csGetCaseConfigurationsCtrl();

        csGetCaseConfigurationsCtrl.cs_ResponseWrapper csWrapper = csGetCaseConfigurationsCtrl.getGetCaseConfigurations('Small', '', '');

        System.debug('csWrapper++++'+csWrapper);        
        System.assert(csWrapper!=null);
        
    }

    //Mofit Pathan(Jaipur)
    
    // test method to cover csGetCaseConfigurationsCtrl.getGetCaseConfigurations functionaliy
    @IsTest
    static void testsearchHistory() {

        csGetCaseConfigurationsCtrl csTest = new csGetCaseConfigurationsCtrl();
        csGetCaseConfigurationsCtrl.setSearchHistory('escalate'); 
        csGetCaseConfigurationsCtrl.setSearchHistory('disput'); 
        csGetCaseConfigurationsCtrl.setSearchHistory('billing'); 
        csGetCaseConfigurationsCtrl.setSearchHistory('order');
        csGetCaseConfigurationsCtrl.setSearchHistory('report'); 
        csGetCaseConfigurationsCtrl.setSearchHistory('fault');    
         ss_Case_Search__c[] searchHistoryForUser = [Select id,User__c, Attachments__c, Search_History__c from ss_Case_Search__c where User__c =: userinfo.getuserId()] ;    
        system.assert(searchHistoryForUser!=null);    
    }
    
    //test method to cover csGetCaseConfigurationsCtrl.getGetOpportunity & csGetCaseConfigurationsCtrl.getProductDomain
    @IsTest
    static void testGetOpportunityProductDomain()
    {
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
                Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+61123456789',
            Email = 'test@tele2.com'  
        );
        Insert contact;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Opportunity testOpty = csGetCaseConfigurationsCtrl.getGetOpportunity(opp.Id);
        System.assert(testOpty!=null);
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        Map<String,Object> testProductDomain = csGetCaseConfigurationsCtrl.getCaseValidations(opp.Id,'CBSContract');
        Map<String,Object> testProductDomain1 = csGetCaseConfigurationsCtrl.getCaseValidations(opp.Id,'CBSBilling');
        Map<String,Object> testProductDomain2 = csGetCaseConfigurationsCtrl.getCaseValidations(opp.Id,'CPE');
		Map<String,Object> testProductDomain3 = csGetCaseConfigurationsCtrl.getCaseValidations(opp.Id,'Get Solution Support');
        
      
        System.assert(testProductDomain!=null);
    }

    
}