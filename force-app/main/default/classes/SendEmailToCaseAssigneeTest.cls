/*---------------------------------------------------------------------
Name : SendEmailToCaseAssigneeTest
Description : The class is used as test class for SendEmailToCaseAssigneeTest
Author: Abinas Panda
Story: P2OB-3883
----------------------------------------------------------------------*/

@isTest
public class SendEmailToCaseAssigneeTest {
    @testSetup 
    public static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        //Added For UserName fix start
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = 'telt'+ orgId + dateString + randomInt;
        //Added For UserName fix end
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', Username = uniqueName + '@testteltra' + '.com'); 
        insert u;
        Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Feedback).getRecordTypeId();
        case cse = new case();
        cse.Subject = 'testsub';
        cse.AssignedUser__c = u.id;
        cse.Comments = 'testcmmt';
        cse.Feedback_Related_to__c = Label.CaseRelatedToInternalComments;
        cse.Feedback_Category__c = Label.CaseCategoryInternalComments;
        cse.RecordTypeId = cseRecordTypeId;

        cse.Internal_Case_Comments__c = 'Loogeed! abc';

        insert cse;
    }
    public static testmethod void sucessmethd() {
        Test.startTest();
        list<user> userlist = [select id,name,username,email from user];
        list<case> cselst = [select id,comments from case];
        SendEmailToCaseAssignee.sendMail(userlist[0].id, cselst[0].id);

        SendEmailToCaseAssignee.getComments(cselst[0].id);

        Test.stopTest();
        system.assertNotEquals(0, userlist.size());
    }
    
}