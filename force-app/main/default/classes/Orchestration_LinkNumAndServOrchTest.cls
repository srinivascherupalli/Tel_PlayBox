/**================================================================
* Appirio, Inc
* Name: Orchestration_LinkNumAndServOrchTest
* Main Class : Orchestration_LinkNumAndServOrchHandler
* Description: Class to update SIMSerailNumber and IMSI in service spec
* Created Date: May 27, 2020
* Created By: Shweta Khandelwal

1.  Prajakta       18/08/2020       EDGE-166432
2.  Gnana          26/02/2020       EDGE-170545 - Added test method
3.  Vaibhav         08-06-2021    EDGE-222326 : Modified assert to check for empty list instead of null
4.  Ila            26/07/2021       DPG-6193: Added for comments
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_LinkNumAndServOrchTest {
    
    //Test Data Setup
    @Testsetup static void dataSetup(){
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
        //Product Configuration Lis
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist0 = new List<csord__Service__c>();
        List<csord__Service__c> servlist1 = new List<csord__Service__c>();
        List<csord__Service__c> servlist2 = new List<csord__Service__c>();
        List<csord__Service__c> servlist3 = new List<csord__Service__c>();
        List<csord__Service__c> servlist4 = new List<csord__Service__c>();
        List<csord__Service__c> servlistAll = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0= new list<Attachment>();
        list<Attachment> attachmentList1= new list<Attachment>();
        list<Attachment> attachmentList2= new list<Attachment>();
        list<Attachment> attachmentList3= new list<Attachment>();
        //Record to create the number
        List<Number__c> numList = new List<Number__c>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true , 5);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(false,2);
        processTempList[0].Name='Order Fulfilment Process';
        processTempList[1].Name='Inflight Orchestration Process';
        insert processTempList;
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,1);        
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
       
        subscriptionList = Orchestration_TestUtility.buildSubscription(true,5,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);       
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist0= Orchestration_TestUtility.buildService(false,3,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        for(csord__Service__c service : servlist0){
         service.Scenario_Type__c = 'Transition';
         service.Action_Type__c = 'New'; //DPG-6193
         service.csord__Status__c='Pending';
        }
        //insert servlist0;
        servlistAll.addAll(servlist0);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist1 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[1].id, orderReqList[0].id, orderList[1].id, productconfiglistList[0].id);
        for(csord__Service__c service : servlist1){
         service.Scenario_Type__c = 'NotTransition';
        }
        //insert servlist1;
        servlistAll.addAll(servlist1);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist2 = Orchestration_TestUtility.buildService(true, 5, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[0].id);
        numList = Orchestration_TestUtility.buildNumber(false, 1, productconfiglistList, '455', 'subId1');
        numList[0].Mobile__c = 'Mobile';
        numList[0].Sim_Serial_Number__c = '1';
        numList[0].IMSI__c = 'IMSI text';
        numList[0].SIM_Type__c = 'SIM card'; //EDGE-166432
        numList[0].SimAvailabilityType__c = 'New SIM'; 
        numList[0].Service_Number__c = 'SVC-167778'; 
        insert numList;
        
        subscriptionList[3].Suspension_reason__c='Requested by Customer';
        update subscriptionList;
        
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist3 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[3].id, orderReqList[0].id, orderList[3].id, productconfiglistList[0].id);
        for(csord__Service__c service : servlist3){
         service.changeType__c = 'Suspend';
         service.Scenario_Type__c='Replace SIM';
        }
        //insert servlist3;
        servlistAll.addAll(servlist3);
        
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist4 = Orchestration_TestUtility.buildService(false, 1, subscriptionList[4].id, orderReqList[0].id, orderList[4].id, productconfiglistList[0].id);
        servlist4[0].name = 'Test Inflight Service 1';
        //insert servlist4;
        servlistAll.addAll(servlist4);
        insert servlistAll;
        
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist0[0].id);
        //processList[1].csordtelcoa__Service__c = servlist2[0].id;
        processList[4].CSPOFA__Orchestration_Process_Template__c = processTempList[1].id;
        processList[2].Order__c = null;
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
        orchStepList[1].CSPOFA__Orchestration_Process__c = processList[1].Id;
        orchStepList[0].JSON__c = '{"orderIds":["'+orderList[0].id+'"]}';
        orchStepList[1].JSON__c = '{"orderIds":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"orderIds":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"orderIds":["'+orderList[3].id+'"]}';
        orchStepList[4].JSON__c = '{"orderIds":["'+orderList[4].id+'"]}';
        orchStepList[4].name = 'Test Inflight Order 1';
        insert orchStepList;
        
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(true,2,servlist0,productconfiglistList[0].id);   
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList1 = Orchestration_TestUtility.buildAttachment(true,2,servlist1,productconfiglistList[0].id);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList1 = Orchestration_TestUtility.buildAttachment(true,2,servlist2,productconfiglistList[0].id);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList3 = Orchestration_TestUtility.buildAttachment(true,1,servlist4,productconfiglistList[0].id);
    }

     @isTest
 static void ProcessTest() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number__c> numList = new List<Number__c>();
        List<csord__Service__c> service = new List<csord__Service__c>();
        List<Attachment> attachments = new List<Attachment>();
        Map<String, Object> tempAdditionalAttMap = new Map<String, Object>();
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        JSON__c,CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c WHERE Name = 'Test Inflight Order 1'];
        
        service = [SELECT Id, Name,csordtelcoa__Service_Number__c
                   FROM csord__Service__c WHERE Name = 'Test Inflight Service 1'];
        
        attachments = [SELECT Id, body FROM Attachment WHERE ParentId = :service[0].Id];
        for(Attachment att : attachments){
         att.body = Blob.valueOf('{ "legacyAttributes":[ ], "serviceId":"", "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000190_Fulfilment", "__targetSystem":"FULFILMENT", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "description":"", "endDate":"", "guid":"963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"Disconnect In Progress", "version":"1" } ] }');
        }
        update attachments;
        numList = [SELECT ID, Product_Configuration__c FROM Number__c];
        numList[0].Service_Id__c = service[0].csordtelcoa__Service_Number__c;
        update numList;                        
        
        Test.startTest();
        Orchestration_LinkNumAndServOrchHandler linkNumServ = new Orchestration_LinkNumAndServOrchHandler();
        orchStepList = linkNumServ.process(orchStepList); 
        Attachment attReplacedService = [SELECT ID, name, body, parentId FROM Attachment LIMIT 1];  
        String serviceattachmentstr = attReplacedService.body.toString();
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
        List<Object> lstSpecifications = (List<Object>)results.get('specifications');
     for(Integer i=0 ; i<lstSpecifications.size();i++){
          Map<String, Object> specificationAttributes = (Map<String, Object>)lstSpecifications[i];
         if (specificationAttributes.containsKey('additionalAttributes')) {
           tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
        }
          System.debug('tempAdditionalAttMap '+i+' '+tempAdditionalAttMap);
     }
      /*  Map<String, Object> specificationAttributes = (Map<String, Object>)lstSpecifications[0];
        if (specificationAttributes.containsKey('additionalAttributes')) {
           tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
        }       
        System.debug('tempAdditionalAttMap '+tempAdditionalAttMap);*/
        //Assert To check specification is added sucessfully or not
       System.assertNotEquals(serviceattachmentstr,null); 
      //  System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Additional Attributes added on the Service Specs');
      //  System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Success: Processing is not required on the order');
      // System.assertEquals(orchStepList[1].CSPOFA__Status__c, 'Complete');
      //  System.assertEquals(orchStepList[2].CSPOFA__Message__c, 'Error: Steps do not have Orders');
        //System.assertEquals(orchStepList[0].CSPOFA__Status__c, 'Complete');
      //  System.assertEquals(orchStepList[2].CSPOFA__Status__c, 'Error');

        Test.stopTest();
    }
    
    //Run class without any limits left
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_LinkNumAndServOrchHandler linkNumServ = new Orchestration_LinkNumAndServOrchHandler();
        orchStepList = linkNumServ.process(orchStepList);         
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true, 'No Steps returned as Limit Reached.');
        Test.stopTest();
    }
    
    //Run class without any limits left DML limite
    static testMethod void breakingLimitsInStartDML(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c,DML_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_limit__c = '1';
        update governerLimit; 

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_LinkNumAndServOrchHandler linkNumServ = new Orchestration_LinkNumAndServOrchHandler();
        orchStepList = linkNumServ.process(orchStepList);         
        //No Steps will be returned and nothing will be updated as Limits were reached
        //System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Processing is not required on the order');
        System.assertEquals(false, orchStepList.isEmpty());
        Test.stopTest();
    }
    //Partial records processed
    static testMethod void breakingLimitsInDMLLimit(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number__c> numList = new List<Number__c>();
        List<csord__Service__c> service = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c,DML_limit__c,CPU_limit__c,DML_Rows_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '2';
    
        update governerLimit; 

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,JSON__c
                        FROM CSPOFA__Orchestration_Step__c];
        service = [SELECT Id, Name,csordtelcoa__Service_Number__c
                   FROM csord__Service__c];
        numList = [SELECT ID, Product_Configuration__c FROM Number__c];
        numList[0].Service_Id__c = service[0].csordtelcoa__Service_Number__c;
        update numList;
        Orchestration_LinkNumAndServOrchHandler linkNumServ = new Orchestration_LinkNumAndServOrchHandler();
        orchStepList = linkNumServ.process(orchStepList);       
       
        //System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
        System.assertNotEquals(orchStepList,null); 
        //System.assertEquals(false, service.isEmpty());

        Test.stopTest();
    }
    
    // EDGE-170545 - Addeded this test method
    @isTest
    static void ProcessTest_InflightOrder() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number__c> numList = new List<Number__c>();
        List<csord__Service__c> service = new List<csord__Service__c>();
        List<Attachment> attachments = new List<Attachment>();
        Map<String, Object> tempAdditionalAttMap = new Map<String, Object>();
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        JSON__c,CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        
        service = [SELECT Id, Name,csordtelcoa__Service_Number__c
                   FROM csord__Service__c];
        
        attachments = [SELECT Id, body FROM Attachment];
        for(Attachment att : attachments){
            att.body = Blob.valueOf('{ "legacyAttributes":[ ], "serviceId":"", "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000190_Fulfilment", "__targetSystem":"FULFILMENT", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "description":"", "endDate":"", "guid":"963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"Disconnect In Progress", "version":"1" } ] }');
        }
        update attachments;
        numList = [SELECT ID, Product_Configuration__c FROM Number__c];
        numList[0].Service_Id__c = service[0].csordtelcoa__Service_Number__c;
        update numList;                        
        
        Test.startTest();
        Orchestration_LinkNumAndServOrchHandler linkNumServ = new Orchestration_LinkNumAndServOrchHandler();
        orchStepList = linkNumServ.process(orchStepList); 
        Attachment attReplacedService = [SELECT ID, name, body, parentId FROM Attachment LIMIT 1];  
        String serviceattachmentstr = attReplacedService.body.toString();
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
        List<Object> lstSpecifications = (List<Object>)results.get('specifications');
        for(Integer i=0 ; i<lstSpecifications.size();i++){
            Map<String, Object> specificationAttributes = (Map<String, Object>)lstSpecifications[i];
            if (specificationAttributes.containsKey('additionalAttributes')) {
                tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
            }
            System.debug('tempAdditionalAttMap '+i+' '+tempAdditionalAttMap);
        }
        System.assertNotEquals(serviceattachmentstr,null); 
        Test.stopTest();
    }

}