public class DisconnectSubscriptionHandler {

   //@InvocableVariable
   // public csord__Subscription__c subscription;
   @InvocableMethod
    Public static void disconnectrequest(List<String> ids){
        if((ids[0].subStringAfter(':')).equals('')){
            Logger2 errorLogger = Logger2.getLogger('DisconnectSubscriptionHandler');
            errorLogger.logMessages(null,null,'DisconnectSubscriptionHandler','Exception',null,'Port Out For Subscription Not Possible as Subscription Does Not Exist in Disconnection Request - '+ids[0].subStringBefore(':'), True, False);
            errorLogger.exitLogger();
            return;
        }else{
            System.debug('allSubs::'+ids);
            List<csord__Subscription__c> subscription = [Select id,csordtelcoa__Subscription_Number__c,csord__Account__c,csordtelcoa__Product_Configuration__c from csord__Subscription__c where id =:ids[0].subStringAfter(':')];
            System.debug('DisconnectSubscriptionHandler : '+subscription);
            List<csbb__Product_Configuration_Request__c> updatedList = new List<csbb__Product_Configuration_Request__c>();
            List<csbb__Product_Configuration_Request__c> productConfigurationRequestList = [select id,csbb__Status__c from csbb__Product_Configuration_Request__c where csbb__Product_Configuration__c =:subscription[0].csordtelcoa__Product_Configuration__c];
            for(csbb__Product_Configuration_Request__c productConfigurationRequest : productConfigurationRequestList){
                if(productConfigurationRequest.csbb__Status__c != 'finalized'){
                    productConfigurationRequest.csbb__Status__c = 'Cancelled';
                    updatedList.add(productConfigurationRequest);
                }
            }
            Update updatedList;
            List<String> subscriptionList = new List<String>();
            subscriptionList.add(subscription[0].ID);
            String tNowCaseRef='';
            List<csord__Order__c> OrderList = OrderGeneratorUtil.generateOrderForScenarioType(subscriptionList,subscription[0].csord__Account__c,System.Label.PortOut,tNowCaseRef);
            
        }
    }
}