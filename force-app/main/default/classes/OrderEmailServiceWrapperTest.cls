/*
===============================================================================================================================
Class : OrderEmailServiceWrapperTest
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
===============================================================================================================================
*/
@isTest
public with sharing class OrderEmailServiceWrapperTest {
    
    @isTest
    public static void processOrderRecordTest() {

        Test.startTest();
        List<csord__Order__c> orderList = BDSNotifyTestFactory.createTestDataSI5Order();
        List<Id> orderIds = new List<Id>(new Map<Id, csord__Order__c>(orderList).keySet());
        OrderEmailServiceWrapper.processOrderRecord(orderIds);
        Test.stopTest();

    }
    @isTest
    public static void processOrderRecordCompletedFrmTriggerTest() {

        Test.startTest();
        List<csord__Order__c> orderList = BDSNotifyTestFactory.createTestDataSI5Order();
        Map<Id,String> orderStatusMap = new Map<Id,String>();
        for(csord__Order__c order:orderList){
            orderStatusMap.put(order.Id,'Completed');
        }
        //List<Id> orderIds = new List<Id>(new Map<Id, csord__Order__c>(orderList).keySet());
        //List<String> orderStatus = new List<String>{'Completed','In Progress'};
        OrderEmailServiceWrapper.processOrderRecordFrmTrigger(orderStatusMap);
        Test.stopTest();

    }
    @isTest
    public static void processOrderRecordinProgressFrmTriggerTest() {

        Test.startTest();
        List<csord__Order__c> orderList = BDSNotifyTestFactory.createTestDataSI5Order();
        
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.OfferID__c ='DMCAT_Offer_001251';
        bds.useSettingFor__c='offerIdCheck';
        bds.triggerOrderNotifications__c=true;
        bds.Name='Adaptive Mobility Care - Test';
        insert bds;
        Map<Id,String> orderStatusMap = new Map<Id,String>();
        for(csord__Order__c order:orderList){
            orderStatusMap.put(order.Id,'In Progress');
        }
        //List<Id> orderIds = new List<Id>(new Map<Id, csord__Order__c>(orderList).keySet());
        //List<String> orderStatus = new List<String>{'Completed','In Progress'};
        //orderStatusMap.put(orderList[0].Id,'In Progress');
        OrderEmailServiceWrapper.processOrderRecordFrmTrigger(orderStatusMap);
        Test.stopTest();

    }

}