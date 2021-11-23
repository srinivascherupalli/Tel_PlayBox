/*
===============================================================================================================================
Class : SubmitOrderOrchestration
Developer Name :
Test Class : c
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  21/3/2018     Edge-53883 Order Submission for Sim Replacement for Assurance service agen Profile  
2.        V Ravi Shankar      5/7/2019      Edge-88033 Port In requirements. Check for validity of CA form.
3.        Shubhi Vijay	    21/08/2019      EDGE-81113 MDM migration order
4.        Vaibhav Deshpande   02/11/2020    EDGE-181982 order orch process for multiple orders
5.        Gautam Kumar.       20/10/2021    DIGI-11210 Transaction Logs on order submission
===============================================================================================================================
*/
global with sharing class SubmitOrderOrchestration {
    @AuraEnabled
    webservice static void createOrderOrchestrationProcess(String orderIds){
        
        //Start of DIGI-11210 added by Gautam Kumar
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs_OrderSubmit','orderSubmitInitiated')){
            insertOrderSubmissionLogs(orderIds);  
        }
        //End of DIGI-11210 added by Gautam Kumar
        
        List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();
        String orderProcessName = '';
		Boolean isComsUpliftment = false;
        isComsUpliftment = FeatureToggle__mdt.getInstance('Orchestration_ComsUpliftment').EnableForAll__c;
        
        if(isComsUpliftment == true){
              orderProcessName = 'Order Fulfilment Process_New';
        }
        else{
             orderProcessName = 'Order Fulfilment Process';}
        /*If([Select id,Change__c from csord__Order__c where id = :orderIds].ModelChange__c){
orderProcessName = 'Migration Order Fulfillment Process';
}else{*/ //commented for Edge-81113 for migration orders
        //orderProcessName = 'Order Fulfilment Process';
        //}
        List<CSPOFA__Orchestration_Process_Template__c> processTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name like  :orderProcessName  LIMIT 1];
       System.debug('processTemplates...'+processTemplates);
        CSPOFA__Orchestration_Process_Template__c processTemplate = null;
        if(!processTemplates.isEmpty()){
            processTemplate = processTemplates[0];
        }
        system.debug('OrderIds..'+orderIds+'    '+'processTemplate...'+processTemplate);
        if(orderIds != null && processTemplate.Id != null){
            CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
            newProcess.CSPOFA__Orchestration_Process_Template__c = processTemplate.Id;
            newProcess.Order__c = orderIds;
            newProcess.CSPOFA__State__c = 'Active';
            
            newProcesses.add(newProcess);
            
        }
        
        if(!newProcesses.isEmpty()){
            insert newProcesses;
        }
        //Edge-28586
        List<Id> serviceIds = new List<Id>();
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        List<RecordType> orderRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
        
        for(RecordType recObj:orderRecordTypeList)
        {
            recordTypeMap.put(recObj.Name,recObj.Id);          
        }
        System.debug('*****recordTypeMap Size:' + recordTypeMap.size()+recordTypeMap+recordTypeMap.keySet());
        
        //csord__Order__c orderRequest =[Select id,csord__Order_Request__c from csord__Order__c where id = :orderIds LIMIT 1];
        //removing primary order 
        //EDGE-181099 Gunjan
        List<csord__Order__c> PrimaryOrderList = [select id, name, csordtelcoa__Opportunity__c,telstra_ord_Start_DateTime__c , 
                                                  Scenario_Type__c, 
                                                  Action_Type__c FROM csord__Order__c WHERE id =:orderIds];
        
        //sr1. added csord__Order__r.csord__Primary_Order__c to support sim replacement
        /* List<csord__Service__c> serviceList = [SELECT id,Name,Appointment_Required__c,csord__Order__c,csord__Order__r.csordtelcoa__Opportunity__c, csord__Order__r.csord__Primary_Order__c FROM csord__Service__c where csord__Order__c =: PrimaryOrderList[0].id];*/
        List<csord__Service__c> serviceList = [SELECT id,Name,Appointment_Required__c,csord__Order__c,csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c where csord__Order__c =: PrimaryOrderList[0].id];
        
        for(csord__Service__c services : serviceList){
            serviceIds.add(services.Id);
        }
        system.debug('serviceIds ::'+serviceIds);
        // List<csord__Order__c> PrimaryOrderList = [select id, name FROM csord__Order__c WHERE id =:orderIds];
        /*List<csord__Order__c> SecondaryOrderList = [select id, name, 
Scenario_Type__c,
Action_Type__c, csord__Primary_Order__c, csord__Primary_Order__r.Action_Type__c FROM csord__Order__c WHERE (Id IN:PrimaryOrderList OR csord__Primary_Order__c IN:PrimaryOrderList)];*/
        
        
        for(csord__Order__c orderObj:PrimaryOrderList){
            //added System.label.ReplaceSIM for bug EDGE-89345
            
            if(serviceIds.size()>0 && orderObj.Scenario_Type__c!=System.label.ReplaceSIM){  
                orderObj.RecordTypeId = recordTypeMap.get('Order Submitted with Appointment');
                orderObj.csord__Status2__c = Label.OrderStatus;
            } 
            else{
                orderObj.RecordTypeId = recordTypeMap.get('Order Submitted');
                orderObj.csord__Status2__c = Label.OrderStatus;
            }
            //EDGE-181099 Gunjan
            orderObj.telstra_ord_Start_DateTime__c = System.Now();
        }
        //commenting bcz of primary order remove
        /*for(csord__Order__c orderObj1:SecondaryOrderList){
orderObj1.csord__Status2__c = 'Pending';
}
*/
        if( !PrimaryOrderList.isEmpty())
        {
            update PrimaryOrderList;
            System.debug('*****Primary Order List Updated' +PrimaryOrderList);
        }
        //commenting bcz of primary order remove
        /* if( !SecondaryOrderList.isEmpty())
{
update SecondaryOrderList;
System.debug('*****Primary Order List Updated' +SecondaryOrderList);
}
*/
        FunctionalContactRoleOperation.upsertFunctionalContactRole(serviceIds);     
    }
    @AuraEnabled
    public static Boolean isPortInValid(Id optyId){ //EDGE-88033 check for validity of CA form
        Boolean isValid = true;
        if(optyId!=null){
            List<Customer_Authority_Form__c> caFormLst = [SELECT Id, Customer_Authorised_date__c FROM Customer_Authority_Form__c WHERE Is_active__c = TRUE AND Opportunity__c = :optyId];
            if(caFormLst != null && caFormLst.size()>0){
                if(caFormLst[0].Customer_Authorised_date__c != null && (Date.today()).daysBetween(caFormLst[0].Customer_Authorised_date__c.addDays(30)) < Integer.valueOf(Label.PortInCAFormValidity))
                    isValid = false;
            }
        }   
        return isValid;
    }
    /*-------------------------------------------------------------------------------
EDGE        -150285
Method      -checkPortOutReversalOrderCaForm
Description -To Check CA form exist or not for Port out reversal order
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------*/
    @AuraEnabled
    public static boolean checkPortOutReversalOrderCaForm(Id opportunityId){
        Boolean isCaFormPresent=true;
        List<cscfga__Product_Basket__c> basketList=[SELECT id,Primary_Basket__c,cscfga__Opportunity__c, 
                                                    (SELECT id,Type__c,Basket__c,Service_Id__c FROM Numbers__r 
                                                     WHERE Type__c =:label.PortOutReversal AND Product_Configuration__c != NULL) 
                                                    FROM cscfga__Product_Basket__c WHERE  cscfga__Opportunity__c =:opportunityId 
                                                    AND Primary_Basket__c =: True LIMIT 1];
        if(!basketList.isEmpty() && !basketList[0].Numbers__r.isEmpty()){
            List<Customer_Authority_Form__c> caFormList = [SELECT Id, Customer_Authorised_date__c FROM Customer_Authority_Form__c 
                                                          WHERE Is_active__c = TRUE AND Opportunity__c = :opportunityId];
            if(caFormList.isEmpty()){
                isCaFormPresent=false;  
            }
        }
        return isCaFormPresent;
        
    }
     /*-------------------------------------------------------------------------------
EDGE        -149259
Method      -isPortinPpvApproved
Description -To Check CA is signed and PPV approved
Author      -Aishwarya Yeware
---------------------------------------------------------------------------------*/
    @AuraEnabled
    public static boolean isPortinPpvApproved(Id opportunityId){
        Boolean isPpvApproved=true;
        List<cscfga__Product_Basket__c> basketList=[SELECT id,Primary_Basket__c,cscfga__Opportunity__c, 
                                                    (SELECT id,Type__c,Basket__c,Service_Id__c FROM Numbers__r 
                                                     WHERE Type__c =:label.PortinOrder AND Product_Configuration__c != NULL) 
                                                    FROM cscfga__Product_Basket__c WHERE  cscfga__Opportunity__c =:opportunityId 
                                                    AND Primary_Basket__c =: True LIMIT 1];
        if(!basketList.isEmpty() && !basketList[0].Numbers__r.isEmpty()){
            List<Customer_Authority_Form__c> caFormList = [SELECT Id, Customer_Authorised_date__c FROM Customer_Authority_Form__c 
                                                          WHERE Is_active__c = TRUE AND Opportunity__c = :opportunityId 
                                                          AND PPV_status__c= :label.PPVStatus];
            if(caFormList.isEmpty() && isPortInValid(opportunityId)){
                isPpvApproved=false;  
            }
        }
        return isPpvApproved;
        
    }
     /*-------------------------------------------------------------------------------
EDGE        -181982
Method      -createOrderOrchestrationProcessBulk
Description -to order order fulfilment orch process for multiple orders
Author      -Vaibhav 
---------------------------------------------------------------------------------*/ 
    public static void createOrderOrchestrationProcessBulk(Map<Id,csord__Order__c> OrderMap){
        List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();
        String orderProcessName; 
		//coms upliftment
        Boolean isComsUpliftment = false;
        isComsUpliftment = FeatureToggle__mdt.getInstance('Orchestration_ComsUpliftment').EnableForAll__c;
        
        if(isComsUpliftment == true){
              orderProcessName = 'Order Fulfilment Process_New';
        }
        else{
             orderProcessName = 'Order Fulfilment Process';}
        List<CSPOFA__Orchestration_Process_Template__c> processTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name like  :orderProcessName  LIMIT 1];
        System.debug('processTemplates...'+processTemplates);
        CSPOFA__Orchestration_Process_Template__c processTemplate = null;
        if(!processTemplates.isEmpty()){
            processTemplate = processTemplates[0];
        }
        system.debug('processTemplate...'+processTemplate);
            for(csord__Order__c ord : OrderMap.values()){
                CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
                newProcess.CSPOFA__Orchestration_Process_Template__c = processTemplate.Id;
                newProcess.Order__c = ord.id;
                newProcess.CSPOFA__State__c = 'Active';
                newProcesses.add(newProcess);
            }
       
        if(!newProcesses.isEmpty()){
            insert newProcesses;
        }
       
    }
    /*-------------------------------------------------------------------------------
EDGE        -170965
Method      -isNotificationCreated
Description -To Check if notification prefernces records created for order
Author      -Aishwarya
---------------------------------------------------------------------------------*/
   @AuraEnabled
    public static boolean isNotificationCreated(String orderIds){
        Boolean isNotificationCreated=false;
        system.debug('orderIds ::'+orderIds);
        if(orderIds != Null){
              		List<Notification_Preference__c> listOfNotificationRecords=[SELECT id,Contact_Id__c,Service_Id__c from Notification_Preference__c WHERE Service_Id__r.csord__Order__c = :orderIds];
		 system.debug('listOfNotificationRecords ::'+listOfNotificationRecords);
            if(!listOfNotificationRecords.isEmpty()){
                isNotificationCreated=true;  
            }
        }
        return isNotificationCreated;
        
    }
    
    
    /*  
    * Method Name : insertOrderSubmissionLogs
    * Author : Gautam Kumar
    * Jira : DIGI-11210
   */
    
    private static void insertOrderSubmissionLogs(String orderId){
        system.debug('G*G insertOrderSubmissionLogs outer called');
        if(String.isNotBlank(orderId)){
            
            Set<String> orderIdSet = new Set<String>(); 
            orderIdSet.add(orderId);
            List<csord__Order__c> orderList = Model_Order.getOrdersList(orderIdSet);
            
            if(!orderList.isEmpty()){
                system.debug('G*G insertOrderSubmissionLogs called');
                for(csord__Order__c order : orderList){
                    if(order.csordtelcoa__Opportunity__c != null && order.Product_Basket__c != null){
                        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                    //Trim Product Basket from 18 digit to 15 digit
                     String ProductBasketId = order.Product_Basket__c!= null && String.ValueOf(order.Product_Basket__c).length()>= 15?
                     String.ValueOf(order.Product_Basket__c).subString(0,15) : '';
                     string correlationId = order.csordtelcoa__Opportunity__c+'-'+ProductBasketId;
                   //string correlationId = order.csordtelcoa__Opportunity__c+'-'+order.Product_Basket__c;
                                          
                        loggerdetailsMap.put('event','Order submission initiated');
                        loggerdetailsMap.put('OrderType',order.csordtelcoa__Opportunity__r.Type);
                        loggerdetailsMap.put('OrderStatus','Submitting');
                        loggerdetailsMap.put('OrderId',order.Id);
                        TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'SubmitOrderOrchestration');
                    }
                }
            }
        }
        
    }
}