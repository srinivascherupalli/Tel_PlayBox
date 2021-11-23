/**
  * Author: Sandeep Soni
  * Team: Jaipur
  * Sprint: 20.06  
  * JIRA Story: P2OB-6036
  * Date: 22 April 2020
  * Class Name: cusdl_AddOppTeamMemBatchSchedule
  * Description: This Schedular class will call to cusdl_AddOppTeamMemBatch class.
  **/
global without sharing class cusdl_AddOppTeamMemBatchSchedule implements Schedulable {
    /*For call to batch class*/
   global void execute(SchedulableContext sc) {       
      cusdl_AddOppTeamMemBatch addOppTeamBach = new cusdl_AddOppTeamMemBatch(); 
       /*Executing Batch class*/
      database.executebatch(addOppTeamBach);
   }
}