/*************************************************************************************************
Name : Model_Subscription
===============================================================================================================================
Sr.No.    Developer Name      Date            Story Description
1.        Shubhi              1-july-2020     EDGE-147513 (new)
2.        Aman Soni           28-Sept-2020    EDGE-173803
3.        Aman Soni           02-Mar-2021     EDGE-191138
4.        Aman Soni           19-Mar-2021     EDGE-199911
5.         shubhi             31/03/29021     EDGE-209293
===============================================================================================================================
***************************************************************************************************/
public with sharing class Model_Subscription {
    
    /*  
     * Method Name : getConfigMap
     * Input Parameter 1 : accountId
     * Return Parameter : returns Billiing acc map
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    public static Map<String,csord__Subscription__c> getSubscriptionsbasedonBillaccStatus(Set<String>solutionIdSet ,set<string> billingAccStatusSet){
        if(solutionIdSet !=null  && solutionIdSet.size()>0 && billingAccStatusSet !=null && billingAccStatusSet.size()>0){
            return new Map<String,csord__Subscription__c>([SELECT id,Name,Billing_Account__c,Billing_Account__r.Status__c 
                                                       from csord__Subscription__c where 
                                                       cssdm__solution_association__c IN:solutionIdSet
                                                       AND Billing_Account__r.Status__c In:billingAccStatusSet]);

        }else{
            return new Map<String,csord__Subscription__c>();
        }
    }
    /*  
     * Input Parameter 1 : subscriptionId
     * Return Parameter : returns subscription
     * Owner : shubhi V
     * Jira : EDGE-173803
    */
    public static csord__Subscription__c getSubscriptionNumer(String subsid){
         csord__Subscription__c subsInfo=[Select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where id =:subsid];
        return subsInfo;
    }  
    /*  
    * Input Parameter 1 : basketID
    * Return Parameter :  subscription list
    * Owner : shubhi V
    * Jira : EDGE-181979
    */
    public static List<csord__Subscription__c> getOrderFromSubscription(String basketID){
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        subList=[select id,csord__Order__c from csord__Subscription__c  where  csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c =: basketID order by createdDate DESC limit 1];
        return subList;
    }

    /*  
    * Input Parameter 1 : List<Id> macdBasketList
    * Return Parameter  : List<csord__Subscription__c>
    * Owner             : Aman Soni
    * Jira              : EDGE-191138
    */
    public static List<csord__Subscription__c> getCHOWNSubscription(List<Id> macdBasketList){
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        subList = [select id, csordtelcoa__Replaced_Subscription__c, csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.configGUID__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,(select id,csordtelcoa__Replacement_Service__c,csordtelcoa__Replaced_Service__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.configGUID__c from csord__Services__r) from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' and csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c IN :macdBasketList];
        return subList;
    } 
    /*  
    * Input Parameter 1 : List<Id> subscriptionIds
    * Return Parameter  : List<csord__Subscription__c>
    * Owner             : Aman Soni
    * Jira              : EDGE-191138
    */
    //updated for EDGE-209293
    public static List<csord__Subscription__c> getSubscriptions(List<Id> subscriptionIds){
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        subList = [SELECT Id,name,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,csord__Order__c,csord__Order__r.csordtelcoa__Opportunity__r.Type FROM csord__Subscription__c WHERE Id IN :subscriptionIds];
        return subList;
    }

    /*  
    * Input Parameter 1 : orderId
    * Return Parameter  : Set<csord__Subscription__c>
    * Owner             : Aman Soni
    * Jira              : EDGE-199911
    */
    public static Set<csord__Subscription__c> getSubsNicknameForOrder(String orderId){
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        List<string> prodSpecsList = Label.ProductsToAllowNickname.split(',');
        if(prodSpecsList != null && !prodSpecsList.isEmpty()){
            subList = [SELECT Id,Name,csordtelcoa__Subscription_Number__c,serviceMSISDN__c,Billing_Account__r.Billing_Account_Number__c,Nickname__c,csord__Order__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Replaced_Subscription__c FROM csord__Subscription__c WHERE csordtelcoa__Replaced_Subscription__c = null and csordtelcoa__Replacement_Subscription__c = null and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c IN :prodSpecsList and csord__Order__c = :orderId];
        }
        Set<csord__Subscription__c> subSet = new Set<csord__Subscription__c>(subList);
        return subSet;
    } 
    /*  
    * Input Parameter 1 : orderIds
    * Return Parameter  : List<csord__Subscription__c>
    * Owner             : Aparna Anisetti
    * Jira              : DIGI-19162
    */
    //START
    public static List<csord__Subscription__c> getListOfSubscriptions(List<Id> orderIds){
        List<csord__Subscription__c> listOfSubscriptions = [SELECT ID, MarketableOffer__r.Offer_ID__c, MarketableOffer__r.Name, csord__Order__c, csord__Account__r.Id, 
        csord__Order__r.csord__Order_Number__c, Billing_Account__r.Billing_Account_Number__c, csordtelcoa__Product_Configuration__r.Id,
        csordtelcoa__Product_Configuration__r.Name, TenancyID__c, csordtelcoa__Replaced_Subscription__c, 
        csordtelcoa__Product_Configuration__r.Type__c, ContractJunction__r.Contract_Number__c, csordtelcoa__Replaced_Subscription__r.Id
        FROM csord__Subscription__c WHERE csord__Order__c IN :orderIds 
        AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' ];
        
        return listOfSubscriptions;
    } 
    //END
}