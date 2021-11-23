/****************************************************************************
@Name: SFOTaskTriggerHandler
@Author: SFO/Vamshi
@CreateDate: 07/04/2020
@Sprint : 20.05[P2OB-5475]
@Description: This Class is for TaskTrigger Trigger - P2OB-5475, to get the test coverage 
using the class SFOTaskTriggerHandlerTest
Note : Implemented Trigger FrameWork
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               			as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
                        01/11/2021 21.15 by pallavi B,Team SFO as part of DIGI-34437
*****************************************************************************/
public without sharing class SFOTaskTriggerHandler extends ATF_AbstractDomainHandler {
    private Map<Id,Task> newTaskMap;
    private Map<Id,Task> oldTaskMap;
    /****************************************************************************
    @Method Name: handleAfterInsert
    @Author: SFO/Vamshi
    @Sprint : 20.05[P2OB-5475]
    @CreateDate: 07/04/2020
    @Description: This Method is triggered before insert to update Standard Name field on Task with 
    custom activity field called "Contact__c"
    ******************************************************************************/      
    public override void handlebeforeInsert(){
        try{ 
            List<Task> tasklist = trigger.new;
            for(Task taskRecord: tasklist){
                 if(taskRecord.whatId != null && String.valueOf(taskRecord.whatId).startsWith('001') && taskRecord.contact__c != null){
                     taskRecord.whoid = taskRecord.contact__c;
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOTaskTriggerHandler Class:::: handleBeforeInsert Method'+ Ex.getMessage());            
        }
    }
    
    /****************************************************************************
    @Method Name: handleAfterInsert
    @Author: SFO/Pallavi
    @Sprint : 21.15[DIGI-34437]
    @CreateDate: 28/10/2021
    @Description: This Method is triggered After insert of tasks and helper class is SFOTaskTriggerHelper
    ******************************************************************************/      
    public override void handleAfterInsert(){
         this.newTaskMap = (Map<Id,Task>) Trigger.newMap;
         SFOTaskTriggerHelper.checkFirstBillSubCheck(this.newTaskMap.values());
    }
    
     /****************************************************************************
    @Method Name: handleAfterUpdate
    @Author: SFO/Pallavi
    @Sprint : 21.15[DIGI-34437]
    @CreateDate: 28/10/2021
    @Description: This Method is triggered after update of tasks and helper class is SFOTaskTriggerHelper
    ******************************************************************************/      
    public override void handleAfterUpdate(Map<Id,Sobject> existingRecords){
           this.newTaskMap = (Map<Id,Task>) Trigger.newMap;
		   this.oldTaskMap = (Map<Id,Task>) Trigger.oldMap;
           SFOTaskTriggerHelper.UpdateFirstBillSubCheck(this.oldTaskMap,this.newTaskMap);
    }  
    /****************************************************************************
    @Method Name: handleAfterDelete
    @Author: SFO/Pallavi
    @Sprint : 21.15[DIGI-34437]
    @CreateDate: 28/10/2021
    @Description: This Method is triggered After Delete of tasks and helper class is SFOTaskTriggerHelper
    ******************************************************************************/      
    public override void handleAfterDelete(){
		   this.oldTaskMap = (Map<Id,Task>) Trigger.oldMap;
           SFOTaskTriggerHelper.checkFirstBillSubCheck(this.oldTaskMap.values());    
    }  
    /****************************************************************************
    @Method Name: handleAfterUndelete
    @Author: SFO/Pallavi
    @Sprint : 21.15[DIGI-34437]
    @CreateDate: 28/10/2021
    @Description: This Method is triggered after Undelete tasks and helper class is SFOTaskTriggerHelper
    ******************************************************************************/      
    public override void handleAfterUndelete(){
           this.newTaskMap = (Map<Id,Task>) Trigger.newMap;
           SFOTaskTriggerHelper.checkFirstBillSubCheck(this.newTaskMap.values());    
    }
}