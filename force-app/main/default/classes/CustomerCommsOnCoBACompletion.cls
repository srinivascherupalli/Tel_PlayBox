/*
 * @Created Date : 5/4/2021
 * @Created By : Kamlesh Kumar
 * @Breif : The class is used to create EmailDTO and used for Customer communication.
 * @Jira Cloud : EDGE:205667
 */
public with sharing class CustomerCommsOnCoBACompletion {
    private static final string notificationEventType = 'Value need to be provided later';
    private static final string entityType = System.Label.EmailEntityType;
    private static final string entityId = System.Label.EmailEntityId;
    static String correlationId = GuidUtil.NewGuid();
   /*
 * @Created Date : 5/4/2021
 * @Created By : Kamlesh Kumar
 * @Breif : The method gets call when case is updated to closed and record type is Change_of_Billing_Account
 * @Jira Cloud : EDGE:205667
 */
  public static void sendCoBACaseClosureEmail(Set<Id> caseId) {
        String templateName = '';
        String subject = '';
        String relatedtoId = '';
        if(!caseId.isEmpty()) {
           try {
              Utility_Settings__c utilSettings = Utility_Settings__c.getInstance();
              APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Subject__c, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c =:utilSettings.Template_Name__c  LIMIT 1];
              List < Case > caseIdList = [SELECT Id,Reason,RecordType.DeveloperName,ContactEmail,CaseNumber,Status,Billing_Account__r.Billing_Account_Number__c,ClosedDate,CreatedDate,Contact.Name, Contact.Email, Account.Name FROM Case WHERE Id IN: caseId];
              
              for(Case caseData : caseIdList) {
                 EmailDTO emailParams = new EmailDTO();
                 List < String > toEmails = new List < String > ();
                 toEmails.add(caseData.Contact.Email);
                 relatedtoId = String.valueOf(caseData.id).substring(0, 15);
                 
                 if(caseData.RecordType.DeveloperName == 'Change_of_Billing_Account') {
                      templateName = utilSettings.Template_Name__c;
                      if(String.isNotBlank(congaTemplate.APXTConga4__Subject__c)) {
                         subject = congaTemplate.APXTConga4__Subject__c;
                         subject = subject.replace('[CoBASubject]',caseData.CaseNumber); 
                      }
                 }
                 
                 emailParams.toEmails = toEmails;
                 emailParams.ccEmails = null;
                 emailParams.templateId = templateName;
                 emailParams.subject = subject;
                 emailParams.entityType = entityType;
                 emailParams.entityId = entityId;
                 emailParams.notificationEventType = notificationEventType;
                 emailParams.relatedtoId = relatedtoId;
                 new EmailService().send(emailParams);
              }   

           
           }
           catch(Exception e) {
              GenericUtilityClass.logException('CustomerCommsOnCoBACompletion','sendCoBACaseClosureEmail','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured when creating EmailDTO',C2O_ExceptionHandler.Capability.ORD);
           }
        }
  }
    
}