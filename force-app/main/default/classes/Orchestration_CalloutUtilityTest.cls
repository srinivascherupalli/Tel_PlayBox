/**================================================================
* Appirio, Inc
* Name: Orchestration_CalloutUtilityTest
* Main Class : Orchestration_CalloutUtility
* Created Date: June 21, 2020
* Created By: Shweta Khandelwal
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_CalloutUtilityTest  {
    public static List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
    public static List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
    public static List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    public static List<account> accountList = new List<account>();
    public static list<Attachment> attachmentList= new list<Attachment>();
    public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
    public static List<csord__Subscription__c> subscriptionListNew = new List<csord__Subscription__c>();
    public static List<csord__Order__c> orderList = new List<csord__Order__c>();
    public static list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
    public static list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
    public static List<csord__Service__c> servlist = new List<csord__Service__c>();
    public static List<csord__Service__c> servlistNew = new List<csord__Service__c>();
    public static Governor_Limits__c governerLimit = new Governor_Limits__c();
    public static List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
    public static List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
    public static List<Opportunity> oppList = new List<Opportunity>();
    public static List<Case> caseList = new List<Case>();
    public static FCR_Settings__c fcr = new FCR_Settings__c();
    public static User newUser = new User();
    public static List<Contact> conList = new List<Contact>();
    public static List<Number__c> numList  = new List<Number__c>();
     @Testsetup static void dataSetup(){
    
        governerLimit = Orchestration_TestUtility.buildLimits();
         accountList = Orchestration_TestUtility.buildAccount(true,1);
        oppList =  Orchestration_TestUtility.buildOpp(false,1,accountList);
        insert oppList;  

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 5);
        insert orderList;
         
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        prdList = Orchestration_TestUtility.buildProductDefination(true,1);
         
        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='Enterprise Mobility Managed Service ';
        pcNewMdm.Type__c='Cancel';
        pcNewMdm.Quantity_Product_Configuration__c = 111;   
        pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
        pcNewMdm.Remaining_Term__c = 0;
        insert pcNewMdm;
         
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,3);
        productconfiglistList[0].Remaining_Term__c = 0;
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id; 
        productconfiglistList[0].Type__c ='Cancel';
        productconfiglistList[0].cscfga__Root_Configuration__c =pcNewMdm.id; 
        productconfiglistList[1].ConfigurationType1__c = 'ProductComponent'; 
        insert productconfiglistList;  

        solutionList = Orchestration_TestUtility.buildSolution(true,1);

        subscriptionList = Orchestration_TestUtility.buildSubscription(false,6,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
        subscriptionList[1].csord__Status__c = 'Pending';
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[2].Name = 'Unified Communication Tenancy Solution';
        subscriptionList[2].csord__Status__c = 'Not Active'; 
        insert subscriptionList;
         

         
        servlist= Orchestration_TestUtility.buildService(false,5,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id; 
        servlist[3].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; 
        servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; 
        servlist[1].csord__Subscription__c = subscriptionList[1].id; 
        servlist[2].csord__Subscription__c = subscriptionList[2].id; 
        insert servlist; 
   
         
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[1].id;
        processList[2].csordtelcoa__Service__c = servlist[2].id; 
        insert processList;
         
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,3,processList);
        for(CSPOFA__Orchestration_Step__c step :orchStepList){
             step.JSON__C = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        }
        insert orchStepList;
 
     }
 
    
  @isTest static void sendRequestGenericTest() {
        //List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //subscriptionList = [SELECT ID FROM csord__Subscription__c LIMIT 1];
        Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
        innerTestClass clas = new innerTestClass();
        String handler = 'GenerateAppointmentHandler';
      Cache.Org.put(handler,'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
       Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      Test.startTest();
        handlerMetaData = clas.getIntegrationHandlerSettings(handler);
        String token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
       // String reqBody = clas.sendBillingOrderPayload.get(subscriptionList[0].ID);
        String orderNumber = '';
        Map<String,String> pathMap = new Map<String,String>();
        Map<String,String> headerMap = new Map<String, String>{
                                                               'Content-Type' => 'application/json',
                                                               'Authorization'=> 'Bearer ' + token,
                                                               'Correlation-Id'=>orderNumber,
                                                               'Source-System'=>'SFDC'}; 

        //Fetching the Metadata
        HttpResponse adResponse;
        adResponse = Orchestration_CalloutUtility.sendRequestGeneric('reqBody', Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, pathMap);
        System.assertEquals('lFYpKM2LkokcsbzQFKfsMTiPeFcA', token);  
      Test.stopTest();
   }
    @isTest static void sendRequestGenericGETest() {
        //List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //subscriptionList = [SELECT ID FROM csord__Subscription__c LIMIT 1];
        Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
        innerTestClass clas = new innerTestClass();
        String handler = 'GenerateAppointmentHandler';
       Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      Test.startTest();
      Long timeDiff = Orchestration_CalloutUtility.getRequestTimeDifference(Datetime.newInstance(1960, 2, 17),Datetime.newInstance(1960, 2, 19));
        handlerMetaData = clas.getIntegrationHandlerSettings(handler);
        String token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
       // String reqBody = clas.sendBillingOrderPayload.get(subscriptionList[0].ID);
        String orderNumber = '';
        Map<String,String> pathMap = new Map<String,String>();
        Map<String,String> headerMap = new Map<String, String>{
                                                               'Content-Type' => 'application/json',
                                                               'Authorization'=> 'Bearer ' + token,
                                                               'Correlation-Id'=>orderNumber,
                                                               'Source-System'=>'SFDC'}; 

        //Fetching the Metadata
        HttpResponse adResponse;
        adResponse = Orchestration_CalloutUtility.sendRequestGeneric('reqBody', Orchestration_CalloutUtility.HTTP_METHOD_GET, headerMap, handlerMetaData, pathMap);

        System.assert(adResponse != null);
        Test.stopTest();
   }
    
    public class innerTestClass extends Orchestration_AbstractStepHandler{
        
        public override List<SObject> process(List<SObject> steps) {return null;}
 }

}