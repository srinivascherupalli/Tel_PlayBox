/*******************************************************************************************************************
Class Name : EnqueueCaseQLI
Test Class : EnqueueCaseQLITest
Description :  When ever user clicks on Invoice Callout quick action in case it will enqueue the job with caseId and set of invoices.
====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.        Vamsi Krishna Vaddipalli    02/06/2021      Edge-219120
====================================================================================================================
********************************************************************************************************************/
public with sharing class EnqueueCaseQLI {
    
     @AuraEnabled
    public static Boolean enqueueQLI(String caseId)
    {
      Boolean isSuccess = false ;
        List<Queried_Line_Item__c> listQLI = Model_QueriedLineItems.getQLIwithInvoiceItems(caseId);
        
        if(listQLI != null && !listQLI.isEmpty())
        {
        Set<String> invoiceset = new Set<String>();
        for(Queried_Line_Item__c qli:listQLI)
        {
          if(qli.Invoice_Line_Item__c != null && qli.Invoice_Line_Item__r.Invoice__c != null)  
          {
            if(String.isNotBlank(qli.Invoice_Line_Item__r.Invoice__r.Name))
            {
            String invoiceNum = qli.Invoice_Line_Item__r.Invoice__r.Name;
            invoiceset.add(invoiceNum); 
            }
          }
          
        }
        
        if( !invoiceset.isEmpty())
        {
          String jobId = System.enqueueJob(new QLIEnrichQueueable(caseId,invoiceset));
          isSuccess = true;
        } 

        }

       return isSuccess; 
    }

}