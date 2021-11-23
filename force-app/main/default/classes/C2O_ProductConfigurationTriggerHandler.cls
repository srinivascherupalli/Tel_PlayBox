/********************************************************************************
* Class Name  : C2O_ProductConfigurationTriggerHandler
* Description : This class is Handler Class to call the helper to execute the logic.   
* Created By  : Uday Dunna 
* Change Log  : Created
********************************************************************************/
public with sharing class C2O_ProductConfigurationTriggerHandler extends SYS_TriggerHandler {
    
    // DECLARE GLOBAL VARIABLES
    private Map<Id, cscfga__Product_Configuration__c> newProdConfigMap;
    private Map<Id, cscfga__Product_Configuration__c> oldProdConfigMap; 
    private List<cscfga__Product_Configuration__c> newProdConfigList;
    private List<cscfga__Product_Configuration__c> oldProdConfigList;    
    
    public C2O_ProductConfigurationTriggerHandler() { 
        this.setHandlerName('C2O_ProductConfigurationTriggerHandler');
        this.newProdConfigMap = (Map<Id, cscfga__Product_Configuration__c>) Trigger.newMap;
        this.oldProdConfigMap = (Map<Id, cscfga__Product_Configuration__c>) Trigger.oldMap;
        this.newProdConfigList = Trigger.new;
        this.oldProdConfigList = Trigger.old;
    }   
    
    /***************************************************************************************
    * Method Name - beforeInsert
    * Description - This method is used to call the before Insert operation on record.
    ****************************************************************************************/
    public override void beforeInsert() {
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Configuration','triggerBeforeInsert')){
            // LOCAL VARIABLES
            List<cscfga__Product_Configuration__c> prodConfigForCheckOfferRef = new List<cscfga__Product_Configuration__c>();  
            List<cscfga__Product_Configuration__c> prodConfigForUpdateCLI = new List<cscfga__Product_Configuration__c>();  
            for(cscfga__Product_Configuration__c pdCon : (List<cscfga__Product_Configuration__c>) Trigger.new){
                if(pdCon.cscfga__Configuration_Offer__c != null){
                    prodConfigForCheckOfferRef.add(pdCon);
                    System.debug('pdCon'+pdCon);
                }
                if(pdCon.cscfga__Product_Basket__c != null){
                    prodConfigForUpdateCLI.add(pdCon);
                }
            }
            
            //Calling Check Offer Reference for Product Configuration logic
            if(!prodConfigForCheckOfferRef.isEmpty() && prodConfigForCheckOfferRef.size() > 0){
                C2O_ProductConfigurationTriggerHelper.CheckOfferReference(prodConfigForCheckOfferRef); 
            }
            
            //Calling Update Charge Line Item for Product Config logic.
            if(!prodConfigForUpdateCLI.isEmpty() && prodConfigForUpdateCLI.size() > 0){
                C2O_ProductConfigurationTriggerHelper.updateChargeLineItemWithPC(prodConfigForUpdateCLI);
            }            
        }         
    } 
    
    /***************************************************************************************
    * Method Name - beforeUpdate
    * Description - This method is used to call the before Update operation on record.
    ****************************************************************************************/
    public override void beforeUpdate(){ 
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Configuration','triggerBeforeUpdate')){
            List<cscfga__Product_Configuration__c> prodConfigForChargeLineItemList = new List<cscfga__Product_Configuration__c>();
            List<cscfga__Product_Configuration__c> prodConfigUpdateList = new List<cscfga__Product_Configuration__c>();
            List<String> changesToMonitor = new List<String>{'cscfga__Configuration_Offer__c'};
                Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);
            
            for(cscfga__Product_Configuration__c prodConfig : (List<cscfga__Product_Configuration__c>)Trigger.new){
                if(recordsWithChanges.get(prodConfig.Id).contains('cscfga__Configuration_Offer__c')){
                    prodConfigUpdateList.add(prodConfig);
                } 
            }
            
            //Calling Check Offer Reference for Product Configuration logic
            if(!prodConfigUpdateList.isEmpty() && prodConfigUpdateList.size() > 0){
                C2O_ProductConfigurationTriggerHelper.CheckOfferReference(prodConfigUpdateList);
            }
        }
    }
    
    /***************************************************************************************
    * Method Name - afterInsert
    * Description - This method is used to call the after Insert operation on record.
    ****************************************************************************************/
    public override void afterInsert(){ 
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Configuration','triggerAfterInsert')){
            List<cscfga__Product_Configuration__c> prodConfigUpdateCLIList = new List<cscfga__Product_Configuration__c>();
            for(cscfga__Product_Configuration__c pdCon : (List<cscfga__Product_Configuration__c>) Trigger.new){
                if(pdCon.cscfga__Product_Basket__c != null){
                    prodConfigUpdateCLIList.add(pdCon);
                }
            }
            
            //Calling Update Charge Line Item for Product Config logic.
            if(!prodConfigUpdateCLIList.isEmpty() && prodConfigUpdateCLIList.size() > 0){
                C2O_ProductConfigurationTriggerHelper.updateChargeLineItemWithPC(prodConfigUpdateCLIList);
            }            
        }   
    }
    
    /***************************************************************************************
    * Method Name - afterUpdate
    * Description - This method is used to call the after Update operation on record.
    ****************************************************************************************/
    public override void afterUpdate(){ 
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Configuration','triggerAfterUpdate')){
            List<cscfga__Product_Configuration__c> prodConfigForChargeLineItemList = new List<cscfga__Product_Configuration__c>();
            List<String> changesToMonitor = new List<String>{'cscfga__Product_Basket__c'};
                Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);
            for(cscfga__Product_Configuration__c prodConfig : newProdConfigList){
                if(recordsWithChanges.get(prodConfig.Id).contains('cscfga__Product_Basket__c')){ 
                    prodConfigForChargeLineItemList.add(prodConfig);
                } 
            }         
            
            //Calling Update Charge Line Item for Product Config logic.
            if(!prodConfigForChargeLineItemList.isEmpty() && prodConfigForChargeLineItemList.size() > 0){
                C2O_ProductConfigurationTriggerHelper.updateChargeLineItemWithPC(prodConfigForChargeLineItemList);
            }            
        }
    }
}