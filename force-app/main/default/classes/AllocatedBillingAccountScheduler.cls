/*************************************************************************************************
Name        : AllocatedBillingAccountScheduler
Description : Scheduler class for AllocatedBillingAccountCleanup 
Author      : Veena Putta
Story       : EDGE-170032
Test class	: AllocatedBillingAccountSchedulerTest
***************************************************************************************************/

public With Sharing class AllocatedBillingAccountScheduler implements Schedulable{
     public void execute(SchedulableContext SC) {      
         Database.executeBatch(new AllocatedBillingAccountCleanup(),50);     
     }
}