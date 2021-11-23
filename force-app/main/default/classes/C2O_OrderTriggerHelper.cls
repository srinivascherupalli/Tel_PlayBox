public class C2O_OrderTriggerHelper { 
    @testVisible private static List<OrderGenerationMSEvent__e> orderEventList = new List<OrderGenerationMSEvent__e>();
    @testVisible private static boolean testException = false;
    static String CONST_INTERFACENAME = 'OrderCustomTriggerHandler';
    static String correlationId = GuidUtil.NewGuid();
    public static boolean isRecursive = false;//EDGE-222343
    public static String SEU_PROFILE_NAME = 'Sales-Enterprise-Unified';
    
    public static void invokeOrderNotification(Set<Id> setOfOrderId, Boolean isCompleted){
        
        try{
            List<csord__Order__c> listOfOrder = getListOfOrder(setOfOrderId);
            List<Id> listOfOrderId = new List<Id>();
            //DIGI-19162 : Initializing a Map to store order and its corresponding status
            Map<Id,String> orderStatusMap = new Map<Id,String>();
            
            for(csord__Order__c order : listOfOrder){
                if(String.isBlank(order.csordtelcoa__Opportunity__c) || 
                   ( String.isNotBlank(order.csordtelcoa__Opportunity__c) &&
                    order.csordtelcoa__Opportunity__r <> NULL && order.csordtelcoa__Opportunity__r.Type <> NULL && 
                    !order.csordtelcoa__Opportunity__r.Type.equalsIgnoreCase(C2O_OrderConstants.OPP_TYPE_MIGRATION))){  
                        listOfOrderId.add(order.Id);
                        orderStatusMap.put(order.Id,order.csord__Status2__c);
                    }
            }
            //DIGI-19162 : Commented the code as part the story
            /*if(!listOfOrderId.isEmpty()){
                if(isCompleted){
                    OrderCompletionEmailServiceWrapper.processOrderRecord(listOfOrderId);
                } else{
                    OrderEmailServiceWrapper.processOrderRecord(listOfOrderId);
                }
            }*/
            if(!orderStatusMap.isEmpty()){
                    OrderEmailServiceWrapper.processOrderRecordFrmTrigger(orderStatusMap);
                }
        } catch(Exception e){
            PRMUtilityClass.createException(e);
        } 
        
    }
    
    public class ChatterNotificationForReadyForSubmit implements Queueable {
        public List<csord__Order__c> listOfOrder;
        public Boolean isPartnerNetwork;
        
        public ChatterNotificationForReadyForSubmit (Set<Id> setOfOrderId, Boolean isPartnerNetwork){
            this.isPartnerNetwork = isPartnerNetwork;
            this.listOfOrder = getListOfOrder(setOfOrderId);
        }
        
        public void execute(QueueableContext context) {
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            Set<String> setOfPRMProfile = new Set<String>{C2O_OrderConstants.PROFILE_NAME_PCU_AUSTRALIA, C2O_OrderConstants.PROFILE_NAME_PRM_ADMIN_AUSTRALIA};
                String networkId = this.isPartnerNetwork ? C2O_OrderConstants.EDGE_PARTNERS_NETWORKID : Network.getNetworkId();
            
            for(csord__Order__c order : this.listOfOrder){
                String ownerProfileName = order?.Owner?.Profile?.Name;
                if(String.isNotBlank(ownerProfileName)){
                    if((!this.isPartnerNetwork && ownerProfileName.equalsIgnoreCase(C2O_OrderConstants.PROFILE_NAME_SEU)) ||
                       (this.isPartnerNetwork && setOfPRMProfile.contains(ownerProfileName))){
                           ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(createChatterPostForReadyForSubmit(order));
                           batchInputs.add(batchInput);
                       }
                }
                if(batchInputs.size() == 500){
                    ConnectApi.ChatterFeeds.postFeedElementBatch(networkId, batchInputs);
                    batchInputs = new List<ConnectApi.BatchInput>();
                }
            }
            try{
                if(!batchInputs.isEmpty()){
                    ConnectApi.ChatterFeeds.postFeedElementBatch(networkId, batchInputs);
                }
            }catch(Exception ex){
                PRMUtilityClass.createException(ex);
            }
        }
    }
    
    @testVisible
    private static ConnectApi.FeedItemInput createChatterPostForReadyForSubmit(csord__Order__c order){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = order.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        messageSegments = PRMUtilityClass.addMentionSegment(order.OwnerId, messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(order?.csord__Order_Number__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' for ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(order?.csord__Account__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' is now in Ready for Submit status.', messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Order URL: ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(order?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(order?.Id, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }
    
    public static List<csord__Order__c> getListOfOrder(Set<Id> setOfOrderId){
        return [SELECT Id, csordtelcoa__Opportunity__c, csordtelcoa__Opportunity__r.Type, Owner.Profile.Name, OwnerId, csord__Order_Number__c,
        csord__Status2__c, csord__Account__c, Base_URL__c FROM csord__Order__c WHERE Id IN :setOfOrderId];
    }
    
    //Method to publish orderGeneration event on status change
    public static void generateOrderMSEvent(List<csord__Order__c> orderNewList){
        //EDGE-222343
        if(!isRecursive){
            isRecursive = true;
            //String orderInitialState = csordtelcoa__Orders_Subscriptions_Options__c.getInstance().csordtelcoa__Order_Initial_State__c;
            
            
            try{
                for(csord__Order__c order: [select id,csord__Account__r.CIDN__c,csord__Order_Number__c,
                                            csord__Status2__c,referenceNumber__c
                                            from csord__Order__c where id in:orderNewList]){
                                                
                                                //if(order.csord__Status2__c != oldMap.get(order.id).csord__Status2__c && oldMap.get(order.id).csord__Status2__c !=null && order.csord__Status2__c !=orderInitialState){
                                                
                                                orderEventList.add(OrderCustomTriggerHelper.createEvent(order));
                                                
                                                //}
                                            }
                
                if(Test.isRunningTest() && testException){
                    Integer i=1/0;
                }
                if(!orderEventList.isEmpty()){
                    List<Database.SaveResult> results = EventBus.publish(orderEventList);
                    for(Database.SaveResult sr : results){
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()){
                                
                                GenericUtilityClass.logException('OrderCustomTriggerHandler','generateOrderMSEvent','',correlationId,err.getMessage() + '-' + err.getStatusCode(),'Exception occured during order event publishing',C2O_ExceptionHandler.Capability.ORD);
                                
                            }
                        }       
                    }
                }  
            }
            catch(Exception e){
                
                GenericUtilityClass.logException('OrderCustomTriggerHandler','generateOrderMSEvent','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during order event publishing',C2O_ExceptionHandler.Capability.ORD);
            }
        }
    }
    
        /********************************************************************************************************************************************
    * Method Name:  postChatterNotification
    * Description:  Post chatter notification based on order status. This method is called from OrderCustomTrigger
    * Edge - 215986
    ********************************************************************************************************************************************/     
    public static void postChatterNotification(List<csord__Order__c> orderNewList,Map<Id,csord__Order__c> oldOrderMap){
        
        Sync_Control_and_Constants__c syncConstMap = new Sync_Control_and_Constants__c();
        try{
            syncConstMap = Sync_Control_and_Constants__c.getValues('Order_Chatter_Notification');
            OrderCustomTriggerHelper.postChatterNotification(orderNewList,oldOrderMap,syncConstMap);
            
            
        }catch(Exception e) {
            GenericUtilityClass.logException(CONST_INTERFACENAME,'postChatterNotification','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while posting chatter notification',C2O_ExceptionHandler.Capability.ORD);
            
        }        
    }
    
    public static void createPostForNewOpportunityTeamMember(List<csord__Order__c> orderNewList){
        try{            
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();  
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();  
            
            for(csord__Order__c ord : [Select Id,csord__Account__r.Name,OwnerId,csord__Order_Number__c,Owner.Profile.Name From csord__Order__c WHere Id IN :orderNewList]){ 
                //Create Chatter post   
                if(SEU_PROFILE_NAME.equalsIgnoreCase(ord.Owner.Profile.Name)){
                    mentionSegmentInput.id = ord.OwnerId;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);                 
                    textSegmentInput.text = '\n' + ord.csord__Order_Number__c  + ' for' + ord.csord__Account__r.Name + 'is now in Ready for Submit status' + '\n' + '\n' +
                        'Order URL:' +  URL.getSalesforceBaseUrl().toExternalForm() + '/'+ord.Id;  
                    messageBodyInput.messageSegments.add(textSegmentInput);                 
                    feedItemInput.body = messageBodyInput;
                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                    feedItemInput.subjectId = ord.Id;                 
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                }   
                
            } 
        }catch(Exception Ex){
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage()); 
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }    
    }
}