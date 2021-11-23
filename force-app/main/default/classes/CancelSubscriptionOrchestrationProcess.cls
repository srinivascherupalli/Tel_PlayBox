/*
  **********************************************************************************************
  * @author       : Resmi Ramakrishnan
  * @date         : 29/11/2016
  * @description  :  This class is using to create cancel subscription processes.
  **********************************************************************************************
*/

public class CancelSubscriptionOrchestrationProcess
{ 


    /*
      * @description       This is method is using for creating orchestration process.                       
      * @param             NA 
      * @return            boolean
      * @throws            NA
    */       
    public static boolean createCancellationOrchProcesses(List<csord__Subscription__c> subscriptionList ) 
    {   
        Map<String,csord__Subscription__c> allSubscriptionMap = new Map<String,csord__Subscription__c>();  
        List<CSPOFA__Orchestration_Process__c> orchestrationProcessList = new List<CSPOFA__Orchestration_Process__c>();
        
        CSPOFA__Orchestration_Process__c orcProcessOverAll = new CSPOFA__Orchestration_Process__c();
        try
        {  
            if(  subscriptionList != null && !subscriptionList.isEmpty())
            {       
                for( csord__Subscription__c subObj:subscriptionList )
                {               
                    allSubscriptionMap.put(subObj.id,subObj); 
                    for( csord__Subscription__c childSubObj:subObj.Subscriptions__r)
                    {
                       allSubscriptionMap.put(childSubObj.id,childSubObj);
                    }                           
                }
                                                
                if( !allSubscriptionMap.isEmpty())
                {                        
                  orcProcessOverAll =  buildOrchProcess(getOverAllOrchProcessTemplate(), null, 'SUBSCRIPTION_CANCEL'+'PARENT', null);  
                  
                  if( orcProcessOverAll  != null)
                  {
                      insert orcProcessOverAll;  
                  }
                                 
                  for(csord__Subscription__c sc : allSubscriptionMap.values()) 
                  {
                    if( sc != null )
                    {
                        CSPOFA__Orchestration_Process__c orcProcessSubscriptn = new CSPOFA__Orchestration_Process__c();
                        orcProcessSubscriptn = buildOrchProcess(getSubscriptionOrchProcessTemplate(),orcProcessOverAll.id, 'SUBSCRIPTION_CANCEL' + sc.name, sc);
                        orchestrationProcessList.add(orcProcessSubscriptn);
                    }
                  }                            
                }
                
                if( !orchestrationProcessList.isEmpty())
                {
                   insert orchestrationProcessList;
                }
                                                               
                if( orcProcessOverAll != null )
                {
                    orcProcessOverAll.CSPOFA__Process_On_Hold__c  = false;
                    update orcProcessOverAll; 
                }
                return true;
            }
            else
            {
               return false;
            }
         }
         catch( Exception Ex )
         {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
            return false;
         }         
    }
    
    
    /*
      * @description       This is method is using for getting orchestration Process Template for creating
                           overAll orchestration process.                       
      * @param             NA 
      * @return            CSPOFA__Orchestration_Process_Template__c 
      * @throws            NA
    */  
    public static CSPOFA__Orchestration_Process_Template__c getOverAllOrchProcessTemplate()
    {
       CSPOFA__Orchestration_Process_Template__c overAllTemplateObj = [SELECT id,Name FROM CSPOFA__Orchestration_Process_Template__c where Name='Overall Cancellation Tracking'];
       return overAllTemplateObj ;
    }
    
    
    /*
      * @description       This is method is using for getting orchestration Process Template for creating
                           child orchestration process.                       
      * @param             NA 
      * @return            CSPOFA__Orchestration_Process_Template__c 
      * @throws            NA
    */  
    public static CSPOFA__Orchestration_Process_Template__c getSubscriptionOrchProcessTemplate()
    {
       CSPOFA__Orchestration_Process_Template__c subscriptionTemplateObj = [SELECT id,Name FROM CSPOFA__Orchestration_Process_Template__c where Name='Subscription Cancellation'];
       return subscriptionTemplateObj ;
    }
    
    
    /*
      * @description       This is method builds overall and child orchestration process.                       
      * @param             NA 
      * @return            CSPOFA__Orchestration_Process__c 
      * @throws            NA
    */ 
    public static CSPOFA__Orchestration_Process__c buildOrchProcess(CSPOFA__Orchestration_Process_Template__c template, String pID, String processName, csord__Subscription__c sub)
    {
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = processName;
        orchProcess.has_Inactive_Children__c = 'NA';
        if(sub != null)
         {
            orchProcess.csordtelcoa__Subscription__c = sub.id;
        }
        orchProcess.Parent_Orchestration_Process__c = pID;
        orchProcess.CSPOFA__Orchestration_Process_Template__c = template.Id;
        orchProcess.CSPOFA__Process_Type__c = Constants.orchestrationProcess_type_Cease;
        orchProcess.CSPOFA__Process_On_Hold__c = true;
        orchProcess.Overall_Cancellation_Status__c= 'NA';
        return orchProcess;
    }            
}