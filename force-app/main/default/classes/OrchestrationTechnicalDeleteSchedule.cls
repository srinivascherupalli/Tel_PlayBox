/*
@ DEVELOPER : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : This class Delete the 30 days old Orchestration records and site created records 
@ DIGI-10971
*/

//DIGI-28081 -Removed the logic and created a helper for Deletion
global with sharing class  OrchestrationTechnicalDeleteSchedule implements Schedulable {    
    global void execute(SchedulableContext sc){
        orchestrationRecordDeleteHelper.deleteOrchestrationTechnicals();      
    }    
}