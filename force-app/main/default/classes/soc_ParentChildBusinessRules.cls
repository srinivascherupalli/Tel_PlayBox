/*****************************************************************************
@Author: Pravin Sonawane
@CreateDate: 9-Jan-2019
@ModifiedByandDate: 
@Description: This class contains different-different business rules for Parent,child cases and Case Line Items. 
@References
Epic :EDGE-40183 P2O: Sales Order Parent Child Division of SFD Cases
Story:EDGE-57512 Stages & Status as part of SFD Parent & Child Cases

*******************************************************************************/
public without sharing class soc_ParentChildBusinessRules {
    
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    
    /**
      * If any child case is not close and user tries to close parent case then show an error message.
      * Sandeep Soni :: EDGE-57850 :: 16-JAN-2019
      */ 
    public  static Map<String,List<Case>> prepareSFDProductParentChildMapByParentId(Set<String> parentIds){  
        //System.debug('<<<<<<<<SOQL Count 1>>>>>>>>>>' + Limits.getQueries());
            List<Case> lstSFDProductChild = [select id,status,soc_Parent_SFD_Reference__c,stage__c,soc_SFD_Product_Status__c,parentId from Case where RecordTypeId = :recId_SFD_ProductType AND 
                                             parentId in :parentIds];
            Map<String,List<Case>> mapSFDParentChildList = new Map<String,List<Case>>();
            for(Case c : lstSFDProductChild){
                if(mapSFDParentChildList.containsKey(c.parentId)){
                    List<Case> lstCase = mapSFDParentChildList.get(c.parentId);
                    lstCase.add(c);
                    mapSFDParentChildList.put(c.parentId,lstCase);
                }
                else{
                    List<Case> lstCase = new List<Case>();
                    lstCase.add(c);
                    mapSFDParentChildList.put(c.parentId,lstCase);
                }
            }
        System.debug('<<<<<<<<SOQL Count 2>>>>>>>>>>' + Limits.getQueries());
        System.debug('prepareSFDProductParentChildMap');
        System.debug(mapSFDParentChildList);
         return mapSFDParentChildList;
                  
    }
    /**
      * As a SFD Team Member I want to close an SFD Case once all there are no further
      * outstanding actions from SFD team for all Products so that a Case is not 
      * accidentally closed with outstanding actions
      * Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
      */
    public  static Boolean checkChildCasesForNonCompleteStatus(List<Case> childCases){
        Set<String> incompleteStatusesSet=new Set<String>{'New','In Progress','Waiting Internal Response','Waiting User Response','On Hold','Escalated','Pending Billing', 
            'Pending Commercial', 'Pending Security', 'Pending Sales','Pending Service Delivery','Pending Project Delivery', 'Pending CTL',
            'Pending Operations', 'Closed Un-Resolved', 'Cancelled','Re-directed'};
        Boolean productEntryStatus=true;
        for(Case ce:childCases){
            if(incompleteStatusesSet.contains(ce.status)){ //ce.soc_SFD_Product_Status__c 
                productEntryStatus=false;
                return productEntryStatus;
            }
        }
        System.debug('checkChildCasesForNonCompleteStatus');
        System.debug(productEntryStatus);
        return productEntryStatus;
        
    }
    /** EDGE-75358: Validate all child has stage as 'validate and assign order/detail order' and status='withdrawn/rejected'
        Sandeep Soni :: EDGE-75358 :: 09-May-2019
    */
    public  static Boolean checkAllChildCaseWithdrawnOrRejected(List<Case> childCases){
        Set<String> incompleteStatusesSet=new Set<String>{'Withdrawn', 'Rejected'};
        Boolean isChildWithdrawnOrRejected = false;
        for(Case ce:childCases){
            if(ce.Stage__c == 'Validate And Assign Order' || ce.Stage__c == 'Detail Order'){
                if(incompleteStatusesSet.contains(ce.status)){ //ce.soc_SFD_Product_Status__c 
                    isChildWithdrawnOrRejected = true;
                }else{
                    isChildWithdrawnOrRejected = false;
                    return isChildWithdrawnOrRejected;
                }
            }
       }
        System.debug('isChildWithdrawnOrRejected::'+isChildWithdrawnOrRejected);
       return isChildWithdrawnOrRejected;
        
    }
    /**
      * As a SFD Team Member if a parent that's being closed by user and related child cases are not closed then show error 
      * message to user.
      * sandeep soni :: EDGE-88448 :: 23-May-2019
      */
    public  static Boolean checkChildCasesForParentClose(List<Case> childCases){
        Set<String> incompleteStatusesSet=new Set<String>{'New','In Progress','Withdrawn','Rejected','Waiting Internal Response','Waiting User Response','On Hold','Escalated','Pending Billing', 
            'Pending Commercial', 'Pending Security', 'Pending Sales','Pending Service Delivery','Pending Project Delivery', 'Pending CTL',
            'Pending Operations', 'Closed Un-Resolved', 'Cancelled','Re-directed'};
        Boolean productEntryStatus=true;
        for(Case ce:childCases){
            if(incompleteStatusesSet.contains(ce.status)){ //ce.soc_SFD_Product_Status__c 
                productEntryStatus=false;
                return productEntryStatus;
            }
        }
        System.debug('checkChildCasesForNonCompleteStatus');
        System.debug(productEntryStatus);
        return productEntryStatus;
        
    }
    /*  
     * As a SFD Team Member, if login user tries to close parent case and if there is any task that's open on that case then will
     * an error message.
        Sandeep Soni    ::  EDGE-57850  :: 16 Jan 2019
    */
    public static Map<Id, List<Task>> getAllOpenTaskByCase(Map<ID,Case> caseMap){ 
        Map<Id, List<Task>> caseTaskMap = new Map<Id, List<Task>>();
        Boolean isOpenTask = false;
        List<Task> taskList = [SELECT id,status, whatId FROM Task WHERE WhatId = :caseMap.keySet() AND Subject = 'Send Order Confirmation'
                               AND Status!='Completed']; 
        List<Task> lstTask = new List<Task>();
        for(Task tsk : taskList){
            if(caseTaskMap.containsKey(tsk.whatId)){
                caseTaskMap.get(tsk.WhatId).add(tsk);     
            }else{
                caseTaskMap.put(tsk.WhatId, new List<Task>{tsk});
            }
        }
        return caseTaskMap;
    }
     /* 
     * As a SFD Team Member, When all children associated with a parent SFD Case have a "Status" as "Completed", Withdrawn" or "Rejected"
    Then i will create a Task on the parent SFD.
    Sandeep Soni    ::  EDGE-57850  :: 16 Jan 2019
    */
    public static Task createTaskOnParentCase(Case cs){
        Task tsk = null;
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SFD_Order_Confirmation').getRecordTypeId();
            tsk = new Task();
            tsk.Subject = 'Send Order Confirmation';
            tsk.Priority = 'High';
            tsk.RecordTypeId = taskRecordTypeId;
            tsk.Status = 'In Progress';
            tsk.Description = 'Please send the Order Confirmation to the customer and attach this to the Parent SFD Case for closure';
            tsk.OwnerId = cs.OwnerId;
            tsk.whatId = cs.id;
            //Calculating working day
            Date workingDate = workingDate(System.today()+1);
            if(workingDate!=null){
            tsk.ActivityDate = workingDate;//1 working day from the date of Task Creation
            }
            System.debug('createTaskOnParentCase'+tsk);  
        return tsk;
    }
    /*
     * This method is used for calculating working date.
     * Sandeep Soni ::  EDGE-57850  ::  17 Jan 2019
    */
    public static Date workingDate(Date currentDate){
        if(currentDate!=null){
            Datetime dt = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt.format('EEEE');
            if(dayOfWeek=='Saturday'){
                currentDate = currentDate+2;
            }else if(dayOfWeek=='Sunday'){
                currentDate = currentDate+1;
            }
        }
        System.debug('Date::'+currentDate);
        return currentDate;
    }
    /*
     * This method is fetching parent case record based on child case id.
     * Sandeep Soni ::  EDGE-57850 ::   17 Jan 2019
    */
    public static Map<Id,Case> getParentByChildCase(map<ID,Case> updatedCaseMap){ 
        Map<Id, Case> childParentCaseMap = new Map<Id, Case>();
        Set<Id> parentIdSet = new Set<Id>();
        for(Case cs : updatedCaseMap.values()){
            if(cs.RecordTypeId==recId_SFD_ProductType){
                 parentIdSet.add(cs.parentId);
            }
        }
        System.debug('parentIdSet::'+parentIdSet);
        Map<Id,Case> parentCaseMap = new Map<Id,Case>();
        Map<Id, Case> childParentMap = new Map<Id, Case>();
        if(parentIdSet.size() > 0){
            parentCaseMap = new Map<Id,Case>([SELECT ID,OwnerId, Status FROM Case WHERE id=:parentIdSet]);
        }
        System.debug('parentCaseMap::'+parentCaseMap);
        if(parentCaseMap!=null && parentCaseMap.size() > 0){
            for(Case cas : updatedCaseMap.values()){
                Case parentCase = null;
                if(parentCaseMap!=null && parentCaseMap.containsKey(cas.parentId)){
                    parentCase = parentCaseMap.get(cas.parentId);
                }
                childParentMap.put(cas.id, parentCase);               
            }
        }
        System.debug('childParentMap::'+childParentMap);
        return childParentMap;
    }
}