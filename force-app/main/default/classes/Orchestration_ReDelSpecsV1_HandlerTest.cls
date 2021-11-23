@isTest
public class Orchestration_ReDelSpecsV1_HandlerTest {
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
        //Product Configuration Lis
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist0 = new List<csord__Service__c>();
        List<csord__Service__c> servlist1 = new List<csord__Service__c>();
        List<csord__Service__c> servlist2 = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0 = new List<Attachment>();
        list<Attachment> attachmentList1 = new List<Attachment>();
        list<Attachment> attachmentList2 = new List<Attachment>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 3);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 3, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist0 = Orchestration_TestUtility.buildServiceWOReplace(true, 3, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        //servlist2 = Orchestration_TestUtility.buildServiceWOReplace(false, 3, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[0].id);
        servlist0[1].csordtelcoa__Replaced_Service__c = servlist0[2].Id;
        servlist0[2].csordtelcoa__Replaced_Service__c = servlist0[1].Id;
        servlist0[0].csordtelcoa__Replaced_Service__c = servlist0[1].Id;
        //servlist0[1].csordtelcoa__Replaced_Service__c = servlist0[2].Id;
        //servlist0[2].csordtelcoa__Replaced_Service__c = servlist0[0].Id;
        update servlist0;
        /*servlist2[0].csordtelcoa__Replaced_Service__c = servlist0[1].Id;
        servlist2[1].csordtelcoa__Replaced_Service__c = servlist0[2].Id;
        servlist2[2].csordtelcoa__Replaced_Service__c = servlist0[0].Id;
        
        insert servlist2;*/
       // List<Orchestration_Technical__c>technicalObj= new List<Orchestration_Technical__c>();
       // for(Integer i=0;i< 2 ;i++){
            Orchestration_Technical__c techObj = new Orchestration_Technical__c();
            techObj.Field_5__c=String.valueOf(servlist0[1].id);            
            techObj.Service__c=servlist0[1].id;
                techObj.Field_8__c='test Obj 0';
            techObj.Field_14__c='DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3';
            techObj.Field_11__c='Attach0GUID';
          //  technicalObj.add(techObj);
       // }
        
        //technicalObj[1].Service__c=servlist0[0].id;
        insert techObj;
        Orchestration_Technical__c techObj1 = new Orchestration_Technical__c();
            techObj1.Field_5__c=String.valueOf(servlist0[0].id);            
            techObj1.Service__c=servlist0[0].id;
        techObj1.Field_8__c='test Obj 1';
            techObj1.Field_14__c='DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3';
            techObj1.Field_11__c='Attach0GUID';
        insert techObj1;
        
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist0[0].id);
        processList[1].csordtelcoa__Service__c = servlist0[1].id;
        processList[2].Order__c = orderList[0].id;
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 3, processList);
        orchStepList[1].CSPOFA__Orchestration_Process__c = processList[1].Id;
        orchStepList[0].JSON__c = '{"orderIds":["' + orderList[0].id + '"]}';
        orchStepList[1].JSON__c = '{"orderIds":["' + orderList[0].id + '"]}';
        orchStepList[2].JSON__c = '{"orderIds":["' + orderList[0].id + '"]}';
        
        insert orchStepList;
        
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(true, 2, servlist0, productconfiglistList[0].id);
        
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        //attachmentList2 = Orchestration_TestUtility.buildAttachment(true, 2, servlist2, productconfiglistList[0].id);
        
        
        
        /*List<Orchestration_Technical__c>technicalObj1= new List<Orchestration_Technical__c>();
        for(Integer i=0;i< 3 ;i++){
            Orchestration_Technical__c techObj = new Orchestration_Technical__c();
            techObj.Field_5__c=String.valueOf(servlist2[0].id);            
            techObj.Service__c=servlist2[0].id;
            techObj.Field_14__c='DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3';
            techObj.Field_11__c='Attach0GUID';
            technicalObj1.add(techObj);
        }
        insert technicalObj1;*/
        
        /*set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c serv: servlist0) {
            lstServiceId.add(serv.Id);
        }
        
        
        
        Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(lstServiceId, orderList[0].id);*/
        
        /*set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c serv: servlist0) {
            lstServiceId.add(serv.Id);
        }
        
        Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(lstServiceId, orderList[2].id);*/
        /*for(Id ord:orderIds){           
            Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(servlist0, orderList[0].id);
        }*/
    }
    

    static testMethod void ProcessTest() {
        
        String str='';
        Set<Id>orderIds=new Set<Id>();
        List<Id> orderIdsList = new List<Id>();
        
        Map<String,Object>payloadMap=new Map<String,Object>();
        
        /*List<CSPOFA__Orchestration_Step__c> stepList = [
SELECT Id, Name, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, 
CSPOFA__Orchestration_Process__r.Order__c,JSON__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, CSPOFA__Step_Order__c
FROM CSPOFA__Orchestration_Step__c];*/
        
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        list<Attachment> attachmentList = new List<Attachment>();
        //csord__Service__c service = new csord__Service__c();
        orchStepList = [
            SELECT
            ID,
            Name,
            CSPOFA__Orchestration_Process__c,
            CSPOFA__Status__c,
            CSPOFA__Completed_Date__c,
            JSON__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csordtelcoa__Replaced_Service__c,
            CSPOFA__Message__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
            CSPOFA__Orchestration_Process__r.cspofa__account__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
            CSPOFA__Orchestration_Process__r.Order__c,
            CSPOFA__Step_Order__c
            FROM CSPOFA__Orchestration_Step__c
        ];
        
        //system.debug('orchStepList...........'+orchStepList);
        
        /*if (orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c != null && !orderIds.contains(orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c)) {
orderIds.add(orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c);
}*/		
        CSPOFA__Orchestration_Step__c orchStep;
        csord__Service__c service = [
            SELECT Id, Name, csord__Order__c, CorrelationId__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate
            FROM csord__Service__c
            WHERE name = 'testService 1'
            LIMIT 1
        ];
        
        //system.debug('replaced serv...........'+'>>>'+service.csordtelcoa__Replaced_Service__r.Id+'>>>'+service.csord__Order__c+'>>>'+service.csordtelcoa__Replaced_Service__c);
        
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null && !orderIds.contains(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                
            }
            
            if(service.csord__Order__c == step.CSPOFA__Orchestration_Process__r.Order__c) 
                orchStep = step;
        }
        
        system.debug('orderIds..............'+orderIds);
        
        attachmentList = [SELECT ID, body FROM Attachment];

                 
         
        /*
        ////Added by OB
        service = [
            SELECT Id, Name, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Replaced_Service__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c
            FROM csord__Service__c
            WHERE csordtelcoa__Replaced_Service__c != null OR name =: 'TestService'
            LIMIT 1
        ];
*/
        
        /*List<csord__Service__c> serviceListResult = [
            SELECT Id, Name, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate
            FROM csord__Service__c
        ];
        
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c serv: serviceListResult) {
            lstServiceId.add(serv.Id);
        }
        lstServiceId.add(service.Id);*/
        
        /*for(Id ord:orderIds){           
            Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(lstServiceId, ord);
        }*/
        
        /*Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c,false);
        csord__Order__c order1 = new csord__Order__c();
        order1 = [SELECT Id, CorrelationId__c FROM csord__Order__c where Id = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c];
        
        service.csordtelcoa__Replaced_Service__r.CorrelationId__c = order1.CorrelationId__c;
        update service;*/
		
		//system.debug('tally...........'+service.CorrelationId__c+'>>>>'+service.csordtelcoa__Replaced_Service__r.CorrelationId__c+'>>>>'+service.csord__Order__c+'>>>>'+orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c);        
        //List<Orchestration_Technical__c> techObj = [SELECT Id,Service__c,Field_1__c,Field_14__c,Field_3__c,Field_11__c FROM Orchestration_Technical__c];
        //System.debug('techObj............'+techObj);
        
        /*Attachment attReplacedServiceold = [SELECT ID, name, body, parentId FROM Attachment];
        String serviceattachmentstrold = attReplacedServiceold.body.toString();
        Map<String, Object> resultsold = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstrold);
        List<Object> lstSpecificationsold = (List<Object>) resultsold.get('specifications');*/
        
       
        
        Test.startTest();
        //replaced service - testService 1
        /*List<Orchestration_Technical__c> techObj = [SELECT Id,Service__c,Field_1__c,Field_14__c,Field_3__c,Field_11__c FROM Orchestration_Technical__c where service__c = :service.id];
        techObj[0].Field_1__c = '';
        update techObj;*/
        
        //testService 0
        csord__Service__c service0 = [
            SELECT Id, Name, csord__Order__c, CorrelationId__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate
            FROM csord__Service__c
            WHERE name = 'testService 0'
            LIMIT 1
        ];
       /* List<Orchestration_Technical__c> techObj1 = [SELECT Id,Service__c,Field_1__c,Field_14__c,Field_3__c,Field_11__c FROM Orchestration_Technical__c limit 1];
        techObj1[0].Field_1__c = '';
        //techObj1[1].Service__c = service0.id;
        update techObj1;*/
        
        Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c,false);
      //  Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(new Set<Id> {service.id}, orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c);
        
        Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
        Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
        //processedRecordIds.serviceIds = new Set<String>();
            system.debug('processedRecordIds passed............'+processedRecordIds);
        processedRecordIds.attachmentIds = new Set<String>{attachmentList[0].Id};
           // Coms_PlatformCacheUtil.insertServicesToCache(orchStep.CSPOFA__Orchestration_Process__r.Order__c);
            //for (CSPOFA__Orchestration_Step__c step : orchStepList) {
                payloadMap.put('orderIds',orderIds);
                payloadMap.put('StepId',orchStepList[0].Id);
                payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c);
                //payloadMap.put('Current',step.CSPOFA__Step_Order__c);
                //payloadMap.put('Current',orderIds[0]);
                payloadMap.put('ProcessName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                //if(OP!=null)
                //	processedIds.put(orchStepList[0].Id,OP);
                //payloadMap.put('ProcessedRecords',processedIds);
                payloadMap.put('ProcessedRecords',processedRecordIds);
                str=(String)JSON.serialize(payloadMap); 
                
                system.debug('str........'+str);
            //}
        
        system.debug('###payload: ' + str);
        
        Orchestration_RecreateDelSpecsV1_Handler handler = new Orchestration_RecreateDelSpecsV1_Handler();
        handler.processUpdate(str);
        //Test.stopTest();
        //orchStepList = recreateDeletedSpecs.process(orchStepList);
        //Query Updated Data for Assertion
        /*Attachment attReplacedService = [SELECT ID, name, body, parentId FROM Attachment];
        String serviceattachmentstr = attReplacedService.body.toString();
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
        List<Object> lstSpecifications = (List<Object>) results.get('specifications');
        //Assert To check specification is added sucessfully or not
        System.assertEquals(lstSpecifications.size(), lstSpecificationsold.size());*/
        
        /*string productConfigurationId = '';
        string status = '';
        Map<String, Object> specificationAttributes = (Map<String, Object>) lstSpecifications[lstSpecifications.size()-1];
        status = (String) specificationAttributes.get('status');
        productConfigurationId = (String) specificationAttributes.get('productConfigurationId');*/
        // Assert To check the status
        System.assert(orchStep.CSPOFA__Status__c!=null);
        //System.assertEquals(status, 'Disconnect In Progress');
        // Assert To check the configId
        //System.assertEquals(productConfigurationId, service.csordtelcoa__Product_Configuration__c); //Check with Prajakta
        //System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Records processed');
        //System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Success - No update required as no services found with deleted specs');
        //System.assertEquals(orchStepList[2].CSPOFA__Message__c, 'Error: Step do not have an order');
        
        Test.stopTest();
    }

}