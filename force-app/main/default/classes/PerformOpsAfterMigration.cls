/******************************************************************************************************************************
Class Name : PerformOpsAfterMigration
Test Class : PerformOpsAfterMigrationTest 
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           02/03/2021    EDGE-191138(New Class)           21.03
******************************************************************************************************************************/
public with sharing class PerformOpsAfterMigration{
    public Map<String, csord__Subscription__c> subOutgoingMap = new Map<String, csord__Subscription__c>();
    public Map<String, csord__Subscription__c> subIncomingMap = new Map<String, csord__Subscription__c>();
    public Map<String, csord__Service__c> servOutgoingMap     = new Map<String, csord__Service__c>();
    public Map<String, csord__Service__c> servIncomingMap     = new Map<String, csord__Service__c>();
    
    /*  
    * Method Name      : linkSubsAfterMigration
    * Input Parameter  : String MCR Id
    * Return Parameter : void
    * Description      : Link All the Incoming Subscription and Services for CHOWN Journey
    * Owner            : Aman Soni
    * Jira             : EDGE-191138
    */
    public void linkSubsAfterMigration(String mcrId){
        If(String.IsBlank(mcrId))
        return;
        Boolean isMapCreated;
        Migration_Change_Request__c mcrRec = [select id, macd_basket_ids__c from Migration_Change_Request__c where Id = :mcrId];
        List<Id> macdBasketList = mcrRec.macd_basket_ids__c != '' ? mcrRec.macd_basket_ids__c.split(',') : new List<Id>();
        List<csord__Subscription__c> subscriptionLst = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subsToUpdateLst = new List<csord__Subscription__c>();
        List<csord__Service__c> servsToUpdateLst = new List<csord__Service__c>();

        if(!macdBasketList.isEmpty()){
            subscriptionLst = Model_Subscription.getCHOWNSubscription(macdBasketList);
        }
        
        if(!subscriptionLst.isEmpty()){
            isMapCreated = createSubsAndServiceMap(subscriptionLst);
        }
        
        if(isMapCreated){
            subsToUpdateLst = performOpsOnSubscriptions();          
            servsToUpdateLst = performOpsOnServices();          
        }
        
        if(subsToUpdateLst != null && !subsToUpdateLst.isEmpty() && servsToUpdateLst != null && !servsToUpdateLst.isEmpty()){
            update subsToUpdateLst; 
            update servsToUpdateLst;
            system.debug('!!Updated Successfully!!');
        }
    }
    
    /*  
    * Method Name      : createSubsAndServiceMap
    * Input Parameter  : List<csord__Subscription__c> subscriptionLst
    * Return Parameter : Boolean
    * Description      : create maps for outgoing and incoming subscriptions and services
    * Owner            : Aman Soni
    * Jira             : EDGE-191138
    */
    public Boolean createSubsAndServiceMap(List<csord__Subscription__c> subscriptionLst){
        Boolean isMapCreated = false;
        for(csord__Subscription__c subcription : subscriptionLst){
            if(subcription.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c.equalsIgnoreCase('Outgoing')){
                subOutgoingMap.put(subcription.csordtelcoa__Product_Configuration__r.configGUID__c, subcription);   
                for(csord__Service__c service : subcription.csord__Services__r){
                    servOutgoingMap.put(service.csordtelcoa__Product_Configuration__r.configGUID__c, service);
                }
            }
            if(subcription.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c.equalsIgnoreCase('Incoming')){
                subIncomingMap.put(subcription.csordtelcoa__Product_Configuration__r.configGUID__c, subcription);   
                for(csord__Service__c service : subcription.csord__Services__r){
                    servIncomingMap.put(service.csordtelcoa__Product_Configuration__r.configGUID__c, service);
                }
            }
        }
        if(!subOutgoingMap.isEmpty() && !subIncomingMap.isEmpty() && !servOutgoingMap.isEmpty() && !servIncomingMap.isEmpty()){
            isMapCreated = true;
        }
        return isMapCreated;
    }
    
    /*  
    * Method Name      : performOpsOnSubscriptions
    * Input Parameter  : NA
    * Return Parameter : List<csord__Subscription__c>
    * Description      : perform operations on incoming subscriptions
    * Owner            : Aman Soni
    * Jira             : EDGE-191138
    */
    public List<csord__Subscription__c> performOpsOnSubscriptions(){
        List<csord__Subscription__c> subsToUpdateLst = new List<csord__Subscription__c>();
        for(csord__Subscription__c subInc : subIncomingMap.values()){
            if(String.isNotBlank(subInc.csordtelcoa__Product_Configuration__r.configGUID__c)){
                if(subOutgoingMap.containsKey(subInc.csordtelcoa__Product_Configuration__r.configGUID__c)){
                    subInc.csordtelcoa__Replaced_Subscription__c = subOutgoingMap.get(subInc.csordtelcoa__Product_Configuration__r.configGUID__c).id;
                    csord__Subscription__c subOut = subOutgoingMap.get(subInc.csordtelcoa__Product_Configuration__r.configGUID__c);
                    subOut.csordtelcoa__Replacement_Subscription__c = subInc.id;
                    subsToUpdateLst.add(subInc);
                    subsToUpdateLst.add(subOut);
                }
            }
        }       
        return subsToUpdateLst;
    }
    
    /*  
    * Method Name      : performOpsOnServices
    * Input Parameter  : NA
    * Return Parameter : List<csord__Service__c>
    * Description      : perform operations on incoming services
    * Owner            : Aman Soni
    * Jira             : EDGE-191138
    */
    public List<csord__Service__c> performOpsOnServices(){
        List<csord__Service__c> servsToUpdateLst = new List<csord__Service__c>();
        for(csord__Service__c serv : servIncomingMap.values()){
            if(String.isNotBlank(serv.csordtelcoa__Product_Configuration__r.configGUID__c)){
                if(servOutgoingMap.containsKey(serv.csordtelcoa__Product_Configuration__r.configGUID__c)){
                    serv.csordtelcoa__Replaced_Service__c = servOutgoingMap.get(serv.csordtelcoa__Product_Configuration__r.configGUID__c).id;
                    csord__Service__c servOut = servOutgoingMap.get(serv.csordtelcoa__Product_Configuration__r.configGUID__c);
                    servOut.csordtelcoa__Replacement_Service__c = serv.id;
                    servsToUpdateLst.add(serv);
                    servsToUpdateLst.add(servOut);
                }
            }
        }
        return servsToUpdateLst;
    }
}