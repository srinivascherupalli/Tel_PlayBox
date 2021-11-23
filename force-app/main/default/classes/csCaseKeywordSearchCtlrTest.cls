/**
* Author: Nilima Borse
* Team: Jaipur
* Sprint: 21.03
* JIRA Story: P2OB-10970
* Date: 22/02/2021
* Class Name: csCaseKeywordSearchCtlrTest 
* Description: This test class will test all test scenario of case keyword search functionality.
**/

@IsTest
public class csCaseKeywordSearchCtlrTest {

    // test method to cover csCaseKeywordSearchCtlr.getSerachResults functionaliy
     @IsTest

    static void caseKeywordSearchWithNoUserDataTest() {
        try{
            csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper = csCaseKeywordSearchCtlr.getSearchResults('escalate', 'Large', 'Escalations, issues & complaints','');
            System.assert(csWrapper!=null);
            csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper2 = csCaseKeywordSearchCtlr.getSearchResults('dispute', 'Large', 'All','');
			System.assert(csWrapper2!=null); 
            csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper3 = csCaseKeywordSearchCtlr.getSearchResults('mobile', 'Large', 'All','');

			System.assert(csWrapper3!=null); 
        }
        catch(System.AsyncException e){
            System.assertEquals('Metadata cannot be deployed from within a test', e.getMessage());
        }
   }    

    // test method to cover csCaseKeywordSearchCtlr.getSerachResults with blank search functionaliy
   @IsTest
    static void csCaseKeywordSearchBlank() {
        try{

            csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper = csCaseKeywordSearchCtlr.getSearchResults('', 'Large', '','');
            System.assert(csWrapper!=null);
            User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            
        	System.runAs(user2){
                csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper2 = csCaseKeywordSearchCtlr.getSearchResults('', 'Small', '','');
                System.assert(csWrapper2!=null);
            }

        }
        catch(System.AsyncException e){
            System.assertEquals('Metadata cannot be deployed from within a test', e.getMessage());
        }
   }
    
    // test method to cover csCaseKeywordSearchCtlr.getSerachResults without data search functionaliy 
   @IsTest

    static void caseKeywordSearchWithUserDataTest() {
        try{
            User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            
        	System.runAs(user2){
            	csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper2 = csCaseKeywordSearchCtlr.getSearchResults('dispute', 'Large', 'All','');
                System.assert(csWrapper2!=null);  
            }
        }
        catch(System.AsyncException e){
            System.assertEquals('Metadata cannot be deployed from within a test', e.getMessage());
        }
   }
    
  @IsTest

    static void caseKeywordSearchWithoutDataTest() {
        try{
            User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            
        	System.runAs(user2){

            	csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper = csCaseKeywordSearchCtlr.getSearchResults('escalate', 'Large', 'Escalations, issues & complaints','');
                System.assert(csWrapper!=null);
                csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper2 = csCaseKeywordSearchCtlr.getSearchResults('dispute', 'Large', 'All','');
                System.assert(csWrapper2!=null); 
                csCaseKeywordSearchCtlr.cs_ResponseWrapper csWrapper3 = csCaseKeywordSearchCtlr.getSearchResults('mobile', 'Large', 'All','');

                System.assert(csWrapper3!=null); 
            }
        }
        catch(System.AsyncException e){
            System.assertEquals('Metadata cannot be deployed from within a test', e.getMessage());
        }
   }
    
    /*Jaipur :: Mofit Pathan
    Sprint & US: 21.09 & P2OB-15011 
    test method to cover csCaseKeywordSearchCtlr.setSearchHistory functionaliy*/
    @IsTest
    static void caseKeywordSearchWithSearchHistory() {
        try{
            User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            Map<String,Case_Types_Configuration__mdt> caseTypeConf = Case_Types_Configuration__mdt.getAll();
            ss_Case_Search__c searchHistoryForUser = new ss_Case_Search__c();
            searchHistoryForUser.Search_History__c = 'CBS billing solution design,Order a new service,CPE request,Request billing changes for the customer,Other support types';
            searchHistoryForUser.User__c = user2.Id;
            insert searchHistoryForUser;
            
        	System.runAs(user2){
                List<string> csWrapper = csCaseKeywordSearchCtlr.setSearchHistory('Order a new service', caseTypeConf);
                System.assert(csWrapper!=null);
                List<string> csWrapper2 = csCaseKeywordSearchCtlr.setSearchHistory('', caseTypeConf);
                System.assert(csWrapper!=null);
            }
        }
        catch(System.AsyncException e){
            System.assertEquals('Metadata cannot be deployed from within a test', e.getMessage());
        }
   } 
    
   //For creating test data
    @TestSetup
    static void makeData(){

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000)); 
        User usr1 = new User(Email='newcsux@test.com',
                                 EmailEncodingKey='UTF-8', LastName='FileTestUser'+randomInt, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_AU', ProfileId = p.Id, 
                                 TimeZoneSidKey='Australia/Sydney',FederationIdentifier='test001',username='newcsux'+randomInt+'@test.com.Test',alias = 'uxUser');
        insert usr1;
        
        
    }
}