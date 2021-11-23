/**
 * Class  Billing Account Validation Manager.
 */
public with sharing class BillingAccountManager {

    //@TODO
    //Will have to modify these variable values based on the interface with the Billing Gateway
	
	public static final String VALIDATE_EVENT = 'VALIDATEBILLINGACCOUNT';
    public static final String CREATE_EVENT = 'Create';
    public static final String UPDATE_EVENT = 'Update';
     
    /**
    * Will enable creating a new Billing charge on the billing system
    * @params list of subscription ids
    */
    public static void createBillingService(String handlerName, List<String> accountIds) {
        ManageBillingService.buildCalloutRequest(handlerName, accountIds, CREATE_EVENT);
    }
    
    /**
    * Will check if the passed billing account details are correct
    * @params CIDN and invoiceArrangID
    * @return BillingAccountValidateResponseDTO object
    */
    public static BillingAccountValidateResponseDTO validateBillingAccount(String financialCIDN, String invoiceArrangID) {
        
        return BillingAccountValidationService.validateBillingAccount(financialCIDN, invoiceArrangID, VALIDATE_EVENT);
        
    }
}