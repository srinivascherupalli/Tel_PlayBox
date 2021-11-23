/**================================================================
 * Name: Orchestration_GenPriSch_Handler_Test
 * Class: Orchestration_GeneratePriceSch_Handler
 * Created Date: 
 * Created By: 
 ==================================================================*/
@isTest
public class Orchestration_PlatformCacheUtil_Test {
@Testsetup
    static void dataSetup() {
        List<account> accountList = new List<account>();
        //Order request on Order
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        //List of Subscription
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        // List of Orders
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<Marketable_Offer__c> marketableOffer = new List<Marketable_Offer__c>();
        //Product Configuration List
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        
        accountList = Orchestration_TestUtility.buildAccount(true, 1);

        //Build Marketbale Offer
        marketableOffer = Orchestration_TestUtility.buildMarkertableOffer(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order2', accountList[0].id, 'Complete', orderReqList[0].id, true, 2);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 1, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        servlist = Orchestration_TestUtility.buildService(true, 1, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
    }
    @isTest
    static void testInsertSubsObject(){        
        Test.startTest();
        List<csord__Subscription__c> subList=[SELECT id,csord__Order__c,triggerBill_RTB__c,CorrelationId__c FROM csord__Subscription__c LIMIT 1];
        Id ordId=subList[0].csord__Order__c;
        String corId = string.valueOf(ordId)+'Subs1';
        subList[0].CorrelationId__c=corId;
        subList[0].triggerBill_RTB__c=false;
        Orchestration_PlatformCacheUtility.updatePlatformCache(subList);
        Test.StopTest();
    }
    @isTest
    static void testInsertSrvObject(){        
        Test.startTest();
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c LIMIT 1];       
        Orchestration_PlatformCacheUtility.updatePlatformCache(serviceId);
        Test.StopTest();
    }
}