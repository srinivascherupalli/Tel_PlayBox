@isTest
public class RecordListControllerTest {
    public static testMethod void TestgetData()
    {
        
        Test.startTest();
        Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
        insert accdis;
        
        Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        system.debug('Proceessing');
        opp.StageName = 'Prospecting';
        opp.AccountId = accdis.Id;
        //opp.Partner__c=userinfo.getUserid();
        // opp.SubmittoPartnerStatus__c='Submitted'; 
        opp.CloseDate = Date.today();
        List<String> sObjectField=new List<String>();
        insert opp;
        system.debug(userinfo.getUserid());
        system.debug('optyId1'+opp.Id);
        String sObjectName='OpportunityContactRole';
        //String sObjectFieldsNames='Contact.Name,Contact.Email';
        String sObjectFieldsNames='Contact.Name';
        sObjectField.add(sObjectFieldsNames);
        string oppId = '';
        oppId = opp.Id;
        
        String whereClause='opportunityId=  \''+opp.Id+'\'';
        //String relationshipFields='{"Contact.Name":"url,Contact Name,ContactName","Contact.Email":"email,Email,ContactEmail"}';
        String relationshipFields='{"Contact.Name":"url,Contact Name,ContactName"}';
        RecordListController.getColumnsAndData(sObjectName, sObjectField, whereClause, relationshipFields);
        
        RecordListController.getOpptyStatus(oppId);
        
        
        System.assertEquals(opp.Name, 'Test Opportunity');
        
        Test.stopTest(); 
    }
    public static testMethod void TestgetData2()
    {
        Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
        insert accdis;
        
        Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        system.debug('Proceessing');
        opp.StageName = 'Prospecting';
        opp.AccountId = accdis.Id;
        //opp.Partner__c=userinfo.getUserid();
        // opp.SubmittoPartnerStatus__c='Submitted'; 
        opp.CloseDate = Date.today();
        List<String> sObjectField=new List<String>();
        insert opp;
        system.debug(userinfo.getUserid());
        system.debug('optyId1'+opp.Id);
        String sObjectName='OpportunityContactRole';
        String sObjectFieldsNames='Contact.Name,Contact.Email,';
        //String sObjectFieldsNames='Role';
        sObjectField.add(sObjectFieldsNames);
        string oppId = '';
        oppId = opp.Id;
        
        String whereClause='opportunityId=  \''+opp.Id+'\'';
        String relationshipFields='{"Contact.Email":"email,Email,ContactEmail"}';
        RecordListController.getColumnsAndData(sObjectName, sObjectField, whereClause, relationshipFields);
        
        
        System.assertEquals(opp.Name, 'Test Opportunity');
    }
    public static testMethod void TestgetData11()
    {
        
        Test.startTest();
        Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
        insert accdis;
        
        Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        system.debug('Proceessing');
        opp.StageName = 'Prospecting';
        opp.AccountId = accdis.Id;
        //opp.Partner__c=userinfo.getUserid();
        // opp.SubmittoPartnerStatus__c='Submitted'; 
        opp.CloseDate = Date.today();
        List<String> sObjectField=new List<String>();
        insert opp;
        system.debug(userinfo.getUserid());
        system.debug('optyId1'+opp.Id);
        String sObjectName='OpportunityContactRole';
        //String sObjectFieldsNames='Contact.Name,Contact.Email,Contact.FirstName';
        String sObjectFieldsNames='Contact.Name,Contact.AccountId';
        sObjectField.add(sObjectFieldsNames);
        string oppId = '';
        oppId = opp.Id;
        
        String whereClause='opportunityId=  \''+opp.Id+'\'';
        //String relationshipFields='{"Contact.Name":"url,Contact Name,ContactName","Contact.Email":"email,Email,ContactEmail"}';
        String relationshipFields='{"Contact.Name":"url,Contact Name,ContactName"}';
        RecordListController.getColumnsAndData(sObjectName, sObjectField, whereClause, relationshipFields);
        
        
        System.assertEquals(opp.Name, 'Test Opportunity');
        
        Test.stopTest(); 
    }
}