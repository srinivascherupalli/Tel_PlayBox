public class EmailRequest {
    public String notificationEventType {get; set;}
    public String entityType  {get; set;}
    public String entityId  {get; set;}
    //public Recipient recipient {get; set;}
    public List<Recipient>recipients{get; set;}
    public List<ContentParameters> contentParameters {get; set;}
    public List<AttachmentParameters> attachmentParameters {get; set;}
    public String correlationId {get; set;}
    //public String clientEventId {get; set;}
    
    
    public class Recipient {
        public String msisdn {get; set;}
        public String emailAddress {get; set;}
        public String emailDeliveryType {get; set;}
        
    }
    
    public class ContentParameters {
        public String name {get; set;}
        public String value {get; set;}
    }
    
    public class AttachmentParameters {
        public String filename {get; set;}
        public String contentType {get; set;}
        public String binaryContent {get; set;}
    }

}