/********************************************************************************
* Class Name  : C2O_ServiceTriggerHandler
* Description : This class is the Handler Class to call other helper methods to execute the necessary logic.   
* Created By  : Sudheendra
* Change Log  : 06 May 2021 - Created 
********************************************************************************/
public class C2O_ServiceTriggerHandler extends SYS_TriggerHandler {
    // Class variables to capture trigger context variables.
    private Map<Id, csord__Service__c> newServiceMap;
    private Map<Id, csord__Service__c> oldServiceMap;
    private List<csord__Service__c> newServiceList;
    private List<csord__Service__c> oldServiceList;
    List<csord__Service__c> listOfServices = new List<csord__Service__c>();
    
    /***************************************************************************************
* Method Name - C2O_ServiceTriggerHandler 
* Description - Constructor method to initialise the necessary trigger context variables
****************************************************************************************/    
    public C2O_ServiceTriggerHandler() {
        this.setHandlerName('C2O_ServiceTriggerHandler');
        this.newServiceMap = (Map<Id, csord__Service__c>) Trigger.newMap;
        this.oldServiceMap = (Map<Id, csord__Service__c>) Trigger.oldMap;
        this.newServiceList = Trigger.new;
        this.oldServiceList = Trigger.old;
    }
    /***************************************************************************************
* Method Name - beforeInsert
* Description - This method is used to call the before Insert operation on record.
****************************************************************************************/
    public override void beforeInsert() {
    
        // LIFT AND SHIFT TO BE OPTIMIZED BY FEATUTRE TEAM
        for(csord__Service__c ser : this.newServiceList){
            if(!String.isEmpty(ser.name) && (ser.name.contains('----') || ser.name.contains(' x '))){
                ser.name = ser.name.replace('------------', '');
                ser.name = ser.name.replace('--------', '');
                ser.name = ser.name.replace('----', '');
                ser.name = ser.name.contains(' x ') ? ser.name.split(' x ',2).get(0) : '';
            }
            if(!String.isEmpty(ser.Model__c) && (ser.Model__c.contains('----') || ser.Model__c.contains(' x '))){
                ser.Model__c = ser.Model__c.replace('------------', '');
                ser.Model__c = ser.Model__c.replace('--------', '');
                ser.Model__c = ser.Model__c.replace('----', '');
                ser.Model__c = ser.Model__c.contains(' x ') ? ser.Model__c.split(' x ',2).get(0) : '';
            }
        }
        
    }
    
    /***************************************************************************************
* Method Name - beforeUpdate
* Description - This method is used to call the before Update operation on record.
****************************************************************************************/
    public override void beforeUpdate() {
    
        // LIFT AND SHIFT TO BE OPTIMIZE BY FEATUTRE TEAM
        for(csord__Service__c ser : this.newServiceList){
            if(!String.isEmpty(ser.name) && (ser.name.contains('----') || ser.name.contains(' x '))){
                ser.name = ser.name.replace('------------', '');
                ser.name = ser.name.replace('--------', '');
                ser.name = ser.name.replace('----', '');
                ser.name = ser.name.contains(' x ') ? ser.name.split(' x ',2).get(0) : '';
            }
            if(!String.isEmpty(ser.Model__c) && (ser.Model__c.contains('----') || ser.Model__c.contains(' x '))){
                ser.Model__c = ser.Model__c.replace('------------', '');
                ser.Model__c = ser.Model__c.replace('--------', '');
                ser.Model__c = ser.Model__c.replace('----', '');
                ser.Model__c = ser.Model__c.contains(' x ') ? ser.Model__c.split(' x ',2).get(0) : '';
            }
        }
    
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Service','triggerBeforeUpdate')){
            
            List<csord__Service__c> replacedServiceBlankList = new List<csord__Service__c>();
            List<csord__Service__c> replacedServiceNonBlankList = new List<csord__Service__c>();
            List<csord__Service__c> disconnectedServiceList = new List<csord__Service__c>();
            List<csord__Service__c> completionDateUpdateList = new List<csord__Service__c>();
            
            
            List<String> changesToMonitor = new List<String>{'csord__Status__c'};
            List<String> trackOldFields = new List<String>{'csord__Status__c'};
                    
            Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(this.oldServiceMap,this.newServiceMap,changesToMonitor);
            Map<Id,Map<String, String>> oldFieldValuesMap = SYS_UtilityClass.getOldValuesMap(this.oldServiceMap,trackOldFields);
            
            
            // Single Loop to handle all possible Trigger context scenarios
            for(csord__Service__c service : this.newServiceList){
                
                if ( service.csord__Status__c <> NULL  ) {
                    
                    if(recordsWithChanges.get(service.Id)?.contains('csord__Status__c')){
                        
                        if(!oldFieldValuesMap.get(service.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.CONNECTED) && 
                           service.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.CONNECTED)){
                               
                               if(String.isBlank(service.csordtelcoa__Replaced_Service__c)){
                                   replacedServiceBlankList.add(service);
                               }
                               else{
                                   replacedServiceNonBlankList.add(service);
                               }
                        }
                    
                    
                        if(!oldFieldValuesMap.get(service.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.DISCONNECTED) 
                           && service.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.DISCONNECTED)){
                               disconnectedServiceList.add(service);                           
                           }
                        if(oldFieldValuesMap.get(service.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.SUSPENDED) 
                           && service.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.ACTIVE)){
                               completionDateUpdateList.add(service);                           
                           }
                        if(!oldFieldValuesMap.get(service.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.SUSPENDED) 
                           && service.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.SUSPENDED)){
                               completionDateUpdateList.add(service);                           
                           }
                        if(!oldFieldValuesMap.get(service.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.PAID_OUT) 
                           && service.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.PAID_OUT)){
                               completionDateUpdateList.add(service);                           
                           }
                        if(!oldFieldValuesMap.get(service.Id)?.get('csord__Status__c').equalsIgnoreCase(C2O_OrderConstants.CLOSED) 
                           && service.csord__Status__c.equalsIgnoreCase(C2O_OrderConstants.CLOSED)){
                               completionDateUpdateList.add(service);                           
                           }
                    }
                }                  
                
                
                
            }
            if(!replacedServiceBlankList.isEmpty()){
                C2O_ServiceTriggerHelper.updateActivationDetailsBlankService(replacedServiceBlankList);
            }
            if(!replacedServiceNonBlankList.isEmpty()){
                C2O_ServiceTriggerHelper.updateActivationDetailsNonBlankService(replacedServiceNonBlankList);
            }
            if(!disconnectedServiceList.isEmpty()){
                C2O_ServiceTriggerHelper.updateDeactivationDetails(disconnectedServiceList);
            }
            if(!completionDateUpdateList.isEmpty()){
                C2O_ServiceTriggerHelper.updateCompletionDate(completionDateUpdateList);
            }
            
        }
    }
    
    /***************************************************************************************
* Method Name - afterInsert
* Description - This method is used to call the after Insert operation on record.
****************************************************************************************/
    public override void afterInsert() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Service','triggerAfterInsert')){
            
            C2O_ServiceTriggerHelper.associateservicetoproductconfig(this.newServiceList);
            
        }
    }
    
    /***************************************************************************************
* Method Name - afterUpdate
* Description - This method is used to call the after Update operation on record.
****************************************************************************************/
    public override void afterUpdate() {
        
        // LIFT AND SHIFT TO BE OPTIMIZED BY FEATUTRE TEAM
        //EDGE-126425
        ServiceTriggerCustomHandler.filterAllvalidrecords(oldServiceMap, newServiceList);
        ServiceTriggerCustomHandler.updateAssetIdforNonSerialized(oldServiceMap, newServiceList); //DIGI-27111
    }
}