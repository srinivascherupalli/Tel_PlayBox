/********************************************************
Class Name : MonitorNotifProcBatchSchedular
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             vaibhav              15/02/2021          EDGE-201432

**********************************************************/
global class MonitorNotifProcBatchSchedular implements Schedulable{
    
    global void execute(SchedulableContext sc) {

        Integer Batchsize = Integer.valueof(label.Batchsizemonitornotif);
      MonitorNotificationProcessingBatch b = new MonitorNotificationProcessingBatch(); 
      database.executebatch(b,Batchsize);

   }
    
    


}