/*****************************************************************
@Name: APTPS_TaskTriggerHandler
@Author: Ruchika Patil 
@CreateDate: 19/4/2016
@Description: This is the handler class for trigger APTPS_TaskTrigger to deny deletion of Activity history task and update associated Obligation with closest due date from the related tasks.
@UsedBy: Task 
******************************************************************/ 
public class APTPS_TaskTriggerHandler {
    public static final String deleteError = 'You do not have permission to delete this record';
    public static final String ObligationObjectName = 'Apttus_SRM__SRMObligation__c';
    public static final String AgreementObjectName = 'Apttus__APTS_Agreement__c';
    public static boolean isDeleted = true;
    public static final String Risk_IssueObjectName = 'Apttus_SRM__Issue__c';
    /******************************************************************
    @Description:This method prevents deletion of Activity History Tasks associated to Agreement record for any profile other than System Administrator.
    *******************************************************************/ 
    public void preventTaskDelete(Map<id,Task> taskMap){
        List<Task> taskList = taskMap.values();
        String profileID = UserInfo.getProfileId();  
        Profile profileRec = [SELECT id FROM Profile WHERE name = :APTPS_Constants.SYSTEM_ADMINISTRATOR LIMIT 1];
        if (profileRec != null){
            taskList = [SELECT Id, Whatid, Status, What.Type FROM Task WHERE id IN:taskList and What.Type = :AgreementObjectName];
            for (Task taskRec : taskList){            
                if (profileID != profileRec.id && taskRec.Status == APTPS_Constants.COMPLETED_STATUS){
                    Task actualRecord = taskMap.get(taskRec.Id);
                    actualRecord.addError(deleteError);
                } 
            }
        }
    }
    /******************************************************************
    @Description:This method is called after insert and update to Update the Obligation due date with the closest associated task due date.
    *******************************************************************/ 
    public void populateObligationDueDate(List<Task> taskListPassed, Map<id,Task> MapOldTask){  //EDGE-69042 Sonar Fix 
        Map<ID, Apttus_SRM__SRMObligation__c> ObligationMap = new Map<ID, Apttus_SRM__SRMObligation__c>();
        List<Id> listIDs = new List<Id>();
        Map<id, Apttus_SRM__SRMObligation__c> updatedObligationsMap = new Map<id, Apttus_SRM__SRMObligation__c>();
        Apttus_SRM__SRMObligation__c associatedOb = new Apttus_SRM__SRMObligation__c();
        List<Task> completedTasks = new List<Task>();
        List<Task> updatedTasks = new List<Task>();
        //filtering tasks related to Obligation only.
        //EDGE-69042 Sonar Fix 
        List<Task> taskList = [SELECT Id, Whatid, Status, What.Type, ActivityDate FROM Task WHERE id in:taskListPassed and What.Type = :ObligationObjectName];
        for(Task taskRec : taskList ) {
             //on update of the existing task records.             
            if(MapOldTask != null && MapOldTask.size()>0 && MapOldTask.Get(taskRec.Id) != null){
                //tasks whose status changed to Completed.
                if(taskRec.Status == APTPS_Constants.COMPLETED_STATUS && MapOldTask.Get(taskRec.Id).Status != APTPS_Constants.COMPLETED_STATUS && MapOldTask.Get(taskRec.Id).Status != null){ 
                    
                    completedTasks.add(taskRec);      
                }           
                //tasks whose Due date has been changed
                else if(((taskRec.ActivityDate==null && MapOldTask.Get(taskRec.Id).ActivityDate != null) || (MapOldTask.Get(taskRec.Id).ActivityDate == null && taskRec.ActivityDate!=null)|| (MapOldTask.Get(taskRec.Id).ActivityDate != null && taskRec.ActivityDate != null && taskRec.ActivityDate != MapOldTask.Get(taskRec.Id).ActivityDate)) && taskRec.Status != APTPS_Constants.COMPLETED_STATUS){ 
                   
                    updatedTasks.add(taskRec);      
                } 
            }  
            //on insert of new Task records.
            else if((MapOldTask == null || MapOldTask.size()==0 || MapOldTask.isEmpty() || ((!MapOldTask.isEmpty() || MapOldTask != null) && MapOldTask.Get(taskRec.Id) == null)) && taskRec.Status != APTPS_Constants.COMPLETED_STATUS ){ 
                listIDs.add(taskRec.WhatId);   
            }         
        }
        //completed tasks
        if(!completedTasks.isEmpty()){
            isDeleted = false;
            recheckObligationDueDate(completedTasks);
        }
        //updated tasks
        if(!updatedTasks.isEmpty()){
            isDeleted = false;
            recheckObligationDueDate(updatedTasks);
        }
        //all newly inserted tasks
        if(!listIDs.isEmpty() && listIDs.size()>0){
            //will fetch all the associated parent Obligations of the tasks.
            ObligationMap = new Map<Id, Apttus_SRM__SRMObligation__c>([SELECT id, APTPS_Due_Date__c FROM Apttus_SRM__SRMObligation__c 
                                                                            WHERE ID IN :listIDs]);      
        } 
        if(!ObligationMap.isEmpty()){
            for (Task taskRec: taskList ){
                associatedOb = ObligationMap.get(taskRec.WhatId);
                If(associatedOb != null){
                    //if new task due date is less than current obligation due date or if obligation due date is blank.
                    if((taskRec.ActivityDate != null && associatedOb.APTPS_Due_Date__c != null && associatedOb.APTPS_Due_Date__c > taskRec.ActivityDate) 
                            || associatedOb.APTPS_Due_Date__c == null){
                        associatedOb.APTPS_Due_Date__c = taskRec.ActivityDate;
                    }
                    updatedObligationsMap.put(associatedOb.id, associatedOb);
                }
            }
            //calls method from helper class to perform update dml.
            system.debug('@@obligationList'+updatedObligationsMap.values());
            APTPS_TaskTriggerHelper.updateObligationDueDate(updatedObligationsMap.values());
        }
    }
    /******************************************************************
    @Description:This method is called before delete, updated & completed tasks to Update the Obligation due date with the closest associated task due date.
    *******************************************************************/ 
    public void recheckObligationDueDate(List<Task> taskListPassed){  //EDGE-69042 Sonar Fix 
        Map<Id, Apttus_SRM__SRMObligation__c> ObligationMap = new Map<Id, Apttus_SRM__SRMObligation__c>();
        List<Id> listIDs = new List<Id>();
        Map<id, Apttus_SRM__SRMObligation__c> updatedObligationsMap = new Map<id, Apttus_SRM__SRMObligation__c>();
        Apttus_SRM__SRMObligation__c associatedOb = new Apttus_SRM__SRMObligation__c();
        Date closestDueDate; 
        //filtering tasks related to Obligation only.
        //EDGE-69042 Sonar Fix 
        List<Task> taskList = [SELECT Id, Whatid, Status, What.Type, ActivityDate FROM Task WHERE id in:taskListPassed and What.Type = :ObligationObjectName];
        for(Task taskRec : taskList) {
            listIDs.add(taskRec.WhatId);   
        }
        if(!listIDs.isEmpty() && listIDs.size()>0){
            //will fetch all the associated parent Obligations of the tasks along with all sibling tasks.
            ObligationMap = new Map<Id, Apttus_SRM__SRMObligation__c>([SELECT id, APTPS_Due_Date__c,(SELECT id, status, ActivityDate 
                                                                        FROM Tasks WHERE status != :APTPS_Constants.COMPLETED_STATUS AND ActivityDate != null) 
                                                                        FROM Apttus_SRM__SRMObligation__c WHERE Id IN :listIDs]);            
        }
        
        if(!ObligationMap.isEmpty()){
            for (Task taskRec: taskList ){
                associatedOb = ObligationMap.get(taskRec.WhatId); 
                closestDueDate = null; 
               
                //if the task does not have any sibling tasks associated to the parent obligation and is getting deleted or completed.
                if(((associatedOb.Tasks.size()==1 && associatedOb.Tasks[0].id == taskRec.id) || associatedOb.Tasks.size()==0) && (taskRec.status == APTPS_Constants.COMPLETED_STATUS || isDeleted == true)){ 
                    closestDueDate = null;
                    associatedOb.APTPS_Due_Date__c = closestDueDate; 
                    updatedObligationsMap.put(associatedOb.id, associatedOb);
                }
                //if the task has sibling tasks               
                else{                    
                    for(Task associatedTask : associatedOb.Tasks){
                        //will get the next closest due date of the deleted/completed tasks if the it's due date is the current obligation due date. 
                        if(taskRec.ActivityDate == associatedOb.APTPS_Due_Date__c && associatedTask.id != taskRec.id && associatedTask.status != APTPS_Constants.COMPLETED_STATUS && associatedTask.ActivityDate != null  && (closestDueDate == null || associatedTask.ActivityDate < closestDueDate)){
                            closestDueDate = associatedTask.ActivityDate;
                          
                        }
                        //will recheck the closest due date if the due date of the previous closest due date is changed to another date.
                        else if(taskRec.ActivityDate != associatedOb.APTPS_Due_Date__c  && associatedTask.status != APTPS_Constants.COMPLETED_STATUS   && associatedTask.ActivityDate != null && (closestDueDate == null || associatedTask.ActivityDate < closestDueDate)){
                            closestDueDate = associatedTask.ActivityDate;
                           
                        }                  
                    }
                    associatedOb.APTPS_Due_Date__c = closestDueDate;
                    updatedObligationsMap.put(associatedOb.id, associatedOb); 
                }
            }
            //calls the helper class to update all the changed obligation due date.
            APTPS_TaskTriggerHelper.updateObligationDueDate(updatedObligationsMap.values());
        }
    }
    /******************************************************************
    @Description:This method is called before insert of Import Offline Document Activity History record which updates the 
                    Status category/Status to In Authoring / Author Contract.
    *******************************************************************/ 
    public void statusChangeOnImportOffline(List<Task> taskList){
        Set<Id> parentIdSet = new Set<Id>(); 
        for (Task taskRec : taskList){          
            if(taskRec.Subject == 'Imported Offline Document'){ //&& taskRec.status == 'Completed'
                parentIdSet.add(taskRec.WhatId);
            }
        }
        List<Apttus__APTS_Agreement__c> agmtList = [SELECT Apttus__Status_Category__c,Apttus__Status__c,Id FROM Apttus__APTS_Agreement__c WHERE Id IN : parentIdSet];
        List<Apttus__APTS_Agreement__c> updatedAgmtList = new List<Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agmt : agmtList){
            agmt.Apttus__Status_Category__c = 'In Authoring';
            agmt.Apttus__Status__c = 'Author Contract';
            updatedAgmtList.add(agmt);
        }
        APTPS_TaskTriggerHelper.updateAgreementStatus(updatedAgmtList);
    }
    
    public void updateObligationAndRisk(List<Task> taskList, Map<id,Task> MapNewTask)
    {
        System.debug('Shishir inside updateObligationAndRisk: ' + taskList);
        Set<Id> taskIds = new Set<Id>();
        List<Task> tskList;

        for(Task tsk : taskList)
        {
            System.debug('Shishir inside forloop tsk: ' + tsk);
            if(tsk.APTS_Obligation__c == null && tsk.APTS_Risk__c == null)
            {
                taskIds.add(tsk.Id);
            }
        }
        
        tskList = [SELECT Id, Whatid, Status, What.Type, ActivityDate,APTS_Obligation__c, APTS_Risk__c FROM Task WHERE id in:taskIds and What.Type = :ObligationObjectName];
        
        if(tskList != null)
        {
            for(Task ts : tskList){
                MapNewTask.get(ts.Id).APTS_Obligation__c = ts.Whatid;
            }
        }
        
        System.debug('ShishirtskList taskIds: ' + taskIds);
        tskList = [SELECT Id, Whatid, Status, What.Type, ActivityDate,APTS_Obligation__c, APTS_Risk__c FROM Task WHERE id in:taskIds and What.Type = :Risk_IssueObjectName];
        System.debug('ShishirtskList risk: ' + tskList);
        if(tskList != null)
        {
            for(Task ts : tskList){
                MapNewTask.get(ts.Id).APTS_Risk__c = ts.Whatid;
            }
        }
    }
}