/*******************************************************************************************************************
Class Name : Model_QueriedLineItems
Test Class : Model_QueriedLineItemsTest
Description :  Model class for Queried Line Items
====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.        Vamsi Krishna Vaddipalli    02/06/2021      Edge-219120
2.         Shubhi            		  02-06-2021      EDGE-216407
3.        Aman Soni                   08/06/2021      EDGE-207869 
====================================================================================================================
********************************************************************************************************************/
public class Model_QueriedLineItems {
    
    public static List<Queried_Line_Item__c> getQLIwithInvoiceItems(String caseId)
    {
         List<Queried_Line_Item__c> listQLI = [SELECT id,Invoice_Line_Item__c,Invoice_Line_Item__r.Invoice__c,
                                               Invoice_Line_Item__r.Invoice__r.Name,processedByMS__c,Case__c 
                                               FROM Queried_Line_Item__c 
                                               WHERE Case__c =: caseId AND Invoice_Line_Item__c != null 
                                               AND Invoice_Line_Item__r.Invoice__c != null 
                                               AND (processedByMS__c = -1 OR processedByMS__c =0)];
        
        return listQLI;
    }

    //  EDGE-216407 method to fetch qlis not processed by MS 
    public static List<Queried_Line_Item__c> getQLINotProcessedByMs(Set<Id> caseIdSet)
    {
        List<Queried_Line_Item__c> listQLI = new  List<Queried_Line_Item__c>();
        if(caseIdSet!=null && !caseIdSet.isEmpty()){
            listQLI=[SELECT id,processedByMS__c,Case__c 
                        FROM Queried_Line_Item__c  WHERE Case__c IN : caseIdSet AND processedByMS__c !=1];
        }
        return listQLI;
    }
    //  EDGE-216407 method to fetch qlis for get ax credit callout 
    public static List<Queried_Line_Item__c> getQLIforGetMax(List<Id> caseIds){
        List<String> chargeTypeList = new List<String>{System.Label.QLI_Charge_Type_Credit_Charge,System.Label.QLI_Charge_Type_Usage_Detail};
        List<Queried_Line_Item__c> listQLI = new  List<Queried_Line_Item__c>();
        if(caseIds!=null && !caseIds.isEmpty()){
            listQLI=[SELECT Id,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Line_Number__c ,Invoice_Line_Item__r.Invoice__r.name,processedByMS__c
            FROM Queried_Line_Item__c WHERE Case__c <> NULL 
            AND Case__r.Billing_Account__r.Billing_Account_Number__c <> NULL AND Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c <> NULL 
            AND Invoice_Line_Item__r.Charge_Identifier__c <> NULL AND Invoice_Line_Item__r.Charge_Type__c <> NULL
            AND Invoice_Line_Item__r.Invoice_Line_Number__c <> NULL AND Invoice_Line_Item__r.Charge_Type__c NOT IN : chargeTypeList AND Case__c IN : caseIds];
        }
        return listQLI;
    }

    /*-------------------------------------------------------- 
    Story(Sprint): EDGE-207869(21.08)
    Method       : getExistingQlis
    Description  : Method to fetch existing QLI against provided Case and Invoice
    Author       : Aman Soni
    --------------------------------------------------------*/
    public static List<Queried_Line_Item__c> getExistingQlis(String exisCaseId, String invoiceNum)
    {
        List<Queried_Line_Item__c> listQLI = new List<Queried_Line_Item__c>();
        listQLI = [select id,Queried_Amount__c from Queried_Line_Item__c where Case__c != null and Invoice_Line_Item__c != null and Invoice_Line_Item__r.Invoice__c != null and Case__r.Id = :exisCaseId and Invoice_Line_Item__r.Invoice__r.Name = :invoiceNum];      
        return listQLI;
    }

}