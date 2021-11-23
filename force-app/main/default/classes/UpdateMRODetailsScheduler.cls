/********************************************************
Class Name : UpdateMRODetailsScheduler
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             Prajakta              12/11/2020          EDGE-179345

**********************************************************
*/

global class UpdateMRODetailsScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
      UpdateMRODetailsSchedulable b = new UpdateMRODetailsSchedulable(); 
      database.executebatch(b);
   }
    
    

}