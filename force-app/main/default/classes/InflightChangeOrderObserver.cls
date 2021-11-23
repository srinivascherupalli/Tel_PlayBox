/**=====================================================================
 * @Story : EDGE-170547 - Enable order observer and version management on order, product inventory entities to support inflight amend order processing
 * @Created By : Pawan Devaliya
 * @Created  Date : 18th Dec 2020
 * @Desc : Hybrid class that can be used as observer to start the batch logic.
 * Will be used as AfterOrderGenerated observer to:
 * 1. Start batch job (itself) to generate service specifications (high volume approach)
 * 2. Upon finishing will start PreRequisite orchestration process to handle the rest of
 * the logic needed for order post processing
 Modify History
1.    14/05/2021    Gnana        EDGE-216215 - Modified Query to get all Subscription from base Order
 =======================================================================*/

global class InflightChangeOrderObserver implements csordcb.ObserverApi.IObserver, Database.Batchable<SObject>, Database.Stateful {
  
  //public final csordtelcoa.OrderGenerationObservable observable;
  public final csordtelcoa.InflightObservable observable;
  public List<Id> orderIds = new List<Id>();
  public Set<Id> basketIds = new Set<Id>();
  public String query = '';
  public Set<Id> successOrderId = new Set<Id>();
  public Set<Id> failureOrderId = new Set<Id>();
  public Set<Id> successSubId = new Set<Id>();
  public Set<Id> failureSubId = new Set<Id>();
    

  global InflightChangeOrderObserver() {
  }

  /**
   *@Description : Constructor for setting context for batch processing
   */
  public InflightChangeOrderObserver(csordcb.ObserverApi.Observable o) {
    this.observable = (csordtelcoa.InflightObservable)o;
  }

  /**
   *@Description : OBSERVER METHOD IMPLEMENTATIONS
   *@Method : executeBatch() - Start service specification generation logic
   */
  global void execute(csordcb.ObserverApi.Observable o, Object arg) {
    Integer subBatchSize = Governor_Limits__c.getInstance().Batch_Size__c != null ? Integer.valueof(Governor_Limits__c.getInstance().Batch_Size__c) : 10;
    Id batchInstanceId = Database.executeBatch(new InflightChangeOrderObserver(o), subBatchSize);
  }

  /**
   *@Description : Batchable method implementation
   *@Methid :  observable.getSubscriptionIds() - Easiest way to control scope of processing is to base it on subscription records and by setting batch size when calling
   */
  public Database.QueryLocator start(Database.BatchableContext BC) {
   // subscriptionIds = observable.getSubscriptionIds();
   Map<Id, Id> ordIdByBasketId = observable.getOrderIdByBasketIdMap();
   orderIds = ordIdByBasketId.values();
   basketIds = ordIdByBasketId.keySet();
   
   // query = 'SELECT Id, csord__Order__c FROM csord__Subscription__c WHERE Id IN :subscriptionIds ORDER BY csord__Order__c ASC';
    //query = 'SELECT Id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c FROM csord__Subscription__c WHERE csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c  IN :basketIds';
    // Modified query as part of EDGE-216215
    query = 'SELECT Id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c FROM csord__Subscription__c WHERE csord__Order__c  IN :orderIds';
    return Database.getQueryLocator(query);
    
  }

  /**
   *@Description : Batchable method to do all required processing for each batch of data
   *@Method : 1. cssmgnt.API_1.linkSubscriptions(subIds) - Link the subscription to solution
   *2. generateSpecifications(subIds, new List<Id>(), true) - Generate specification and will
   *return JSON as successfully created and plain string with error message as failure.
   *@Logic : On the heroku side it will throw the error but on the salesforce side we will get plain string
   *as error message, So in order to track error we are deserializing the response so that
   *in case of error it will throw error and we can handle in catch block.
   */
  public void execute(Database.BatchableContext BC, List<csord__Subscription__c> scope) {
    List<Id> subIds = new List<Id>();
    List<Id> subIdsNewinInflight = new List<Id>();
    List<csord__Subscription__c> participatingSubs = new List<csord__Subscription__c>();
    for (csord__Subscription__c sub : scope) {
      subIds.add(sub.Id);
      if(sub.csordtelcoa__Product_Configuration__c != null && basketIds.contains(sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c)){
        participatingSubs.add(sub);
        if(sub.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c == null){
            subIdsNewinInflight.add(sub.Id);
        }
      }
    }

    System.debug('Subscription Ids are' + subIds);
    cssmgnt.API_1.linkSubscriptions(subIds);

    try {
        if(subIdsNewinInflight != null && !subIdsNewinInflight.isEmpty()){
      String response = csedm.API_1.generateSpecifications(subIdsNewinInflight, new List<Id>(), true); 
      System.debug('***Response is***' + response);
      Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        }
      for (csord__Subscription__c sub : participatingSubs) {
        successOrderId.add(sub.csord__Order__c);
        successSubId.add(sub.id);
      }
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
      System.debug('Failure orderIds--' + failureOrderId);
      for (csord__Subscription__c sub : participatingSubs) {
        failureOrderId.add(sub.csord__Order__c);
        failureSubId.add(sub.id);
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
    successSubId.removeAll(failureSubId);
 
    System.debug('Success order Ids are' + successOrderId);
    System.debug('Failure order Ids are' + failureOrderId);
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
        InflightOrderObserverManager_V1 inflightOrderObserver = new InflightOrderObserverManager_V1(successSubId, successOrderId,basketToOrderFieldList);
        Database.executeBatch(inflightOrderObserver,observerBatchSize);
      }
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
  }
}