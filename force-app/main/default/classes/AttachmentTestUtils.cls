@isTest
public class AttachmentTestUtils {
    
    public static Attachment createAttachment(String fileName, String body, String contentType) {     
        Case cse = new Case();
        insert cse;

        Attachment att = new Attachment();
        att.Body = Blob.valueOf(body);
        att.ContentType = contentType;
        att.Name = fileName;
        att.ParentId = cse.id;
        insert att;
        return att;
    }

}