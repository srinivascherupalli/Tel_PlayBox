/**************************************************************************
EDGE        -108332
component   -UsageSummaryCmp
Description -Controller for Component UsageSummaryCmp
Author      -Sasidhar Devarapalli
Team        -Osaka
*********************************************************************************/
public with sharing class UsageSummaryHandler {
    private static final String CONST_INTERFACENAME = 'UsageSummaryHandler';
    private static String correlationId = GuidUtil.NewGuid();
    @AuraEnabled(cacheable=true)
    public static String getUsageResponseDetails(String invoiceLineItemId,Map<String,Object> invoiceMapStr, Boolean isInvoiceLineItem){
                 
        system.debug('invoiceMapStr'+invoiceMapStr);
        UsageRequestDTO invoiceMap;
        
         if(invoiceMapStr !=null){
         String JSONString = JSON.serialize(invoiceMapStr.values());
         JSONString=JSONString.removeStart('[');
         JSONString=JSONString.removeEnd(']');
    
          if(!Test.isRunningTest()){
         invoiceMap = UsageRequestDTO.parse(JSONString);
           }
             
             }

        
        UsageRequestDTO requestDto = null;
        
        String responseResult = null;
        try{
            if(isInvoiceLineItem && invoiceMap == null){
                System.debug('invoiceLineItemId-->'+invoiceLineItemId);
                
                Invoice_Line_Item__c   invoiceLineItem = getinvoiceLineItem(invoiceLineItemId);
                /*Invoice_Line_Item__c   invoiceLineItem = [SELECT Usage_Type_Code__c Usage Type code,Charge_Id__c,Invoice__r.name,Invoice__r.Aria_Invoice_Number__c,Invoice__r.Billing_Account__r.Billing_Account_Number__c,Invoice__r.Invoice_Period__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c 
                                                                FROM Invoice_Line_Item__c  WHERE id = :invoiceLineItemId
                                                                LIMIT 1];*/
                System.debug('invoiceLineItem: '+invoiceLineItem);
                //US-0096098 : Addressing CyclomaticComplexity
                    requestDto = new UsageRequestDTO();
                requestDto =  getrequestDto(invoiceLineItem);
                
                
            }
            if(!isInvoiceLineItem && invoiceMap !=null ){
                //requestDto = UsageRequestDTO.parse(invoiceMap.values());
                //stringResponse = invoiceMap.values();
                // String stringResponse = JSON.serialize(invoiceMap.values()[0]);
                //requestDto = UsageRequestDTO.parse(invoiceMap.values()[0]);
                requestDto = invoiceMap;
                System.debug('requestDto for billing'+requestDto);
                System.debug('BillingAccount Request');
            }
            if(requestDto !=null ){
                responseResult = UsageCalloutHandler.calloutUsageDetails(requestDto);
                //getUsageTypeLabels(requestDto.usageTypeCode);
            }else {
                responseResult = null;
            }
        }catch (Exception e) {
            return null;
        }
        return responseResult;
    }
    
    /**************************************************************************
EDGE        -163368
component   -UsageSummaryCmp
Description -CyclomaticComplexity  Fix 
Author      -Mohammed Zeeshan
Team        -Osaka
*********************************************************************************/
    
    public static UsageRequestDTO getRequestDTO(Invoice_Line_Item__c   invoiceLineItem ){
        UsageRequestDTO requestDto = new UsageRequestDTO();
        if(invoiceLineItem != null ){
            
                    List<Integer> planInstance = new List<Integer>();
                    requestDTO.usageTypeCode = invoiceLineItem.Usage_Type_Code__c;
                    requestDto.statementNumber = invoiceLineItem.Invoice__r.Name;
                    requestDTO.invoiceNumber = invoiceLineItem.Invoice__r.Aria_Invoice_Number__c;
                    requestDto.accountNumber = invoiceLineItem.Invoice__r.Billing_Account__r.Billing_Account_Number__c;
                    requestDTO.invoicePeriod = invoiceLineItem.Invoice__r.Invoice_Period__c;
                    if( invoiceLineItem.Plan_Instance_Details_List__c != null){
                        List<String> planInstanceList = new List<String>();
                        planInstanceList.addAll(invoiceLineItem.Plan_Instance_Details_List__c.split(','));
                        for(String planVar : planInstanceList ){
                            planInstance.add(Integer.valueOf(planVar));
                        }
                        if(!planInstance.isEmpty()){
                            requestDto.planInstanceDetailsList = planInstance;
                        }
                    }
                    requestDTO.taxInclusive = Integer.valueOf(invoiceLineItem.Tax_Inclusive__c);
                    requestDto.taxRate = invoiceLineItem.Tax_Rate__c;
                    if(invoiceLineItem.Charge_Id__c != null){
                        requestDto.chargeId = Integer.valueOf(invoiceLineItem.Charge_Id__c);
                        System.debug('InvoiceLineItem Request');
                    }
                    System.debug('requestDto:'+requestDto);
                }
        return requestDto;
            }
    
    /*----------------------------------------------------------------
Method     : getUsageTypeLabels
Description: Method to fetch Usage Typle Labels for lightning datatable columns for Usage Summary lightning component for Billing consultant journey and Assurance Journey
Author     : Manjunath Ediga
Story      : EDGE-141682 
-------------------------------------------------------------------------------------*/
    //Method to fetch columns from custom meta Data
    @AuraEnabled(cacheable=true)
    public static List<Usage_Type__mdt > getUsageTypeLabels(string usageTypeCode ,String invoiceLineItemId,Boolean isInvoiceLineItem){
        List<Usage_Type__mdt > usgMetaData = null;
        Invoice_Line_Item__c invoiceLineItem = null;
        string usageCode = '';
        try{
            //isInvoiceLineItem condition to get Usage type labels from custom metaData using Usage Type code present in Invoice Line Item(Billing consulatant) 
            // else from Usage Type code of Invoicecmp lightning component for assurance journey  
            if(isInvoiceLineItem){
                invoiceLineItem = getinvoiceLineItem(invoiceLineItemId);
                usageCode = invoiceLineItem.Usage_Type_Code__c;
            } 
            else{
                usageCode = usageTypeCode;
            }
            usgMetaData = [SELECT Table_Column__c, fields__c,Sequence_Number__c,Data_Type__c  FROM Usage_Type__mdt WHERE MasterLabel =:usageCode ORDER BY Sequence_Number__c ];

        }
        catch (Exception e) {
            return null;
        }
        return usgMetaData; 
    }
    
    /*----------------------------------------------------------------
Method     : getinvoiceLineItem
Description: Method to fetch invoice lineitem record for Usage Summary lightning component in invoice line item record detail for Billing consultant journey 
Author     : Manjunath Ediga
Updated by :Zeeshan : Added Invoice_Transaction_ID__c field to fetch the transaction id
Story      : EDGE-141682 
-------------------------------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
    public static Invoice_Line_Item__c getinvoiceLineItem(String invoiceLineItemId){
        Invoice_Line_Item__c invoiceLineItem = null;
        try{
            invoiceLineItem = [SELECT Usage_Type_Code__c,Invoice_Transaction_ID__c,Charge_Id__c,Invoice__r.name,Invoice__r.Aria_Invoice_Number__c,Invoice__r.Billing_Account__r.Billing_Account_Number__c,Invoice__r.Invoice_Period__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c 
                               FROM Invoice_Line_Item__c  WHERE id = :invoiceLineItemId
                               LIMIT 1];
        }
        catch (Exception e) {
            return null;
        }
        return invoiceLineItem;
    }
     /*----------------------------------------------------------------
Method     : invoiceLineItemList
Description: Method to download the data from Invoice page
Author     : Mohammed Zeeshan
Story      : EDGE-141682 
-------------------------------------------------------------------------------------*/   
    @AuraEnabled
    
    public static UsageSummaryHandler.invoiceLineItemListWrapper invoiceLineItemList(string InvoiceLineNumber){
        UsageSummaryHandler.invoiceLineItemListWrapper invoiceLineItemWrapper = new UsageSummaryHandler.invoiceLineItemListWrapper();
        Invoice_Line_Item__c invoiceLineItemRecDetails = new Invoice_Line_Item__c();
        String accountName;
        String caseNumber;
        String accountNumber;
        List<Queried_Line_Item__c> qliList = new List<Queried_Line_Item__c>();
        Invoice_Line_Item__c invoiceLine= new Invoice_Line_Item__c();
        invoiceLine = [select id,Name,Offer_Name__c,Physical_Location_Name__c,Line_Item_Identifier__c,Invoice_Line_Number__c,Service_Type__c,Charge_Type__c,Quantity__c, Is_Taxable__c, Charge_Excluding_GST__c,Charge_Including_GST__c,Invoice__r.Name,Invoice__r.Billing_Account__r.Billing_Account_Number__c  ,Invoice__r.Billing_Account__r.Account__r.Name,Invoice__r.Billing_Account__r.Account__r.AccountNumber, (select id,case__r.caseNumber from Queried_Line_Items__r) from Invoice_Line_Item__c  where id =: InvoiceLineNumber limit 1];
        invoiceLineItemWrapper.invoiceLineItemRecDetails = invoiceLine;
        for(Queried_Line_Item__c qli : invoiceLine.Queried_Line_Items__r){
            caseNumber = qli.case__r.caseNumber;
        }
        accountName = invoiceLine.Invoice__r.Billing_Account__r.Account__r.Name;
        accountNumber = invoiceLine.Invoice__r.Billing_Account__r.Account__r.AccountNumber;
        System.debug('accountNumber'+accountNumber);
        invoiceLineItemWrapper.caseNumber = caseNumber;
        invoiceLineItemWrapper.accountName = accountName;
        invoiceLineItemWrapper.accountNumber = accountNumber;
        // account 2nd query // inner class return case and Account details fetch billing account # and Account number
        return invoiceLineItemWrapper;
    }   
/*----------------------------------------------------------------
Method     : getInvoiceDetails
Description: Method to get Invoice charge details for corresponding Invoice
Author     : Pradeep
Story      : EDGE-163366 
-------------------------------------------------------------------------------------*/  
    @AuraEnabled
    public static Map<Integer,String> getInvoiceDetails(String request,String handlerName){
       Map<Integer,String> response;
        response=UsageCalloutHandler.calloutInvoiceDetails(request,handlerName);
        return response;
    }
    
        /*----------------------------------------------------------------
Method     : upsertInvoiceLineItem
Description: Method to upsert Invoice Line Item
Author     : Shresth
Story      : DPG-3572
-------------------------------------------------------------------------------------*/  
@AuraEnabled
public static void upsertInvoiceLineItem(Invoice_Line_Item__c invoiceLineItem){
    try{ 
      Upsert invoiceLineItem;
    }
    catch(Exception e){
        throw new aurahandledexception('Please contact your system adminstrator :'+e.getMessage());
    }
}

    

    
    /*----------------------------------------------------------------
    Inner Class     : rcPicklistWrapper
    Description: Wrapper class for invoiceLineItemList
    Author     : Mohammed Zeeshan
    Story      : EDGE-141682 
    -------------------------------------------------------------------------------------*/
    public class invoiceLineItemListWrapper{
        @AuraEnabled
        public Invoice_Line_Item__c invoiceLineItemRecDetails {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public String accountNumber {get;set;}
        @AuraEnabled
        public String caseNumber {get;set;}
        
        
        public invoiceLineItemListWrapper() {
            invoiceLineItemRecDetails=new Invoice_Line_Item__c();
            String accountName;
            String accountNumber;
            String caseNumber;
        }
    }
    
    /*----------------------------------------------------------------
Method     : getQueryLineItems
Description: Method to get query line items based on invoice line items
Author     : Jayghosh
Team     : Osaka
Story      : EDGE-163368 
-------------------------------------------------------------------------------------*/ 
    
    
    @AuraEnabled(cacheable=true)
    public static List<Queried_Line_Item__c> getQueryLineItems(String invoiceId){
        
        List<Queried_Line_Item__c> fetchRecord = new List<Queried_Line_Item__c> ();
        
        try{

            fetchRecord = [select Id, name, Case__c, Max_Credit_Amount__c, Reason_Code__c, Determination_Amount__c, Case__r.CaseNumber, Invoice_Line_Item__r.Invoice__r.Name, Invoice_Line_Item__r.Invoice__r.Billing_Account__r.Billing_Account_Number__c, Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c, Credit_Adjustment__r.Date_when_credit_was_given_to_customer__c, Invoice_Line_Item__r.Invoice_Line_Number__c, Invoice_Line_Item__r.Charge_Identifier__c, Invoice_Line_Item__r.Charge_Type__c from Queried_Line_Item__c where Credit_Adjustment__r.Submitted__c = true AND Invoice_Line_Item__c =:invoiceId ORDER BY Credit_Adjustment__r.Date_when_credit_was_given_to_customer__c];

        }
        catch (Exception e) {
            return null;
        }
        return fetchRecord;
    }
    /*----------------------------------------------------------------
    Method     : createDeviceCSV
    Description: Method to generate a csv of deviceIds if there are multiple deviceIds
    Author     : Mukta Wadhwani
    Team	   : Apple
    Story      : EDGE-223833 
    -------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static Id createDeviceCSV(String invoiceLineId,String deviceId){
        Id contentersionId ;
        List<ContentDocumentLink> existingContentDocList = new List<ContentDocumentLink>();
        if(!FeatureEligibilityChecker.determineFeatureEligiblity('B2B11159','deviceIds') && !Test.isRunningTest()){
            return contentersionId;
        }
        try{
            existingContentDocList = [select id,ContentDocument.LatestPublishedVersion.Id from ContentDocumentLink where LinkedEntityId =: invoiceLineId and ContentDocument.Title = 'DeviceIds.csv'];

            if(existingContentDocList.isEmpty() && !String.isBlank(deviceId)){
                List<String> deviceIdList = deviceId.split(',');
                String csvContent = 'Device Id\n'+String.join(deviceIdList,'\n');
                ContentVersion cVersion = new ContentVersion();
                cVersion.PathOnClient = 'DeviceIds.csv';
                cVersion.Title = 'DeviceIds.csv';
                cVersion.VersionData = Blob.valueOf(csvContent);
                Insert cVersion;
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = invoiceLineId;
                Insert cDocLink;
                contentersionId = cVersion.Id;
            }
            else{
                contentersionId = existingContentDocList[0].ContentDocument.LatestPublishedVersion.Id;
            }
        }
        catch(Exception e){
            logException('createDeviceCSV','',correlationId, e.getMessage(), 'device ID csv creation failed.',CONST_INTERFACENAME);
        }
        return contentersionId;
    }
    /*----------------------------------------------------------------
    Method     : logException
    Description: Method to log exceptions
    Author     : Mukta Wadhwani
    Team	   : Apple
    Story      : EDGE-223833 
    -------------------------------------------------------------------------------------*/ 
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,String CONST_INTERFACENAME){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}