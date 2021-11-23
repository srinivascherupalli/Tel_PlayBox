/********************************************************************************************
@Class Name                 :   cusdl_WorkOrderTriggerService
@Description                :   P2OB-4166, Sprint-20.10
@Author                     :   Sandeep Soni
@Comments                   :   This apex class will have the workorder functionalty.

@Modified                   :   P2OB-15612 Tirth Shah (Team Hawaii) (21.10): As a Custom Deal 
                                Team Member, I should be allowed to create multiple Domain Architect 
                                Work Orders, so that I can request help for multiple domains
*********************************************************************************************/
public without sharing class cusdl_WorkOrderTriggerService {
    
    //P2OB-4166: If there is already a workorder that's assigned to resolver group then show this error message
    public static String WO_ALREADY_ASSIGNED_RESOLVER_GROUP = 'Work Order is already assigned to the resolver groups';
    
    //P2OB-15612: Added by Team Hawaii (Tirth Shah) 21.10
    public static String WO_TYPE_DOMAIN_ARCHITECH = 'Domain Architect';
    //Fetching Custom Deal work order record type id
    public static Id recTypeId_WOCustomDeal= Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('cusdl_custom_deal_work_order').getRecordTypeId();
    //Fetching custom deal record type id
    public static Id recTypeId_CustomDeal= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
        
    /*
    *  Story No: P2OB-6376
    *  Developer Name: Sandeep Soni  
    *  Description: validate workorder owner is offshore restricted or not
    */
    public static void checkWOOffShoreRestricted(Set<Id> setAccId, Set<Id> setOwnerId, Map<Id, WorkOrder> mapNewWorkOrder){
            Set<Id> roleids = new set<id>();
            //Fetching account details that have offshore restricted true
            Map<id, Account> mapOffShoreAcc = new Map<Id, Account>([SELECT ID,APTPS_Off_Shore_Restricted__c FROM Account WHERE id IN :setAccId AND APTPS_Off_Shore_Restricted__c = true]);
            //validate setOwnerId should not be null and size should be grater than zero.
            if(setOwnerId!=null && setOwnerId.size()>0){
                //Fetching user details from set of workorder ownerid
                Map<Id,User> mapUser = new Map<Id,User>([SELECT ID, UserRoleId FROM User where Id IN : setOwnerId]);
                //fetching role id's set from public group.
                roleids=GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
                //Iterate workorder record and validate for each record.
                for(WorkOrder wo : mapNewWorkOrder.values()){
                    //Check: mapOffShoreAcc,mapUser should not be null and empty and also check if offshore restricted     
                    if(mapOffShoreAcc!=null && mapOffShoreAcc.containsKey(wo.AccountId) 
                       && (mapUser !=null && mapUser.containsKey(wo.OwnerId) && mapUser.get(wo.OwnerId).UserRoleId !=null && roleids!=null && roleids.size()>0 && roleids.contains(mapUser.get(wo.OwnerId).UserRoleId)) || (GroupMembership.groupUserId!=null && GroupMembership.groupUserId.contains(wo.ownerId))){
                           //add error message on workorder record if workorder.Account is offshore restricted and also workorder owner is the member of OffshoreGroup.
                           wo.addError(System.Label.cusdl_OffshoreRestrictedRoleErrorMessage);
                       }
                }        
            }
    }
    /*
    Method Name:         checkWOAlreadyAssignedToResloverGroup
    Input Parameter:     Map<Id, WorkOrder> oldMapWorkOrder: This map will have old workorder records
                         Map<Id, WorkOrder> newMapWorkOrder: This map will have old workorder records
                         Set<String> setWOStatus: This set will have workorder status like New, In Progress
    Output Parameter:    Nothing(Void)
    Description:         This Method will check if, there is already a workorder open('New','In Progress','On Hold') in same case then
                         Show an error message to user.
    Reference:           JIRA Story: P2OB-4166::As a system when there is already a Work Order open then i should not allow the user to create another work order of the same work order type                     
    */
    public static void checkWOAlreadyAssignedToResloverGroup(Map<Id, WorkOrder> oldMapWorkOrder, Map<Id, WorkOrder> newMapWorkOrder, Set<String> setWOStatus){
        
        //This set will contain all caseids.
        Set<Id> setCaseId = new Set<Id>();
        //iterate all workorder
        for(WorkOrder wo : newMapWorkOrder.values()){
            //store case id into set variable
            if(wo.CaseId!=null){
              setCaseId.add(wo.CaseId);
            }
        }
        System.debug('Set of caseidss::'+setCaseId);
        if(setCaseId!=null && setCaseId.size()>0){
            //Fetching all cases with related work order with required parameter.
            Map<ID, Case> mapCase = new Map<Id,Case>([SELECT ID,(SELECT ID,cusdl_work_order_type__c FROM WorkOrders WHERE  
            RecordTypeId=:recTypeId_WOCustomDeal AND Status IN :setWOStatus) FROM Case WHERE ID IN :setCaseID AND
             RecordTypeId=:recTypeId_CustomDeal]);
            if(mapCase != null && newMapWorkOrder!=null && newMapWorkOrder.size()>0){
                //Fetching all workorder
                for(WorkOrder wo : newMapWorkOrder.values()){
                    /*validation mapCase!=null, mapCase should contains wo.caseid, if there is any workorder that have with above required condition
                    then show an error message to user.*/

                    /*  Updated - 21.10
                        P2OB-15612 Tirth Shah (Team Hawaii) (21.10): As a Custom Deal Team Member, I should be allowed to create multiple Domain Architect Work Orders, so that I can request help for multiple domains
                        User Should be able to create multiple Work Order with "Domain Architect" Type.
                    */
                    if(wo.cusdl_work_order_type__c != WO_TYPE_DOMAIN_ARCHITECH){
                        if((wo.id==null || (wo.id!=null && oldMapWorkOrder!=null && oldMapWorkOrder.containsKey(wo.id) && 
                        oldMapWorkOrder.get(wo.id).cusdl_work_order_type__c != wo.cusdl_work_order_type__c)) 
                        && mapCase.containsKey(wo.CaseID) && mapCase.get(wo.CaseID).WorkOrders!=null &&
                        mapCase.get(wo.CaseID).WorkOrders.size()>0){
                            for(WorkOrder existWO : mapCase.get(wo.CaseID).WorkOrders){
                            //validate work order with same workorder type is already exist then show error.
                                if(existWO.cusdl_work_order_type__c == wo.cusdl_work_order_type__c){
                                    //show error message 'work order is already assigned to resolver group.'
                                    wo.addError(WO_ALREADY_ASSIGNED_RESOLVER_GROUP);
                                }
                            }
                        
                        }
                    }
                }
            }
        }
        
    }
    

}