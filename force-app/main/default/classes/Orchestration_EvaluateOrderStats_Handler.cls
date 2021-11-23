global with sharing class Orchestration_EvaluateOrderStats_Handler implements Orchestration_StepInterface{
@TestVisible private Map<Id, Integer> orderSubscriptionCntMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> cancellationInProgressMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> failedMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> activeMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> paidOutMap = new Map<Id, Integer>();  //EDGE-163712
    @TestVisible private Map<Id, Integer> inActiveMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> closedMap = new Map<Id, Integer>();  //EDGE-177027    
    @TestVisible private Map<Id, Integer> cancelledMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> billingCompleteMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> suspendedMap = new Map<Id, Integer>();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
    //Store active Solution component subscription
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //Solution Subscription --> Child Subscription
   
    //Solution Association related to the step
    //Store multiple records for a step at a place
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Store the active step Id
    private String currentStep = '';
    //Keep track of order updation
    private Map<Id, csord__Order__c> updateOrderMap = new Map<Id, csord__Order__c>();
    //Keep track of subscription updation
    private Map<Id, csord__Subscription__c> updateSubsMap = new Map<Id, csord__Subscription__c>();
    Set<Id> orderIds=new Set<Id>();
    
    /**************************************************************
Name: process
Parameters: List<SObject> steps
Return Type: List<SObject>
Description: Overriding the process method of ExecutionHandler interface
*******************************************************************/
    public void processUpdate(String strPayload) {
        List<SObject> sobjList=new List<SObject>(); // Added as part of EDGE-222326
       Set<Id>subscriptionIds = new Set<Id>();
        Id stepId;
        //Exception Handling
        try {
           // List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            //Aggregate query for order status calculation
            //runAggregateProgram();
            //Step processing
            //for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Storing the Order related to the subscription
                    Map<String, Object> mapPayload = (Map<String, Object>)JSON.deserializeUntyped(strPayload);
                    List<Object> reqs = (List<Object>)mapPayload.get('subscriptionIds');
                    List<Object>orderIdList = (List<Object>)mapPayload.get('orderIds'); 
                    Id currentSubsRec= (Id)mapPayload.get('Current');
                    stepId = (Id)mapPayload.get('StepId');
                    currentStep=stepId;
                    Object processedRecord = mapPayload.get('ProcessedRecords');
               String prRecords = JSON.serialize(processedRecord);
               Orchestration_ProcessedRecords processedRecordIds =  (Orchestration_ProcessedRecords) JSON.deserialize(prRecords, Orchestration_ProcessedRecords.class);
                   // Orchestration_ProcessedRecords processedRecordIds = (Orchestration_ProcessedRecords)mapPayload.get('ProcessedRecords');
                    if(processedRecordIds!=null)
                        processedIds.put(stepId,processedRecordIds);
                  // processedIds=(Map<String, Orchestration_ProcessedRecords>)mapPayload.get('ProcessedIds');
                    /*for(integer i=0;i<reqs.size();i++){
                        String str=(String)reqs[i];
                        system.debug('ListSubscription '+str);
                        subscriptionIds.add(str);
                    }*/
                    subscriptionIds.add(currentSubsRec);
                   // Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);                    
                   // if (processedRecordIds != null) {
                   //     processedIds.put(stepId, processedRecordIds);
                   // }
                    
                    List<csord__Subscription__c> subscriptionList = Coms_PlatformCacheUtil.getListOfSubscriptionFromCache(subscriptionIds);
                    system.debug('subListFromCache### '+subscriptionList);
                    runAggregateProgram(subscriptionList);
                    csord__Order__c orderRec;
                    string subsChangeType; //EDGE-180743
                    for(csord__Subscription__c subs: subscriptionList){
                        system.debug('substatus### '+subs.csord__Status__c);
                        if(subs.csord__Order__r != null){
                            orderRec = subs.csord__Order__r;
                            subsChangeType = subs.changeType__c;//EDGE-180743 
                        }
                        else if (subs.csordtelcoa__Replacement_Subscription__c != null &&
                        subs.csordtelcoa__Replacement_Subscription__r.csord__Order__c != null) {
                        orderRec = subs.csordtelcoa__Replacement_Subscription__r.csord__Order__r;
                        subsChangeType = subs.changeType__c;//EDGE-180743
                    }
                    system.debug('subsChangeType### '+subsChangeType);
                    /*if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c != null) {
                        orderRec = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r;
                        subsChangeType = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c;//EDGE-180743
                    } else if (
                        step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__c != null &&
                        step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c != null
                    ) {
                        orderRec = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r;
                        subsChangeType = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c;//EDGE-180743
                    }*/
                   
                    //Order processing will start and avoiding the processed order
                    if (orderRec != null && !updateOrderMap.containsKey(orderRec.Id) &&
                        !(processedIds.containsKey(currentStep) &&
                          processedIds.get(currentStep).orderIds != null && processedIds.get(currentStep).orderIds.contains(orderRec.Id))) {
                        //if (updateOrderStatus(orderRec)) {//EDGE-180743
                        if (updateOrderStatus(orderRec, subsChangeType)) {//EDGE-180743
                            //Capturing the step where limit got
                            pendingStep = stepId; break;
                            //Terminate the loop
                            
                        }
                    }
                    //These will be marked as Complete directly
                    if ((pendingStep == '' || pendingStep != stepId) && !stepRelationshipMap.containsKey(currentStep)) {
                        //Updating steps as complete where no processing required
                     //   stepResults.put(step.Id, new stepResult('Success: No records required processing under the step', OrchestratorConstants.OrchestratorStep.Complete));
                         mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: No records required processing under the step',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                    }
                    }                    
                } catch (Exception ex) { 
                     mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                    //stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
           // }
        } catch (Exception ex) {
           // for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            //}
        }
        
        if (updateOrderMap.size() + updateSubsMap.size() > 0) {
            updateOrdObjects();
        }
        updateStepStatus();
        //return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
      
    private Boolean updateOrderStatus(csord__Order__c ord, string subsChangeType) {//EDGE-169360 added subsChangeType parameter
        String status = getOrderStatus(ord.Id);
        system.debug('OrderStatus### '+ord.csord__Status2__c);
        if(!ord.csord__Status2__c.equals(status) &&  (subsChangeType == null || !subsChangeType.containsIgnoreCase('Resume'))){//EDGE-180743
            //if (!ord.csord__Status2__c.equals(status) && !ord.name.containsIgnoreCase('Resume')) { // EDGE-169360
            ord.csord__Status2__c = status;
            ord.CorrelationId__c=ord.Id;
            if (status.equals(OrchestratorConstants.OrderStatus.Completed)) {  ord.csord__End_Date__c = Date.today();
                                                                            }
            
            //Storing Order records for updation
            // if (!hasDMLRowsLimitExceeded()) {
             if (!Orchestration_LimitsUtility.areLimitsViolated()){
            updateOrderMap.put(ord.Id, ord);
            //Maintain the relationship
            if (!stepRelationshipMap.containsKey(currentStep)) {
                stepRelationshipMap.put(currentStep, new Set<Id>{ ord.Id });
            } else {  stepRelationshipMap.get(currentStep).add(ord.Id);
                   }
             } else { return true;
            //limit got hit
            
             }
        }
        return false;
    }
    
    //Method to return order status based on the subscription
    @TestVisible
    private String getOrderStatus(Id ordId) {
        String status = OrchestratorConstants.OrderStatus.InProgress;
        if (closedMap.get(ordId) == orderSubscriptionCntMap.get(ordId)) {   //EDGE-177027
            status = OrchestratorConstants.OrderStatus.Completed;
        } 
        else if (cancellationInProgressMap.get(ordId) == orderSubscriptionCntMap.get(ordId)) {
            status = OrchestratorConstants.OrderStatus.CancellationInProgress;
        } else if (failedMap.get(ordId) == orderSubscriptionCntMap.get(ordId)) {
            status = OrchestratorConstants.OrderStatus.Failed;
        } else if (cancelledMap.get(ordId) == orderSubscriptionCntMap.get(ordId)) {
            status = OrchestratorConstants.OrderStatus.Cancelled;
        } else if ((billingCompleteMap.get(ordId)+activeMap.get(ordId) + paidOutMap.get(ordId) + inActiveMap.get(ordId)+ cancelledMap.get(ordId)) == orderSubscriptionCntMap.get(ordId)) { //EDGE-163712 : Including terminal status as paidOut also
            status = OrchestratorConstants.OrderStatus.Completed;
        } 
        /*Merged this elseIf with above if while fixing EDGE-217066(added cancelled and active status together)
        else if ((billingCompleteMap.get(ordId)+ paidOutMap.get(ordId) + inActiveMap.get(ordId) + cancelledMap.get(ordId)) == orderSubscriptionCntMap.get(ordId)) {   //EDGE-163712
            status = OrchestratorConstants.OrderStatus.Completed;
        }
        */
        else if (suspendedMap.get(ordId) == orderSubscriptionCntMap.get(ordId)) {
            status = OrchestratorConstants.OrderStatus.Completed;
        }
        
        return status;
    }
    
    /**
* @author Gaurang Maheshwari
* @date 19/05/2020
* @description for updating the records related to the steps (Step is dependent on multiple records)
step with failed records --> Error AND put the success ids in JSON
step with all passed records -- > Complete
Step with partial records due to limit and all success --> In progress AND put the success ids in JSON
Step with partial records due to limit and failed records --> Error AND put the success ids in JSON
*/
    public void updateOrdObjects() {
        //Success DML order Ids
        List<Id> orderSuccessIds = new List<Id>();
        //Success DML subscription Ids
        List<Id> subsSuccessIds = new List<Id>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        if (updateOrderMap.size() > 0) {
            orderList.add(updateOrderMap.values());
            Orchestration_PlatformCacheUtility.updatePlatformCache(orderList);
            for(csord__Order__c orders:orderList){
                orderSuccessIds.add(orders.Id);					
            }
        }
       /* List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
        //Updating all the order records
        if (updateOrderMap.size() > 0) {
            updateResult = Database.update(updateOrderMap.values(), false);
            
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    orderSuccessIds.add(rslt.getId());
                }
            }
        }*/
        
        //Updating all the subscription records
        
        if (updateSubsMap.size() > 0) {            
            List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();             
            subscriptionList.add(updateSubsMap.values());
            Orchestration_PlatformCacheUtility.updatePlatformCache(subscriptionList);
            for(csord__Subscription__c subs:subscriptionList){
                subsSuccessIds.add(subs.Id);
            }
            
        }
        
        //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the orderids Set
            perStepSuccessIds.orderIds = new Set<String>();
            Boolean isFailed = false;
            
            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Storing only order ids, subscription will be filter with SOQL
                if (orderSuccessIds.contains(recId)) {
                    perStepSuccessIds.orderIds.add(recId);
                    //check if subscription record else failure
                } else if (!subsSuccessIds.contains(recId)) {isFailed = true;
                    //Failure
                    
                }
            }
            system.debug('pendingStep ' +pendingStep);
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
               // stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }
            
            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).orderIds != null) {
                perStepSuccessIds.orderIds.addAll(processedIds.get(stepId).orderIds);
            }
            String serializedIds = JSON.serialize(perStepSuccessIds, true);
            if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Partial records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress,JSON__c=serializedIds));
                //stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Unable to process records',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,JSON__c=serializedIds));
               // stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
    }
    
    
    
   /* public boolean hasDMLRowsLimitExceeded() {
        if (updateOrderMap.size() + updateSubsMap.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }*/
    
    private void runAggregateProgram(List<csord__Subscription__c> subList){
        Set<Id>orderIds = new Set<Id>();
        Map<String,Integer> statCount = new Map<String,Integer>();
        
        //List<csord__Order__c>orderList = Coms_PlatformCacheUtil.getOrderFromCache(orderIds);
        for(csord__Subscription__c subOrd:subList){
            if(subOrd.csord__Status__c!=null){
                String status = subOrd.csord__Status__c;
                system.debug('subOrd '+status);
                Id ordId=subOrd.csord__Order__c;
                if (!orderSubscriptionCntMap.containsKey(ordId)) {
                orderSubscriptionCntMap.put(ordId, 0);
            } else {
                orderSubscriptionCntMap.put((ordId), orderSubscriptionCntMap.get(ordId) + 1);
            }
                
                if(!statCount.containsKey(status)){
                    statCount.put(status,0);
                }
                Integer currentInt=statCount.get(status)+1;
                statCount.put(status,currentInt);

                     
            if (status.equals(OrchestratorConstants.SubscriptionStatus.CancellationInProgress)) {
                cancellationInProgressMap.put(ordId, statCount.get(status));
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Failed)) {
                failedMap.put(ordId, statCount.get(status));
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Active)) {
                activeMap.put(ordId, statCount.get(status));
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Inactive)) {
                inActiveMap.put(ordId, statCount.get(status));
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Cancelled)) {
                cancelledMap.put(ordId, statCount.get(status));
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.BillingComplete)) {
                billingCompleteMap.put(ordId, statCount.get(status));
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Suspended)) {
                suspendedMap.put(ordId, statCount.get(status));
            }  else if (status.equals(OrchestratorConstants.SubscriptionStatus.PaidOut)) {
                paidOutMap.put(ordId, statCount.get(status));    //EDGE-163712
            }  else if(status.equals('Closed')) {//status.equals(OrchestratorConstants.SubscriptionStatus.PaidOut)) {
                closedMap.put(ordId, statCount.get(status));    //EDGE-177027
            }
            //Initializing to zero
            if (!cancellationInProgressMap.containsKey(ordId)) {
                cancellationInProgressMap.put(ordId, 0);
            }
            if (!failedMap.containsKey(ordId)) {
                failedMap.put(ordId, 0);
            }
            if (!activeMap.containsKey(ordId)) {
                activeMap.put(ordId, 0);
            }
            if (!inActiveMap.containsKey(ordId)) {
                inActiveMap.put(ordId, 0);
            }
            if (!cancelledMap.containsKey(ordId)) {
                cancelledMap.put(ordId, 0);
            }
            if (!billingCompleteMap.containsKey(ordId)) {
                billingCompleteMap.put(ordId, 0);
            }
            if (!suspendedMap.containsKey(ordId)) {
                suspendedMap.put(ordId, 0);
            }
            if (!paidOutMap.containsKey(ordId)) {//EDGE-163712
                paidOutMap.put(ordId, 0);
            }
            if (!closedMap.containsKey(ordId)) {//EDGE-177027
                closedMap.put(ordId, 0);
            }
            }
        }
    }
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