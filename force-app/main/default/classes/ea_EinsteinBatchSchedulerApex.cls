/**
  * Author : Shreyansh Sharma(Jaipur)
  * Date : 5/24/2021
  * Description: P2OB-14430, Schedular class for Einstein Batch
  **/
global with sharing class ea_EinsteinBatchSchedulerApex implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        ea_EinsteinDataBatch bCon = new ea_EinsteinDataBatch();
        Database.ExecuteBatch(bCon,1);
    } 
    
   
 
  


}