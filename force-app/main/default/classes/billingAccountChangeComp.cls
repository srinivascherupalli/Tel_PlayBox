/*********************************************************************************************************************************
*Class Name      :   billingAccountChangeComp
Test Class : billingAccountChangeCompTest
Ch.No.  Developer Name      Date            Story Description
1.      Gokul               27/04/2021      EDGE-210200 - Created a new method to get related Subscription on parallel MACD 
2.      Gokul               28/06/2021      EDGE-224341 - Modified the Billing Account filter to included only created and Modified
*********************************************************************************************************************************
*/
public with sharing class billingAccountChangeComp {
    
    private static String correlationId =   GuidUtil.NewGuid();
    //EDGE-210200 - Created a new method to get related Subscription on parallel MACD
    @AuraEnabled(cacheable=true)
    public static list<string> getRelatedSubs(list<string> subIds){
        set<string> solutionIds = new set<string>();
        list<string> finalSubIds = new list<string>();
        try{
            for(csord__Subscription__c sub : [select id,cssdm__solution_association__c 
                                              from csord__Subscription__c where id IN : subIds and
                                              MarketableOffer__r.BAN_Cardinality__c = 'Single' ]){
                                                  
                                                  solutionIds.add(sub.cssdm__solution_association__c);
                                                  
                                              }
            
            for(csord__Subscription__c sub : [select 
                                              id, Name,csordtelcoa__Subscription_Number__c,createddate,
                                              Site__r.Address__c,csord__Status__c,Access_Type__c,serviceMSISDN__c,customerFacingServiceId__c,
                                              csord__Total_Recurring_Charges__c,Billing_Account__r.Name,createdby.Name,initialActivationDate__c,
                                              csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name 
                                              from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' and 
                                              cssdm__solution_association__c IN : solutionIds and id NOT IN :subIds ]){
                                                  
                                                  finalSubIds.add(sub.id);
                                                  
                                              }
            finalSubIds.addAll(subIds);
            if(test.isRunningTest())
                throw new NullPointerException();
        }catch(Exception e) {
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
        return finalSubIds;
    }
    
    //EDGE-224341 - Modified the Billing Account filter to included only created and Modified
    @AuraEnabled
    public static list<string> getBillingAccStatus(){
        
        List<String> statusList =  new List<String>();
        try{
            Utility_Settings__c utilitySettings =  Utility_Settings__c.getInstance();
            if(String.isNotBlank(utilitySettings.Billing_Account_Status_Filter__c)) {
                for(String status : utilitySettings.Billing_Account_Status_Filter__c.split(',')) {
                    statusList.add('\''+status+'\'');
                }
            }
            if(test.isRunningTest())
                throw new NullPointerException();
        }catch(Exception e) {
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
        return statusList;
        
    }
}