/**********************************************************************************************
@description: OrderObserverInvoker implements the invocable method which is used in 
process builder to subscribe to order decomposition platform event. This method will be called 
when order generation uses future method and will be used to chain observer batch jobs to this 
future method transaction
@Test: OrderBifurcationFrameworkObserver_Test
***********************************************************************************************/

public class OrderObserverInvoker {
    
    @InvocableMethod(label='Order Observer Invocation')
    public Static void invokeOrderObserverBatch(List<Id> temporderIds){
        csordcb.ObserverApi.Observable o;
        List<Id> subscriptionIds = new List<Id>();
        for(csord__subscription__c subs: [Select Id from csord__subscription__c WHERE csord__order__c IN: temporderIds]){
            subscriptionIds.add(subs.Id);
        }
        OrderObserverInvoker.observerChainingMethod(subscriptionIds, o, temporderIds);
    }
    
    public static void observerChainingMethod(List<Id> subscriptionIds , csordcb.ObserverApi.Observable o, List<Id> temporderIds){
        
        //try{
            //EDGE-209293 added by shubhi start ----
            //EDGE-209293 added by shubhi start ----
            //csordtelcoa.OrderGenerationObservable observable = (csordtelcoa.OrderGenerationObservable)o;
            //subscriptionIds = observable.getSubscriptionIds();
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
        /*}catch(exception e){
            String correlationId = GuidUtil.NewGuid();
            orderBifurcationExceptionHandler.logException('observerChainingMethod', temporderIds, correlationId, e.getMessage(), 'Order observer via platform event failed to execute' );
        }*/
      
    }  
}