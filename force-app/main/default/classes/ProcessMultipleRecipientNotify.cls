public with sharing class ProcessMultipleRecipientNotify
{
    public static void updateEmailDeliveryStatus(String eventId,String Status,String statusDescription)
    {
  
        List<EmailDeliveryStatus__c> Emaildelivery = [select id, Status__c,RecipientContact__c,RecipientEmail__c ,CorrelationId__c from EmailDeliveryStatus__c where  CorrelationId__c =: eventId];
        
        if(!Emaildelivery.isEmpty())
        {
            
            If (Status == Label.Email_Status_Opened)
            {
                
                for(EmailDeliveryStatus__c EM : Emaildelivery)
                {
                    if (EM.CorrelationId__c == eventId && EM.Status__c != 'MESSAGE_UNDELIVERED')
                    {
                        EM.Status__c= Status;
                    }
                }
            }
            
            If(Status == Label.Email_Status_Message_Undelivered)   
            {
                
                List<Contact> Cont = [select id from Contact where email =: statusDescription and Contact_Status__c = 'Active' limit 1];
                
                If(!Cont.isEmpty())
                {
                    
                    for(EmailDeliveryStatus__c EM : Emaildelivery)
                    {
                        if (EM.CorrelationId__c == eventId && EM.RecipientContact__c == Cont[0].id)
                        {
                            EM.Status__c= Status;
                        }
                    }
                }
            }
            update Emaildelivery;        
    }
}
}