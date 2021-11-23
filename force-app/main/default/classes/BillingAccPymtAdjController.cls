/*************************************************************************************************
EDGE - 162804
Name:BillingAccPymtAdjController
Description: Controller for component BillingAccountPaymentAndAdjustment 
Author: Ravi Shankar
Modified by:
***************************************************************************************************/
public class BillingAccPymtAdjController {
    
    @AuraEnabled
    public static String checkPRMActivePOR(String accountId) {
        String resultStr = 'isCRM';
        boolean isActPOR = false;
        try{
            if(FeatureManagement.checkPermission('Partner_User')){
                resultStr = 'isInactivePOR';
                list<Billing_Account__c> lstCustAcct = [SELECT Id, Account__c FROM Billing_Account__c WHERE Id= :accountId];                
				isActPOR = PRMPartnerPORCheck.checkActivePOR(lstCustAcct[0].Account__c);    
                if(isActPOR){
                    resultStr = 'isActivePOR';
                }
            }
		}
        catch(Exception e){
            system.debug('prmPartnerPORCheck'+e.getMessage());
        }
        return resultStr;
    }
}