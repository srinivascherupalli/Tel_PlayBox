/**================================================================
Name: CoBAResponseHandler
Description:  class to Handle CoBA response
Created Date: April 27, 2021
Created By: Pawan Singh
==================================================================*/
public with sharing class CoBAResponseHandler {
    public static  void updateEventId(List<Id> listOfSubscriptionIds, String eventId){
        try
        {
            list<csord__Subscription__c> updateSubList =  new list<csord__Subscription__c>(); 
            for(csord__Subscription__c sub: [SELECT eventId__c FROM csord__Subscription__c WHERE Id IN :listOfSubscriptionIds])
            {
                sub.eventId__c = eventId;
                updateSubList.add(sub);
            }	
            if(!updateSubList.isEmpty()){
                update updateSubList;
            }
        }
        catch(Exception e){ 
            CoBABillHandler.logException('CoBAResponseHandler', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'coba response hanlder failed');
            
            throw e; }
    }
}