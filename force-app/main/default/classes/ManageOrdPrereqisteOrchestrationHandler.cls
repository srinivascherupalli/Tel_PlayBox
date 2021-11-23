/*************************************************************************************
Name: ManageOrderPrereqisteOrchestrationHandler
Description: This class updated as part 66239 for OrderPrereqiste Process creation for primary order
************************************************************************************/
 
public with sharing class ManageOrdPrereqisteOrchestrationHandler{

    @Future
    public static void createOrchestrationProcessASYNC(List<String> orderIds){

        List<CSPOFA__Orchestration_Process_Template__c> processTemplates =   [SELECT Id, Name 
                                            FROM CSPOFA__Orchestration_Process_Template__c 
                                            WHERE Name = 'Order Pre Requisite PE Process' LIMIT 1];

        if ( !processTemplates.isEmpty() ) {

            List<CSPOFA__Orchestration_Process__c> processRecords = [SELECT Id, Name 
                                            FROM CSPOFA__Orchestration_Process__c 
                                            WHERE  Order__c IN :orderIds 
                                            AND CSPOFA__Orchestration_Process_Template__c =: processTemplates[0].Id];

            if ( processRecords.isEmpty() ){
                createOrchestrationProcess(orderIds);
            }
        }

        
    }

    public static void createOrchestrationProcess(List<String> orderIds){
        List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();
        String orderProcessName = 'Order Prerequisite Process';

        if(FeatureEligibilityChecker.determineFeatureEligiblity('Orchestration','batchProcess')){
            orderProcessName = 'Order Pre Requisite PE Process';
            System.Debug(' FeatureEligibilityChecker.determineFeatureEligiblity ENTERED Order Pre Requisite PE Process ==> ' );
        }

        List<CSPOFA__Orchestration_Process_Template__c> processTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name =:orderProcessName LIMIT 1];
        CSPOFA__Orchestration_Process_Template__c processTemplate = new CSPOFA__Orchestration_Process_Template__c();
        if(!processTemplates.isEmpty()){
            processTemplate = processTemplates[0];
        }
        if(!orderIds.isEmpty() && processTemplate.Id != null){
            for(String orderId: orderIds){
                CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
                newProcess.CSPOFA__Orchestration_Process_Template__c = processTemplate.Id;
                newProcess.Order__c = orderId;
                newProcess.CSPOFA__State__c = 'Active';
                newProcesses.add(newProcess);
            }
        }
        if(!newProcesses.isEmpty())
        {
            insert newProcesses;
        }
    }

    /*public static void createOrchestrationProcess2(Map<Id,csord__Order__c> OrdPreReqMap){
        List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();
        Map<Id,String> orchOrdMap = new Map<Id,String>();
        Map<String,String> orchNameIdMap = new Map<String,String>();
        Set<Id> orderIds = new Set<Id>();
        Set<String> templateNameSet = new Set<String>();
        for(csord__Order__c ord: OrdPreReqMap.values()){    
            orderIds.add(ord.Id);
            if(ord.csordtelcoa__Opportunity__c !=null && ord.csordtelcoa__Opportunity__r.Type != null && ord.csordtelcoa__Opportunity__r.Type == 'CHOWN'){
                orchOrdMap.put(ord.Id,'Chown Order Prerequisite Process');
                templateNameSet.add('Chown Order Prerequisite Process');
            }
            else{
                orchOrdMap.put(ord.Id,'Order Prerequisite Process');
                templateNameSet.add('Order Prerequisite Process');
            }
            
        }
        System.debug('orchOrdMap...'+orchOrdMap);
        System.debug('templateNameSet...'+templateNameSet);
        Map<Id, CSPOFA__Orchestration_Process_Template__c> processTemplatesMap = new Map<Id, CSPOFA__Orchestration_Process_Template__c>(
            [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name =:templateNameSet]);

        for(CSPOFA__Orchestration_Process_Template__c temp : processTemplatesMap.values()){
            orchNameIdMap.put(temp.Name,temp.Id);
        }
        System.debug('orchNameIdMap...'+orchNameIdMap);
        if(!orderIds.isEmpty() && orchNameIdMap != null){
            for(String orderId: orderIds){
                CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
                newProcess.CSPOFA__Orchestration_Process_Template__c = orchNameIdMap.get(orchOrdMap.get(orderId));
                System.debug('newProcess.CSPOFA__Orchestration_Process_Template__c...'+newProcess.CSPOFA__Orchestration_Process_Template__c);
                newProcess.Order__c = orderId;
                newProcess.CSPOFA__State__c = 'Active';
                newProcesses.add(newProcess);
            }
        }
        System.debug('newProcesses...'+newProcesses);
        if(!newProcesses.isEmpty())
        {
            insert newProcesses;
        }
    }*/
	public static void createChownOrchestrationProcess(Map<Id,csord__Order__c> ordChownMap){
List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();

String OrderChownProcessName = 'Chown Order Prerequisite Process';

List<CSPOFA__Orchestration_Process_Template__c> processTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name =:OrderChownProcessName LIMIT 1];
CSPOFA__Orchestration_Process_Template__c processTemplate = new CSPOFA__Orchestration_Process_Template__c();
if(!processTemplates.isEmpty()){
processTemplate = processTemplates[0];
}
if(!ordChownMap.isEmpty() && processTemplate.Id != null){
for(String orderId: ordChownMap.keyset()){
CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
newProcess.CSPOFA__Orchestration_Process_Template__c = processTemplate.Id;
newProcess.Order__c = orderId;
newProcess.CSPOFA__State__c = 'Active';
newProcesses.add(newProcess);
}
}
if(!newProcesses.isEmpty())
{
insert newProcesses;
}
}
}