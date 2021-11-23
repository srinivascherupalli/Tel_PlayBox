@isTest
public class CaseAssignmentTriggerTest {
 
       public static testMethod void TestRunAssigRulesforPartner()
        {
    test.startTest();
    Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Sales Support').getRecordTypeId();
    Case c = new Case(Status='New',Origin ='Email',recordtypeid=devRecordTypeId,type='CSA');
   
    insert c;
    case ca=[select ownerid from case where id=:c.id];
    system.assertNotEquals(userinfo.getUserId(),ca.ownerid );
    test.stopTest();
    }

}