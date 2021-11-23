/* 
Author : Abinash Barik 
Company : Telstra
Description : EDGE-80870 Reverse Logistics
History : Initail Version 09/25/2019

===============================================
ChagneSet No    Name            Date                    Description
*/
public with sharing class DeviceReplacementOrchestrationProcess {
    // This method is used for Scenario Type "Device replacement" for subscription and 
    // Service if any one of the service under order has scenario type "Device replacement" and Metadata is false 
    public Static boolean isDeviceReplacementOrchestrationProcess(List<csord__Service__c> serviceSubsList){
        boolean isOrchestrationProcess = true;
        List<Orchestration_Config__mdt> lstconFig = [SELECT id,developername,label,Run_Service_Orchestration__c,
                                                     Run_Subscription_Orchestration__c FROM Orchestration_Config__mdt
                                                     WHERE label=:Label.Device_Replacement limit 1];
        system.debug('serviceSubsList>>>>>>>'+serviceSubsList);
        system.debug('lstconFig>>>>>>>'+lstconFig);
        if(!serviceSubsList.isEmpty() && !lstconFig.isEmpty() && 
          (lstconFig[0].Run_Service_Orchestration__c==false || lstconFig[0].Run_Subscription_Orchestration__c==false)){            
            for(csord__Service__c sub : serviceSubsList){
                if(sub.Scenario_Type__c == Label.Device_Replacement){
                    isOrchestrationProcess = false;
                }
            }
        }
        return isOrchestrationProcess;
    }

}