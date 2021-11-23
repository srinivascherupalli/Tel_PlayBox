/*****************************************************************************
@Author: Mahesh Gaikwad
@CreateDate: 22-July-2019
@ModifiedByandDate: 
@Description:  This class is test class for Salesup_LinkedCasesController
@References
Epic :Certitude And Sales Support
Story:EDGE-94141
*******************************************************************************/
@isTest(SeeAllData=false)
private class Salesup_LinkedCasesControllerTest {

    @testSetup static void setupTestData() {
        // Create common test accounts
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;

        Case testCSObj= new Case(Subject='Linked Case Parent',
                                 AccountId=acct.id,
                                 Description='Test');
        testCSObj.RecordTypeId=Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        insert testCSObj;

        Case testCSObjUpdated =  new Case(id=testCSObj.id, salesup_Link_Case__c = testCSObj.Id);

        List<Case> linkedCaseToCreate = new List<Case>();
        linkedCaseToCreate.add(testCSObjUpdated);
        
        for(Integer i=0;i<2;i++){
            Case testCSObjTemp = new Case(Subject='Linked Case '+i,
                                 AccountId=acct.id,
                                 salesup_Link_Case__c = testCSObj.ID,
                                 Description='Test');
            linkedCaseToCreate.add(testCSObjTemp);
        }   

        upsert linkedCaseToCreate;
    }

    @IsTest private static user returnContextUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales - Enterprise'];
        User userObj = new User(Alias = 'newUser', Email='linkedCases@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='linkedCases@testorg.com',phone='+911231231234');
        System.assertEquals('Testing', userObj.LastName, 'Last name should be Testing');
        return userObj;
    }
    
    @IsTest static void  fetchLinkedCases_PositiveScenario(){
        
        User userObj = returnContextUser();

        list<Case> allLinkedCases = new list<Case>();

        Test.startTest();
        Case linkedCaseObj = [SELECT Id FROM Case WHERE Subject = 'Linked Case Parent' limit 1];
        // Run using the user of profile Sales - Enterprise
        System.runAs(userObj){
            allLinkedCases = Salesup_LinkedCasesController.fetchLinkedCases(linkedCaseObj.Id);
        }
        Test.stopTest();

        System.assertEquals(2, allLinkedCases.size(), 'Number of linked cases are not 2');       
    }

    // If passed case id is empty then it should return empty case list
    @IsTest static void  fetchLinkedCases_NegativeScenario(){
        
        User userObj = returnContextUser();

        list<Case> allLinkedCases = new list<Case>();

        Test.startTest();
        Case linkedCaseObj = [SELECT Id FROM Case WHERE Subject = 'Linked Case Parent' limit 1];
        // Run using the user of profile Sales - Enterprise
        System.runAs(userObj){
            allLinkedCases = Salesup_LinkedCasesController.fetchLinkedCases('');
        }
        Test.stopTest();

        System.assertEquals(0, allLinkedCases.size(), 'Number of linked cases should be zero');    
    }

    @IsTest static void  fetchAllCaseRecords_Test(){
        User userObj = returnContextUser();
        Salesup_LinkedCasesController.DataTableResponse dataTableResponse;
        
        Test.startTest();
        Case linkedCaseObj = [SELECT Id FROM Case WHERE Subject = 'Linked Case Parent' limit 1];
        // Run using the user of profile Sales - Enterprise
        System.runAs(userObj){
            dataTableResponse = Salesup_LinkedCasesController.fetchAllCaseRecords(String.valueOf(linkedCaseObj.Id), 'Case', 'Salesup_DataTableFieldSet');
        }
        Test.stopTest();
        
        System.assertEquals(2, dataTableResponse.lstDataTableData.size(), 'Number of linked cases should be 2');  
    }

    @IsTest static void  assignCasesToUser_Test(){
        User userObj = returnContextUser();
        String returnMessage;
        
        Test.startTest();
        
        List<String> caseIDS = new List<String>();

        for(case csObj : [SELECT Id FROM Case LIMIT 10]){
            caseIDS.add(csObj.Id);
        }
       
        // Run using the user of profile Sales - Enterprise
        System.runAs(userObj){
            returnMessage = Salesup_LinkedCasesController.assignCasesToUser(caseIDS);
        }
        Test.stopTest();
        
        System.assertEquals('Success', returnMessage, 'Returned message is not success');  
    }
}