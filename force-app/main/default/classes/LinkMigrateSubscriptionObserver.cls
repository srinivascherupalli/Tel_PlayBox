global with sharing class LinkMigrateSubscriptionObserver implements csordcb.ObserverApi.IObserver {  

   global void execute(csordcb.ObserverApi.Observable o, Object arg) {
       List<Id> subscriptionIds = ((csordtelcoa.OrderGenerationObservable) o).getSubscriptionIds();
       system.debug('linkSubsObserver-MS');
       system.debug('subscriptionIds-MS: '+ subscriptionIds);
       List<csord__Subscription__c> subscriptions = [
           select id, name, cssdm__solution_association__c,  csord__Account__c,cssdm__solution_association__r.Name
           from csord__Subscription__c 
           where id in :subscriptionIds
       ];
       List<Id> accountIds = new List<Id>();       
       List<Id> solutionIds = new List<Id>();
       for (csord__Subscription__c sub : subscriptions) {
           solutionIds.add(sub.cssdm__solution_association__c);
           accountIds.add(sub.csord__Account__c);
       }
       system.debug('accountIds-MS: '+ accountIds);
       system.debug('solutionIds-MS: '+ solutionIds);
       List<csord__Solution__c> solutions = [
           select id, name, cssdm__product_basket__c
           from csord__Solution__c
           where id in :solutionIds
       ];
       List<Id> basketIds = new List<Id>();
       for (csord__Solution__c sol : solutions) {
           basketIds.add(sol.cssdm__product_basket__c);
       }
       system.debug('basketIds-MS: '+ basketIds);
       if (!basketIds.isEmpty()) {
           List<Migration_Change_Request__c> mcrList = [
               select id, name, macd_basket_ids__c
               from Migration_Change_Request__c
               where macd_basket_ids__c != ''
               and migration_status__c = 'Completed'
               and account_id__c in :accountIds
           ];
           
           if (!mcrList.isEmpty()){
               String mcrId;
               for (Migration_Change_Request__c mcr : mcrList) {
                   List<Id> mcrBasketIds = mcr.macd_basket_ids__c != '' ?
                   	mcr.macd_basket_ids__c.split(',') :
                   	new List<Id>(); 
                   for (Id instance : mcrBasketIds) {
                       if (basketIds.contains(instance)) {
                           mcrId = mcr.id;
                           break;
                       }
                   }
               }
               if (!String.isBlank(mcrId)) {
                   String result = MigrateSubscriptionUtil.linkSubscriptionsAfterMigration(mcrId);
                   system.debug('result from LinkMigrateSubsciption Observer --> '+result);
               }
           }
       }
   }
}