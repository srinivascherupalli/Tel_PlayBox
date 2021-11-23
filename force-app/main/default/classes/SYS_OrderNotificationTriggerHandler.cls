/********************************************************************************
* Class Name  : OrderNotification__e Trigger Handler
* Description : This class is Handler Class to call the helper to execute the logic.   
* Created By  :  
* Change Log  : Created
	Author: Dunna, Uday Kumar
	Date: 14/09/2021
********************************************************************************/

Public class SYS_OrderNotificationTriggerHandler extends SYS_TriggerHandler {
    
    // DECLARE GLOBAL VARIABLES  
    private Map<Id, OrderNotification__e> newNotificationMap;
    private Map<Id, OrderNotification__e> oldNotificationMap;
    List<NotificationParameters> notificationParametersList = new List<NotificationParameters>();
    Integer counter = 0;
    String toLog ='';
    Integer fixedSize = Integer.valueOf(System.Label.fixedSize);
    Integer fullBatchSize = trigger.new.size();
    
    //CONSTRUCTOR 
    public SYS_OrderNotificationTriggerHandler () {
        this.setHandlerName('SYS_NotificationTriggerHandler');
        this.newNotificationMap = (Map<Id, OrderNotification__e>) Trigger.newMap;
        this.oldNotificationMap = (Map<Id, OrderNotification__e>) Trigger.oldMap;
        
    }
    
    
    
    /*************************************************************************************** 
* Method Name - afterInsert
* Description - This method is used to call the after Insert operation on record.
****************************************************************************************/
    public override void afterInsert() {
        // LOCAL VARIABLES
        //NotificationParameters notificationParameters = NotificationParameters ();
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Order_Notification','triggerAfterInsert')){ 
            List<OrderNotification__e> eventList = new List<OrderNotification__e>();
            String ReplayIdOfPreviousEvent = '';
            eventList.addAll((List<OrderNotification__e>)trigger.new);
            if(!eventList.isEmpty()){
                Logger2 log = Logger2.getLogger('All_HVMSNotifications');
                log.logMessages(JSON.serialize(eventList.toString(), true), '', '', '', '', '', false, false,200,'','','');
                log.exitLogger();
            }
            for(OrderNotification__e event : this.newNotificationMap.values() ) {                
                System.debug(counter + ':: Event ExternalId ==> '+event.externalOrderId__c);                
                fullBatchSize = fullBatchSize - 1;                
                if( (counter < fixedSize) && (fullBatchSize != 0)) {  //First 4 notification will be processed in this block 
                    system.debug('entered fullBatchSize - 1');
                    toLog += '*'+event.orderItemId__c+'->'+event.msCorrelationId__c+'\n';
                    notificationParametersList.add( NotificationUtils.getNotificationParameters(event) );   
                    ReplayIdOfPreviousEvent = event.ReplayId;                 
                } else if(fullBatchSize == 0){    //last notification in case of notification equal or less than 6 will be processed in this block 
                    system.debug('entered fullBatchSize == 0');
                    toLog += '*'+event.orderItemId__c+'->'+event.msCorrelationId__c+'\n';
                    notificationParametersList.add( NotificationUtils.getNotificationParameters(event));                    
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);                    
                    counter = 0;
                    break;                    
                } else {  //Incase of Notifications more than 6 batch of for batch of 5 notifications method call will happen from this block  
                    system.debug('entered else');
                    if(String.isNotBlank(ReplayIdOfPreviousEvent)){
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(ReplayIdOfPreviousEvent);
                    }
                    
                    counter = 0;
                    //notificationParametersList = new List<NotificationParameters>();
                    break;
                }                
                counter++;
                if(!String.isBlank(toLog)){
                    Logger2 log = Logger2.getLogger('HVMSEvents');
                    log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false,200,'','','');
                    log.exitLogger();
                }
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);   //Sending events other than first 5, remaining will be send back to event to process in susequent transactions
                
            } // FOR LOOP ENDS            
            if(!notificationParametersList.isEmpty()){
                //OrderNotificationEventHandler.EventHandler(notificationParametersList);
                try{
                    SYS_OrderNotifcationMain.EventHandler(notificationParametersList);
                }
                catch(exception ex){
                    C2O_Utilities.createException(ex);
                }
            }
        }
    } 
}