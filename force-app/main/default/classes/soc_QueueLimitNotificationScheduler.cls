/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 1-APR-2019
@ModifiedByandDate: <Please mention All modifications here>
@Description: Scheduler class for soc_QueueLimitNotification
@References
Epic :EDGE-53259 ::SF&D Reporting & Additional Enhancements
Story:EDGE-53126:As a SFD Manager, I need to be alerted by email & chatter if any of the SFD queues have 10 or more requests open

*******************************************************************************/



global class soc_QueueLimitNotificationScheduler implements Schedulable{
    
    global void execute(SchedulableContext SC) {
            
            soc_QueueLimitNotification.triggerQueueLimitNotification();
        }

}