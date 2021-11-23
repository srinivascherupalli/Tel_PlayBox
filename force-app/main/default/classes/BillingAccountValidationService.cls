/**
 * Class for Billing Account Validate service.
 */
public with sharing class BillingAccountValidationService  {

    /**
     * Validate Billing Account
     *
     * @param      financialCIDN  The financial CIDN
     * @param      invoiceArrangementID the invoice Arrangement ID
     * @param      eventAction  The event action
     *
     * @return     BillingAccountValidateResponseDTO Class
     */
    public static BillingAccountValidateResponseDTO   validateBillingAccount(String financialCIDN, String invoiceArrangID, String eventAction) {


        BillingAccountValidateRequestDTO request = new BillingAccountValidateRequestDTO();
        request.Product = new BillingAccountValidateRequestDTO.Product();
        request.product.account  = new BillingAccountValidateRequestDTO.Account();
        request.product.owner =  new BillingAccountValidateRequestDTO.Owner();
        request.product.owner.party =  new BillingAccountValidateRequestDTO.Account();

        request.product.account.ID = invoiceArrangID;
        request.product.owner.party.ID = financialCIDN;

        String reqBody = System.JSON.serialize(request);
        return fetchResults( reqBody, eventAction);
    }



    /**
     * Fetches results.
     *
     * @param      validate_url  The validate url
     * @param      event       The event
     *
     * @return     BillingAccountValidateResponse
     */
    public static BillingAccountValidateResponseDTO fetchResults(String reqBody, String event) {

        BillingAccountValidateResponseDTO billAccValidateRes;
        try {
        	
        	//@TODO
    		//Will have to modify Token Endpoint values based on the interface with the Billing Gateway
    	
            String token = APIUtils.getToken(EnvironmentVariable.get('okapi_token_url'), event);

            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            HttpResponse adResponse = IntegrationRecordHandlerUtil.callout(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, BillingAccountValidationService.class.getName(), null, null);
            

            if (adResponse.getStatusCode() == 200) {

                System.debug('json Response Test ' + adResponse.getBody());
                billAccValidateRes = BillingAccountValidateResponseDTO.parse(adResponse.getBody());

            } else {
                Logger.getLogger(BillingAccountValidationService.class).debug('Callout not success ' + adResponse.getStatusCode());
                Logger.exitLogger();
            }
        } catch (Exception e) {

            Logger.getLogger(BillingAccountValidationService.class).debug(e);
            Logger.exitLogger();
        }
        return billAccValidateRes;
    }

}