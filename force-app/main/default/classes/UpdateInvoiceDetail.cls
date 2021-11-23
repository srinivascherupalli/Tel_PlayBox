/*************************************************************************************************
Name : UpdateInvoiceDetail
Description : Update Invoice Detail ILI records with Physical Location,Charge ID and Offer Name
Author: Manjunath Ediga
Story: EDGE-164871
***************************************************************************************************/
public with sharing class  UpdateInvoiceDetail{
    
    public static void updateInvoiceLineDetails(List<Invoice_Line_Item__c> invoiceList , String invoice) {
        try{
            system.debug('invoiceList in updateIld'+invoiceList);
            Map<Decimal, Invoice_Line_Item__c> resMap = new Map<Decimal, Invoice_Line_Item__c>();
            
            // Capture the all the response ILI's into Map to compare the transaction id with List without physical location,charge ID and Offer Name
            for(Invoice_Line_Item__c resILI : invoiceList)
            {
                resMap.put(resILI.Invoice_Transaction_ID__c, resILI);
            }
            
            List<Invoice_Line_Item__c> detailList =[SELECT id,Invoice__c,name,Invoice_Transaction_ID__c,Physical_Location_Name__c,Offer_Name__c,Charge_Id__c 
                                                        FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice AND Physical_Location_Name__c = null AND Offer_Name__c = null];
            System.debug('detailList size'+detailList.size());
            System.debug('detailList size'+detailList);
            
            List<Invoice_Line_Item__c> detailIliListToUpdate = new List<Invoice_Line_Item__c> ();
           //Check Whether responseMap contains transaction id of ILI's without Physical Location 
            for(Integer i = 0; i < detailList.size() ; i++){
                if(resMap.containsKey(detailList[i].Invoice_Transaction_ID__c)){
                    Invoice_Line_Item__c ili = resMap.get(detailList[i].Invoice_Transaction_ID__c);
                    if(ili != null){
                        detailList[i].Physical_Location_Name__c =  ili.Physical_Location_Name__c !=null ? ili.Physical_Location_Name__c : null ;
                        detailList[i].Offer_Name__c =  ili.Offer_Name__c !=null ? ili.Offer_Name__c : null ;
                        detailList[i].Charge_Id__c =  ili.Charge_Id__c !=null ? ili.Charge_Id__c : null ;
                        detailList[i].Is_Taxable__c =  ili.Is_Taxable__c !=null ? ili.Is_Taxable__c : null ;
                        detailList[i].Tax_Inclusive__c =  ili.Tax_Inclusive__c !=null ? ili.Tax_Inclusive__c : null ;
                        detailList[i].Tax_Rate__c =  ili.Tax_Rate__c !=null ? ili.Tax_Rate__c : null ;
                        detailList[i].Plan_Instance_Details_List__c =  ili.Plan_Instance_Details_List__c !=null ? ili.Plan_Instance_Details_List__c : null ;
                        detailList[i].Service_Type__c =  ili.Service_Type__c !=null ? ili.Service_Type__c : null ;
                        detailList[i].Usage_Type_Code__c =  ili.Usage_Type_Code__c !=null ? ili.Usage_Type_Code__c : null ;
                        detailList[i].Drill_Down_Endpoint__c =  ili.Drill_Down_Endpoint__c !=null ? ili.Drill_Down_Endpoint__c : null ;
                        detailList[i].Is_Discount_Drillable__c =  ili.Is_Discount_Drillable__c !=null ? ili.Is_Discount_Drillable__c : null ;
                    }
                   
                }
            }
            //Update the ILI's with updated values
            if(detailList.size() > 0){
                update detailList;
            }
        }
        catch(exception e){
            system.debug('exception in UpdateInvoice Detail'+e.getLineNumber()+'Message is :'+e.getMessage());
        }
    }
}