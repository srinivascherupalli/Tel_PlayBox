/**================================================================ 
* Name: Orchestration_EvaluateChownAsset
* Description: Update chwon asset on chown orders with replaced data
* Created Date:28/06/2021
*  Story :EDGE-216816
* Created By: Prajakta
EDGE-216816     Prajakta     changes done for linking of asset record to outing order and it's status changes to chown Replaced
EDGE-229080    Prajakta     added changes for linking of asset to chown out order and cloning of asset to incoming order
DIGI-15938     Prajakta     Added all fields in SOQL for asset
DIGI-35047     Mukta       Removed Fields(STANDARD) from number SOQL
===================================================================*/

global with sharing class Orchestration_EvaluateChownAsset extends Orchestration_AbstractStepHandler {
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
     private Database.SaveResult[] result = new List<Database.SaveResult>();
    //Store multiple records for a step at a place, use set to avoid duplication
    private Map<Id, Set<Asset>> stepRelationshipMap = new Map<Id, Set<Asset>>();
    private Map<Id, List<csord__Service__c>> ordToServiceMap = new Map<Id, List<csord__Service__c>>();
    private Map<String,Asset> assetToUpdate = new Map<String,Asset>();
    private Map<String,Asset> assetToInsert = new Map<String,Asset>();
    private Id IncompleteStepId = null;
    private Map<String, List<Asset>> svcAssetListMap = new Map<String, List<Asset>>();
    Set<String> serNumSet = new Set<string>();
    private List<csord__Service__c>serList = new List<csord__Service__c>();
    private Map<String,List<Asset>> svcAssetListUpdatedMap = new Map<String,List<Asset>>();
  private Map<String,csord__service__c>SerNumServiceMap = new Map<String,csord__service__c>();
    
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

                  
                    for (csord__service__c ser : [SELECT Id,csord__Order__c,csord__Order__r.csord__Account__c,csordtelcoa__Replaced_Service__c,csordtelcoa__Replaced_Service__r.csord__Order__r.id,csordtelcoa__Replaced_Service__r.csordtelcoa__Replaced_Service__c,Action_Type__c,Scenario_Type__c,csordtelcoa__Service_Number__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Product_Configuration__c,csord__Subscription__c, csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csordtelcoa__Product_Configuration__c,csord__Subscription__r.Billing_Account__c ,csord__Order__r.id FROM csord__Service__c WHERE csord__Order__c IN :orderIds]) {
                        
                        if (ordToServiceMap.containsKey(ser.csord__Order__c)) {
                            ordToServiceMap.get(ser.csord__Order__c).add(ser);
                        } else {
                            ordToServiceMap.put(ser.csord__Order__c, new List<csord__service__c>{ ser });
                        }
            
          
                       
            serNumSet.add(ser.csordtelcoa__Service_Number__c);
                    
            serList.add(ser);
            SerNumServiceMap.put(ser.csordtelcoa__Service_Number__c,ser);      
                    } 


                    for(Asset aset : [select Id,Name,AccountId,AssetLevel,AssetProvidedById,AssetServicedById,IsCompetitorProduct,ContactId,Description,
                    DigitalAssetStatus,ExternalIdentifier,InstallDate,IsInternal,LocationId,ManufactureDate,ParentId,Price,Product2Id,ProductCode,
                    ProductDescription,ProductFamily,StockKeepingUnit,PurchaseDate,Quantity,RootAssetId,SerialNumber,Status,StatusReason,
                    Uuid,UsageEndDate,AssetID__c,AssetIDType__c,AssetInstanceID__c,Asset_Type__c,AssetUUID__c,csord__Asset_Value__c,csordtelcoa__Attribute_Field__c,csordtelcoa__Cancelled_By_Change_Process__c,csord__deliverable__c,csord__deliverable_line_item__c,csordtelcoa__Delta_Status__c,csord__External_Identifier__c,devicecareCaseId__c,csord__External_Identifier2__c,HerokuUpdateStatus__c,csord__Identification__c,OfferID__c,csord__Order__c,csord__Order_Line_Item__c,csord__Order_Request__c,Ownership__c,Product_Code__c,Product_Description__c,recoveryMethod__c,csordtelcoa__Replaced_Asset__c,csordtelcoa__Replacement_Asset__c,returnReasonType__c,csord__Service__c,csord__Service_Line_Item__c,Stock_Keeping_Unit__c,Subscription__c,TNowCaseId__c,csord__Service__r.csordtelcoa__Service_Number__c from Asset where csord__Service__r.csordtelcoa__Service_Number__c IN :serNumSet AND Status =:'Active']){//DIGI-15938
             if (!svcAssetListMap.containsKey(aset.csord__Service__r.csordtelcoa__Service_Number__c)) {
                                        svcAssetListMap.put(aset.csord__Service__r.csordtelcoa__Service_Number__c, new List<Asset>{aset});
                                }
                                else {
                                        svcAssetListMap.get(aset.csord__Service__r.csordtelcoa__Service_Number__c).add(aset);
                                    }          
            }
           
            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
        
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
                    
        
      IncompleteStepId = updateAssetForChownOut(step.id);
      system.debug('IncompleteStepId:'+IncompleteStepId);
        
        if(IncompleteStepId == null || IncompleteStepId != step.Id){
                    if (!stepRelationshipMap.containsKey(step.Id)) {
                       
                            stepResults.put(step.Id, new stepResult('Success - No update required as no data needed any update for this step', OrchestratorConstants.OrchestratorStep.Complete));
                        } else {stepResults.put(step.Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));}
                    }
            
            }
       
        }catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step1 : (List<CSPOFA__Orchestration_Step__c>) steps) {
            stepResults.put(step1.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}
        }
        
               if (!assetToUpdate.isEmpty()) { system.debug('assetToUpdate:'+assetToUpdate);
    updateObjects();}
  
        
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
  
  
  public Id updateAssetForChownOut (Id stepId){ //EDGE-229080- updating asset for chown out order as chown replaced 
              
        for(csord__service__c serv :serList){
      
      if (!Orchestration_LimitsUtility.areLimitsViolated() && !hasDMLRowsLimitExceeded()) {
                        
                if(!svcAssetListMap.isEmpty() && svcAssetListMap.get(serv.csordtelcoa__Service_Number__c)!= null){
                
                
                system.debug('svcAssetListMap:'+svcAssetListMap);
                List<Asset> assList = svcAssetListMap.get(serv.csordtelcoa__Service_Number__c);
                if (!assList.isEmpty()){
                for(Asset assObj :assList){
                    
                    system.debug('assObj:'+assObj);
                    assObj.csord__Service__c = serv.csordtelcoa__Replaced_Service__c;
                    assObj.Subscription__c = serv.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c;
          assObj.csord__Order__c = serv.csordtelcoa__Replaced_Service__r.csord__Order__r.id;
                    assObj.status = 'CHOWN Replaced';
                    assetToUpdate.put(assObj.AssetID__c,assObj);
          if (!svcAssetListUpdatedMap.containsKey(assObj.csord__Service__r.csordtelcoa__Service_Number__c)) {
                                        svcAssetListUpdatedMap.put(assObj.csord__Service__r.csordtelcoa__Service_Number__c, new List<Asset>{assObj});
                                }
                                else {
                                        svcAssetListUpdatedMap.get(assObj.csord__Service__r.csordtelcoa__Service_Number__c).add(assObj);
                                    }          
            
          system.debug('svcAssetListUpdatedMap:'+svcAssetListUpdatedMap);
                    
                     if (!stepRelationshipMap.containsKey(stepId)) {
                                    stepRelationshipMap.put(stepId, new Set<Asset>{ assObj });
                                } else {
                                    stepRelationshipMap.get(stepId).add(assObj);
                                }
                    
                }
                }
            }
            
            }
            else{
      return stepId;
      }       
                                      
     }
          
      IncompleteStepId = insertAssetForChownIn(stepId);            

    return IncompleteStepId;      
     }
     
     
     public Id insertAssetForChownIn(Id stepId){ //EDGE-229080- cloning of asset for chown in order as active
       
      system.debug('inside');
      if(!svcAssetListUpdatedMap.isEmpty()){
        for (String serNum : svcAssetListUpdatedMap.keyset()){
        
                            
                           if (!Orchestration_LimitsUtility.areLimitsViolated() && !hasDMLRowsLimitExceeded()) {
                             List<Asset> assetList = svcAssetListUpdatedMap.get(serNum);
                               
                            system.debug('svcAssetListUpdatedMap1:'+svcAssetListUpdatedMap);
             
                            if(!assetList.isEmpty()){      

                            for(Asset aset :assetList){
                                 Asset newasset = new Asset();
                                 newasset = aset.clone(); 

                                  newasset.csord__Service__c = SerNumServiceMap.get(serNum).id;
                                  newasset.Subscription__c = SerNumServiceMap.get(serNum).csord__Subscription__c;
                                  newasset.Status ='Active';
                                  newasset.AccountId =SerNumServiceMap.get(serNum).csord__Order__r.csord__Account__c;
                  newasset.csord__Order__c = SerNumServiceMap.get(serNum).csord__Order__r.id;
                  system.debug('newasset:'+newasset);
                                  assetToInsert.put(newasset.AssetID__c,newasset);

                                if (!stepRelationshipMap.containsKey(stepId)) {
                                    stepRelationshipMap.put(stepId, new Set<Asset>{ newasset });
                                } else {
                                    stepRelationshipMap.get(stepId).add(newasset);
                                }
                             
                            }
              
                            }
                        
              }else{
                
      return stepId;
      }   
      
     }  }
        
        return null;
     }
     
  
    
    public override void updateObjects() {

       List<Id> assetSuccessIds = new List<Id>();
     List<Id> successIds = new List<Id>();


    if (!assetToUpdate.isEmpty()) {

   system.debug('assetToUpdate'+assetToUpdate);
   
        Database.SaveResult[] updateResult = Database.update(assetToUpdate.values(), true);
    
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                assetSuccessIds.add(rslt.getId());
            }
        }
    }
  
    if (!assetToInsert.isEmpty()) {
          
            Database.SaveResult[] updateResult = Database.insert(assetToInsert.values(), true);
            result.addAll(updateResult);
           
        }
        
        for (Database.SaveResult rslt : result) {
            if (rslt.isSuccess()) {
                successIds.add(rslt.getId());
            }
        }
    
     Map<String, String> successIdentifiersMap = new Map<String, String>();
         for (String key : assetToInsert.keyset()) {
            String recordId = (String) assetToInsert.get(key).get('Id');
            if (successIds != null && recordId != null) {
                if (successIds.contains(recordId)) {
                    successIdentifiersMap.put(key, recordId);
                }
            }
        }
  
  
    for (Id stepId : stepRelationshipMap.keySet()) {
        
        Boolean isFailed = false;

    
    Set<Asset> asrec = stepRelationshipMap.get(stepId);
              for (Asset aset :asrec) {
          
           if (assetSuccessIds.contains(aset.Id) || successIdentifiersMap.containsKey(aset.AssetID__c)) {
            stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
          }
                    else{
                         stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Complete));

                    }
                }
           
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
        if (assetToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
    
}