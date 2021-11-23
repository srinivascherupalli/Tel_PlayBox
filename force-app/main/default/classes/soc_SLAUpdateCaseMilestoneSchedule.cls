/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 09/04/2018
@ModifiedByandDate:  
@Description: This scheduable class will schedule batch class 
*******************************************************************************/
global class soc_SLAUpdateCaseMilestoneSchedule implements Schedulable{  

    /*
    * Method Name: execute
    * Input Parameter:  SchedulableContext sc
    * Output Parameter: void
    * Description: For scheduling batch class. 
    * Created By:   Sandeep Soni
    * Create Date:  09 April 2019
    */
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        soc_SLAUpdateCaseMilestoneBatch b = new soc_SLAUpdateCaseMilestoneBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
}