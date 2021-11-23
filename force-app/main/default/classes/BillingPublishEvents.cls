public interface BillingPublishEvents {
   void createBillingEventObject(List<sObject> eventRecords,String businessEntityName, String eventAction);
   void addressEventObject(List<sObject> eventRecords,String businessEntityName, String eventAction);
   void createBillingEvent();
}