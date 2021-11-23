/*******************************************************************************************************************
Name : PushHerokuConfigurationsBatch
Test Class: PushHerokuConfigurationsBatchTest
Description : To Update the configuration values to Heroku.
Sr.No.    Developer Name            Date                  Story Description
1.         Martand                  08/02/2021               EDGE-201336         
2.         Shweta & Arinjay         18/02/2021 
3.         Venkat T                 04/03/2021               EDGE-207635 Defect fix                                       
********************************************************************************************************************/
public class PushHerokuConfigurationsBatch implements Database.Batchable<csord__Service__c>, Database.AllowsCallouts{
    private Set<Id> serviceIds = new Set<Id>();
    private Map<Id, Map<String, String>> serviceConfigurationMap = new Map<Id, Map<String, String>>();
    /* '0001' => {
        'AllowAmend' => ''
        'AllowRemediation' => ''
        
    },
    '0002' => {
        'AllowAmend' => ''
    },

    '0003' => {
        'AllowAmend' => ''
    } */
    private String saveJobId;

    public PushHerokuConfigurationsBatch(Set<Id> serviceIds, String saveJobId) {
        this.serviceIds = serviceIds;
        this.saveJobId = saveJobId;
    }
    public PushHerokuConfigurationsBatch(Map<Id, Map<String, String>> serviceConfigurationMap, String saveJobId) {
        this.serviceIds = serviceConfigurationMap.keySet();
        this.saveJobId = saveJobId;
        this.serviceConfigurationMap = serviceConfigurationMap;
    }

    public List<csord__Service__c> start(Database.BatchableContext BC){
        List<csord__Service__c> serviceList = [SELECT Id, csord__Order__c, csord__Subscription__r.csord__Status__c,cssdm__solution_association__c,csordtelcoa__Product_Configuration__r.configGUID__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c,csord__Status__c FROM csord__Service__c WHERE Id IN :serviceIds];   //EDGE-207635  added csord__Status__c  
        try{
            if((new List<String>{'UpdateRemediationFlag','SaveJobId'}).contains(saveJobId) && !serviceList.isEmpty()){
                Id batchJobId = BC.getJobId();
                update new csord__Order__c(Id = serviceList[0].csord__Order__c, Push_Heroku_Configurations_Job_Id__c = batchJobId);//update the order with Batch job Id
            }
        } catch(Exception ex){
            System.debug('PushHerokuConfigurationsBatch.start ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString());
        }
        return serviceList;
    }

    public void execute(Database.BatchableContext BC, List<csord__Service__c> scope){
        try {
            for(csord__Service__c service : scope){
                if(serviceConfigurationMap != null && serviceConfigurationMap.size() > 0 )
                {
                    System.debug('inside execute >> ' + serviceConfigurationMap.size());
                    InflightBasketUtility.pushConfigurationstoHeroku(new Map<Id, csord__Service__c>{ service.Id => service},
                            serviceConfigurationMap );
                }
                else
                    InflightBasketUtility.pushConfigurationstoHeroku(new Map<Id, csord__Service__c>{ service.Id => service} );
            }
        } catch(Exception ex){
            System.debug('PushHerokuConfigurationsBatch.execute ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext BC){
        try{
             List<csord__Service__c> serviceList = [SELECT Id, csord__Order__c,cssdm__solution_association__c,csordtelcoa__Product_Configuration__r.configGUID__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c,csord__Status__c FROM csord__Service__c WHERE Id IN :serviceIds LIMIT 1];  //EDGE-207635  added csord__Status__c 
            if((new List<String>{'UpdateRemediationFlag','SaveJobId'}).contains(saveJobId) && !serviceList.isEmpty()){
                Id batchJobId = BC.getJobId();
                update new csord__Order__c(Id = serviceList[0].csord__Order__c, Push_Heroku_Configurations_Job_Id__c = '');
            }
        } catch(Exception ex){
             System.debug('PushHerokuConfigurationsBatch.finish ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString());
        }
    }
}