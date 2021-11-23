/*************************************************************************************************
Name : InvoiceCalloutHandler
Description : Service class for Invoice API
Author: Kalashree Borgaonkar
Story: EDGE-88307
Modified by: Manjunath Ediga(Osaka Team),EDGE-115138
Refactored by: Ramya G(Osaka), EDGE-127660:Hackathon
***************************************************************************************************/
public with sharing class InvoiceCalloutHandler {
    public static final String  handlerName = 'InvoiceByNumberHandler'; 
    public static final String  handlerNamePdf = 'InvoicePDFHandler';   
    public static final String  handlerInvoice = 'InvoiceHandler'; 
    public static final string  QLIENRICHHANDLER ='InitiateQLIEnrichment';
    public static Boolean invSkipCallout=false;

/*-------------------------------------------------------- 
EDGE-119417,EDGE-115138
Inner Class: Offer
Description: Added as part of code refactoring to store the necessary values at the offer level
Author:Ramesh Somalagari
--------------------------------------------------------*/   
    public class Offer{
        
        public Integer identifier;
        public String offerName;
        public Double offerTotalExcludingGstCost;
        public Double offerTotalIncludingGstCost;
        public Integer invoiceDef;
    }
    
/*-------------------------------------------------------- 
//Defect Fix and Refactoring
Inner Class: ProductOffer & CreditOffer
Description: Added as part of extending the class for CMP structure and code refactoring 
Author: Ramya G
--------------------------------------------------------*/
    public class ProductOffer{
        
        public Offer offer;
        public InvoiceResponseDTO.ListOfProducts productOffer;
        
    }
 
/*-------------------------------------------------------- 
//Defect Fix and Refactoring
Inner Class: ProductOffer & CreditOffer
Description: Added as part of extending the class for CMP structure and code refactoring 
Author: Ramya G
--------------------------------------------------------*/
 
    public class CreditOffer{
        
        public Offer offer;
        public InvoiceResponseDTO.listOfChargesAndCredits creditOffer;
        
    }
/*-------------------------------------------------------- 
EDGE-92010
Method: calloutInvoiceByNumber overriding
Description: Method to make callout to Invoice API using Invoice Number
Author:Manjunath Ediga
--------------------------------------------------------*/
        
        public static InvoiceResponseDTO calloutInvoiceByNumber(invoiceRequestDTO  invoiceRequest)
        { 
            InvoiceResponseDTO response = null;
              /*** START OF EDGE-125016
              Adding the try catch block ***/
            try{
                String strResponse = calloutInvoiceByNumber(invoiceRequest,false);
                System.debug('strResponse :: '+strResponse);
                response = InvoiceResponseDTO.parse(strResponse);
                System.debug('response :: '+response);
            }catch(Exception e){
            
            System.debug('Error :: '+e);
            }
            
              /*** END OF EDGE-125016 ***/
            return response;
            
        }
            /*-------------------------------------------------------- 
EDGE-88307
Method: calloutInvoiceByNumber
Description: Method to make callout to Invoice API using Invoice Number
Author:Kalashree Borgaonkar
Modified: Manjunath Ediga
--------------------------------------------------------*/
    public static String calloutInvoiceByNumber(invoiceRequestDTO  invoiceRequest,Boolean skipCommit){
        InvoiceResponseDTO response = null;
        Logger2 logger = Logger2.getLogger(handlerName);
        String reqBody = JSON.serialize(invoiceRequest,true);
        String correlationId = EDISSingleManager.getUID();
        HttpResponse invResponse;
        try {
            system.debug('-------->insidetry');  
            String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
             //START of EDGE-127660:Hackathon:Ramya
            token=setToken(handlerName);
            //system.debug('token set is '+token);
             //END of EDGE-127660:Hackathon:Ramya
           //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            /**if(!Test.isRunningTest()){
                //token = AuthenticationManager.getOauthToken(handlerName);

            }*/
            Map < String, String > headerMap = new Map < String, String > {
                'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + token,
                    'correlationId' => correlationId
                    };
            system.debug('---->reqBody'+reqBody);
            system.debug('---->IntegrationRecordHandlerUtil'+ IntegrationRecordHandlerUtil.HTTP_METHOD_POST);
            system.debug('---->headerMap'+headerMap);
            system.debug('---->handlerName'+handlerName);          
            invResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            // Check that invoice response is not null
            if(invResponse!=null){
            system.debug('response::' + invResponse.getBody());
            String responseCode = String.valueOf(invResponse.getStatusCode());
            
            if (responseCode.startsWith('2')) {
                
                logger.logMessages(reqBody, invResponse.getBody(), '', '', '', '', false, false,Integer.valueof(invResponse.getStatusCode()) , null, null, null);
                if(skipCommit){
                    return invResponse.getBody();
                }
                else{
                 response = InvoiceResponseDTO.parse(invResponse.getBody());
                 saveResponse(response);
                }
            } else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                response = InvoiceResponseDTO.parse(invResponse.getBody());
                logger.logMessages(reqBody, invResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(invResponse.getStatusCode()) , null, null, null);
            }
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        system.debug('invResponse--------->'+invResponse.getBody());
       // Check if invoice response is not null
        if(invResponse!=null){
        return invResponse.getBody();
        }else{
            return null;
        }
    }
     /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: setToken
    Description: Refactored Method to set token dynamically
    Author:Ramya G
    --------------------------------------------------------*/
    
    public static String setToken(String handlerName) {
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        String token='';
            if(handleSettingRecord!=null) {
                if(handleSettingRecord.Enable_Mock_Integration__c) {
                     token = System.Label.QLI_Token;
                     return token;
                }
               // System.debug('Token for  ' + handlerName + ' is ' +token);
                token =AuthenticationManager.getOauthToken(handlerName);                            
                
            }
            return token;
    }
    /*-------------------------------------------------------- 
EDGE-88307
Method: calloutInvoicePDF
Description: Method to make callout to generate PDF 
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static HttpResponse calloutInvoicePDF(invoiceRequestDTO  invoiceRequest){
        String res =null;
        Logger2 logger = Logger2.getLogger(handlerNamePdf);
        String reqBody = JSON.serialize(invoiceRequest,true);
        String correlationId = EDISSingleManager.getUID();
        HttpResponse response=null;
        try {
            String token = AuthenticationManager.getOauthToken(handlerNamePdf);
            //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            
            Map < String, String > headerMap = new Map < String, String > {
           
                
                
                'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + token,
                    'correlationId' => correlationId
                    };
            response = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerNamePdf);
            String responseCode = String.valueOf(response.getStatusCode());
            System.debug('responseCode: '+responseCode);
            if (responseCode.startsWith('2')) {
                logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
            } else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()), null, null, null);
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return response;
    }
    /*-------------------------------------------------------- 
EDGE-88307
Method: createPayload
Description: Method to create payload for Invoice Number
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static InvoiceRequestDTO createPayload(String customerAccountNumber,Long invoiceNumber){
        InvoiceRequestDTO requestDto = new InvoiceRequestDTO();
        requestDto.customerAccountNumber=customerAccountNumber;
        requestDto.invoiceNumber=invoiceNumber;
        return requestDto;
    }
    /*-------------------------------------------------------- 
EDGE-88307
Method: saveResponse
Description: Method to save Response from getInvoiceDetailsByNumber callout
Author:Kalashree Borgaonkar
Modified by : Manjunath Ediga(Osaka Team),EDGE-115138 to get Invoice Period populated from getInvoiceDetailsByNymber callout
--------------------------------------------------------*/
    public static void saveResponse(InvoiceResponseDTO responseDto){
       Invoice__c invoice = null;
       saveResponse(responseDto,invoice);
    }
    
    public static void saveResponse(InvoiceResponseDTO responseDto,Invoice__c invoice){        
        
        //List<Invoice__c> invoiceList = null;
        String year=null;
        //String accountNumber = null;
        //String str=null;
        List<string> dateStringSplit =  responseDto.PaymentSummary.dueDate.split(' ');
        year = '20'+dateStringSplit[2];
        try{
            if(invoice==null) {
             invoice = saveInvoice(responseDto);
              
            } 
            System.debug('invoice.id: '+invoice.id);
            if(invoice.id!=null){
                //Modified the Map type to offer identifier as key and a combination of offer and products as value.
                //Map<InvoiceCalloutHandler.Offer, InvoiceResponseDTO.ListOfProducts> productsMap = new Map<InvoiceCalloutHandler.Offer,InvoiceResponseDTO.ListOfProducts>();
                Map<Integer,InvoiceCalloutHandler.ProductOffer> productsMap = new Map<Integer,InvoiceCalloutHandler.ProductOffer>();
                productsMap=getProducts(responseDto,invoice.id,year);
                Map<Integer,InvoiceCalloutHandler.CreditOffer> creditMap = new Map<Integer,InvoiceCalloutHandler.CreditOffer>();
                creditMap = getCreditCharge(responseDto,invoice.id,year);
                List <Invoice_Line_Item__c> productILI = new List <Invoice_Line_Item__c>();
                if(!productsMap.isEmpty()) {
                   
                      productILI= updateInvoiceLineItems(productsMap,invoice.id,year);
                 }
                 //START of Credit ILI:Ramya
                 updateCreditInvoiceLineItems(creditMap,invoice.id,productILI,year);                 
                           
                  
                  
                  //END of credit ILI
                //Start of EDGE-120657: Added modular code for creating adjustment line item
                //Hackathon: Passed the list.
                updateAdjustmentLineItem(responseDto,invoice.id,productILI);
                
                //EDGE-120657: Merged all invoice lineitems into single list for commit
                
                //EDGE-120657: Moved the logic to commit all invoice line item records together  
                    try{
                        //Start of EDGE:164871 : Check if this update is part of Insert(true) update(false)
                    if (!productILI.isEmpty()) {
                     system.debug('===> Inside upsert'+productILI); 
                     upsert productILI Line_Item_Identifier__c;
                          UpdateInvoiceDetail.updateInvoiceLineDetails(productILI,invoice.id);
                     }
                   
                    }catch(exception e){system.debug('exception in upsert'+e.getLineNumber()+'Message is :'+e.getMessage());}
                //End of EDGE-120657    
                
            }
            
        } catch (Exception e) {
            System.debug('Exception in saveResponse: '+e.getStackTraceString() + e.getCause() + e.getMessage());
        }   
    }
    
    public static Invoice__c  saveInvoice(InvoiceResponseDTO responseDto,Boolean skipCallOut){
    invSkipCallout = skipCallOut;             
    Invoice__c invoice =saveInvoice(responseDto); 
    return invoice ;    
      }    
    
    public static Invoice__c saveInvoice(InvoiceResponseDTO responseDto){
        Invoice__c invoice = null;
        //List<Invoice__c> invoiceList = null;
        String year=null;
        Boolean isAriaNumberCheck;
        String accountNumber = null;
        List<string> dateStringSplit;
        String str=null;
        try{
            if(responseDto.InvoiceDetails!=null){
                invoice = new Invoice__c();
                accountNumber = responseDto.InvoiceDetails.accountNumber;
                System.debug('accountNumber: '+accountNumber);
                List<Billing_Account__c> billingAccount = [SELECT id FROM Billing_Account__c WHERE Billing_Account_Number__c=:accountNumber];
                
                if(!billingAccount.isEmpty()){
                    invoice.Billing_Account__c = billingAccount[0].id;
                }
                invoice.Name = responseDto.InvoiceDetails.invoiceNumber;
                if(responseDto.InvoiceDetails.invoiceIssueDate!=null){
                    dateStringSplit =  responseDto.InvoiceDetails.invoiceIssueDate.split(' ');
                    str='20'+dateStringSplit[2]+  '-'+getMonth(dateStringSplit[1])+'-'+       dateStringSplit[0];
                    invoice.Issue_Date__c = Date.valueOf(str);
                    year = '20'+dateStringSplit[2];
                    dateStringSplit.clear();
                }
                if(responseDto.InvoiceDetails.invoicePeriod!=null){
                    //Start of EDGE-115138 : Removed Start Date and End Date and added only Invoice Period   
                    invoice.Invoice_Period__c = responseDto.InvoiceDetails.invoicePeriod;
                    //End of EDGE-115138
                }
                invoice.Aria_Invoice_Number__c = responseDto.InvoiceDetails.ariaInvoiceNumber;
            }
            if(responseDto.PaymentSummary!=null){
                invoice.Balance_Carried_Forward__c = responseDto.PaymentSummary.balanceCarriedForward;
                invoice.Total_Due__c = responseDto.PaymentSummary.totalDue;
                invoice.Payments_and_Adjustments__c = responseDto.PaymentSummary.paymentsAndAdjustments;
                if(responseDto.PaymentSummary.dueDate!=null){
                    dateStringSplit =  responseDto.PaymentSummary.dueDate.split(' ');
                    str='20'+dateStringSplit[2]+  '-'+getMonth(dateStringSplit[1])+'-'+       dateStringSplit[0];
                    //Start of defect EDGE-134136:Changed issue date to due date.
                    invoice.Due_Date__c = Date.valueOf(str);
                    //End of defect EDGE-134136
                    dateStringSplit.clear();
                }
                invoice.New_Charge__c = responseDto.PaymentSummary.newCharges;
            }

           if (invSkipCallout){
               invoice.skipInvoiceCallout__c=true;}

            /*if(invoice!=null){
                upsert invoice Aria_Invoice_Number__c;
            }*/
            //Start of Defect EDGE:132933 (User Story - EDGE-130452)
        List<Invoice__c> InvoiceName = [SELECT id,name,Aria_Invoice_Number__c FROM Invoice__c WHERE name=:responseDto.InvoiceDetails.invoiceNumber Limit 1];      
        //Matching Aria Number in object and response
        isAriaNumberCheck = invoice!=null && !InvoiceName.isEmpty() && invoice.Aria_Invoice_Number__c == InvoiceName[0].Aria_Invoice_Number__c;
        if (isAriaNumberCheck)
         {
         upsert invoice Aria_Invoice_Number__c;             
         } 
         //Overwrite Aria Number in object in case of mismatch of Aria Number in response
        else{
        upsert invoice Name;
        }        
        //END OF Defect EDGE-132933     
            
            
        } catch (Exception e) {
            System.debug('Exception in saveResponse: '+e.getStackTraceString() + e.getCause() + e.getMessage());
        }
        return invoice;
    }
    
    /*-------------------------------------------------------- 
EDGE-88307
Method: getProducts
Description: Method to save Response from getInvoiceDetailsByNumber callout
Author:Ramesh Somalagari
--------------------------------------------------------*/
    public static Map<Integer,InvoiceCalloutHandler.ProductOffer>
        getProducts(InvoiceResponseDTO responseDto,String invoiceId,String year){
            InvoiceCalloutHandler.Offer offerInstance=null;
            InvoiceCalloutHandler.ProductOffer productInstance=null;
            //Map<Integer, InvoiceResponseDTO.ListOfProducts> productsMap= new Map<Integer,InvoiceResponseDTO.ListOfProducts>();
            Map<Integer, InvoiceCalloutHandler.ProductOffer> productsMap= new Map<Integer, InvoiceCalloutHandler.ProductOffer>();
            try{
                if(responseDto.serviceSummary!=null ){
                    integer identifier=0;
                    //List<InvoiceResponseDTO.ListOfProducts> productList = new List<InvoiceResponseDTO.ListOfProducts>();
                    for(InvoiceResponseDTO.ListOfOffers offer : responseDto.serviceSummary.listOfOffers){
                        
                        if(offer.listOfProducts != null){
                        for(InvoiceResponseDTO.ListOfProducts products: offer.listOfProducts){
                            identifier++;
                            offerInstance = new InvoiceCalloutHandler.Offer();
                            //EDGE-124921: Added offer and product details to a wrapper class
                            productInstance = new InvoiceCalloutHandler.productOffer();
                            offerInstance.offerName=offer.offerName;
                            offerInstance.offerTotalExcludingGstCost=offer.offerTotalExcludingGstCost;
                            offerInstance.offerTotalIncludingGstCost=offer.offerTotalIncludingGstCost;
                            offerInstance.invoiceDef=offer.invoiceDef;                          
                            
                            offerInstance.identifier = identifier;
                            //Start of EDGE-124921: Setoffer and product details to a wrapper class
                            productInstance.productOffer =  products;   
                            productInstance.offer        = offerInstance;
                            //Endof EDGE-124921
                            if(products.listOfChargesAndCredits!=null)
                            {
                                //productsMap.put(offerInstance,products);
                                productsMap.put(offerInstance.identifier, productInstance);
                            }
                        }
                    }
                }
                }
                
            } catch (Exception e) {
                System.debug('Exception in SaveInvoiceItems: '+e.getStackTraceString()+e.getMessage());
            } 
            return productsMap;
            
        }
        
    /*-------------------------------------------------------- 
EDGE-88307
Method: getCreditCharge
Description: Method to save Response from getInvoiceDetailsByNumber callout
Author:Ramya
--------------------------------------------------------*/
    public static Map<Integer,InvoiceCalloutHandler.CreditOffer>
        getCreditCharge(InvoiceResponseDTO responseDto,String invoiceId,String year){
            InvoiceCalloutHandler.Offer offerInstance=null;
            InvoiceCalloutHandler.CreditOffer creditInstance=null;
            //Map<Integer, InvoiceResponseDTO.ListOfProducts> productsMap= new Map<Integer,InvoiceResponseDTO.ListOfProducts>();
            Map<Integer, InvoiceCalloutHandler.CreditOffer> creditMap= new Map<Integer, InvoiceCalloutHandler.CreditOffer>();
            try{
                if(responseDto.serviceSummary!=null ){
                    integer identifier=0;
                    InvoiceResponseDTO.ListOfChargesAndCredits credits = new InvoiceResponseDTO.ListOfChargesAndCredits();
                    for(InvoiceResponseDTO.ListOfOffers offer : responseDto.serviceSummary.listOfOffers){
                        
                        
                            credits = offer.listOfChargesAndCredits;
                            identifier++;
                            offerInstance = new InvoiceCalloutHandler.Offer();
                            //EDGE-124921: Added offer and product details to a wrapper class
                            creditInstance = new InvoiceCalloutHandler.creditOffer();
                            offerInstance.offerName=offer.offerName;
                            offerInstance.offerTotalExcludingGstCost=offer.offerTotalExcludingGstCost;
                            offerInstance.offerTotalIncludingGstCost=offer.offerTotalIncludingGstCost;
                            offerInstance.invoiceDef=offer.invoiceDef;                          
                            
                            offerInstance.identifier = identifier;
                            //Start of EDGE-124921: Setoffer and product details to a wrapper class
                            creditInstance.creditOffer =  credits;   
                            creditInstance.offer        = offerInstance;
                            System.debug('credits ---------->'+credits);
                             System.debug('offer.listOfChargesAndCredits ---------->'+offer.listOfChargesAndCredits);
                            //Endof EDGE-124921
                            if(credits!=null)
                            {
                                //productsMap.put(offerInstance,products);
                                creditMap.put(offerInstance.identifier, creditInstance);
                            }
                        
                    }
                }
                
            } catch (Exception e) {
                System.debug('Exception in SaveInvoiceItems: '+e.getStackTraceString()+e.getMessage());
            } 
            return creditMap;
            
        }        
    /**
*  Refactoring the code as a part of EDGE-115138
*  @name              - updateInvoiceLineItems
*  @param productMap  - List of Product Map
*  @return void       - 
*  @throws exception  - NA
*  @jira Story Ref    - EDGE-119417,EDGE-115138,EDGE-120657
*  @createdBy         - Ramesh Somalagari
*  @Modified by       - Mohammed Zeeshan 
*  @team              - OSAKA
*  @Description       - Return all offer based Invoice line item in the invoice api response. 
*                       EDGE-120657:Changed return type to list of Invoice line item and removed commit logic
**/
    public static List<Invoice_Line_Item__c> updateInvoiceLineItems(Map<Integer,InvoiceCalloutHandler.ProductOffer> productMap,String invoiceId,String year) {
        List<Invoice_Line_Item__c>lineItemList = new List<Invoice_Line_Item__c>();
       //List<string> dateStringSplit;
       // String genericDate = null;
 
        for(Integer offerId : productMap.keySet()){
           // InvoiceCalloutHandler.ProductOffer prodOfferInstance= productMap.get(offerId);

           // InvoiceResponseDTO.ListOfProducts products = productMap.get(offer);
           InvoiceResponseDTO.ListOfProducts products = productMap.get(offerId).productOffer;
           InvoiceCalloutHandler.Offer offerInstance = productMap.get(offerId).offer;
            //Invoice_Line_Item__c lineItem  = null;
            //Handle CMP fix to check products are not null
            if(products != null && products.listOfChargesAndCredits != null){
            //START of EDGE-127660:Hackathon:Ramya
            if(products != null && products.listOfChargesAndCredits.planCharges != null){
                getPlanCharges(lineItemList, products, offerInstance,invoiceId, year);
            }
            
            if (products != null && products.listOfChargesAndCredits.onceOffChargesAndCredits != null) {
                getOnceOffCharges(lineItemList, products, offerInstance, invoiceId);
            }
    
            if (products != null && products.listOfChargesAndCredits.UsageSummaryCharges != null) {
                //Start of EDGE-115138, Adding Invoice Line Attributes under UsageSummaryCharges and creating a Invoice Line Item Record
                getUsageSummaryCharges(lineItemList, products, offerInstance, invoiceId);
            }
            //END of EDGE-127660:Hackathon:Osaka:Ramya
            }  
        }
        //Start of EDGE-120657
        return lineItemList;
        //End of EDGE-120657
    }
    
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: getPlanCharges
    Description: Refactored Method to get plan charges
    Author:Ramya G
    --------------------------------------------------------*/
    public static void getPlanCharges(List<Invoice_Line_Item__c>lineItemList, InvoiceResponseDTO.ListOfProducts products,InvoiceCalloutHandler.Offer offerInstance,String invoiceId,String year) {
        Invoice_Line_Item__c lineItem;
        List<string> dateStringSplit;
        String genericDate = null;
        for(InvoiceResponseDTO.PlanCharges planCharge: products.listOfChargesAndCredits.planCharges){
                        //Start of EDGE-115138, Adding Invoice Line Attributes under plancharges and creating a Invoice Line Item Record
             if(planCharge.invoiceLineAttributes !=null ){          
                        for (InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute: planCharge.invoiceLineAttributes) {
                            lineItem = new Invoice_Line_Item__c();
                            //START of EDGE-127660:Hackathon:Ramya
                            setOfferDetails(lineItem, offerInstance, invoiceId);
                            setPlanDetails(lineItem,planCharge,invoiceLineAttribute);
                            //END of EDGE-127660:Hackathon
                            
                            lineItem.Physical_Location_Name__c = products.physicalLocationName;
                            lineItem.Site_Excluding_GST_Cost__c= products.siteExcludingGstCost;
                            lineItem.Site_Including_GST_Cost__c= products.siteIncludingGstCost;

                            if(planCharge.startDate!=null){
                                dateStringSplit =  planCharge.startDate.split(' ');
                                genericDate =year+    '-'+getMonth(dateStringSplit[1])+'-'+       dateStringSplit[0];
                                lineItem.Start_Date__c = Date.valueOf(genericDate);
                                dateStringSplit.clear();
                            }
                            if(planCharge.endDate!=null){
                                dateStringSplit =  planCharge.endDate.split(' ');
                                genericDate=year+    '-'+getMonth(dateStringSplit[1])+'-'+       dateStringSplit[0];
                                lineItem.End_Date__c = Date.valueOf(genericDate);
                                dateStringSplit.clear();
                            }
                            if(lineItem!=null)
                                lineItemList.add(lineItem);
                        }
                    }
                    }
    
    }
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: getOnceOffCharges
    Description: Refactored Method to get once-off charges
    Author:Ramya G
    --------------------------------------------------------*/
    public static void getOnceOffCharges(List<Invoice_Line_Item__c>lineItemList, InvoiceResponseDTO.ListOfProducts products,InvoiceCalloutHandler.Offer offerInstance, String invoiceId) {
        Invoice_Line_Item__c lineItem;        
        for (InvoiceResponseDTO.onceOffChargesAndCredits onceOffChargesAndCredit: products.listOfChargesAndCredits.onceOffChargesAndCredits) {
                    if (onceOffChargesAndCredit.invoiceLineAttributes != null) {
                     //setOnesOffLineItem(InvoiceResponseDTO.onceOffChargesAndCredits onceOffChargesAndCredit,InvoiceCalloutHandler.Offer offerInstance, String invoiceId,String year
                        //Start of EDGE-115138, Adding Invoice Line Attributes under onceOffChargesAndCredits and creating a Invoice Line Item Record
                        for (InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute: onceOffChargesAndCredit.invoiceLineAttributes) {
                           
                            lineItem = new Invoice_Line_Item__c();
                            //START of EDGE-127660:Hackathon:Ramya
                            setOfferDetails(lineItem, offerInstance, invoiceId);
                            setOnceOffDetails(lineItem,onceOffChargesAndCredit, invoiceLineAttribute);
                            //END of EDGE-127660:Hackathon
                            lineItem.Physical_Location_Name__c = products.physicalLocationName;
                            lineItem.Site_Excluding_GST_Cost__c = products.siteExcludingGstCost;
                            lineItem.Site_Including_GST_Cost__c = products.siteIncludingGstCost;
                            lineItem.Physical_Location_Name__c = products.physicalLocationName;
                            lineItem.Site_Excluding_GST_Cost__c= products.siteExcludingGstCost;
                            lineItem.Site_Including_GST_Cost__c= products.siteIncludingGstCost;
                            if(lineItem!=null)
                                lineItemList.add(lineItem);  
                        }
                    }  
                }

    }
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: getUsageSummaryCharges
    Description: Refactored Method to get usage charges
    Author:Ramya G
    --------------------------------------------------------*/
    public static void getUsageSummaryCharges(List<Invoice_Line_Item__c>lineItemList, InvoiceResponseDTO.ListOfProducts products,InvoiceCalloutHandler.Offer offerInstance, String invoiceId) {
        Invoice_Line_Item__c lineItem;        
        for (InvoiceResponseDTO.UsageSummaryCharges usageSummaryCharge: products.listOfChargesAndCredits.UsageSummaryCharges) {
                        for (InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute: usageSummaryCharge.invoiceLineAttributes) {
                             lineItem = new Invoice_Line_Item__c();
                             //START of EDGE-127660:Hackathon:Ramya
                            setOfferDetails(lineItem, offerInstance, invoiceId);
                            setUsageDetails(lineItem,usageSummaryCharge, invoiceLineAttribute);
                            //END of EDGE-127660:Hackathon
                            lineItem.Physical_Location_Name__c = products.physicalLocationName;
                            lineItem.Site_Excluding_GST_Cost__c = products.siteExcludingGstCost;
                            lineItem.Site_Including_GST_Cost__c = products.siteIncludingGstCost;
                            if(lineItem!=null)
                                lineItemList.add(lineItem);
                        }                    
                    
                }
    }
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: setOfferDetails
    Description: Refactored Method - Repetitive code moved to this new method
    Author:Ramya G
    --------------------------------------------------------*/
    
    public static void setOfferDetails(Invoice_Line_Item__c lineItem, InvoiceCalloutHandler.Offer offerInstance, String invoiceId) {
        lineItem.Invoice__c = invoiceId;
        lineItem.Offer_Name__c = offerInstance.offerName;
        lineItem.Offer_Total_Excluding_GST_Cost__c = offerInstance.offerTotalExcludingGstCost;
        lineItem.Offer_Total_Including_GST_Cost__c = offerInstance.offerTotalIncludingGstCost;
        lineItem.Invoice_Def__c = offerInstance.invoiceDef;
    }
    
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: setPlanDetails
    Description: Refactored Method - Repetitive code moved to this new method
    Author:Ramya G
    --------------------------------------------------------*/
    
    public static void setPlanDetails(Invoice_Line_Item__c lineItem,InvoiceResponseDTO.PlanCharges planCharge, InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute) {
        lineItem.Service_Type__c= planCharge.serviceType;
       //Start of : EDGE-130452
         //lineItem.Quantity__c= planCharge.quantityWithUnit;
        //lineItem.Quantity__c= planCharge.quantity;
        //End of : EDGE-130452
        lineItem.Excluding_Cost__c= planCharge.excludingGstCost;
        lineItem.Including_Cost__c= planCharge.includingGstCost;
        lineItem.Sigma_Id__c= planCharge.sigmaSpecId;
        lineItem.Is_Aggregated__c= planCharge.isAggregated;
        lineItem.Is_Taxable__c= planCharge.isTaxable;
        lineItem.Is_Queryable__c= planCharge.isQueryable;
        lineItem.Charge_Identifier__c= (planCharge.chargeIdentifier!=null)?planCharge.chargeIdentifier:null;
        lineItem.Charge_Type__c= planCharge.chargeType;
        //EDGE-115138,Capturing  Invoice_Line_Number__c,Invoice_Transaction_ID__c,Charge_Excluding_GST__c,Charge_Including_GST__c at the time of creating record
        lineItem.Invoice_Line_Number__c = invoiceLineAttribute.invoiceLineNumber;
        lineItem.Invoice_Transaction_ID__c = invoiceLineAttribute.invoiceTransactionId;
        lineItem.Charge_Excluding_GST__c = invoiceLineAttribute.chargeExcludingGST;
        lineItem.Charge_Including_GST__c = invoiceLineAttribute.chargeIncludingGST;
        lineItem.Charge_Id__c = (planCharge.drillDownInputAttribute != null) ? String.valueOf(planCharge.drillDownInputAttribute.chargeId) : null;
        lineItem.Line_Item_Identifier__c = lineItem.Charge_Type__c + lineItem.Charge_Identifier__c + lineItem.Invoice_Transaction_ID__c;
        lineItem.Drill_Down_Endpoint__c = planCharge.drillDownEndpoint;
        //Start of EDGE:164871 mapping de-aggregated quantity at the invoice line item.
        lineItem.Quantity__c = invoiceLineAttribute.quantity;
    //End of EDGE:164871  
        //End of : EDGE-115138
        //Start of EDGE:164871 capturing isDrillable from Discounts Attributes to enable for Discount callout at ILI
        if(planCharge.discounts != null ){
            for(InvoiceResponseDTO.Discounts discILI : planCharge.discounts ){
            lineItem.Is_Discount_Drillable__c = discILI.isDrillable;
          }
        }
        //End of EDGE:164871
    }
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: setOnceOffCharges
    Description: Refactored Method - Repetitive code moved to this new method
    Author:Ramya G
    --------------------------------------------------------*/
    
    public static void setOnceOffDetails(Invoice_Line_Item__c lineItem,InvoiceResponseDTO.onceOffChargesAndCredits onceOffChargesAndCredit, InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute) {
        lineItem.Service_Type__c= onceOffChargesAndCredit.serviceType;
        //Start of : EDGE-130452
        // lineItem.Quantity__c= onceOffChargesAndCredit.quantityWithUnit;
         //lineItem.Quantity__c= onceOffChargesAndCredit.quantity;
        //End of : EDGE-130452
        lineItem.Excluding_Cost__c= onceOffChargesAndCredit.excludingGstCost;
        lineItem.Including_Cost__c= onceOffChargesAndCredit.includingGstCost;
        lineItem.Sigma_Id__c= onceOffChargesAndCredit.sigmaSpecId;
        lineItem.Is_Aggregated__c= onceOffChargesAndCredit.isAggregated;
        lineItem.Is_Taxable__c= onceOffChargesAndCredit.isTaxable;
        lineItem.Is_Queryable__c= onceOffChargesAndCredit.isQueryable;
        lineItem.Charge_Identifier__c= (onceOffChargesAndCredit.chargeIdentifier!=null)?onceOffChargesAndCredit.chargeIdentifier:null;
        //EDGE-115138,Capturing Invoice_Line_Number__c,Invoice_Transaction_ID__c,Charge_Excluding_GST__c,Charge_Including_GST__c at the time of creating record
        lineItem.Invoice_Line_Number__c = invoiceLineAttribute.invoiceLineNumber;
        lineItem.Invoice_Transaction_ID__c = invoiceLineAttribute.invoiceTransactionId;
        lineItem.Charge_Excluding_GST__c = invoiceLineAttribute.chargeExcludingGST;
        lineItem.Charge_Including_GST__c = invoiceLineAttribute.chargeIncludingGST;
        lineItem.Charge_Type__c = onceOffChargesAndCredit.chargeType;
        lineItem.Line_Item_Identifier__c = lineItem.Charge_Type__c + lineItem.Charge_Identifier__c + lineItem.Invoice_Transaction_ID__c;
        //20.13:Osaka: START of EDGE-181508:fixing QA2 defect 
        lineItem.Drill_Down_Endpoint__c = onceOffChargesAndCredit.drillDownEndpoint;
        lineItem.Charge_Id__c = (onceOffChargesAndCredit.drillDownInputAttribute != null) ? String.valueOf(onceOffChargesAndCredit.drillDownInputAttribute.chargeId) : null;
         //END of EDGE-181508
        //Start of EDGE:164871: mapping de-aggregated quantity at the invoice line item.  
        lineItem.Quantity__c = invoiceLineAttribute.quantity;
    //End of EDGE:164871  
        //End of : EDGE-115138
     //Start of EDGE:164871 capturing isDrillable from Discounts Attributes to enable for Discount callout at ILI
        if(onceOffChargesAndCredit.discounts != null){
            for(InvoiceResponseDTO.Discounts discILI : onceOffChargesAndCredit.discounts ){
            lineItem.Is_Discount_Drillable__c = discILI.isDrillable;
          }
        }
        //End of EDGE:164871    
    }
    
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: setUsageDetails
    Description: Refactored Method - Repetitive code moved to this new method
    Author:Ramya G
    --------------------------------------------------------*/
    
     public static void setUsageDetails(Invoice_Line_Item__c lineItem,InvoiceResponseDTO.UsageSummaryCharges usageSummaryCharge, InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute) {
         //Start of : EDGE-130452
         lineItem.Service_Type__c=usageSummaryCharge.usageTypeName;
         //End of : EDGE-130452
         lineItem.Excluding_Cost__c = usageSummaryCharge.excludingGstCost;
         lineItem.Including_Cost__c = usageSummaryCharge.includingGstCost;
         lineItem.Is_Aggregated__c = usageSummaryCharge.isAggregated;
         lineItem.Is_Taxable__c = usageSummaryCharge.isTaxable;
         //Start of : EDGE-130452
         //lineItem.Quantity__c = usageSummaryCharge.units;
         //End of : EDGE-130452
         lineItem.Is_Queryable__c = usageSummaryCharge.isQueryable;
         lineItem.Charge_Identifier__c = (usageSummaryCharge.chargeIdentifier != null) ? usageSummaryCharge.chargeIdentifier : null;
         lineItem.Charge_Type__c = String.valueOf(usageSummaryCharge.chargeType);
         
         lineItem.Usage_Type_Code__c = usageSummaryCharge.drillDownInputAttribute.usageTypeCode;
         lineItem.Tax_Inclusive__c = usageSummaryCharge.drillDownInputAttribute.taxInclusive;
         lineItem.Tax_Rate__c = usageSummaryCharge.drillDownInputAttribute.taxRate;
         //EDGE-120657 Start addition of drillDownEndpoint attribute
         lineItem.Drill_Down_Endpoint__c = usageSummaryCharge.drillDownEndpoint;
         lineItem.Charge_Id__c = (usageSummaryCharge.drillDownInputAttribute != null) ? String.valueOf(usageSummaryCharge.drillDownInputAttribute.chargeId) : null;
         //EDGE-120657 End
         List<long> planInstanceList = new List<long>();
         if( usageSummaryCharge.drillDownInputAttribute.planInstanceDetailsList != null){                    
             planInstanceList.addAll(usageSummaryCharge.drillDownInputAttribute.planInstanceDetailsList);
         }
         lineItem.Plan_Instance_Details_List__c = (usageSummaryCharge.drillDownInputAttribute.planInstanceDetailsList != null) ? String.ValueOf(planInstanceList).replaceAll('[\\s+]', '').replace('(','').replace(')',''): null;
         if (usageSummaryCharge.invoiceLineAttributes != null) {
             //Capturing  Invoice_Line_Number__c,Invoice_Transaction_ID__c,Charge_Excluding_GST__c,Charge_Including_GST__c at the time of creating record
             
             lineItem.Invoice_Line_Number__c = invoiceLineAttribute.invoiceLineNumber;
             lineItem.Invoice_Transaction_ID__c = invoiceLineAttribute.invoiceTransactionId;
             lineItem.Charge_Excluding_GST__c = invoiceLineAttribute.chargeExcludingGST;
             lineItem.Charge_Including_GST__c = invoiceLineAttribute.chargeIncludingGST;
             lineItem.Line_Item_Identifier__c = lineItem.Charge_Type__c + lineItem.Charge_Identifier__c + lineItem.Invoice_Transaction_ID__c;
             //End of EDGE-115138
             //Start of EDGE:164871 mapping de-aggregated quantity at the invoice line item.
             lineItem.Quantity__c = invoiceLineAttribute.quantity;
      //End of EDGE:164871  
          }
         
         //Start of EDGE:164871 capturing isDrillable from Discounts Attributes to enable for Discount callout at ILI
          if(usageSummaryCharge.discounts != null){
              for(InvoiceResponseDTO.Discounts discILI : usageSummaryCharge.discounts ){
                lineItem.Is_Discount_Drillable__c = discILI.isDrillable;
          }
      }
         //End of EDGE:164871    
      }

    
    
   /**
*  Refactoring the code as a part of EDGE-115138
*  @name              - updateCreditInvoiceLineItems
*  @param productMap  - List of Product Map
*  @return void       - 
*  @throws exception  - NA
*  @jira Story Ref    - Defect fix and refactoring
*  @createdBy         - Ramya G
*  @team              - OSAKA
*  @Description       - Return all offer based Invoice line item in the invoice api response. 
*                       EDGE-120657:Changed return type to list of Invoice line item and removed commit logic
**/
    public static void updateCreditInvoiceLineItems(Map<Integer,InvoiceCalloutHandler.CreditOffer> creditMap,String invoiceId,List<Invoice_Line_Item__c> lineItemList,String year) {
        
        if(!creditMap.isEmpty()) {
            for(Integer offerId : creditMap.keySet()){
                InvoiceCalloutHandler.CreditOffer creditOfferInstance= creditMap.get(offerId);
               InvoiceResponseDTO.ListOfChargesAndCredits credits = creditMap.get(offerId).creditOffer;
               InvoiceCalloutHandler.Offer offerInstance = creditMap.get(offerId).offer;
               if(credits != null){
                //START of EDGE-127660:Hackathon:Ramya
                    if(credits.planCharges != null){
                        getCreditPlanCharges(lineItemList,credits,offerInstance,invoiceId,year);                
                    }
                    
                    if (credits.onceOffChargesAndCredits != null) {
                        getCreditOnceOffCharges(lineItemList, credits,offerInstance, invoiceId);
                    }
            
                    if (credits != null && credits.UsageSummaryCharges != null) {
                        getCreditUsageSummaryCharges(lineItemList, credits,offerInstance, invoiceId);
                    }
                }
               //END of EDGE-127660:Hackathon
            }
        }
        //Start of EDGE-120657
        
        //End of EDGE-120657
    }

 /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: getCreditPlanCharges
    Description: Refactored Method to get plan charges
    Author:Ramya G
    --------------------------------------------------------*/
    public static void getCreditPlanCharges(List<Invoice_Line_Item__c>lineItemList,InvoiceResponseDTO.ListOfChargesAndCredits credits,InvoiceCalloutHandler.Offer offerInstance,String invoiceId,String year) {
        Invoice_Line_Item__c lineItem;
        List<string> dateStringSplit;
        String genericDate = null;
        for(InvoiceResponseDTO.PlanCharges planCharge: credits.planCharges){
                        //Start of EDGE-115138, Adding Invoice Line Attributes under plancharges and creating a Invoice Line Item Record
                    for (InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute: planCharge.invoiceLineAttributes) {
                        lineItem = new Invoice_Line_Item__c();
                        //START of EDGE-127660:Hackathon:Ramya
                        setOfferDetails(lineItem, offerInstance, invoiceId);
                        setPlanDetails(lineItem,planCharge,invoiceLineAttribute);
                        //END of EDGE-127660:Hackathon                            
                        

                        if(planCharge.startDate!=null){
                            dateStringSplit =  planCharge.startDate.split(' ');
                            genericDate =year+    '-'+getMonth(dateStringSplit[1])+'-'+       dateStringSplit[0];
                            lineItem.Start_Date__c = Date.valueOf(genericDate);
                            dateStringSplit.clear();
                        }
                        if(planCharge.endDate!=null){
                            dateStringSplit =  planCharge.endDate.split(' ');
                            genericDate=year+    '-'+getMonth(dateStringSplit[1])+'-'+       dateStringSplit[0];
                            lineItem.End_Date__c = Date.valueOf(genericDate);
                            dateStringSplit.clear();
                        }
                        if(lineItem!=null)
                            lineItemList.add(lineItem);
                    }
              }
    
    }
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: getCreditOnceOffCharges
    Description: Refactored Method to get once-off charges
    Author:Ramya G
    --------------------------------------------------------*/
    public static void getCreditOnceOffCharges(List<Invoice_Line_Item__c>lineItemList, InvoiceResponseDTO.ListOfChargesAndCredits credits,InvoiceCalloutHandler.Offer offerInstance, String invoiceId) {
        Invoice_Line_Item__c lineItem;        
         for (InvoiceResponseDTO.onceOffChargesAndCredits onceOffChargesAndCredit: credits.onceOffChargesAndCredits) {
                    if (onceOffChargesAndCredit.invoiceLineAttributes != null) {
                     //setOnesOffLineItem(InvoiceResponseDTO.onceOffChargesAndCredits onceOffChargesAndCredit,InvoiceCalloutHandler.Offer offerInstance, String invoiceId,String year
                        //Start of EDGE-115138, Adding Invoice Line Attributes under onceOffChargesAndCredits and creating a Invoice Line Item Record
                        for (InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute: onceOffChargesAndCredit.invoiceLineAttributes) {
                           
                            lineItem = new Invoice_Line_Item__c();
                            //START of EDGE-127660:Hackathon:Ramya
                            setOfferDetails(lineItem, offerInstance, invoiceId);
                            setOnceOffDetails(lineItem,onceOffChargesAndCredit, invoiceLineAttribute);
                            //END of EDGE-127660:Hackathon     
                            if(lineItem!=null)
                                lineItemList.add(lineItem);  
                        }
                    }  
                }

    }
    /*-------------------------------------------------------- 
    Story: EDGE-127660:Hackathon
    Method: getCreditUsageSummaryCharges
    Description: Refactored Method to get usage charges
    Author:Ramya G
    --------------------------------------------------------*/
    public static void getCreditUsageSummaryCharges(List<Invoice_Line_Item__c>lineItemList, InvoiceResponseDTO.ListOfChargesAndCredits credits,InvoiceCalloutHandler.Offer offerInstance, String invoiceId) {
        Invoice_Line_Item__c lineItem;        
        for (InvoiceResponseDTO.UsageSummaryCharges usageSummaryCharge: credits.UsageSummaryCharges) {
                   for (InvoiceResponseDTO.InvoiceLineAttributes invoiceLineAttribute: usageSummaryCharge.invoiceLineAttributes) {
                             lineItem = new Invoice_Line_Item__c();
                             //START of EDGE-127660:Hackathon:Ramya
                            setOfferDetails(lineItem, offerInstance, invoiceId);
                            setUsageDetails(lineItem,usageSummaryCharge, invoiceLineAttribute);
                            //END of EDGE-127660:Hackathon 
                            if(lineItem!=null)                           
                                lineItemList.add(lineItem);
                    }                    
                    
         }
    }
   
  /*-------------------------------------------------------- 
EDGE-120657
Method: updateAdjustmentLineItem
Description: Method to return the adjustment invoice line item list. Hackathon: Passing ILI list in input and changing return type to void.
Author:Mohammed Zeeshan
Updated by: Ramya G
--------------------------------------------------------*/
    public static void updateAdjustmentLineItem(InvoiceResponseDTO responseDto,String invoiceId, List<Invoice_Line_Item__c> lineItemList) {
        //List<Invoice_Line_Item__c>lineItemList = new List<Invoice_Line_Item__c>(); 
        Invoice_Line_Item__c lineItem;
        if(responseDto.adjustmentSummary!=null ){
        system.debug('--->Creating adjustment line item: '+responseDto.adjustmentSummary);
        for(InvoiceResponseDTO.Adjustments adjustment: responseDto.adjustmentSummary.adjustments){
            if( adjustment.invoiceLineAttributes !=null){
                
                for(InvoiceResponseDTO.invoiceLineAttributes InvoiceLineAttribute: adjustment.invoiceLineAttributes){
                    // START of Defect EDGE-133764 :Adjustment moved to inner loop to create one per ILI 
                lineItem = new Invoice_Line_Item__c();    
                lineItem.Invoice__c = invoiceId;
                lineItem.Total_Adjustments_Cost__c =  responseDto.adjustmentSummary.totalAdjustmentsCost;
                lineItem.Total_GST_Included_In_Adjustments__c=  responseDto.adjustmentSummary.totalGSTIncludedInAdjustments;
                lineItem.Adjustment_Description__c = adjustment.adjustmentDescription;
                lineItem.Adjustment_Date__c = adjustment.adjustmentDate;
                lineItem.Adjustments_Cost__c = adjustment.adjustmentsCost;
                lineItem.GST_Included_In_Adjustments__c = adjustment.gstIncludedInAdjustments;
                lineItem.Charge_Identifier__c = adjustment.chargeIdentifier;
                lineItem.Charge_Type__c = adjustment.chargeType;
                    // END of Defect EDGE-133764 
                    lineItem.Invoice_Transaction_ID__c = InvoiceLineAttribute.invoiceTransactionId;
                    lineItem.Line_Item_Identifier__c = lineItem.Charge_Type__c + lineItem.Charge_Identifier__c + lineItem.Invoice_Transaction_ID__c;    
                    lineItem.Charge_Excluding_GST__c = InvoiceLineAttribute.chargeExcludingGST;
                    lineItem.Charge_Including_GST__c = InvoiceLineAttribute.chargeIncludingGST;
                    lineItemList.add(lineItem);
                }
            }
          }    
        }      
            //EDGE-120657 End
    }
  
/*-----------------------------------------------------------
    EDGE-124066
    Method: fetchInvoiceNumber
    Description: Method to make callout to Invoice API using Billing Account Number to retrive last 13 invoices.
    Author:Pradeep
 --------------------------------------------------------------  */
 
 public static Map<String,String> getInvoiceNumbers(String billingAccNumber) {
        Logger2 logger = Logger2.getLogger(handlerInvoice);
        String reqBody;
        String correlationId = EDISSingleManager.getUID();
        Map<String,String> invoiceMap= new Map<String,String>();
        HttpResponse invResponse;
        try {
            String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            token = InvoiceCalloutHandler.setToken(handlerInvoice);
            Map < String, String > headerMap = new Map < String, String > {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + token,
                'correlationId' => correlationId
            };
            reqBody = 'customerAccountNumber=' + billingAccNumber;
            invResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerInvoice);
            system.debug('invResponse is::' + invResponse);

            if (invResponse != null) {
                String responseCode = String.valueOf(invResponse.getStatusCode());

                if (responseCode.startsWith('2')) {
                    invoiceMap.put(responseCode,invResponse.getBody());
                    logger.logMessages(reqBody, invResponse.getBody(), '', '', '', '', false, false, Integer.valueof(invResponse.getStatusCode()), null, null, null);
                   

                } else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                    invoiceMap.put(responseCode,invResponse.getBody());
                    logger.logMessages(reqBody, invResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(invResponse.getStatusCode()), null, null, null);
                    
                }
            }
            logger.exitLogger();
        } 
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return invoiceMap;
        
    }
    
    
    /*-------------------------------------------------------- 
EDGE-88307
Method: InvoiceCalloutHandler
Description: Method to get month number
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static Integer getMonth(String mon){
        Map < String, Integer > monthMp = new Map < String, Integer > {
            'Jan' => 1,
                'Feb'=> 2,
                'Mar'=>3,
                'Apr'=>4,
                'May'=>5,
                'Jun'=>6,
                'Jul'=>7,
                'Aug'=>8,
                'Sep'=>9,
                'Oct'=>10,
                'Nov'=>11,
                'Dec'=>12
                };
                    List<string> dateStringSplit;
        String str=null; 
        return monthMp.get(mon);
    }
/*-------------------------------------------------------- 
EDGE-212404
Method: informMStoEnrichQLI 
Description:For assisted channel flow, whenever a case is created with QLI or new QLI are added to an existing case, 
invoke a REST API call to Case Invoice MS to inform them to work on the case and get the necessary 
info from Invoice Manager and populate in Salesforce
--------------------------------------------------------*/
    public static String informMStoEnrichQLI(String caseID,String invoiceNumber)
    {
        try{ 
            String handlerName = 'InitiateQLIEnrichment';
            DateTime startTime = DateTime.now();
            Map<String, String> headerMap=new Map<String, String>();
            headerMap=InvoiceCalloutHandler.getOauthDetails(handlerName);
            Map<String, String> pathMap = new Map<String, String>{'case-invoice-details'=> caseID+'?invoiceNumber='+invoiceNumber};
            String requestString='case-invoice-details/'+caseID+'?invoiceNumber='+invoiceNumber;
            //HttpResponse calloutResponse = IntegrationRecordHandlerUtil.calloutSync('',IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName,pathMap);  
			HttpResponse calloutResponse = IntegrationRecordHandlerUtil.calloutSync(requestString,IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName);
            String statusCode='';string correlationId='';
            if(calloutResponse!=null)
            {
                statusCode = String.valueOf(calloutResponse.getStatusCode());
                correlationId=headerMap!=null && headerMap.containskey('correlationId')?headerMap.get('correlationId'):'';
                //InvoiceCalloutHandler.createLogger(handlerName,requestString,calloutResponse,correlationId,startTime);
            }
            return statusCode.equals('202')?'Success':'Failure';
        }
        catch(Exception e)
        {
            InvoiceCalloutHandler.createExceptionLogger(handlerName, e);
            throw e;
        }
    }
	public static void informMStoEnrichQLIBulk(Map<String,Set<String>> caseToInvoicenumListMap)
    {
        try{ 
            String handlerName = InvoicecalloutHandler.QLIENRICHHANDLER;
			Logger2 log = Logger2.getLogger(handlerName);
			for(String caseId:caseToInvoicenumListMap.keyset()){
				for(String invoiceNumber:caseToInvoicenumListMap.get(caseId)){
					DateTime startTime = DateTime.now();
					Map<String, String> headerMap=new Map<String, String>();
					headerMap=InvoiceCalloutHandler.getOauthDetails(handlerName);
					Map<String, String> pathMap = new Map<String, String>{'case-invoice-details'=> caseID+'?invoiceNumber='+invoiceNumber};
					String requestString='case-invoice-details/'+caseID+'?invoiceNumber='+invoiceNumber; 
					HttpResponse calloutResponse = IntegrationRecordHandlerUtil.calloutSync(requestString,IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName);
					String statusCode='';string correlationId='';
					DateTime endTime = DateTime.now();
					Long requestTime = log.getRequestTimeDifference(startTime, endTime);
					if(calloutResponse!=null)
					{
						statusCode = String.valueOf(calloutResponse.getStatusCode());
						correlationId=headerMap!=null && headerMap.containskey('correlationId')?headerMap.get('correlationId'):'';
						log.logMessages(requestString, calloutResponse.getBody(), '', '', '',
					'', String.valueOf(calloutResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
					}
				}
			}
			log.exitLogger();			
		}
        catch(Exception e)
        {
            InvoiceCalloutHandler.createExceptionLogger(handlerName, e);
            throw e;
        }
    }
    private static Map<String, String> getOauthDetails(String handlerName){
        String oAuthToken = AuthenticationManager.getOauthToken(handlerName);
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        String sourceSystemId='';
        //Digi-23315 shubhi/vamsi 15/09/2021 start----------
        if(!Test.isRunningTest()){
            EnvironmentVariable__c sourceSystem = EnvironmentVariable__c.getValues('CaseInvoiceSourceSystem');
            sourceSystemId = sourceSystem.Value__c;
        }else{
            sourceSystemId='SFDC_U2FsZXNmb3JjZVVzZXI6Tm9ucHJvZHBhc3N3b3Jk' ;
        }//Digi-23315 end----------
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + oAuthToken, 'correlationId' => correlationId, 'Source-System' =>sourceSystemId };
        headerMap.put('X-HTTP-Method-Override', 'PATCH');
        return headerMap;
    }
    private static void createLogger(String handlerName,String requestBody,HttpResponse calloutResponse,String correlationId,DateTime startTime){
        Logger2 log = Logger2.getLogger(handlerName);
        DateTime endTime = DateTime.now();
        Long requestTime = log.getRequestTimeDifference(startTime, endTime);
        log.logMessages(requestBody, calloutResponse.getBody(), '', '', '', 
        '', String.valueOf(calloutResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
        log.exitLogger();
    }
    private static void createExceptionLogger(String handlerName,Exception e){
        Logger2 logger = Logger2.getlogger('InvoiceCalloutHandler');
        logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in '+handlerName,e.getLineNumber() + ' ' + e.getMessage(), false, false);
        logger.exitLogger();
    }
}