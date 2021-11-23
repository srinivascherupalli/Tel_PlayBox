/*******************************************************************************************************************
Name : PushHerokuConfigurationsBatchTest
Class: PushHerokuConfigurationsBatch
Description : To Update the configuration values to Heroku.
Sr.No.    Developer Name            Date                  Story Description
1.         Martand                  08/02/2021               EDGE-201336                                                  
********************************************************************************************************************/
@isTest
public class PushHerokuConfigurationsBatchTest {
    @TestSetup
    static void setup() {
        //Create Services and Product Configs to get the Config Id and update it ti Heroku.
        Account testAccount = new Account();
    testAccount.Name = 'testAccount';
    testAccount.Customer_Status__c = 'ACTIVE';
    insert testAccount;

    Opportunity testOpp = new Opportunity();
    testOpp.AccountId = testAccount.Id;
    testOpp.Name = 'testOpp';
    testOpp.Product_Domain__c = 'Other';
    testOpp.StageName = 'Develop';
    testOpp.Product_Type__c = 'Modular';
    testOpp.CloseDate = System.Date.today();
    testOpp.Description__c = 'test';
    insert testOpp;
      
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

    csord__Order__c testOrder = new csord__Order__c();
    testOrder.csord__Account__c = testAccount.Id;
    testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
    testOrder.csordtelcoa__Point_of_No_Return_Reached__c = true;
    testOrder.cancel_Point_of_No_Return_Reached__c = true;
    testOrder.Name = 'TestOrderNameForTest';
    testOrder.csord__Identification__c = 'test';
    testOrder.Product_Basket__c = testBasket.id;
    insert testOrder;

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
        
        csord__Service__c ser1 = new csord__Service__c();
        ser1.csord__Subscription__c = sub.ID;
        ser1.csord__Identification__c = sub.csord__Identification__c;
        ser1.cssdm__solution_association__c = sol1.Id;
        ser1.csord__Order__c = testOrder.Id;
        ser1.csordtelcoa__Product_Configuration__c = userPC1.ID;
        insert ser1;
        
        
        csord__Service__c ser2 = new csord__Service__c();
        ser2.csord__Subscription__c = sub.ID;
        ser2.csord__Identification__c = sub.csord__Identification__c;
        ser2.cssdm__solution_association__c = sol1.Id;
        ser2.csord__Order__c = testOrder.Id;
        ser2.csordtelcoa__Product_Configuration__c = userPC1.ID;
        insert ser2;
    }


    @isTest
    static void  storeValueonOrder(){
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.LastModifiedDate,csord__Order__c FROM csord__Service__c LIMIT 1]);
        //Test for positive scenerio
        Test.startTest();
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'SaveJobId'), 1);
        Test.stopTest();
        csord__Order__c ord = [SELECT Id,LastModifiedDate FROM csord__Order__c WHERE Id =: servicesMap.values()[0].csord__Order__c];
        System.assertNotEquals(ord.LastModifiedDate, servicesMap.values()[0].csord__Order__r.LastModifiedDate);
    }
    @isTest
    static void  storeValueonOrder1(){
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.LastModifiedDate,csord__Order__c FROM csord__Service__c LIMIT 1]);
        //Test for positive scenerio
        Test.startTest();
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'UpdateRemediationFlag'), 1);
        Test.stopTest();
        csord__Order__c ord = [SELECT Id,LastModifiedDate FROM csord__Order__c WHERE Id =: servicesMap.values()[0].csord__Order__c];
        System.assertNotEquals(ord.LastModifiedDate, servicesMap.values()[0].csord__Order__r.LastModifiedDate);
    }
    
    @isTest
    static void  storeValueonOrder2(){
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.LastModifiedDate,csord__Order__c FROM csord__Service__c LIMIT 1]);
        //Test for positive scenerio
        Test.startTest();
        Map<Id, Map<String, String>> serviceConfigurationMap = new Map<Id, Map<String, String>>();
        serviceConfigurationMap.put(servicesMap.values()[0].id,new Map<String,String>
            { 
              Label.AllowAmend =>'Amend Allowed'
            });
        
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(serviceConfigurationMap, 'BatchCheckNotRequired'), 1); 
        Test.stopTest();
        System.assertNotEquals(jobId,null);
    }

    @isTest
    static void  notStoreValueOnOrder(){
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__c,csord__Order__r.LastModifiedDate FROM csord__Service__c LIMIT 1]);
        //Test for positive scenerio
        Test.startTest();
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), ''), 1);
        csord__Order__c ord = [SELECT Id,Push_Heroku_Configurations_Job_Id__c,LastModifiedDate FROM csord__Order__c WHERE Id =: servicesMap.values()[0].csord__Order__c];
        Test.stopTest();
        System.assert(String.isBlank(ord.Push_Heroku_Configurations_Job_Id__c));
        System.assertEquals(ord.LastModifiedDate, servicesMap.values()[0].csord__Order__r.LastModifiedDate);

    }

}