/******************************************************************************************************************************
Class Name : Model_Order
Test Class : Model_Ordertest 
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Shubhi              22/02/2021    EDGE-191138(order gen issue fix))21.03
******************************************************************************************************************************/
public class Model_Order {
    /*  
    * Input Parameter 1 : set<string> basketIds
    * Return Parameter  : Set<csord__Subscription__c>
    * Owner             : Shubhi V
    * Jira              : EDGE-209293
    */
    public static List<csord__Order__c> getorderfrombasket(set<string> basketIds){
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        if(basketIds != null && !basketIds.isEmpty()){
            orderList = [SELECT Id FROM csord__Order__c WHERE csordtelcoa__Opportunity__c IN (Select cscfga__Opportunity__c from cscfga__Product_Basket__c where ID IN:basketIds)];
        }
        return orderList;
    }
    
    /*  
    * @param   : set<string> orderIds
    * @return  : List<csord__Order__c>
    * @author  : Gautam Kumar
    * @jira    : DIGI-11210
    */
    public static List<csord__Order__c> getOrdersList(Set<string> orderIdSet){
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        if(!orderIdSet.isEmpty()){
            orderList = [Select Id, csordtelcoa__Opportunity__c, csordtelcoa__Opportunity__r.Type, csordtelcoa__Opportunity__r.Name, Product_Basket__c 
                         From csord__Order__c
                         Where Id IN: orderIdSet
                         LIMIT 50000];
        }
        return orderList;
    }
    
    /*  
    * @param   : set<string> orderIds
    * @return  : List<csord__Order__c>
    * @author  : Gautam Kumar
    * @jira    : DIGI-11210
    */
    public static List<csord__Order__c> getOrdersListFromServices(Set<string> recIdSet){
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Set<String> orderIdSet = new Set<String>();
        for(csord__Service__c service: [Select Id, csord__Order__c 
                                       From csord__Service__c
                                       Where Id In: recIdSet
                                       And csord__Order__c != null
                                       LIMIT 50000]){
                                            orderIdSet.add(service.csord__Order__c);
                                        }
        orderList = getOrdersList(orderIdSet);
        return orderList;
    }

}