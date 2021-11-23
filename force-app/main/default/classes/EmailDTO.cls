public class EmailDTO {
     
     
 /**
*  Created default constructor for EMAILDTO to set email params.
*  @name              - EmailDTO
*  @jira Story Ref    - EDGE-88300
 **/
    
     public EmailDTO()
     {  }
    public String fromEmail {get; set;}
    public List<String> toEmails {get; set;}
    public List<String> ccEmails {get; set;}
    public List<String> bccEmails {get; set;}
    public String templateId {get; set;}
    public String subject {get; set;}
    public List<id> attachmentIds {get; set;}
    public String entityType {get; set;}
    public String entityId {get; set;}
    public String notificationEventType {get; set;}
    public String msisdn {get; set;}
    public Map<String, String> otherKayValues {get; set;}
    public String relatedtoId {get; set;}       

    
    
    public EmailDTO(String fromEmail, List<String> toEmails,List<String> ccEmails,List<String> bccEmails,String templateId, String subject
                    , List<id> attachmentIds, String entityType, String entityId
                    , String notificationEventType, String msisdn, String relatedtoId, Map<String, String> otherKayValues) {
        this.fromEmail = fromEmail;
        this.toEmails = toEmails;
        this.ccEmails = ccEmails;
        this.bccEmails = bccEmails;              
        this.templateId = templateId;
        this.subject = subject;
        this.attachmentIds = attachmentIds;
        this.entityType = entityType;
        this.entityId = entityId;
        this.notificationEventType = notificationEventType;
        this.msisdn = msisdn;
        this.otherKayValues = otherKayValues; 
        this.relatedtoId = relatedtoId;
    }
     
}