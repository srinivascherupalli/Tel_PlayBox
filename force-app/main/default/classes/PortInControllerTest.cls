/*************************************************************************************************
Name : PortInControllerTest
Description : Test class for PortInController 
Author: Kalashree Borgaonkar
Story: EDGE-80749,EDGE-89257,EDGE-89299
***************************************************************************************************/
@isTest
public class PortInControllerTest {
    /*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-80749 
Descripton : Create Data
-------------------------------------------------------------------------------------*/
    @testSetup 
    public static void setupdata(){
        
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
        List<Number__c> lstNum= new List<Number__c>();
        TestDataFactory.generateProductConfiguration();
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        cscfga__Product_Configuration__c productConfig  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];    
        productConfig.cscfga__Product_Basket__c=basket.Id;
        update productConfig;
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        sqRecord.SQ_Type__c='Port in SQ';
        sqRecord.Incumbent_Account_Number__c='3545654656';
        sqRecord.Incumbent_Carrier__c='Vodafone';
        sqRecord.Added_to_CA_form__c=true;
        sqRecord.basket_id__c=basket.Id;//DIGI-867
        sqList.add(sqRecord); 
        Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'61422222222','N');
        sqRecord.SQ_Type__c='Port in SQ';
        sqRecord1.Added_to_CA_form__c=true;
        sqRecord1.basket_id__c=basket.Id;//DIGI-867
        sqList.add(sqRecord1);
        insert sqList;
        Service_Qualification__c sq = [SELECT id FROM Service_Qualification__c WHERE Service_Number__c='61411111111'];
        Service_Qualification__c sq1 = [SELECT id FROM Service_Qualification__c WHERE Service_Number__c='61422222222'];
        Number__c num1 = TestUtil.createNumber('61411111111',basket.id,sq.id);
        num1.Type__c='Port In';
        lstNum.add(num1);
       
        Number__c num2 = TestUtil.createNumber('61422222222',basket.id,sq1.id);
       	insert lstNum;
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Customer_Authorised_date__c=Date.Today();
        insert  custAuthForm;

    }

    /*----------------------------------------------------------------
Method : saveMsisdnSQresultsTest
Author: Kalashree Borgaonkar
Story:EDGE-80749
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void saveMsisdnSQresultsTest(){
        List<Number__c> numList=[SELECT service_number__c from Number__c];
        System.Debug('numList'+numList);
        List<PortInController.NumberWrapper> msisdnLst = new List<PortInController.NumberWrapper>();
        PortInController.NumberWrapper msisdn1 = new PortInController.NumberWrapper();
        msisdn1.num='2459872';
        msisdn1.accountNumber='Acc1';
        msisdnLst.add(msisdn1);
        PortInController.NumberWrapper msisdn2 = new PortInController.NumberWrapper();
        msisdn2.num='24598721';
        msisdn2.accountNumber='Acc2';
        msisdnLst.add(msisdn2);
        String msisdn = JSON.serialize(msisdnlst);
        //cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();   
        cscfga__Product_Configuration__c testProductConfiguration  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];     
        String status;
        Test.startTest();
        status = PortInController.saveMsisdnSQresults(msisdn,testProductConfiguration.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals(status!=null, true, 'Record saved');
    }
    /*----------------------------------------------------------------
Method : saveMsisdnSQresultsFailTest
Author: Kalashree Borgaonkar
Story: EDGE-80749
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void saveMsisdnSQresultsFailTest(){
        String msisdn = 'msisdn';
        //cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();   
        cscfga__Product_Configuration__c testProductConfiguration  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];         
        String status;
        Test.startTest();
        status = PortInController.saveMsisdnSQresults(msisdn,testProductConfiguration.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals(status!=null, true, 'Record save failed');
    }
    /*----------------------------------------------------------------
Method : getQualifyResponseTestSuccess
Author: Kalashree Borgaonkar
Story: EDGE-80749
-------------------------------------------------------------------------------------
    
    @isTest
    public static void getQualifyResponseTestSuccess(){
        String msisdn = '2459872';
        String accountNumber = 'Acc1234';
        Account acc=[Select id from Account where name ='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Success'));
        PortInController.NumberWrapper wrap =  PortInController.getQualifyResponse(msisdn,accountNumber,basket.id);
        Test.stopTest();
        System.assertEquals(wrap!=null, true, 'Callout succesfull');
    }
    /*----------------------------------------------------------------
Method : getQualifyResponseTestFailure
Author: Kalashree Borgaonkar
Story: EDGE-80749 
-------------------------------------------------------------------------------------
    
    @isTest
    public static void getQualifyResponseTestFailure(){
        String msisdn = '2459872';
        String accountNumber = 'Acc1234';
        Account acc=[Select id from Account where name ='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Failure'));
        PortInController.NumberWrapper wrap =  PortInController.getQualifyResponse(msisdn,accountNumber,basket.id);
        Test.stopTest();
        System.assertEquals(wrap.message!=null, true, 'Callout failure');
    }
    /*----------------------------------------------------------------
Method : getQualifyResponseTestFailure429
Author: Kalashree Borgaonkar
Story: EDGE-80749
-------------------------------------------------------------------------------------
    
    @isTest
    public static void getQualifyResponseTestFailure429(){
        String msisdn = '2459872';
        String accountNumber = 'Acc1234';
        Account acc=[Select id from Account where name ='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Error429'));
        PortInController.NumberWrapper wrap =  PortInController.getQualifyResponse(msisdn,accountNumber,basket.id);
        Test.stopTest();
        System.assertEquals(wrap.message!=null, true, 'Callout failure');
    }
    /*----------------------------------------------------------------
Method : getQualifiedMsisdnTest
Author: Kalashree Borgaonkar/Ila
Story: EDGE-89257, EDGE-88795 
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void getQualifiedMsisdnTest(){
        cscfga__Product_Configuration__c productConfig = TestDataFactory.generateProductConfiguration();
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
        Test.startTest();
        List<PortInController.QualifiedNumbers> qualifiedNumList = PortInController.getQualifiedMsisdn(basket.id);
        Test.stopTest();
        System.assertEquals(qualifiedNumList!=Null, true, 'Received Qualified MSISDN');
    }
    /*----------------------------------------------------------------
Method : saveToReservationPoolTest
Author: Kalashree Borgaonkar/Ila
Story: EDGE-89257,EDGE-88795
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void saveToReservationPoolTest(){
        
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id limit 1];
        
        cscfga__Product_Configuration__c productConfig = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%']; 
        
        List<PortInController.QualifiedNumbers> qualifiedNumList = new List<PortInController.QualifiedNumbers>();
        qualifiedNumList.add(new PortInController.QualifiedNumbers(true,'61411111111'));
        qualifiedNumList.add(new PortInController.QualifiedNumbers(false,'61422222222'));
        String msisdnList = JSON.serialize(qualifiedNumList);              
        
        Test.startTest();
        String status = PortInController.saveToReservationPool(msisdnList,productConfig.cscfga__Product_Basket__c);        
        PortInController.CafDetails   customerAuthForm = PortInController.checkActiveCAF(productConfig.cscfga__Product_Basket__c);
        Customer_Authority_Form__c custAuthForm = [SELECT id FROM Customer_Authority_Form__c WHERE Account__r.name='Test Account1'];
        custAuthForm.Is_active__c=false;
        update custAuthForm;
        PortInController.CafDetails  customerInactive = PortInController.checkActiveCAF(productConfig.cscfga__Product_Basket__c);
        String statusError = PortInController.saveToReservationPool(null,productConfig.cscfga__Product_Basket__c);
        String statusException = PortInController.saveToReservationPool('msisdnList',productConfig.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals('Moved to Reservation Pool'.equalsIgnoreCase(status), true, 'Records Saved');
    }
    /*----------------------------------------------------------------
Method : saveToReservationPoolFailTest
Author: Kalashree Borgaonkar/Ila
Story: EDGE-89257,EDGE-88795 
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void saveToReservationPoolFailTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id limit 1];
        cscfga__Product_Configuration__c productConfig = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%']; 
        
        List<PortInController.QualifiedNumbers> qualifiedNumList = new List<PortInController.QualifiedNumbers>();
        qualifiedNumList.add(new PortInController.QualifiedNumbers(true,'61411111111'));
        qualifiedNumList.add(new PortInController.QualifiedNumbers(false,'61422222222'));
        String msisdnList = JSON.serialize(qualifiedNumList);
        
        Test.startTest(); 
        String statusException = PortInController.saveToReservationPool('msisdnList',productConfig.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals('SaveError'.equalsIgnoreCase(statusException), true, 'Records Save Failed');
    }
    /*----------------------------------------------------------------
Method : checkActiveCAFSuccess
Author: Kalashree Borgaonkar,Ila
Story: EDGE-89257,EDGE-88795 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void checkActiveCAFSuccess(){
        cscfga__Product_Configuration__c productConfig = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%']; 
        
        Test.startTest();
        PortInController.CafDetails  customerInactive = PortInController.checkActiveCAF(productConfig.cscfga__Product_Basket__c);
        Boolean  custInactive = PortInController.checkCAF(productConfig.cscfga__Product_Basket__c);
        System.assertEquals(customerInactive.isActive,false,'Active CAF present');
        Test.stopTest();
    }
    /*----------------------------------------------------------------
Method : checkActiveCAFFail
Author: Kalashree Borgaonkar
Story: EDGE-89257
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void checkActiveCAFFail(){
        cscfga__Product_Configuration__c productConfig = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%']; 
        Test.startTest();
        PortInController.CafDetails  cafDetail = PortInController.checkActiveCAF(productConfig.cscfga__Product_Basket__c);
        System.assertEquals(cafDetail.isActive,false,'Active CAF not present');
        Test.stopTest();
    }
    /*----------------------------------------------------------------
Method : createLinkTest
Author: Kalashree Borgaonkar/Ila
Story: EDGE-89299,EDGE-88795
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void createLinkTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Test.startTest();
        ID  fileid = PortInController.createLink('Filename','base64Data','contentType',basket.id,Date.today());
        System.assertEquals(fileid!=null,true,'Active CAF not present');
        Test.stopTest();
    }
    /*----------------------------------------------------------------
Method : getPpvDetailsTest
Author: Kalashree Borgaonkar,Ila
Story: EDGE-89257,EDGE-88795
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void getPpvDetailsTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1'];
        Customer_Authority_Form__c custAuthForm = [SELECT id FROM Customer_Authority_Form__c WHERE Account__r.name='Test Account1' limit 1];
        Customer_Authority_Form__c custAuthFormPpv = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthFormPpv.Type__c ='PPV';
        custAuthFormPpv.Customer_Authority_Form__c=custAuthForm.id;
        insert custAuthFormPpv;
        Test.startTest();
        PortInController.PpvDetails ppvDetail = PortInController.getPpvDetails(basket.id);
        PortInController.getBasketId(basket.id);
        System.assertEquals(ppvDetail!=null,true, 'PPV details');
        Test.stopTest();
    }
    /*----------------------------------------------------------------
Method : getSQResults
Author: Ila
Story: EDGE-80751
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void getSQResults(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Test.startTest();
        List<PortInController.NumberWrapper> importedNum = PortInController.getImportedData(basket.id);
        System.assertEquals(importedNum!=null,true, 'Imported Data present');
        Test.stopTest();
    }
        /*----------------------------------------------------------------
Method : isPortInValidTest
Author: Kalashree Borgaonkar
Story: EDGE-80751
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void isPortInValidTrueTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Test.startTest();
        Boolean isValid = PortInController.isPortInValid(basket.id);
        System.assertEquals(isValid,false, 'valid');
        Test.stopTest();
    }
     /*----------------------------------------------------------------
Method : isPortInValidFalseTest
Author: Kalashree Borgaonkar
Story: EDGE-80751
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void isPortInValidFalseTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' limit 1];
        Customer_Authority_Form__c caf = [SELECT id FROM Customer_Authority_Form__c WHERE Opportunity__c=:opp.id];
        caf.Customer_Authorised_date__c=Date.today().addMonths(2*-1);
        update caf;
        Test.startTest();
        Boolean isValid = PortInController.isPortInValid(basket.id);
        System.assertEquals(isValid,true, 'valid');
        Test.stopTest();
    }
     /*----------------------------------------------------------------
Method : getQualifyResponseTestSuccess
Author: Aishwarya
Story: EDGE-107149
-------------------------------------------------------------------------------------*/
     @isTest
    public static void getQualifyResponseTestSuccess(){
       
        
        /*String msisdn = '2459872';
        String accountNumber = 'Acc1234';*/
        Account acc=[Select id from Account where name ='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
    	List<PortInController.NumberWrapper> msisdnLst = new List<PortInController.NumberWrapper>();
        PortInController.NumberWrapper msisdn1 = new PortInController.NumberWrapper();
        msisdn1.num='2459872';
        msisdn1.accountNumber='Acc1';
        msisdn1.isSelect=true;
        msisdnLst.add(msisdn1);
        PortInController.NumberWrapper msisdn2 = new PortInController.NumberWrapper();
        msisdn2.num='24598721';
        msisdn2.accountNumber='Acc2';
         msisdn2.isSelect=true;
        msisdnLst.add(msisdn2);
        String msisdn = JSON.serialize(msisdnlst);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('success_multiple'));
        List<PortInController.NumberWrapper> wrap =  PortInController.getMultipleQualifyResponse(msisdn,basket.id);
        Test.stopTest();
        System.assertEquals(wrap!=null, true, 'Callout succesfull');
    } /*----------------------------------------------------------------
Method : getQualifyResponseTestFailure
Author: Aishwarya
Story: EDGE-107149
-------------------------------------------------------------------------------------*/
     @isTest
    public static void getQualifyResponseTestFailure(){
       
        
        /*String msisdn = '2459872';
        String accountNumber = 'Acc1234';*/
        Account acc=[Select id from Account where name ='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
    	List<PortInController.NumberWrapper> msisdnLst = new List<PortInController.NumberWrapper>();
        PortInController.NumberWrapper msisdn1 = new PortInController.NumberWrapper();
        msisdn1.num='2459872';
        msisdn1.accountNumber='Acc1';
        msisdn1.isSelect=true;
        msisdnLst.add(msisdn1);
        PortInController.NumberWrapper msisdn2 = new PortInController.NumberWrapper();
        msisdn2.num='24598721';
        msisdn2.accountNumber='Acc2';
         msisdn2.isSelect=true;
        msisdnLst.add(msisdn2);
        String msisdn = JSON.serialize(msisdnlst);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('failure_multiple'));
        List<PortInController.NumberWrapper> wrap =  PortInController.getMultipleQualifyResponse(msisdn,basket.id);
        Test.stopTest();
        System.assertEquals(wrap!=null, true, 'Callout succesfull');
    }
    /*----------------------------------------------------------------
Method : updateServiceQualificationTest
Author: Aishwarya
Story:EDGE-130044
-------------------------------------------------------------------------------------*/
     @isTest
    public static void updateServiceQualificationTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id limit 1];
        cscfga__Product_Configuration__c productConfig = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%']; 
        
        List<PortInController.QualifiedNumbers> qualifiedNumList = new List<PortInController.QualifiedNumbers>();
        qualifiedNumList.add(new PortInController.QualifiedNumbers(true,'61411111111'));
        qualifiedNumList.add(new PortInController.QualifiedNumbers(false,'61422222222'));
        String msisdnList = JSON.serialize(qualifiedNumList);
        Boolean status;
        Test.startTest(); 
        status = PortInController.updateServiceQualification(msisdnList,productConfig.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals(msisdnList !=Null , true, 'List not empty');
    }
    
}