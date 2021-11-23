/*------------------------------------------------------------------------ 
Created By: Ivan Aerlic 
US: EDGE-80291, P2OB-3621
----------------------------------------------------------------------------*/
@isTest(SeeAllData=true)
public class WaitingUserResponse_Batch_Test {     
    private static final Integer BATCH_SIZE = WaitingUserResponse_BatchSchedule.BATCH_SIZE;
    //A unique value placed inside the body of a FeedItem so that we can observe it is 
    //test data and not a default FeedItem attached upon Case creation   
    private static final String RAW_ID = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
    private static final User CREATOR = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' AND id != :userInfo.getUserId() LIMIT 1];
    private static final String RECORD_TYPE_ID = [Select Id,SobjectType,Name From RecordType WHERE Name = 'Feedback' AND SobjectType ='Case'  LIMIT 1].id;
    private static Case [] cases = new List<Case>();

    //Setup bulk data
    public static void setup(Integer num){
        for(Integer i = 0; i < num; i++){
            Case cse = new Case();
            //Case
            cse.Requestor__c = creator.Id;
            cse.Priority = 'Medium';
            cse.subject = 'TestWaitingUserResponse';
            cse.Feedback_Category__c = 'Missing Data';
            cse.status = 'Waiting User Response';
            cse.RecordTypeId = RECORD_TYPE_ID;
            cases.add(cse);
        }
    }
    //Create a Case_Messages__c for each day value in the array parameter
    public static void createCaseMessages(Integer [] days){
        Case_Messages__c [] messages = new List<Case_Messages__c>();
        for(Integer i=0;i<days.size();i++){
            messages.add(new Case_Messages__c(Name='Test'+i, Message__c=RAW_ID+days[i], Day__c=days[i]));
        }
        insert messages;
    }
    //Test that Status has effect on batch run
    @isTest public static void status(){
        setup(2); 
        cases[0].Status = 'New';
        cases[1].Status = 'Waiting User Response';
        System.runAs(creator){
            insert cases;
        }
        //Assert field is null
        System.assertEquals(null, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id =:cases[0].id].Days_Waiting_for_Response__c);
         System.assertEquals(null, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id =:cases[1].id].Days_Waiting_for_Response__c);
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        //Assert field was incremented
        System.assertEquals(null, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id =:cases[0].id].Days_Waiting_for_Response__c);
        System.assertEquals(1, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id =:cases[1].id].Days_Waiting_for_Response__c);
    }
    //Test that Days Waiting for Response is incremented from a null value
    @isTest public static void incrementDayNullValues(){
        setup(1); 
        System.runAs(creator){
            insert cases; 
        }
        //Assert field is null
        System.assertEquals(null, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id IN:cases].Days_Waiting_for_Response__c);
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        //Assert field was incremented
        System.assertEquals(1, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id IN:cases].Days_Waiting_for_Response__c);
    }
    //Test that Days Waiting for Response is incremented from a numeric value
    @isTest public static void incrementDaysNumericValue(){
        setup(1); 
        cases[0].Days_Waiting_for_Response__c = 1;
        System.runAs(creator){
            insert cases;
        }
        //Assert field is null
        System.assertEquals(1, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id IN:cases].Days_Waiting_for_Response__c);
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        //Assert field was incremented
        System.assertEquals(2, [SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id IN:cases].Days_Waiting_for_Response__c);
    }
    //Check that no message is sent when no day from the custom setting is equal to Days Waiting for Response
    @isTest public static void noHit(){
        setup(1); 
        System.runAs(creator){
            insert cases;
        }
        createCaseMessages(new Integer[]{2});
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();        
        System.assertEquals(0, found(cases[0], RAW_ID));
    }
    //Check that one message is sent when one message from the custom setting is equal to Days Waiting for Response
    @isTest public static void oneHit(){
        setup(1); 
        cases[0].Days_Waiting_for_Response__c = 1;
        System.runAs(creator){
            insert cases;
        }
        createCaseMessages(new Integer[]{2});
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        System.assertEquals(1, found(cases[0], RAW_ID));
    }
    //Check that multiple messages are present but only one one message from the custom setting is equal to Days Waiting for Response and sent
    /*@isTest public static void multipleMessagesOneHit(){
        setup(1); 
        cases[0].Days_Waiting_for_Response__c = 1;
        System.runAs(creator){
            insert cases;
        }
        createCaseMessages(new Integer[]{2,3});
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        System.assertEquals(1, found(cases[0], RAW_ID));
    }*/
    //Check that multiple messages are sent where multiple days from the custom setting are equal to Days Waiting for Response
    /*@isTest public static void multipleMessagesMultipleHits(){
        setup(1); 
        cases[0].Days_Waiting_for_Response__c = 1;
        System.runAs(creator){
            insert cases;
        }
        createCaseMessages(new Integer[]{2,2});
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        System.assertEquals(2, found(cases[0], RAW_ID));
    }*/
    //Multiple messages present in Custom Setting and multiple Cases present 
    /*@isTest public static void multipleCasesMultipleMessages(){
        setup(2);
        cases[0].Days_Waiting_for_Response__c = 1;
        cases[1].Days_Waiting_for_Response__c = 2;
        System.runAs(creator){
            insert cases;
        }
        Integer [] days = new Integer[]{2,3,3};
        createCaseMessages(days);
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        System.assertEquals(1, found(cases[0], RAW_ID+days[0]));
        System.assertEquals(2, found(cases[1], RAW_ID+days[1]));
    }*/
    //Bulk Test
   /* @isTest public static void bulkTest(){
        setup(BATCH_SIZE); 
        for(Case cse : cases){
            cse.Days_Waiting_for_Response__c =1;
        }
        System.runAs(creator){
            insert cases;
        }
        Integer [] days = new Integer[]{2};
        createCaseMessages(days);
        Test.startTest();
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch(cases);
        Database.executeBatch(waiting, BATCH_SIZE);
        Test.stopTest();
        System.debug(cases.size());
        //Test more than one case to confirm success
        System.assertEquals(1, found(cases[0], RAW_ID+days[0]));
        System.assertEquals(1, found(cases[1], RAW_ID+days[0]));
    }*/
	//Chech the number of FeedItems related to a Case
	//if the body matches the unique identifier - to confirm origin of FeedItem
    public static Integer found(Case cse, String uniqueKey){
        FeedItem [] feedItems = [SELECT Id, Body FROM FeedItem WHERE ParentId =:cse.Id];
        Integer found = 0;
        for(FeedItem feedItem: feedItems){
            if(feedItem.Body.contains(uniqueKey)){
                found++;
            }
        }
        return found; 
    }
    /*//PB Case: Reset Countdown update
    @isTest public static void variableReset(){
        setup(); 
        cse.Days_Waiting_for_Response__c = 3;
        System.runAs(creator){
            insert cse;
        }
        System.assertEquals(3,[SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id = :cse.id].Days_Waiting_for_Response__c);
        Test.startTest();
        cse.Status = 'User Response Received';
        update cse;
        Test.stopTest();
        System.assertEquals(null ,[SELECT Id, Days_Waiting_for_Response__c FROM Case WHERE Id = :cse.id].Days_Waiting_for_Response__c);
    }
    //FeedItem PB does update
    @IsTest public static void feedItemUpdate(){
        setup();
        cse.Status = 'Waiting User Response';
        //Feed Item
        FeedItem fi = new FeedItem();
        fi.body = 'Hello There!';
        System.runAs(creator){
            insert cse;
            fi.ParentId = cse.Id; 
            insert fi;
        }
        System.assertEquals('User Response Received', [SELECT Id, Status FROM Case WHERE Id =:cse.Id].Status);
    }*/
}