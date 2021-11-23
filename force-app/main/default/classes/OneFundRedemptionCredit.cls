/********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : Approved Redemption Details needs to be sent to ARIA
Author      : Hari
Date        :10/02/2020
*******************************************************************/

public without sharing class OneFundRedemptionCredit {
 /********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : Method to Submmit Redemption Details
Author      : Hari
Date        :10/02/2020
*******************************************************************/
@InvocableMethod(label='OneFundRedemptionCredit' description='Submmit OneFundRedemption Credit')
     public static void submmitOneFundRedemptionCredit(list<FlowInputs> request) {
        FlowInputs ips=null;
        for(FlowInputs inp :request){
            ips=inp;
        }
        case c2 =[Select id, Billing_Account__r.Billing_Account_Number__c,CaseNumber from case where id=:ips.caseid];
        String customerAccountNumber=c2.Billing_Account__r.Billing_Account_Number__c;
        OneFundRedemptioncreditRequestDTO OCR_DO= generatePayLoadforRedemptionCredit(request);
        OCR_DO.caseReferenceNumber=c2.CaseNumber;
        String reqBody = JSON.serialize(OCR_DO,true);
        calloutRedemptionCredit(reqBody,customerAccountNumber,ips.creditAndAdjustmentid,ips.caseid);
    }
 /********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : method to make callout 
Author      : Hari
Date        :10/02/2020
*******************************************************************/   
    @future(callout=true)
    public static Void calloutRedemptionCredit(String reqParam,String ban,Id creditId,Id caseId){
        System.debug('reqParam'+reqParam);
        list<OneFund_Transactions__c> OFTs =[Select id,Start_Date__c,Transaction_Status__c from OneFund_Transactions__c where Case_Number__c=:caseId];
        Credits_and_Adjustments__c creditAndAdjustment=new Credits_and_Adjustments__c();
        creditAndAdjustment =[Select id, Redemption_Status__c,Failure_Reason__c,Submitted__c, Date_when_credit_was_given_to_customer__c FROM Credits_and_Adjustments__c WHERE id =:creditId ];
        case OFCase=new case();
        OFCase =[Select id, status FROM Case where id =:caseId ];
        System.debug('creditAndAdjustment'+creditAndAdjustment);
        System.debug('OFCase'+OFCase);
        ResponseWrapper  responseObj;
        String message;
        String handler ='OneFundRedemptionCredit';
       String token= AuthenticationManager.getOauthToken(handler);
        // String token = 'MLhlJPHAFdP38Z1CsAnEI1EDts6h';
        String correlationId=IntegrationRecordHandlerUtil.getUUID();
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Authorization'=> 'Bearer ' + token,'Source-System'=>'SFDC'};
            HTTPResponse    response = ApplyOnceOffCreditCallout(ban,reqParam, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handler,correlationId,null);          
        if(response !=null){
            responseObj= (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
            if(response.getStatusCode()==201 || response.getStatus()=='Success'){
                creditAndAdjustment.Submitted__c=true;
				creditAndAdjustment.Date_when_credit_was_given_to_customer__c = System.Today();
                creditAndAdjustment.Redemption_Status__c = 'Posted';
                OFCase.Status='Closed';
                message=Label.BDS_Response_Success_Message;
                for(OneFund_Transactions__c SOF:OFTs){
                    SOF.Transaction_Status__c='Active';
                    SOF.Start_Date__c = Date.Today();//DIGI-31078
                }
            }
            else{
                creditAndAdjustment.Failure_Reason__c=responseObj.errors[0].message;
                message=Label.BDS_Response_Error_Message;
                creditAndAdjustment.Redemption_Status__c = 'Submission Failed';
                OFCase.Status='Submission Failed';
                for(OneFund_Transactions__c SOF:OFTs){
                    SOF.Transaction_Status__c='Declined';                                        
                }
            }
        }
        update creditAndAdjustment;
        update OFCase;
        System.debug('OFTs==================>'+OFTs);
        if(OFTs.isempty() == false){
            update OFTs;
        }       
    }          
/********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : method to make generate request payload 
Author      : Hari
Date        :10/02/2020
*******************************************************************/   
    @AuraEnabled
    public static OneFundRedemptioncreditRequestDTO generatePayLoadforRedemptionCredit(list<FlowInputs> request){
        OneFundRedemptioncreditRequestDTO ERM_DTO = null;
        OneFundRedemptioncreditRequestDTO ERM_DTO2 = null;
        OneFundRedemptioncreditRequestDTO.AdjustmentTarget adjustment=new OneFundRedemptioncreditRequestDTO.AdjustmentTarget();
        FlowInputs FIps=null;        
        for(FlowInputs finp :request){
            FIps=finp;
        }
        list<id> iliids =new list<id>();
        for(Queried_Line_Item__c qlilist: FIps.QLI_list){ 
            iliids.add(qlilist.Invoice_Line_Item__c);
        }       
        list<Invoice_Line_Item__c> ILIList =[Select id,Invoice_Transaction_ID__c,Invoice_Line_Number__c,Charge_Type__c from Invoice_Line_Item__c where  id in:iliids ];

        Non_Marketable_Product__c nonMarkatableProdRec=[SELECT Name,billingSpecId__c,currency__c,externalId__c,specId__c,productDescription__c,taxTreatment__c
        		FROM Non_Marketable_Product__c WHERE Name =:Label.RedemptionChargeType];
        if(!FIps.QLI_list.isEmpty() && FIps.QLI_list.size() > 0 && FIps!=null){
            ERM_DTO = new OneFundRedemptioncreditRequestDTO();
            ERM_DTO.instanceId = FIps.instanceId;
            ERM_DTO.adjustmentType = FIps.adjustmentType;
            ERM_DTO.ariaInvoiceNumber = Integer.valueOf(FIps.ariaInvoiceNumber);
            ERM_DTO.comments = FIps.comments;
            ERM_DTO.currencyCode = FIps.currencyCode;
           // ERM_DTO.caseReferenceNumber = FIps.caseReferenceNumber;
            ERM_DTO.productId = FIps.productId;
            //EDGE-157138:Included externalRateId and chargeId in the payload
            if(nonMarkatableProdRec !=Null){
           	ERM_DTO.chargeId = nonMarkatableProdRec.billingSpecId__c;
            ERM_DTO.externalRateId = nonMarkatableProdRec.externalId__c;
            }
            List<OneFundRedemptioncreditRequestDTO.invoiceItem> invoiceItemDetailsList = new List<OneFundRedemptioncreditRequestDTO.invoiceItem>();
            for(Queried_Line_Item__c eqli2:FIps.QLI_list)
            {
                OneFundRedemptioncreditRequestDTO.invoiceItem invoiceItems = new OneFundRedemptioncreditRequestDTO.invoiceItem();
                invoiceItems.lineItemReasonCode =Integer.valueOf(FIps.lineItemReasonCode);
                invoiceItems.creditAmount=eqli2.Redemption_Amount__c;
                invoiceItems.invoiceLineNumber=Integer.valueOf(eqli2.Invoice_Line_Number__c);
                for(Invoice_Line_Item__c EINLI :ILIList)
                {
                    if(EINLI.Invoice_Line_Number__c == eqli2.Invoice_Line_Number__c)
                    {
                        invoiceItems.chargeType=EINLI.Charge_Type__c;
                        invoiceItems.invoiceTransactionId=Integer.valueOf(EINLI.Invoice_Transaction_ID__c);
                    }                                       
                }
                invoiceItemDetailsList.add(invoiceItems);                
            }
            System.debug('invoiceItemDetailsList :'+invoiceItemDetailsList);           
            if(invoiceItemDetailsList!=null && invoiceItemDetailsList.size()>0){
                adjustment.invoiceItem=invoiceItemDetailsList;
                ERM_DTO.AdjustmentTarget=adjustment;
            }
        }
        return ERM_DTO;                      
        // System.debug('ERM_DTO in generatePayLoad');
    }
    /********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : method to make ApplyOnceOffCreditCallout 
Author      : Hari
Date        :10/02/2020
*******************************************************************/      
    public static HTTPResponse ApplyOnceOffCreditCallout (String BAN_number, String reqBody, String method, Map<String,String> headerMap, String handlerName, String correlationId, Map<String,String> params) {
        String errorMessage;
        String endPoint;
        Logger2 logger = Logger2.getLogger(handlerName +':'+correlationId);
        HTTPResponse res;         
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c) {
                endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
            }
            else {
                endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
            }
        }
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if(String.isBlank(endPoint)) {
            System.debug('Cannot make a callout without an Endpoint');            
            return null;
        }else
        {
            endPoint=  endPoint.replace('{BAN}', BAN_number);
        }
        integer count=0;
        if(params!= null && params.size()>0){
            for(string p: params.keyset()){
                if(count==0)
                    endPoint= endPoint +'?'+p+'='+params.get(p);
                else
                    endPoint= endPoint +'&'+p+'='+params.get(p);
                count++;
            }
        }                
        HttpRequest req = new HttpRequest();  
        try {
            req.setEndpoint(endPoint);
            if(reqBody!= null){
                req.setBody(reqBody);
            }           
            if(!test.isRunningTest()){
                if(handleSettingRecord.Enable_MASSL__c) {
                    System.debug('MASSL is enabled for interface');
                    String certificateName = null;
                    certificateName = EnvironmentVariable.get('massl_certificate_name');
                    System.debug('Setting ' + certificateName + ' certificate for http call');
                    req.setClientCertificateName(certificateName);
                }
            }            
            req.setMethod(method);
            req.setTimeout(timeout);            
            if(headerMap != null) {
                for(String hdName : headerMap.keySet()) {
                    req.setHeader(hdName, headerMap.get(hdName));   
                }
            }          
            system.debug('request data==>'+req);
            Http http = new Http();
            res = http.send(req);
            // Stored enpoint and request body both in Logs as both contains essential request information.
            logger.logMessages(endpoint +' : '+ reqBody, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);           
            system.debug(res.getBody());
        }
        catch(exception ex)
        { 
            system.debug(ex.getMessage());
            logger.logMessages(endpoint +' : '+ reqBody, ex.getMessage(), ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        logger.exitLogger();
        return res;
    }    
    /********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : Class for Callout responce 
Author      : Hari
Date        :10/02/2020
******************************************************************/ 
    public class ResponseWrapper{
        @AuraEnabled  public String correlationId;
        @AuraEnabled  public Integer code;
        @AuraEnabled  public Integer status;
        @AuraEnabled  public String  message;
        @AuraEnabled  public List<errors> errors;
    }
    
    public Class Errors{
        @AuraEnabled  public String code;
        @AuraEnabled  public String field;
        @AuraEnabled  public String message;
        
    }
    
    /********************************************************************
EDGE        : EDGE-116382
Controller  : OneFundRedemptionCredit
Description : Wrapper Class to store flow output 
Author      : Hari
Date        :10/02/2020
*******************************************************************/ 
    public class FlowInputs{                        
        @InvocableVariable
        public String instanceId;        
        @InvocableVariable
        public String adjustmentType;        
        @InvocableVariable
        public string ariaInvoiceNumber;        
        @InvocableVariable
        public String comments;        
        @InvocableVariable
        public String currencyCode;        
        @InvocableVariable
        public String caseReferenceNumber;        
        @InvocableVariable
        public String productId;        
        @InvocableVariable
        public String lineItemReasonCode;        
        @InvocableVariable
        public id caseid;        
        @InvocableVariable
        public id creditAndAdjustmentid;       
        @InvocableVariable
        public list<Queried_Line_Item__c> QLI_list;      
    }    
}