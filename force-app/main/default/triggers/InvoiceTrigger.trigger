/*************************************************************************************************
Name : InvoiceTriggerHandler
Description : Handler for InvoiceTrigger 
Author: Kalashree Borgaonkar
Modified By: Pradeep
Story: EDGE-88307,EDGE-134600
***************************************************************************************************/
trigger InvoiceTrigger on Invoice__c (after insert) {
    
    List<String> invoiceIdList = new List<String>();
    // Start of : EDGE-134600- to retrict invoice callout for the records created by Service Assurance Agent(510 functionality)
    Map<id,Boolean> invoiceMap= new Map<id,Boolean>();
    for(Invoice__c invoice: Trigger.New){
        invoiceMap.put(invoice.id,invoice.skipInvoiceCallout__c);
    }
    for (String invoiceData : invoiceMap.keySet())
    {
        if(!invoiceMap.get(invoiceData))
        {
            invoiceIdList.add(invoiceData);
        }
    }
    //End : EDGE-134600
    if(!invoiceIdList.isEmpty())
        InvoiceTriggerHandler.makeCallout(invoiceIdList);
}