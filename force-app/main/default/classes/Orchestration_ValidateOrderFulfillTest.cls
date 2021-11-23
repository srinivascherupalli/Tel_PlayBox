/* Appirio, Inc
* Name: Orchestration_ValidateOrderFulfillTest
* Main Class : Orchestration_ValidateOrderFulfillment
* Created Date: June 12, 2020
* Created By: Shweta Khandelwal

1 		Aparna Anisetti 		20/08/2021  DIGI-5635 : Modified Telstra Collaboration to 
														Adaptive Collaboration 
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_ValidateOrderFulfillTest {

     @Testsetup static void dataSetup(){
        //Orchestration Processes list
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
         //Process Templates for Processes
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        //List of Orchestration Steps which needs to be executed
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List of Accounts for order
        List<account> accountList = new List<account>();
        //Attachment for the services
        list<Attachment> attachmentList= new list<Attachment>();
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

        //Build Data to Perform Actions on
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Case> caseList = new List<Case>();
        FCR_Settings__c fcr = new FCR_Settings__c();
        List<User> newUser = new List<User>();
        List<Contact> conList = new List<Contact>();
        
        
        //Build Process Records through wich the Steps will be executed.
        newUser = Orchestration_TestUtility.buildUser(true,1);
         System.runAs(newUser[0]){ 
        fcr = Orchestration_TestUtility.buildFCR();
        governerLimit = Orchestration_TestUtility.buildLimits();
         accountList = Orchestration_TestUtility.buildAccount(true,1);
        oppList =  Orchestration_TestUtility.buildOpp(false,1,accountList);
        oppList[0].OwnerId = newUser[0].id;
        insert oppList;  
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 5);
         for(csord__Order__c ord: orderList){
         ord.csordtelcoa__Opportunity__c = oppList[0].id;
         ord.skipFulfillment__c = false;    
         }
             insert orderList;
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        prdList = Orchestration_TestUtility.buildProductDefination(true,1);
        offerList = Orchestration_TestUtility.buildMarkertableOffer(false,4);
        offerList[0].Type__c = 'Professional Service' ;
        offerList[1].Type__c = 'Managed Service';
        offerList[2].Offer_ID__c = 'DMCAT_Offer_000936'; //Fix to remove hardcoded Id for Telstra Collaboration PS
        offerList[3].Offer_ID__c = 'DMCAT_Offer_001251'; //DPG-1914: Adaptive Care Mobility
        insert offerList; 
        
        //DPG-2857: Adaptive Care Mobility
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        insert billingAccount;
        
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,6);
        productconfiglistList[1].ConfigurationType1__c = 'Product Component';
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[1].cscfga__Product_Definition__c = prdList[0].id; 
        productconfiglistList[2].Marketable_Offer__c = offerList[2].id; //Fix to remove hardcoded Id for Telstra Collaboration PS
        productconfiglistList[2].name='Adaptive Collaboration Professional Services'; //DIGI-5635 : Name change
        productconfiglistList[3].Marketable_Offer__c=offerList[3].id;  //DPG-1914: Adaptive Care Mobility
        productconfiglistList[3].ConfigurationType1__c = 'SolutionComponent';
        productconfiglistList[4].Marketable_Offer__c=offerList[3].id;
        productconfiglistList[4].ConfigurationType1__c = '';
         productconfiglistList[5].Marketable_Offer__c=offerList[3].id;
        productconfiglistList[5].ConfigurationType1__c = '';
         productconfiglistList[5].Type__c = 'Cancel';
        insert productconfiglistList;

        solutionList = Orchestration_TestUtility.buildSolution(true,1);

         subscriptionList = Orchestration_TestUtility.buildSubscription(false,9,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
         subscriptionList[5].csord__order__c = null; 
         subscriptionList[1].csord__order__c = orderList[1].id;
         subscriptionList[2].csord__order__c = orderList[1].id;
         subscriptionList[3].csord__order__c = orderList[3].id;
         subscriptionList[4].csord__order__c = orderList[4].id;
         subscriptionList[5].csord__order__c = orderList[2].id;
         subscriptionList[6].csord__order__c = orderList[1].id;
         subscriptionList[7].csord__order__c = orderList[1].id;
         subscriptionList[8].csord__order__c = orderList[1].id;
         subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
         subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
         subscriptionList[6].csordtelcoa__Product_Configuration__c = productconfiglistList[3].id;
         subscriptionList[7].csordtelcoa__Product_Configuration__c = productconfiglistList[4].id;
         subscriptionList[8].csordtelcoa__Product_Configuration__c = productconfiglistList[5].id;
         subscriptionList[0].MarketableOffer__c = offerList[0].id;
         subscriptionList[1].MarketableOffer__c = offerList[0].id;
         subscriptionList[2].MarketableOffer__c = offerList[1].id;
         subscriptionList[3].MarketableOffer__c = offerList[0].id;
         subscriptionList[4].MarketableOffer__c = offerList[1].id;
         subscriptionList[6].MarketableOffer__c =offerList[3].id;
         subscriptionList[7].MarketableOffer__c = offerList[3].id;
         subscriptionList[8].MarketableOffer__c = offerList[3].id;
         subscriptionList[6].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
         subscriptionList[7].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active;
         subscriptionList[6].Billing_Account__c = billingAccount.id;
         subscriptionList[7].Billing_Account__c = billingAccount.id;
             insert subscriptionList;
         

             system.debug(' subscriptionList[7]' +subscriptionList[7]);
        servlist= Orchestration_TestUtility.buildService(false,6,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        servlist[2].csord__Subscription__c = subscriptionList[2].id;
        servlist[3].csord__Subscription__c = subscriptionList[0].id;
        servlist[4].csord__Subscription__c = subscriptionList[6].id;
        servlist[5].csord__Subscription__c = subscriptionList[8].id;
        servlist[5].csord__Status__c = 'Pending';
        servlist[5].csordtelcoa__Product_Configuration__c=productconfiglistList[4].id;
        servlist[5].csord__Order__c=orderList[1].id;
            
        insert servlist; 
        
             system.debug('servlist+' +servlist);
             
        processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[4].csordtelcoa__Subscription__c = null;
        
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
        orchStepList[0].CSPOFA__Orchestration_Process__c = processList[4].id;
        for(CSPOFA__Orchestration_Step__c step :orchStepList){
             step.JSON__C = '{"StepId" : "ABC","mapInsertedRecords" :{  "Service" : "a","Subscription" : "d","Attachment" : "f"  }}';
         }
         insert orchStepList;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false,5,servlist,productconfiglistList[0].id);
        attachmentList[1].ParentId = productconfiglistList[1].id; // attachment's parent id is product config id
        attachmentList[2].ParentId = productconfiglistList[1].id; // attachment's parent id is product config id 
        attachmentList[3].ParentId = productconfiglistList[1].id; // attachment's parent id is product config id
        attachmentList[4].ParentId = servlist[5].id; // attachment's parent id is product config id
        attachmentList[1].Name = 'Operations User_schema.json';
        attachmentList[2].Name = 'Operations User_schema.json';
        attachmentList[3].Name = 'Operations User_schema.json';
        //attachmentList[3].Name = 'ServiceSpecifications.json';
        attachmentList[1].Body = Blob.valueOf('{ "configurations":[ { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" }, { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" } ] }'); 
        attachmentList[2].Body = Blob.valueOf('{ "configurations":[ { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" }, { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" } ] }'); 
        attachmentList[3].Body = Blob.valueOf('{ "configurations":[ { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" }, { "OfferName":"Offer1", "Operational User" : "'+newUser[0].id+'" } ] }'); 
        attachmentList[4].Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[5].id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","description":"Adaptive Care","id":"a3u5P000000A5eFQAS","currency":"AUD","type":"NEW","billingSpecId":"BSUSG005_CB","billDescription":"Support fee","taxTreatment":"GST Applicable","rateCardId":"7889"},"code":"DMCAT_ProductSpecification_001252_Billing_RecurringCharge_001268","description":"Adaptive Care_Billing_RecurringCharge_001268","endDate":"","guid":"ebf616fa-51ca-369d-4657-ae85a9fa819f","includeBilling":false,"instanceId":"","metadata":{},"name":"1252_RC_1268","productConfigurationId":"a3T5P0000003Ya2UAE","specification":"98042a16-e857-b35d-6bac-ae9f760c732e","startDate":"","status":"Created","version":"1"}]}');
             
         insert attachmentList;
             system.debug('attachmentList+' +attachmentList[4]);
     }
     }
    
    static testMethod void ProcessTestActive() {
         //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<Functional_Contact_Role__c> fcrList = new List<Functional_Contact_Role__c>();
        List<FulfillmentLineItem__c> fliList = new List<FulfillmentLineItem__c>();
        List<Case> caseList = new List<Case>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c];
        
        
        Test.startTest();
        Orchestration_ValidateOrderFulfillment validateOrderFulfillment = new Orchestration_ValidateOrderFulfillment();
        orchStepList = validateOrderFulfillment.process(orchStepList);
        //Query Updated Data for Assertion 
        orderList = [SELECT ID, skipFulfillment__c FROM csord__Order__c];
        
        System.assertEquals(orderList[4].skipFulfillment__c, true);
        subscriptionList = [SELECT id, MarketableOffer__r.Type__c,csord__Status__c,triggerBill_RTB__c,
                            (SELECT Id, Tenancy_Id__c, Purchase_Order_No__c, csord__Status__c FROM csord__Services__r)
                            FROM csord__Subscription__c
                            WHERE MarketableOffer__r.Type__c = 'Managed Service'
                            AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent'];
        System.debug('subscriptionList '+subscriptionList);
        //System.assertEquals(subscriptionList[0].csord__Status__c, 'Provisioned');
        //System.assertEquals(subscriptionList[0].triggerBill_RTB__c, true);
        
        fcrList = [SELECT id FROM Functional_Contact_Role__c];
        fliList = [SELECT id FROM FulfillmentLineItem__c];
        //caseList = [SELECT id FROM Case];
        
       // System.assertEquals(caseList.size() > 0 ? true :false ,true);
        System.assertEquals(fliList.size() > 0 ? true :false ,true);
        System.assertEquals(fcrList.size() == 0 ? true :false ,true);
        
        
        Test.stopTest();
    }
    
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
       
          Orchestration_ValidateOrderFulfillment validateOrderFulfillment = new Orchestration_ValidateOrderFulfillment();
        orchStepList = validateOrderFulfillment.process(orchStepList);
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
          Orchestration_ValidateOrderFulfillment validateOrderFulfillment = new Orchestration_ValidateOrderFulfillment();
        orchStepList = validateOrderFulfillment.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(isNull, true);
        Test.stopTest();
    }
    
    // Limits got hit : Partial records processed
    static testMethod void breakingLimitsDML1(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Status__c, 
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
               
      Orchestration_ValidateOrderFulfillment validateOrderFulfillment = new Orchestration_ValidateOrderFulfillment();
        orchStepList = validateOrderFulfillment.process(orchStepList);
       System.assertEquals(orchStepList[0].CSPOFA__Message__c ,'Success: Partial records processed');
       
       
        Test.stopTest();
    }
    //covering innerCatch by bad Json (Error condition)
    static testMethod void breakingLimitsInnerCatch(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
        for(CSPOFA__Orchestration_Step__c step : orchStepList){
           step.JSON__C = OrchestratorConstants.SystemConstant.AttachmentMsg;
        }
        update orchStepList;
              
      Orchestration_ValidateOrderFulfillment validateOrderFulfillment = new Orchestration_ValidateOrderFulfillment();
        orchStepList = validateOrderFulfillment.process(orchStepList);
       
        System.assertEquals(orchStepList[0].CSPOFA__Status__c ,OrchestratorConstants.OrchestratorStep.Error);
       
        Test.stopTest();
    }
    
    public static testmethod void performCalloutsTestSuccess(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      
        List<sObject> result = new List<sObject>();
        
        cscfga__Product_Configuration__c pc=[Select Id from cscfga__Product_Configuration__c where Name='Adaptive Collaboration Professional Services' limit 1];//DIGI-5635 Change
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new MockProductConfigOEdata('Test'));
        Orchestration_ValidateOrderFulfillment validateOrderFulfillment = new Orchestration_ValidateOrderFulfillment();
        Boolean result1=validateOrderFulfillment.performCallouts(orchStepList);
        result=validateOrderFulfillment.process(orchStepList);
        
        cssmgnt.ProductProcessingUtility.Attribute attr = new cssmgnt.ProductProcessingUtility.Attribute();
        attr.displayValue='8b07bcaa-9c22-92c5-39b8-6d286bb20978';
        attr.name='Test';
        attr.value='GUID';
        attr.showInUI=false;
        attr.value='8b07bcaa-9c22-92c5-39b8-6d286bb20978';


        list<cssmgnt.ProductProcessingUtility.Attribute> attrlist= new list<cssmgnt.ProductProcessingUtility.Attribute>();
        attrlist.add(attr);

        cssmgnt.ProductProcessingUtility.Configuration config= new cssmgnt.ProductProcessingUtility.Configuration();
        config.attributes=attrlist;
        config.configurationName='test comp';
        config.guid='Test config';


        List<cssmgnt.ProductProcessingUtility.Configuration> listconfig= new list<cssmgnt.ProductProcessingUtility.Configuration>();
        listconfig.add(config);


        cssmgnt.ProductProcessingUtility.Component comp= new cssmgnt.ProductProcessingUtility.Component();
        comp.changeType='Test';
        comp.description='Test';
        comp.configurations=listconfig;
        comp.guid='Test';

        list<cssmgnt.ProductProcessingUtility.Component> complist= new list<cssmgnt.ProductProcessingUtility.Component>();
        complist.add(comp);



        Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap = new Map<Id,List<cssmgnt.ProductProcessingUtility.Component>>();
        oeMap.put(pc.id,complist);//Fix to remove hardcoded Id for Telstra Collaboration PS

        Map<id,Map<String,String>> calloutResults=validateOrderFulfillment.parseResponse(oeMap);
   
        Test.stopTest();
        
        System.assertEquals(True,result1);
    }

}