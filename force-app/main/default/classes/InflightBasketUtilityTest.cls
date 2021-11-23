/******************************************************************************************************
*Class Name     : InflightBasketUtility
*Test Class     : InflightBasketUtilityTest

Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________
1.        Pooja Gupta             17.12.2020    EDGE-191125
2.       Martand Atrey        15.01.2021  EDGE-195759
3.       Vamsi Krishna Vaddipalli   27.01.2021 EDGE-192911
4.       Shweta Khandelwal         5.02.2021 EDGE-192752
5.     Arunkumar Vankadhara     10.02.2021 EDGE-201336 
*******************************************************************************************************/
@isTest
public class InflightBasketUtilityTest {
  @TestSetup
  static void dataSetup() {
    Account testAccount = new Account();
    testAccount.Name = 'testAccount';
    testAccount.Customer_Status__c = 'ACTIVE';
    insert testAccount;

    List<Opportunity> opptyList = new List<Opportunity>();
    Opportunity testOpp = new Opportunity();
    testOpp.AccountId = testAccount.Id;
    testOpp.Name = 'testOpp';
    testOpp.Product_Domain__c = 'Other';
    testOpp.StageName = 'Develop';
    testOpp.Product_Type__c = 'Modular';
    testOpp.CloseDate = System.Date.today();
    testOpp.Description__c = 'test';
    //insert testOpp;
    opptyList.add(testOpp);
    
    
    Opportunity testOpp1 = new Opportunity();
    testOpp1.AccountId = testAccount.Id;
    testOpp1.Name = 'testOpp';
    testOpp1.Product_Domain__c = 'Other';
    testOpp1.StageName = 'Develop';
    testOpp1.Product_Type__c = 'Modular';
    testOpp1.CloseDate = System.Date.today();
    testOpp1.Description__c = 'test';
    opptyList.add(testOpp1);
    insert opptyList;
      
     //Added by Vamsi for EDGE-192911 on 27JAN21 starts    
    csconta__Frame_Agreement__c frameAgg = new csconta__Frame_Agreement__c();
    frameAgg.csconta__Account__c = testAccount.Id;
    insert frameAgg;
      
        Contact con = new Contact();
        con.FirstName = 'Rajiv';
        con.LastName = 'Singh'; 
        con.email ='rajiv@test.com';
        con.Contact_Status__c ='Active';
        con.AccountId = testAccount.Id;
        insert con;
     //Added by Vamsi for EDGE-192911 on 27JAN21 ends
     
    Id RecordTypeIdProdBasket = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();

    List<cscfga__Product_Basket__c> productBasketList = new List<cscfga__Product_Basket__c>();
      
     //Added by Vamsi for EDGE-192911 on 27JAN21 starts                
    cscfga__Product_Basket__c testBasket3 = new cscfga__Product_Basket__c();
    testBasket3.csbb__Account__c = testAccount.Id;
    testBasket3.Name = 'TestPreviousBasket';
    testBasket3.cscfga__Opportunity__c = testOpp.Id;
    testBasket3.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
    testBasket3.csconta__Frame_Agreement__c = frameAgg.Id;
    testBasket3.Device_Care_Contact__c = con.Id;
     insert testBasket3;
      //Added by Vamsi for EDGE-192911 on 27JAN21 ends   
       
    cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
    testBasket.csbb__Account__c = testAccount.Id;
    testBasket.Name = 'InflightTestBasket';
    testBasket.cscfga__Opportunity__c = testOpp.Id;
    testBasket.csordtelcoa__Basket_Stage__c = 'Draft';
    testBasket.RecordTypeId = RecordTypeIdProdBasket;
    testBasket.csordtelcoa__Previous_Product_Basket__c = testBasket3.Id;
    productBasketList.add(testBasket);

    cscfga__Product_Basket__c testBasket1 = new cscfga__Product_Basket__c();
    testBasket1.csbb__Account__c = testAccount.Id;
    testBasket1.Name = 'InflightTestBasket1';
    testBasket1.cscfga__Opportunity__c = testOpp.Id;
    testBasket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
    // testBasket1.RecordTypeId = RecordTypeIdProdBasket;
    productBasketList.add(testBasket1);

    cscfga__Product_Basket__c testBasket2 = new cscfga__Product_Basket__c();
    testBasket2.csbb__Account__c = testAccount.Id;
    testBasket2.Name = 'TestBasket';
    testBasket2.cscfga__Opportunity__c = testOpp.Id;
    testBasket2.csordtelcoa__Basket_Stage__c = 'Draft';
    productBasketList.add(testBasket2);
    insert productBasketList;

    List<csord__Order__c> orderList = new List<csord__Order__c>();
    
    csord__Order__c testOrder = new csord__Order__c();
    testOrder.csord__Account__c = testAccount.Id;
    testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
    testOrder.csordtelcoa__Point_of_No_Return_Reached__c = true;
    testOrder.cancel_Point_of_No_Return_Reached__c = true;
    testOrder.Name = 'TestOrderNameForTest';
    testOrder.csord__Identification__c = 'test';
    testOrder.Product_Basket__c = testBasket.id;
    //insert testOrder;
    orderList.add(testOrder);


    csord__Order__c testOrder1 = new csord__Order__c();
    testOrder1.csord__Account__c = testAccount.Id;
    testOrder1.csordtelcoa__Opportunity__c = testOpp1.Id;
    testOrder1.csordtelcoa__Point_of_No_Return_Reached__c = true;
    testOrder1.cancel_Point_of_No_Return_Reached__c = true;
    testOrder1.Name = 'TestOrderNameForTest1';
    testOrder1.csord__Identification__c = 'test';
    testOrder1.Product_Basket__c = testBasket1.id;
    testOrder1.csord__Status2__c = 'Amend Rejected';
    orderList.add(testOrder1);
    insert orderList;

    Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Enquiry').getRecordTypeId();

    case testCase = new case();
    testCase.Subject = 'testCase';
    testCase.RecordTypeId = RecordTypeIdCase;
    testCase.Status = 'New';
    testCase.Origin = 'TPC';
    insert testCase;

    csord__Solution__c sol1 = PricingTestDataFactory.generateSolution('nextgenEM_positive');
    sol1.cssdm__product_basket__c = testBasket.Id;
    sol1.csord__Order__c = testOrder.Id;
    csord__Solution__c sol2 = PricingTestDataFactory.generateSolution('nextgenEM_negative');
    //sol2.cssdm__product_basket__c = testBasket.Id;
    sol2.csord__Order__c = testOrder.Id;
    insert new List<csord__Solution__c>{ sol1, sol2 };
    sol1.cssdm__replaced_solution__c = sol2.Id;
    update sol1;
        
        
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.Name = 'testsub';
        sub.cssdm__solution_association__c = sol1.Id;
        sub.csord__Account__c = testAccount.Id;
        sub.csord__Order__c = testOrder.Id;
        sub.csord__Identification__c = 'testing';
        sub.Point_of_No_Return_Reached__c = false;
        sub.customerFacingServiceId__c = '1234';
        insert sub;
        
        cscfga__Product_Configuration__c userPC1 = new cscfga__Product_Configuration__c(Name = 'IP site',  Quantity_Product_Configuration__c = 3, Type__c = 'Cancel', configGuID__c = '122344');
        insert userPC1;
        
      	List<csord__Service__c> services = new List<csord__Service__c>();
        csord__Service__c ser1 = new csord__Service__c();
        ser1.csord__Subscription__c = sub.ID;
        ser1.csord__Identification__c = sub.csord__Identification__c;
        ser1.cssdm__solution_association__c = sol1.Id;
        ser1.csordtelcoa__Product_Configuration__c = userPC1.ID;
        services.add(ser1);
        
        
        csord__Service__c ser2 = new csord__Service__c();
        ser2.csord__Subscription__c = sub.ID;
        ser2.csord__Identification__c = sub.csord__Identification__c;
        ser2.cssdm__solution_association__c = sol1.Id;
        ser2.csordtelcoa__Product_Configuration__c = userPC1.ID;
        services.add(ser2);
        
      insert services;
        
  }

  @isTest
  static void testDoesSolutionExistInBasket() {
    csord__Solution__c solution = [SELECT Id, Name, cssdm__product_basket__c, cssdm__replaced_solution__c FROM csord__Solution__c WHERE cssdm__product_basket__c != null AND cssdm__replaced_solution__c != null LIMIT 1];
    system.debug('solution' + solution);
    Test.startTest();
    Boolean Status = InflightBasketUtility.doesSolutionExistInBasket(solution.cssdm__product_basket__c, solution.cssdm__replaced_solution__c);
    Test.stopTest();
    System.assertNotEquals(Status, null);
    System.assert(Status);
  }
  @isTest
  static void testDoesSolutionExistInBasketFalse() {
    csord__Solution__c solution = [SELECT Id, Name, cssdm__product_basket__c, cssdm__replaced_solution__c FROM csord__Solution__c WHERE cssdm__product_basket__c != null AND cssdm__replaced_solution__c != null LIMIT 1];
    Id productbasketId = solution.cssdm__product_basket__c;
    Id replacedSolutionId = solution.cssdm__replaced_solution__c;
    delete solution;
    system.debug('solution' + solution);
    Test.startTest();
    Boolean Status = InflightBasketUtility.doesSolutionExistInBasket(productbasketId, replacedSolutionId);
    Test.stopTest();
    System.assertNotEquals(Status, null);
    System.assert(!Status);
  }
  @isTest
  static void testDoesInflightBasketExist() {
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'TestOrderNameForTest' LIMIT 1];
    Test.startTest();
    //String result = InflightBasketUtility.doesInflightBasketExist(ordRec.id);
    cscfga__Product_Basket__c bas = InflightBasketUtility.doesInflightBasketExist(ordRec);
    Test.stopTest();
    System.assertNotEquals(bas, null);
  }

  @isTest
  static void testUpdateBasket() {
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c,csord__Status2__c, Product_Basket__c FROM csord__Order__c WHERE Product_Basket__c != null and csord__Status2__c='Amend Rejected' LIMIT 1];
      //ordRec.csord__Status2__c = 'Amend Rejected'; // Added by Shweta khandelwal : 192752
      //update ordRec;
      system.debug('ordRec '+ordRec);
    case testCase = [SELECT id FROM case WHERE Subject = 'testCase' LIMIT 1];
    Test.startTest();
    Boolean Status = InflightBasketUtility.updateBasket(ordRec.Product_Basket__c, 'Commercial and Non-Commercial', testCase.Id);
    Test.stopTest();
    System.assertEquals(Status, false);
  }

  @isTest
  static void testGetJobStatus() {
    cscfga__Product_Basket__c testProdBasket = [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c WHERE csordtelcoa__Basket_Stage__c = 'Draft' LIMIT 1];
    Test.startTest();
    string Status = InflightBasketUtility.GetJobStatus(testProdBasket.Id);
    Test.stopTest();
    System.assertNotEquals(Status, null);
    csutil__Async_Task_Data__c asyncData = new csutil__Async_Task_Data__c(csutil__linked_object_id__c=testProdBasket.Id);
    insert asyncData;
    string Status1 = InflightBasketUtility.GetJobStatus(testProdBasket.Id);
    System.assertEquals(Status1,'FAILURE');
  }

  @isTest
  static void testCreateInFlightBasket() {
    csord__Solution__c solution = [SELECT Id, Name, cssdm__product_basket__c FROM csord__Solution__c WHERE cssdm__product_basket__c != null LIMIT 1];
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c, Product_Basket__c FROM csord__Order__c WHERE Product_Basket__c = :solution.cssdm__product_basket__c and Name = 'TestOrderNameForTest' LIMIT 1];
    //update new cscfga__Product_Basket__c(csordtelcoa__Basket_Stage__c = 'Contract Accepted', Id = solution.cssdm__product_basket__c,csbb__Synchronised_With_Opportunity__c = false);
    delete [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c WHERE Id != :solution.cssdm__product_basket__c];
    Test.startTest();
    List<Map<String, String>> solutionList = InflightBasketUtility.createInFlightBasket(ordRec.Id, new List<Id>{ solution.Id, solution.Id });
    Test.stopTest();
    System.assertNotEquals(solutionList, null);
  }
    
    //When InflightBasket is in Commerical configuration Stage
      @isTest
  static void testCreateInFlightBasket3() {
    csord__Solution__c solution = [SELECT Id, Name, cssdm__product_basket__c FROM csord__Solution__c WHERE cssdm__product_basket__c != null LIMIT 1];
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c, Product_Basket__c FROM csord__Order__c WHERE Product_Basket__c = :solution.cssdm__product_basket__c and Name = 'TestOrderNameForTest' LIMIT 1];
    Test.startTest();
    update new cscfga__Product_Basket__c(csordtelcoa__Basket_Stage__c = 'Commercial Configuration', Id = solution.cssdm__product_basket__c);
    //delete [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c WHERE Id != :solution.cssdm__product_basket__c];
    
    List<Map<String, String>> solutionList = InflightBasketUtility.createInFlightBasket(ordRec.Id, new List<Id>{ solution.Id, solution.Id });
    Test.stopTest();
    System.assertNotEquals(solutionList, null);
  }
    
   //When InflightBasket is in Submitted Stage
      @isTest
  static void testCreateInFlightBasket4() {
    csord__Solution__c solution = [SELECT Id, Name, cssdm__product_basket__c FROM csord__Solution__c WHERE cssdm__product_basket__c != null LIMIT 1];
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c, Product_Basket__c FROM csord__Order__c WHERE Product_Basket__c = :solution.cssdm__product_basket__c and Name = 'TestOrderNameForTest' LIMIT 1];
    Test.startTest();
    update new cscfga__Product_Basket__c(csordtelcoa__Basket_Stage__c = 'Submitted', Id = solution.cssdm__product_basket__c);
    //delete [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c WHERE Id != :solution.cssdm__product_basket__c];
    
    List<Map<String, String>> solutionList = InflightBasketUtility.createInFlightBasket(ordRec.Id, new List<Id>{ solution.Id, solution.Id });
    Test.stopTest();
    System.assertNotEquals(solutionList, null);
  }
    //When inflight basket doesnot exist
   @isTest
  static void testCreateInFlightBasket2() {
    csord__Solution__c solution = [SELECT Id, Name, cssdm__product_basket__c FROM csord__Solution__c WHERE cssdm__product_basket__c != null LIMIT 1];
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c, Product_Basket__c FROM csord__Order__c WHERE Product_Basket__c = :solution.cssdm__product_basket__c and Name = 'TestOrderNameForTest' LIMIT 1];
    //update new cscfga__Product_Basket__c(csordtelcoa__Basket_Stage__c = 'Submitted', Id = solution.cssdm__product_basket__c);
    delete [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c WHERE Id = :solution.cssdm__product_basket__c AND RecordType.Name ='Inflight Change'];
    Test.startTest();
    List<Map<String, String>> solutionList = InflightBasketUtility.createInFlightBasket(ordRec.Id, new List<Id>{ solution.Id, solution.Id });
    Test.stopTest();
    System.assertNotEquals(solutionList, null);
  }   

  @isTest
  static void testgetOrderDetails() {
    csord__Order__c ordRec = [SELECT id, csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c FROM csord__Order__c where Name = 'TestOrderNameForTest' LIMIT 1];
    Test.startTest();
    Map<boolean, boolean> result = InflightBasketUtility.getOrderDetails(ordRec.Id);
    Test.stopTest();
    System.assertNotEquals(result, null);
  }
  
  @isTest
  static void testPushSolutionToHeroku() {
    Test.startTest();
    Map<String, String> requestMap = new Map<String, String>{ 'replacedSolutionId' => 'solId', 'targetSolutionId' => 'tsolId', 'targetBasketId' => 'basketId', 'targetMainConfigurationId' => 'configId', 'changeType' => 'Change Request' };
    
    List<Map<String, String>> listOfMap = new List<Map<String, String>>();
    listOfMap.add(requestMap);
    system.debug('listOfMap' + listOfMap);
    InflightBasketUtility.pushSolutionToHeroku(json.serialize(listOfMap),'targetSolutionId');
    Test.stopTest();
    System.assertEquals(listofmap.size()>0 ,true);
  }
    
    @isTest
    static void updateOpportunity(){
        cscfga__Product_Basket__c baskId = [select ID from cscfga__Product_Basket__c where Amend_Type__c != 'Non-Commercial' limit 1];
        Test.startTest();
        boolean val = inflightBasketUtility.updateOpportunity(baskId.Id);
        Test.stopTest();
        system.assertEquals(true, val);

         
    }
    
    @isTest
    static void getTargetMainConfigurationId(){
        Test.startTest();
         string targetMainConfigId = InflightBasketUtility.getTargetMainConfigurationId(null,null);
        Test.stopTest();
        system.assertNotEquals(null, targetMainConfigId);
    }
    
  @isTest
  static void pushConfigurationstoHerokuErrorTest(){
    //updateConfigurations
    Test.startTest();
    Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id,Name,csord__Service__c.csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.configGUID__c,csordtelcoa__Point_of_No_Return_Reached__c,csordtelcoa__Service_Number__c,cancel_Point_of_No_Return_Reached__c,csord__Service__c.cssdm__solution_association__c FROM csord__Service__c]);
    Boolean result = InflightBasketUtility.pushConfigurationstoHeroku(servicesMap);
    Test.stopTest();
    System.assertEquals(false, result);
    }
    @isTest
    static void checkQueuedJobStatus() {    //EDGE-201336 
    Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id,Name,csord__Service__c.csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.configGUID__c,csordtelcoa__Point_of_No_Return_Reached__c,csordtelcoa__Service_Number__c,cancel_Point_of_No_Return_Reached__c,csord__Service__c.cssdm__solution_association__c FROM csord__Service__c limit 1]);
    update servicesMap.values();
    Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(),  'UpdateRemediationFlag'), 1);
    List<AsyncApexJob> testjob =  [select status from AsyncApexJob where ID = :jobID];
    Test.startTest();
    String result = InflightBasketUtility.checkQueuedJobStatus(jobId);
    Test.stopTest();
    System.assertNotEquals(result, null);
      }

}