/*********************************************************************************************************************************
Class Name : NumberTriggerHandler
Test Class : NumberTriggerHandlerTest
Created By : Sonalisa Verma
Created On : 19 Feb 2020
User Story : EDGE - 138136 created trigger to assign coorelation id
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Nikhil Sharma        11 March 2021    EDGE-202844
2.            Vivek; Apple         26 April 2021    EDGE-204050
3.            Arun; DPG Neon       09 Aug 2021      DIGI-9672
***********************************************************************
*/

public with sharing class NumberTriggerHandler {

    /**************************************************************************************
    ****** Desc         : Method to filter records for after insert
    ****** Story        : EDGE-138136
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
        public static void handleAfterInsert(Map<Id, Number__C> newMap){
            Map<Id, Number__C> filteredNumbersMap = new Map<Id, Number__C>();
            List<Number__c> provisionedNumbersList = new List<Number__c>();
            List<Number__c> disconnectedNumbersList = new List<Number__c>();
            for(Number__C n : newMap.values()){
                 //check if Mobile__c = ‘Fixed’ and Status = ‘Provisioned’
                if((n.Mobile__c == 'Fixed' || (n.Mobile__c =='Mobile' && n.Pattern_Type__c == 'Number'))  
                    && n.Status__c!=null && n.Status__c.equalsIgnoreCase('Provisioned') 
                    && n.Subscription_number__c != null) {
                        filteredNumbersMap.put(n.Id, n);
                }
                
                if((n.Mobile__c == 'Fixed' || (n.Mobile__c =='Mobile' && n.Pattern_Type__c == 'Number')) && n.Status__c!=null){
                    // add by Nikhil as part of EDGE-202844 //EDGE-219683
                    if(String.isNotBlank(n.Service_Number__c) && String.isNotBlank(n.Subscription_number__c) 
                    && n.Status__c.equalsIgnoreCase('Provisioned') && n.Invoke_BDS_Notification__c == true) {
                        provisionedNumbersList.add(n);
                    }
                    // add by Nikhil as part of EDGE-202844 (6b)
                    if(String.isNotBlank(n.Service_Number__c) && n.Status__c.equalsIgnoreCase('Disconnected')) {
                        disconnectedNumbersList.add(n);
                    }
                } 
            }
            if(filteredNumbersMap.size()>0){
                processNumbers(filteredNumbersMap);
            }
            // add by Nikhil as part of EDGE-202844 
            if(provisionedNumbersList.size()>0){
                pushNumbersToBDS(provisionedNumbersList,'Provisioned');
            }        
            // add by Nikhil as part of EDGE-202844 (6b)
             if(disconnectedNumbersList.size()>0){
                pushNumbersToBDS(disconnectedNumbersList,'Disconnected');
            }
        }
    
    /**************************************************************************************
    ****** Desc         : Method to filter records for after update
    ****** Story        : EDGE-138136
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
        public static void handleAfterUpdate(Map<Id, Number__C> newMap, Map<Id, Number__C> oldMap){
            system.debug('inside after');
            Map<Id, Number__C> filteredNumbersMap   = new Map<Id, Number__C>();
            List<Number__c> provisionedNumbersList  = new List<Number__c>();
            List<Number__c> disconnectedNumbersList = new List<Number__c>();
            Set<Id> relatedNumberGroupList          = new Set<Id>();  // EDGE-204050 @APPLE
            for(Id numberId : newMap.keySet() ){
                Number__C n = newMap.get(numberId);
                 //check if Mobile__c = ‘Fixed’ and Status in ‘Provisioned’,'Bill Readiness In Progress','Error','Active','Inactive','Disconnect Pending','Disconnect In Progress'
                if(oldMap.get(numberId).Status__c != n.Status__c && (n.Mobile__c == 'Fixed' || (n.Mobile__c =='Mobile' && n.Pattern_Type__c == 'Number')) && n.Subscription_number__c != null
                    && n.Status__c !=null && (n.Status__c.equalsIgnoreCase('Provisioned')
                        || n.Status__c.equalsIgnoreCase('Bill Readiness In Progress') 
                        || n.Status__c.equalsIgnoreCase('Error')
                        || n.Status__c.equalsIgnoreCase('Active') 
                        || n.Status__c.equalsIgnoreCase('Inactive')
                        || n.Status__c.equalsIgnoreCase('Disconnect Pending') 
                        || n.Status__c.equalsIgnoreCase('Disconnect In Progress')
                        || n.Status__c.equalsIgnoreCase('Disconnected'))) {
    
                            filteredNumbersMap.put(n.Id, n);
                }
                if((n.Mobile__c == 'Fixed' || (n.Mobile__c =='Mobile' && n.Pattern_Type__c == 'Number')) && n.Status__c!=null){
                    // add by Nikhil as part of EDGE-202844 
                    if(String.isNotBlank(n.Service_Number__c) && String.isNotBlank(n.Subscription_number__c)
                       && n.Status__c.equalsIgnoreCase('Provisioned') && n.Invoke_BDS_Notification__c == true
                       && ((oldMap.get(numberId).Status__c != n.Status__c) ||
                       (oldMap.get(numberId).Invoke_BDS_Notification__c != n.Invoke_BDS_Notification__c))){
                        provisionedNumbersList.add(n);
                    }
                    // add by Nikhil as part of EDGE-202844 
                    if(n.Status__c.equalsIgnoreCase('Disconnected') 
                        && oldMap.get(numberId).Status__c != n.Status__c && String.isNotBlank(n.Service_Number__c)){
                        disconnectedNumbersList.add(n);
                    }
                }
                relatedNumberGroupList.add(n.Number_Group__c); //  EDGE-204050
            }
            system.debug('filteredNumbersMap'+filteredNumbersMap);
            if(filteredNumbersMap.size()>0){
                processNumbers(filteredNumbersMap);
            }
            // add by Nikhil as part of EDGE-202844 
            if(provisionedNumbersList.size()>0){
                pushNumbersToBDS(provisionedNumbersList,'Provisioned');
            }        
            // add by Nikhil as part of EDGE-202844 (6b)
             if(disconnectedNumbersList.size()>0){
                pushNumbersToBDS(disconnectedNumbersList,'Disconnected');
            }
    
            // added by vivek as part of EDGE-204050
            if(relatedNumberGroupList.size()>0){
    
               updateNumberGroupStatus( relatedNumberGroupList,false, newMap );
            }
        }
    
    
         // added by vivek as part of EDGE-204050 : start
        public static void handleAfterDelete(Map<Id, Number__C> oldMap){
            Set<Id> disconnectedNumberGroupId        = new Set<Id>();  // EDGE-204050 @APPLE
            for( Number__c num : oldMap.values()){
                disconnectedNumberGroupId.add(num.Number_Group__c);
            } 
    
                updateNumberGroupStatus(disconnectedNumberGroupId,true, oldMap);
        } 
    
         // added by vivek as part of EDGE-204050 : end
    
    /**************************************************************************************
    ***************************************************************************************/
        public static void handleBeforeUpdate(Map<Id, Number__c> newMap, Map<Id, Number__c> oldMap){
           for( Number__c num : newMap.values()){
               if( num.Status__c == 'Active' || num.Status__c == 'Inactive'){
                   if( num.IsDisconnected__c == true ){
                       num.IsDisconnected__c = false;
                   }
               }
           }
        }
       
    /**************************************************************************************
    ****** Desc         : Method to process numbers which qualifies after insert/after update filters
    ****** Story        : EDGE-138136
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
    
        private static void processNumbers(Map<Id, Number__C> newMap){
            Map<Id, List<Number__c>> mapNumberGroupToNumber = new Map<Id, List<Number__c>>();
            // create a map of number group and list of numbers associated to it
            for(Number__c n : newMap.values()){
                List<Number__c> lst = new List<Number__c>();
                if(n.Number_Group__c !=null){
                    if(mapNumberGroupToNumber.containsKey(n.Number_Group__c)) {
                        lst = mapNumberGroupToNumber.get(n.Number_Group__c);
                    } 
                    lst.add(n);
                    mapNumberGroupToNumber.put(n.Number_Group__c, lst);
                }
            }
            //}
            if(mapNumberGroupToNumber.size()>0){
                // get platform event object list from numbers
                List<PublishNumberStatusChanges__e> listNumberEvent = getPublishNumberStatusChangeEventList(mapNumberGroupToNumber);
                if(listNumberEvent.size()>0){
                    // publish platform events
                    publishNumberStatusChanges(listNumberEvent);
                }
            }
        }
    
    /**************************************************************************************
    ****** Desc         : Method to create list of platform event objects from the numbers
    ****** Story        : EDGE-138136
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
        private static List<PublishNumberStatusChanges__e> getPublishNumberStatusChangeEventList(Map<Id, List<Number__c>> mapEventDetail) {
            // List to hold event objects to be published.
            List<PublishNumberStatusChanges__e> listNumberEvent = new List<PublishNumberStatusChanges__e>();
            Map<Id,Number_Group__c> mapOfNumberGroup = new Map<Id,Number_Group__c>([SELECT Id,Name,Transition_Id__c From Number_Group__c WHERE Id In : mapEventDetail.keySet()]);
            String payload = '';
            for(Id numberGroup : mapEventDetail.keySet()){
                // get payload from number object
                Number_Group__c numberGroupRecord = mapOfNumberGroup.get(numberGroup);
                payload = getPayload(numberGroupRecord.Transition_Id__c,mapEventDetail.get(numberGroup));
                system.debug('##Platform Event Payload:'+ payload);
                // allow payloads with length smaller than 131000
                if(payload.length()>131000){
                    System.debug('Payload size is outside the allowed size. Expected - 131000, Actual - '+payload.length());
                } else {
                    // Create event objects.
                    PublishNumberStatusChanges__e numberEvent = new PublishNumberStatusChanges__e(
                                Object_Name__c = 'Number',
                                Number_Group__c = numberGroupRecord.Name,
                                Payload__c = payload
                                );
                    // Add event objects to the list.
                    listNumberEvent.add(numberEvent);
                }
            }
            system.debug('##Platform Event records:'+ String.valueOf(listNumberEvent));
            return listNumberEvent;
        }
    
    /**************************************************************************************
    ****** Desc         : Method to prepare payload of platform event
    ****** Story        : EDGE-138136
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
        private static string getPayload(String transitionId, List<Number__c> listNumber){
            List<NumberPayloadWrapper> listPayload = new List<NumberPayloadWrapper> ();
            List<NumberWrapperMobile> listPayloadMobile = new List<NumberWrapperMobile> ();
                for(Number__c n : listNumber){
                    if(n.Mobile__c =='Mobile' && n.Pattern_Type__c == 'Number')   //DIGI-9672
                    {
                    listPayloadMobile.add(new NumberWrapperMobile(n.Subscription_number__c,
                                                            n.Service_Id__c,
                                                            n.Service_Number__c,
                                                            n.Status__c,
                                                            n.Sim_Serial_Number__c,
                                                            n.IMSI__c,
                                                            n.External_Id__c,
                                                            n.Service_Instance_Id__c)
                                    );
                    } 
                    else {
                    listPayload.add(new NumberPayloadWrapper(n.Subscription_number__c,
                                                                n.Service_Id__c,
                                                                n.Service_Number__c,
                                                                n.Service_Instance_Id__c,
                                                                n.Status__c,
                                                                transitionId)
                                        );       
                    }     
                } 
                if(listPayloadMobile.size()>0){
                    return JSON.serialize(listPayloadMobile);
                }                
            return JSON.serialize(listPayload);
        }
    
    /**************************************************************************************
    ****** Desc         : Method to publish platform events
    ****** Story        : EDGE-138136
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
        private static void publishNumberStatusChanges(List<PublishNumberStatusChanges__e> listNumberEvent){
            List<string> uuidList = new List<string>();
            Logger2 logger = Logger2.getLogger('NumberTriggerHandler');
            // Call method to publish events.
            List<Database.SaveResult> results = EventBus.publish(listNumberEvent);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if(sr.isSuccess()) {
                    uuidList.add(EventBus.getOperationId(sr));
                }
            }
            logger.logMessages(JSON.serialize(listNumberEvent), JSON.serialize(results), '', '', '', '', false, false, null, null, null, null);
            logger.exitLogger();
        }
    
    /**************************************************************************************
    ****** Desc         : EDGE-202844 Push Provisioned Number To BDS Service Microservice 
    ****** Story        : EDGE-138136
    ****** Developer    : Nikhil Sharma
    ***************************************************************************************/
        private static void pushNumbersToBDS(List<Number__c> numbersList, String statusType){
            System.enqueueJob(new NumberProvisionedQueueable(numbersList,statusType));
        }
    
    /**************************************************************************************
    ****** Desc         : EDGE-204050 Update Number Group Status if all numbers are disconnected
    ****** Story        : EDGE-204050
    ****** Developer    : Vivek ; Apple
    ***************************************************************************************/
    
        private static void updateNumberGroupStatus( Set<Id> numbersGroupIdSet,Boolean isDelete , Map<Id, Number__c>numberMap){
            Map<Id, Integer> NumberGroupToRelatedNumbers        = new Map<Id, Integer>();
            List<Number_Group__c> numberGroupListToUpdate       = new List<Number_Group__c>();
            List<Number_Group__c> numberGroupListToDelete       = new List<Number_Group__c>();
    
    
            List<Number_Group__c> numberGroupList = [ SELECT Id , Status__c , ( SELECT Id,Status__c,IsDisconnected__c FROM Numbers__r) from Number_Group__c where id in: numbersGroupIdSet ];
            
            for( Number_Group__c ng : numberGroupList ){
                if ( ng.Numbers__r != null &&  ng.Numbers__r.size() > 0 ){
                    Integer n = Integer.valueOf(ng.Numbers__r.size());
                    NumberGroupToRelatedNumbers.put( ng.Id , n );
                }else{
                    numberGroupListToDelete.add(  ng );
                }
                Integer countDisconnectdNumber  = 0;
                Integer countActiveNumber       = 0;
                Integer countInActiveNumber     = 0;
    
                for( Number__c num : ng.Numbers__r ){
    
                    if( numberMap.containsKey(num.Id) &&( numberMap.get(num.Id).Status__c == 'Disconnected' || numberMap.get(num.Id).IsDisconnected__c == true)) {
                        countDisconnectdNumber = countDisconnectdNumber + 1;
                    }else if( numberMap.containsKey(num.Id)  && numberMap.get(num.Id).Status__c == 'Active' ){
                        countActiveNumber = countActiveNumber + 1;
                    }else if( numberMap.containsKey(num.Id)  && numberMap.get(num.Id).Status__c == 'Inactive'){
                        countInActiveNumber = countInActiveNumber + 1;
                    }
                   else{
                       // @APPLE edge-222728 : Using Number List to loop as Map might not have all numbers changed at once. : start
                       if( num.Status__c == 'Disconnected' || num.IsDisconnected__c == true) {
                            countDisconnectdNumber = countDisconnectdNumber + 1;
                        }else if( num.Status__c == 'Active' ){
                            countActiveNumber = countActiveNumber + 1;
                        }else if( num.Status__c == 'Inactive'){
                            countInActiveNumber = countInActiveNumber + 1;
                        }
                        // @APPLE edge-222728 : Using Number List to loop as Map might not have all numbers changed at once. : end
                    } 
                }
                System.debug('countDisconnectdNumber --> ' + countDisconnectdNumber);
                if ( NumberGroupToRelatedNumbers.containsKey(ng.Id) && NumberGroupToRelatedNumbers.get( ng.Id ) == countDisconnectdNumber ) {
                    ng.Status__c = 'Disconnected';
                    numberGroupListToUpdate.add(ng);
                }else if( NumberGroupToRelatedNumbers.containsKey(ng.Id) && NumberGroupToRelatedNumbers.get( ng.Id ) == countActiveNumber ) {
                    ng.Status__c = 'Active';
                    numberGroupListToUpdate.add(ng);
                }else if( NumberGroupToRelatedNumbers.containsKey(ng.Id) && NumberGroupToRelatedNumbers.get( ng.Id ) == countInActiveNumber ) {
                    ng.Status__c = 'Inactive';
                    numberGroupListToUpdate.add(ng);
                }
            }
            
            if ( numberGroupListToUpdate.size() > 0){
                update numberGroupListToUpdate;
            }
    
            if ( numberGroupListToDelete.size() >  0 && isDelete) {
                delete numberGroupListToDelete;
            }
        }
    
        public class NumberPayloadWrapper {
            public string Subscription_Number {get; set;}
            public string Service_Id {get; set;}
            public string Service_Number {get; set;}
            public string Correlation_Id {get; set;}
            public string Status {get; set;}
            public string Transition_Id {get; set;}
 
            public NumberPayloadWrapper(string subscriptionNumber, string serviceId, string serviceNumber, string correlationId, string status, string transitionId){
                this.Subscription_Number = subscriptionNumber;
                this.Service_Id = serviceId;
                this.Service_Number = serviceNumber;
                this.Correlation_Id = correlationId;
                this.Status= status;
                this.Transition_Id = transitionId;
            }
        }
 //DIGI-9672
        public class NumberWrapperMobile{
            public string Subscription_Number {get; set;}
            public string Service_Id {get; set;}
            public string Service_Number {get; set;}
            public string Status {get; set;}
            public string SIMSerialNumber {get; set;}
            public string IMSI {get; set;}
            public string GUID {get; set;}
			public string Correlation_Id {get; set;}
    
            public NumberWrapperMobile(string subscriptionNumber, string serviceId, string serviceNumber, string status, string SIMSerialNumber, string IMSI, string GUID, string Correlation_Id){
                this.Subscription_Number = subscriptionNumber;
                this.Service_Id = serviceId;
                this.Service_Number = serviceNumber;
                this.Status= status;
                this.SIMSerialNumber = SIMSerialNumber;
                this.IMSI = IMSI;
                this.GUID = GUID;
				this.Correlation_Id = Correlation_Id;
            }
        }
        
    }