/*****************************************************************************
@Author: Preeti Malik
@CreateDate: 3-APR-2019
@ModifiedByandDate: <Please mention All modifications here>
@Description: This Test class contains Test methods for soc_QueueLimitNotification class. 
@References
Epic :EDGE-53259 ::SF&D Reporting & Additional Enhancements
Story:EDGE-53126:As a SFD Manager, I need to be alerted by email & chatter if any of the SFD queues have 10 or more requests open

*******************************************************************************/
@isTest(seeAllData=False)
public class soc_QueueLimitNotificationTest {
    
    /**
      * This method tests the positive senario by inserting the desired number of cases for triggering the alert process.
      * @Author: Preeti Malik
      * @Date: 3-APR-2019
      */
    @isTest static void triggerQueueLimitNotification_testPositive() {
        DataSetup(12);
        test.startTest();        
        soc_QueueLimitNotification.triggerQueueLimitNotification();
        List < group > groupsExceedingLimit = soc_QueueLimitNotification.findQueuesExceedinglimit();
        test.stopTest();
        system.assert(groupsExceedingLimit.size()>0);
    }
    
    
    /**
      * This method tests the negative senario by inserting less cases then desired so that the alert process doesn't trigger.
      * @Author: Preeti Malik
      * @Date: 3-APR-2019
      */
    @isTest static void triggerQueueLimitNotification_testNegative() {
        DataSetup(10);
        test.startTest();        
        soc_QueueLimitNotification.triggerQueueLimitNotification();
        List < group > groupsExceedingLimit = soc_QueueLimitNotification.findQueuesExceedinglimit();
        test.stopTest();
        system.assert(groupsExceedingLimit.size()==0);
    }
    
    
    /**
      * This method tests the bulky senario by inserting large number of cases for triggering the alert process.
      * @Author: Preeti Malik
      * @Date: 3-APR-2019
      */
    @isTest static void triggerQueueLimitNotification_testBulky() {
        DataSetup(20);
        //soc_QueueLimitNotification.triggerQueueLimitNotification();
        test.startTest();
        List < group > groupsExceedingLimit = soc_QueueLimitNotification.findQueuesExceedinglimit();
        test.stopTest();
        system.assert(groupsExceedingLimit.size()>0);
    }
    
    
    /**
      * This method is used to create the cases as required in the test methods.
      * @Author: Preeti Malik
      * @Date: 3-APR-2019
      */
    public static void DataSetup(Integer NumberOfCases) {
        List<Case> CasesInQueues = new List<Case>();
        Group Detailer = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'soc_SFD_Concierge_Offshore' LIMIT 1];
        for(Integer i=1;i<NumberOfCases;i++){
            Case CaseInQueue = new Case();
            CaseInQueue.Subject = 'Pending Case : '+ i;
            CaseInQueue.OwnerId = Detailer.Id;
            CaseInQueue.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
            CasesInQueues.add(CaseInQueue);
        }
        insert CasesInQueues;
    }
    

}