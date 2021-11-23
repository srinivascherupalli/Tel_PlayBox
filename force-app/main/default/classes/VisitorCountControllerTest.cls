/**
*   Purpose         :   This class is used to test coverage of VisitorCountControllerClass.
*
*   Author          :   Pratap Garani (Wipro)
*
*   Date            :   01/20/2019
*
*   Current Version :   V_1.0
*
*   Revision Log    :   V_1.0 - DPA-271 - Created
*                   :   V_1.1 - DPA-1020 - Updated
**/
@isTest
private class VisitorCountControllerTest 
{
    @testSetup static void setup() {
        List<Visitor_Tracker__c> testAccts = new List<Visitor_Tracker__c>();
        testAccts.add(new Visitor_Tracker__c(Originating_URL__c = 'xyz.com',
                                             Button_Type__c = Label.CHAT_BUTTON_ENTERPRISE));
        testAccts.add(new Visitor_Tracker__c(Originating_URL__c = 'xyz.com',
                                             Button_Type__c = 'Concierge Abandoned'));
        testAccts.add(new Visitor_Tracker__c(Originating_URL__c = 'xyz.com',
                                             Button_Type__c = 'Concierge',
                                             Record_Count__c = 3));
        testAccts.add(new Visitor_Tracker__c(Originating_URL__c = 'xyz.com',
                                             Button_Type__c = 'Concierge Abandoned',
                                             Record_Count__c = 3));
        testAccts.add(new Visitor_Tracker__c(Originating_URL__c = 'xyz.com',
                                             Button_Type__c = 'Concierge Abandoned',
                                             Record_Count__c = 1));
        insert testAccts; 
    }
    static testMethod void savePreChatVisitorCountTest(){
        Test.startTest();
        Visitor_Tracker__c vr = [SELECT Id,Button_Type__c FROM Visitor_Tracker__c where Button_Type__c='Enterprise' LIMIT 1];
        Visitor_Tracker__c vr1 = [SELECT Id,Button_Type__c FROM Visitor_Tracker__c where Button_Type__c='Concierge' and Record_Count__c = 3 LIMIT 1];
        Visitor_Tracker__c vr2 = [SELECT Id,Button_Type__c FROM Visitor_Tracker__c where Button_Type__c='Concierge Abandoned' and Record_Count__c = 3 LIMIT 1];
        Visitor_Tracker__c vr3 = [SELECT Id,Button_Type__c FROM Visitor_Tracker__c where Button_Type__c='Concierge Abandoned' and Record_Count__c = 1 LIMIT 1];
        String test6 = VisitorCountController.saveMinimisedVisitorCount(vr2.id,'xyz.com','abc'); 
        Boolean test1 = VisitorCountController.savePreChatVisitorCount('clickInstance','Personal');
        Boolean test2 = VisitorCountController.savePreChatVisitorCount('clickInstance','Small Business');
        Boolean test3 = VisitorCountController.savePreChatVisitorCount('xyz.com','Enterprise');
        Boolean test4 = VisitorCountController.savePreChatVisitorCount('clickInstance','Enterprise Abandoned');
        String test5 = VisitorCountController.saveMinimisedVisitorCount('','xyz.com','abc');
        String test8 = VisitorCountController.saveMinimisedVisitorCount(vr1.id,'xyz.com','abc'); 
        String test7 = VisitorCountController.saveMinimisedVisitorCount(vr3.id,'xyz.com','abc'); 
        String test9 = VisitorCountController.saveMinimisedVisitorCount('','xyzw.com','abc'); 
        system.assertEquals(true, test1);
        system.assertEquals('Enterprise', vr.Button_Type__c);
        Test.stopTest();
    }

}