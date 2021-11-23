/********************************************************************************
* Class Name  : C2O_ServiceTriggerHelper
* Description : Service Trigger Helperruns logic on Service records which are filtered
*               based on certain filter conditions which are defined in handler
* Created By  : Sudheendra
* Change Log  : 06 May 2021: Created 
********************************************************************************/
public class C2O_ServiceTriggerHelper {
    Public Static Date todaysDate = Date.today();
    Public Static DateTime todaysDatetime = (DateTime) Date.today();
    
    public static void updateActivationDetailsBlankService(List <csord__Service__c> replacedSubscriptionList){
        for(csord__Service__c replacedSubscription:  replacedSubscriptionList){
            
            if(replacedSubscription.Initial_Activation_DateTime__c == null){
                replacedSubscription.Initial_Activation_DateTime__c = todaysDatetime;
            }
            replacedSubscription.Completion_Date__c = todaysDatetime;
            
            if(replacedSubscription.csord__Activation_Date__c == null){
                replacedSubscription.csord__Activation_Date__c = todaysDate;
            }
            if(replacedSubscription.Initial_Activation_Date__c == null){
                replacedSubscription.Initial_Activation_Date__c = todaysDate;
            }
        }
    }
    
    public static void updateActivationDetailsNonBlankService(List <csord__Service__c> replacedServiceNonBlankList){
        for(csord__Service__c replacedSubscription:  replacedServiceNonBlankList){
            
            if(replacedSubscription.Initial_Activation_DateTime__c == null){
                replacedSubscription.Initial_Activation_DateTime__c = replacedSubscription?.csordtelcoa__Replaced_Service__r?.Initial_Activation_DateTime__c;
            }
            replacedSubscription.Completion_Date__c = todaysDatetime;
            
            if(replacedSubscription.csord__Activation_Date__c == null){
                replacedSubscription.csord__Activation_Date__c = todaysDate;
            }
            if(replacedSubscription.Initial_Activation_Date__c == null){
                replacedSubscription.Initial_Activation_Date__c = replacedSubscription?.csordtelcoa__Replaced_Service__r?.Initial_Activation_Date__c;
            }
        }
    }
    
    
    public static void updateDeactivationDetails(List <csord__Service__c> disconnectedServiceList){
        for(csord__Service__c discService:  disconnectedServiceList){
            
            if(discService.Deactivation_Date__c == null){
                discService.Deactivation_Date__c = todaysDatetime;
            }
            discService.Completion_Date__c = todaysDatetime;
            
            if(discService.csord__Deactivation_Date__c == null){
                discService.csord__Deactivation_Date__c = todaysDate;
            }
        }
    }
    
    public static void updateCompletionDate(List <csord__Service__c> completionDateUpdateList){
    	for(csord__Service__c completionDateUpdateSvc:  completionDateUpdateList){
            completionDateUpdateSvc.Completion_Date__c = todaysDatetime;
        }
    
    }
    
    public static void associateservicetoproductconfig(List <csord__Service__c> newservicelist) {
        List<ID> serviceIDs = new List<ID>();
        for(csord__Service__c service : newservicelist){
            serviceIDs.add(service.ID);
        }
        
        try{
            If(!serviceIDs.IsEmpty()){
                ServiceObjectRecordHandler.updateChargeLineItemWithService(serviceIDs);
            }  
        }
        Catch(Exception Exp){
            PRMUtilityClass.createException(Exp);
        }
        
    }
}