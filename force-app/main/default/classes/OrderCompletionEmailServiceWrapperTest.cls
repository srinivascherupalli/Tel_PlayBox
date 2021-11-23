/*
===============================================================================================================================
Class : OrderCompletionEmailServiceWrapperTest
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
===============================================================================================================================
*/
@isTest
public with sharing class OrderCompletionEmailServiceWrapperTest {

    @isTest
    public static void processOrderRecordTest() { 

        Test.startTest();
        List<csord__Order__c> orderList = BDSNotifyTestFactory.createTestDataSI5Order();
        List<Id> orderIds = new List<Id>(new Map<Id, csord__Order__c>(orderList).keySet());
        OrderCompletionEmailServiceWrapper.processOrderRecord(orderIds);
        Test.stopTest();

    }

}