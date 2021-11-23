/********************************************************************************************
@Class Name                 :   cusdl_WorkOrderTriggerHandler
@Description                :   P2OB-6376, Sprint-20.07
@Author                     :   Sandeep Soni
@Comments                   :   This apex class will have the workorder functionalty.

Modified                    :   20-05-2021 : Tirth Shah : P2OB-14473 - Create Platform Events when Owner is changed.
DIGI-37522 : Vivian Charlie 15 Nov 2021 : invoking platform event only for Purple Presales Standard Solution
*********************************************************************************************/
public without sharing class cusdl_WorkOrderTriggerHandler {
    
    public static Id recTypeId_SFDWoRequest = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('SFD_Work_Order_Request').getRecordTypeId();
    
    /*
*  Story No: P2OB-6376
*  Developer Name: Sandeep Soni  
*  Description: validate workorder owner is offshore restricted or not
*/
    public static void validateWorkOrderOwnerCheck(Map<Id, WorkOrder> mapOldWorkOrder, Map<Id, WorkOrder> mapNewWorkOrder){
        Set<Id> setAccId = new Set<Id>();
        Set<Id> setOwnerId = new Set<Id>();
        //For fetching accountid and owner id from workorder.
        for(WorkOrder wo : mapNewWorkOrder.values()){
            if(wo.OwnerId!=null && String.valueOf(wo.OwnerId).startsWith('005')){
                if(wo.AccountId != null && ((mapOldWorkOrder!=null && mapOldWorkOrder.containsKey(wo.id) && mapOldWorkOrder.get(wo.Id).OwnerId != wo.Ownerid) || mapOldWorkOrder == null)){
                    //add workorder's accountid in set 
                    setAccId.add(wo.AccountId);
                    //add workorder owner id in set
                    setOwnerId.add(wo.OwnerId);
                }
            }
            
        }
        //validate setAccId is not null and size is grater than zero
        if(setAccId!=null && setAccId.size()>0){
            //validate if work order is offshore restricted or not.
            cusdl_WorkOrderTriggerService.checkWOOffShoreRestricted(setAccId,setOwnerId, mapNewWorkOrder);
            
        }
        
    }
    /*
    Method Name:         validataeWOAlreadyExistWithWOType
    Input Parameter:     Map<Id, WorkOrder> oldMapWorkOrder: This map will have old workorder records
                         Map<Id, WorkOrder> newMapWorkOrder: This map will have old workorder records
    Output Parameter:    Nothing(Void)
    Description:         This Method will check if, there is already a workorder open('New','In Progress','On Hold') in same case then
                         Show an error message to user.
    Reference:           JIRA Story: P2OB-4166::As a system when there is already a Work Order open then i should not allow the user to create another work order of the same work order type                     
    */
    public static void validataeWOAlreadyExistWithWOType(Map<Id, WorkOrder> oldMapWorkOrder, Map<Id, WorkOrder> newMapWorkOrder){
         //This set contains all work order type for which we will check existing workorder.
         Set<String> setWOStatus= new Set<String>{'New', 'In Progress','On Hold'};
         //call to checkWOAlreadyAssignedToResloverGroup method for fetching all workorders.
         cusdl_WorkOrderTriggerService.checkWOAlreadyAssignedToResloverGroup(oldMapWorkOrder, newMapWorkOrder,setWOStatus);
    }
    
    /*
    Method Name:         validataeSFDWOAlreadyExist
    Input Parameter:     Map<Id, WorkOrder> oldMapWorkOrder: This map will have old workorder records
    Output Parameter:    Nothing(Void)
    Description:         This Method will check if, there is already a workorder status('Withdrawn') in same case then
                         Show an error message to user.
    Reference:           JIRA Story: P2OB-10131::As a system when there is already a Work Order open then i should not allow the user to create another work order                 
    */
    public static void validataeSFDWOAlreadyExist(List<WorkOrder> newWorkOrderlist){
         //This set contains all work order type for which we will check existing workorder.
         Set<String> setWOStatus= new Set<String>{'Withdrawn'};
         Set<String> setCaseStatus= new Set<String>{'Closed', 'Withdrawn','Rejected'};
         Set<Id> setOfCaseId = new Set<Id>();
        
        Map<Id, WorkOrder> newMapWorkOrder= new Map<Id, WorkOrder>();
    
        for(WorkOrder wo : newWorkOrderlist){
            //validate record type check
            if(wo.RecordTypeId!=null && wo.RecordTypeId == recTypeId_SFDWoRequest){
                newMapWorkOrder.put(wo.id, wo);
                if(wo.CaseId!=null){
                    setOfCaseId.add(wo.CaseId);
                }
            }
        }
        
        System.debug('setOfCaseId:'+ setOfCaseId);
        if(setOfCaseId !=null && setOfCaseId.size() > 0){            
            Map<Id,Case> existingCaseSet = new map<id,case>([Select ID,(Select ID, Status from WorkOrders WHERE 
                                            RecordTypeId =: recTypeId_SFDWoRequest AND Status IN :setWOStatus) from Case where ID IN :setOfCaseId]);
            
            Map<Id,Case> existingCaseStatusSet = new map<id,case>([Select ID, Status from Case where Status IN :setCaseStatus AND ID IN :setOfCaseId]);
            
            System.debug('existingCaseStatusSet:'+ existingCaseSet.Values());
            
            if(existingCaseStatusSet !=null){
                for(Workorder wok : newMapWorkOrder.values()){
                    if(existingCaseStatusSet.containsKey(wok.CaseId)){
                        wok.addError('Work Order cannot be created for given Case because either its closed or is not in correct stage.');
                    }
                }
            }
            
            if(existingCaseSet != null){
                for(Workorder wok : newMapWorkOrder.values()){
                    if(wok.CaseId !=null && existingCaseSet.containsKey(wok.CaseId) && existingCaseSet.get(wok.CaseID).WorkOrders!=null &&
                     existingCaseSet.get(wok.CaseID).WorkOrders.size()>0){
                        wok.addError('A withdrawn work order exists on the case, please edit the existing withdrawn work order instead of creating a new work order.');
                    }
                }
            }
        }       
    }
    
    
    /**    
    * Description : Method to Create OpenAirNotification Platform Event for MuleSoft. Whenever the WorkOrder Owner is changed. 
    * Jira : P2OB-14473 (Sprint 21.07)
    DIGI-37522 : adding fixes for invoking event only for Purple Presales Opportunities
    */
    public static void createOpenAirNotification(Map<id,WorkOrder> newMap, Map<id,WorkOrder> oldMap){
        try{
            Id StandardSolution = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Presales_Solution_Work_Order').getRecordTypeId();
            List<OpenAir_Notification__e> oanList = new List<OpenAir_Notification__e>();
            Map<id,list<WorkOrder>> mapcaseId_WorkOrders = new Map<id,list<WorkOrder>>();
            /*
            for(Id WorkOrderId : newMap.keySet()){
                String NewOwner = newMap.get(WorkOrderId).OwnerId.getSObjectType().getDescribe().getName();
                String OldOwner = oldMap.get(WorkOrderId).OwnerId.getSObjectType().getDescribe().getName();
                
                if(newMap.get(WorkOrderId).RecordTypeId == StandardSolution && newMap.get(WorkOrderId).OwnerId != oldMap.get(WorkOrderId).OwnerId){
                    if( ( OldOwner == 'Group' && NewOwner == 'User' ) || ( OldOwner == 'User' && NewOwner == 'User' ) ){
                        oanList.add(PRMOpenAirNotificationUtil.GenrateOpenAirNotificationData(WorkOrderId, newMap.get(WorkOrderId).CaseId));
                    }
                }
            }
            */
            for(WorkOrder objWorkOrder : newMap.values()){
                if(objWorkOrder.RecordTypeId == StandardSolution 
                && objWorkOrder.OwnerId != oldMap.get(objWorkOrder.Id).OwnerId){
                    String newOwner = String.valueof(objWorkOrder.OwnerId);
                    String oldOwner = String.valueof(oldMap.get(objWorkOrder.Id).OwnerId);

                    if((OldOwner.startsWith('00G') && NewOwner.startsWith('005')) 
                    || (OldOwner.startsWith('005') && NewOwner.startsWith('005'))){
                        if(!mapcaseId_WorkOrders.containsKey(objWorkOrder.CaseId)){
                            mapcaseId_WorkOrders.put(objWorkOrder.CaseId,new list<WorkOrder>{objWorkOrder});
                        }else{
                            mapcaseId_WorkOrders.get(objWorkOrder.CaseId).add(objWorkOrder);
                        }
                    }
                } // end of owner change check for Standard Solution WO
            } // end of WorkOrder for loop

            if(!mapcaseId_WorkOrders.isEmpty()){
                    for(Case objC : [Select Id
                                      , RecordtypeId
                                      , Recordtype.DeveloperName
                                      , Technology_Specialisation__c
                                From Case
                                Where Id IN : mapcaseId_WorkOrders.keyset()
                                and Technology_Specialisation__c != null
                                and Technology_Specialisation__c != ''
                                and Recordtype.Developername = 'Presales_Solution']){
                        for(WorkOrder objEligibleWO : mapcaseId_WorkOrders.get(objC.Id)){
                            oanList.add(PRMOpenAirNotificationUtil.GenrateOpenAirNotificationData(objEligibleWO.Id, objC.Id));
                        }
                    }
            } // end of !mapcaseId_WorkOrders.isEmpty()

            if(oanList != null && !oanList.isEmpty()){
                system.debug('oanList*****'+oanList);
                PRMOpenAirNotificationUtil.publishEvents(oanList);
            }
        }catch(Exception e){
            System.debug('***Telstra:CaseTriggerHandler:createOpenAirNotification:exception:'+e.getMessage());
            System.debug('***Telstra:CaseTriggerHandler:createOpenAirNotification:exception: At Line number: ' + e.getLineNumber());
        }
    }
}