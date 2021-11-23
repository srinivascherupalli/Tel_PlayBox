/*******************************************************************************
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
*******************************************************************************/
@istest
public class OppProposalDueDateTrigger_Handler_Test {
    
    private static testMethod void OpptestCreate() {
        try{
            Test.StartTest();
            Id recordtypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Custom).getRecordTypeId();
            Account acc=new Account();
            acc.Name='TESTAccount';
            acc.Customer_status__c = 'ACTIVE';
            acc.Migrated_Customer__c=true;
            Insert acc;
            Opportunity newOpp=new Opportunity();
            newOpp.AccountId=acc.Id;
            newOpp.Name='Test';
            newOpp.closedate=System.today();
            newOpp.StageName=System.label.Opp_Stage_Propose;
            newOpp.Proposal_Required_Date__c=null;
            newOpp.RecordTypeId=recordtypeID;
            Insert newOpp;
            newOpp.Proposal_Required_Date__c=null;
            Update newOpp;
            system.assertEquals('Test',newOpp.Name);
            Test.StopTest();
        }
        catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());
            
        }
    }
    private static testMethod void OpptestCreateNegetive() {
        try{
            Test.StartTest();
            Id recordtypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Custom).getRecordTypeId();
            Account acc=new Account();
            acc.Name='TESTAccount';
            acc.Customer_status__c = 'ACTIVE';
            acc.Migrated_Customer__c=true;
            Insert acc;
            Opportunity newOpp=new Opportunity();
            newOpp.AccountId=acc.Id;
            newOpp.Name='Test';
            newOpp.closedate=System.today();
            newOpp.Proposal_Required_Date__c=System.today();
            newOpp.StageName=System.label.Opp_Stage_Propose;
            newOpp.RecordTypeId=recordtypeID;
            Insert newOpp;
            newOpp.Proposal_Required_Date__c=System.today();
            Update newOpp;
            system.assertEquals('Test',newOpp.Name);
            Test.StopTest();
        }
        catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());
            
        }
    }
    
    private static testMethod void  OpptestCreateTest(){
        try{
            Test.StartTest();
            Profile p = [SELECT Id FROM Profile WHERE Name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: 'Sales - Enterprise'];
            
            User usr = new User(Email='telsta@test.com', 
                                EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_AU', ProfileId = p.Id, phone='+121231231234',
                                TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
            
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = p.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com');
            insert sales;
            
            id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Custom).getRecordTypeId();
            
            
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.Customer_status__c = 'ACTIVE';
            acc.RecordTypeId = accRecordTypeId;        
            Insert acc;
            system.runas(sales){
                Opportunity opp=new Opportunity();
                opp.AccountId=acc.Id;
                opp.recordTypeId=oppRecordTypeId;
                opp.Name='TestOppCreateForEventCreate';
                opp.Proposal_Required_Date__c=null;//System.today()+2;
                opp.CloseDate=System.today()+10;
                opp.StageName='Develop';//System.label.Opp_Stage_ClosedLost;
                opp.Description__c='Test';
                opp.Product_Domain__c='MOBILES';
                opp.Shared_Opportunity__c=True;
                opp.Proposal_Required_Date__c=null;
                insert opp;
                system.assertEquals(opp.Name,'TestOppCreateForEventCreate');
                opp.Proposal_Required_Date__c=null;
                update opp;
            }
            
            Test.StopTest();
        }catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());            
        }
    }
    
    
}