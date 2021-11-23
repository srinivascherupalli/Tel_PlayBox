/**================================================================
* Appirio, Inc
* Name: Orchestration_ServiceSubscriptionTest
* Created Date: May 28, 2020
* Created By: Shweta Khandelwal
==================================================================
 Change.No.    Developer Name          Date          Story Description
 1.            Milos Djordjevic	      08-06-2021	  EDGE-222326 : Modified assert to check for empty list instead of null
*/
@isTest 
public class Orchestration_ServiceSubscriptionTest { 
    
     List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
     List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
     List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
     List<account> accountList = new List<account>();
     List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
     List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
     List<csord__Subscription__c> subscriptionListNew = new List<csord__Subscription__c>();
     List<csord__Order__c> orderList = new List<csord__Order__c>();
     list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
     list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
     List<csord__Service__c> servlist = new List<csord__Service__c>();
     Governor_Limits__c governerLimit = new Governor_Limits__c();
     list<Attachment> attachmentList= new list<Attachment>();
    @Testsetup static void dataSetup(){
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
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
        List<csord__Subscription__c> allSubs = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subscriptionList0 = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subscriptionList1 = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subscriptionList2 = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subscriptionList3 = new List<csord__Subscription__c>();
        // List of Orders
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<csord__Order__c> primaryOrderList = new List<csord__Order__c>();
        //Product Configuration List
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        //Service List
        List<csord__Service__c> allServs = new List<csord__Service__c>();
        List<csord__Service__c> servlist0 = new List<csord__Service__c>();
        List<csord__Service__c> servlist1 = new List<csord__Service__c>();
        List<csord__Service__c> servlist2 = new List<csord__Service__c>();
        List<csord__Service__c> servlist3 = new List<csord__Service__c>();
       // List<csord__Service__c> servlist4 = new List<csord__Service__c>();
        List<csord__Service__c> servlist5 = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0 = new list<Attachment>();
        list<Attachment> attachmentList1 = new list<Attachment>();
        list<Attachment> attachmentList2 = new list<Attachment>();
        list<Attachment> attachmentList3 = new list<Attachment>();
        list<Attachment> attachmentList4 = new list<Attachment>();
        list<Attachment> attachmentList5 = new list<Attachment>();
        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        Orchestration_TestUtility.orderList = new List<csord__Order__c>();
        primaryOrderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Completed', orderReqList[0].id, false , 2);
        primaryOrderList[0].name = 'primaryOrder';
        primaryOrderList[1].name = 'primaryOrder1';
        insert primaryOrderList;
        
        Orchestration_TestUtility.orderList = new List<csord__Order__c>();
        orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Completed', orderReqList[0].id, false , 6);
        orderList[1].csord__Status2__c = 'Active'; //order1 does not have any process but have primary order
        orderList[2].csord__Status2__c = 'Completed'; //order2 has two services 
        orderList[3].csord__Status2__c = 'Suspended';// order3 have process but does not have any service 
        orderList[1].csord__Primary_Order__c = primaryOrderList[0].id;
        orderList[5].csord__Primary_Order__c = primaryOrderList[1].id;
        insert orderList;
        
        //Build Process Records through wich the Steps will be executed.
        processTempList = Orchestration_TestUtility.buildProcessTemplate(false,5);
        insert processTempList;
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,2);
        productconfiglistList[0].Type__c = 'Cancel';
        productconfiglistList[0].ConfigurationType1__c = '';
        productconfiglistList[1].ConfigurationType1__c = '';
        insert productconfiglistList;
        
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        
        Orchestration_TestUtility.subscriptionList = new List<csord__Subscription__c>();    
        subscriptionList0 = Orchestration_TestUtility.buildSubscription(false,24,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
        //allSubs.addAll(subscriptionList0);
        //Orchestration_TestUtility.subscriptionList = new List<csord__Subscription__c>(); 
        //subscriptionList1 = Orchestration_TestUtility.buildSubscription(false,6,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
        Integer counter = 0;
        for(csord__Subscription__c sub : subscriptionList0){
           switch on counter {
               when 6,7,8,9,10,11 {
                   sub.csord__Order__c = orderList[1].id;
               }
               when 12,13,14,15,16,17 {
                   sub.csord__Order__c = orderList[2].id;
               }
               when 18,19,20,21,22,23 {
                   sub.csord__Order__c = orderList[3].id;
               }
			}
           counter++;
            allSubs.add(sub);
        }
        /*allSubs.addAll(subscriptionList1);
        Orchestration_TestUtility.subscriptionList = new List<csord__Subscription__c>(); 
        subscriptionList2 = Orchestration_TestUtility.buildSubscription(false,6,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
        for(csord__Subscription__c sub : subscriptionList2){
           sub.csord__Order__c = orderList[2].id;
        }
         allSubs.addAll(subscriptionList2);
        Orchestration_TestUtility.subscriptionList = new List<csord__Subscription__c>();
        subscriptionList3 = Orchestration_TestUtility.buildSubscription(false,6,accountList[0].id,orderList, productconfiglistList[1].id, solutionList[0].id);
         for(csord__Subscription__c sub : subscriptionList3){
           sub.csord__Order__c = orderList[3].id;
        }
        allSubs.addAll(subscriptionList3);*/
        //insert allSubs;
        
        // This sub does not have any related process.
        csord__Subscription__c serviceSub = new csord__Subscription__c();
        serviceSub.Name = 'ServiceSub';
        serviceSub.csord__Identification__c = 'IDE1322';
        serviceSub.csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        allSubs.add(serviceSub);
        insert allSubs;
        
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        Integer serviceCounter = 0;
        servlist0= Orchestration_TestUtility.buildService(false,30,serviceSub.Id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        for(csord__Service__c service: servlist0){
            switch on serviceCounter {
               when 0,1,2,3,4,5 {
                  service.Scenario_Type__c = 'Device Replacement';
                   service.csord__Order__c = orderList[0].id;
               }
                when 6,7,8,9,10,11{
                    service.csord__Order__c = orderList[1].id;
                    service.Scenario_Type__c = 'Device Replacement';
                }
                when 12,13,14,15,16,17{
                    service.csord__Order__c = orderList[2].id;
                    
                }
                when 18,19,20,21,22,23{
                    service.csord__Order__c = orderList[3].id;
                    service.Scenario_Type__c = 'Device Replacement';
                }
                when 24,25,26,27,28,29{
                    service.csord__Order__c = orderList[5].id;
                    
                }
			}
           serviceCounter++;
            allServs.add(service);
           
        }
       /* allServs.addAll(servlist0);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist1= Orchestration_TestUtility.buildService(false,6,serviceSub.Id,orderReqList[0].id,orderList[1].id,productconfiglistList[0].id);
         for(csord__Service__c service: servlist1){
           service.Scenario_Type__c = 'Device Replacement';
        }
        allServs.addAll(servlist1);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist2= Orchestration_TestUtility.buildService(false,6,serviceSub.Id,orderReqList[0].id,orderList[2].id,productconfiglistList[0].id);
        allServs.addAll(servlist2);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist3= Orchestration_TestUtility.buildService(false,6,serviceSub.Id,orderReqList[0].id,orderList[3].id,productconfiglistList[0].id);
         for(csord__Service__c service: servlist3){
           service.Scenario_Type__c = 'Device Replacement';
        }
        allServs.addAll(servlist3);

        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist5= Orchestration_TestUtility.buildService(false,6,serviceSub.Id,orderReqList[0].id,orderList[5].id,productconfiglistList[0].id);
        allServs.addAll(servlist5);
		*/
        insert allServs;
        
        servlist0 = new List<csord__Service__c>();
         servlist1 = new List<csord__Service__c>();
       servlist2 = new List<csord__Service__c>();
        servlist3 = new List<csord__Service__c>();
        servlist5 = new List<csord__Service__c>();
        Integer attachmentCounter = 0;
        for(csord__Service__c serv : allServs){
            switch on attachmentCounter {
               when 0,1,2,3,4,5 {
                  servlist0.add(serv);
               }
                when 6,7,8,9,10,11{
                    servlist1.add(serv);
                }
                when 12,13,14,15,16,17{
                    servlist2.add(serv);
                    
                }
                when 18,19,20,21,22,23{
                    servlist3.add(serv);
                }
                when 24,25,26,27,28,29{
                    servlist5.add(serv);
                    
                }
            }
                attachmentCounter++;
            
        }
        List<Attachment> allAttachments = new List<Attachment>();
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(false,5,servlist0,productconfiglistList[0].id);
        allAttachments.addAll(attachmentList0);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList1 = Orchestration_TestUtility.buildAttachment(false,5,servlist1,productconfiglistList[0].id);
        allAttachments.addAll(attachmentList1);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList2 = Orchestration_TestUtility.buildAttachment(false,5,servlist2,productconfiglistList[0].id);
        allAttachments.addAll(attachmentList2);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList3 = Orchestration_TestUtility.buildAttachment(false,5,servlist3,productconfiglistList[0].id);
        allAttachments.addAll(attachmentList3);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList5 = Orchestration_TestUtility.buildAttachment(false,5,servlist5,productconfiglistList[0].id);
        allAttachments.addAll(attachmentList5);
        insert allAttachments;
        
        processList = Orchestration_TestUtility.buildProcess(false, 6, processTempList[0].id, orderList, subscriptionList0,accountList[0].id,null);  
        processList[1].Order__c = primaryOrderList[0].id;
        processList[0].Order__c = primaryOrderList[0].id;
        processList[5].Order__c = primaryOrderList[1].id;
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,6,processList);
        for(integer i=0;i<orchStepList.size();i++){
           orchStepList[i].JSON__c = '{"orderIds":["'+orderList[0].id+'","'+orderList[1].id+'"]}';
        }
        insert orchStepList;
       } 
    
    //Case: No templates found
    static testMethod void ProcessTestNotTemplate() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
      
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c,
                        CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__r.cspofa__account__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.Order__c
                        FROM CSPOFA__Orchestration_Step__c
                        ];
      
        Test.startTest();
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
        
        Test.stopTest();
        
    }
    
    //Case:  templates found and service Scnerio Type = Device Replacement
    static testMethod void ProcessTestWithTemplate() {
        List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<CSPOFA__Orchestration_Process_Template__c> orctempList = new List<CSPOFA__Orchestration_Process_Template__c>();
     
        orctempList = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c];
        orctempList[0].name = OrchestratorConstants.OrchesTemplateName.serviceTemplate;
        orctempList[1].name = OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate;
        orctempList[2].name =  OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate;
        update orctempList;
            
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c 
                        ];
                      
        
        Test.startTest();
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
        orchProcess = [SELECT Id,CSPOFA__Orchestration_Process_Template__r.Name,CSPOFA__State__c
                       FROM CSPOFA__Orchestration_Process__c
                       WHERE csordtelcoa__Subscription__r.Name = 'ServiceSub'];
                       
        
       // System.assertEquals(orchProcess.size() >= 1, true); // If process inserted sucessfully then size will be one or greater than one
       
       // System.assertEquals(orchProcess[0].CSPOFA__Orchestration_Process_Template__r.Name, OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate);
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Complete);
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, 'Complete');
        System.assertEquals(orchStepList[1].CSPOFA__Message__c,'Success: Service has a device Replacement Scenerio.');
        // System.assertEquals(orchProcess[0].CSPOFA__State__c, 'ACTIVE');
        Test.stopTest();
        
    }
    
    //Case:  templates found and service Scnerio Type NOT = Device Replacement
 /*   static testMethod void ProcessTestWithOnlyTemplate() {
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Process_Template__c> orctempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
        
        orctempList = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c];
        orctempList[0].name = OrchestratorConstants.OrchesTemplateName.serviceTemplate;
        orctempList[1].name = OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate;
        orctempList[2].name =  OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate;
        update orctempList;
        
        serviceList = [SELECT Id, Scenario_Type__c, csord__Subscription__c FROM csord__Service__c WHERE Scenario_Type__c = :Label.Device_Replacement];
        serviceList[0].Scenario_Type__c ='New Device';
        serviceList[1].Scenario_Type__c ='New Device';
        update serviceList;
        
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c ];
              
                
        Test.startTest();
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
        
        orchProcess = [SELECT Id,CSPOFA__Orchestration_Process_Template__r.Name 
                       FROM CSPOFA__Orchestration_Process__c
                       WHERE csordtelcoa__Subscription__r.Name = 'ServiceSub'];
        
        System.assertEquals(orchProcess.size() >= 1, true); // If process inserted sucessfully then size will be one or greater than one
        //temp name assert
        System.assertEquals(orchProcess[0].CSPOFA__Orchestration_Process_Template__r.Name, OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate);
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Complete);
        System.debug('orchStepList[1].CSPOFA__Message__c 200 '+orchStepList[0].CSPOFA__Status__c);
        System.debug('orchStepList[2].CSPOFA__Message__c 200'+orchStepList[0].CSPOFA__Status__c);
        System.debug('orchStepList[3].CSPOFA__Message__c 200'+orchStepList[0].CSPOFA__Status__c);
        System.debug('orchStepList[4].CSPOFA__Message__c 200'+orchStepList[0].CSPOFA__Status__c);
        System.debug('orchStepList[5].CSPOFA__Message__c 200'+orchStepList[0].CSPOFA__Status__c);
        Test.stopTest();
        
    }*/
    
     // Limits got hit
    static testMethod void breakingLimits(){
         //Query to get the Data for Processing 
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }
    
    //Run class without any limits left
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Custom Limits to check no updation is done
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true); // Modified as part of EDGE-222326
        Test.stopTest();
    }
    
     //Case:  templates found and service Scnerio Type NOT = Device Replacement & Limits got Hit
    static testMethod void ProcessTestWithOnlyTemplateLimitHit() {
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Process_Template__c> orctempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
         //Query to get the Data for Processing 
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '9';
        update governerLimit;
      
        Test.startTest();
        orctempList = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c];
        orctempList[0].name = OrchestratorConstants.OrchesTemplateName.serviceTemplate;
        orctempList[1].name = OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate;
        orctempList[2].name =  OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate;
        update orctempList;
        
        serviceList = [SELECT Id, Scenario_Type__c, csord__Subscription__c FROM csord__Service__c WHERE Scenario_Type__c = :Label.Device_Replacement];
        serviceList[0].Scenario_Type__c ='New Device';
        serviceList[1].Scenario_Type__c ='New Device';
        update serviceList;
        
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c,
                        CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__r.cspofa__account__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.Order__c
                        FROM CSPOFA__Orchestration_Step__c ];
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
        // Step will be in completed step
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Service has a device Replacement Scenerio.');
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Complete);
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Success: Service has a device Replacement Scenerio.');
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Complete);
        Test.stopTest();
        
    }
    // To cover inner catch : Provinding Invalid JSON (Error Condition)
       static testMethod void breakingLimitsInnerCatch(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        Test.startTest();
         //Query to get the Data for Processing 
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
        for(CSPOFA__Orchestration_Step__c step : orchStepList){
           step.JSON__C = OrchestratorConstants.SystemConstant.AttachmentMsg;
        }
        update orchStepList;
      Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);
       
        System.assertEquals(orchStepList[0].CSPOFA__Status__c ,OrchestratorConstants.OrchestratorStep.Error);
       
       
        Test.stopTest();
    }
    
       //Run class without any limits left DML limit
    static testMethod void breakingLimitsInStartDML(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c,DML_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_limit__c = '0';
        update governerLimit; 

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_ServiceSubscription serviceSubscription = new Orchestration_ServiceSubscription();
        orchStepList = serviceSubscription.process(orchStepList);       
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true, 'No Steps returned as Limit Reached.'); // Modified as part of EDGE-222326
        Test.stopTest();
    }

}