/**================================================================
 * Name: Orchestration_InflightSendMngOrd
 * EDGE-170545
 * Description: Class to send Manage order payload to AMDOCS and remediate rolledback subscriptions in case of inflight Orders
 * Created Date: Feb 22, 2021
 * Created By: Pawan Devaliya
===============================================================================================================================
1.   Pawan            08-Sep-2021        DIGI-18183: Added new parameter in payload : Fulfilment Order Version
===============================================================================================================================
*/

 global with sharing class Orchestration_InflightSendMngOrd extends Orchestration_AbstractStepHandler {
    //Store the response for creating the application logs for High Volume
    List<Orchestration_CallOutResponse> respWrapper = new List<Orchestration_CallOutResponse>();
    private Map<Id, List<csord__Service__c>> subServiceMap = new Map<Id, List<csord__Service__c>>();
    private Map<Id, List<csord__Subscription__c>> ordIdSubsMap = new Map<Id, List<csord__Subscription__c>>();
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
    private Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
    private Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>();
    private Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>();
    List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>(); 
    private String IncompleteStepId = '';
    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        //Limit check
        List<SObject> sobjList=new List<SObject>(); 
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList;
        }

        //Exception Handling
        try {
            //Type casting of steps
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
             getRelatedOrderIds(stepList);
             runDataCollectionSOQLs(); 
      
            //Processing the steps
            if (!Orchestration_Utility.HighVolumeOrderCheck()) {
                //nothing to publish, custom setting is off
                return populateStepResults('High Volume custom setting off therefore no processing required', OrchestratorConstants.OrchestratorStep.Complete, (List<CSPOFA__Orchestration_Step__c>) steps);
            }

            for (CSPOFA__Orchestration_Step__c step : stepList) {
            try {
                Boolean isEventToPublish = false;
                if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                    //Updating steps as Error since no proper data linked to step
                    stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                    //Check the next step
                    continue;
                }   
                if (!hasDMLRowsLimitExceeded()) {
                  if(ordIdSubsMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)){
                    
                    for(csord__Subscription__c subscription :ordIdSubsMap.get(step.CSPOFA__Orchestration_Process__r.Order__c)){
                            if(String.isNotBlank(subscription.Action_Type__c) && subscription.Action_Type__c.contains('Rollback')){
                                subscription.csord__Status__c =  getSubscriptionStatus(subscription);
                        
                                sObjectsToUpdate.put(subscription.Id, subscription);
                                if (!stepRelationshipMap.containsKey(step.Id)) {
                                        stepRelationshipMap.put(step.Id, new List<String>{subscription.Id});
                                }
                                else {
                                        stepRelationshipMap.get(step.Id).add(subscription.Id);
                                    }                        

                            }
                            else if(subscription.orderversion__c == step.CSPOFA__Orchestration_Process__r.Order__r.Fulfilment_Order_Version__c){
                                isEventToPublish = true;
                            }
                    }
                }
                
                if(orderMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c) && !isEventToPublish){
                    csord__Order__c ord = orderMap.get(step.CSPOFA__Orchestration_Process__r.Order__c);
                    ord.csord__Status2__c = 'In Progress';
                    sObjectsToUpdate.put(ord.Id, ord);
                    if (!stepRelationshipMap.containsKey(step.Id)) {
                        stepRelationshipMap.put(step.Id, new List<String>{ord.Id});
                    } else {
                        stepRelationshipMap.get(step.Id).add(ord.Id);
                    }                   
                }

                if(isEventToPublish){
                    sendManageOrder(orderMap.get(step.CSPOFA__Orchestration_Process__r.Order__c));
                }

                
            }
            else{
                IncompleteStepId = step.Id;
                break;
            }
    
            } catch (Exception ex) {
                System.debug('EXception1 '+ex.getMessage() + ' on line ' + ex.getLineNumber());
            stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
          }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }

        if (eventsToPublish.size() > 0 || !sObjectsToUpdate.isEmpty()) {

            updateObjects();
        }
        System.debug('stepResults 114 '+stepResults);
        System.debug('stepResults 115 '+steps);
        System.debug('processStepResults '+processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults));
        System.debug('stepResults 117 '+steps);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
        
    }

    private void sendManageOrder(csord__Order__c ord) {
        HighVolumeReadyToSubmitOrder__e highVolEvent = new HighVolumeReadyToSubmitOrder__e();
        highVolEvent.OrderID__c = ord.Id;
        highVolEvent.Order_Number__c = ord.csord__Order_Number__c;
        highVolEvent.CorrelationID__c = Orchestration_Utility.getUID();
        highVolEvent.Fulfilment_Order_Version__c= ord.Fulfilment_Order_Version__c; // DIGI-18183

        String StatusCode = '200';
        Orchestration_CallOutResponse res = new Orchestration_CallOutResponse(null, JSON.serialize(highVolEvent, true), null, statusCode, 'HighVolumeEvent', 'Integration', null, null, statusCode, null, null);
        respWrapper.add(res);
 
        //Putting the event in the list
        eventsToPublish.add(highVolEvent);
    }

    public override List<sObject> getStepList(List<sObject> steps) {
        //Fetching more fields from the query
        List<sObject> stepList = [SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.csord__Order_Number__c, CSPOFA__Orchestration_Process__r.Order__r.Fulfilment_Order_Version__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        return stepList;
    }

    public override boolean hasDMLRowsLimitExceeded() {
        if (eventsToPublish.size()+ sObjectsToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
    
     private void runDataCollectionSOQLs(){

        String serviceQuery = 'SELECT Id, Name, csord__Status__c,';
        serviceQuery += 'csord__Subscription__c ';
        serviceQuery += ' FROM csord__Service__c Where csord__Order__c IN:orderIds';    
        
        serviceMap = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(serviceQuery));
        
        for(csord__Service__c service :serviceMap.values()){
      if(!subServiceMap.containsKey(service.csord__Subscription__c)){
          subServiceMap.put(service.csord__Subscription__c, new List<csord__Service__c>{service});
      } else {
          subServiceMap.get(service.csord__Subscription__c).add(service);
      }
    }

        String subQuery = 'SELECT Id, Name, csord__Status__c,';
        subQuery += 'csord__Order__c, ';
        subQuery += 'orderversion__c, ';
        subQuery += 'Action_Type__c';
        subQuery += ' FROM csord__Subscription__c Where csord__Order__c IN:orderIds';   
        
        subMap = new Map<Id, csord__Subscription__c>((List<csord__Subscription__c>) Database.query(subQuery));
        
        for(csord__Subscription__c sub :subMap.values()){
      if(!ordIdSubsMap.containsKey(sub.csord__Order__c)){
          ordIdSubsMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{sub});
      } else {
          ordIdSubsMap.get(sub.csord__Order__c).add(sub);
      }
    }   
        
    String orderQuery = 'SELECT Id, Name, csord__Status2__c, csord__Order_Number__c,Fulfilment_Order_Version__c';
    orderQuery += ' FROM csord__Order__c Where Id IN:orderIds'; 
    
    orderMap = new Map<Id, csord__Order__c>((List<csord__Order__c>) Database.query(orderQuery));
  }
  
      @TestVisible
  private String getSubscriptionStatus(csord__Subscription__c subcription){
      
          Integer countSvcStatus = 0;
          String status = 'Provisioning In Progress';
          
          for(csord__Service__c service: subServiceMap.get(subcription.Id)){
              if(service.csord__Status__c == 'Connected' || service.csord__Status__c == 'Disconnected' || service.csord__Status__c == 'Paid Out'){
                  countSvcStatus = countSvcStatus +1;
              }
      }
      
      
      if(subServiceMap.get(subcription.Id).size() == countSvcStatus){
          status = 'Provisioned';
      }
      
      return status;
}

public override void updateObjects() {

    if (eventsToPublish.size() > 0) {

        publishObject(respWrapper);

        if (sObjectsToUpdate.isEmpty()) {
            System.debug('stepList : '+stepList);
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.id, new stepResult('Success: Events are enqueued', OrchestratorConstants.OrchestratorStep.Complete));
            }
    }
}
System.debug('stepResults 218: '+stepResults);
    if (!sObjectsToUpdate.isEmpty()) {

    List<Id> subsOrdSuccessIds = new List<Id>();
   system.debug('sObjectsToUpdate407'+sObjectsToUpdate);
    if (sObjectsToUpdate.size() > 0) {
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
     system.debug('updateResult410'+updateResult);
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                subsOrdSuccessIds.add(rslt.getId());
            }
        }
    }
    for (Id stepId : stepRelationshipMap.keySet()) {
        
        Boolean isFailed = false;
        
        for (Id recId : stepRelationshipMap.get(stepId)) {
            if (!subsOrdSuccessIds.contains(recId)) {
                isFailed = true;
                break;
            }
        }
        
        if (!isFailed && (String.isBlank(IncompleteStepId) || !IncompleteStepId.equals(stepId))) {
            stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
            //move to next step
            continue;
        }
        
        if (!isFailed && !String.isBlank(IncompleteStepId) && IncompleteStepId.equals(stepId)) {
            stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress));
        } else {
            stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
        }
    } 
}
System.debug('stepResults 256: '+stepResults); 
}

  
}