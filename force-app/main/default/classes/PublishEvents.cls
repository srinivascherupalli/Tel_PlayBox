public interface PublishEvents {

    void createEventObject(List<sObject> eventRecords,String businessEntityName, String eventAction);
    void createEvent();
}