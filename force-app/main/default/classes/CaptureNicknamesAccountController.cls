/******************************************************************************************************************************
Class Name : CaptureNicknamesAccountController
Test Class : CaptureNicknamesAccountControllerTest
===============================================================================================================================
Sr.No.  Developer                   Date         Sprint                   Story Description                
1.      Adityen Krishnan            20/09/2021   DIGI-8027(New Class)     Capture Nickname in order journey
******************************************************************************************************************************/


public with sharing class CaptureNicknamesAccountController {

    /*  
    * Method Name      : getSubscriptionsRecords 
    * Input Parameter  : String Account Id
    * Return Parameter : List<SubscriptionData>
    * Description      : will return all the Subscriptions against the input order to LWC Comp  
    * Owner            : Adityen Krishnan
    * Jira             : DIGI-8027
    */
    @AuraEnabled (cacheable=true)
    public static List<csord__Subscription__c> getSubscriptionsRecords(String accountId){

        List<String> prodSpecsList = (System.Label.ProductsToAllowNickname).split(',');
        System.debug('prodSpecList <><>><><>'+prodSpecsList);
        List<csord__Subscription__c> subcriptionList = [SELECT Id,Name,csordtelcoa__Subscription_Number__c,serviceMSISDN__c,csord__Order__r.Name,csord__Status__c,
                                                        Billing_Account__r.Billing_Account_Number__c,Nickname__c,csord__Order__c,csord__Order__r.csord__Order_Number__c,
                                                        csordtelcoa__Product_Configuration__c, csord__Account__c,customerFacingServiceId__c,Billing_Account__r.Name,
                                                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                        csordtelcoa__Replacement_Subscription__c,csordtelcoa__Replaced_Subscription__c ,cssdm__solution_association__r.Name
                                                        FROM csord__Subscription__c 
                                                        WHERE csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c IN :prodSpecsList 
                                                        AND csord__Account__c = :accountId AND csord__Status__c IN ('Active','Provisioned')];
        return subcriptionList;
    }

/* ===============================================================================================================================
Sr.No.  Developer                   Date         Sprint                   Story Description                
1.      Yogesh Chavan               24-09-2021         DIGI-17933    Capture Nickname uplode 
******************************************************************************************************************************/
    @AuraEnabled
    public static String uploadFile(String base64Data, String metaDataRecName){
        String result = '';
        //Start of DIGI-17933 to bulk update Nickname on Subscription.
        if(metaDataRecName == 'SubscriptionNicknameOrder'){
            result = CaptureNicknamesAccountControllerHelper.updateNickName(base64Data);
        }
        //End of DIGI-17933 to bulk update Nickname on Subscription.
        return result;
    }

    
}