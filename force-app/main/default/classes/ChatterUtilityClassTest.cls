/*********************************************************************************************************************************
 * Class Name   :   ChatterUtilityClassTest
 * Description  :   Test Class for ChatterUtilityClass
 SL.No.     Developer Name      Date            Story Description
 1.         Pooja Bhat          27/04/2021      EDGE-212439 - As a User, I should receive Chatter Notification if CoBA request fails/Errors
**********************************************************************************************************************************/
@isTest
private class ChatterUtilityClassTest {
    
    @testSetup
    static void testdata() {
        Account testAccount =   TestDataFactory.generateAccount();
        
        Contact testContact =   TestDataFactory.generateContact('Test',testAccount.Id,'Active','User1',System.today(),'Mobile');
        insert testContact;
    }
    
    @isTest
    static void unitTest1() {
        List<Account> accList = [SELECT Id FROM Account];
        System.assertEquals(1, accList.size());
        List<Contact> conList = [SELECT Id FROM Contact];
        System.assertEquals(1, conList.size());
        
        List<ChatterUtilityClass.ChatterFeedWrapper> feedsLst   =   new List<ChatterUtilityClass.ChatterFeedWrapper>();
        String currentUserId                                    =   UserInfo.getUserId();
        String feedMessage                                      =   'Hi {0}, This is test feed on {1}';
        
        List<String> params1 = new List<String>{'{'+currentUserId+'}','{record:' + accList[0].Id + '}'};
        List<String> params2 = new List<String>{'{'+currentUserId+'}','{record:' + conList[0].Id + '}'};
        
        String parameterizedLabel1   =   String.format(feedMessage, params1);
        Boolean isMsgWithParams11    =   parameterizedLabel1.contains(currentUserId);
        Boolean isMsgWithParams12    =   parameterizedLabel1.contains(accList[0].Id); 
        
        String parameterizedLabel2   =   String.format(feedMessage, params2);
        Boolean isMsgWithParams21    =   parameterizedLabel2.contains(currentUserId);
        Boolean isMsgWithParams22    =   parameterizedLabel2.contains(conList[0].Id);  

        feedsLst.add(new ChatterUtilityClass.ChatterFeedWrapper(null,accList[0].Id,parameterizedLabel1));
        feedsLst.add(new ChatterUtilityClass.ChatterFeedWrapper(null,conList[0].Id,parameterizedLabel2));
        
        Test.startTest();
            ChatterUtilityClass.chatterNotificationHelper(feedsLst);
            System.assertEquals(true, isMsgWithParams11);
            System.assertEquals(true, isMsgWithParams12);
            System.assertEquals(true, isMsgWithParams21);
            System.assertEquals(true, isMsgWithParams22);
        Test.stoptest();
    }

    @isTest
    static void unitTest2() {
        List<ChatterUtilityClass.ChatterFeedWrapper> feedsLst   =   new List<ChatterUtilityClass.ChatterFeedWrapper>();
        Test.startTest();
            ChatterUtilityClass.chatterNotificationHelper(feedsLst);
            ChatterUtilityClass.chatterNotificationHelper(null);
        Test.stoptest();
        System.assertEquals(0, feedsLst.size());
    }
}