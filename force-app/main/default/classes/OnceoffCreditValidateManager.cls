/*------------------------------------------------------------ 
Author: Mahima Gandhe 
Company: Telstra 
Description: Class to provide helper and business logic between OnceOffCreditBillingService and OneOffCreditController
Test Class: OnceoffCreditValidateManagerTest 
History :
<16-04-2019> <Mahima Gandhe> <EDGE-64232> 
------------------------------------------------------------*/
public with sharing class OnceoffCreditValidateManager {
    
    public Static string HNADLER_NAME='OnceOffCreditBillingHandler';
    public Static string HANDLER_NAME='OneFundChargesHandler';
    public static string ADJUSTMENT_TYPE='Once-off';
    public Static integer GOODWILL_CREDIT= 2001;
    public Static integer TELSTRA_ISSUE= 2002;
    public Static integer INSOLVENT_CREDIT= 2006;
    //DPG-3598 start.
    //public Static integer SERVICE_ESTABLISHMENT= Integer.valueof(Label.Service_Establishment_Fee_Code);
    ////DPG-3598 end.
    

    /*------------------------------------------------------------ 
Metohd: getRequestData
Description: Creates the api callout to the Service class. 
Inputs: Credits_and_Adjustments__c  object record
Returns: Map of response from API call
History 
<16-04-2019> <Mahima Gandhe>
------------------------------------------------------------*/
    public static Map<string, string> ApplyOnceOffCredit(Credits_and_Adjustments__c credObj,String caseNumber) { 
        
        string BAN='';
        Map<string, string> responseMap= new Map<string, string>();
        List<Billing_Account__c> banObj = [select Billing_Account_Number__c from Billing_Account__c where id=: credObj.Billing_Account_Number_BAN__c limit 1];
        if(banObj!= null && banObj.size()>0)
        {
            BAN= banObj[0].Billing_Account_Number__c;
            
        }
        system.debug('>>>>>>>>>>> credObj : '+credObj);
        OnceOffCreditBillingService.OnceOffCreditRequest reqData= getRequestData(credObj,caseNumber);
        system.debug('>>>>>>>>>>> credObj : '+reqData);
        OnceOffCreditBillingService.OnceOffCreditResponse response = 
            OnceOffCreditBillingService.ApplyOnceOffCreditService(reqData,HNADLER_NAME, BAN);
        if(response!= null)
        {
            if(response.errors!= null)    {
                for(OnceOffCreditBillingService.Error err:response.errors)   {
                    responseMap.put('Error',err.message);
                }
            }
            else    {
                responseMap.put('Success','');
            } 
        }
        return responseMap;
    }
/*------------------------------------------------------------ 
Metohd: ApplyOnceOffDebit
Description: Creates the api callout to the Service class. 
Inputs: Credits_and_Adjustments__c  object record 
Returns: Map of response
History 
<16-04-2019> <Mahima Gandhe>
<24-06-2020> <Pradeep<EDGE-149471>>
------------------------------------------------------------*/
    
    public static Map<string, string> ApplyOnceOffDebit(Credits_and_Adjustments__c credObj,String caseNumber) 
    {
        String BAN='';
        OnceOffCreditBillingService.OnceOffCreditResponse responseObj=new OnceOffCreditBillingService.OnceOffCreditResponse();
        Map<string, string> responseMap= new Map<string, string>();
        List<Billing_Account__c> banObj = [select Billing_Account_Number__c from Billing_Account__c where id=: credObj.Billing_Account_Number_BAN__c limit 1];
        if(banObj!= null && banObj.size()>0)         {
            BAN= banObj[0].Billing_Account_Number__c;   
        }
        String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
        token = OnceOffCreditBillingService.setToken(HANDLER_NAME);
        String correlationId=IntegrationRecordHandlerUtil.getUUID();
        String reqBody = createDebitPayload(BAN,caseNumber,credObj);
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Authorization'=> 'Bearer ' + token,'Source-System'=>'SFDC'};        
            
            HttpResponse response=OnceOffCreditBillingService.ApplyOnceOffCreditCallout(BAN,reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, HANDLER_NAME,correlationId, null);
        if(String.isNotBlank(response.getBody()))
        {
            responseObj= (OnceOffCreditBillingService.OnceOffCreditResponse)JSON.deserialize(response.getBody(), OnceOffCreditBillingService.OnceOffCreditResponse.class);
        }
        else{
            OnceOffCreditBillingService.Error err= new OnceOffCreditBillingService.Error();
            err.message='Some error occured.';
            err.code='';
            err.field='';
            responseObj.errors=new List<OnceOffCreditBillingService.Error>();
            responseObj.errors.add(err);
        }  
        
        if(responseObj!= null)     {
            if(responseObj.errors!= null)            {
                for(OnceOffCreditBillingService.Error err:responseObj.errors)             {
                    responseMap.put('Error',err.message);
                }
            }
            else       {
                responseMap.put('Success','');
            }
        }
        return responseMap;
    }
 
    /*------------------------------------------------------------ 
Metohd: getRequestData
Description: Creates the record of OnceOffCreditRequest  request DTO. 
Inputs: Credits_and_Adjustments__c  object record
Returns: OnceOffCreditRequest wrapper record
History 
<16-04-2019> <Mahima Gandhe>
<24-06-2020> <Pradeep<EDGE-149471>>
------------------------------------------------------------*/
    private static OnceOffCreditBillingService.OnceOffCreditRequest getRequestData(Credits_and_Adjustments__c credObj,String caseNumber)
    {
        OnceOffCreditBillingService.OnceOffCreditRequest requestData= new OnceOffCreditBillingService.OnceOffCreditRequest();
        List<Non_Marketable_Product__c> lstNMprod= [SELECT Name,externalId__c,billingSpecId__c,currency__c,productDescription__c,specId__c, taxTreatment__c 
                                                    FROM Non_Marketable_Product__c 
                                                    WHERE id=:credObj.Non_Marketable_Product__c LIMIT 1];
        if(lstNMprod!= null && lstNMprod.size()>0)
        {
            requestData.description     =lstNMprod[0].productDescription__c;
            requestData.productId       =lstNMprod[0].specId__c;
            requestData.currencyCode    =lstNMprod[0].currency__c;
            requestData.gstIndicator    =lstNMprod[0].taxTreatment__c;
			//EDGE-157139, EDGE-157137. Kalashree Borgaonkar. Added chargeId,externalRateId in request
			List<String> nonMarketableNameList = System.Label.NonMarketableProductList.split(',');
            if(nonMarketableNameList.contains(lstNMprod[0].name.toUpperCase())){
                requestData.chargeId    	=lstNMprod[0].billingSpecId__c;
				requestData.externalRateId  =lstNMprod[0].externalId__c;
            }
			
        }        
        requestData.instanceId      =credObj.id;
        requestData.adjustmentType  =ADJUSTMENT_TYPE;
        requestData.amount          =credObj.Credit_Change_Amount__c;
        requestData.caseReferenceNumber          =caseNumber;
        if(credObj.Reason_Code__c.contains('Goodwill Credit'))
        {
            requestData.reasonCode = GOODWILL_CREDIT;
        }
        else if(credObj.Reason_Code__c.contains('Telstra Issue'))
        {
            requestData.reasonCode = TELSTRA_ISSUE;
        }
        else if(credObj.Reason_Code__c.contains('Insolvent Credit'))
        {
            requestData.reasonCode = INSOLVENT_CREDIT;
        }
        //DPG-3598 start.
        /*else if(credObj.Reason_Code__c.contains('Service Establishment'))
        {
            requestData.reasonCode = SERVICE_ESTABLISHMENT;
        }
        */
        //DPG-3598 end.
        return requestData;
    }
/*------------------------------------------------------------ 
Metohd: createDebitPayload
Description: Creates the payload for debit transactions as per request DTO. 
Inputs: Credits_and_Adjustments__c  object record and billing account
Returns: String of request data
History 
<16-04-2019> <Mahima Gandhe>
<24-06-2020> <Pradeep<EDGE-149471>>
------------------------------------------------------------*/
    public static String createDebitPayload(String BAN,String caseNumber,Credits_and_Adjustments__c credObj)
    {
        String reqBody;
        OneFundChargesRequestDTO chargesDTO = new OneFundChargesRequestDTO();
        OneFundChargesRequestDTO.ChargeTarget oneFundTarget=new OneFundChargesRequestDTO.ChargeTarget();
        OneFundChargesRequestDTO.customerReferences customerRef=new OneFundChargesRequestDTO.customerReferences();
        List<OneFundChargesRequestDTO.customerReferences> customerRefList= new List<OneFundChargesRequestDTO.customerReferences>();
        List<Non_Marketable_Product__c> lstNMprod= [SELECT name,billingSpecId__c,externalId__c,currency__c,productDescription__c,specId__c, taxTreatment__c 
                                                    FROM Non_Marketable_Product__c 
                                                    WHERE id=:credObj.Non_Marketable_Product__c LIMIT 1];
        if(lstNMprod!= null && lstNMprod.size()>0)
        {
            chargesDTO.description     =lstNMprod[0].productDescription__c;
            chargesDTO.productId       =lstNMprod[0].specId__c;
            chargesDTO.currencyCode    =lstNMprod[0].currency__c;
            chargesDTO.taxTreatment    = lstNMprod[0].taxTreatment__c ;
            List<String> nonMarketableNameList = System.Label.NonMarketableProductList.split(',');
            //EDGE-157139, EDGE-157137. Kalashree Borgaonkar. Added chargeId,externalRateId in request
            if(nonMarketableNameList.contains(lstNMprod[0].name.toUpperCase().trim())){
                chargesDTO.chargeId    	=lstNMprod[0].billingSpecId__c;
				chargesDTO.externalRateId  =lstNMprod[0].externalId__c;
            }
        }        
        chargesDTO.instanceId      =credObj.id;
        String dateofDebit=String.valueOf(credObj.Date_when_credit_was_given_to_customer__c);
        String debitTime=String.valueof(datetime.now().time());
        chargesDTO.effectiveDate=dateofDebit+'T'+debitTime;
        chargesDTO.unitPrice = credObj.Credit_Change_Amount__c;
        chargesDTO.units=1;
        chargesDTO.billingSpecId='BSOTC001_CB';
        oneFundTarget.billingAccountNumber=Long.valueOf(BAN);
        chargesDTO.ChargeTarget=oneFundTarget;
        customerRef.name='caseReferenceId';
        customerRef.value=caseNumber;
        customerRefList.add(customerRef);
        chargesDTO.customerReferences=customerRefList;
        reqBody= JSON.serialize(chargesDTO,true);
        return reqBody;
    }
}