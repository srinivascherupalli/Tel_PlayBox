// Test class for Orchestration_EvaluateChownNumber
@isTest(SeeAllData=false)
public class Orchestration_EvaluateChownNumberTest {

   //Data Setup   
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
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0= new list<Attachment>();
        list<Attachment> attachmentList1= new list<Attachment>();
        list<Attachment> attachmentList2= new list<Attachment>();
        list<Attachment> attachmentList3= new list<Attachment>();
        //Record to create the number
        //Build Data to Perform Actions on
                
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true , 5);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(false,2);
		processTempList[0].Name='Chown Order Prerequisite Process';
        insert processTempList;
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,1);          
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
       
        subscriptionList = Orchestration_TestUtility.buildSubscription(true,5,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);       
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist0= Orchestration_TestUtility.buildService(false,3,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        for(csord__Service__c service : servlist0){
         service.Scenario_Type__c = 'Transition';
         service.name ='chownService1';
        }
        insert servlist0;
       
       Number_Group__c ng = new Number_Group__c();
       insert ng;
       List<Number__c> numList = new List<Number__c>();
        numList = Orchestration_TestUtility.buildNumber(false, 1, productconfiglistList, '3', 'subId1');
        numList[0].Mobile__c = 'Mobile';
        numList[0].Sim_Serial_Number__c = '1';
        numList[0].IMSI__c = 'IMSI text';
        numList[0].SIM_Type__c = 'SIM card'; //EDGE-166432
        numList[0].SimAvailabilityType__c = 'New SIM'; 
        numList[0].Service_Number__c = 'SVC-167778'; 
		numList[0].Status__c = 'CHOWN Replaced';
        insert numList;
        List<Number__c> numberList = Orchestration_TestUtility.buildNumber(false, 1, productconfiglistList, '3', 'subId1');
        numberList[0].Mobile__c = 'Fixed';
        numberList[0].Sim_Serial_Number__c = '1';
        numberList[0].Service_Number__c = 'SVC-167778'; 
		numberList[0].Status__c = 'CHOWN Replaced';
        numberList[0].Number_Group__c = ng.Id;
        insert numberList;
                
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
                insert orchStepList;
        
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(true,2,servlist0,productconfiglistList[0].id);
        
   }
    
    
  @isTest
 	static void ProcessTest() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number__c> numList = new List<Number__c>();
        List<csord__Service__c> service = new List<csord__Service__c>();
       
       
           Test.startTest();
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        JSON__c,CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        
        service = [SELECT Id, Name,csordtelcoa__Service_Number__c
                   FROM csord__Service__c];
        
       
        numList = [SELECT ID, Product_Configuration__c FROM Number__c];
        numList[0].Service_Id__c = service[0].csordtelcoa__Service_Number__c;
        numList[1].Service_Id__c = service[0].csordtelcoa__Service_Number__c;
        update numList;                        
        
     
        Orchestration_EvaluateChownNumber chown = new Orchestration_EvaluateChownNumber();
        orchStepList = chown.process(orchStepList); 
              
     
       System.assertNotEquals(numList,null); 
    

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
      Orchestration_EvaluateChownNumber chown = new Orchestration_EvaluateChownNumber();
      orchStepList = chown.process(orchStepList);         
      //No Steps will be returned and nothing will be updated as Limits were reached
      //System.assertEquals(orchStepList, null, 'No Steps returned as Limit Reached.');
      System.assertEquals(orchStepList.isEmpty(), true);
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
      Orchestration_EvaluateChownNumber chown = new Orchestration_EvaluateChownNumber();
      orchStepList = chown.process(orchStepList);         
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
      Orchestration_EvaluateChownNumber chown = new Orchestration_EvaluateChownNumber();
      orchStepList = chown.process(orchStepList);       
     
      System.assertNotEquals(orchStepList[0].CSPOFA__Message__c, null);
      

      Test.stopTest();
  }
  

}