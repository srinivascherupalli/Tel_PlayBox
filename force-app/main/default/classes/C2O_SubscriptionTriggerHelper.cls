/********************************************************************************
* Class Name  : C2O_SubscriptionTriggerHelper
* Description : Subscription Trigger Helperruns logic on Subscription records which are filtered
*               based on certain filter conditions which are defined in handler
* Created By  : Sudheendra
* Change Log  : 06 May 2021: Created
********************************************************************************/
public class C2O_SubscriptionTriggerHelper {
    Public Static Date todaysDate = Date.today();
    Public Static DateTime todaysDatetime = (DateTime) Date.today();
    Public Static DateTime systemNow = System.now();
    
   
    @testVisible
    public static Boolean doChainJob = true;
    private static String correlationId = GuidUtil.NewGuid();	
    private static final String CONST_INTERFACENAME = 'C2O_SubscriptionTriggerHelper';	
    public static List<BDS_Notify_Settings__c> allBDSNotifySettings = BDS_Notify_Settings__c.getall().values();

    public static void updateActivationDetails(List <csord__Subscription__c> relacedSubscriptionList) {
        for(csord__Subscription__c relacedSubscription:  relacedSubscriptionList) {
            relacedSubscription.Completion_Date__c = systemNow;
            relacedSubscription.Initial_Activation_DateTime__c = systemNow;
            relacedSubscription.initialActivationDate__c = todaysDate;
        }
    }

    public static void updateCompletionDate(List <csord__Subscription__c> paidOutSubscriptionList) {
        for(csord__Subscription__c paidOutSubscription:  paidOutSubscriptionList) {
        // SS    paidOutSubscription.Completion_Date__c = todaysDatetime;
              paidOutSubscription.Completion_Date__c = systemNow;  
        }
    }
    public static void updateDeactivationDetails(List <csord__Subscription__c> inactiveSubscriptionList) {
        for(csord__Subscription__c inactiveSubscription:  inactiveSubscriptionList) {
        
            inactiveSubscription.Completion_Date__c = systemNow;
            inactiveSubscription.initialActivationDate__c = inactiveSubscription.initialActivationDate__c;

            
            if(inactiveSubscription.Deactivation_Date__c == null) {
                inactiveSubscription.Deactivation_Date__c = systemNow ;
            }
        }
    }
    public static void updateFirstActivatedDetails(List <csord__Subscription__c> nonBlankReplacedSubscrList) {
        for(csord__Subscription__c nonBlankReplacedSubscr:  nonBlankReplacedSubscrList) {
            nonBlankReplacedSubscr.initialActivationDate__c = todaysDate;
        }
    }

    //Added by P.M
    public static void postChatterForSubscriptionOrder(Set<Id> setOfSubscriptionId) {
        List<csord__Subscription__c> listOfSubscription = getListOfSubscription(setOfSubscriptionId);

        if(!listOfSubscription.isEmpty()) {
            Map<Id,AdaptiveCareChatterWrapper> mapAccountIdVsAdaptiveCareChatterWrapper = new Map<Id,AdaptiveCareChatterWrapper>();

            for(csord__Subscription__c subscription : listOfSubscription) {
                if( subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Type <> NULL && 
                    !subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Type?.equalsIgnoreCase(C2O_OrderConstants.STATUS_MIGRATION) &&
                	subscription?.MarketableOffer__r?.Offer_ID__c <> NULL && 
                    subscription?.MarketableOffer__r?.Offer_ID__c?.equalsIgnoreCase(Label.Adaptive_Care_Marketable_Offer) &&
                    subscription?.csordtelcoa__Product_Configuration__r?.cscfga__Product_Definition__r?.product_Specification__c <> NULL && 
                	subscription?.csordtelcoa__Product_Configuration__r?.cscfga__Product_Definition__r?.product_Specification__c?.equalsIgnoreCase(Label.Adaptive_Care_Product_Specification)) {
                    
                    AdaptiveCareChatterWrapper wrapper = new AdaptiveCareChatterWrapper();
                    wrapper.newOrderOrNot = subscription?.toBeCancelled__c?.equalsIgnoreCase(C2O_OrderConstants.FALSE_STRING) ? true : false;
                    wrapper.billingAccountNumber = subscription?.Billing_Account__r?.Billing_Account_Number__c;
                    mapAccountIdVsAdaptiveCareChatterWrapper.put(subscription.csord__Account__c, wrapper);
                }
            }

            if(!mapAccountIdVsAdaptiveCareChatterWrapper.isEmpty() && !System.isQueueable()) {
                System.enqueueJob(new AdaptiveCareChatter(mapAccountIdVsAdaptiveCareChatterWrapper));
            }
        }
    }

    //Added by P.M
    public static void tenacyIdUpdate(Set<Id> setOfSubscriptionId) {
        List<csord__Subscription__c> listOfSubscription = getListOfSubscription(setOfSubscriptionId);
        List<String> listOfOrderIdVsTenacyId = new List<String>();

        for(csord__Subscription__c subscription : listOfSubscription) {
            
            String tenacyId = String.isNotBlank(subscription.TenancyID__c) ? subscription.TenancyID__c : C2O_OrderConstants.FALSE_STRING;
            
            if(String.isNotBlank(subscription.TenancyID__c) && subscription?.MarketableOffer__r?.Offer_ID__c == C2O_OrderConstants.DMCAT_OFFER_000681) {
               
                listOfOrderIdVsTenacyId.add(subscription.csord__Order__c + C2O_OrderConstants.SEPERATOR + tenacyId);
            
            } else if( subscription.csord__Status__c <> NULL && subscription.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.STATUS_ACTIVE) &&
                	   subscription?.MarketableOffer__r?.Offer_ID__c == C2O_OrderConstants.DMCAT_OFFER_000750) {
                           
                listOfOrderIdVsTenacyId.add(subscription.csord__Order__c + C2O_OrderConstants.SEPERATOR + tenacyId);
            }
        }

        if(!listOfOrderIdVsTenacyId.isEmpty() && !System.isQueueable()) {
            System.enqueueJob(new TenancyIdUpdate_TmdmMsPsQueueable(listOfOrderIdVsTenacyId));
        }
    }

    //Added by P.M
    //Added this logic because existing functionality is not bulkify
    public class TenancyIdUpdate_TmdmMsPsQueueable implements Queueable {
        public List<String> listOfOrderIdVsTenacyId;
        
        public TenancyIdUpdate_TmdmMsPsQueueable(List<String> listOfOrderIdVsTenacyId) {
            this.listOfOrderIdVsTenacyId = listOfOrderIdVsTenacyId;
        }

        public void execute(QueueableContext context) {
            List<String> listOfTmpOrderIdVsTenacyId = new List<String>();

            for (Integer i = 0; i < this.listOfOrderIdVsTenacyId.size(); i++) {
                if(i < 50) {
                    TenancyIdUpdate_TmdmMsPs.updateTenancyId(new List<String>{this.listOfOrderIdVsTenacyId.get(i)});
                } else {
                    listOfTmpOrderIdVsTenacyId.add(this.listOfOrderIdVsTenacyId.get(i));
                }
            }
            if(!listOfTmpOrderIdVsTenacyId.isEmpty()) {
                System.enqueueJob(new TenancyIdUpdate_TmdmMsPsQueueable(listOfTmpOrderIdVsTenacyId));
            }
        }
    }

    //Added by P.M
    public class AdaptiveCareChatter implements Queueable {
        public Map<Id,AdaptiveCareChatterWrapper> mapAccountIdVsAdaptiveCareChatterWrapper;
        public List<Partner_of_Record__c> listOfPartnerOfRecord;

        public AdaptiveCareChatter(Map<Id,AdaptiveCareChatterWrapper> mapAccountIdVsAdaptiveCareChatterWrapper) {
            this.mapAccountIdVsAdaptiveCareChatterWrapper = mapAccountIdVsAdaptiveCareChatterWrapper;
            this.listOfPartnerOfRecord = getListOfPartnerOfRecord(this.mapAccountIdVsAdaptiveCareChatterWrapper.keySet());
        }

        public void execute(QueueableContext context) {
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

            if(!this.listOfPartnerOfRecord.isEmpty()) {

                for(Partner_of_Record__c partnerOfRecord : this.listOfPartnerOfRecord) {
                    AdaptiveCareChatterWrapper adaptiveCareChatterInfo = this.mapAccountIdVsAdaptiveCareChatterWrapper?.get(partnerOfRecord.Customer__c);
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(createChatterPost(partnerOfRecord, adaptiveCareChatterInfo, partnerOfRecord?.Customer__r?.OwnerId, false));
                    batchInputs.add(batchInput);
                    batchInput = new ConnectApi.BatchInput(createChatterPost(partnerOfRecord, adaptiveCareChatterInfo, partnerOfRecord?.Partner__r?.OwnerId, true));
                    batchInputs.add(batchInput);
                    if(batchInputs.size() == 500) {
                        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                        batchInputs = new List<ConnectApi.BatchInput>();
                    }
                }

                try{
                    if(!batchInputs.isEmpty()) {
                        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                    }
                } catch(Exception ex) {
                    PRMUtilityClass.createException(ex);
                }
            }
        }
    }

    //Added by Sudheendra
    public class OrderNotificationWithNetworkWrapper implements Queueable {
        public Map<Id,String> mapSubIdVsNotificationWithWrapper;
        public List<csord__Subscription__c> listOfSubscription;

        public OrderNotificationWithNetworkWrapper (Map<Id,String> mapSubIdVsNotificationWithWrapper, Boolean isPartnerNetwork) {
            this.mapSubIdVsNotificationWithWrapper = mapSubIdVsNotificationWithWrapper;
            this.listOfSubscription = getListOfSubscription(this.mapSubIdVsNotificationWithWrapper.keyset());
        }

        public void execute(QueueableContext context) {

            List<ConnectApi.BatchInput> batchInputsPRM = new List<ConnectApi.BatchInput>();
            List<ConnectApi.BatchInput> batchInputsCRM = new List<ConnectApi.BatchInput>();

            for(csord__Subscription__c subscription : this.listOfSubscription) {
                String notificationType = this.mapSubIdVsNotificationWithWrapper?.get(subscription.Id);
                // Get the list of Chatter feed input messages based on the status value
                List<ChatterFeedNetworkIdWrapper> listOfFeedItemInputWrapper = getChatterBodyWrapperBasedOnNotification(subscription, notificationType);
                system.debug('@@listOfFeedItemInputWrapper:'+listOfFeedItemInputWrapper);
                if(!listOfFeedItemInputWrapper.isEmpty()) {
                    for(ChatterFeedNetworkIdWrapper feedInpWrap: listOfFeedItemInputWrapper) {
                        
                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedInpWrap.chatterFeed);
                        if(feedInpWrap.isPartnerNetwork) {
                            batchInputsPRM.add(batchInput);
                        }
                        else{
                            batchInputsCRM.add(batchInput);
                        }
                    }
                }
                if(batchInputsPRM.size() == 500) {
                    ConnectApi.ChatterFeeds.postFeedElementBatch(C2O_OrderConstants.EDGE_PARTNERS_NETWORKID, batchInputsPRM);
                    batchInputsPRM = new List<ConnectApi.BatchInput>();
                }
                 if(batchInputsCRM.size() == 500) {
                    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputsCRM);
                    batchInputsCRM = new List<ConnectApi.BatchInput>();
                }
            }

            try{
                if(!batchInputsCRM.isEmpty()) {
                        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputsCRM);
                }
                if(!batchInputsPRM.isEmpty()) {
                        ConnectApi.ChatterFeeds.postFeedElementBatch(C2O_OrderConstants.EDGE_PARTNERS_NETWORKID, batchInputsPRM);
                }

            } catch(Exception ex) {
                PRMUtilityClass.createException(ex);
            }
        }
    }
    
    //Added by Sudheendra
    
    private static List<ChatterFeedNetworkIdWrapper> getChatterBodyWrapperBasedOnNotification(csord__Subscription__c subscription, String notificationType) {
        Set<String> setOfCRMProfile = new Set<String>{C2O_OrderConstants.PROFILE_NAME_ASA, C2O_OrderConstants.PROFILE_NAME_SEU, C2O_OrderConstants.PROFILE_NAME_SEB};
        Set<String> setOfPRMProfile = new Set<String>{C2O_OrderConstants.PROFILE_NAME_PCU_AUSTRALIA, C2O_OrderConstants.PROFILE_NAME_PRM_ADMIN_AUSTRALIA};
        String orderOwnerProfileName = subscription?.csord__Order__r?.Owner?.Profile?.Name;
        String accountOwnerProfileName = subscription?.csord__Account__r?.Owner?.Profile?.Name;
        String oppOwnerProfileName = subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.Profile?.Name;
        String accountOwnerId = subscription?.csord__Account__r?.OwnerId;
        String oppOwnerId = subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.OwnerId;
        
        List<ChatterFeedNetworkIdWrapper> listofFeedItemWrapper = new List<ChatterFeedNetworkIdWrapper>();
        system.debug('@@accountOwnerProfileName:'+accountOwnerProfileName);
        system.debug('@@oppOwnerProfileName:'+oppOwnerProfileName);
    
        if(notificationType == C2O_OrderConstants.STAGE_READY_FOR_USE) {
            if(String.isNotBlank(accountOwnerProfileName) && String.isNotBlank(oppOwnerProfileName)) {
                if(setOfCRMProfile.contains(accountOwnerProfileName) || setOfCRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItemWrapper.add(createCrmUsersReadyForUseFeed(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                } else if(setOfPRMProfile.contains(accountOwnerProfileName) || setOfPRMProfile.contains(oppOwnerProfileName)){
                    listofFeedItemWrapper.add(createPrmUsersReadyForUseAccFeed(subscription));
                    listofFeedItemWrapper.add(createPrmUsersReadyForUseOppFeed(subscription));
                } else if(setOfPRMProfile.contains(accountOwnerProfileName) || setOfCRMProfile.contains(oppOwnerProfileName)){
                    listofFeedItemWrapper.add(createCrmUsersReadyForUseFeed(subscription, new Set<Id>{ oppOwnerId}));
                    listofFeedItemWrapper.add(createPrmUsersReadyForUseAccFeed(subscription));
                } else if(setOfCRMProfile.contains(accountOwnerProfileName) || setOfPRMProfile.contains(oppOwnerProfileName)){
                    listofFeedItemWrapper.add(createPrmUsersReadyForUseOppFeed(subscription));
                    listofFeedItemWrapper.add(createCrmUsersReadyForUseFeed(subscription, new Set<Id>{ accountOwnerId}));
                }
            }
        }
        return listofFeedItemWrapper;
    }
    
        //Added by sudheendra
    private static ChatterFeedNetworkIdWrapper createPrmUsersReadyForUseOppFeed(csord__Subscription__c subscription){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription?.csord__Order__r?.csordtelcoa__Opportunity__c;
        
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;   
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.FirstName, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.LastName, messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);        
        messageSegments = PRMUtilityClass.addTextSegment('Provisioning of ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' for ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' is complete, operational and ready to bill at  ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        ChatterFeedNetworkIdWrapper chatterWrap =new ChatterFeedNetworkIdWrapper(feedItemInput, true);
        return chatterWrap;
    }
    
    
        //Added by sudheendra
    private static ChatterFeedNetworkIdWrapper createPrmUsersReadyForUseAccFeed(csord__Subscription__c subscription){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription?.csord__Account__c;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;   
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Owner?.FirstName, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Owner?.LastName, messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);        
        messageSegments = PRMUtilityClass.addTextSegment('Provisioning of ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' for ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' is complete, operational and ready to bill at  ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        ChatterFeedNetworkIdWrapper chatterWrap =new ChatterFeedNetworkIdWrapper(feedItemInput, true);
        return chatterWrap;
    }
    
    
    
    //Added by sudheendra
    private static ChatterFeedNetworkIdWrapper createCrmUsersReadyForUseFeed(csord__Subscription__c subscription, Set<Id> setOfUserId){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Provisioning of ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' for ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' is complete, operational and ready to bill at  ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        ChatterFeedNetworkIdWrapper chatterWrap =new ChatterFeedNetworkIdWrapper(feedItemInput, false);
        return chatterWrap;
    }
    
    //Added by P.M
    public class OrderNotification implements Queueable {
        public Map<Id,String> mapSubIdVsNotificationType;
        public List<csord__Subscription__c> listOfSubscription;
        public Boolean isPartnerNetwork;

        public OrderNotification (Map<Id,String> mapSubIdVsNotificationType, Boolean isPartnerNetwork) {
            this.mapSubIdVsNotificationType = mapSubIdVsNotificationType;
            this.isPartnerNetwork = isPartnerNetwork;
            this.listOfSubscription = getListOfSubscription(this.mapSubIdVsNotificationType.keyset());
        }

        public void execute(QueueableContext context) {

            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            String networkId = this.isPartnerNetwork ? C2O_OrderConstants.EDGE_PARTNERS_NETWORKID : Network.getNetworkId();

            for(csord__Subscription__c subscription : this.listOfSubscription) {
                String notificationType = this.mapSubIdVsNotificationType?.get(subscription.Id);
                // Get the list of Chatter feed input messages based on the status value
                List<ConnectApi.FeedItemInput> listOfFeedItemInput = getChatterBodyBasedOnNotification(subscription, notificationType, this.isPartnerNetwork);
                system.debug('@@listOfFeedItemInput:'+listOfFeedItemInput);
                if(!listOfFeedItemInput.isEmpty()) {
                    for(ConnectApi.FeedItemInput feedInp: listOfFeedItemInput) {
                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedInp);
                        batchInputs.add(batchInput);
                    }
                }
                if(batchInputs.size() == 500) {
                    ConnectApi.ChatterFeeds.postFeedElementBatch(networkId, batchInputs);
                    batchInputs = new List<ConnectApi.BatchInput>();
                }
            }

            try{
                if(!batchInputs.isEmpty()) {
                        ConnectApi.ChatterFeeds.postFeedElementBatch(networkId, batchInputs);
                        system.debug('Posted..'+batchInputs);
                }
                if(!this.isPartnerNetwork && doChainJob) {
                    System.enqueueJob(new OrderNotification(mapSubIdVsNotificationType, true));
                }
            } catch(Exception ex) {
                PRMUtilityClass.createException(ex);
            }
        }
    }
    
    

    //Added by P.M
    private static List<ConnectApi.FeedItemInput> getChatterBodyBasedOnNotification(csord__Subscription__c subscription, String notificationType, Boolean isPartnerNetwork) {
        Set<String> setOfCRMProfile = new Set<String>{C2O_OrderConstants.PROFILE_NAME_ASA, C2O_OrderConstants.PROFILE_NAME_SEU, C2O_OrderConstants.PROFILE_NAME_SEB};
        Set<String> setOfPRMProfile = new Set<String>{C2O_OrderConstants.PROFILE_NAME_PCU_AUSTRALIA, C2O_OrderConstants.PROFILE_NAME_PRM_ADMIN_AUSTRALIA};
        String orderOwnerProfileName = subscription?.csord__Order__r?.Owner?.Profile?.Name;
        String accountOwnerProfileName = subscription?.csord__Account__r?.Owner?.Profile?.Name;
        String oppOwnerProfileName = subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.Profile?.Name;
        String accountOwnerId = subscription?.csord__Account__r?.OwnerId;
        String oppOwnerId = subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.OwnerId;
        List<ConnectApi.FeedItemInput> listofFeedItem = new List<ConnectApi.FeedItemInput>();
        system.debug('@@accountOwnerProfileName:'+accountOwnerProfileName);
        system.debug('@@oppOwnerProfileName:'+oppOwnerProfileName);
        system.debug('@@isPartnerNetwork:'+isPartnerNetwork);
        if(notificationType == C2O_OrderConstants.DELAY_NOTIFICATION) {
            if(String.isNotBlank(orderOwnerProfileName)) {
                if(setOfCRMProfile.contains(orderOwnerProfileName) || setOfPRMProfile.contains(orderOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForDelayNotification(subscription));
                }
            }

        } else if (notificationType == C2O_OrderConstants.STAGE_OREDR_RECEIVED) {
            if(String.isNotBlank(accountOwnerProfileName) && String.isNotBlank(oppOwnerProfileName)) {
                if(!isPartnerNetwork && setOfCRMProfile.contains(accountOwnerProfileName) && setOfCRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForOrderReceived(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                } else if(isPartnerNetwork && setOfPRMProfile.contains(accountOwnerProfileName) && setOfPRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForOrderReceived(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                } else if(!isPartnerNetwork && setOfPRMProfile.contains(accountOwnerProfileName) && setOfCRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForOrderReceived(subscription, new Set<Id>{oppOwnerId}));
                } else if(isPartnerNetwork && setOfPRMProfile.contains(accountOwnerProfileName) && setOfCRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForOrderReceived(subscription, new Set<Id>{accountOwnerId}));
                } else if(!isPartnerNetwork && setOfCRMProfile.contains(accountOwnerProfileName) && setOfPRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForOrderReceived(subscription, new Set<Id>{oppOwnerId}));
                } else if(isPartnerNetwork && setOfCRMProfile.contains(accountOwnerProfileName) && setOfPRMProfile.contains(oppOwnerProfileName)) {
                    listofFeedItem.add(createChatterPostForOrderReceived(subscription, new Set<Id>{accountOwnerId}));
                }
            }

        } else if(notificationType == C2O_OrderConstants.STAGE_BEING_FULFILLED) {
            if(String.isNotBlank(accountOwnerProfileName) && String.isNotBlank(oppOwnerProfileName)) {
                if(setOfCRMProfile.contains(accountOwnerProfileName) && setOfCRMProfile.contains(oppOwnerProfileName)) {
                    if(!isPartnerNetwork) {
                        listofFeedItem.add(createChatterPostForBeingFulfilled(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                    } else{
                        listofFeedItem.add(createChatterPostForFulfilledAndProvisioned(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                    }
                } else if(setOfPRMProfile.contains(accountOwnerProfileName) && setOfPRMProfile.contains(oppOwnerProfileName)) {
                    if(!isPartnerNetwork) {
                        listofFeedItem.add(createChatterPostFulfilledPRMOpptyOwner(subscription, new Set<Id>{oppOwnerId})); // Partner Network post
                    } else {
                        listofFeedItem.add(createChatterPostFulfilledPRMAccOwner(subscription, new Set<Id>{accountOwnerId}));  // Partner Network post
                    }
                } else if(setOfCRMProfile.contains(oppOwnerProfileName) && setOfPRMProfile.contains(accountOwnerProfileName)) {
                    if(!isPartnerNetwork) {
                        listofFeedItem.add(createChatterPostForFulfilledOptyAccCrmUser(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                    } else {
                        listofFeedItem.add(createChatterPostFulfilledPRMAccOwner(subscription, new Set<Id>{accountOwnerId}));  // Partner Network post
                    }
                } else if(setOfCRMProfile.contains(accountOwnerProfileName) && setOfPRMProfile.contains(oppOwnerProfileName)) {
                    if(!isPartnerNetwork) {
                        listofFeedItem.add(createChatterPostForFulfilledOptyAccCrmUser(subscription, new Set<Id>{accountOwnerId, oppOwnerId}));
                    } else {
                        listofFeedItem.add(createChatterPostFulfilledPRMOpptyOwner(subscription, new Set<Id>{oppOwnerId})); // Partner Network post
                    }
                }
            }
        }
        return listofFeedItem;
    }

    //Added by Sudheendra
    private static ConnectApi.FeedItemInput createChatterPostFulfilledPRMAccOwner(csord__Subscription__c subscription, Set<Id> setOfUserId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.FirstName, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.LastName, messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Order ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' has been entirely provisioned for site ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by Sudheendra
    private static ConnectApi.FeedItemInput createChatterPostFulfilledPRMOpptyOwner(csord__Subscription__c subscription, Set<Id> setOfUserId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.FirstName, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csordtelcoa__Opportunity__r?.Owner?.LastName, messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Order ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Account__r?.Name, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' has been entirely provisioned for site ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by P.M
    private Static ConnectApi.FeedItemInput createChatterPost(Partner_of_Record__c partnerOfRecord, AdaptiveCareChatterWrapper adaptiveCareChatterInfo, String userId, Boolean isPartnerUserOrNot) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = partnerOfRecord.Customer__c;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        messageSegments = PRMUtilityClass.addTextSegment('Hi ', messageSegments);
        messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(', ', messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);

        if(adaptiveCareChatterInfo.newOrderOrNot) {
            if(isPartnerUserOrNot) {
                messageSegments = PRMUtilityClass.addTextSegment('Adaptive Mobility Care has been added to Billing Account ', messageSegments);
                messageSegments = PRMUtilityClass.addTextSegment(adaptiveCareChatterInfo.billingAccountNumber, messageSegments);
                messageSegments = PRMUtilityClass.addTextSegment(' by ', messageSegments);
                messageSegments = PRMUtilityClass.addMentionSegment(partnerOfRecord?.Partner_Signatories__r?.OwnerId, messageSegments);
                messageSegments = PRMUtilityClass.addTextSegment('. ', messageSegments);
            } else {
                messageSegments = PRMUtilityClass.addTextSegment('Adaptive Mobility Care has been successfully added to Billing Account ', messageSegments);
                messageSegments = PRMUtilityClass.addTextSegment(adaptiveCareChatterInfo.billingAccountNumber, messageSegments);
                messageSegments = PRMUtilityClass.addTextSegment('. ', messageSegments);
            }
        } else {
            messageSegments = PRMUtilityClass.addTextSegment('Adaptive Mobility Care has been removed from Billing Account ', messageSegments);
            messageSegments = PRMUtilityClass.addTextSegment(adaptiveCareChatterInfo.billingAccountNumber, messageSegments);
            messageSegments = PRMUtilityClass.addTextSegment('. ', messageSegments);
        }
        messageSegments = PRMUtilityClass.addEntityLink(partnerOfRecord?.Partner__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' can now access associated account management features on this Account.', messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by P.M
    private static ConnectApi.FeedItemInput createChatterPostForDelayNotification(csord__Subscription__c subscription) {
        System.Debug(' *** createChatterPostForDelayNotification ==> ' + subscription );
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        messageSegments = PRMUtilityClass.addMentionSegment(subscription?.csord__Order__r?.OwnerId, messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('There is a delay expected to Order# ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__r?.csord__Order_Number__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' for ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Account__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' as the forecasted delivery date has changed to ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(String.valueOf(subscription?.Forecasted_Delivery_Date__c), messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('You may need to contact the customer to keep them informed of this delay. The below URL will direct you to the related subscription which has been delayed: ', messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Id, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by P.M
    private static ConnectApi.FeedItemInput createChatterPostForOrderReceived(csord__Subscription__c subscription, Set<Id> setOfUserId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Fulfillment has been requested for Subscription ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Id, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Account__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by Sudheendra
    private static ConnectApi.FeedItemInput createChatterPostForFulfilledAndProvisioned(csord__Subscription__c subscription, Set<Id> setOfUserId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Order ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Account__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Account__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' has been entirely provisioned for site.', messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
       messageSegments = PRMUtilityClass.addEntityLink(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by Sudheendra
    private static ConnectApi.FeedItemInput createChatterPostForFulfilledOptyAccCrmUser(csord__Subscription__c subscription, Set<Id> setOfUserId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Order ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.Base_URL__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(subscription?.csord__Order__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Account__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' has been entirely provisioned for site.', messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Site__c, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by P.M
    private static ConnectApi.FeedItemInput createChatterPostForBeingFulfilled(csord__Subscription__c subscription, Set<Id> setOfUserId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = subscription.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
        }
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('Subscription ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Id, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' from ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.csord__Account__c, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' has been accepted and entered provisioning.', messageSegments);
        messageSegments = PRMUtilityClass.addEmptySegment(messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' Track the status here.', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(subscription?.Id, messageSegments);
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    //Added by P.M
    //Modified by Nikhil added few fields as part of  DIGI-4694
    public static List<csord__Subscription__c> getListOfSubscription(Set<Id> setOfSubscriptionId) {
        return [SELECT Id, Name, csord__Order__r.csordtelcoa__Opportunity__r.Type, MarketableOffer__r.Offer_ID__c,
                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                csordtelcoa__Replaced_Subscription__c, toBeCancelled__c, csord__Account__c,csord__Order__r.Name,
                csord__Order__r.csord__Order_Number__c, Forecasted_Delivery_Date__c, Base_URL__c,
                Billing_Account__r.Billing_Account_Number__c,csord__Order__r.OwnerId,csord__Account__r.Name,
                csord__Order__r.csordtelcoa__Opportunity__r.OwnerId, csord__Account__r.OwnerId,
                csord__Account__r.Owner.Profile.Name, csord__Order__r.csordtelcoa__Opportunity__r.Owner.Profile.Name,
                csord__Order__r.Owner.Profile.Name,csord__Status__c,csord__Order__c,TenancyID__c,Site__r.Name,
                csord__Order__r.csordtelcoa__Opportunity__r.Owner.FirstName,
                csord__Order__r.csordtelcoa__Opportunity__r.Owner.LastName,Site__c,
                csord__Account__r.Owner.LastName, csord__Account__r.Owner.FirstName,	
                csordtelcoa__Product_Configuration__r.ConfigurationType1__c,ContractJunction__r.Contract_Number__c,	
                MarketableOffer__r.Name,csord__Account__r.Id,csordtelcoa__Product_Configuration__r.Type__c,	
                cssdm__solution_association__c 
                
                FROM csord__Subscription__c WHERE Id IN :setOfSubscriptionId];
    }

    //Added by P.M
    public static List<Partner_of_Record__c> getListOfPartnerOfRecord(Set<Id> setOfAccountId) {
        return [SELECT Id, Customer__c, Customer__r.OwnerId, Customer__r.Name, Partner_Signatories__r.OwnerId,
                Partner__r.Name, Partner__r.OwnerId, Partner__c FROM Partner_of_Record__c WHERE Customer__c IN :setOfAccountId];
    }

    //Added by P.M
    public Class AdaptiveCareChatterWrapper{
        public String billingAccountNumber;
        public Boolean newOrderOrNot;

        public AdaptiveCareChatterWrapper() {
            this.billingAccountNumber = '';
            this.newOrderOrNot = false;
        }
    }
        //Added by P.M
    public Class ChatterFeedNetworkIdWrapper{
        public ConnectApi.FeedItemInput chatterFeed;
        public Boolean isPartnerNetwork;
        public string networkId;

        public ChatterFeedNetworkIdWrapper(ConnectApi.FeedItemInput feedInput, boolean isPartnerNw) {
            this.chatterFeed = feedInput;
            this.isPartnerNetwork = isPartnerNw;
            this.networkId = this.isPartnerNetwork ? C2O_OrderConstants.EDGE_PARTNERS_NETWORKID : Network.getNetworkId();
        }
    }
    /***************************************************************************************
    * Method Name    - sendOrderNotification
    * Developer Name - Nikhil Sharma
    * Story          - DIGI-4694 
    * Description    - This method is used to call the notifyEventsForSubscriptions 
    * 				   on BDSNotifyService class.
    ****************************************************************************************/
    public static void sendOrderNotification(Set<Id> setOfSubscriptionId) {
        try{
            List<csord__Subscription__c> listOfSubscription = getListOfSubscription(setOfSubscriptionId);
            Map<Id,csord__Subscription__c> mapOfSubscriptions = new Map<Id,csord__Subscription__c>();
            Set<Id> solutionIds = new Set<Id>();
            Map<Id, List<csord__Subscription__c>> solutionWithSubscriptionMap = new Map<Id, List<csord__Subscription__c>>();
            List<csord__Subscription__c> listOfSubscriptionBasedOrder = new List<csord__Subscription__c>();

            for(csord__Subscription__c subscription : listOfSubscription) {

                if(isSubscriptionBasedOrder(subscription) && subscription.csordtelcoa__Product_Configuration__r?.ConfigurationType1__c != 'SolutionComponent'){
                    solutionIds.add(subscription.cssdm__solution_association__c);
                    listOfSubscriptionBasedOrder.add(subscription);
                }
            }

            for(csord__Subscription__c subscription: [SELECT id,cssdm__solution_association__c,csord__Status__c FROM 
                                                     csord__Subscription__c WHERE cssdm__solution_association__c IN :solutionIds  
                                                     AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent']){
        
   
                    if(solutionWithSubscriptionMap.containsKey(subscription.cssdm__solution_association__c)){
                        solutionWithSubscriptionMap.get(subscription.cssdm__solution_association__c).add(subscription);
                    }else{
                        solutionWithSubscriptionMap.put(subscription.cssdm__solution_association__c,new List<csord__Subscription__c>{subscription});
                    }
            } 

            for(csord__Subscription__c subscription : listOfSubscriptionBasedOrder) {
                if(solutionWithSubscriptionMap.size() > 0 && solutionWithSubscriptionMap.containsKey(subscription.cssdm__solution_association__c)
                   && checkExistingSubscriptionStatus(solutionWithSubscriptionMap.get(subscription.cssdm__solution_association__c),subscription.csord__Status__c)){
                    mapOfSubscriptions.put(subscription.cssdm__solution_association__c,subscription);
                }
            }

            if(mapOfSubscriptions.size() > 0){
                //called method to create payload and fire platform event 
                BDSNotifyService.notifyEventsForSubscriptions(mapOfSubscriptions);
            }
        }catch(Exception e){
            //Exception log
            logException('sendOrderNotificationForDMS','',correlationId, e.getMessage(), 'Send order notification for DMS failed.',CONST_INTERFACENAME);
        }
    }
    
	/***************************************************************************************
    * Method Name    - checkExistingSubscriptionStatus
    * Developer Name - Nikhil Sharma
    * Story          - DIGI-20762
    * Description    - This method is used to check child subscription status.
    ****************************************************************************************/
    public static boolean checkExistingSubscriptionStatus(List<csord__Subscription__c> solutionWithSubscriptionList,String status){
        Integer subsCount = 0;
        if(status.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS)){
            for(csord__Subscription__c subscription : solutionWithSubscriptionList){
                if(subscription?.csord__Status__c != 'Pending'){
                    subsCount++;
                }
            }
        }else if(status.equalsIgnoreCase(C2O_OrderConstants.STATUS_ACTIVE)
                 || status.equalsIgnoreCase(C2O_OrderConstants.STATUS_INACTIVE)){
            for(csord__Subscription__c subscription : solutionWithSubscriptionList){
                if(subscription?.csord__Status__c?.equalsIgnoreCase(status)){
                    subsCount++;
                }
            }
        }
        if(subsCount == solutionWithSubscriptionList.size()){
            return true;
        }
        return false;
    }
    
	/**************************************************************************************
    * Method Name    - isSubscriptionBasedOrder*
    * Developer Name - Nikhil Sharma
    * Story          - DIGI-4694 
    * Description    - This method is used check is subscription based order or not.
    ****************************************************************************************/
    public static boolean isSubscriptionBasedOrder(csord__Subscription__c subscription){
        String orderStatus = subscription.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS) ? 'INPROGRESS' : 'COMPLETE';
        for(BDS_Notify_Settings__c bdsNotifySetting : allBDSNotifySettings){
            if(bdsNotifySetting?.Value__c == subscription?.MarketableOffer__r?.Offer_ID__c 
            && bdsNotifySetting.Is_SI5_Offer__c && bdsNotifySetting.Is_Sub_Offer__c &&
            ((orderStatus == 'INPROGRESS' && bdsNotifySetting.EventType_InProgress__c.contains(subscription.csordtelcoa__Product_Configuration__r.Type__c))
            || (orderStatus == 'COMPLETE' && bdsNotifySetting.EventType_Complete__c.contains(subscription.csordtelcoa__Product_Configuration__r.Type__c)))){
                return true;
            }
        }
        return false;
    }

    /*----------------------------------------------------------------
    Method     : logException
    Description: Method to create log exceptions
    Author     : Nikhil Sharma
    Story      : DIGI-4694 
    -------------------------------------------------------------------------------------*/ 
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,String CONST_INTERFACENAME){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
}