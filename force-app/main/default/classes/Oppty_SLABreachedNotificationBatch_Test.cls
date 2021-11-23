@isTest(seeAllData=false) 
private class Oppty_SLABreachedNotificationBatch_Test {
    @testSetup 
    static void setupTestData(){   
        Account testAccount;
        testAccount = SYS_TestDataFactory.createAccount('test', 'Enterprise');
        testAccount.OwnerId = UserInfo.getUserId();
        Datetime todaysDate = (DateTime)Date.today();
        insert testAccount;   
        List<Opportunity> testListOppty = SYS_TestDataFactory.createOpportunities(testAccount.Id,10);
        for(Opportunity testOpp:testListOppty){                
            testOpp.Partner_Opportunity_Verification__c = 'Verification Required';
            testOpp.Opportunity_Source__c = 'Partner';
            testOpp.SLA_date__c = todaysDate;
        }
        insert testListOppty;  
        
    } 
    @isTest static void testBreachNotificationBatch(){
        
        Test.startTest();
            Oppty_SLABreachedNotificationBatch invokeSlaBreach = new Oppty_SLABreachedNotificationBatch();
            String sch = '0 0 2 * * ?'; 
            system.schedule('TestOpptySLABreach', sch, invokeSlaBreach);
            List<Opportunity> tstOpptyLst = [Select Id from Opportunity where Name LIKE '%Test Opportunity%'];
            System.assertEquals(tstOpptyLst.size(),10);   
        Test.stopTest();
    }
    
}