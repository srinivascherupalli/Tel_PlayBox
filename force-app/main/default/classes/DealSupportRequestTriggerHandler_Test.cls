/*
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772  updating API version to 50.
*/
@istest
public class DealSupportRequestTriggerHandler_Test {
    private static testMethod void DSRtestCreate() {
        try{
        Id recordtypeID = Schema.SObjectType.Deal_Support_Request__c.getRecordTypeInfosByName().get('Pricing Support').getRecordTypeId();
        Account acc=new Account();
        acc.Name='TESTAccount';
        acc.Migrated_Customer__c=true;
        acc.Customer_Status__c='ACTIVE';
        Insert acc;
        Opportunity newOpp=new Opportunity();
        newOpp.AccountId=acc.Id;
        newOpp.Name='Test';
        newOpp.closedate=System.today();
        newOpp.Proposal_Required_Date__c=System.today();
        newOpp.StageName='Propose';
        Insert newOpp;	
        Deal_Support_Request__c DSR1 = new Deal_Support_Request__c();
        DSR1.Pricing_Request_Status__c='Assessment Not Started';
        DSR1.RecordTypeId=recordtypeID;
        DSR1.Opportunity__c=newOpp.id;
        DSR1.Comments__c='test2';
        insert DSR1;
        Deal_Support_Request__c DSR3 = new Deal_Support_Request__c();
        DSR3.Pricing_Request_Status__c='On Hold';
        DSR3.RecordTypeId=recordtypeID;
        DSR3.Opportunity__c=newOpp.id;
        DSR3.Comments__c='test2';
        insert DSR3; 
         list<Deal_Support_Request__c> DSRorg = [SELECT Id FROM Deal_Support_Request__c];
            system.assertEquals(DSRorg[0].id,DSR1.Id);
        }
        catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());
        }
    }
    private static testMethod void DSRtestUpdate() {
        try{
        Id recordtypeID = Schema.SObjectType.Deal_Support_Request__c.getRecordTypeInfosByName().get('Pricing Support').getRecordTypeId();
        Account acc=new Account();
        acc.Name='TESTAccount';
        acc.Customer_Status__c='ACTIVE';
        acc.Migrated_Customer__c=true;
        Insert acc;
        Opportunity newOpp=new Opportunity();
        newOpp.AccountId=acc.Id;
        newOpp.Name='Test';
        newOpp.closedate=System.today();
        newOpp.Proposal_Required_Date__c=System.today();
        newOpp.StageName='Propose';
        Insert newOpp;	
        Deal_Support_Request__c DSR1 = new Deal_Support_Request__c();
        DSR1.Pricing_Request_Status__c='Assessment Not Started';
        DSR1.RecordTypeId=recordtypeID;
        DSR1.Opportunity__c=newOpp.id;
        DSR1.Comments__c='test2';
        insert DSR1;
        //Deal_Support_Request__c DSR3 = new Deal_Support_Request__c();
        DSR1.Pricing_Request_Status__c='On Hold';
        DSR1.RecordTypeId=recordtypeID;
        DSR1.Status__c='Completed';
        DSR1.Opportunity__c=newOpp.id;
        DSR1.Comments__c='test2';
        update DSR1; 
         list<Deal_Support_Request__c> DSRorg = [SELECT Id FROM Deal_Support_Request__c];
            system.assertEquals(DSRorg[0].id,DSR1.Id);
        }
        catch(Exception Ex){
            system.debug('Exdeption-->'+Ex.getMessage());
        }
    }
}