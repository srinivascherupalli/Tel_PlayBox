/*
===============================================================================================================================
Class : OrderCompletionEmailServiceWrapper
Developer Name :Anand Shekhar
Test Class : OrderCompletionEmailServiceWrapperTest
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
===============================================================================================================================
*/
public with sharing class OrderCompletionEmailServiceWrapper {
        
    @InvocableMethod
    public static void processOrderRecord(List<Id> OrderId){ 

        Map<String, List<csord__Subscription__c>> seperatedList = OrderEmailServiceWrapperHelper.ordersSeperation(OrderId);
        
        List<csord__Subscription__c> otherSubscriptions = seperatedList.get('OtherOrders');
        List<csord__Subscription__c> BDSNotifySubscriptions = seperatedList.get('BDSNotifyOrders');
        Set<Id> directNotifyOrderIDs = new Set<Id>();        
        if (otherSubscriptions!= null && !otherSubscriptions.isEmpty()) {
            for(csord__Subscription__c subscription: otherSubscriptions ) {directNotifyOrderIDs.add(subscription.csord__Order__c);}
            OrderCompletionEmailService.sendEmailByOrderID(new List<Id>(directNotifyOrderIDs));
        }

        if (BDSNotifySubscriptions!= null && !BDSNotifySubscriptions.isEmpty() ) {

            BDSNotifyService.triggerPlatformEvent(BDSNotifySubscriptions,'Complete');
        }

    }
}