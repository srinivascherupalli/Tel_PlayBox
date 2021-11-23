/****************************************************************************
@Name: SFOTaskTriggerHelper
@Author: SFO/Pallavi B
@CreateDate: 01/11/2021
@Sprint : 21.15 DIGI-34437
@Test Class: SFOTriggerHandlerTest
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               			as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
                        0/11/2021 21.15 by pallavi B,Team SFO as part of DIGI-34437
*****************************************************************************/
public without sharing class SFOTaskTriggerHelper {
    //Migration Lead Record Type.Added as part of DIGI-34437 S21.15
    public static Id leadMigrationRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Migration).getRecordTypeId();
    public static Map<Id,Task> oldTkMap= new Map<Id,Task>(); //Captures old task values to use in ischanged() method
    /****************************************************************************
    @Method Name: checkFirstBillSubCheck
    @Author: SFO/Pallavi B
    @Sprint : 21.15 DIGI-34437
    @CreateDate: 01/11/2021 
    @Description: This Method is triggered After insert/Delete/Undelete to update FirstBillTaskOnLead__c on Lead when there is a task created/Updated/deleted/undeleted with subject/status 
    ******************************************************************************/    
    
    public static void checkFirstBillSubCheck(List<Task> lstTasks){
        try{ 
			Map<Id,Task> mapOfExistingTasks = new Map<Id,Task>();
            List<Id> taskList = new List<Id>();
            List<Id> leadList = new List<Id>();
            List<Lead> lstLeadsToUpdate = new List<Lead>();
            
            //Iterates over  new Task and captures tasks whose status is completed and subject contains first bill
            for(Task taskRecord: lstTasks){
                if(taskRecord.whoId != null && String.valueOf(taskRecord.whoId).startsWith('00Q') && taskRecord.Status == System.Label.Task_Status_Completed && taskRecord.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill)){
                    leadList.add(taskRecord.whoId); //Captures task related Lead Id
                    taskList.add(taskRecord.Id);  //Captures Task Id
                }
            }
            
            if(leadList.isEmpty()){
                      return; //if there is no leads available for the given tasks no need to run anything else
            }
            
            //Iterated over tasks that are available on Lead
            for(Task t : [select id,whoId,Subject,Status from Task where whoId =:leadList]){
                 if(t.Status == System.Label.Task_Status_Completed && (t.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill)) && !taskList.contains(t.id)){
                     //Captures existing tasks that are with subject completed and subject contains first bill on the lead.
                     //If this map is null means there are no existing tasks on the lead with the critieria
                     mapOfExistingTasks.put(t.whoId,t);
                 }
                 
             }
                //Iterated over lead to update FirstBillTaskOnLead__c field
                for(Lead objLead: [select id,RecordTypeId,FirstBillTaskOnLead__c from Lead where Id =:leadList and RecordTypeId =:leadMigrationRecordType ]){
                   if(mapOfExistingTasks.get(objLead.id)==null){ //this means that there are no existing tasks with status completed and subject first bill
                         if(TRIGGER.isInsert || TRIGGER.isUndelete){
                             objLead.FirstBillTaskOnLead__c = true;
                          }
                         else if(TRIGGER.isDelete){
                             objLead.FirstBillTaskOnLead__c = false;
                          }
                        lstLeadsToUpdate.add(objLead);  
                      }
			 }
            
            //Updates FirstBillTaskOnLead__c on task when there are no exisiting tasks with status completed and subject first bill respectively
            // depending on the triggering event like inset/delete/undelete of task
            if(!lstLeadsToUpdate.isEmpty()){
                Update lstLeadsToUpdate;
            }
			
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOTaskTriggerHelper Class:::: checkFirstBillSubCheck Method'+ Ex.getMessage());            
        }
    }

      
    /****************************************************************************
    @Method Name: UpdateFirstBillSubCheck
    @Author: SFO/Pallavi B
    @Sprint : 21.15 DIGI-34437
    @CreateDate: 01/11/2021 
    @Description: This Method is triggered After Update. to update FirstBillTaskOnLead__c on Lead 
    ******************************************************************************/  
    public static void UpdateFirstBillSubCheck(Map<Id,Task> oldTaskMap , Map<Id,Task> newTaskMap){
        oldTkMap = oldTaskMap;
        try{
			List<Id> lstWhoIdfirstbillcheckTrue = new List<Id>();//Captures id of lead when the respective task status changed to completed and subject is in first bill 
            List<Id> lstWhoIdfirstbillcheckfalse = new List<Id>();//Captures id of lead when the respective task status changed from completed and subject changed from first bill 
            List<Id> currentTasks = new List<Id>();
            Map<Id,Task> mapofExistingTask = new Map<Id,Task>(); //stores tasks that are completed and contains firs bill in subject and that record shuld not be the changed task record
            List<Lead> lstLeadsToUpdate = new List<Lead>();
            
            //Iterates over updated Task  whose status/status is changed
            for(Task taskRecord: newTaskMap.values()){
                if(taskRecord.whoId != null && String.valueOf(taskRecord.whoId).startsWith('00Q')){ //Checks whether task is associated with lead or not
                    if(!(isChanged('Status',taskRecord) || isChanged('Subject',taskRecord))){ //if subject/status are not changed then it stops here itself
                       continue;
                     } 
                    //Sceanario:1 -- When Subject is changed from Some value to First Bill, at this time Status is constant and is completed only
                    if(taskRecord.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill) && !(oldTaskMap.get(taskRecord.Id).Subject.containsIgnoreCase(Label.TaskSubjectFirstBill)) && taskRecord.Status == System.Label.Task_Status_Completed){
                        lstWhoIdfirstbillcheckTrue.add(taskRecord.whoId);  
                    }
                    //Sceanario:2 -- When Subject is changed from First Bill to Some value, at this time Status is constant and is completed only
                    if(!(taskRecord.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill)) && oldTaskMap.get(taskRecord.Id).Subject.containsIgnoreCase(Label.TaskSubjectFirstBill) && taskRecord.Status == System.Label.Task_Status_Completed){
                        lstWhoIdfirstbillcheckfalse.add(taskRecord.whoId);
                    }
                    //Sceanario:3 -- When Status is changed from Some value to completed, at this time Subject is first bill only
                    if(taskRecord.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill) && oldTaskMap.get(taskRecord.Id).Status != System.Label.Task_Status_Completed && taskRecord.Status == System.Label.Task_Status_Completed){
                        lstWhoIdfirstbillcheckTrue.add(taskRecord.whoId);
                    }
                    //Sceanario:4 -- When Subject is changed from completed to Some value, at this time subject is first bill only
                    if(taskRecord.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill) && oldTaskMap.get(taskRecord.Id).Status == System.Label.Task_Status_Completed && taskRecord.Status != System.Label.Task_Status_Completed){
                        lstWhoIdfirstbillcheckfalse.add(taskRecord.whoId);
                    }
                    currentTasks.add(taskRecord.id);//Captures current task id
                }
            }
            
            //Iterated over all Tasks that got from above leads matching criteria
              if(!lstWhoIdfirstbillcheckfalse.isEmpty() || !lstWhoIdfirstbillcheckTrue.isEmpty()){
                     for(Task t : [select id,whoId,Subject,Status from Task where  (WhoId =:lstWhoIdfirstbillcheckfalse OR WhoId =:lstWhoIdfirstbillcheckTrue)]){ //will get all the tasks in the respective lead 
                        //mapofExistingTaskstores values for tasks  matches with subject as first bill and status as completed on that particular lead already  and it should not be current record
                         if(t.Status == System.Label.Task_Status_Completed && (t.Subject.containsIgnoreCase(Label.TaskSubjectFirstBill)) && !currentTasks.contains(t.Id)){
                           mapofExistingTask.put(t.WhoId,t); 
                        } 
                    }
              }
            
            if(!lstWhoIdfirstbillcheckfalse.isEmpty() || !lstWhoIdfirstbillcheckTrue.isEmpty()){
                for(Lead l : [select id,RecordTypeId,FirstBillTaskOnLead__c from Lead where RecordTypeId =:leadMigrationRecordType AND (Id =:lstWhoIdfirstbillcheckfalse OR Id =:lstWhoIdfirstbillcheckTrue)]){
                    //if this map is null that means that there are existing tasks with subject as first bill and status as completed.
                    //so it will enter the if and update lead record with matched critieria
                    if(mapofExistingTask.get(l.id)==null){ 
                        if(lstWhoIdfirstbillcheckTrue.contains(l.id)){
                            l.FirstBillTaskOnLead__c=True;
                        } else if(lstWhoIdfirstbillcheckFalse.contains(l.id)){
                            l.FirstBillTaskOnLead__c=false;
                        }
                        lstLeadsToUpdate.add(l);
                    }
                }
            }
             //Updates FirstBillTaskOnLead__c on task when there are no exisiting tasks with status completed and subject first bill respectively
            // depending on the triggering event update
            if(!lstLeadsToUpdate.isEmpty()){
                Update lstLeadsToUpdate;
            }           
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOTaskTriggerHelper Class:::: checkFirstBillSubCheck Method'+ Ex.getMessage());            
        }
    } 
    
 /****************************************************************************
    @Method Name: isChanged
    @Author: SFO/Pallavi B
    @Sprint : 21.15 DIGI-34437
    @CreateDate: 01/11/2021 
    @Description: This Method is triggered to check the ischanged of fields
    ******************************************************************************/    
        public static boolean isChanged(String fieldApiName, Task tk){
        return tk?.get(fieldApiName) != oldTkMap.get(tk.Id)?.get(fieldApiName);
    }

}