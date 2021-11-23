/**=====================================================================
 * @Story : EDGE-172952 - Error handling for failure order
 * @Modified By : Kamlesh Kumar
 * @Modified Date : 3rd Nov 2020
 * @Desc : Hybrid class that can be used as observer to start the batch logic.
 * Will be used as AfterOrderGenerated observer to:
 * 1. Start batch job (itself) to generate service specifications (high volume approach)
 * 2. Upon finishing will start PreRequisite orchestration process to handle the rest of
 * the logic needed for order post processing
 =======================================================================
 ===============================================================================================================================
Change.No.      Developer Name          Date            Story Description
1.              Shubhi V                31/03/2021      EDGE-209293 (chown order)
2.              Pooja Bhat              22/06/2021      EDGE-224638 Changed cssmgnt.API_1.linkSubscriptions api call to batch iteration cssmgnt.LinkSubscriptionsBatch to avoid CPU timeout exception for large volume MACD orders.
================================================================================================================================*/
global class OrderPostProcessing implements Database.Batchable<SObject>, Database.Stateful {
  
  public final csordtelcoa.OrderGenerationObservable observable;
  public List<Id> subscriptionIds = new List<Id>();
  public String query = '';
  public Set<Id> successOrderId = new Set<Id>();
  public Set<Id> failureOrderId = new Set<Id>();
  public Set<Id> ignoreOrderIds = new Set<Id>(); //EDGE-209293 added by shubhi

  global OrderPostProcessing() {
  }

  /**
  *@Description : Constructor for setting context for batch processing
  */
  public OrderPostProcessing(csordcb.ObserverApi.Observable o) {
      this.observable = (csordtelcoa.OrderGenerationObservable)o;
  }
  
  public OrderPostProcessing(csordcb.ObserverApi.Observable o,List<Id> subscriptionIds) {
      this.observable = (csordtelcoa.OrderGenerationObservable)o;
      this.subscriptionIds=subscriptionIds;
  }
  
  /* contructor with failure order ids */
  //EDGE-209293 added by shubhi
  public OrderPostProcessing(csordcb.ObserverApi.Observable o,Set<Id> ignoreOrderIds,List<Id> subscriptionIds) {
      this.observable = (csordtelcoa.OrderGenerationObservable)o;
      this.ignoreOrderIds=ignoreOrderIds;
      this.subscriptionIds=subscriptionIds;
  }

  /**
  *@Description : OBSERVER METHOD IMPLEMENTATIONS
  *@Method : executeBatch() - Start service specification generation logic
  */
  /*global void execute(csordcb.ObserverApi.Observable o, Object arg) {
      //EDGE-209293 added by shubhi start ----
      csordtelcoa.OrderGenerationObservable observable = (csordtelcoa.OrderGenerationObservable)o;
      subscriptionIds = observable.getSubscriptionIds();
      //Start: EDGE-224638 
      Integer scopeSize = (Governor_Limits__c.getInstance().Subscription_Relinking_Batch_Size__c != null ? Integer.valueof(Governor_Limits__c.getInstance().Subscription_Relinking_Batch_Size__c) : 200);
      cssmgnt.LinkSubscriptionsBatch linkSubBatch = new cssmgnt.LinkSubscriptionsBatch(subscriptionIds);  
      Database.executeBatch(linkSubBatch, scopeSize);
      //End: EDGE-224638 
      List<csord__Subscription__c> subscriptionList=new List<csord__Subscription__c>();
      if(subscriptionIds!=null && !subscriptionIds.isEmpty()){
          subscriptionList=Model_Subscription.getSubscriptions(new List<Id>(subscriptionIds));
      }
      Boolean isChown=false;
      if(subscriptionList!=null && !subscriptionList.isEmpty()){
          for(csord__Subscription__c sub:subscriptionList){
              if(String.isNotBlank(sub.csord__Order__r.csordtelcoa__Opportunity__r.Type) && sub.csord__Order__r.csordtelcoa__Opportunity__r.Type.containsIgnoreCase('CHOWN')){
                  isChown=true;
                  break;
              }
          }
      }
      Integer subBatchSize = Governor_Limits__c.getInstance().Batch_Size__c != null ? Integer.valueof(Governor_Limits__c.getInstance().Batch_Size__c) : 10;
      Id batchInstanceId = isChown? Database.executeBatch(new CHOWNOrderObserver_V1(o,subscriptionList,subscriptionIds),subBatchSize):Database.executeBatch(new OrderPostProcessing(o,subscriptionIds), subBatchSize);
      //EDGE-209293 added by shubhi end -------
  }*/

  /**
  *@Description : Batchable method implementation
  *@Method :  observable.getSubscriptionIds() - Easiest way to controle scope of processing is to base it on subscription records and by setting batch size when calling
  */
  public Iterable<sObject> start(Database.BatchableContext BC) {
      //subscriptionIds = observable.getSubscriptionIds();
      List<sObject> subList=new List<sObject>();
      subList = [SELECT Id, csord__Order__c FROM csord__Subscription__c WHERE Id IN :subscriptionIds AND csord__Order__c NOT IN :ignoreOrderIds ORDER BY csord__Order__c ASC]; ////EDGE-209293 updated by shubhi
      return subList;
  }

  /**
  *@Description : Batchable method to do all required processing for each batch of data
  *@Method : 1. cssmgnt.API_1.linkSubscriptions(subIds) - Link the subscription to solution
  *2. generateSpecifications(subIds, new List<Id>(), false) - Generate specification and will
  *return JSON as successfully created and plain string with error message as failure.
  *@Logic : On the heroku side it will throw the error but on the salesforce side we will get plain string
  *as error message, So in order to track error we are deserializing the response so that
  *in case of error it will throw error and we can handle in catch block.
  */
  public void execute(Database.BatchableContext BC, List<csord__Subscription__c> scope) {
      List<Id> subIds = new List<Id>();
      for (csord__Subscription__c sub : scope) {
          subIds.add(sub.Id);
      }
      //Commented as part of EDGE-224638, moved this to execute() of Observer in same class inorder to avoid CPU timeout error for large orders.
      //cssmgnt.API_1.linkSubscriptions(subIds);
      try {
          String response = csedm.API_1.generateSpecifications(subIds, new List<Id>(), false); //EDGE-169364 - Changed Parameter to false to keep same Spec GUID in case of MACD
          Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
          for (csord__Subscription__c sub : scope) {
              successOrderId.add(sub.csord__Order__c);
          }
      } catch (Exception e) {
          for (csord__Subscription__c sub : scope) {
              failureOrderId.add(sub.csord__Order__c);
          }
      }
  }

  /**
  *@Description : Using this method we are updating the failure order with error message and
  *running the orchestration process for success orders.
  *@Logic : 1. successOrderId.removeAll(failureOrderId) - There may be chance because of batch processing
  *failureId is present in successId.
  *2. In order to save query and reduce the time complexity, we are directly
  *running for loop in failure Id.
  */
  public void finish(Database.BatchableContext BC) {
      List<csord__Order__c> updatedFailureOrder = new List<csord__Order__c>();
      List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = new List<Basket_To_Order_Field_Map__c>();
      Integer observerBatchSize = Governor_Limits__c.getInstance().Observer_Batch_Size__c!= null ? Integer.valueof(Governor_Limits__c.getInstance().Observer_Batch_Size__c) : 500;
      successOrderId.removeAll(failureOrderId);
      try {
          if (failureOrderId.size() > 0) {
              for (Id ordId : failureOrderId) {
                  updatedFailureOrder.add(
                      new csord__Order__c(Id = ordId, csord__Status2__c = 'Order Decomposition Failed', Observer_Message__c = 'Failed Retry Again')
                  );
              }
              if (updatedFailureOrder.size() > 0) {
                  update updatedFailureOrder;
              }
          }

          if (successOrderId.size() > 0) {
              basketToOrderFieldList = Basket_To_Order_Field_Map__c.getall().values();
              OrderObserverManager_V2 orderObserver = new OrderObserverManager_V2(successOrderId,basketToOrderFieldList);
              Database.executeBatch(orderObserver,observerBatchSize);
          }
      } catch (Exception e) {
          System.debug('The following exception has occurred: ' + e.getMessage());
      } 
  }
}