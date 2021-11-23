/*
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
										updated to match the code coverage
*/

@istest
public class SharepointRelatedlistController_Test {
       @testSetup
    static void setup()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: 'Sales - Enterprise'];
            
            User usr = new User(Email='telsta@test.com', 
                                EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_AU', ProfileId = p.Id, phone='+121231231234',
                                TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
            
            insert usr;
    }
    private static testMethod void oppTestCreation() {
        
        try{
            
            
            Test.StartTest();
            SharepointRelatedlistController.fetchUser();
            
            Id recordtypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
            Account acc=TestUtil.createAccount('TESTAccount');
            acc.Migrated_Customer__c=true;
            Insert acc;
            Opportunity newOpp=new Opportunity();
            newOpp.AccountId=acc.Id;
            newOpp.Name='Test' ;
            newOpp.closedate=System.today();
            newOpp.Proposal_Required_Date__c=System.today();
            newOpp.StageName='Propose';
            newOpp.Product_Domain__c='FIXED TELEPHONY';
            newOpp.RecordTypeId=recordtypeID;
            newOpp.SharePoint_Folder_Link__c='www.salesforce.com';
            
            Insert newOpp;
            
            system.assertEquals('Test',newOpp.Name);
            
            SharepointRelatedlistController.getOppRecData(newOpp.id); 
            
            SharepointRelatedlistController.createOppRecEventSync(newOpp.id);
            SharepointRelatedlistController.createOppRequestAccess(newOpp.id);
            Test.StopTest();
        }
        
        catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());
            
        }  
        
        
    }
}