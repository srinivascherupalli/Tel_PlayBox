/**================================================================
* Name: Orchestration_OrdertoBillUpdate_Handler
* Description: Class to push subscription on Billing System
* Created Date: 
* Created By: 
==================================================================*/
global with sharing class Orchestration_OrdertoBillUpdate_Handler implements Orchestration_StepInterface{
//private Map<Id, stepResult> stepResults = new Map<Id, stepResult>();
protected Map<Id, Map<Id, ApplicationLog__c>> mapStepIdToRecordApplicationLog = new Map<Id, Map<Id, ApplicationLog__c>>();
    protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
   // private Map<Id, stepResult> stepResults = new Map<Id, stepResult>();
    private Boolean exceptionInCallOut = false;
    private Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
    public static String handlerName = 'PostSubscriptionHandler';
    private Map<Id, Charge_Line_Item__c> chargeLineItemToUpdate = new Map<Id, Charge_Line_Item__c>();
    private Map<Id, Discount_Line_Item__c> discountLineItemToUpdate = new Map<Id, Discount_Line_Item__c>();
    private Map<Id, Price_Schedule_Line_Item__c> priceSchedLineItemToUpdate = new Map<Id, Price_Schedule_Line_Item__c>();
    private Map<Id, Tier_Line_Item__c> tierLineItemToUpdate = new Map<Id, Tier_Line_Item__c>();
    private Map<Id, Number__c> numbersToUpdate = new Map<Id, Number__c>();
    private Map<Id, csord__Subscription__c> mapSubscritpion = new Map<Id, csord__Subscription__c>();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
    //private Set<String> subscriptionNumbers = new Set<String>();
    //private Map<Id, List<csord__Subscription__c>> mapOrderToSubs = new Map<Id, List<csord__Subscription__c>>();
    private String pendingStep = '';
    private List<CSPOFA__Orchestration_Step__c> stepList;
    private BillingUtility billUtility;
    public static Integration_Handler__mdt handlerMetaData;
    public List<Id> subscriptionIdList = new List<Id>();
    public List<ApplicationLog__c> logList = new List<ApplicationLog__c>();
    private Map<Id, Billing_Account__c> billingAccountsToUpdate = new Map<Id, Billing_Account__c>();
    //public List<Billing_Account__c> billingAccountList = new List<Billing_Account__c>();
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
    //private Map<Id, ApplicationLog__c> mapSubIdToApplicationLog = new Map<Id, ApplicationLog__c>();
    private boolean allStepSkipped = true;
    public String oAuthToken = 'MLhlJPHAFdP38Z1CsAnEI1EDts6h';
    String msgStr='';
    String errStatus='';
    
    
    /**
* @description   :  This method is inherited from AbstractStepHandlers to do further processing
* @param         : List<Sobject>
* @return        :  List<Sobject>
**/
    public void processUpdate(String strPayload) {
        List<Id>subscriptionIds=new List<Id>();        
        Id stepID;
        
        try{
            Map<String, Object> mapOfPayload = (Map<String, Object>)JSON.deserializeUntyped(strPayload);
      /*List<Object> reqs = (List<Object>)mapOfPayload.get('subscriptionIds');
           
      for(integer i=0;i<reqs.size();i++){
          String str=(String)reqs[i];
          system.debug(str);
          subscriptionIds.add(str);
      }*/
            system.debug('enteres process method====>>>');            
                try{
                    if (!Orchestration_LimitsUtility.areLimitsViolated()){
                    String subsId =(String)mapOfPayload.get('Current');
                        subscriptionIds.add(subsId);
                    stepID = (Id)mapOfPayload.get('StepId');
                    String statusCode=(String)mapOfPayload.get('CalloutStatus');
                        Object processedRecord = mapOfPayload.get('ProcessedIds');
               String prRecords = JSON.serialize(processedRecord);
                        system.debug('prRecords '+prRecords);
               Orchestration_ProcessedRecords processedRecordIds =  (Orchestration_ProcessedRecords) JSON.deserialize(prRecords, Orchestration_ProcessedRecords.class);
                   // Orchestration_ProcessedRecords processedRecordIds = (Orchestration_ProcessedRecords)mapOfPayload.get('ProcessedIds');
                    system.debug('subscriptionIds### '+subscriptionIds);
                        if (processedRecordIds != null) {
                            processedIds.put(stepId,processedRecordIds);
                        }
                    billUtility=new BillingUtility(subscriptionIds,true,false,'PostSubscriptionHandler');
                        //processedIds=(Map<String, Orchestration_ProcessedRecords>)mapOfPayload.get('ProcessedIds');                   
                    if(String.isNotBlank(subsId)) {
                        
                        ApplicationLog__c appLog;
                       
                        String responseBody = (String)mapOfPayload.get('ResponseBody');
                        
                        if(responseBody == ''){                            
                             mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Callout Failed: no response recieved from the interface',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                        }
                        system.debug('before subscription check' +subsId);
                        csord__Subscription__c subscriptionToUpdate = billUtility.subscriptionMap.get(subsId);
                        system.debug('subscriptionToUpdate### '+subscriptionToUpdate);
                        Billing_Account__c billingAccountToUpdate = subscriptionToUpdate.Billing_Account__r;
                        system.debug('billingAccountToUpdate===='+billingAccountToUpdate);
                        system.debug('before status code check');
                        if(statusCode != '202'){                           
                           if(performCalloutProcessOperations(stepId ,subscriptionToUpdate, billingAccountToUpdate, 'Billing Pending', 'Error', false,  statusCode, null)){
                                pendingStep = stepId;
                               // break;
                            }
                        } else {
                            if(performCalloutProcessOperations(stepId ,subscriptionToUpdate, billingAccountToUpdate, 'Bill Readiness In Progress', 'Provisioned', true, '202', responseBody)){
                                pendingStep = stepId;
                               // break;
                            }
                        }
                    }
                                   if (pendingStep != '') {
                       // break;
                    } else if (stepRelationshipMap.isEmpty() || !stepRelationshipMap.containsKey(stepId)) {
                        system.debug('====>>>> entered complete');
                        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success : No update required as no data found to update',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                       
                            }
                    }
                }catch(Exception ex){
                         
                    mapStepDetails.put(stepID,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                }
          
        }catch(Exception ex){
           
        }
        updateBillObjects();
        updateStepStatus();
       
    }
    public boolean performCalloutProcessOperations(Id stepId, csord__Subscription__c subscriptionToUpdate, Billing_Account__c billingAccountToUpdate, String SubStatus, String billingStatus, Boolean isSuccessOperation, String statusCode, String responseBody){
        //System.debug('Response Body ::'+ responseBody + ' statusCode :::'+ statusCode + ' SubStatus :::'+ SubStatus);
        Set<Id> serviceIdsToFetchNew = new Set<Id>();
        Set<Id> baseOrderServiceID = new Set<Id>();
        BillingPostSubscriptionResponseDTO billingPostSubscriptionResponseJson;
        if(responseBody != null){
            billingPostSubscriptionResponseJson = BillingPostSubscriptionResponseDTO.parse(responseBody);
        }
      
       // if(!hasDMLRowsLimitExceeded()){
        if (!Orchestration_LimitsUtility.areLimitsViolated()){
            system.debug('subscriptionToUpdate.csord__Status__c'+subscriptionToUpdate.csord__Status__c);
            if(subscriptionToUpdate.csord__Status__c != SubStatus && subscriptionToUpdate.csord__Status__c!= 'Ready for Activation' && (subscriptionToUpdate.triggerBill_RTB__c==true || subscriptionToUpdate.toBeCancelled__c.equalsIgnoreCase('true'))){
                system.debug('Inside 1st if');
                subscriptionToUpdate.csord__Status__c = SubStatus;
                if(isSuccessOperation){
                    /*if(subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != null){
                        if (subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                            subscriptionToUpdate.triggerBill_RTB__c = true;//added as part of EDGE-156196
                        }
                    }*/ //commented as part of solution suppression story
                    subscriptionToUpdate.eventId__c = billingPostSubscriptionResponseJson.eventId;
                    //subscriptionToUpdate.response_Status_Code__c = response.getStatusCode();
                }
               // subscriptionToUpdate.isCacheUpdated__c=true;
                subscriptionToUpdate.response_Status_Code__c = statusCode != null ? Integer.valueOf(statusCode) : null;
                subscriptionsToUpdate.put(subscriptionToUpdate.Id, subscriptionToUpdate);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new List<String>{ subscriptionToUpdate.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(subscriptionToUpdate.Id);
                }
            }
            // EDGE-187676 akanksha adding starts
            else if(subscriptionToUpdate.csord__Status__c == 'Ready for Activation')
            {
               
                subscriptionToUpdate.response_Status_Code__c = statusCode != null ? Integer.valueOf(statusCode) : null;
                if(isSuccessOperation){
					//commented as part of B2B-328 solution supress - Start
                    /*if(subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != null){
                        if (subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                            subscriptionToUpdate.csord__Status__c = 'Provisioned';
                            list<csord__Subscription__c> subsLst = new List<csord__Subscription__c>();
                            for(csord__Subscription__c subs: billUtility.solutionToSubsMap.get(subscriptionToUpdate.cssdm__solution_association__c))
                            {
                                if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent')
                                {
                                    subs.Trigger_RFA__c = true;subscriptionsToUpdate.put(subs.Id,subs);
                                }
                            }
                        }
                    }
                    else
                    {*///commented as part of B2B-328 solution supress - End
                        // individual subscription
                        subscriptionToUpdate.csord__Status__c = 'Provisioning In Progress';
                        //updateNumberStatus(subscriptionToUpdate.csordtelcoa__Subscription_Number__c, 'Provisioning In Progress', StepId);
                       // subscriptionToUpdate.eventId__c = 'test';
                       // System.debug('Inside 325 55555');
                   // }
                    //subscriptionToUpdate.eventId__c = billingPostSubscriptionResponseJson.eventId;
                }
                subscriptionsToUpdate.put(subscriptionToUpdate.Id, subscriptionToUpdate);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new List<String>{ subscriptionToUpdate.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(subscriptionToUpdate.Id);
                }
            }
            system.debug('subscriptionsToUpdate ---350'+subscriptionsToUpdate);
            // EDGE-187676 akanksha adding ends
        }
        else {
            return true;
        }
        //EDGE-186947 Record order submission date for all order scenarios including billing only change by Gunjan
        //if(!hasDMLRowsLimitExceeded()){
         if (!Orchestration_LimitsUtility.areLimitsViolated()){
            if(billingAccountToUpdate != null && billingAccountToUpdate.Status__c != billingStatus && billingStatus != 'Error' && (subscriptionToUpdate.csord__Status__c != 'Ready for Activation' || subscriptionToUpdate.csord__Status__c != 'Provisioning In Progress')){
                billingAccountToUpdate.Status__c = billingStatus;
                billingAccountToUpdate.isUpdated__c = true; //EDGE-170215 Kalashree. Fix for calling MS
               // billingAccountToUpdate.isCacheUpdated__c=true;
                billingAccountsToUpdate.put(billingAccountToUpdate.Id, billingAccountToUpdate);
                
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new List<String>{ billingAccountToUpdate.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(billingAccountToUpdate.Id);
                }
                 //system.debug('billingAccountToUpdate ---350'+billingAccountToUpdate);
            }
         //}
        }else {return true;
        }
        if(isSuccessOperation){
            //numbersUpdate
            if(subscriptionToUpdate.csord__Status__c!= 'Ready for Activation' && subscriptionToUpdate.csord__Status__c == 'Bill Readiness In Progress' && (subscriptionToUpdate.triggerBill_RTB__c==true || subscriptionToUpdate.toBeCancelled__c.equalsIgnoreCase('true'))){
                if(updateNumberStatus(subscriptionToUpdate.csordtelcoa__Subscription_Number__c, 'Bill Readiness In Progress', StepId)){
                return true;
            }
            //}
            
            List<Id> serviceIdsForSubscription = billUtility.mapSubscriptionTolistServiceIds.get(subscriptionToUpdate.Id);
            for(id serviceId: serviceIdsForSubscription){
                csord__Service__c service = billUtility.serviceMap.get(serviceId);
                if (service.csordtelcoa__Replaced_Service__c == null) {
                    serviceIdsToFetchNew.add(service.Id);
                } else if (service.csordtelcoa__Replaced_Service__c != null && service.toBeCancelled__c.equalsIgnoreCase('false')) {
                    serviceIdsToFetchNew.add(service.Id);
                    baseOrderServiceID.add(service.csordtelcoa__Replaced_Service__c);
                }
            }
            //All cli, pli etc
            //Code added as part of EDGE-124711/EDGE-124029
            if (serviceIdsToFetchNew != null) {
                if(updateSchedule(stepId, serviceIdsToFetchNew, 'Ready to Active')){return true;
                }
            }
            if (baseOrderServiceID != null) {
                if(updateSchedule(stepId, baseOrderServiceID, 'Ready to Replaced')){return true;
                }
            }
            }
        }
        return false;
    }
    private boolean updateSchedule(String stepId, Set<Id> serviceIdsBaseOrder, String status) {
        for (Id serviceId : serviceIdsBaseOrder) {
            if(billUtility.mapServiceToCLIs != null && billUtility.mapServiceToCLIs.containsKey(serviceId)) {
                for (Charge_Line_Item__c cli : billUtility.mapServiceToCLIs.get(serviceId)) {
                    //if (hasDMLRowsLimitExceeded()) {return true;
                   // }
                    if (!Orchestration_LimitsUtility.areLimitsViolated()){
                        if(cli.status__c != status){
                            cli.status__c = status;
                            chargeLineItemToUpdate.put(cli.Id, cli);
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new List<String>{ cli.Id });
                            } else {
                                stepRelationshipMap.get(stepId).add(cli.Id);
                            }
                        }
                    }
                        if(billUtility.mapCLIsToDLIs != null && billUtility.mapCLIsToDLIs.containsKey(cli.Id)) {
                            for (Discount_Line_Item__c dli : billUtility.mapCLIsToDLIs.get(cli.Id)) {
                                // if (hasDMLRowsLimitExceeded()) {
                                //     return true;
                                // }
                                if (!Orchestration_LimitsUtility.areLimitsViolated()){
                                if(dli.status__c != status){
                                    dli.status__c = status;
                                    discountLineItemToUpdate.put(dli.Id, dli);
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new List<String>{ dli.Id });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(dli.Id);
                                    }
                                }
                            }
                            }
                        }
                        if(billUtility.mapCLIsToPSLIs != null && billUtility.mapCLIsToPSLIs.containsKey(cli.Id)) {
                            for (Price_Schedule_Line_Item__c pSLI : billUtility.mapCLIsToPSLIs.get(cli.Id)) {
                                // if (hasDMLRowsLimitExceeded()) {
                                //    return true;
                                // }
                                if (!Orchestration_LimitsUtility.areLimitsViolated()){
                                if(pSLI.status__c != status){
                                    pSLI.status__c = status;
                                    priceSchedLineItemToUpdate.put(pSLI.Id, pSLI);
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new List<String>{ pSLI.Id });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(pSLI.Id);
                                    }
                                }
                            }
                                if(billUtility.mapPSLIsToTLIs != null && billUtility.mapPSLIsToTLIs.containsKey(pSLI.Id)) {
                                    for (Tier_Line_Item__c tLI : billUtility.mapPSLIsToTLIs.get(pSLI.Id)) {
                                        //   if (hasDMLRowsLimitExceeded()) {return true;
                                        //   }
                                        if (!Orchestration_LimitsUtility.areLimitsViolated()){
                                        if(tLI.status__c != status){
                                            tLI.status__c = status;
                                            tierLineItemToUpdate.put(tLI.Id, tLI);
                                            if (!stepRelationshipMap.containsKey(stepId)) {
                                                stepRelationshipMap.put(stepId, new List<String>{ tLI.Id });
                                            } else {
                                                stepRelationshipMap.get(stepId).add(tLI.Id);
                                            }
                                        }
                                    }
                                    }
                                }
                            }
                        }
                    //}
                }
                
            }
        }
        return false;
    }
    private boolean updateNumberStatus(String subscriptionNumber, String status, Id StepId) {
        Orchestration_ProcessedRecords processedRecordIds = processedIds.get(stepId);
        if(billUtility.mapSubsNumbers != null && billUtility.mapSubsNumbers.containskey(subscriptionNumber)){
            for (Number__c numb : billUtility.mapSubsNumbers.get(subscriptionNumber)) {
              if (!Orchestration_LimitsUtility.areLimitsViolated()){
                System.debug('status ' + status);
                //EDGE-132208 - Added confitions to set the Number Status based on Previous Status and Notification Status.
                if(!(processedRecordIds !=null && processedRecordIds.numberIds!=null && processedRecordIds.numberIds.contains(numb.Id))){
                    if(numb.Status__c!='Active'){ // EDGE-175339 & EDGE-179374
                        if (numb.Status__c == 'RESERVED') {
                            numb.Status__c = status;
                        } else if (numb.Status__c == 'DISCONNECT PENDING') {
                            numb.Status__c = 'Disconnect in Progress';
                        } else if (numb.status__c == 'Disconnect In Progress') {
                            numb.Status__c = 'Disconnected';
                        } else if (numb.status__c == 'Provisioning In Progress') {
                            numb.Status__c = status;
                        } else if (numb.status__c == 'Provisioned') {
                            numb.Status__c = status;
                        } else {
                            numb.Status__c = status;
                        }
                      //  numb.isCacheUpdated__c=true;
                        numbersToUpdate.put(numb.Id, numb);
                        if (!stepRelationshipMap.containsKey(stepId)) {
                            stepRelationshipMap.put(stepId, new List<String>{ numb.Id });
                        } else {
                            stepRelationshipMap.get(stepId).add(numb.Id);
                        }
                    }
                }
            }
            }
        }
        system.debug('numbersToUpdate:'+numbersToUpdate);
        system.debug('stepRelationshipMap:'+stepRelationshipMap);
        return false;
    }
    public void updateBillObjects() {
        //Success DML order Ids
        List<Id> successIds = new List<Id>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //List<Id> subscriptionSuccessIds = new List<Id>();
        //List<Id> billingAccSuccessIds = new List<Id>();
        //List<Id> cLISuccessIds = new List<Id>();
        //List<Id> dSLISuccessIds = new List<Id>();
        //List<Id> pSLISuccessIds = new List<Id>();
        //List<Id> tLISuccessIds = new List<Id>();
        List<Id> numbersSuccessIds = new List<Id>();
        List<Charge_Line_Item__c> chargeList = new List<Charge_Line_Item__c>();
        List<Tier_Line_Item__c> tierList = new List<Tier_Line_Item__c>();
        List<Price_Schedule_Line_Item__c> priceList = new List<Price_Schedule_Line_Item__c>();
        List<Discount_Line_Item__c> discountItem = new List<Discount_Line_Item__c>();
        List<Number__c>numberList = new List<Number__c>();
        List<Billing_Account__c> billAccList = new List<Billing_Account__c>();
        //Updating all the subscription records
        //system.debug('subscriptionsToUpdate===>>>'+subscriptionsToUpdate);
        if (subscriptionsToUpdate.size() > 0) {
            subscriptionList.add(subscriptionsToUpdate.values());
            Orchestration_PlatformCacheUtility.updatePlatformCache(subscriptionList);
            for(csord__Subscription__c subs:subscriptionList){
                successIds.add(subs.Id);
            }
           
        }
        //Updating all the order records
        //system.debug('billingAccountsToUpdate===>>>'+billingAccountsToUpdate);
        if (billingAccountsToUpdate.size() > 0) {
            //billAccList.addAll(billingAccountsToUpdate.values());
            List<Database.SaveResult> updateResult = Database.update(billingAccountsToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //billingAccSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
         //   Orchestration_PlatformCacheUtility.updatePlatformCache(billAccList);
            //List<Billing_Account__c> billingAccList=billingAccountsToUpdate.values();
           // for(Billing_Account__c billAcc:billAccList){
          // system.debug('billAccListSize '+billAccList.size());
          //  for(Integer i=0;i<billAccList.size();i++){
               // successIds.add(billAcc.Id);          
           //      successIds.add(billAccList[i].Id);          
                
          //  }
        //}
        //}
        //Updating all the order records
        if (chargeLineItemToUpdate.size() > 0) {            
            chargeList.addAll(chargeLineItemToUpdate.values());
          Orchestration_PlatformCacheUtility.updatePlatformCache(chargeList);
          for(Charge_Line_Item__c chrg:chargeList){
              successIds.add(chrg.Id);
          }
        }
        //Updating all the order records
        if (discountLineItemToUpdate.size() > 0) {           
            discountItem.addAll(discountLineItemToUpdate.values());
             //discountList.add(discountLineItemToUpdate.values());
            Orchestration_PlatformCacheUtility.updatePlatformCache(discountItem);
          for(Discount_Line_Item__c disItem:discountItem){
              successIds.add(disItem.Id);
          }
        }
        //Updating all the order records
        if (priceSchedLineItemToUpdate.size() > 0) {           
            priceList.addAll(priceSchedLineItemToUpdate.values());
        Orchestration_PlatformCacheUtility.updatePlatformCache(priceList);
          for(Price_Schedule_Line_Item__c prcList:priceList){
              successIds.add(prcList.Id);
          }
        }
        //Updating all the order records
        if (tierLineItemToUpdate.size() > 0) {            
            tierList.addAll(tierLineItemToUpdate.values());
        Orchestration_PlatformCacheUtility.updatePlatformCache(tierList);
          for(Tier_Line_Item__c tierItem:tierList){
              successIds.add(tierItem.Id);
          }
        }
        //Updating all the order records
        if (numbersToUpdate.size() > 0) {
            system.debug('inside if:');
           
            numberList.addAll(numbersToUpdate.values());
            Orchestration_PlatformCacheUtility.updatePlatformCache(numberList);
            for(Number__c numbItem:numberList){
                numbersSuccessIds.add(numbItem.Id);
               
            }
        }
        //}
        system.debug('numbersSuccessIds'+numbersSuccessIds);
        system.debug('successIds'+successIds);
        //Iteration over each step, processed Id check is not required
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the orderids Set
            perStepSuccessIds.numberIds = new Set<String>();
            Boolean isFailed = false;
            for (Id recId : stepRelationshipMap.get(stepId)) {
                if(numbersSuccessIds.size()>0 && numbersSuccessIds.contains(recId)){
                    perStepSuccessIds.numberIds.add(recId);
                    system.debug('inside if568');
                }else if (successIds.size() > 0 && !successIds.contains(recId)){
                    //Failure
                    isFailed = true;
                    system.debug('isFailed571'+isFailed);
                }
            }
            String errorMessage = 'Error: Unable to process records';
            if (mapStepDetails.containsKey(stepId)) {
                CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
               // stepResult sr = stepResults.get(stepId);
                if (stepDetails.CSPOFA__Status__c == OrchestratorConstants.OrchestratorStep.Error) {
                    isFailed = true;errorMessage = stepDetails.CSPOFA__Status__c;
                    system.debug('isFailed579'+isFailed);
                    
                }
            }
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                if(mapStepDetails!=null && mapStepDetails.containsKey(stepId)){
                    CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                    stepDetails.CSPOFA__Message__c = 'Success: Records processed';
                    stepDetails.CSPOFA__Status__c = OrchestratorConstants.OrchestratorStep.Complete;
                }else{
                    //Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                    mapStepDetails.put(stepId, new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Records processed', CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                }
                //move to next step
                continue;
            }
            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).numberIds != null) {
                perStepSuccessIds.numberIds.addAll(processedIds.get(stepId).numberIds);
            }
            String serializedIds = JSON.serialize(perStepSuccessIds, true);
            if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                if(mapStepDetails!=null && mapStepDetails.containsKey(stepId)){
                    CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                    stepDetails.CSPOFA__Message__c = 'Success: Partial records processed';                   
                    stepDetails.CSPOFA__Status__c = OrchestratorConstants.OrchestratorStep.InProgress;                    
                    stepDetails.JSON__c = serializedIds;
                }else{
                    mapStepDetails.put(stepId, new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Partial records processed', CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress, JSON__c=serializedIds));
                }
            } else {
                if(mapStepDetails!=null && mapStepDetails.containsKey(stepId)){
                    CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                    stepDetails.CSPOFA__Message__c = errorMessage;                    
                    stepDetails.CSPOFA__Status__c = OrchestratorConstants.OrchestratorStep.Error;                    
                    stepDetails.JSON__c = serializedIds;
                }else{
                    mapStepDetails.put(stepId, new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c=errorMessage, CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error, JSON__c=serializedIds));
                }
            }
        }
    }
    
    /*public boolean hasDMLRowsLimitExceeded() {
        System.debug('Available Limit ::'+ Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c));
        System.debug('Total Limit :::'+ (chargeLineItemToUpdate.size() + discountLineItemToUpdate.size() + priceSchedLineItemToUpdate.size() + billingAccountsToUpdate.size() + tierLineItemToUpdate.size() + numbersToUpdate.size() + subscriptionsToUpdate.size() + Limits.getDMLRows()));
        if ((chargeLineItemToUpdate.size() + discountLineItemToUpdate.size() + priceSchedLineItemToUpdate.size() + billingAccountsToUpdate.size() + tierLineItemToUpdate.size() + numbersToUpdate.size() + subscriptionsToUpdate.size() + Limits.getDMLRows()) < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            system.debug('enterde false----==>>>');
            return false;
        }
        //Limit Hit
        return true;
    }*/
    //public void updateStepStatus(Id stepId,String msg,String stepStatus){
    public void updateStepStatus(){
        //CSPOFA__Orchestration_Step__c step = [Select id,CSPOFA__Message__c,CSPOFA__Status__c from CSPOFA__Orchestration_Step__c where id=:stepid];
        List<Database.SaveResult> updateResult = Database.update(mapStepDetails.values(), false);
      // step.CSPOFA__Message__c= msg;
       // step.CSPOFA__Status__c=stepStatus; 
        //update step;
        for(Database.SaveResult result: updateResult){
            if (result.isSuccess()) {
                System.debug('Successfully updated step status ==> ' + result );
            } else {
                for(Database.Error err : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage()); 
                }
            }
        }
    }
}