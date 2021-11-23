@isTest
public class Orchestration_CreateLegacyServ_HandTest {
    //Test Data Setup
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
        List<csord__Service__c> servlist0 = new List<csord__Service__c>();
        List<csord__Service__c> servlist1 = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0 = new List<Attachment>();
        list<Attachment> attachmentList1 = new List<Attachment>();
        list<Attachment> allAttachment = new List<Attachment>();
        //Fetching Metadata
        List<Product__mdt> productPlanDetails = [SELECT DeveloperName,Label, (SELECT Id,Label,Communication_Method__c,Type__c FROM Plan__r ) FROM Product__mdt];
        List<Plan__mdt> planDetails = [SELECT Communication_Method__c, Product__c, Type__c FROM Plan__mdt];
        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(false,2); 
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;
        
        csord__Solution__c solution = new csord__Solution__c();
        solution.Name = 'Adaptive Mobility';
        solution.csord__Identification__c = 'Solution Console 2020-10-08 10:25:36';
        insert solution;
        
         cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_001196';
        insert productDefinition;
        
        cscfga__Product_Configuration__c prodConfigRec = new cscfga__Product_Configuration__c();
        prodConfigRec.name='Enterprise Mobility Managed Service';
        prodConfigRec.Type__c='New';
        prodConfigRec.ConfigurationType1__c = 'SolutionComponent';
        prodConfigRec.Quantity_Product_Configuration__c = 111;
        prodConfigRec.cssdm__solution_association__c = solution.id;
        prodConfigRec.cscfga__Product_Definition__c=productDefinition.id;
        insert prodConfigRec;
        
        
        
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true , 4);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,2);
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 4, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        //subscriptionList[1].csord__Account__c = accountList[1].id ; // account which is already in Acquired state.
        //insert subscriptionList;
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist0 = Orchestration_TestUtility.buildService(true, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        //servlist[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        //insert servlist;
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist1 = Orchestration_TestUtility.buildService(true, 2, subscriptionList[1].id, orderReqList[0].id, orderList[1].id, productconfiglistList[1].id);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(false, 2, servlist0, productconfiglistList[0].id);
        for (Attachment att : attachmentList0) {
            att.Name = System.label.DTOName;
            att.parentId = productconfiglistList[0].id;
            att.body = Blob.valueOf(
                '{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice",' +
                '"service":[{"User_Type":"","serviceExtension":[{"Services_To":"7836518762","Services_From":"7836518752","eligibilityStatus":"Eligible",' +
                '"eligibilityReason":"","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"7836518752","IsInflight":null,' +
                '"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"Eligible","eligibilityReason":"",' +
                '"disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,' +
                '"checkValue":false}],"Product_Type":"PSTN","eligibilityStatus":"Eligible","eligibilityReason":null,"disableCheck":null,"checkValue":true},' +
                '{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"9508637503","Services_From":"9508637493",' +
                '"eligibilityStatus":"Ineligible","eligibilityReason":"All Numbers are not available","disableCheck":null,"checkValue":false}],"Service_Type":"Voice",' +
                '"Service_Id":"9508637493","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"",' +
                '"eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,' +
                '"checkValue":false}],"Product_Type":"ISDN","eligibilityStatus":"Not valid for assessment","eligibilityReason":null,"disableCheck":null,"checkValue":true},' +
                '{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"291397","Services_From":"291386",' +
                '"eligibilityStatus":"Ineligible","eligibilityReason":"All Numbers are not available","disableCheck":null,"checkValue":false},{"Services_To":"291397",' +
                '"Services_From":"291385","eligibilityStatus":"Ineligible","eligibilityReason":"All Numbers are not available","disableCheck":null,"checkValue":false}],' +
                '"Service_Type":"Voice","Service_Id":"2913852467","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N",' +
                '"eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"",' +
                '"Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2DID","eligibilityStatus":"Ineligible","eligibilityReason":null,' +
                '"disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"401432055"}],"serviceCount":2,"Error_Description":"",' +
                '"Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICE82cfb97b7581e661a0","CIDN":"5829086067"}'

         ); 
        }
        allAttachment.addAll(attachmentList0);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList1 = Orchestration_TestUtility.buildAttachment(false, 2, servlist1, productconfiglistList[1].id);
        for (Attachment att : attachmentList1) {
            att.Name = System.label.NgUcTransitionName;
            att.parentId = productconfiglistList[1].id;
            att.body = Blob.valueOf(
                '{ "Source_System_Id":"Replicator", "productList" :[ { "Product_Type":"PSTN", "eligibilityStatus":"Eligible",' +
                ' "eligibilityReason":null, "disableCheck":null, "checkValue":true, "site":[ { "siteName":null, "Error_Description":"", "Error_Code":"", ' +
                '"ADBOR_Id":"401432055", "linkedSiteId":null, "serviceList":[ { "checkValue":false, "checkReserved":true, "disableCheck":null, "Service_Type":"Voice", ' +
                '"eligibilityStatus":"Eligible", "eligibilityReason":"", "groupType":[ { "groupId" : "group1", "transitionId" : "trans1", "disableCheck":null, ' +
                '"checkValue":true, "serviceAssociations" :null, "service":[ { "Service_Id " : "srv1", "Reserve_status" : "reserved" } ] } ] } ] } ] } ] }'
            );
        }
        
        allAttachment.addAll(attachmentList1);
        insert allAttachment;
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(true, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, null);
        // processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;
        //processList[3].csordtelcoa__Subscription__c = null; // Process where sub is null
        //insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,4,processList);
        for(CSPOFA__Orchestration_Step__c step :orchStepList){
            //step.JSON__C = '{"StepId" : "ABC","mapDetailRecords" :{  "Service" : "a","Subscription" : "d","Attachment" : "f"  }}';
            
            step.JSON__c = null;
        }
        insert orchStepList;
    }
    
    static testMethod void ProcessTest() {
        String str='';
    	Set<Id>orderIds=new Set<Id>();
        List<Id> orderIdsList = new List<Id>();   
        Map<String,Object>payloadMap=new Map<String,Object>();

        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        List<Attachment> attlistNew = new List<Attachment>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,JSON__c, CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
        CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        List<Attachment> atchmnt = [SELECT ID, name, body, parentId FROM Attachment WHERE name = :System.label.DTOName OR name = :System.label.NgUcTransitionName];
        List<csord__Subscription__c> subList = [SELECT ID FROM csord__Subscription__c];
        List<csord__Service__c> serList = [SELECT ID FROM csord__Service__c];
        Orchestration_ProcessedRecords records = new Orchestration_ProcessedRecords();

        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null && !orderIds.contains(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                
            }
        }

        system.debug('orderIds..............'+orderIds);

        /*for(Id ord:orderIds){           
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ord,false);
        }*/
        Test.startTest();
         Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c,false);

        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        // OP.serviceIds = new Set<String>();
        // OP.serviceIds.add(serList[0].Id);
        // OP.serviceIds.add(serList[0].Id);
        // OP.serviceIds.add(serList[0].Id);
        // OP.serviceIds.add(serList[0].Id);
        
        
        Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
        Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
        //for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            payloadMap.put('StepId',orchStepList[0].Id);
            payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c);
            //payloadMap.put('OrderId',orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c);
            //payloadMap.put('StepId',orchStepList[0].Id);
            //payloadMap.put('Current',step.CSPOFA__Step_Order__c);
            //payloadMap.put('Current',orderIds[0]);
            payloadMap.put('ProcessName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
            //if(OP!=null)
            //	processedIds.put(orchStepList[0].Id,OP);
            //payloadMap.put('ProcessedRecords', processedRecordIds);
            str=(String)JSON.serialize(payloadMap); 
            
            system.debug('str........'+str);
        //}
        
        system.debug('###payload: ' + str);

        Orchestration_CreateLegacyServ_Handler handler = new Orchestration_CreateLegacyServ_Handler();
        handler.processUpdate(str);
        //Query Updated Data for Assertion
        attlistNew = [SELECT ID, name, body, parentId FROM Attachment];
        List<csord__Subscription__c> subListNew = [SELECT ID FROM csord__Subscription__c];
        List<csord__Service__c> serListNew = [SELECT ID FROM csord__Service__c];
		Test.stopTest();
        System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
    
    static testMethod void ProcessTestNguc() {
        String str='';
    	Set<Id>orderIds=new Set<Id>();
        List<Id> orderIdsList = new List<Id>();   
        Map<String,Object>payloadMap=new Map<String,Object>();

        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        List<Attachment> attlistNew = new List<Attachment>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,JSON__c, CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
        CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        List<Attachment> atchmnt = [SELECT ID, name, body, parentId FROM Attachment WHERE name = :System.label.NgUcTransitionName];
        List<csord__Subscription__c> subList = [SELECT ID FROM csord__Subscription__c];
        List<csord__Service__c> serList = [SELECT ID FROM csord__Service__c];
        Orchestration_ProcessedRecords records = new Orchestration_ProcessedRecords();

        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null && !orderIds.contains(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                
            }
        }

        system.debug('orderIds..............'+orderIds);

        /*for(Id ord:orderIds){           
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ord,false);
        }*/
        Test.startTest();
         Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(orchStepList[1].CSPOFA__Orchestration_Process__r.Order__c,false);
        
        Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
        Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
        //for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            payloadMap.put('StepId',orchStepList[1].Id);
            payloadMap.put('Current',orchStepList[1].CSPOFA__Orchestration_Process__r.Order__c);
            payloadMap.put('ProcessName',orchStepList[1].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
            //if(OP!=null)
            //	processedIds.put(orchStepList[0].Id,OP);
            //payloadMap.put('ProcessedRecords', processedRecordIds);
            str=(String)JSON.serialize(payloadMap); 
            
            system.debug('str........'+str);
        //}
        
        system.debug('###payload: ' + str);

        Orchestration_CreateLegacyServ_Handler handler = new Orchestration_CreateLegacyServ_Handler();
        handler.processUpdate(str);
        //Query Updated Data for Assertion
        attlistNew = [SELECT ID, name, body, parentId FROM Attachment];
        List<csord__Subscription__c> subListNew = [SELECT ID FROM csord__Subscription__c];
        List<csord__Service__c> serListNew = [SELECT ID FROM csord__Service__c];
		Test.stopTest();
        System.assert(orchStepList[1].CSPOFA__Status__c!=null);
    }
}