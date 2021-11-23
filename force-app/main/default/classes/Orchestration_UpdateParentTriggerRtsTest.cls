/**================================================================ 
 * Appirio, Inc 
 * Name: Orchestration_UpdateParentTriggerRtsTest   
 * Class: Orchestration_UpdateParentTriggerRts  
 * Created Date: May 21, 2020   
 * Created By: Shweta Khandelwal    
 ==================================================================
  Change.No.    Developer Name          Date          Story Description
  1.            Milos Djordjevic	    08-06-2021	  EDGE-222326 : Modified assert to check for empty list instead of null*/   
@isTest 
public class Orchestration_UpdateParentTriggerRtsTest { 
        
    @Testsetup  
    static void dataSetup() {   
        //Orchestration Processes list  
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();  
        //Process Templates for Processes   
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();    
        //List of Orchestration Steps which needs to be executed    
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();   
        //List of Accounts for order    
        List<account> accountList = new List<account>();    
        //Order request on Order    
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();   
        //List of Subscription  
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>(); 
        // List of Orders   
        List<csord__Order__c> orderList = new List<csord__Order__c>();  
        //Product Configuration List    
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();    
        //Solutions list    
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>(); 
        //Service List  
        List<csord__Service__c> servlist = new List<csord__Service__c>();   
        //Record to create the Custom Settings with Custom Limits   
        Governor_Limits__c governerLimit = new Governor_Limits__c();    
        //Record to attachment for services 
        list<Attachment> attachmentList = new List<Attachment>();   
        //Governor Limit Creation   
        governerLimit = Orchestration_TestUtility.buildLimits();    
        //Build Accounts to Store the Orders    
        accountList = Orchestration_TestUtility.buildAccount(false, 2); 
        accountList[1].Customer_Status__c = 'Acquired'; 
        insert accountList; 
        //Build Data to Perform Actions on  
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);    
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 4); 
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);  
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 2);  
        productconfiglistList[0].Type__c = 'Cancel';    
        productconfiglistList[1].ConfigurationType1__c = null;  
        insert productconfiglistList;   
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);    
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 4, accountList[0].id, orderList, productconfiglistList[1].id, solutionList[0].id);    
        subscriptionList[1].csord__Account__c = accountList[1].id;  
        subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;    
        subscriptionList[1].Trigger_RTS__c = true;  
        subscriptionList[2].Trigger_RTS__c = true;  
        subscriptionList[3].Trigger_RTS__c = true;  
        subscriptionList[0].csord__Status__c = 'Inactive';  
        subscriptionList[1].csord__Status__c = 'PaidOut';   
        subscriptionList[2].csord__Status__c = 'Inactive';  
        subscriptionList[3].csord__Status__c = 'PaidOut';   
        subscriptionList[2].csordtelcoa__Product_Configuration__c = null;   
        insert subscriptionList;    
        servlist = Orchestration_TestUtility.buildService(true, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);   
        attachmentList = Orchestration_TestUtility.buildAttachment(true, 2, servlist, productconfiglistList[0].id); 
        //Build Process Records through wich the Steps will be executed.    
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);  
        processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;   
        processList[2].csordtelcoa__Subscription__c = subscriptionList[2].id;   
        processList[3].csordtelcoa__Subscription__c = null; // Process where sub is null    
        insert processList; 
        orchStepList = Orchestration_TestUtility.buildOrchStep(true, 4, processList);   
    }   
    // When subscription's Trigger_RTS__c got updated   
    static testMethod void ProcessTest() {  
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();   
        List<Id> subscriptionIds = new List<Id>();  
        //Query from data stepup    
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c FROM CSPOFA__Orchestration_Step__c];   
        Test.startTest();   
        //First run of process creates the JSON step    
        Orchestration_UpdateParentTriggerRts updateParentTriggerRts = new Orchestration_UpdateParentTriggerRts();   
        orchStepList = updateParentTriggerRts.process(orchStepList);    
        //Second run excludes the records processed in first run    
        updateParentTriggerRts = new Orchestration_UpdateParentTriggerRts();    
        orchStepList = updateParentTriggerRts.process(orchStepList);    
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {   
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {   
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);    
            }   
        }   
        // QUery after processing and updation  
        List<csord__Subscription__c> subscriptionList = [SELECT Id, csord__Account__c, csord__Account__r.Customer_Status__c, Trigger_RTS__c FROM csord__Subscription__c WHERE csordtelcoa__Product_Configuration__r.ConfigurationType1__c = :OrchestratorConstants.ProductConfigType.SolutionComponent];    
        System.assertEquals(subscriptionList[0].Trigger_RTS__c, false); 
        Test.stopTest();    
    }   
        
    //Limit reached 
    static testMethod void breakingLimitsInStart() {    
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();   
        Governor_Limits__c governerLimit = new Governor_Limits__c();    
        //Query from data stepup    
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c]; 
        governerLimit.SOQL_limit__c = '0';  
        update governerLimit;   
        Test.startTest();   
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];  
        Orchestration_UpdateParentTriggerRts orderClass = new Orchestration_UpdateParentTriggerRts();   
        orchStepList = orderClass.process(orchStepList);    
        System.assert(orchStepList.isEmpty()); // Modified as part of EDGE-222326
        Test.stopTest();    
    }   
        
    // No steps to process  
    static testMethod void serviceProcessExceptionTest() {  
        Orchestration_UpdateParentTriggerRts orderClass = new Orchestration_UpdateParentTriggerRts();   
        Test.startTest();   
        try {   
            orderClass.process(null);   
        } catch (Exception ex) {    
            System.assert(String.isNotBlank(ex.getMessage()));  
        }   
        Test.stopTest();    
    }   
}