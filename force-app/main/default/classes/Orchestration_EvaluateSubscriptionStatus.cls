/*
Change.No.    Developer Name          Date          Story Description
1.            Prajakta              11/08/2020      EDGE-164012
2.      Pawan Devaliya               17/08/2020   EDGE-163712 : Changes for PayOut 
3.      Pawan Devaliya              14/09/2020    EDGE-164355 : set value of Trigger_RTS field on subscription
4.      Pawan Devaliya              28/09/2020    EDGE-179613: isBillable should be true when device care is cancelled within 30 days
5.      Pawan Devaliya              15/10/2020    EDGE-184285 fix
6.      Pawan                       28-10-2020      EDGE-177027 : For blank sim updating subscription status to closed if all services have status closed
7.      Pooja Gupta                 25-11-2020      EDGE-180743 : Enhance fulfilment service specification state lifecycle for suspend/resume orders
8.      Vaibhav                     12-01-2021      EDGE-197664 : NGUC Transition_RTB triggered fix for business calling.
9.      Pawan                       12-03-2021  EDGE-189976 : added Billrediness status to handle missing scenario 
10.     Mahima Gandhe               16-03-2021      DPG-4545, Suspend and Resume for AM Plan
11.     Akanksha                    25/03/2021  EDGE-202436 :added changes for No Fault return order to update RTS on device and device care
12. Pawan                           17-04-2021      B2B-328 : Sol suppress changes- removed part related to sol subs updated and added update for individual subscriptions
13. Prajakta                        01-06-2021      SVT Fix
14.     Gnana                       08-06-2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
*/

global with sharing class Orchestration_EvaluateSubscriptionStatus extends Orchestration_AbstractStepHandler {
    
  private List<CSPOFA__Orchestration_Step__c> stepList= new List<CSPOFA__Orchestration_Step__c>();
  private String IncompleteStepId = '';
  private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
  private Map<Id,csord__Subscription__c> subscriptionMap = new Map<Id,csord__Subscription__c>();
   private Map<Id,csord__Subscription__c> legacysubscriptionMap = new Map<Id,csord__Subscription__c>();
  private Set<Id> subscriptionIdSet = new Set<Id>();
  private Set<Id> subscriptionSolutionAssociationIds = new Set<Id>();
  private Map<Id, List<csord__Service__c>> subServiceMap = new Map<Id, List<csord__Service__c>>();
  private Map<Id, csord__Subscription__c> solutionToParentSubMap = new Map<Id, csord__Subscription__c>(); 
  private Map<String, Non_Legacy_Product__mdt > NonLegacymetadataMap = new Map<String, Non_Legacy_Product__mdt >();
  private Map<Id, set<String>> legacySubMap = new Map<Id, Set<String>>();
  private Map<Id, boolean> SubIdRTSFlagMap = new Map<Id, boolean>();
  
  public override List<SObject> process(List<SObject> data){

    List<SObject> sobjList=new List<SObject>(); // Added as part of EDGE-222326
      if(Orchestration_LimitsUtility.areLimitsViolated()){        
          system.debug('stopping execution as limit breached.....');
          //return null; // Commented as part of EDGE-222326
          return sobjList; // Added as part of EDGE-222326
      }
      try{   
          
          stepList= (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
          System.debug('step size '+stepList.size());
          //getRelatedServiceIds(stepList);
          runDataCollectionSOQLs();
          
          for(CSPOFA__Orchestration_Step__c step : stepList) {
              try {
                  
                  if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c == null) {
                      stepResults.put(step.Id, new stepResult('Error: Step is not related to a service', OrchestratorConstants.OrchestratorStep.Error));
                      continue;
                  }
                  if (Orchestration_LimitsUtility.areLimitsViolated()) {break;                      
                  }
                  Boolean isBillable = false;
                  Boolean changeStatus = true;
                  Boolean updateSolutionSubscription = false;
                  
                  Map<String,String> statusMap = new Map<String,String>();
                  csord__Subscription__c subscriptioToUpdate = subscriptionMap.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);
                  
                  system.debug('subscriptioToUpdate====>>>>'+subscriptionMap.keyset()+'----====');
                  
                  String updatedStatus = 'Provisioning In Progress';
                  String updatedSubStatus = '';
                  
                  isBillable = checkIsBillable(subscriptioToUpdate);          
                  System.debug('--Is Billable--' + isBillable);          
                  changeStatus = checkchangeStatus(subscriptioToUpdate);
                  system.debug('changeStatus57'+changeStatus);
                  system.debug('subServiceMap60'+subServiceMap);

                  if(subscriptioToUpdate.legacy_subscription__c != null){
                      
                      statusMap = getSubscriptionStatus(subServiceMap.get(subscriptioToUpdate.Id),'true',true, isBillable);
                      //added as part of legacy services fix
                      system.debug('subscriptioToUpdate68'+subscriptioToUpdate.legacy_subscription__c);
                      system.debug('legacysubscriptionMap'+legacysubscriptionMap);
                      Boolean checkBillable = checkIsBillable(legacysubscriptionMap.get(subscriptioToUpdate.legacy_subscription__c));
                      system.debug('checkBillable69'+checkBillable);
                      system.debug('legstat' + subscriptioToUpdate.legacy_subscription__r.csord__Status__c);
                      if(subscriptioToUpdate.legacy_subscription__r.csord__Status__c != 'Provisioned' && checkBillable){
                          subscriptioToUpdate.legacy_subscription__r.csord__Status__c = 'Provisioned';
              subscriptioToUpdate.legacy_subscription__r.triggerBill_RTB__c = true; // sol supress
              sObjectsToUpdate.put(subscriptioToUpdate.legacy_subscription__c, subscriptioToUpdate.legacy_subscription__r);
                         
                          system.debug('sObjectsToUpdate71'+sObjectsToUpdate);
                      }

                      system.debug('statusMap60'+statusMap);
                      system.debug('abed1');
                      //system.debug('subscription changeType**' + subscriptioToUpdate.changeType__c);
                  } //else if(subscriptioToUpdate.csord__Order__c != null && subscriptioToUpdate.csord__Order__r.name != null && subscriptioToUpdate.csord__Order__r.name.containsIgnoreCase('Resume')){ //EDGE-164012
                      else if(subscriptioToUpdate.csord__Order__c != null && subscriptioToUpdate.changeType__c != null && subscriptioToUpdate.changeType__c.containsIgnoreCase('Resume') && subscriptioToUpdate.Suspension_reason_summary__c=='' ){//EDGE-180743 
                         
                          statusMap.put('status','Active');
                      statusMap.put('subStatus','Active');  //TODO: Put story number and replace this for strategic fix. Action on Prajakta               
                  } else {
                      if(changeStatus){ 
                          statusMap = getSubscriptionStatus(subServiceMap.get(subscriptioToUpdate.Id), subscriptioToUpdate.toBeCancelled__c, subscriptioToUpdate.Is_Bill_Stopped__c, isBillable);
                          system.debug('statusMap66'+statusMap);
                      }
                  }
                   system.debug('statusMap69'+statusMap);
                  if (sObjectsToUpdate.containsKey(subscriptioToUpdate.Id) || (!statusMap.isEmpty() && statusMap.get('status') == subscriptioToUpdate.csord__Status__c)){
                      //TODO check for solution subscription data as well
                      stepResults.put(step.Id, new stepResult('Success: No Updation required as subscription already updated', OrchestratorConstants.OrchestratorStep.Complete));
                      continue;
                  } else if(!statusMap.isEmpty() && statusMap.get('status') !=null && (statusMap.get('status') != subscriptioToUpdate.csord__Status__c)){
                      if(String.isNotBlank(subscriptioToUpdate.Suspension_reason__c)){ //Removed the condition && subscriptioToUpdate.Suspension_reason__c.containsIgnoreCase('Requested by') For DPG- 4545 Mahima
                          updatedStatus = 'Suspended';
                          updatedSubStatus = 'Suspended';
                      /*}else if(subscriptioToUpdate.csord__Order__c != null && subscriptioToUpdate.csord__Order__r.name != null && subscriptioToUpdate.csord__Order__r.name.containsIgnoreCase('Resume')){  // EDGE-164012 start
                        subscriptioToUpdate.csord__Status__c = 'Active';
                        subscriptioToUpdate.Sub_Status__c = 'Active'; // EDGE-164012 end*/
                        } else {
                          updatedStatus = statusMap.get('status');
                          updatedSubStatus = statusMap.get('subStatus');
                      } 
                      

                  } /*else if((statusMap.isEmpty() || statusMap == null || (!statusMap.isEmpty() && statusMap.get('status') == null ))&& !changeStatus){

                      system.debug('Inside If');
                      updatedStatus = 'Provisioned';
                  }*/

          system.debug('subscriptioToUpdate.csord__Status__c91'+subscriptioToUpdate.csord__Status__c);
          system.debug('updatedStatus92'+updatedStatus);
                  if (subscriptioToUpdate.csord__Status__c != updatedStatus && subscriptioToUpdate.csord__Status__c!='Active' && subscriptioToUpdate.csord__Status__c!='Bill Readiness In Progress' && subscriptioToUpdate.csord__Status__c!='Billing Pending' && subscriptioToUpdate.csord__Status__c!='Failed') { //svt fix
                      if (!hasDMLRowsLimitExceeded()) {
              system.debug('insideif93');
                         if(!subscriptioToUpdate.toBeCancelled__c.equalsIgnoreCase('true')){
                          subscriptioToUpdate.csord__Status__c = updatedStatus;
                          subscriptioToUpdate.Sub_Status__c = updatedSubStatus;
                         }
                         else{
                             if(subscriptioToUpdate.csord__Status__c != 'Inactive' && subscriptioToUpdate.csord__Status__c != 'Bill Readiness In Progress'){
                                subscriptioToUpdate.csord__Status__c = updatedStatus;
                                subscriptioToUpdate.Sub_Status__c = updatedSubStatus;    
                             }
                         } 
                          //EDGE-164355 : When logical deactivation substage is not received, setting Trigger_TRS to true if device PayOut(Parent) + Cancel(Child) as cease orchestration will be created 
                          System.debug('SubIdRTSFlagMap 101'+SubIdRTSFlagMap);
                          if(SubIdRTSFlagMap.get(subscriptioToUpdate.id) != null && !subscriptioToUpdate.Trigger_RTS__c){
                              subscriptioToUpdate.Trigger_RTS__c = true;
                          }
                          
              //Sol Supress : Only considering individual subs from next if, commenting sol subs part
              if(updatedStatus == 'Provisioned'){
                                  subscriptioToUpdate.triggerBill_RTB__c = true;
                              }
                          sObjectsToUpdate.put(subscriptioToUpdate.Id, subscriptioToUpdate);
                          if (!stepRelationshipMap.containsKey(step.Id)) {
                              stepRelationshipMap.put(step.Id, new List<String>{ subscriptioToUpdate.Id });
                          } else { stepRelationshipMap.get(step.Id).add(subscriptioToUpdate.Id);
                          }
              
               System.debug('subscriptioToUpdate :: '+subscriptioToUpdate);
              System.debug('solutionToParentSubMap :: '+solutionToParentSubMap);
              //Sol supress :  For blank SIM updating sol subs to closed
              if((updatedStatus == 'Closed' || updatedStatus == 'Active') && !solutionToParentSubMap.isEmpty() && solutionToParentSubMap.containsKey(subscriptioToUpdate.cssdm__solution_association__c)){
                csord__Subscription__c solutionSubscriptionToUpdate = solutionToParentSubMap.get(subscriptioToUpdate.cssdm__solution_association__c);
                if(updatedStatus == 'Closed'){
                 solutionSubscriptionToUpdate.csord__Status__c = 'Closed'; 
                      }
                else if(updatedStatus == 'Active'){solutionSubscriptionToUpdate.csord__Status__c = 'Active';  
                  }
                  
             
                          sObjectsToUpdate.put(solutionSubscriptionToUpdate.Id, solutionSubscriptionToUpdate);
                          if (!stepRelationshipMap.containsKey(step.Id)) {
                              stepRelationshipMap.put(step.Id, new List<String>{ solutionSubscriptionToUpdate.Id });
                          } else { stepRelationshipMap.get(step.Id).add(solutionSubscriptionToUpdate.Id);
                          }
                          }
                          
                      } else {
              system.debug('else111');
                          IncompleteStepId = step.Id;break;
                      }
                  }
                  system.debug('updatedStatus113'+updatedStatus);
                  system.debug('stepRelationshipMap:'+stepRelationshipMap);
                  system.debug('IncompleteStepId:'+IncompleteStepId);
                   system.debug('step.Id:'+step.Id);
                  //These will be marked as Complete directly
                  if ((IncompleteStepId == '' || IncompleteStepId != step.Id) && !stepRelationshipMap.containsKey(step.Id)) {
                      //Updating steps as complete where no processing required
                     system.debug('Inside if:');
                      stepResults.put(step.Id, new stepResult('Success: No records required processing under the step', OrchestratorConstants.OrchestratorStep.Complete));
                  }
                  
              } catch (Exception ex) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
              } 
          }
      } catch(Exception ex) {
          for(CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) data) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
          }
      }
      system.debug('sObjectsToUpdate192'+sObjectsToUpdate);
      if (sObjectsToUpdate.size() + sObjectsToUpdate.size() > 0) {
       system.debug('sObjectsToUpdate194'+sObjectsToUpdate);
          updateObjects();
      }
      
      return processStepResults((List<CSPOFA__Orchestration_Step__c>) stepList, stepResults);
  }
  
  @TestVisible
  private Map<String,String> getSubscriptionStatus(List<csord__Service__c> services, String isStopBillValue, Boolean isBillStopped, Boolean isBillable){
      String status = 'Provisioning In Progress';
      String subStatus = '';
      Map<String,String> statusMap = new Map<String,String>();
      Integer countInProgress = 0;
      Integer countcancellationInProgress = 0;
      Integer countFailed = 0;
      Integer countConnected = 0;
      Integer countDisconnected = 0;
      Integer countCancelled = 0;
      Boolean isStopBill=Boolean.ValueOf(isStopBillValue);
      Integer countPayOutConnected = 0; //EDGE-163712
      Integer countPayOutDisconnected = 0;  //EDGE-181559 : For full cancelled PayOut scenarios
      Integer countClosed = 0;  //EDGE-177027 : Terminal status for blank Sim order scenario is closed
      Integer countNoFaultRet =0; // EDGE-202436 no fault return counter var
           
      system.debug('isBillable175'+isBillable);
      for(csord__Service__c service: services){
          
          //for Any child service status is In Progress or Cancellation In Progress
          if(service.csord__Status__c == 'In Progress'){
              status = 'Provisioning In Progress';
                system.debug('abed4');
              statusMap.put('status',status);
              return statusMap;
          }
          
          //for All child services status
          if (service.csord__Status__c == 'Cancellation In Progress')
              countcancellationInProgress = countcancellationInProgress+1;
          else if (service.csord__Status__c == 'Failed')
              countFailed = countFailed +1;
          else if (service.csord__Status__c == 'Connected' && service.Action_Type__c == 'PayOut')       //EDGE-163712
              countPayOutConnected = countPayOutConnected +1;         
          else if (service.csord__Status__c == 'Disconnected' && service.Action_Type__c == 'PayOut')       //EDGE-181559
              countPayOutDisconnected = countPayOutDisconnected +1;               
          else if ((service.csord__Status__c == 'Disconnected'|| service.csord__Status__c == 'Connected') && (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('No Fault Return'))) //EDGE-202436
              countNoFaultRet = countNoFaultRet +1;
          else if (service.csord__Status__c == 'Connected')
              countconnected = countconnected +1;
          else if (service.csord__Status__c == 'Disconnected')
              countDisconnected = countDisconnected +1;
          else if (service.csord__Status__c == 'Cancelled')
              countcancelled = countcancelled +1;     
          else if (service.csord__Status__c == 'Closed')    //EDGE-177027
              countClosed = countClosed +1;    
          
          
      }
      system.debug('countcancellationInProgress'+countcancellationInProgress);
       system.debug('countFailed'+countFailed);
        system.debug('countconnected'+countconnected);
      system.debug('countDisconnected'+countDisconnected);
       system.debug('countcancelled'+countcancelled);
       system.debug('countClosed : '+countClosed);
    system.debug('countNoFaultRet : '+countNoFaultRet);
      
      if(services.size() == countClosed){   //EDGE-177027 updating subscription status to Closed if all the services have Status Closed
          status = 'Closed';
      }   
      else if(services.size() == countcancellationInProgress){
          status = 'Cancellation In Progress';
      }
      else if(services.size() == countFailed){
          status = 'Failed';
      }
      else if(countconnected != 0 && ((services.size() == (countconnected + countDisconnected + countcancelled) && isBillable == true) || (services.size() != countconnected && services.size() == (countconnected + countcancelled + countPayOutConnected)))){
          status = 'Provisioned';
          subStatus = 'Active';
          System.debug('Status Pro--'+status);
      }
       //EDGE-164355 & EDGE-181559 : When logical deactivation substage is not received, setting Trigger_TRS to true if device PayOut(Parent) + Cancel(Child) as cease orchestration will be created
       else if(isBillable == true && (( countPayOutDisconnected > 0 || countPayOutConnected > 0 || countNoFaultRet > 0) && (services.size() == (countDisconnected + countPayOutDisconnected + countPayOutConnected+countNoFaultRet)))) // EDGE-202436
       {
           //EDGE-164355
           boolean isTriggerRTSTrue = setTriggeRTSOnSubs(services);
          System.debug('SubIdRTSFlagMap 237'+SubIdRTSFlagMap);
           System.debug('isTriggerRTSTrue 237'+isTriggerRTSTrue);
          if(isTriggerRTSTrue){
          status = 'Provisioned';
          subStatus = 'Active';
          System.debug('Status Pro2--'+status);
          
          }
         
      } 
      else if(countconnected != 0 && services.size() == (countconnected + countDisconnected + countcancelled)){
          status = 'Active';
          subStatus = 'Active';
      }
      else if(countDisconnected == 0 && services.size()== countcancelled){
          status= 'Cancelled';
      }
      else if(countconnected == 0 && services.size() == (countDisconnected + countPayOutDisconnected) && (isStopBill)){//EDGE-189014 : added status for payOut disconnected notification
        System.debug('Inside 308');
              status = 'Provisioned';
              subStatus = 'Inactive';

      }
       else if(isBillable == true && countconnected != 0 && (services.size() == (countconnected + countPayOutDisconnected))){
           //EDGE-197447 : When Parent(Plan): non cancellation but fulfillment is there and only device is cancelled
            status = 'Provisioned'; subStatus = 'Active';
         
      }   
      if(services.size() == (countDisconnected + countcancelled)){
          //status = 'Inactive';
          subStatus = 'Inactive';
      }
     
      
      statusMap.put('status',status);
      statusMap.put('subStatus',subStatus);
      return statusMap;
  }
  
  
  public override List<sObject> getStepList(List<sObject> steps) {
      List<sObject> stepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.cssdm__solution_association__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.legacy_subscription__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.legacy_subscription__r.cssdm__solution_association__c  FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
  //added by vaibhav - added fields in soql for legacy
  for(CSPOFA__Orchestration_Step__c step: (List<CSPOFA__Orchestration_Step__c>)stepList){
    
    if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.cssdm__solution_association__c !=  null){
              subscriptionSolutionAssociationIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.cssdm__solution_association__c);
      }
    
          subscriptionIdSet.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);
  }
      System.debug('subscriptionSolutionAssociationIds : '+subscriptionSolutionAssociationIds);
      return stepList;
  }
  
  private void runDataCollectionSOQLs(){
      for(csord__Service__c service: [select id, csord__Subscription__c, csord__Subscription__r.cssdm__solution_association__c FROM csord__Service__c Where Id IN:serviceIds]){
          if(service.csord__Subscription__r.cssdm__solution_association__c !=  null){subscriptionSolutionAssociationIds.add(service.csord__Subscription__r.cssdm__solution_association__c);
          }
          subscriptionIdSet.add(service.csord__Subscription__c);
      }

      for(csord__Service__c service: [select id, name,csord__Service__c,toBeCancelled__c,csord__Subscription__r.Trigger_RTS__c, csord__Status__c, csord__Subscription__c, csord__Order__r.name, csord__Order__c,Action_Type__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c From csord__Service__c Where csord__Subscription__c IN:subscriptionIdSet]){

          if(!subServiceMap.containsKey(service.csord__Subscription__c)){
              subServiceMap.put(service.csord__Subscription__c, new List<csord__Service__c>{service});
          } else {
              subServiceMap.get(service.csord__Subscription__c).add(service);
          }
      }
      system.debug('subscriptionIdSet278'+subscriptionIdSet);
      //EDGE-164355 : added Trigger_RTS__c in query

      //EDGE-180743 added changeType__c in the query
      subscriptionMap = new Map<Id,csord__Subscription__c>([SELECT Id,Trigger_RTS__c, csord__Total_Recurring_Charges__c,csord__Total_One_Off_Charges__c, changeType__c, csord__Status__c, Sub_Status__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c,cssdm__solution_association__c, toBeCancelled__c, Is_Bill_Stopped__c, Suspension_reason__c, triggerBill_RTB__c, MarketableOffer__c, MarketableOffer__r.Config__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, legacy_subscription__c, legacy_subscription__r.csord__Status__c, csord__Order__c,csord__Order__r.name,legacy_subscription__r.MarketableOffer__c, legacy_subscription__r.MarketableOffer__r.Config__c, legacy_subscription__r.csord__Total_Recurring_Charges__c,legacy_subscription__r.csord__Total_One_Off_Charges__c,legacy_subscription__r.cssdm__solution_association__c, Suspension_reason_summary__c from csord__Subscription__c where cssdm__solution_association__c IN : subscriptionSolutionAssociationIds OR Id IN: subscriptionIdSet]);// EDGE-164012 query change



      system.debug('subscriptionMap.keyset===>>>'+subscriptionMap.keyset());
      for(Id subscriptionId : subscriptionMap.keySet()){
          csord__Subscription__c subscription = subscriptionMap.get(subscriptionId);
      
          if(String.isNotBlank(subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) && subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
              //solsub = subscription;
              solutionToParentSubMap.put(subscription.cssdm__solution_association__c, subscription);
          }
      
          if(subscription.legacy_subscription__c!=null){
        legacysubscriptionMap.put(subscription.legacy_subscription__c,subscription.legacy_subscription__r);
      }
          system.debug('legacysubscriptionMap368'+legacysubscriptionMap);
      }
      
      List<Non_Legacy_Product__mdt> NonLegacymetadataList= [select Id, Product_Spec_Code__c, Dependent_Transition__c from Non_Legacy_Product__mdt ];
      
      for(Non_Legacy_Product__mdt transMetadata : NonLegacymetadataList){
          NonLegacymetadataMap.put(transMetadata.Product_Spec_Code__c, transMetadata);
      }
      
      List<csord__Subscription__c> legacySubList = [select Id, legacy_subscription__c, legacy_subscription__r.cssdm__solution_association__c,csord__Status__c  from csord__Subscription__c where legacy_subscription__c IN :subscriptionIdSet];
      
      for(csord__Subscription__c legacysub : legacySubList){
          if(legacySubMap.containsKey(legacysub.legacy_subscription__c)){
              legacySubMap.get(legacysub.legacy_subscription__c).add(legacysub.csord__Status__c);
          }else{
              legacySubMap.put(legacysub.legacy_subscription__c, new Set<String> {legacysub.csord__Status__c});
          }
     // legacysubscriptionMap.put(legacysub.legacy_subscription__c,legacysub.legacy_subscription__r);
          //system.debug('legacysubscriptionMap368'+legacysubscriptionMap);
      }
  }
   
  
  private boolean checkIsBillable(csord__Subscription__c subscription){
      if(subscription!=null && (subscription.csord__Total_One_Off_Charges__c != null ) && (subscription.csord__Total_Recurring_Charges__c != null)){
          if((subscription.csord__Total_One_Off_Charges__c > 0) || (subscription.csord__Total_Recurring_Charges__c > 0)){return true;
          }
      }
      if(subscription!=null && subscription.MarketableOffer__c != null  && subscription.MarketableOffer__r.Config__c!= null){
          Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
          if(basketConfiguration.get('isConsumptionBasedCharge') != NULL && (Boolean)basketConfiguration.get('isConsumptionBasedCharge')){
              return true;
          }
      }
      //EDGE-179613 : when there is no charge redeemed on base order but device care is cancelled within 30 days then isbillable should be true
      if(subscription!=null && subServiceMap.get(subscription.id) != null ){
          for(csord__Service__c svc : subServiceMap.get(subscription.id)){
              if(svc.csordtelcoa__Product_Configuration__c!=null &&svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c!=null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c!=null &&  svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase( 'DMCAT_ProductSpecification_001208') && svc.toBeCancelled__c.equalsIgnoreCase('true')){return true;  
              }
              
            }
          }
      return false;          
  }
  
  private boolean checkChangeStatus(csord__Subscription__c subscription){
      String prodCode= subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
      system.debug('prodCode317'+prodCode);
      Non_Legacy_Product__mdt NonLegacymetada = NonLegacymetadataMap.get(prodCode);
      system.debug('NonLegacymetada319'+NonLegacymetada);
      system.debug('legacySubMap320'+legacySubMap);
      if(NonLegacymetada != NULL && NonLegacymetada.Dependent_Transition__c && legacySubMap.containsKey(subscription.Id)){
           system.debug('legacySubMap322'+legacySubMap);
          if(!( legacySubMap.get(subscription.Id).size() == 1 && legacySubMap.get(subscription.Id).contains('Inactive'))){ return false;
            
          }
          
      }
      return true;      
  }
  
  public override void updateObjects() {
      List<Id> subsSuccessIds = new List<Id>();
     system.debug('sObjectsToUpdate407'+sObjectsToUpdate);
      if (sObjectsToUpdate.size() > 0) {
          Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
       system.debug('updateResult410'+updateResult);
          for (Database.SaveResult rslt : updateResult) {
              if (rslt.isSuccess()) {
                  subsSuccessIds.add(rslt.getId());
              }
          }
      }
      for (Id stepId : stepRelationshipMap.keySet()) {
          
          Boolean isFailed = false;
          
          for (Id recId : stepRelationshipMap.get(stepId)) {
              if (!subsSuccessIds.contains(recId)) {
                  isFailed = true;  break;
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
  
  //EDGE-164355 : When logical deactivation substage is not received, setting Trigger_TRS to true if device PayOut(Parent) + Cancel(Child) as cease orchestration will be created
  public boolean setTriggeRTSOnSubs(List<csord__Service__c> services) {
      System.debug('Inside setRTS');
      boolean isTriggerRTSTrue = false;
      for(csord__Service__c service: services){
          System.debug('All 401 '+service.csord__Service__c  +' '+ service.Action_Type__c  +' '+ service.toBeCancelled__c.equalsIgnoreCase('true'));
          if(service.csord__Service__c == null && (service.Action_Type__c != null && (service.Action_Type__c == 'PayOut' || service.Action_Type__c.equalsIgnoreCase('No Fault Return'))) && service.toBeCancelled__c.equalsIgnoreCase('true')) //EDGE-202436
          {
              if(!service.csord__Subscription__r.Trigger_RTS__c){
                  SubIdRTSFlagMap.put(service.csord__Subscription__c, true);
                  isTriggerRTSTrue = true;
              }
              
          }
          
      }
return isTriggerRTSTrue;      
}

}