/************************************************************ 
* @version      - 0.1
* @createdBy    - Pradeep Bhumi
* @team         - OSAKA
* @jirastoryRef - EDGE-88300
******************************************************************/ 


@isTest
 class EmailDTOTest {
    @isTest
    static void testEmailDTO(){
     String fromEmail='testtelstra@team.telstra.com';
     List<String> toEmails = new List<String>();
     List<String> ccEmails = new List<String>(); 
     List<String> bccEmails = new List<String>();
     toEmails.add('testDTO@team.telstra.com');
     String templateId = 'Billing Enquiry';
     String subject ='Billing Enquiry';
     List<id> attachmentIds =null;
     String entityType ='NOT_APPLICABLE';
     String entityId ='NOT_APPLICABLE';
     String notificationEventType= 'Online Ordering';
     String msisdn ='';
     Map<String, String> otherKayValues;
     String relatedtoId ='';
        
    EmailDTO dto = new EmailDTO(fromEmail,toEmails,ccEmails,bccEmails,templateId, subject
                    , attachmentIds, entityType,entityId
                    , notificationEventType,msisdn, relatedtoId, otherKayValues);
           System.assert(toEmails !=null);
    }
    
    }