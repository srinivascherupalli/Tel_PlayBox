/**================================================================
 * Appirio, Inc
 * Main Name: UpdateNotificationPreference
 * Description: To update the notification preference record with new service id on macd
 * Created Date: Oct 28, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/

@isTest
public with sharing class UpdateNotificationPreferenceTest {
    @isTest
    public static void checkUpdation() {
        //Data creation
        List<account> accountList = Orchestration_TestUtility.buildAccount(true, 1);
        List<csord__Order_Request__c> orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        List<csord__Order__c> orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, true, 2);
        List<cscfga__Product_Configuration__c> productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        List<csord__Solution__c> solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        List<csord__Subscription__c> subscriptionList = Orchestration_TestUtility.buildSubscription(true, 1, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        List<csord__Service__c> servlist = Orchestration_TestUtility.buildService(true, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[0].csordtelcoa__Replacement_Service__c = servlist[1].id;
        update servlist[0];

        //Creating notification preference record
        Notification_Preference__c notificationPref = new Notification_Preference__c(Service_Id__c = servlist[0].Id);
        insert notificationPref;

        //Calling the main class method
        UpdateNotificationPreference.notificationPreference(new List<String>{ servlist[0].Id });
        //There will be only one notification record
        List<Notification_Preference__c> notif = [SELECT Id, Service_Id__c FROM Notification_Preference__c];

        //checking if the record is updated with the replacement service
        System.assertEquals(servlist[0].csordtelcoa__Replacement_Service__c, notif[0].Service_Id__c);
    }
}