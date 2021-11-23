/**
*	Purpose			:	This class is used to build Notify email integration service request
*
*	Author			:	Padmesh Soni (Wipro)
*
*	Date			:	8/1/2019
*
*	Current Version	:	V_1.0
*
**/
public class LiveChatTranscriptWrapper {
    
    public class Data{
        public String notificationEventType {get; set;}
        public String entityType  {get; set;}
        public String entityId  {get; set;}
        public Recipient recipient {get; set;}
        public List<ContentParameters> contentParameters {get; set;}
        
    }
    
    public class Recipient {
        public String emailAddress {get; set;}
    }
    
    public class ContentParameters {
        public String name {get; set;}
        public String value {get; set;}
        public List<List<Values>> values {get; set;}
    }
    
    public class Values {
        public String name {get; set;}
        public String value {get; set;}
    }
}