/*************************************************************************************************
Name : ConfigurationCloneSubscriber 
Description : ConfigurationCloneSubscriber
Test Class  : ConfigurationCloneSubscriberTest
Sr no 1.11/04/2019      Laxmi Rahate    EDGE-74263,EDGE-70717 - BUG-The WideFeas code not coming in case of cloned basket. 
Sr No 2. 02/05/2019     Laxmi Rahate    EDGE-75157 - Added to code to populate PC_cloned_from_Id__C 
                        while cloning the basket - this field is used to copy the attachment from Original Basket
**************************************************************************************************/

global with sharing class ConfigurationCloneSubscriber extends csutil.ASubscriber {
    static final String KEY_NAME = 'ConfigIdsOldToNew'; //AB: post upgrade changes

    public override void onMessage(String topic, String subject, Map<String, Object> payload) {
        System.debug('payload>>>>'+payload);
        Set<Id> allConfigIds = new Set<Id>();
        //Added for EGDE-75157 - the Set to hold the Cloned PC IDs
        Set<Id> setClonedConfigIDs = new Set<Id>();

        
        Map<Id, Id> newConfigIdOldConfigId = new Map<Id, Id>();
        // get all config Ids for SOQL, set map between cloned configuration id and origin configuration id
        // //AB: post upgrade changes start
        if (!payload.keySet().isEmpty() && payload.containsKey(KEY_NAME)) {
            System.debug(payload.get(KEY_NAME));
            Map<Id, List<Id>> payloadMap = (Map<Id, List<Id>>)JSON.deserializeStrict(JSON.serialize(payload.get(KEY_NAME)), Map<Id, List<Id>>.class);
            System.debug('payload><><>'+payload);
            for (Id originConfigId : payloadMap.keySet()) {
               System.debug('originConfigId--' + originConfigId);
                allConfigIds.add(originConfigId);
                for (Id clonedConfigId : payloadMap.get(originConfigId)) {
                    allConfigIds.add(clonedConfigId);
                    System.debug('clonedConfigId--' + clonedConfigId);
                    setClonedConfigIDs.add(clonedConfigId);
                    newConfigIdOldConfigId.put(clonedConfigId, originConfigId);
                }
            }
        } else {
            System.debug('Nothing to do, exiting...');
            return;
        }
        //AB: post upgrade changes end
        System.debug('setClonedConfigIDs--List of Cloned Config IDs' + setClonedConfigIDs);

        List<cscfga__Product_Configuration__c> productConfigurations = [Select Id,name,cscfga__Product_Basket__c,cscfga__Configuration_Status__c,cscfga__Product_Definition__r.product_Specification__c From cscfga__Product_Configuration__c Where Id in :allconfigIds];
        Map<Id, String> idStatusMap = new Map<Id, String>();
        Map<ID,String> prodConfigTobasketMap= new Map<ID,String>();
        Map<Id, cscfga__Product_Configuration__c> idProductConfigurationMap = new Map<Id, cscfga__Product_Configuration__c>();
        for(cscfga__Product_Configuration__c productConfiguration : productConfigurations) {
            idStatusMap.put(productConfiguration.Id, productConfiguration.cscfga__Configuration_Status__c);
            idProductConfigurationMap.put(productConfiguration.Id, productConfiguration);
            //1 - Populating Map only in case of IP Site
            //if(productConfiguration.name=='IP Site'){
           
            if (productConfiguration.cscfga__Product_Definition__r.product_Specification__c != null &&
                productConfiguration.cscfga__Product_Definition__r.product_Specification__c.equals('DMCAT_ProductOffering_000304') &&
                productConfiguration.name.contains('Site')) {
                prodConfigTobasketMap.put(productConfiguration.Id,productConfiguration.cscfga__Product_Basket__c);
            }
            
        }
       
        
        List<cscfga__Product_Configuration__c> productConfigurationsForUpdate = new List<cscfga__Product_Configuration__c>();
        for (Id clonedConfigId : newConfigIdOldConfigId.keySet()) {
            if (idStatusMap.get(clonedConfigId) != idStatusMap.get(newConfigIdOldConfigId.get(clonedConfigId))) {
                cscfga__Product_Configuration__c updateConfiguration = idProductConfigurationMap.get(clonedConfigId);
                updateConfiguration.cscfga__Configuration_Status__c = idStatusMap.get(newConfigIdOldConfigId.get(clonedConfigId));
                productConfigurationsForUpdate.add(updateConfiguration);
            }
            
        }
        if (productConfigurationsForUpdate.size() > 0) {
            update productConfigurationsForUpdate;
        }
        Set<ID> productConfigurationsForUpdateId = new Set<ID>();
        for (Id clonedConfigId : newConfigIdOldConfigId.keySet()) {   
            // 1 Checking if Basket IDs are same - only when these are same we need to default the Site Object selections - Widefeas, Servicelocation, Zone
            if (prodConfigTobasketMap.get(clonedConfigId) == prodConfigTobasketMap.get(newConfigIdOldConfigId.get(clonedConfigId))) {
                 productConfigurationsForUpdateId.add(clonedConfigId);
            }
        }
        
         
         //2 - with the PC for Cloned Set - setClonedConfigIDs get the list of PC and for those PC IDs get the Original PC ID.

        List<cscfga__Product_Configuration__c> pcForUpdateOriginPCID= new List<cscfga__Product_Configuration__c> ();
        for(cscfga__Product_Configuration__c pc:[Select Id,name,cscfga__Product_Basket__c,cscfga__Configuration_Status__c,
                                                 PC_cloned_from_Id__C From cscfga__Product_Configuration__c 
                                                 Where Id in: setClonedConfigIDs]){
            pc.PC_cloned_from_Id__C = newConfigIdOldConfigId.get(pc.ID);
            pcForUpdateOriginPCID.add(pc);
            
        }
        
         if (pcForUpdateOriginPCID.size() > 0) {
            update pcForUpdateOriginPCID;
        }
        //Select Id,name,cscfga__Product_Basket__c,cscfga__Configuration_Status__c,PC_cloned_from_Id__C From cscfga__Product_Configuration__c Where Id ='a3T2O000000HXMq'

        List<cscfga__Attribute__c> attributeListToBeUpdated= new List<cscfga__Attribute__c> ();
        for(cscfga__Attribute__c att:[Select id,name,cscfga__Value__c,cscfga__Product_Configuration__c from cscfga__Attribute__c where name IN('Widefeas Code','SiteNetworkZone','ServiceabilityLocation') and cscfga__Product_Configuration__c IN: productConfigurationsForUpdateId]){
            if(att.name=='ServiceabilityLocation'){
                att.cscfga__Value__c='Urban';
            }else if(att.name=='Widefeas Code'){
                att.cscfga__Value__c='';
            }else if(att.name=='SiteNetworkZone'){
                att.cscfga__Value__c='1';
            }
            
            attributeListToBeUpdated.add(att);
        }
        try {
        if(attributeListToBeUpdated.size()>0){
            update  attributeListToBeUpdated;
            } 
            
        }
        catch (Exception e){
        System.debug('An exception occurred  ' + e.getMessage());
        } 
    }
    global class Optionals{
        global String selectedAddressDisplay;
        global String hiddenParam1;
    }
}