/**
* Description : Util class to publish the Platform Event
* Jira        : P2OB - 14466, P2OB - 14473
* Author      : Team Hawaii : Tirth Shah
* Date        : 20-May-2021 

DIGI-37522 : 15 Nov 2021 : Vivian Charlie : 
**/
public class PRMOpenAirNotificationUtil {
	
    public static OpenAir_Notification__e GenrateOpenAirNotificationData(Id RecordId, Id ParentId){
        return processRecord(RecordId,ParentId,RecordId.getSObjectType().getDescribe().getName());
    }

    public static OpenAir_Notification__e GenrateOpenAirNotificationData(Id RecordId, Id ParentId, String objectName){
        return processRecord(RecordId,ParentId,objectName);
    }

    public static OpenAir_Notification__e processRecord(Id RecordId, Id ParentId, String objectName){
        OpenAir_Notification__e oan = new OpenAir_Notification__e();
        oan.Record_ID__c = RecordId;
        oan.Parent_record_ID__c = ParentId;
        oan.sObject__c = objectName;
        return oan;
    }
    
    public static void publishEvents(List<OpenAir_Notification__e> OanList){
        List<Database.SaveResult> results = EventBus.publish(oanList);
    }
}