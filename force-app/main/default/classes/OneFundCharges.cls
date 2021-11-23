/*-------------------------------------------------------- 
EDGE-123565
Class: OneFundCharges
Description: Created for posting OneFund charges to BDS
Author:Tejes
--------------------------------------------------------*/

public with sharing class OneFundCharges {
	public static final String handlerName = 'OneFundChargesHandler';
	public static final String token;
    public static HttpResponse response;

	/*-------------------------------------------------------- 
    EDGE-123565
    Method: postOnefundCharges
    Description: Invoked from OneFund Charges Approver Process builder to post OneFund Charges
    Author:Tejes
    --------------------------------------------------------*/
	
    @InvocableMethod 
    public static void postOnefundCharges(List<Credits_and_Adjustments__c> creditRecList){
        Map<Id,String> creditBillingMap = new Map<Id,String>();
         Map<String,Non_Marketable_Product__c> mapOfNonMarkatableProd = new Map<String,Non_Marketable_Product__c>();
		Set<Id> setOfCreditIds=new Set<Id>();
        if(creditRecList.size()>0){
            for(Credits_and_Adjustments__c rec:creditRecList){
                setOfCreditIds.add(rec.Id);
            }
        }
        List<Credits_and_Adjustments__c> billingNumList=[select Id,Billing_Account_Number_BAN__r.Billing_Account_Number__c ,Charge_Type__c
                                                         from Credits_and_Adjustments__c where Id IN: setOfCreditIds];
       
	   Set<String> setOfChargeType=new Set<String>();
        for(Credits_and_Adjustments__c credit:billingNumList){
            creditBillingMap.put(credit.id,credit.Billing_Account_Number_BAN__r.Billing_Account_Number__c);
			 setOfChargeType.add(credit.Charge_Type__c);
        }
        //EDGE-157138:Retrieving the deatails from non markatable products table based on credit charge type
         List<Non_Marketable_Product__c> listOfNonMarkatableProd= [SELECT Name,billingSpecId__c,currency__c,externalId__c,specId__c,productDescription__c,taxTreatment__c
        		FROM Non_Marketable_Product__c WHERE Name IN: setOfChargeType];
        for(Non_Marketable_Product__c NMP :listOfNonMarkatableProd){
            mapOfNonMarkatableProd.put(NMP.Name,NMP);
        }
        Integer creditListSize=(creditRecList.size()>=100)?100:creditRecList.size();
        for(integer i=0;i<creditListSize;i++){
            String correlationId = EDISSingleManager.getUID();
            String billingAccountNumber = creditBillingMap.get(creditRecList[i].Id);
            Id creditId=creditRecList[i].Id;
            Id caseId=creditRecList[i].Case_Number__c;
            Non_Marketable_Product__c recordOfProduct=mapOfNonMarkatableProd.get(creditRecList[i].Charge_Type__c);
             system.debug('recordOfProduct: '+recordOfProduct);
            String request=createChargesPayload(creditRecList[i],recordOfProduct,correlationId,billingAccountNumber);
            system.debug('Request Body: '+request);
            calloutCharges(request,handlerName,correlationId,creditId,caseId);                        
        }       
    }
    
    
    
    /*-------------------------------------------------------- 
    EDGE-123565,EDGE-157138
    Method: createChargesPayload
    Description: Method to create payload for OneFund Charges,Modified method
    Author:Tejes
    --------------------------------------------------------*/

	public static String createChargesPayload(Credits_and_Adjustments__c creditRecord,Non_Marketable_Product__c NonMarkatableProduct,String correlationId, String billingAccountNumber){
        OneFundChargesRequestDTO chargesDTO = new OneFundChargesRequestDTO();
        OneFundChargesRequestDTO.ChargeTarget oneFundTarget=new OneFundChargesRequestDTO.ChargeTarget();
        oneFundTarget.billingAccountNumber=Long.valueOf(billingAccountNumber);
       // oneFundTarget.subscriptionId='SN';
        chargesDTO.ChargeTarget=oneFundTarget;
        chargesDTO.instanceId = correlationId;
        chargesDTO.unitPrice = creditRecord.Charge_Amount__c;
        String effectiveDate=JSON.serialize(Datetime.now());
        chargesDTO.effectiveDate=effectiveDate.replaceAll('"', '');
        //EDGE-157138:Removed Harded coded values and fetched deatils from non-markatable products
        if(NonMarkatableProduct !=Null){
        chargesDTO.productId=NonMarkatableProduct.specId__c;
        chargesDTO.units=1;
        chargesDTO.currencyCode=NonMarkatableProduct.currency__c;
        chargesDTO.billingSpecId=Label.BillingSpecId;
        chargesDTO.taxTreatment=NonMarkatableProduct.taxTreatment__c;
        chargesDTO.description = NonMarkatableProduct.productDescription__c;
		chargesDTO.chargeId = NonMarkatableProduct.billingSpecId__c;
		chargesDTO.externalRateId = NonMarkatableProduct.externalId__c;
        }
       
        
        string reqBody= JSON.serialize(chargesDTO,true);
        return reqBody;
        
	}
        
    
    /*-------------------------------------------------------- 
    EDGE-123565
    Method: calloutCharges
    Description: Method to call API for posting OneFund Charges
    Author:Tejes
    --------------------------------------------------------*/
    @future(callout=true)
    public static Void calloutCharges(String reqBody,String handlerName,String correlationId,Id creditId,Id caseId){
        Logger2 logger = Logger2.getLogger(handlerName);
        try{
        string token = AuthenticationManager.getOauthToken(handlerName);
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id' => correlationId,'Source-System' => 'SFDC','Authorization'=> 'Bearer ' + token};
        DateTime startTime = DateTime.now();

        response=IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
    	DateTime endTime = DateTime.now();
        System.debug('Response: '+response); 
        Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
        String responseCode = String.valueOf(response.getStatusCode());
        if (responseCode.startsWith('2')){
        logger.logMessages(reqBody, response.getBody(), '', '', '','', String.valueOf(response.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);
        }
       else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
       logger.logMessages(reqBody, response.getBody(), '', '', '','', String.valueOf(response.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);

       }
        
        logger.exitLogger();}
    	catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            system.debug('Excepetion in rejection'+e.getStackTraceString());
           
            logger.exitLogger();
        }
       	checkResponseStatus(response,creditId,caseId,correlationId);
    }
    
    /*-------------------------------------------------------- 
    EDGE-123565
    Method: checkResponseStatus
    Description: Method to check HTTP response status
    Author:Tejes
    --------------------------------------------------------*/
    public static Void checkResponseStatus(HttpResponse res,Id creditId,Id caseId,String correlationId){
        String caseStatus;
        String caseDescription;
        String chargeStatus;
        if(res != null){    
                if(res.getStatusCode()==201){
                    chargeStatus='Posted';
                    caseStatus='Closed';
                    caseDescription='Successfully Posted to Billing';
                }
                else{
                    chargeStatus='Submission Failed';
                    caseStatus='Submission Failed';
                    caseDescription='Submission Failed for Billing';
                }                
                updateCaseRecord(caseId,caseStatus,caseDescription);
                updateCreditRecord(creditId,chargeStatus,correlationId);
         }
    }
    
    /*-------------------------------------------------------- 
    EDGE-123565
    Method: updateCreditRecord
    Description: Method to update Credit and Adjustment Record.
    Author:Tejes
    --------------------------------------------------------*/    
    
    public static Void updateCreditRecord(Id creditId,String chargeStatus,String correlationId){
        Credits_and_Adjustments__c creditRec = new Credits_and_Adjustments__c();
        creditRec.Id = creditId;
        creditRec.Charge_Status__c = chargeStatus;
        creditRec.Corelation_ID__c = correlationId;
        update creditRec;
    }

    
    
    /*-------------------------------------------------------- 
    EDGE-123565
    Method: updateCaseRecord
    Description: Method to update related Case status and description.
    Author:Tejes
    --------------------------------------------------------*/    
    
    public static Void updateCaseRecord(Id caseRecId,String caseStatus,String caseDescription){
        Case caseRec = new Case();
        caseRec.Id = caseRecId;
        caseRec.Status=caseStatus;
        caseRec.Description=caseDescription;
        update caseRec;
    }
}