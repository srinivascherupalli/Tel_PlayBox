/*------------------------------------------------------------------------ 
Author: Ivan Aerlic 
Company: Telstra 
Description: A test class created to validate the FeedCommentTriggerHelper class
Tests executed: 
1 - feedCommmentUpdate() 
Test if Case does update
2 - feedCommmentBadUser()
Test if Case doesn't update due to bad User id
3- feedCommmentBadStatus()
Test if Case doesn't update due to bad Status
4 - feedCommmentWithoutCase()
Test what happens when the ParentId of a FeedComment doesn't belong to a Case
5 - bulkTest()
200 comment records
History:
Created by Ivan Aerlic on 24-05-19 .
----------------------------------------------------------------------------*/
@IsTest
public class TestFeedCommentHelperAndTrigger {
    private static FeedComment [] feedComments = new List<FeedComment>();
    private static FeedComment fc= new FeedComment();
    private static Case cs= new Case();
    private static FeedItem fi = new FeedItem();
   //Setup test data
    public static void setup(){  
        //Case
        cs.Priority = 'Medium';
        cs.subject = 'Hello There!';
        cs.Feedback_Related_To__c = 'Account';
        cs.Feedback_Category__c = 'Missing Data';
        cs.RecordTypeId =[Select Id,SobjectType,Name From RecordType WHERE Name ='Feedback' and SobjectType ='Case'  limit 1].Id;
        insert cs;
        //Feed Item
        fi = new FeedItem();
        fi.body = 'Hello There!';
        fi.ParentId = cs.Id; 
        insert fi;
        //Feed Comments
        feedComments = new List<FeedComment>();
        for(Integer i = 0; i < 200; i++){
            fc = new FeedComment();
            fc.CommentBody = 'Hello There!';
            fc.FeedItemId = fi.id;
            feedComments.add(fc);
        }
    }
    //Setup bulk test data
    public static void bulkSetup(){  
        //Case
        cs.Priority = 'Medium';
        cs.subject = 'Hello There!';
        cs.Feedback_Related_To__c = 'Account';
        cs.Feedback_Category__c = 'Missing Data';
        cs.RecordTypeId =[Select Id,SobjectType,Name From RecordType WHERE Name ='Feedback' and SobjectType ='Case'  limit 1].Id;
        insert cs;
        //Feed Item
        fi = new FeedItem();
        fi.body = 'Hello There!';
        fi.ParentId = cs.Id; 
        insert fi;
        //Feed Comment
        fc.CommentBody = 'Hello There!';
        fc.FeedItemId = fi.id;
    }
    //Test if Case does update
    @IsTest public static void feedCommmentUpdate(){
        setup();
        cs.Status = 'Waiting User Response';
        update cs;
        insert fc;
        System.assert(![SELECT id, status FROM Case WHERE Status = 'User Response Received'].isEmpty());
    }
    //Test if Case doesn't update due to bad User id
    @IsTest public static void feedCommmentBadUser(){
        setup();
        cs.Status = 'Waiting User Response';
        update cs;
        User user = [SELECT Id FROM User WHERE id != :UserInfo.getUserId() AND IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(user){
            insert fc;
        }
        System.assert([SELECT id, status FROM Case WHERE Status = 'User Response Received'].isEmpty());
    }
    //Test if Case doesn't update due to bad Status
    @IsTest public static void feedCommmentBadStatus(){
        setup();
        cs.Status = 'Waiting Internal Response';
        update cs;
        insert fc;
        System.assert([SELECT id, status FROM Case WHERE Status = 'User Response Received'].isEmpty());
    }
    //Test what happens when the ParentId doesn't belong to a Case
    @IsTest public static void feedCommmentWithoutCase(){
        setup();
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        //Create new Feed Item, to set ParentId
        fi = new FeedItem();
        fi.body = 'Hello There!';
        fi.ParentId = acc.Id;
        insert fi;
        try{
            Test.startTest();
            insert fc; 
            Test.stopTest();
            System.assert(true);
        }catch(Exception ex){
            System.assert(false);
        }
    }
    //Bulk Test with 200 FeedComments
    @IsTest public static void bulkTest(){
        setup();
        cs.Status = 'Waiting User Response';
        update cs;
        insert feedComments;
        System.assert(![SELECT id, status FROM Case WHERE Status = 'User Response Received'].isEmpty());
    }
}