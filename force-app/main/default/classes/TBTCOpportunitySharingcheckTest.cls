@IsTest
public class TBTCOpportunitySharingcheckTest {
    private static testMethod void  spTBTCValidationTest1(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
            User usr = new User(Email='telsta@test.com', 
                              EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_AU', ProfileId = p.Id, 
                              TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
            
            insert usr;
            
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        system.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            //P2OB-14077 SFO Business plus is no longer a valid value for enterprise record type changing it to priority
            acc.aptps_business_segment__c = 'Priority';
            Insert acc;
            Account acc1 = new Account();
            acc1.name = 'TestClassEvent1';
            acc1.CIDN__c = 'ASDF12345';
            acc1.RecordTypeId = accRecordTypeId;
            acc1.Migrated_Customer__c = true;
            acc1.Customer_status__c = 'ACTIVE';
            Insert acc1;
            //id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            //opp.recordTypeId=oppRecordTypeId;
            opp.Name='TestOppCreateForEventCreate';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;
            system.assertEquals(opp.Name,'TestOppCreateForEventCreate');
            Opportunity opp1=new Opportunity();
            opp1.AccountId=acc1.Id;
            //opp.recordTypeId=oppRecordTypeId;
            opp1.Name='TestOppCreateForEventCreate1';
            opp1.Proposal_Required_Date__c=System.today()+2;
            opp1.CloseDate=System.today()+10;
            opp1.StageName=System.label.Opp_Stage_Develop;
            opp1.Description__c='Test';
            opp1.Product_Domain__c='MOBILES';
            opp1.Shared_Opportunity__c=True;
            insert opp1;
            system.assertEquals(opp1.Name,'TestOppCreateForEventCreate1');
        }
        
        Test.StopTest();
    }
    private static testMethod void  spTBTCValidationTest2(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
            User usr = new User(Email='telsta@test.com', 
                              EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_AU', ProfileId = p.Id, 
                              TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
            
            insert usr;
            
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        system.runas(usr){
            Account acc1 = new Account();
            acc1.name = 'TestClassEvent1';
            acc1.CIDN__c = 'ASDF12345';
            acc1.RecordTypeId = accRecordTypeId;
            acc1.Migrated_Customer__c = true;
            acc1.Customer_status__c = 'ACTIVE';
            Insert acc1;
            //id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
            Opportunity opp1=new Opportunity();
            opp1.AccountId=acc1.Id;
            //opp.recordTypeId=oppRecordTypeId;
            opp1.Name='TestOppCreateForEventCreate1';
            opp1.Proposal_Required_Date__c=System.today()+2;
            opp1.CloseDate=System.today()+10;
            opp1.StageName=System.label.Opp_Stage_Develop;
            opp1.Description__c='Test';
            opp1.Product_Domain__c='MOBILES';
            opp1.Shared_Opportunity__c=True;
            insert opp1;
            system.assertEquals(opp1.Name,'TestOppCreateForEventCreate1');
        }
        
        Test.StopTest();
    }
}