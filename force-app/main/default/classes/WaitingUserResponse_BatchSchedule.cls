/*------------------------------------------------------------ 
Created By: Ivan Aerlic 
US: EDGE-80291, P2OB-3621
------------------------------------------------------------*/
public Without Sharing class WaitingUserResponse_BatchSchedule implements Schedulable {
    public static final Integer BATCH_SIZE = 50; 
    public void execute(SchedulableContext sc){ 
        WaitingUserResponse_Batch waiting = new WaitingUserResponse_Batch([SELECT Id, Status, CreatedBy.FirstName, CreatedDate, RecordTypeId, Days_Waiting_for_Response__c FROM Case 
                      WHERE Status = 'Waiting User Response' AND RecordTypeId IN (SELECT id FROM RecordType WHERE Name ='Feedback' OR Name ='Access Issue')]);
        Database.executeBatch(waiting, BATCH_SIZE);
    }
}