/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateSrvcStsMainSolTest
 * Main Class : Orchestration_UpdateSrvcStatusMainSol
 * Created Date: June 21, 2020
 * Created By: Shweta Khandelwal
 * 1. Gnana		22-12-2020		EDGE-132434 : Added test methods 
 ==================================================================
 ==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_UpdateSrvcStsMainSolTest {
    // Method for data setup
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
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // record for product defination
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        //Contact List
        List<Contact> conList = new List<Contact>();
        //Marketable Offer List 
        List<Marketable_Offer__c> markOfferList = new List<Marketable_Offer__c>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 5);
        insert orderList;

        markOfferList = Orchestration_TestUtility.buildMarkertableOffer(false,3);
		markOfferList[0].Offer_ID__c='DMCAT_Offer_001354';
        markOfferList[1].Offer_ID__c='DMCAT_Offer_000854';
        insert markOfferList;
        
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        prdList = Orchestration_TestUtility.buildProductDefination(false, 3);
        prdList[1].product_Specification__c = 'DMCAT_Offer_000646';
        prdList[2].product_Specification__c = 'DMCAT_Offer_000854';
        insert prdList;

        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name = 'Enterprise Mobility Managed Service ';
        pcNewMdm.Type__c = 'Cancel';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
        pcNewMdm.Remaining_Term__c = 0;
        insert pcNewMdm;

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 6);
        productconfiglistList[0].Remaining_Term__c = 0;
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[0].Type__c = 'Cancel';
        productconfiglistList[0].cscfga__Root_Configuration__c = pcNewMdm.id;
        productconfiglistList[1].ConfigurationType1__c = 'ProductComponent';
        productconfiglistList[2].cscfga__Product_Definition__c = prdList[1].id;
         productconfiglistList[3].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[5].ConfigurationType1__c = 'SolutionComponent';
        productconfiglistList[5].Marketable_Offer__c = markOfferList[1].Id;
        productconfiglistList[5].cscfga__Product_Definition__c = prdList[2].id;
        insert productconfiglistList;

        solutionList = Orchestration_TestUtility.buildSolution(true, 1);

        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 9, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[1].csord__Status__c = 'Pending';
        subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[2].Name = 'Unified Communication Tenancy Solution';
        subscriptionList[2].csord__Status__c = 'Not Active';
        subscriptionList[3].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        subscriptionList[0].MarketableOffer__c = markOfferList[0].Id;
        subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[3].id;
        subscriptionList[4].MarketableOffer__c = markOfferList[0].Id;
        subscriptionList[4].csordtelcoa__Product_Configuration__c = productconfiglistList[4].id;
        subscriptionList[5].csord__Status__c = 'Inactive'; //Increase code coverage: Ila
        subscriptionList[5].csordtelcoa__Product_Configuration__c=pcNewMdm.id;
        subscriptionList[6].csordtelcoa__Product_Configuration__c = productconfiglistList[3].id;
        subscriptionList[6].csord__Status__c = 'Pending';
        subscriptionList[7].MarketableOffer__c = markOfferList[1].Id;
        subscriptionList[7].csord__Status__c = 'Pending';
        subscriptionList[7].csordtelcoa__Product_Configuration__c = productconfiglistList[5].id;
        insert subscriptionList;

        servlist = Orchestration_TestUtility.buildService(false, 10, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id; //Status: Connected
        servlist[3].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; //directCompleteServiceIds
        servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; //directCompleteServiceIds
        servlist[9].csordtelcoa__Product_Configuration__c = productconfiglistList[5].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id; // Sub with Pending Status
        servlist[2].csord__Subscription__c = subscriptionList[2].id; // Sub with Name:Unified Communication Tenancy Solution
        servlist[0].csord__Subscription__c = subscriptionList[3].id;
        servlist[5].csord__Subscription__c = subscriptionList[0].Id;
        servlist[6].csord__Subscription__c = subscriptionList[4].Id;
        servlist[7].csord__Subscription__c = subscriptionList[5].Id;
        servlist[8].csord__Subscription__c = subscriptionList[6].Id;
        servlist[9].csord__Subscription__c = subscriptionList[7].Id;
        insert servlist;

        //Build Process Records through wich the Steps will be executed. 
        processList = Orchestration_TestUtility.buildProcess(false, 9, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[1].id;
        processList[2].csordtelcoa__Service__c = servlist[3].id;
        processList[3].csordtelcoa__Service__c = servlist[2].id;
        processList[0].csordtelcoa__Service__c = servlist[0].id;
        processList[4].csordtelcoa__Service__c = servlist[4].id;
        processList[5].csordtelcoa__Service__c = servlist[6].id;
        processList[6].csordtelcoa__Service__c = servlist[7].id;
        processList[7].csordtelcoa__Service__c = servlist[8].id;
        processList[8].csordtelcoa__Service__c = servlist[9].id;
        insert processList;

        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 8, processList);
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__C = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        }
        insert orchStepList;
    }

    // update service
    static testMethod void ProcessTestActive() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //Query to get data from datasetup
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Test.startTest();
        Orchestration_UpdateSrvcStatusMainSol updateServiceStatusMain = new Orchestration_UpdateSrvcStatusMainSol();
        orchStepList = updateServiceStatusMain.process(orchStepList);
        
        // Query after process
        List<csord__Service__c> services = [SELECT Id, csord__Status__c FROM csord__Service__c WHERE toBeCancelled__c = 'true'];
        //Assert to check service status 
        System.assertEquals(services[0].csord__Status__c, 'Disconnected');
        System.assertEquals(orchStepList[2].CSPOFA__Message__c, 'Success - No service and subsciption found for update');
        Test.stopTest();
    }

    // No limits
    static testMethod void breakingLimitsInStart() {
         //Query to get the Data for Processing 
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation  
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_UpdateSrvcStatusMainSol updateServiceStatusMain = new Orchestration_UpdateSrvcStatusMainSol();
        orchStepList = updateServiceStatusMain.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(isNull, true);
        Test.stopTest();
    }

    static testMethod void processExceptionTest() {
        Orchestration_UpdateSrvcStatusMainSol updateServiceStatusMain = new Orchestration_UpdateSrvcStatusMainSol();
        Test.startTest();
        try {
            updateServiceStatusMain.process(null);
        } catch (Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        Test.stopTest();
    }
    
    // updating process 
    static testMethod void serviceProcessTest() {
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        List<CSPOFA__Orchestration_Process__c> processes = new List<CSPOFA__Orchestration_Process__c>();

        /*CSPOFA__Orchestration_Process__c orchProcess1 = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        CSPOFA__Orchestration_Process__c orchProcess2 = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        CSPOFA__Orchestration_Process__c orchProcess3 = ProductTestService.getNewOrchestrationProcess(parentTemplate);*/
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        processList = [SELECT Id,csordtelcoa__Service__c FROM CSPOFA__Orchestration_Process__c LIMIT 3];
        // Query data from datasetup
        List<csord__Service__c> serList = [SELECT Id, Name, csord__Status__c FROM csord__Service__c 
                                           WHERE csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent' LIMIT 2];
        processList[1].csordtelcoa__Service__c = serList[0].Id;
        processList[2].csordtelcoa__Service__c = serList[1].Id;
        update processList; // updation for further process
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps = [SELECT Id, CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c 
                WHERE CSPOFA__Orchestration_Process__c IN :processList];
        
           
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit; // updation for further process

        Test.startTest();
        Orchestration_UpdateSrvcStatusMainSol orderClass = new Orchestration_UpdateSrvcStatusMainSol();
        List<SObject> result = orderClass.process((List<SObject>) steps);
        // Assert to check limit size
        System.assert(result.size() > 0);

        Test.stopTest();
    }
    
    static testMethod void solutionClosedTest() {
        
        // Query data from datasetup
        List<csord__Service__c> serList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c FROM csord__Service__c 
                                           WHERE csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent' LIMIT 1];
        
        csord__Subscription__c sub =[SELECT id,MarketableOffer__c, csordtelcoa__Product_Configuration__c  from csord__Subscription__c where id =: serList[0].csord__Subscription__c];
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
        pc.id = sub.csordtelcoa__Product_Configuration__c;
        pc.ConfigurationType1__c = 'SolutionComponent';
        update pc;
                                       
        Marketable_Offer__c MO = new Marketable_Offer__c(Name = 'Blank SIM', Offer_ID__c = 'DMCAT_Offer_001354');
        sub.MarketableOffer__c = MO.id;
        //sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent';
        update sub;
        
    List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        processList = [SELECT Id,csordtelcoa__Service__c FROM CSPOFA__Orchestration_Process__c LIMIT 1];

        processList[0].csordtelcoa__Service__c = serList[0].Id;
        update processList; // updation for further process
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps = [SELECT Id, CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c 
                WHERE CSPOFA__Orchestration_Process__c IN :processList];
        
           
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit; // updation for further process

        Test.startTest();
        Orchestration_UpdateSrvcStatusMainSol orderClass = new Orchestration_UpdateSrvcStatusMainSol();
        List<SObject> result = orderClass.process((List<SObject>) steps);
           
         // Assert to check limit size
        System.assert(result.size() > 0);

        Test.stopTest();
    }   
    
    // Added as part of EDGE-132434 to test Provisioned Status
    static testMethod void TestProvisioned() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Test.startTest();
        Orchestration_UpdateSrvcStatusMainSol updateServiceStatusMain = new Orchestration_UpdateSrvcStatusMainSol();
        orchStepList = updateServiceStatusMain.process(orchStepList);
        
        List<csord__Service__c> listOfServs = [SELECT Id, name,csord__Status__c,csord__Subscription__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.MarketableOffer__c FROM csord__Service__c];
        Integer i=0;
        
        for(csord__Service__c s : listOfServs){
            System.debug('services status...'+ i + '----' + s.Name+'==='+s.csord__Subscription__r.csord__Status__c + ' ' + s.csord__Subscription__r.MarketableOffer__c);
            i++;
        }
        System.assertEquals(listOfServs[9].csord__Subscription__r.csord__Status__c, 'Provisioned');
        Test.stopTest();
    }
    
    // Added as part of EDGE-132434 to test Provisioning In Progress Status
    static testMethod void TestProvisioningInProgress() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Test.startTest();
        Orchestration_UpdateSrvcStatusMainSol updateServiceStatusMain = new Orchestration_UpdateSrvcStatusMainSol();
        orchStepList = updateServiceStatusMain.process(orchStepList);
        
        List<csord__Service__c> listOfServs = [SELECT Id, name,csord__Status__c,csord__Subscription__c,csord__Subscription__r.csord__Status__c FROM csord__Service__c];
        Integer i=0;
        for(csord__Service__c s : listOfServs){
            System.debug('services status...'+ i + '----' + s.Name+'==='+s.csord__Subscription__r.csord__Status__c);
          i++;
        }
        System.assertEquals(listOfServs[2].csord__Subscription__r.csord__Status__c, 'Provisioning In Progress');
        Test.stopTest();
    }
}