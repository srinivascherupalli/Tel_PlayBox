/*******************************************************************
@Class Name:FindRelatedLeadsControllerTest
@Description:Sprint 19.04 , EDGE-71679
@Date:19-03-2019
@Author:SFO Team (Sravanthi)
@Comments:Test class for FindRelatedLeadsController

@Last Modified By: Pallavi B              
@Last Modified Date: 16/03/2021 S21.04 :: P2OB-12075             
@Last Modified Comments: As part of Tech Debt (Removed References for the Label of Enterprise Record Type)             

*********************************************************************/
@isTest
public class FindRelatedLeadsControllerTest {
    @isTest
    static void findRelatedLeadsControllerTest1(){
        Test.startTest();
        String leadQueue = System.Label.Lead_EnterpriseQueue;
        List<Lead> leadList=new List<Lead>();
        lead l=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',Email = 'test.test@inf.com',Country__c='India',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(System.label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                        phone='031245678');
        leadList.add(l);
        lead l1=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',Email = 'test.test@inf.com',Country__c='India',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(System.label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                         phone='031245678');
        leadList.add(l1);        
        insert leadList;
        list<QueueSobject> q = [select Id, QueueId from QueueSobject WHERE SobjectType = 'Lead' AND Queue.Name =:leadQueue LIMIT 1];
        l1.OwnerId=q[0].QueueId;
        update l1;       
        FindRelatedLeadsController.getData(l.id);
        FindRelatedLeadsController.changeOwner(l.id);
        system.assertequals(String.valueOf(l.ownerId),null);
        Test.stopTest();
    }
    
    @isTest
    static void findRelatedLeadsControllerTest2(){
        Test.startTest();
        List<Lead> leadList=new List<Lead>();
        lead l=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',Email = 'test.test@inf.com',Country__c='India',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(System.label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                        phone='031245678');
        leadList.add(l);
        lead l1=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',Email = 'test.test@inf.com',Country__c='India',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(System.label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                         phone='031245678');
        leadList.add(l1);        
        insert leadList;
        FindRelatedLeadsController.changeOwner(l.id);
        system.assertEquals('test.test@inf.com', leadList.get(0).Email);
        Test.stopTest();
    }
    
}