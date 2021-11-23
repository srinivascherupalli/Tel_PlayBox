/*
===============================================================================================================================
Class : OrderEmailServiceWrapper
Developer Name :Anand Shekhar
Test Class : OrderEmailServiceWrapperTest
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
===============================================================================================================================
*/
public with sharing class OrderEmailServiceWrapper {
        
    @InvocableMethod
     //DIGI-19162 : This method is invoked through process builder on toggle
    public static void processOrderRecord(List<Id> OrderId){

        Map<String, List<csord__Subscription__c>> seperatedList = OrderEmailServiceWrapperHelper.ordersSeperation(OrderId);
        
        List<csord__Subscription__c> otherSubscriptions = seperatedList.get('OtherOrders');
        List<csord__Subscription__c> BDSNotifySubscriptions = seperatedList.get('BDSNotifyOrders');
        
        if (otherSubscriptions!= null && otherSubscriptions.size() > 0) {
            Set<Id> directNotifyOrderIDs = new Set<Id>();
            for(csord__Subscription__c subscription: otherSubscriptions ) {
                directNotifyOrderIDs.add(subscription.csord__Order__c);
            }
            OrderEmailService.processOrderRecord(new List<Id>(directNotifyOrderIDs));
        }
        if (BDSNotifySubscriptions != null && BDSNotifySubscriptions.size() > 0) {

            BDSNotifyService.triggerPlatformEvent(BDSNotifySubscriptions, 'InProgress');
        }

    }
 //DIGI-19162 Creating a new method for invoking through trigger
    //Start
    public static void processOrderRecordFrmTrigger(Map<Id,String> orderStatusMap){
        List<Id> OrderIdList = new List<Id>();
        Set<Id> directNotifyOrderIDs = new Set<Id>();
        for(Id orderId : orderStatusMap.keySet()){
            OrderIdList.add(orderId);
        }
        Map<String, List<csord__Subscription__c>> seperatedList = OrderEmailServiceWrapperHelper.ordersSeperation(OrderIdList);
        List<csord__Subscription__c> otherSubscriptions = seperatedList.get('OtherOrders');
        List<csord__Subscription__c> BDSNotifySubscriptions  = seperatedList.get('BDSNotifyOrders');
        
        if (otherSubscriptions != null && otherSubscriptions.size() > 0) {
            for(csord__Subscription__c subscription: otherSubscriptions ) {
                directNotifyOrderIDs.add(subscription.csord__Order__c);
            }
        }
        for(Id oId:OrderIdList){  
            if(orderStatusMap.get(oId) == System.Label.OrderStatus_InProgress){
                OrderEmailService.processOrderRecord(new List<Id>(directNotifyOrderIDs));
            }
            else if(orderStatusMap.get(oId) == System.Label.OrderStatus_Completed){
                OrderCompletionEmailService.sendEmailByOrderID(new List<Id>(directNotifyOrderIDs));
            }            
        }
        if (BDSNotifySubscriptions != NULL && BDSNotifySubscriptions.size() > 0) {
            for(Id oId:OrderIdList){
                if(orderStatusMap.get(oId) == System.Label.OrderStatus_Completed){
                    BDSNotifyService.triggerPlatformEvent(BDSNotifySubscriptions , 'Complete');
                }
                else if(orderStatusMap.get(oId) == System.Label.OrderStatus_InProgress){
                    BDSNotifyService.triggerPlatformEvent(BDSNotifySubscriptions , 'InProgress');
                } 
            }
            
        }
    }    
    //END
}