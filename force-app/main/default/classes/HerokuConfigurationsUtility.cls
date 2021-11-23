/***********************************************************************************************************************************
Class Name :HerokuConfigurationsUtility
Test Class :HerokuConfigurationsUtilityTest
************************************************************************************************************************************
Change.No.    Developer Name          Date          Story Description
1.            Venkat T               08/02/2021      created(EDGE-198709 In-Flight: Update Remediate required flag on Amend order rejection)
2             Shweta Khandelwal      17/01/2021      EDGE-198709 In-Flight: Update Remediate required flag on Amend order rejection
3.            Arinjay Singh          22/02/2021     EDGE-201409 In-Flight: Reset Amend Allowed Heroku PONR flag 
************************************************************************************************************************************/

public class HerokuConfigurationsUtility {
    
    public static Boolean pushRemediationFlagToHeroku(String orderId) {  
        Boolean result = false;
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id,Name,
            csordtelcoa__Product_Configuration__c,
            csordtelcoa__Product_Configuration__r.configGUID__c,
            csord__Subscription__r.csord__Status__c,
            csordtelcoa__Point_of_No_Return_Reached__c,csordtelcoa__Service_Number__c,
            cancel_Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
            cssdm__solution_association__c,csordtelcoa__Replaced_Service__c,
            csordtelcoa__Product_Configuration__r.subType__c ,csord__Status__c,csord__Order__c
            From csord__Service__c WHERE csord__Subscription__r.csord__Status__c='Amend Rejected' And csord__Order__c =:orderId ]);
                  
            if(servicesMap.size() > 0){
                try{
                    Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'UpdateRemediationFlag'), 1); 
                    System.debug('PushHerokuConfigurationsBatch jobId: ' + jobId);
                } 
                catch(Exception ex){
                    System.debug('Exception occoured '+ex);
                }
            }
        return true;
    }

    //Created By Shweta Khandelwal EDGE-198709
    public static void PushResetHerokuConfigurations (String BasketID){
        cscfga__Product_Basket__c inflightBasket =  [SELECT Id,csordtelcoa__Order_Under_Change__c, csordtelcoa__Order_Under_Change__r.csord__Status2__c 
        FROM cscfga__Product_Basket__c
        WHERE Id =: BasketID];

        Map<Id, Map<String, String>> serviceConfigurationMap = new Map<Id, Map<String, String>>();
        if(inflightBasket.csordtelcoa__Order_Under_Change__r.csord__Status2__c == Label.AmendRejectStatus){
            for(csord__Service__c service : [SELECT Id,Name,csord__Order__c
                From csord__Service__c WHERE csord__Order__c =:inflightBasket.csordtelcoa__Order_Under_Change__c]){
                serviceConfigurationMap.put(service.id,new Map<String,String>
                    {Label.AllowRemediation=>'',Label.AllowAmend =>'Amend Allowed'});
            }   
        }                                                                      
        if(serviceConfigurationMap.size() > 0){
            try{  
                Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(serviceConfigurationMap, 'BatchCheckNotRequired'), 1); 
                System.debug('PushHerokuConfigurationsBatch jobId: ' + jobId);
            } 
            catch(Exception ex){
                System.debug('Exception occoured '+ex);
            }
        }
    }

    // Arinjay :: 201409
    public static void resetAllowAmendInHeroku (String BasketID){
        cscfga__Product_Basket__c inflightBasket =  [SELECT Id,csordtelcoa__Order_Under_Change__c, csordtelcoa__Order_Under_Change__r.csord__Status2__c 
        FROM cscfga__Product_Basket__c
        WHERE Id =: BasketID];

        // Get All the Services 
        Map<Id, Map<String, String>> serviceConfigurationMap = new Map<Id, Map<String, String>>();
        for(csord__Service__c service : [SELECT Id,Name,csord__Order__c
            FROM csord__Service__c WHERE csord__Order__c =:inflightBasket.csordtelcoa__Order_Under_Change__c]){
            serviceConfigurationMap.put(service.id,new Map<String,String>
                { 
                   Label.AllowAmend =>'Amend Allowed'
                });
        } 
        System.debug('check serviceConfigurationMap >> ' + serviceConfigurationMap.size());
        if(serviceConfigurationMap.size() > 0){
            try{  
                Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(serviceConfigurationMap, 'BatchCheckNotRequired'), 1); 
                System.debug('PushHerokuConfigurationsBatch jobId: ' + jobId);
            } 
            catch(Exception ex){
                System.debug('Exception occoured '+ex);
            }
        }
    }
}