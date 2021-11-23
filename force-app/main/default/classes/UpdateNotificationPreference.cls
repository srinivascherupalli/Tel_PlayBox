/**================================================================
 * Appirio, Inc
 * Name: UpdateNotificationPreference
 * Description: To update the notification preference record with new service id on macd
 * Created Date: Oct 28, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/

public with sharing class UpdateNotificationPreference {
    @InvocableMethod(label='Notification Preference')
    public static void notificationPreference(List<String> serviceIds) {
        List<Notification_Preference__c> updateNotificationPerfList = new List<Notification_Preference__c>();
        for (Notification_Preference__c notificationPref : [SELECT Id, Service_Id__c, Service_Id__r.csordtelcoa__Replacement_Service__c FROM Notification_Preference__c WHERE Service_Id__c IN :serviceIds AND Service_Id__r.csordtelcoa__Replacement_Service__c != NULL]) {
            if (notificationPref.Service_Id__c != notificationPref.Service_Id__r.csordtelcoa__Replacement_Service__c) {
                notificationPref.Service_Id__c = notificationPref.Service_Id__r.csordtelcoa__Replacement_Service__c;
                updateNotificationPerfList.add(notificationPref);
            }
        }

        if (updateNotificationPerfList.size() > 0) {
            update updateNotificationPerfList;
        }
    }
}