/********************************************************************************************
@Apex Trigger Name          :   WorkOrderTrigger
@Description                :   P2OB-6376, Sprint-20.07
@Author                     :   Sandeep Soni
@Comments                   :   This apex trigger will use for workorder event.

@Modified					:	20/05/2021 - Tirth Shah ( P2OB-14473 ) updated for scenarios for PreSales WorkOrder
*********************************************************************************************/
trigger WorkOrderTrigger on WorkOrder (before insert, before update, after update) {
    
    //Fetching Custom Deal RecordType Id
    public static String recId_CustomDeal= Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('cusdl_custom_deal_work_order').getRecordTypeId();
    
    Map<Id, WorkOrder> oldMapWorkOrder= new Map<Id, WorkOrder>();
    Map<Id, WorkOrder> newMapWorkOrder= new Map<Id, WorkOrder>();
    
    for(WorkOrder wo : Trigger.new){
        //validate record type check
        if(wo.RecordTypeId!=null && wo.RecordTypeId == recId_CustomDeal){
            newMapWorkOrder.put(wo.id, wo);
            if(trigger.isUpdate){
                oldMapWorkOrder.put(wo.id,Trigger.oldMap.get(wo.id));
            }
        }    
    }
    //check trigger for isBefore event
    if(trigger.isBefore){
        //check trigger event for before insert, update
        if(trigger.isInsert || trigger.isUpdate){
        System.debug('newMapWorkOrder::'+newMapWorkOrder);
            if(newMapWorkOrder!=null && newMapWorkOrder.size()>0){
                // validate workorder owner is offshore restricted or not.
                cusdl_WorkOrderTriggerHandler.validateWorkOrderOwnerCheck(oldMapWorkOrder, newMapWorkOrder);
                //validate workorder is already assigned to resolver group or not.
                cusdl_WorkOrderTriggerHandler.validataeWOAlreadyExistWithWOType(oldMapWorkOrder, newMapWorkOrder);
            }
        }
        
        //P2OB-10131:: Throw error message while creating workorder based on case and workorder status
        if(trigger.isInsert){
           cusdl_WorkOrderTriggerHandler.validataeSFDWOAlreadyExist(Trigger.new);
        }
    }
    
    /**    
    * Description : Method added for scenarios for PreSales WorkOrder
    * Jira : P2OB - 14473( Tirth Shah )
    */
    if(trigger.isUpdate && trigger.isAfter ){
        cusdl_WorkOrderTriggerHandler.createOpenAirNotification(Trigger.newMap, Trigger.OldMAp);
    }
}