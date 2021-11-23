/**================================================================ 
* Name: Orchestration_EvaluateChownNumber
* Description: Class to update service and subscriptions with service number and subscription number with replaced    data for chown orders 
* Created Date:02/03/2021
*  Story : EDGE-152473
* Created By: Prajakta

1. Prajakta       08/07/2021       EDGE-216816 :deepclone method changed to clone for numbers
2. Prajakta       05/08/2021       EDGE-229080 :clone done for single objects
3. DIGI-15938     Prajakta         Added all fields in SOQL for Number
4. DIGI-14128     20/09/2021       Chown Order Orchestration Changes
5. DIGI-14128     06/10/2021       updated numbergroupinsert method by apple team 
6. DIGI-35047     25/10/2021       Removed Fields(STANDARD) from number SOQL

===================================================================*/
global with sharing class Orchestration_EvaluateChownNumber extends Orchestration_AbstractStepHandler {
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
     private Database.SaveResult[] result = new List<Database.SaveResult>();
    //Store multiple records for a step at a place, use set to avoid duplication
    private Map<Id, Set<Number__c>> stepRelationshipMap = new Map<Id, Set<Number__c>>();
    private Map<Id, List<csord__Service__c>> ordToServiceMap = new Map<Id, List<csord__Service__c>>();
    private Set<Number__c> numberToUpdate = new set<Number__c>();
    private List<Number__c> numListToUpdate = new List<Number__c>();
    private Map<String,Number__c> mapNumRecord = new Map<String,Number__c>();
    private Id IncompleteStepId = null;
    private Map<String, List<Number__c>> svcNumberListMap = new Map<String, List<Number__c>>();
    Set<String> serNumSet = new Set<string>();
    Boolean isNgucChownEnabled = FeatureEligibilityChecker.determineFeatureEligiblity('NGUC_Chown','processNgucChown');
    Set<String> oldNumberGroupIdSet = new Set<string>();
   
    
    public override List<SObject> process(List<SObject> steps) {
        system.debug('steps:'+steps); 
        List<SObject> sobjList=new List<SObject>();  
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList;
        }
        
        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            system.debug('stepList:'+stepList);
            //Service Map Fething Records

                  
                    for (csord__service__c ser : [SELECT Id,csord__Order__c,csordtelcoa__Replaced_Service__c,Action_Type__c,Scenario_Type__c,csordtelcoa__Service_Number__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Product_Configuration__c,csord__Subscription__c, csordtelcoa__Product_Configuration__c,csord__Subscription__r.Billing_Account__c,csord__Subscription__r.csord__Account__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds]) {
                        
                        if (ordToServiceMap.containsKey(ser.csord__Order__c)) {
                            ordToServiceMap.get(ser.csord__Order__c).add(ser);
                        } else {
                            ordToServiceMap.put(ser.csord__Order__c, new List<csord__service__c>{ ser });
                        }
                       
                      serNumSet.add(ser.csordtelcoa__Service_Number__c);
                        
                    }           
                 
           //Removed Fields(STANDARD) from number SOQL as part of DIGI-35047
            for(Number__c numb1 : [Select ID,Account__c,Basket__c,BDS_Error_Message__c,BDS_EventId__c,Billing_Account__c,Billing_Accounts__c,Error_in_assigning_plan__c,Invoke_BDS_Notification__c,IsDisconnected__c,Locked_By__c,Number_Group__c,Product_Specification_Code__c,ReasonForLockUnlock__c,Service_Instance_Id__c,Status_LastModifiedDate__c,Plan_Name__c,Service_Number__c, Subscription_number__c,Mobile__c, Service_Id__c, Status__c, Start_Range__c, Type__c,End_range__c, Product_Configuration__r.Id,toBeCancelled__c,ListingCode__c,IMSI__c,is_Part_of_Range__c,isSimvalid__c,SimAvailabilityType__c,Number_Range__c,Offer__c,Plan_Type__c,Product_ID__c,Service_Qualification__c,Sim_Serial_Number__c,SIM_Type__c,Source_System__c,Transition_Id__c from Number__c where Service_Id__c IN:serNumSet AND(Status__c =:'Active' OR Status__c=:'CHOWN Replaced')]){//DIGI-15938
                if (isNgucChownEnabled && numb1.Mobile__c == 'Fixed') { // DIGI-14128 changes
                    oldNumberGroupIdSet.add(numb1.Number_Group__c);
                }
             if (!svcNumberListMap.containsKey(numb1.Service_Id__c)) {
                                        svcNumberListMap.put(numb1.Service_Id__c, new List<Number__c>{numb1});
                                }
                                else {
                                        svcNumberListMap.get(numb1.Service_Id__c).add(numb1);
                                    }          
            }
            
            system.debug('svcNumberListMap:'+svcNumberListMap);
            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                
                try {
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {break;
                    }
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    
                    //Check for data issue - order should be present
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null || ordToServiceMap == null || (ordToServiceMap.keyset()!=null && !ordToServiceMap.containskey(step.CSPOFA__Orchestration_Process__r.order__c))) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    
                    system.debug('ordToServiceMap:'+ordToServiceMap);
                        
                        for (csord__service__c service : ordToServiceMap.get(step.CSPOFA__Orchestration_Process__r.order__c)) {
                             
                            if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
                                //terminate the loop
                                IncompleteStepId = step.Id;
                                break;
                            }
                            
                            if(!svcNumberListMap.isEmpty() && svcNumberListMap.get(service.csordtelcoa__Service_Number__c)!= null){
                                 
                            List<Number__c> numList = svcNumberListMap.get(service.csordtelcoa__Service_Number__c);
                            
                            for(Number__c num :numList){

                                  Number__c numb = num.clone();//done  clone for single object at once
                                  numb.Product_Configuration__c = service.csordtelcoa__Product_Configuration__c!= null ? service.csordtelcoa__Product_Configuration__c : null;
                                  // DIGI-14128 changes
                                  if (numb.Mobile__c != 'Fixed') {
                                    numb.Status__c = 'RESERVED';
                                  }
                                  if (isNgucChownEnabled && numb.Mobile__c == 'Fixed') {
                                     numb.Invoke_BDS_Notification__c = false;
                                     numb.Status__c = 'Active';
                                  }
                                  numb.Billing_Accounts__c = service.csord__Subscription__r.Billing_Account__c!= null ? 
                                  service.csord__Subscription__r.Billing_Account__c : null;
                                  // DIGI-14128 change
                                  numb.Account__c = service.csord__Subscription__r.csord__Account__c!= null ?
                                  service.csord__Subscription__r.csord__Account__c : null;

                                  numberToUpdate.add(numb);
                                  mapNumRecord.put(numb.Service_Number__c,numb);

                                if (!stepRelationshipMap.containsKey(step.Id)) {
                                    stepRelationshipMap.put(step.Id, new Set<Number__c>{ numb });
                                } else {
                                    stepRelationshipMap.get(step.Id).add(numb);
                                }
                             
                            }
                            
                          }  
                            
                        }  
                        
                    if(IncompleteStepId == null || IncompleteStepId != step.Id){
                    if (!stepRelationshipMap.containsKey(step.Id)) {
                       
                            stepResults.put(step.Id, new stepResult('Success - No update required as no data needed any update for this step', OrchestratorConstants.OrchestratorStep.Complete));
                        } else {stepResults.put(step.Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));}
                    }
                        
                }catch (Exception ex) {
                    for (CSPOFA__Orchestration_Step__c st : (List<CSPOFA__Orchestration_Step__c>) steps) {stepResults.put(st.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}
                }
            
            }
      
        }catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step1 : (List<CSPOFA__Orchestration_Step__c>) steps) {
            stepResults.put(step1.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}
        }
        
        
        if (!numberToUpdate.isEmpty()) {
            insertObjects();
        }
        
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    
    public override void insertObjects() {
        system.debug('numberToUpdate:'+numberToUpdate);
        if (numberToUpdate.size() > 0) {
            numListToUpdate.addAll(numberToUpdate);
            // DIGI-14128 changes
            insertNumberGroups();
            Database.SaveResult[] updateResult = Database.insert(numListToUpdate, false);
            result.addAll(updateResult);
           
        }
        
         List<Id> successIds = new List<Id>();
        for (Database.SaveResult rslt : result) {
            if (rslt.isSuccess()) {
                successIds.add(rslt.getId());
            }
        }
        
          Map<String, String> successIdentifiersMap = new Map<String, String>();
         for (String key : mapNumRecord.keyset()) {
            String recordId = (String) mapNumRecord.get(key).get('Id');
            if (successIds != null && recordId != null) {
                if (successIds.contains(recordId)) {
                    successIdentifiersMap.put(key, recordId);
                }
            }
        }
        
         for (Id stepId : stepRelationshipMap.keySet()) {
             if(stepRelationshipMap.get(stepId)!= null){
             Set<Number__c> numrec = stepRelationshipMap.get(stepId);
              for (Number__c rec :numrec) {
                    if(successIdentifiersMap.containsKey(rec.Service_Number__c)){
                         stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                    }else{
                         stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Complete));

                    }
                }
              }
             }
        } 
         
/**************************************************************************************
****** Desc         : Method to create Number Groups before inserting numbers
****** Story        : DIGI-14128
****** Developer    : Puneeth Kamath
***************************************************************************************/
    public void insertNumberGroups() {
    
        List<Number_Group__c> numberGroupsToInsert = new List<Number_Group__c>();
        Map<Id,Id> oldAndNewNumberGroupIds = new Map<Id,Id>();
        if (isNgucChownEnabled && !oldNumberGroupIdSet.isEmpty()) {
            for (Number_Group__c ng : [Select id, Cut_Over_Date__c, Service_Number__c, Object_Specification_Code__c, OrderId__c, Pattern_Type__c, Product_Basket__c, Product_Configuration__c, Product_Family__c, Product_Specification_Code__c, RequestedCompletionDate__c, Scenario_Type__c, Service_Instance_Id__c, Service_Id__c, SiteID__c, Status__c, Subscription_Number__c, Total_Numbers_Completed__c, Total_Numbers_Reserved__c, Transition_Id__c from Number_Group__c where id=:oldNumberGroupIdSet]) {
                Number_Group__c newNg = ng.clone(false,false,false,false);
                newNg.Scenario_Type__c = 'CHOWN';
                numberGroupsToInsert.add(newNg);
            }

            if (!numberGroupsToInsert.isEmpty()) {
                Database.SaveResult[] insertResult = Database.insert(numberGroupsToInsert, false);
                result.addAll(insertResult); 
            }
                    
            for (Number_Group__c NG : numberGroupsToInsert) {
                oldAndNewNumberGroupIds.put(NG.getCloneSourceId(),NG.Id);
            }
        }

        for (number__c numb : numListToUpdate) {
            numb.Number_Group__c = oldAndNewNumberGroupIds.get(numb.Number_Group__c);
        } 
    }
    
    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.skipFulfillment__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        Set<String> stepIds = new Set<String>();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Get orders related to the steps
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {stepIds.add(step.Id);
            }
        }
        //Check if attachments is required
        if (stepIds.size() > 0) {getAttachmentList(stepIds);
        }
        
        //Returning the step list
        return stepList;
    }
    
    
    public override boolean hasDMLRowsLimitExceeded() {
        if (numberToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
    
}