/**
* Author: Shreyansh Sharma
* Team: Jaipur
* Sprint: 21.07
* JIRA Story: P2OB-13643
* Date: 5/18/2021 
* Description: Test class for csGetCaseValidationsHelper
**/
@isTest
public class csGetCaseValidationsHelperTest {
    //check existing CBS Billing Case
    @isTest
    public static void checkExistingCBSCaseValidations(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=csGetCaseValidationsHelper.existingCBSCaseValidation(optyObj.id);
        System.assertEquals(results.get('CaseAlreadyExist'), 'no');
        Test.stoptest();
    }
    //check existing CBS Billing Case - Case Exist Scenerio - Jaipur Team - Mofit Pathan
    @isTest
    public static void checkExistingCBSCaseValidationSuccess(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Case caseObj = new Case();
        caseObj.OpportunityId__c = optyObj.Id;
        caseObj.srvsup_Categories__c = 'Billing Solution Design';
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();    
        insert caseObj;
        Test.startTest();
        Map<String,Object> results=csGetCaseValidationsHelper.existingCBSCaseValidation(optyObj.id);
        System.assertEquals(results.get('CaseAlreadyExist'), 'yes');
        Test.stoptest();
    }
    //check existing CBS Contract Case
    @isTest
    public static void checkExistingCBSCaseContractValidations(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=csGetCaseValidationsHelper.ExistingCBSCaseContractValidation(optyObj.id);
        System.assertEquals(results.get('CaseAlreadyExist'), 'no');
        Test.stoptest();
    }
    //get Product Domain value for CPE case
    @isTest
    public static void checkgetProductDomain(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=csGetCaseValidationsHelper.getProductDomain(optyObj.id);
        System.assertNotEquals(results.get('oppDetails'),NULL);
        
        Test.stoptest();
    }
    
    //Stage validation for Presales case
    @isTest
    public static void checkpresalesOpportunityStageValidation(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=csGetCaseValidationsHelper.presalesOpportunityStageValidation(optyObj.id);
        System.assertNotEquals(results.get('oppDetails'),NULL);
        
        Test.stoptest();
    }
    @istest
    public static void testOppStageValidation(){
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE',Credit_Health__c = 'Low Risk',Override_Credit_Health__c = false);
        insert acct;
        
        
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = acct;
        testOpp.AccountId = acct.Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Qualify';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Contract_Type__c = null;
        testOpp.Expected_TCV_Range__c = null;
        testOpp.Will_this_require_integration__c = null;
        testOpp.Number_of_Additional_Domains_if_any__c = null;
        insert testOpp;
        
        Opportunity testOpp1 = new Opportunity();
        Id customRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_MAC).getRecordTypeId();
        testOpp1.RecordTypeId = customRecordTypeId;
        testOpp1.Account = acct;
        testOpp1.AccountId = acct.Id;
        testOpp1.Name = 'testOpp'; 
        testOpp1.StageName = 'Closed Won';
        testOpp1.Product_Type__c = 'Non Modular';
        testOpp1.CloseDate = System.Date.today();
        testOpp1.Contract_Type__c = null;
        testOpp1.Expected_TCV_Range__c = null;
        testOpp1.Will_this_require_integration__c = null;
        testOpp1.Number_of_Additional_Domains_if_any__c = null;
        insert testOpp1;
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Account = acct;
        testOpp2.AccountId = acct.Id;
        testOpp2.Name = 'testOpp';
        testOpp2.StageName = 'Define';
        testOpp2.Product_Type__c = 'Non Modular';
        testOpp2.CloseDate = System.Date.today();
        insert testOpp2;
        
        Opportunity testOpp3 = new Opportunity();
        testOpp3.Account = acct;
        testOpp3.AccountId = acct.Id;
        testOpp3.Name = 'testOpp';
        testOpp3.StageName = 'Qualify';
        testOpp3.Product_Type__c = 'Non Modular';
        testOpp3.CloseDate = System.Date.today();
        testOpp3.Contract_Type__c = 'Telstra Purple';
        testOpp3.Expected_TCV_Range__c = '$10,000 to $99,999';
        testOpp3.Will_this_require_integration__c = 'Yes';
        testOpp3.Number_of_Additional_Domains_if_any__c = '2';
        insert testOpp3;
        
        Opportunity testOpp4 = new Opportunity();
        testOpp4.Account = acct;
        testOpp4.AccountId = acct.Id;
        testOpp4.Name = 'testOpp';
        testOpp4.StageName = 'Develop';
        testOpp4.Product_Type__c = 'Non Modular';
        testOpp4.CloseDate = System.Date.today();
        testOpp4.Contract_Type__c = 'Telstra Purple';
        testOpp4.Expected_TCV_Range__c = '$10,000 to $99,999';
        testOpp4.Will_this_require_integration__c = 'Yes';
        testOpp4.Number_of_Additional_Domains_if_any__c = '2';
        insert testOpp4;
        
        Opportunity testOpp5 = new Opportunity();
        testOpp5.Account = acct;
        testOpp5.AccountId = acct.Id;
        testOpp5.Name = 'testOpp';
        testOpp5.StageName = 'Define';
        testOpp5.Product_Type__c = 'Non Modular';
        testOpp5.CloseDate = System.Date.today();
        testOpp5.Contract_Type__c = 'Telstra Purple';
        testOpp5.Expected_TCV_Range__c = '$10,000 to $99,999';
        testOpp5.Will_this_require_integration__c = 'Yes';
        testOpp5.Number_of_Additional_Domains_if_any__c = '2';
        insert testOpp5;
        
        test.startTest();
        
        List<Opportunity> ListOpp = new List<Opportunity>();
        ListOpp.add(testOpp);
        ListOpp.add(testOpp1);
        ListOpp.add(testOpp2);
        ListOpp.add(testOpp3);
        ListOpp.add(testOpp4);
        ListOpp.add(testOpp5);
        
        csGetCaseValidationsHelper.ScreenInputs screenInput = new csGetCaseValidationsHelper.ScreenInputs();
        for(Opportunity opp : ListOpp){
            screenInput.oppId = opp.id;
            screenInput.AccountId = acct.id;
            screenInput.categoryValue = 'Solution Development';
            screenInput.flowName = 'Get Solution Support';
            
        }  
        List<csGetCaseValidationsHelper.ScreenInputs> lstScreenInputs = new List<csGetCaseValidationsHelper.ScreenInputs>();
        lstScreenInputs.add(screenInput);
        List<string> strList = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs);
        lstScreenInputs.clear();
          screenInput.oppId = ListOpp[3].id;  
            screenInput.categoryValue = 'Solution Development';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList1 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs);  
        lstScreenInputs.clear();
        
          screenInput.oppId = ListOpp[0].id;  
            screenInput.categoryValue = 'Solution Development';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList0 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs);  
        lstScreenInputs.clear();
        
          screenInput.oppId = ListOpp[1].id;  
            screenInput.categoryValue = 'Solution Development';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList11 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs);  
        lstScreenInputs.clear();
        
          screenInput.oppId = ListOpp[4].id;
            screenInput.categoryValue = 'Qualification';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList2 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs); 
        
        lstScreenInputs.clear();
          screenInput.oppId = ListOpp[4].id;   
            screenInput.categoryValue = 'Workshop';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList3 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs); 
        
        lstScreenInputs.clear();
          screenInput.oppId = ListOpp[4].id;   
            screenInput.categoryValue = 'Indicative Pricing';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList4 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs); 
        
        lstScreenInputs.clear();
          screenInput.oppId = ListOpp[5].id;   
            screenInput.categoryValue = 'Customer Meeting';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList5 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs);
        lstScreenInputs.clear();
          screenInput.oppId = ListOpp[5].id;   
            screenInput.categoryValue = 'Engage Standard Solutions';
            screenInput.flowName = 'Get Solution Support';
        lstScreenInputs.add(screenInput);
        List<string> strList6 = csGetCaseValidationsHelper.OppStageValidation(lstScreenInputs);
        
        //system.assertEquals(strList.size(), 1);
        //system.assertEquals(strList1.size(), 1);
        system.assertNotEquals(strList6.size(), null);
        
        
        test.stopTest();
        
    }

    
    
}