/*************************************************************************************************
Name : InvoiceTriggerHandler
Description : Handler for InvoiceTrigger 
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
public with sharing class InvoiceTriggerHandler {
     /*-------------------------------------------------------- 
EDGE-88307
Method: makeCallout
Description: Method to initiate getInvoiceByNumber callout
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static void  makeCallout(List<String> invoiceIdList){
        if(!invoiceIdList.isEmpty()){
            String jobid = System.enqueueJob(new InvoiceCalloutQueueable(invoiceIdList));
            System.debug('jobid: '+invoiceIdList);
        }
    }
}