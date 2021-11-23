/********************************************************************************
* Class Name  : C2O_NumberTriggerHandler
* Description : This class is the Handler Class to call other helper methods to execute the necessary logic related to Number__c object.   
* Created By  : Sumit
* Change Log  : 09 May 2021 - Created 
********************************************************************************/
public class C2O_NumberTriggerHandler extends SYS_TriggerHandler{
    // Class variables to capture trigger context variables.
        private Map<Id, Number__c> newNumberMap;
        private Map<Id, Number__c> oldNumberMap;
        private List<Number__c> newNumberList;
        private List<Number__c> oldNumberList;
        
    /***************************************************************************************
    * Method Name - C2O_NumberTriggerHandler 
    * Description - Constructor method to initialise the necessary trigger context variables
    ****************************************************************************************/    
        public C2O_NumberTriggerHandler() {
            this.setHandlerName('C2O_NumberTriggerHandler');
            this.newNumberMap = (Map<Id, Number__c>) Trigger.newMap;
            this.oldNumberMap = (Map<Id, Number__c>) Trigger.oldMap;
            this.newNumberList = (List<Number__c>)Trigger.new;
            this.oldNumberList = (List<Number__c>)Trigger.old;
        }
        
    /***************************************************************************************
    * Method Name - beforeInsert
    * Description - DIGI-34845: This method is used to call the before Insert operation on record.
    ****************************************************************************************/
    public override void beforeInsert() {
        List<ConstantMetadataUtility__mdt> mdtUtilityList = [SELECT Value__c,DeveloperName FROM ConstantMetadataUtility__mdt WHERE DeveloperName='Product_Specification_Code' AND Value__c != null LIMIT 1];
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Number','triggerBeforeInsert')){
            for(Number__c num : this.newNumberList){
                if(num.Subscription_number__c != null && mdtUtilityList != null && num.Product_Specification_Code__c == mdtUtilityList[0].Value__c){
                    num.Status__c = 'Active';
                }
            }
        }
    }
    /***************************************************************************************
    * Method Name - beforeUpdate
    * Description - This method is used to call the before Update operation on record.
    ****************************************************************************************/
    public override void beforeUpdate() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Number','triggerBeforeUpdate')){
        
            List<Number__c> recordswithstatuschange = new List<Number__c>();
            List<String> changesToMonitor = new List<String>{'Status__c'};
            List<String> trackOldFields = new List<String>{'Status__c'};
                
            Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(this.oldNumberMap,this.newNumberMap,changesToMonitor);
            List<ConstantMetadataUtility__mdt> mdtUtilityList = [SELECT Value__c,DeveloperName FROM ConstantMetadataUtility__mdt WHERE DeveloperName='Product_Specification_Code' AND Value__c != null LIMIT 1];
            // Single Loop to handle all possible Trigger context scenarios
            for(Number__c num : this.newNumberList){
                
                // PB CRITERIA FOR BATCH
                if(Environment_Configurations__c.getInstance().call_EDIS_Batch__c && recordsWithChanges.get(num.Id)?.contains('Status__c') && (num.Status__c.equalsIgnoreCase(C2O_OrderConstants.ACTIVE) || num.Status__c.equalsIgnoreCase(C2O_OrderConstants.INACTIVE) )){
                     num.DL_API_response_code__c = NULL;
                     num.DL_API_response_msg__c = NULL;
                     num.Directory_Listing_DateTime__c = NULL;
                     num.Status_LastModifiedDate__c = DateTime.now();
                }
                if(num.Subscription_number__c != null && mdtUtilityList != null && num.Product_Specification_Code__c == mdtUtilityList[0].Value__c){
                    num.Status__c = 'Active';
                }
            }
            
        }
         // LIFT AND SHIFT TO BE OPTIMIZED BY FEATUTRE TEAM
        NumberTriggerHandler.handleBeforeUpdate(newNumberMap, oldNumberMap);
    }
        
    /***************************************************************************************
    * Method Name - afterInsert
    * Description - This method is used to call the before Update operation on record.
    ****************************************************************************************/
        public override void afterInsert() {
            // LIFT AND SHIFT TO BE OPTIMIZED BY FEATUTRE TEAM
            NumberTriggerHandler.handleAfterInsert(newNumberMap);
        }
        
    /***************************************************************************************
    * Method Name - afterUpdate
    * Description - This method is used to call the before Update operation on record.
    ****************************************************************************************/
        public override void afterUpdate() {
        
            if(FeatureEligibilityChecker.determineFeatureEligiblity('Number','triggerAfterUpdate')){
            
                List<Number__c> recordswithstatuschange = new List<Number__c>();
                List<String> changesToMonitor = new List<String>{'Status__c'};
                List<String> trackOldFields = new List<String>{'Status__c'};
                    
                Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(this.oldNumberMap,this.newNumberMap,changesToMonitor);
               
                // Single Loop to handle all possible Trigger context scenarios
                for(Number__c num : this.newNumberList){
                    if(!Environment_Configurations__c.getInstance().call_EDIS_Batch__c && 
                       recordsWithChanges.get(num.Id)?.contains('Status__c') && 
                       (num.Status__c <> NULL && (num.Status__c.equalsIgnoreCase(C2O_OrderConstants.ACTIVE) || 
                                                  num.Status__c.equalsIgnoreCase(C2O_OrderConstants.INACTIVE) ) ) ){
                        recordswithstatuschange.add(num);
                    }
                    
                }
                
                If(!recordswithstatuschange.isEmpty()){
                    C2O_NumberTriggerHelper.callEDIS(recordswithstatuschange);
                }
            }
            
            // LIFT AND SHIFT TO BE OPTIMIZED BY FEATUTRE TEAM
            NumberTriggerHandler.handleAfterUpdate(newNumberMap, oldNumberMap);
            
        }
        
       /* Public override void afterDelete() {
        
          //  if( Test.isrunningtest() || !FeatureEligibilityChecker.determineFeatureEligiblity('Number','triggerAfterDelete')) {
                if( BypassTrigger.isRunningTestCheck || !FeatureEligibilityChecker.determineFeatureEligiblity('Number','triggerAfterDelete')) {
            
                // LIFT AND SHIFT TO BE OPTIMIZED BY FEATUTRE TEAM
                NumberTriggerHandler.handleAfterDelete(oldNumberMap);
            
            }
            //Commenting this because it is not called in trigger.
        }*/
    }