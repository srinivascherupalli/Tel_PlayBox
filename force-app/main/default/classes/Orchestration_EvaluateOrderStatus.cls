/**================================================================
* Appirio, Inc
* Name: Orchestration_EvaluateOrderStatus
* Description: Class to update Status of Orders and triggerBill_RTB__c field of Subscription
* Created Date: April 30, 2020
* Created By: Gaurang Maheshwari
 
 Prajakta   13/08/2020      EDGE-169360
 Pawan      02-Sep-2020     EDGE-163712
 Pawan      28-10-2020      EDGE-177027 : Updating order status to complete when all subscriptions reached 'Closed' status
 Pooja      25-11-2020      EDGE-180743 : Enhance fulfilment service specification state lifecycle for suspend/resume orders
 Gnana    11-01-2021    EDGE-197713 : Updating TriggerRFA flag to true
 Pawan      28-04-2021      EDGE-217066 : Added condition for subsc status canceleed + Active together
 Pawan      17-04-2021      B2B-328 : Sol suppress- commented code related to sol subs update
 Gnana      08-06-2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
==================================================================*/

global with sharing class Orchestration_EvaluateOrderStatus extends Orchestration_AbstractStepHandler {
    //Collection for the calculations
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
    
    /**************************************************************
Name: process
Parameters: List<SObject> steps
Return Type: List<SObject>
Description: Overriding the process method of ExecutionHandler interface
*******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        List<SObject> sobjList=new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            //return null; // Commented as part of EDGE-222326
            return sobjList; // Added as part of EDGE-222326
        }
        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            //Aggregate query for order status calculation
            runAggregateProgram();
            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step is not related to a subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    //Setting the current variable
                    currentStep = step.Id;
                    //Only order will be present in Json
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);                    
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    //Storing the Order related to the subscription
                    csord__Order__c orderRec;
                    string subsChangeType; //EDGE-180743
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c != null) {
                        orderRec = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r;
                        subsChangeType = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c;//EDGE-180743
                    } else if (
                        step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__c != null &&
                        step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c != null
                    ) {
                        orderRec = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r;
                        subsChangeType = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c;//EDGE-180743
                    }
                   
                    //Order processing will start and avoiding the processed order
                    if (
                        orderRec != null && !updateOrderMap.containsKey(orderRec.Id) &&
                        !(processedIds.containsKey(currentStep) &&
                          processedIds.get(currentStep).orderIds != null && processedIds.get(currentStep).orderIds.contains(orderRec.Id))) {
                        //if (updateOrderStatus(orderRec)) {//EDGE-180743
                        if (updateOrderStatus(orderRec, subsChangeType)) {//EDGE-180743
                            //Capturing the step where limit got
                            pendingStep = step.Id; break;
                            //Terminate the loop
                            
                        }
                    }
                    //These will be marked as Complete directly
                    if ((pendingStep == '' || pendingStep != step.Id) && !stepRelationshipMap.containsKey(currentStep)) {
                        //Updating steps as complete where no processing required
                        stepResults.put(step.Id, new stepResult('Success: No records required processing under the step', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                } catch (Exception ex) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }
        
        if (updateOrderMap.size() + updateSubsMap.size() > 0) {
            updateObjects();
        }
        
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
      
    private Boolean updateOrderStatus(csord__Order__c ord, string subsChangeType) {//EDGE-169360 added subsChangeType parameter
        String status = getOrderStatus(ord.Id);
            if(!ord.csord__Status2__c.equals(status) &&  (subsChangeType == null || !subsChangeType.containsIgnoreCase('Resume'))){//EDGE-180743
        //if (!ord.csord__Status2__c.equals(status) && !ord.name.containsIgnoreCase('Resume')) { // EDGE-169360
            ord.csord__Status2__c = status;
            
            if (status.equals(OrchestratorConstants.OrderStatus.Completed)) {  ord.csord__End_Date__c = Date.today();
            }
            
            //Storing Order records for updation
            if (!hasDMLRowsLimitExceeded()) {
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
    public override void updateObjects() {
        //Success DML order Ids
        List<Id> orderSuccessIds = new List<Id>();
        //Success DML subscription Ids
        List<Id> subsSuccessIds = new List<Id>();
        Set<String> orderIdSet = new Set<String>();
        
        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
        //Updating all the order records
        if (updateOrderMap.size() > 0) {
            updateResult = Database.update(updateOrderMap.values(), false);
            
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    orderSuccessIds.add(rslt.getId());
                    orderIdSet.add(rslt.getId());
                    
                }
            }
        }
        
        
        //Updating all the subscription records
        if (updateSubsMap.size() > 0) {
            updateResult = Database.update(updateSubsMap.values(), false);
            
            //Storing the subscription success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) { subsSuccessIds.add(rslt.getId());
                }
            }
        }
        
        //Start of DIGI-11210
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs_OrderSubmit','orderSubmitCompleted')){
            insertcompletedOrderLogs(orderIdSet);  
        }
        //End of DIGI-11210
        
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
            
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }
            
            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).orderIds != null) {
                perStepSuccessIds.orderIds.addAll(processedIds.get(stepId).orderIds);
            }
            
            if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
    }
    
    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
            Id,
            CSPOFA__Orchestration_Process__c,
            CSPOFA__Status__c,
            CSPOFA__Completed_Date__c,
            CSPOFA__Message__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.name,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.csord__Status2__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Status2__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__End_Date__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.csord__End_Date__c,
            JSON__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.triggerBill_RTB__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];//EDGE-180743 added change type in query
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            
            //Get orders related to the subscriptions
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            } else if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c);
            }
            
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }
        
        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds);
        }
        
        //Returning the step list
        return stepList;
    }
    
    public override boolean hasDMLRowsLimitExceeded() {
        if (updateOrderMap.size() + updateSubsMap.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
    
    private void runAggregateProgram(){
        //Aggregate query for order status calculation
        for (AggregateResult ar : [
            SELECT csord__Order__c order, COUNT(Id) subCnt, csord__Status__c status
            FROM csord__Subscription__c
            WHERE csord__Order__c IN :orderIds AND csord__Status__c != null
            GROUP BY csord__Order__c, csord__Status__c
        ]) {
            /*if (Orchestration_LimitsUtility.areLimitsViolated()) {
//Cannot create collections
return null;
}*//*not needed*/
            
            String status = (String) ar.get('status');
            Id ordId = (Id) ar.get('order');
            Integer subscriptionsCnt = (Integer) ar.get('subCnt');
            
            if (!orderSubscriptionCntMap.containsKey(ordId)) {
                orderSubscriptionCntMap.put(ordId, subscriptionsCnt);
            } else {
                orderSubscriptionCntMap.put((ordId), orderSubscriptionCntMap.get(ordId) + subscriptionsCnt);
            }
            
            if (status.equals(OrchestratorConstants.SubscriptionStatus.CancellationInProgress)) {
                cancellationInProgressMap.put(ordId, subscriptionsCnt);
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Failed)) {
                failedMap.put(ordId, subscriptionsCnt);
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Active)) {
                activeMap.put(ordId, subscriptionsCnt);
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Inactive)) {
                inActiveMap.put(ordId, subscriptionsCnt);
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Cancelled)) {
                cancelledMap.put(ordId, subscriptionsCnt);
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.BillingComplete)) {
                billingCompleteMap.put(ordId, subscriptionsCnt);
            } else if (status.equals(OrchestratorConstants.SubscriptionStatus.Suspended)) {
                suspendedMap.put(ordId, subscriptionsCnt);
            }  else if (status.equals(OrchestratorConstants.SubscriptionStatus.PaidOut)) {
                paidOutMap.put(ordId, subscriptionsCnt);    //EDGE-163712
            }  else if(status.equals('Closed')) {//status.equals(OrchestratorConstants.SubscriptionStatus.PaidOut)) {
                closedMap.put(ordId, subscriptionsCnt);    //EDGE-177027
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
    
    /*  
    * Method Name : insertcompletedOrderLogs
    * Author : Gautam Kumar
    * Jira : DIGI-11210
   */
    
    private static void insertcompletedOrderLogs(Set<String> orderIdSet){
        system.debug('G*G insertcompletedOrderLogs outer called');
        if(!orderIdSet.isEmpty()){
            
            List<csord__Order__c> orderList = Model_Order.getOrdersList(orderIdSet);
            
            if(!orderList.isEmpty()){
                system.debug('G*G insertcompletedOrderLogs called');
                for(csord__Order__c order : orderList){
                    if(order.csordtelcoa__Opportunity__c != null && order.Product_Basket__c != null){
                        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                    //Trim Product Basket from 18 digit to 15 digit
                     String ProductBasketId = order.Product_Basket__c!= null && String.ValueOf(order.Product_Basket__c).length()>= 15?
                     String.ValueOf(order.Product_Basket__c).subString(0,15) : '';
                     string correlationId = order.csordtelcoa__Opportunity__c+'-'+ProductBasketId;
                   //string correlationId = order.csordtelcoa__Opportunity__c+'-'+order.Product_Basket__c;
                                         
                        loggerdetailsMap.put('event','Order Completed');
                        loggerdetailsMap.put('OrderType',order.csordtelcoa__Opportunity__r.Type);
                        loggerdetailsMap.put('OrderStatus','Completed');
                        loggerdetailsMap.put('OrderId',order.Id);
                        TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'Orchestration_EvaluateOrderStatus');
                    }
                }
            }
        }
      
    }
    
}