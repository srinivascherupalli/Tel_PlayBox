/**
* Description : Test Class for PRMOpenAirNotificationUtil
* Jira        : P2OB - 14466, P2OB - 14473
* Author      : Team Hawaii : Tirth Shah
* Date        : 20-May-2021
**/
@isTest
public class PRMOpenAirNotificationUtilTest {
	
    @isTest
    public static void GenrateOpenAirNotificationDataTest(){
        Account customerAccount=TestUtil.createAccount('Testacc');
        list<Opportunity> oppList = new list<Opportunity>();
        Opportunity opp =TestUtil.createOpportunity(customerAccount.id);
        opp.Product_Type__c='Modular';
        opp.Opportunity_Type__c='Disconnected';
        opp.Contract_Attachment_Count__c=1;
        opp.Attachment_Count__c=1;
        oppList.add(opp) ;
        insert oppList;
        Case cs = new Case(RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').RecordTypeId,AccountId=customerAccount.id,Status='New',OpportunityId__c=opplist[0].id,Subject='This is child case');
        insert cs;
        System.assertEquals(cs.RecordTypeId,Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').RecordTypeId);
        
        List<OpenAir_Notification__e> OanList = new List<OpenAir_Notification__e>();
        OanList.add(PRMOpenAirNotificationUtil.GenrateOpenAirNotificationData(cs.Id,opplist[0].id));
        PRMOpenAirNotificationUtil.publishEvents(OanList);
        System.assertEquals(OanList.size(),1);
    }
}