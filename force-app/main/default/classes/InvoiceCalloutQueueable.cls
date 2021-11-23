/*************************************************************************************************
Name : InvoiceCalloutQueueable
Description : Queueable for calling API in trigger 
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
public with sharing class InvoiceCalloutQueueable implements Queueable, Database.AllowsCallouts{
    public static final String  handlerName = 'InvoiceByNumberHandler'; 
    public final List<Id> invoiceIdList;
    public InvoiceCalloutQueueable(List<Id> invoiceIdList){
        this.invoiceIdList = invoiceIdList;
    }    
    
    /*-------------------------------------------------------- 
EDGE-88307
Method: execute
Description: execute method implemented
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public void execute(QueueableContext context) {
        // This method will make a REST API call
        Logger2 log = Logger2.getLogger(handlerName);
        List<InvoiceRequestDTO> requestDToList = InvoiceComponentHandler.getInvoiceRequestBulk(invoiceIdList);
        System.debug('requestDToList: '+requestDToList);
        for(InvoiceRequestDTO requestDto : requestDToList){
            InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
        }
        log.exitLogger();
        
    }
    
}