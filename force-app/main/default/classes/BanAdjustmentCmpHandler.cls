/*************************************************************************************************
EDGE -104930
Name: BanAdjustmentCmpHandler
Description: Controller for component BanAdjustmentCmp 
Author:Mahima 
***************************************************************************************************/
public with sharing class BanAdjustmentCmpHandler {
    
    //UI Wrapper for Error and Success Data
    public class AdjustmentFullWrapper{
        @AuraEnabled
        public List<AdjustmentDataWrapper> lstAddWrapper{get; set;}
        @AuraEnabled
        public ErrorWrapper errorwr{get; set;}
        
    }
    
    //Ui Wrapper for API response 
    public class AdjustmentDataWrapper{
        @AuraEnabled
        public String adjustmentId{get; set;}
        @AuraEnabled
        public String description{get; set;}
        @AuraEnabled
        public String dateApplied{get; set;}
        @AuraEnabled
        public String adjustmentAmount{get; set;}
        @AuraEnabled
        public String amountApplied{get; set;}
        @AuraEnabled
        public String amountUnapplied{get; set;}
    }
    
    //Ui wrapper for Error API response
    public class ErrorWrapper
    {
        @AuraEnabled
        public Integer code { get; set; }
        @AuraEnabled
        public string field { get; set; }
        @AuraEnabled
        public string message { get; set; }
    }
     /*----------------------------------------------------------------------------
EDGE        -104930
Method Name -getBAN
Description -Get Billing account number
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
 
     @AuraEnabled  public static string getBan(String billingAccountId){
         string bANnum ;
         if(string.isNotBlank(billingAccountId))
         {
             List<Billing_Account__c> lstban=[SELECT id,Billing_Account_Number__c FROM Billing_Account__c WHERE Id =:billingAccountId];
             if(!lstban.IsEmpty())
             {
                 bANnum=lstban[0].Billing_Account_Number__c;
             }   
         }
         return bANnum;
     }
    /**********************************
EDGE-104930 
Description: Method to call Adjustment API for given start and end date and billing Account Id
Author: Mahima
************************************/
    @AuraEnabled 
    public static AdjustmentFullWrapper getAdjustmentList(string startdate, string endDate, String bANId)
    {
        AdjustmentFullWrapper resultWrapper = new AdjustmentFullWrapper();
        //try{
            String bANnum=getBan(bANId);
           if(string.isNotBlank(bANnum))
            {
                List<AdjustmentDataWrapper> lstdata= new List<AdjustmentDataWrapper>();
                AdjustmentsResponseDTO resDTO=BanAdjustmentPaymentService.GetCreditAdjustListService(startdate,endDate,bANnum);
                
                if(resDTO!= null && resDTO.errors!= null && resDTO.errors.size()>0)
                {  
                    for( AdjustmentsResponseDTO.Error err: resDTO.errors){
                        ErrorWrapper ew= new ErrorWrapper();
                        ew.code=err.code;
                        ew.field=err.field;
                        ew.message=err.message;
                        resultWrapper.errorwr=ew;
                        break;
                    }
                }
                else if( resDTO!= null && resDTO.adjustments!= null && resDTO.adjustments.size()>0){
                    for( AdjustmentsResponseDTO.Adjustment adj: resDTO.adjustments)
                    {
                        AdjustmentDataWrapper adw= new AdjustmentDataWrapper();
                        adw.adjustmentId= adj.adjustmentId;
                        adw.description= adj.description;
                        adw.dateApplied= adj.dateApplied;
                        adw.adjustmentAmount= string.valueOf(adj.adjustmentAmount);
                        adw.amountApplied= string.valueOf(adj.amountApplied);
                        adw.amountUnapplied= string.valueOf(adj.amountUnapplied);
                        lstdata.add(adw);
                    }
                    resultWrapper.lstAddWrapper= lstdata;
                    resultWrapper.errorwr= null;
                }              
                
            }
            else
            {
                ErrorWrapper ew= new ErrorWrapper();                
                ew.message=System.Label.Billing_Acc_cannot_null;
                resultWrapper.errorwr=ew;
            }
            
        //}
        /*catch(exception e)
        {
            system.debug('Exception in getAdjustmentList==>'+ e.getLineNumber() +' '+e.getMessage());
            ErrorWrapper ew= new ErrorWrapper();                
            ew.message=e.getMessage();
            resultWrapper.errorwr=ew;
            resultWrapper.lstAddWrapper= null;
            
        }*/
        
        return resultWrapper;
    }
    
}