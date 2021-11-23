/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateFnnDetails
 * Description: Class to update FNN Number based on the Service and Subscription
 * Created Date: June 09, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================
 Change.No.    Developer Name          Date          Story Description
 1.		       Milos Djordjevic        08/06/2021    EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
 */
 
global with sharing class Orchestration_UpdateFnnDetails extends Orchestration_AbstractStepHandler {
    //Step --> processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //Store multiple records for a step at a place
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Store the active step Id
    private String currentStep = '';
    //Keep track of Number updation
    private Map<Id, Number__c> updateNumberMap = new Map<Id, Number__c>();
    //Order --> Subscription --> Service
    private Map<Id, List<csord__Service__c>> ordToServiceMap = new Map<Id, List<csord__Service__c>>();
    //Product Configuration --> Subscription, considering 1:1 Mapping
    private Map<Id, csord__Subscription__c> prodConfigToSubsMap = new Map<Id, csord__Subscription__c>();
    //Product Configuration --> Service, considering 1:1 Mapping
    private Map<Id, csord__Service__c> prodConfigToServiceMap = new Map<Id, csord__Service__c>();
    //Number Map based on the product configuration of the service
    private Map<Id, List<Number__c>> prodConfigToNumberMap = new Map<Id, List<Number__c>>();
    //Added by Nikhil as part of EDGE-142544 (Keep track of Number Group updation records)
    private Map<Id, Number_Group__c> updateNumberGroupMap = new Map<Id, Number_Group__c>();
    //Added by Nikhil as part of EDGE-142544 (Number Group Map based on the product configuration of the service)
    private Map<Id, List<Number_Group__c>> prodConfigToNumberGroupMap = new Map<Id, List<Number_Group__c>>();
     //Added by Nikhil as part of EDGE-209571
    private Map<Id, Id> numberGroupAndProdConfigMap = new Map<Id, Id>();

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
	List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList; // Added as part of EDGE-222326
        }

        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);

            //Get Subscription --> Service Map
            for (csord__Service__c ser : [
                SELECT
                    id,
                    csordtelcoa__Service_Number__c,
                    csord__Subscription__c,
                    csord__Subscription__r.csord__Order__c,
                    csord__Subscription__r.Billing_Account__c,
                    csord__Subscription__r.csconta__Billing_Account__c,
                    csord__Subscription__r.csordtelcoa__Subscription_Number__c,
                    csord__Subscription__r.csordtelcoa__Product_Configuration__c,
                    csordtelcoa__Product_Configuration__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                    csordtelcoa__Product_Configuration__r.Marketable_Offer__c,
                    csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name,
                    // Added as part of EDGE-211087
                    csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,
                    csordtelcoa__Product_Configuration__r.Type__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c
                FROM csord__Service__c
                WHERE csord__Subscription__r.csord__Order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null
            ]) {
                if (!ordToServiceMap.containsKey(ser.csord__Subscription__r.csord__Order__c)) {
                    ordToServiceMap.put(ser.csord__Subscription__r.csord__Order__c, new List<csord__Service__c>{ ser });
                } else {
                    ordToServiceMap.get(ser.csord__Subscription__r.csord__Order__c).add(ser);
                }

                //Capturing the product configuration --> subscription
                if (ser.csord__Subscription__r.csordtelcoa__Product_Configuration__c != null) {
                    prodConfigToSubsMap.put(ser.csord__Subscription__r.csordtelcoa__Product_Configuration__c, ser.csord__Subscription__r);
                }

                //Capturing the product configuration --> service                
                // Added as part of EDGE-211087
                prodConfigToServiceMap.put(ser.csordtelcoa__Product_Configuration__c, ser);
                if (ser.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null){
                        prodConfigToServiceMap.put(ser.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c, ser); 
                }
            }
            //System.debug('prodConfigToSubsMap '+prodConfigToSubsMap);
            //System.debug('prodConfigToServiceMap '+prodConfigToServiceMap);
            //System.debug('ordToServiceMap '+ordToServiceMap);
            //Get Number based on the product configuration of the service
            for (Number__c num : [SELECT Id, Product_Configuration__c, Service_Id__c, Subscription_number__c,Number_Group__c FROM Number__c WHERE Product_Configuration__c IN :prodConfigToServiceMap.keySet()]) {
                if (!prodConfigToNumberMap.containsKey(num.Product_Configuration__c)) {
                    prodConfigToNumberMap.put(num.Product_Configuration__c, new List<Number__c>{ num });
                } else {
                    prodConfigToNumberMap.get(num.Product_Configuration__c).add(num);
                }
                //Added by Nikhil as part of EDGE-209571
                if(num.Number_Group__c !=null){
                    numberGroupAndProdConfigMap.put(num.Number_Group__c , num.Product_Configuration__c);
                }
            }
            
            //System.debug('prodConfigToNumberMap::: '+prodConfigToNumberMap);
            
            if(numberGroupAndProdConfigMap.size() > 0){
                //Added by Nikhil as part of EDGE-142544 Get Number Group based on the product configuration of the service
                for (Number_Group__c numGroup : [SELECT Id, Product_Configuration__c,Service_Instance_Id__c,OrderId__c, Service_Id__c, Subscription_number__c FROM Number_Group__c WHERE Id IN :numberGroupAndProdConfigMap.keySet()]) {
                    if (!prodConfigToNumberGroupMap.containsKey(numberGroupAndProdConfigMap.get(numGroup.Id))) {
                        prodConfigToNumberGroupMap.put(numberGroupAndProdConfigMap.get(numGroup.Id), new List<Number_Group__c>{ numGroup });
                    } else {
                        prodConfigToNumberGroupMap.get(numberGroupAndProdConfigMap.get(numGroup.Id)).add(numGroup);
                    }
                }
            }
           
            //Check if number are present for the updation
            if (prodConfigToNumberMap.size() == 0) {
                return populateStepResults('Success: No record related to the product configuration for processing', OrchestratorConstants.OrchestratorStep.Complete, stepList);
            }
          
            
            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
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

                    if (step.CSPOFA__Orchestration_Process__c != null && step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                        //Bulk Method - return true if limit hits
                        if (updateNumberDetails(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                            //Capturing the step where limit got
                            pendingStep = step.Id;
                            //Terminate the loop
                            break;
                        }
                        //Added by Nikhil as part of EDGE-142544 
                        //Bulk Method - return true if limit hits
                        if (prodConfigToNumberGroupMap.size() > 0 && updateNumberGroupDetails(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                            //Capturing the step where limit got
                            pendingStep = step.Id;
                            //Terminate the loop
                            break;
                        }

                        //These will be marked as Complete directly
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            //Updating steps as complete where no processing required
                            stepResults.put(step.Id, new stepResult('Success: No records required processing under the step', OrchestratorConstants.OrchestratorStep.Complete));
                        }
                    } else {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
                    }
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }

        if (updateNumberMap.size() > 0) {
            updateObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private Boolean updateNumberDetails(Id ordId) {
        for (csord__Service__c serv : ordToServiceMap.get(ordId)) {
            //Added conditions as part of EDGE-211087
            if ((serv.csordtelcoa__Product_Configuration__c != null && prodConfigToNumberMap.containskey(serv.csordtelcoa__Product_Configuration__c) && prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__c) == null) || (serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && prodConfigToNumberMap.containskey(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) && prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) == null)) {
                //Move to next Service
                continue;
            }
            
            // Added as part of EDGE-211087
            //System.debug('prodConfigToNumberMap::: '+prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c));
            list<Number__c>numberList=new list<Number__c>();
            if (serv.csordtelcoa__Product_Configuration__c != null && prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__c) != null){
                numberList.addAll(prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__c));
            }
            if (serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) != null) {
                numberList.addAll(prodConfigToNumberMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c));
            }
           

            for (Number__c num : numberList) {
                //Number are fetched based on service product configuration
                if (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).numberIds != null && processedIds.get(currentStep).numberIds.contains(num.Id))) {
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //limit got hit
                        return true;
                    }
                    // Added as part of EDGE-211087
                    if (prodConfigToServiceMap.containskey(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c)){
                        num.Product_Configuration__c = prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c).csordtelcoa__Product_Configuration__c;
                        num.Basket__c = prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c).csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c;
                    }
                    
                    // Changed as part of EDGE-211087
                    if (prodConfigToServiceMap.containskey(serv.csordtelcoa__Product_Configuration__c)){
                        num.Service_Id__c = prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__c).csordtelcoa__Service_Number__c;
                        num.Product_ID__c = prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__c).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                        num.Offer__c = prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__c).csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name;
                    }
                    //check if subscription of same production configuration is present
                    if (prodConfigToSubsMap.containsKey(serv.csordtelcoa__Product_Configuration__c)) {
                        num.Billing_Accounts__c = prodConfigToSubsMap.get(serv.csordtelcoa__Product_Configuration__c).csconta__Billing_Account__c;
                        num.Subscription_number__c = prodConfigToSubsMap.get(serv.csordtelcoa__Product_Configuration__c).csordtelcoa__Subscription_Number__c;
                    }

                    if (num != null) {
                        if (!hasDMLRowsLimitExceeded()) {
                            updateNumberMap.put(num.Id, num);
                            //Maintain the relationship
                            if (!stepRelationshipMap.containsKey(currentStep)) {
                                stepRelationshipMap.put(currentStep, new Set<Id>{ num.Id });
                            } else {
                                stepRelationshipMap.get(currentStep).add(num.Id);
                            }
                        } else {
                            //limit got hit
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    //Added below Method by Nikhil as part of EDGE-142544 for update Number Group Records
    private Boolean updateNumberGroupDetails(Id ordId) {
        for (csord__Service__c serv : ordToServiceMap.get(ordId)) {
            //Added conditions as part of EDGE-211087
            if ((serv.csordtelcoa__Product_Configuration__c != null && prodConfigToNumberGroupMap.containskey(serv.csordtelcoa__Product_Configuration__c) && prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__c) == null) || (serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && prodConfigToNumberGroupMap.containskey(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) && prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) == null)) {
                //Move to next Service
                continue;
            }
            // Added as part of EDGE-211087
            List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
            Set<Id> oldNumberGroupIds = new Set<Id>();
            Set<String> oldServiceInstanceId = new Set<String>();
            if (serv.csordtelcoa__Product_Configuration__c != null && prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__c) != null){
                numberGroupList.addAll(prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__c));
            }
            if (serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) != null) {
                numberGroupList.addAll(prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c));
                for(Number_Group__c numbGrp: prodConfigToNumberGroupMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c)){
                    oldNumberGroupIds.add(numbGrp.Id);
                    oldServiceInstanceId.add(numbGrp.Service_Instance_Id__c);
                }
            }
            for (Number_Group__c numGrp : numberGroupList) {
                //Number Group are fetched based on service product configuration
                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                    //limit got hit
                    return true;
                }                
                numGrp.OrderId__c = ordId;
                // Added as part of EDGE-211087
                numGrp.Service_Id__c = serv.csordtelcoa__Service_Number__c;
                numGrp.Product_Configuration__c = serv.csordtelcoa__Product_Configuration__c;
                if(oldServiceInstanceId.size() > 0 && !oldServiceInstanceId.contains(numGrp.Service_Instance_Id__c ) ){// we need to replace new service Instance Id with old value that is with O2A
                    numGrp.Service_Instance_Id__c = (new list<string>(oldServiceInstanceId))[0];
                }
                
                if(oldNumberGroupIds.Contains(numGrp.Id)){
                    numGrp.Scenario_Type__c = 'Modify';// newly added for EDGE-222787
                }
                //moved condition below to check for Cancel scenario
                if (serv.csordtelcoa__Product_Configuration__r.Type__c.equalsIgnoreCase('Cancel')) {
                    numGrp.Scenario_Type__c = 'Remove';
                }
                if (prodConfigToServiceMap.containsKey(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) && prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) != null) {
                    numGrp.Product_Basket__c = prodConfigToServiceMap.get(serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c).csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c;
                }
                //check if subscription of same production configuration is present
                if (prodConfigToSubsMap.containsKey(serv.csordtelcoa__Product_Configuration__c)) {
                    numGrp.Subscription_number__c = prodConfigToSubsMap.get(serv.csordtelcoa__Product_Configuration__c).csordtelcoa__Subscription_Number__c;
                }

                if (numGrp != null) {
                    if (!hasDMLRowsLimitExceeded()) {
                        updateNumberGroupMap.put(numGrp.Id, numGrp);
                    } else {
                        //limit got hit
                        return true;
                    }
                }
            }
        }
        return false;
    }
    /* END EDGE-142544*/

    /**
* @author Gaurang Maheshwari
* @description for updating the records related to the steps (Step is dependent on multiple records)
step with failed records --> Error AND put the success ids in JSON
step with all passed records -- > Complete
Step with partial records due to limit and all success --> In progress AND put the success ids in JSON
Step with partial records due to limit and failed records --> Error AND put the success ids in JSON
*/
    public override void updateObjects() {
        //Success DML number Ids
        List<Id> numberSuccessIds = new List<Id>();

        //Added below Method by Nikhil as part of EDGE-142544 
        List<Database.SaveResult> updateNumberGroupResult = Database.update(updateNumberGroupMap.values(), false);
        
        //Updating all the order records
        List<Database.SaveResult> updateResult = Database.update(updateNumberMap.values(), false);
        
        //Storing the number success Ids
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                numberSuccessIds.add(rslt.getId());
            }
        }

        //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the numberIds Set
            perStepSuccessIds.numberIds = new Set<String>();
            Boolean isFailed = false;

            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (numberSuccessIds.contains(recId)) {
                    perStepSuccessIds.numberIds.add(recId);
                } else {
                    //Failure
                    isFailed = true;
                }
            }

            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).numberIds != null) {
                perStepSuccessIds.numberIds.addAll(processedIds.get(stepId).numberIds);
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
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, JSON__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Fetching the order Set
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
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
        if (updateNumberMap.size() + updateNumberGroupMap.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}