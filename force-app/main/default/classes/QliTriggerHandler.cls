/********************************************************************************
* Class Name  : QliTriggerHandler
* Description : This class is Handler Class to call the helper to execute the logic.   
* Created By  : ShubhiVijayvergia 
******************************************************************
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             13-05-2021    DIGI-12734
********************************************************************************/

public with sharing class QliTriggerHandler {
    
/***************************************************************************************
* Method Name - beforeInsert
* Description - This method is used to call the before Insert operation on record.
****************************************************************************************/
    public static void beforeInsert(List<Queried_Line_Item__c> newQLiList){
       Map<String,case> caseMap=getCasesforQLI(newQLiList);
       Map<String,Invoice_Line_Item__c> invoiceMap=getInvoicesforQLI(newQLiList);
        for(Queried_Line_Item__c qli : newQLiList){
            if(qli.Case__c != null && caseMap.containskey(qli.case__c)){
                qli.CaseNumber__c=caseMap.get(qli.case__c).caseNumber;
            }
            if(qli.Invoice_Line_Item__c!=null && invoiceMap.containskey(qli.Invoice_Line_Item__c)){             
                qli.ChargeDescription__c = invoiceMap.get(qli.Invoice_Line_Item__c).Service_Type__c;
                qli.ChargeType__c = invoiceMap.get(qli.Invoice_Line_Item__c).Charge_Type__c;
                qli.InvoiceID__c = invoiceMap.get(qli.Invoice_Line_Item__c).name;
            }
        } 
    }
    
    /*************************************************************************************************/
    public static Map<String,Case> getCasesforQLI(List<Queried_Line_Item__c> QliList){
        List<String> caseidList=new List<String>();
        for(Queried_Line_Item__c qli : QliList){
            if(qli.Case__c != null)
                caseidList.add(qli.case__c);
        } 
        Map<String,Case> caseMap=new Map<String,Case>([Select id,caseNumber From Case where  id in:caseidList]);
        return !caseMap.isEmpty()?caseMap:new Map<String,Case>();
    }
    public static Map<String,Invoice_Line_Item__c> getInvoicesforQLI(List<Queried_Line_Item__c> QliList){
        List<String> invoiceidList=new List<String>();
        for(Queried_Line_Item__c qli : QliList){
            if(qli.Invoice_Line_Item__c != null)
                invoiceidList.add(qli.Invoice_Line_Item__c);
        } 
        Map<String,Invoice_Line_Item__c> InvoiceMap=new Map<String,Invoice_Line_Item__c>([Select id,Charge_Type__c,name,Service_Type__c From Invoice_Line_Item__c where  id in:invoiceidList]);
        return !InvoiceMap.isEmpty()?InvoiceMap:new Map<String,Invoice_Line_Item__c>();
    }
    /*************************************************************************************************/
}