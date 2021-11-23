/*************************************************************************************************************************************************
* Name         :   subscriptionTableCompController  
* Description  :   Create a wrapper data of subs to show it in the Pagination table                    
* Test Class   :   subscriptionTableCompControllerTest

Sr.No.      Developer Name      Date            Story           Description
1.          Gokul               12/04/2021      EDGE-205598     Create a wrapper data of subs to show it in the Pagination table 
**************************************************************************************************************************************************/
public with sharing class subscriptionTableCompController {

    static String correlationId = GuidUtil.NewGuid();
	//EDGE-205598     This method returns the list a wrapper data of subs to show it in the Pagination table 
    @AuraEnabled(cacheable=true)
    public static list<SubWrapper> getSubscriptionData(list<string> subIds){
    	list<SubWrapper> subWrapList = new list<SubWrapper>();
        String dateFormatString                 =   'dd/MM/yyyy HH:mm:ss';
        try{
		Offer_Id__mdt offerIdMdt = Offer_Id__mdt.getInstance('Telstra_Collaboration');
            for(csord__Subscription__c sub : [select 
                 id, Name,csordtelcoa__Subscription_Number__c,createddate,
                 Site__r.Address__c,csord__Status__c,Access_Type__c,serviceMSISDN__c,customerFacingServiceId__c,MarketableOffer__r.Offer_ID__c,

             csord__Total_Recurring_Charges__c,Billing_Account__r.Name,createdby.Name,initialActivationDate__c,
                                          csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name 
             from csord__Subscription__c where id IN : subIds]){
        	
                 SubWrapper sw = new SubWrapper();
                 sw.SubscriptionID = sub.id;
                 sw.subscriptionName = sub.Name;
                 sw.subNameLink = '/'+sub.Id;
                 sw.subscriptionNumber = sub.csordtelcoa__Subscription_Number__c;
                 sw.createdBy = sub.createdby.Name;
                 sw.siteAddress = sub.Site__r.Address__c;
                 sw.status = sub.csord__Status__c;
                 sw.accessType = sub.Access_Type__c;

                     sw.ServiceId = (sub.MarketableOffer__r.Offer_ID__c ==  offerIdMdt.MasterLabel) ? sub.customerFacingServiceId__c : sub.serviceMSISDN__c;
                     sw.totalRCVal = sub.csord__Total_Recurring_Charges__c;
                     sw.billingAccount = sub.Billing_Account__r.Name;
                     sw.createdDateVal = sub.CreatedDate;

                 sw.firstActivationDate = string.valueof(sub.initialActivationDate__c) ;
                 sw.productDefinitionName = sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name;
                 subWrapList.add(sw); 
        }
     return subWrapList;   

        }catch(Exception e) {
            GenericUtilityClass.logException('subscriptionTableCompController','getSubscriptionData','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during getting the list of subscriptions',C2O_ExceptionHandler.Capability.ORD);
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }

    }
}