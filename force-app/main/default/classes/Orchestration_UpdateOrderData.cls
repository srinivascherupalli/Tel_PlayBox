/**================================================================
* Name: Orchestration_UpdateOrderData
* Description: Class to update order details from platformcache to database
* ================================================================*/

global with sharing class Orchestration_UpdateOrderData extends Orchestration_AbstractStepHandler {
    private List<CSPOFA__Orchestration_Step__c> stepList= new List<CSPOFA__Orchestration_Step__c>();
    list<CSPOFA__Orchestration_Process__c> orderOrchesProcess =  new list<CSPOFA__Orchestration_Process__c>();
    Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = CS_OrchUtils.getorchesTemplates();
    private String IncompleteStepId = '';
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    public override List<SObject> process(List<SObject> data){
        stepList= (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
        getRelatedOrderIds(stepList);
        System.debug('###orderIds '+orderIds);
        List<csord__Order__c>ordList = [SELECT Id,LastModifiedDate from csord__Order__c where Id IN :orderIds];
        set<ID> subsId = new set<ID>();
        set<ID> servsId = new set<ID>();

        Map<Id,Boolean> isWrongCache = new Map<Id,boolean>();
        set<Id> serIds = new set<Id>();
        List<Object>technicalObjList=new List<Object>();                
        List<Attachment> attachList = new List<Attachment>();
        List<csord__Service__c> servList = new List<csord__Service__c>();
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        for(CSPOFA__Orchestration_Step__c step : stepList) {
            subsId.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);
            servsId.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c);
            servList = Coms_PlatformCacheUtil.getListofServicesFromCache(servsId);
            subList = Coms_PlatformCacheUtil.getListOfSubscriptionFromCache(subsId); 
            System.debug('####subList '+subList);
        	System.debug('####servList '+servList);
            for(csord__Order__c ord: ordList){
                //if(srv.IsUpdated == true){
                if (ord.LastModifiedDate <= ord.LastModifiedDate){
                    sObjectsToUpdate.put(ord.Id,ord);
                    stepRelationship.put(ord.Id, step.Id);
                }
                else{
                    isWrongCache.put(ord.id,true);
                } 
                
            }  
            
            
            for(csord__Service__c serv: servList){
                if (serv.LastModifiedDate <= serv.LastModifiedDate){
                    serIds.add(serv.id);
                    sObjectsToUpdate.put(serv.Id,serv);
                    stepRelationship.put(serv.Id, step.Id);
                }
                else{
                    isWrongCache.put(serv.csord__Order__c,true);
                }                   
            }
            
            for(csord__Subscription__c sub: subList){
                if (sub.LastModifiedDate <= sub.LastModifiedDate){
                    sObjectsToUpdate.put(sub.Id,sub);
                    stepRelationship.put(sub.Id, step.Id);
                }
                else{
                    isWrongCache.put(sub.csord__Order__c,true);
                    
                }                   
            }
            
            
            technicalObjList = Coms_PlatformCacheUtil.getListofTechnicalObjectFromCache(serIds);
            for(Attachment techObjItem: (List<Attachment>)technicalObjList){
                if(techObjItem.name=='ServiceSpecifications.json'){
                    sObjectsToUpdate.put(techObjItem.Id,techObjItem);
                    stepRelationship.put(techObjItem.Id, techObjItem.Id);
                    
                }
            } 
            
            
            for(csord__Order__c ord: ordList){
                
                if(isWrongCache.containsKey(ord.Id) && isWrongCache.get(ord.Id)==true){
                    String orderfulfilmentprocess = 'Order Fulfilment Process_New';
                    CSPOFA__Orchestration_Process__c orderorches = new CSPOFA__Orchestration_Process__c() ;
                    System.debug('###orchTemplate'+orchesTemplates);
                    orderorches = CS_OrchUtils.createOchestrationProcess(orchesTemplates.get(orderfulfilmentprocess).id,ord.Id,null,null);
                    orderOrchesProcess.add(orderorches);  
                }
            }
            
            
        }
        
        if(orderOrchesProcess.size()>0)
            insert orderOrchesProcess;
        updateObjectsFromPlatformCache();
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) stepList, stepResults);
    }
    public override List<sObject> getStepList(List<sObject> steps) {
        List<sObject> stepList = [SELECT ID, CSPOFA__Orchestration_Process__r.Order__c, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Step_Order__c, CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.cssdm__solution_association__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.legacy_subscription__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.legacy_subscription__r.cssdm__solution_association__c  FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
        
        return stepList;
    }
    public void updateObjectsFromPlatformCache() {
        
        
        if (sObjectsToUpdate.size() > 0) {           
            Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);            
            for (Database.SaveResult rslt : updateResult) {                
                if (rslt.isSuccess()) {
                    stepResults.put(stepRelationship.get(rslt.getId()),           
                                    new stepResult('Success: order records updated', OrchestratorConstants.OrchestratorStep.Complete)
                                   );
                } else {
                    //record updation failed there related step updated
                    stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to update records to database', OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        }       
    }
}