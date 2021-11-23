/********************************************************************************
* Class Name  : C2O_SubscriptionTriggerHandler
* Description : This class is the Handler Class to call other helper methods to execute the necessary logic.
* Created By  : Sudheendra
* Change Log  : 06 May 2021 - Created
********************************************************************************/
public class C2O_SubscriptionTriggerHandler extends SYS_TriggerHandler {
    // Class variables to capture trigger context variables.
    private Map<Id, csord__Subscription__c> newSubscriptionMap;
    private Map<Id, csord__Subscription__c> oldSubscriptionMap;
    private List<csord__Subscription__c> newSubscriptionList;
    private List<csord__Subscription__c> oldSubscriptionList;
    List<csord__Subscription__c> listOfSubsWithOrderDetails = new List<csord__Subscription__c>();

    /***************************************************************************************
    * Method Name - C2O_SubscriptionTriggerHandler
    * Description - Constructor method to initialise the necessary trigger context variables
    ****************************************************************************************/
    public C2O_SubscriptionTriggerHandler() {
        this.setHandlerName('C2O_SubscriptionTriggerHandler');
        this.newSubscriptionMap = (Map<Id, csord__Subscription__c>) Trigger.newMap;
        this.oldSubscriptionMap = (Map<Id, csord__Subscription__c>) Trigger.oldMap;
        this.newSubscriptionList = Trigger.new;
        this.oldSubscriptionList = Trigger.old;
    }

    /***************************************************************************************
    * Method Name - beforeInsert
    * Description - This method is used to call the before Insert operation on record.
    ****************************************************************************************/
    public override void beforeInsert() {

    }

    /***************************************************************************************
    * Method Name - beforeUpdate
    * Description - This method is used to call the before Update operation on record.
    ****************************************************************************************/
    public override void beforeUpdate() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Subscription','triggerBeforeUpdate')){
            List<String> changesToMonitor = new List<String>{'csord__Status__c'};
                List<String> trackOldFields = new List<String>{'csord__Status__c'};

                    Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(this.oldSubscriptionMap,this.newSubscriptionMap,changesToMonitor);
            Map<Id,Map<String, String>> oldFieldValuesMap = SYS_UtilityClass.getOldValuesMap(this.oldSubscriptionMap,trackOldFields);

            List <csord__Subscription__c> relacedSubscriptionList = new List <csord__Subscription__c>();
            List <csord__Subscription__c> paidOutSubscriptionList = new List <csord__Subscription__c>();
            List <csord__Subscription__c> inactiveSubscriptionList = new List <csord__Subscription__c>();
            List <csord__Subscription__c> nonBlankReplacedSubscrList = new List <csord__Subscription__c>();

            // Single Loop to handle all possible Trigger context scenarios
            for(csord__Subscription__c subscription : this.newSubscriptionList){

                if(String.isBlank(subscription.csordtelcoa__Replaced_Subscription__c) && recordsWithChanges.get(subscription.Id)?.contains('csord__Status__c')
                   && oldFieldValuesMap?.get(subscription.Id)?.get('csord__Status__c') <> NULL
                   && !oldFieldValuesMap.get(subscription.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.ACTIVE)
                   && subscription.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.ACTIVE)
                   && subscription.Initial_Activation_DateTime__c == null &&  subscription.initialActivationDate__c==null)
                {
                    relacedSubscriptionList.add(subscription);
                }
                // Logic to check if the status value is changed from some value to Suspended OR Paid Out OR Closed
                if(recordsWithChanges.get(subscription.Id)?.contains('csord__Status__c') && oldFieldValuesMap?.get(subscription.Id)?.get('csord__Status__c') <> NULL &&
                   ((!oldFieldValuesMap.get(subscription.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.PAID_OUT)
                    && subscription.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.PAID_OUT)) ||
                   (oldFieldValuesMap.get(subscription.Id)?.get('csord__Status__c') != C2O_OrderConstants.SUSPENDED
                    && subscription.csord__Status__c == C2O_OrderConstants.SUSPENDED) ||
                   (oldFieldValuesMap.get(subscription.Id)?.get('csord__Status__c') != C2O_OrderConstants.CLOSED
                    && subscription.csord__Status__c == C2O_OrderConstants.CLOSED)))
                {
                    paidOutSubscriptionList.add(subscription);
                }
                if(oldFieldValuesMap.get(subscription.Id)?.get('csord__Status__c') != C2O_OrderConstants.INACTIVE
                   && subscription.csord__Status__c == C2O_OrderConstants.INACTIVE
                   && recordsWithChanges.get(subscription.Id)?.contains('csord__Status__c')){
                       inactiveSubscriptionList.add(subscription);
                   }
                if(recordsWithChanges.get(subscription.Id)?.contains('csord__Status__c')
                   && oldFieldValuesMap.get(subscription.Id)?.get('csord__Status__c') != C2O_OrderConstants.ACTIVE
                   && subscription.csord__Status__c == C2O_OrderConstants.ACTIVE
                   && !String.isBlank(subscription.csordtelcoa__Replaced_Subscription__c) ){
                       nonBlankReplacedSubscrList.add(subscription);
                   }
            }
            if(!relacedSubscriptionList.isEmpty()){
                C2O_SubscriptionTriggerHelper.updateActivationDetails(relacedSubscriptionList);
            }
            if(!paidOutSubscriptionList.isEmpty()){
                C2O_SubscriptionTriggerHelper.updateCompletionDate(paidOutSubscriptionList);
            }
            if(!inactiveSubscriptionList.isEmpty()){
                C2O_SubscriptionTriggerHelper.updateDeactivationDetails(inactiveSubscriptionList);
            }
            if(!nonBlankReplacedSubscrList.isEmpty()){
                C2O_SubscriptionTriggerHelper.updateFirstActivatedDetails(nonBlankReplacedSubscrList);
            }
            SubscriptionCustomTriggerHandler.updateInvokeBDSNotificationOnNumbers(this.newSubscriptionMap,this.oldSubscriptionMap);//added as part of DIGI-13385

        }
    }


    /***************************************************************************************
    * Method Name - afterInsert
    * Description - This method is used to call the after Insert operation on record.
    ****************************************************************************************/
    public override void afterInsert() {
        // LIFT AND SHIFT TO BE OPTIMIZE BY FEATUTRE TEAM
        // SOQL to get List of Suscriptions with Order details
        listOfSubsWithOrderDetails = SubscriptionCustomTriggerHandler.getSubscriptionsWithOrderDetails(Trigger.newMap.keySet());
        SubscriptionCustomTriggerHandler.afterInsert(this.newSubscriptionMap,listOfSubsWithOrderDetails);
    }

    /***************************************************************************************
    * Method Name - afterUpdate
    * Description - This method is used to call the after Update operation on record.
    ****************************************************************************************/
    public override void afterUpdate() {

        // LIFT AND SHIFT TO BE OPTIMIZE BY FEATUTRE TEAM
        // SOQL to get List of Suscriptions with Order details
        listOfSubsWithOrderDetails = SubscriptionCustomTriggerHandler.getSubscriptionsWithOrderDetails(Trigger.newMap.keySet());
        SubscriptionCustomTriggerHandler.afterUpdate(this.newSubscriptionMap,this.oldSubscriptionMap,listOfSubsWithOrderDetails);


        if(FeatureEligibilityChecker.determineFeatureEligiblity('Subscription','triggerAfterUpdate')){
            //Added by P.M
            setMaxLoopCount(2);
            List<String> changesToMonitor = new List<String>{'csord__Status__c', 'Telstra_Committed_Date__c', 'Forecasted_Delivery_Date__c',
                'Telstra_Committed_Date__c', 'Forecasted_Delivery_Date__c', 'stage__c','TenancyID__c', 'Nickname__c','Suspension_reason_summary__c'};
            List<String> trackOldFields = new List<String>{'csord__Status__c', 'TenancyID__c'};
            Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap, Trigger.newMap, changesToMonitor);
            Map<Id,Map<String, String>> oldFieldValuesMap = SYS_UtilityClass.getOldValuesMap(Trigger.oldMap, trackOldFields);

            List<String> listOfSubscriptionForUpdateEvent = new List<String>();
            List<String> listOfSubscriptionForCreateEvent = new List<String>();
            Set<Id> setOfSubscriptionIdForOrderChatter =  new Set<Id>();
            Set<Id> setOfContractIdToCancel = new Set<Id>();
            Set<Id> setOfSubIdForTenancyIdUpdate = new Set<Id>();
            Map<Id,String> mapSubIdVsNotificationType = new Map<Id,String>();
            Map<Id,String> mapSubIdVsNotificationWithWrapper = new Map<Id,String>();
            Set<Id> setOfSubscriptionIds = new Set<Id>();

            Set<String> setOfSubscriptionStatusForUpdate = new Set<String>{C2O_OrderConstants.STATUS_PROVISIONED, C2O_OrderConstants.STATUS_SUSPENDED,
                C2O_OrderConstants.STATUS_BILL_READINESS_IN_PROGRESS, C2O_OrderConstants.STATUS_BILLING_COMPLETE, C2O_OrderConstants.STATUS_PARTIAL_ACTIVE,
                C2O_OrderConstants.STATUS_ACTIVE, C2O_OrderConstants.STATUS_INACTIVE, C2O_OrderConstants.STATUS_FAILED,
                C2O_OrderConstants.STAGE_AMEND_PENDING, C2O_OrderConstants.STAGE_AMEND_REJECTED, C2O_OrderConstants.STAGE_CANCELLATION_PENDING,
                C2O_OrderConstants.STAGE_CANCELLATION_IN_PROGRESS, C2O_OrderConstants.STAGE_CANCELLED, C2O_OrderConstants.CLOSED};

            for(csord__Subscription__c subscription : this.newSubscriptionList){

                // STATUS CHANGE CONDITION STARTS
                if(recordsWithChanges.get(subscription.Id)?.contains('csord__Status__c')){
                    // STATUS ALL
                    System.Debug(' subscription.csord__Status__c ==> ' + subscription.csord__Status__c );
                    System.Debug(' setOfSubscriptionStatusForUpdate.contains(subscription.csord__Status__c) ==> ' + setOfSubscriptionStatusForUpdate.contains(subscription.csord__Status__c) );
                    if(setOfSubscriptionStatusForUpdate.contains(subscription.csord__Status__c)){
                        listOfSubscriptionForUpdateEvent.add(subscription.Id + C2O_OrderConstants.SEPERATOR + C2O_OrderConstants.UPDATE_OPERATION);
                    }
                    //StatusProvisioning In Progress
                    else if( (String.isBlank(oldFieldValuesMap?.get(subscription.Id)?.get('csord__Status__c')) ||
                       (oldFieldValuesMap?.get(subscription.Id)?.get('csord__Status__c') <> NULL && 
                        !oldFieldValuesMap?.get(subscription.Id)?.get('csord__Status__c')?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS)) ) &&
                        (subscription.csord__Status__c <> NULL && subscription.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS) )) {
                        
                            listOfSubscriptionForCreateEvent.add(subscription.Id + C2O_OrderConstants.SEPERATOR + C2O_OrderConstants.CREATE_OPERATION);
                    }


                    if(subscription?.csord__Status__c <> NULL && subscription?.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_CLOSED_REPLACED) &&
                        
                       String.isNotBlank(subscription.Contract__c) && String.isNotBlank(subscription.ContractJunction__c)){
                       setOfContractIdToCancel.add(subscription.ContractJunction__c);
                    }
                    
                    if( subscription?.csord__Status__c <> NULL && (subscription?.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONED) ||
                        subscription?.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_INACTIVE))&&
                        String.isNotBlank(subscription.MarketableOffer__c) &&
                        (subscription.toBeCancelled__c <> NULL && subscription.toBeCancelled__c.equalsIgnoreCase(C2O_OrderConstants.FALSE_STRING)) &&
                        String.isNotBlank(subscription.csordtelcoa__Replaced_Subscription__c)){
                            
                        setOfSubscriptionIdForOrderChatter.add(subscription.Id);
                    }
                    
                    if( subscription?.csord__Status__c <> NULL && 
                        subscription?.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_ACTIVE) &&
                        String.isNotBlank(subscription.MarketableOffer__c )){
                            
                        setOfSubIdForTenancyIdUpdate.add(subscription.Id);
                    }
                    
                    //Added by Nikhil as part of DIGI-4694  
                    if((subscription?.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_ACTIVE) 
                    || subscription.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS) 
                    || subscription.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_INACTIVE)) &&
                                        String.isNotBlank(subscription.MarketableOffer__c )){                              
                        setOfSubscriptionIds.add(subscription.Id);  
                    }
                }
                // NickNameChanged
                else if(recordsWithChanges.get(subscription.Id)?.contains('Nickname__c')) {
                    
                    if(subscription.csord__Status__c <> NULL && subscription.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS)){
                        
                        listOfSubscriptionForUpdateEvent.add(subscription.Id + C2O_OrderConstants.SEPERATOR + C2O_OrderConstants.UPDATE_OPERATION);
                    }
                }
                // Stackable Suspensions
                else if( recordsWithChanges.get(subscription.Id)?.contains('Suspension_reason_summary__c') ) {
                    
                    if(!recordsWithChanges.get(subscription.Id)?.contains('csord__Status__c') &&
                        (subscription?.csord__Status__c <> NULL && subscription?.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.SUSPENDED)) &&
                        subscription.Suspension_reason_summary__c.contains(',') ){
                            
                        listOfSubscriptionForUpdateEvent.add(subscription.Id + C2O_OrderConstants.SEPERATOR + C2O_OrderConstants.UPDATE_OPERATION);
                    }
                }
                // STATUS CHANGE CONDITION ENDS

                if(recordsWithChanges?.get(subscription.Id)?.contains('TenancyID__c')){
                    if(String.isBlank(oldFieldValuesMap?.get(subscription.Id)?.get('TenancyID__c')) &&
                        String.isNotBlank(subscription.MarketableOffer__c)){
                            
                        setOfSubIdForTenancyIdUpdate.add(subscription.Id);
                    }
                }

                if(recordsWithChanges?.get(subscription.Id)?.contains('Telstra_Committed_Date__c') ||
                    recordsWithChanges?.get(subscription.Id)?.contains('Forecasted_Delivery_Date__c')){
                        
                        if(String.isNotBlank(String.valueOf(subscription.Telstra_Committed_Date__c)) &&
                            String.isNotBlank(String.valueOf(subscription.Forecasted_Delivery_Date__c)) &&
                            subscription.Forecasted_Delivery_Date__c > subscription.Telstra_Committed_Date__c){
                            
                                System.Debug(' *** DELAY_NOTIFICATION ==> ' );
                                mapSubIdVsNotificationType.put(subscription.Id, C2O_OrderConstants.DELAY_NOTIFICATION);
                    }
                }
                

                if(recordsWithChanges?.get(subscription.Id)?.contains('stage__c') && subscription?.stage__c <> NULL ){
                    
                    //STAGE_OREDR_RECEIVED
                    if(subscription?.stage__c?.equalsIgnoreCase(C2O_OrderConstants.STAGE_OREDR_RECEIVED)){
                        mapSubIdVsNotificationType.put(subscription.Id, C2O_OrderConstants.STAGE_OREDR_RECEIVED);
                    }
                    //STAGE_BEING_FULFILLED
                    if(subscription?.stage__c?.equalsIgnoreCase(C2O_OrderConstants.STAGE_BEING_FULFILLED)){
                        mapSubIdVsNotificationType.put(subscription.Id, C2O_OrderConstants.STAGE_BEING_FULFILLED);
                    }
                    //STAGE_READY_FOR_USE
                    if(subscription?.stage__c?.equalsIgnoreCase(C2O_OrderConstants.STAGE_READY_FOR_USE)){
                        mapSubIdVsNotificationWithWrapper.put(subscription.Id, C2O_OrderConstants.STAGE_READY_FOR_USE);
                    }
                }

            }

            if(!listOfSubscriptionForUpdateEvent.isEmpty()){
                InvokeInventoryPublishEvents.publishSubscriptionEventHandler(listOfSubscriptionForUpdateEvent);
            }
            if(!listOfSubscriptionForCreateEvent.isEmpty()){
                InvokeInventoryPublishEvents.publishSubscriptionEventHandler(listOfSubscriptionForCreateEvent);
            }
            if(!setOfContractIdToCancel.isEmpty()){
                CancelContractWithAgreement.processCancellation(new List<Id>(setOfContractIdToCancel));
            }
            if(!setOfSubscriptionIdForOrderChatter.isEmpty()){
                C2O_SubscriptionTriggerHelper.postChatterForSubscriptionOrder(setOfSubscriptionIdForOrderChatter);
            }
            if(!mapSubIdVsNotificationType.isEmpty() && !System.isQueueable()){
                System.enqueueJob(new C2O_SubscriptionTriggerHelper.OrderNotification(mapSubIdVsNotificationType, false));
            }
            if(!mapSubIdVsNotificationWithWrapper.isEmpty() && !System.isQueueable()){
                System.enqueueJob(new C2O_SubscriptionTriggerHelper.OrderNotificationWithNetworkWrapper(mapSubIdVsNotificationWithWrapper, false));
            }
            if(!setOfSubIdForTenancyIdUpdate.isEmpty() && !System.isQueueable()){
                C2O_SubscriptionTriggerHelper.tenacyIdUpdate(setOfSubIdForTenancyIdUpdate);
            }
            
            //Added by Nikhil as part of DIGI-4694
            if(!setOfSubscriptionIds.isEmpty()){
                C2O_SubscriptionTriggerHelper.sendOrderNotification(setOfSubscriptionIds);
            }
        }

    }
}