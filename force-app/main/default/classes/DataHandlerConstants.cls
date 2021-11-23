/*****************************************************************
@Name: DataHandlerConstants 
@Author: Rahul Asarma 
@CreateDate: 30/03/2021
@Description: This class contains all the Constants used by other custom classes related to DataHandler.
@UsedBy: All classes 
******************************************************************/ 
Public class DataHandlerConstants {
    public static final String ngUCordertype = 'Transition to Telstra Collaboration';
    public static final String ngUCOffer = 'PSTN/ISDN/ISDN2/ISDN30/TIPT/SIPC';
    public static final String modifyChangeType = 'Change service configuration';
    public static final String rcAttr = 'RC';
    public static final String totalRC = 'TotalRecurringPrice';
    public static final String totalRCExGST = 'GSTExcl_Total_Recurring_Charges';
    public static final String totalRCIncGST = 'GSTIncl_Total_Recurring_Charges';
    public static final String ngUCPlan = 'Business Calling';
    
    
    //Object API names
    public static final String PRICE_ITEM_APINAME = 'cspmb__Price_Item__c';
    
    
    // Spec Ids
    public static final String ADAPTIVE_MOBILITY_SPECID = 'DMCAT_Offer_001231'; //EDGE-148728 // previoulsy ngemId
    public static final String ngemPlanId = 'DMCAT_Offer_001233'; //EDGE-148728
    public static final String ngemDeviceProdSpecId = 'DMCAT_ProductSpecification_001211'; // EDGE-172118
    public static final String ngemAccProdSpecId= 'DMCAT_ProductSpecification_001389'; // DPG-3508-3708
    public static final String ngemDeviceCare = 'DMCAT_ProductSpecification_001208'; //EDGE-176688
    //Telstra Collab
    public static final String BUSINESS_CALLING_SPECID = 'DMCAT_ProductSpecification_000871';//EDGE-132608
    public static final String UNIFIED_COMMUNICATION_DEVICE_SPECID = 'DMCAT_ProductSpecification_000622'; 
    public static final String UNIFIED_COMMUNICATION_ACCESSORY_SPECID = 'DMCAT_ProductSpecification_000623';  
    //EDGE-134662 START 
    public static final String TC_Offer_Id = 'DMCAT_Offer_000618'; 
    public static final String DPR_DealQuoteTC= 'DPR_DealQuoteTC'; 
    public static final String TC= 'TC';   
    public static final String REPAYMENT= ' Repayment'; 
    public static final String MONTHS=  ' months';
    public static final String ONE_TO_TEN=  '1 to 10';
    public static final String ELEVEN_TO_TWENTY=  '11 to 20';
    public static final String TWENTYONE_TO_FIFTY=  '21 to 50';
    public static final String FIFTYONE_TO_TWOHUNDRED=  '51 to 200';
    public static final String TWOHUNDREDONE_TO_FIVEHUNDRED=  '201 to 500';
    public static final String FIVEHUNDREDONE_TO_NINTYNINETHOUSANDNINEHUNDREDNINTYNINE=  '501 to 99999';
    //EDGE-134662 END 
    //DIGI-16765 Start
    public static final String IOT_Offer_Id = 'DMCAT_Offer_001522';
    public static final String IOt_LPWAN = 'LPWAN';
    public static final String IOt_LTE = 'LTE';
    public static final String IOT_Utilities = 'Utilities';
     
    public static final String LPWAN_VolumeTier1 = '(1 to 5000)';
    public static final String LPWAN_VolumeTier2 = '(5001 to 10000)';
    public static final String LPWAN_VolumeTier3 = '(10001 to 50000)';
    public static final String LPWAN_VolumeTier4 = '(50001 to 100000)';
    public static final String LPWAN_VolumeTier5 = '(100001 to 999999)';
        
    public static final String LTE_VolumeTier1 = '(1 to 999)';
    public static final String LTE_VolumeTier2 = '(1000 to 2499)';
    public static final String LTE_VolumeTier3 = '(2500 to 9999)';
    public static final String LTE_VolumeTier4 = '(10000 to 24999)';
    public static final String LTE_VolumeTier5 = '(25000 to 999999)';
            
    public static final String Utilities_VolumeTier1 = '(1 to 75000)';
    public static final String Utilities_VolumeTier2 = '(75001 to 275000)';
    public static final String Utilities_VolumeTier3 = '(275001 to 500000)';
    public static final String Utilities_VolumeTier4 = '(500001 to 750000)';
    public static final String Utilities_VolumeTier5 = '(750001 to 999999)'; 
    
    public static final String excessCharge = 'ExcessCharge';
    //DIGI- 16765 End 
    public static String Adaptive;
    
    public DataHandlerConstants(){
    Adaptive='Adaptive';
    } 
    
}