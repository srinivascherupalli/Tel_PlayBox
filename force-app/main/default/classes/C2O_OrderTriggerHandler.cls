/********************************************************************************
* Class Name  : C2O_OrderTriggerHandler
* Description : This class is the Handler Class to call other helper methods to execute the necessary logic.
* Created By  : P.M
* Change Log  : 16 May 2021 - Created

v1.1   05/Oct/2021  Sharath K       Cleaning up duplicate nodes as part of DIGI-28390 
       11/oct/2021  Arun V          Digi-9361
********************************************************************************/
public class C2O_OrderTriggerHandler extends SYS_TriggerHandler {
    // Class variables to capture trigger context variables.
    private Map<Id, csord__Order__c> newOrderMap;
    private Map<Id, csord__Order__c> oldOrderMap;
    private List<csord__Order__c> newOrderList;
    private List<csord__Order__c> oldOrderList;
    
    /***************************************************************************************
* Method Name - C2O_OrderTriggerHandler
* Description - Constructor method to initialise the necessary trigger context variables
****************************************************************************************/
    public C2O_OrderTriggerHandler() {
        this.setHandlerName('C2O_OrderTriggerHandler');
        this.newOrderMap = (Map<Id, csord__Order__c>) Trigger.newMap;
        this.oldOrderMap = (Map<Id, csord__Order__c>) Trigger.oldMap;
        this.newOrderList = Trigger.new;
        this.oldOrderList = Trigger.old;
    }
    /***************************************************************************************
* Method Name - beforeInsert
* Description - This method is used to call the before Insert operation on record.
****************************************************************************************/
    public override void beforeInsert() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Order','triggerBeforeInsert')){
            
        }
    }
    
    /***************************************************************************************
* Method Name - beforeUpdate
* Description - This method is used to call the before Update operation on record.
****************************************************************************************/
    public override void beforeUpdate() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Order','triggerBeforeUpdate')){
            List<String> changesToMonitor = new List<String>{'csord__Status2__c'};
            List<String> trackOldFields = new List<String>{'csord__Status2__c'};
            Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);
            Map<Id,Map<String, String>> oldFieldValuesMap = SYS_UtilityClass.getOldValuesMap(Trigger.oldMap,trackOldFields);
            List<ID> orderIds = new List<ID>();
            for(csord__Order__c order : this.newOrderList){
                if(recordsWithChanges?.get(order.Id)?.contains('csord__Status2__c')){
                    String oldValue = oldOrderMap.get(order.Id).csord__Status2__c;
                    if(order?.csord__Status2__c <> NULL && order?.csord__Status2__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_COMPLETED)){
                        order.RecordTypeId = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByDeveloperName().get('Completed_Order').getRecordTypeId();
                    }
                }
            }
        }
    }
    
    
    /***************************************************************************************
* Method Name - afterInsert
* Description - This method is used to call the after Insert operation on record.
****************************************************************************************/
    public override void afterInsert() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Order','triggerAfterInsert')){
            System.debug('afterinsert----->' + BypassTrigger.isRunningTestCheck);
            List<ID> orderIds = new List<ID>();
            List<ID> OrderId = new List<ID>();
            List<ID> OrderRecIds = new List<ID>();
            //DIGI-19162 : Declaring a Map to store orderIds and their corresponding Status
            Map<Id,String> orderStatusMap = new Map<Id,String>();
            List<csord__Order__c> orderNewList = new List<csord__Order__c>();
            
            for(csord__Order__c order : this.newOrderList){
                if(order.csord__Status2__c!=null){
                    //Added from DirectoryListing PB
                    if(order.csord__Status2__c == System.Label.OrderStatus){
                        orderIds.add(order.Id);
                    }                    
                    //AllOrderProcess PB
                    if(order.csord__Status2__c == 'Completed'){
                        //DIGI-19162 : Commented the below line and added OrderIds and Order status into Map
                        //OrderId.add(order.Id);
                        orderStatusMap.put(order.Id,order.csord__Status2__c);
                    } 
                    if(order.csord__Status2__c == 'In Progress'){
                        //DIGI-19162 : Commented the below line and added OrderIds and Order status into Map 
                        //OrderRecIds.add(order.Id);
                        orderStatusMap.put(order.Id,order.csord__Status2__c);
                    }
                    if(order.csord__Status2__c == 'Ready For Submit'){
                        orderNewList.add(order);
                    }
                }   
            }
            //Added from DirectoryListing PB
             if(!orderIds.isEmpty()){
                AssetUpsertionHelper.processAssetCreation(orderIds);
            }
            if(!orderStatusMap.isEmpty()){
                OrderEmailServiceWrapper.processOrderRecordFrmTrigger(orderStatusMap);
            }
            
            if(!orderNewList.isEmpty()){
                C2O_OrderTriggerHelper.createPostForNewOpportunityTeamMember(orderNewList);
            }     

        }
    }
    

    /***************************************************************************************
* Method Name - afterUpdate
* Description - This method is used to call the after Update operation on record.
****************************************************************************************/
    public override void afterUpdate() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Order','triggerAfterUpdate')){
            //DIGI-34440 fix
            CSPOFA.Events.emit('update', this.newOrderMap.keySet());

            List<String> changesToMonitor = new List<String>{'csord__Status2__c'};
                List<String> trackOldFields = new List<String>{'csord__Status2__c'};
                    Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);
            Map<Id,Map<String, String>> oldFieldValuesMap = SYS_UtilityClass.getOldValuesMap(Trigger.oldMap,trackOldFields);
            List<ID> orderIds = new List<ID>();
            Set<Id> setOfOrderIdOnCompletion = new Set<Id>();
            Set<Id> setOfOrderIdOnNotCompletion = new Set<Id>();
            Set<Id> setOfOrderIdOnReadyForSubmit = new Set<Id>();
            Set<Id> ordids = new Set<Id>();
            List<Id> listOfOrderIdForAssetUpsert = new List<Id>();
            List<ID> OrderId = new List<ID>();
            List<ID> OrderRecIds = new List<ID>();
            //DIGI-19162 : Declaring a Map to store orderIds and their corresponding Status
            Map<Id,String> orderStatusMap = new Map<Id,String>();
            List<csord__Order__c> orderNewListRecs = new List<csord__Order__c>();
            List<csord__Order__c> orderNewListRecs1 = new List<csord__Order__c>(); //Digi-9361 
            String orderInitialState = csordtelcoa__Orders_Subscriptions_Options__c.getInstance().csordtelcoa__Order_Initial_State__c;
            for(csord__Order__c order : this.newOrderList){
                if(recordsWithChanges?.get(order.Id)?.contains('csord__Status2__c')){
                    String oldValue = oldOrderMap.get(order.Id).csord__Status2__c;
                    if(order?.csord__Status2__c <> NULL && order?.csord__Status2__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_COMPLETED)){
                        //setOfOrderIdOnCompletion.add(order.Id);
                        orderStatusMap.put(order.Id,order.csord__Status2__c);
                    }
                    if(order?.csord__Status2__c <> NULL &&  (order?.csord__Status2__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_IN_PROGRESS) ||
                       order?.csord__Status2__c.equalsIgnoreCase(C2O_OrderConstants.STATUS_COMPLETE) )){
                           //setOfOrderIdOnNotCompletion.add(order.Id);
                           orderStatusMap.put(order.Id,order.csord__Status2__c);
                       }
                    if( order?.csord__Status2__c <> NULL &&  order?.csord__Status2__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_READY_FOR_SUBMIT)){
                        setOfOrderIdOnReadyForSubmit.add(order.Id);
                    }//Digi-9361 starts
                    if(order?.csord__Status2__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_READY_FOR_SUBMIT) || order?.csord__Status2__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_OREDR_FAILED)){
                        orderNewListRecs1.add(order);
                        ordids.add(order.id);
                    }//Digi-9361 ends
                    //Added from DirectoryListing PB
                    if( order.csord__Status2__c <> NULL && oldValue != order.csord__Status2__c && order.csord__Status2__c.equalsIgnoreCase(Label.OrderStatus)){
                        listOfOrderIdForAssetUpsert.add(order.Id);
                    }   
                    if(order.csord__Status2__c <> NULL &&  order.csord__Status2__c != oldValue && order.csord__Status2__c !=orderInitialState){
                        orderNewListRecs.add(order);
                    }
                    
                }
            }
            if(!setOfOrderIdOnReadyForSubmit.isEmpty() && !System.isQueueable()){
                System.enqueueJob(new C2O_OrderTriggerHelper.ChatterNotificationForReadyForSubmit(setOfOrderIdOnReadyForSubmit, false));
            }
            if(!listOfOrderIdForAssetUpsert.isEmpty()){
                AssetUpsertionHelper.processAssetCreation(listOfOrderIdForAssetUpsert);
            }
            if(!orderNewListRecs.isEmpty()){ 
                C2O_OrderTriggerHelper.generateOrderMSEvent(orderNewListRecs);
            }            
            if(!newOrderList.isEmpty() && !oldOrderMap.isEmpty()){ 
                C2O_OrderTriggerHelper.postChatterNotification(newOrderList,oldOrderMap);
            }  
            if(!orderStatusMap.isEmpty()){
                OrderEmailServiceWrapper.processOrderRecordFrmTrigger(orderStatusMap);
            }//Digi-9361 starts
            if(!orderNewListRecs1.isEmpty()){
                //ordInjAPIenrichBaskeTnCreateOrder.order_PlatformEvent(orderNewListRecs1, ordids);
            }//Digi-9361 ends
        }
    }
}