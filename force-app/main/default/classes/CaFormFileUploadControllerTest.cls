/*----------------------------------------------------------------------
EDGE        -142351
Class       -CaFormFileUploadControllerTest
Description -Test class for CaFormFileUploadController
Author      -Dheeraj Bhatt
------------------------------------------------------------------------*/
@IsTest
public with sharing class CaFormFileUploadControllerTest {
    /*----------------------------------------------------------------------
EDGE        -142351
Method      -dataSetup
Description -Test data for class
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/     
    @testSetup public static void dataSetup(){
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
        TestDataFactory.generateProductConfiguration();
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Mobile Subscription';
        productDefinition.cscfga__Description__c = 'Mobile Subscription';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        productConfig.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig);
        insert pcList;
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Customer_Authorised_date__c=Date.Today();
        custAuthForm.Account__c=acc.id;
        custAuthForm.Opportunity__c=opp.id;
        insert  custAuthForm;
        Id RecordTypeIdOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted with Appointment').getRecordTypeId();
        Id RecordTypeIdSecondaryOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Secondary Order').getRecordTypeId();
        csord__Order_Request__c orderRequest=new csord__Order_Request__c();
        csord__Order__c prord = new csord__Order__c();
        prord.csord__Identification__c = 'test identification';
        prord.Name = 'test order';
        prord.csord__Order_Request__c=orderRequest.id;
        prord.csord__Status2__c = 'Pending';
        prord.RecordTypeId=RecordTypeIdOrder;
        prord.Scenario_Type__c='';
        insert prord;
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification1';
        ord.Name = 'test sec order';
        ord.csord__Order_Request__c=orderRequest.id;
        ord.RecordTypeId=RecordTypeIdSecondaryOrder;
        ord.Scenario_Type__c='';
        ord.csord__Primary_Order__c=prord.id;
        ord.csordtelcoa__Opportunity__c=opp.id;
        insert ord;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;
        insert subs;
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '4';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Failed';
        serv.csord__Order__c = ord.id;
        serv.Appointment_Required__c='true';
        serv.Scenario_Type__c ='Port Out Reversal';
        insert serv;
        string serviceNumber=[SELECT csordtelcoa__Service_Number__c from csord__Service__c WHERE Id =: serv.id ].csordtelcoa__Service_Number__c;
        Number__c num= new Number__c(Service_Id__c=serviceNumber,Service_Number__c='61459812342',Type__c='Port Out Reversal', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        insert num;
    }
    /*-------------------------------------------------------------------------------------------------
EDGE        -142351
Method      -getActiveCustomerAuthorityFormTest
Description -Test method for getActiveCustomerAuthorityForm method in CaFormFileUploadController class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------*/       
    @isTest  public static void getActiveCustomerAuthorityFormTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Test.startTest();
        List<Customer_Authority_Form__c> custAuthFormList=  CaFormFileUploadController.getActiveCustomerAuthorityForm(basket.id);
        Test.stopTest();
        system.assert(custAuthFormList.size()>0);
    }
    /*-------------------------------------------------------------------------------------------------
EDGE        -142351
Method      -saveFileTest
Description -Test method for saveFile method in CaFormFileUploadController class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------*/     
    @isTest public static void saveFileTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Test.startTest();
        CaFormFileUploadController.saveFile(Date.today(),basket.id,'Filename','base64Data','contentType',true);
        Test.stopTest();
        List<Customer_Authority_Form__c> custAuthFormList=[SELECT id,Account__c,Is_active__c FROM Customer_Authority_Form__c WHERE Account__r.name='Test Account1' AND Is_active__c=true];
        system.assertEquals(custAuthFormList.size(),1);
    }
    /*-------------------------------------------------------------------------------------------------
EDGE        -142351
Method      -getBasketDetailsTest
Description -Test method for getBasketDetails method in CaFormFileUploadController class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------*/ 
    @isTest  public static void getBasketDetailsTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Test.startTest();
        List<cscfga__Product_Basket__c> basketList=  CaFormFileUploadController.getBasketDetails(basket.id);
        Test.stopTest();
        system.assert(basketList.size()>0);
    }
}