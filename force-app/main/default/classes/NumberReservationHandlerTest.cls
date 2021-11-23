/*************************************************************************************************
EDGE -93081
Name: NumberReservationHandlerTest
Description: Test class for NumberReservationHandler
Author:Mahima/Ila
***************************************************************************************************/
@isTest
public class NumberReservationHandlerTest {

    public static Id basketId{get; set;}
    public static Id PCId{get; set;}
    public static List<Number__C> lstNumbers{get; set;}
    public static List<String> prodConfigs{get;set;}
    //EDGE-93081
    //Author: Mahima Gandhe
    public static void setupdata(){

        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
         Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobilityPlanSelected';
         attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='ModelString';
        attr2.cscfga__Value__c='testProductConfiguration1.id';
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        insert lstAttr;

        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Mobile Device';
        attr.cscfga__Value__c=testProductConfiguration1.id;
        attr.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attr;
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobility';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        testProductConfiguration.name='CWP Mobile Seat';
        testProductConfiguration.cscfga__Product_Definition__c=pd.id;
        update testProductConfiguration;
        PCId=testProductConfiguration.id;
       List<Number__c> lstNum= new List<Number__c>();
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId);
        lstNum.add(num);
        Number__c num1= new Number__c(Service_Number__c='62384721',Type__c='Port In',Basket__c=basketId,Product_Configuration__c= PCId);
        lstNum.add(num1);
        Number__c num2= new Number__c(Service_Number__c='61359834532',Type__c='FNN', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId,Start_Range__c='61359834532',End_Range__c='61359834534');
        lstNum.add(num2);
        Number__c num3= new Number__c(Service_Number__c='61359810332',Type__c='FNN', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId);
        lstNum.add(num3);

        insert lstNum;
        
        lstNumbers=lstNum;
        
        List<Number_Group__c> lstNumGrp= new List<Number_Group__c>();
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Number_Group__c numgrp= new Number_Group__c(Service_Number__c='62384723',Product_Configuration__c= PCId);
        lstNumGrp.add(numgrp);
        Number_Group__c numgrp2= new Number_Group__c(Service_Number__c='62384721',Product_Configuration__c= PCId);
        lstNumGrp.add(numgrp2);

        insert lstNumGrp;
        system.debug('lstNum==>'+lstNum);
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
    }
    public static void setupdataForNgUc(){
        
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
         Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobilityPlanSelected';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='ModelString';
        attr2.cscfga__Value__c='testProductConfiguration1.id';
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        insert lstAttr;
        
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Mobile Device';
        attr.cscfga__Value__c=testProductConfiguration1.id;
        attr.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attr;
        cscfga__Attribute__c attrnguc= new cscfga__Attribute__c();
        attrnguc.name ='NumberofPhoneNumbers';
        attrnguc.cscfga__Value__c='2';
        attrnguc.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attrnguc;
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Next Generation Voice';
        pd.product_Specification__c='DMCAT_ProductSpecification_000871';
        update pd;       
        testProductConfiguration.name='CWP Mobile Seat';
        testProductConfiguration.cscfga__Product_Definition__c=pd.id;
        update testProductConfiguration;
        PCId=testProductConfiguration.id;
       List<Number__c> lstNum= new List<Number__c>();
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        
        Number__c num2= new Number__c(Service_Number__c='61359834532',Type__c='FNN', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId,Start_Range__c='61359834532',End_Range__c='61359834534');
    lstNum.add(num2);
         Number__c num3= new Number__c(Service_Number__c='61359810332',Type__c='FNN', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId);
    lstNum.add(num3);

        insert lstNum;
        lstNumbers=lstNum;
        system.debug('lstNum==>'+lstNum);
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
    }

    //EDGE-97390
    //Author: Mahima Gandhe/ Ila
    public static void setupdataModify(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cspmb__Price_Item__c commProd= new cspmb__Price_Item__c(Colour__C='Red', Model__C='Apple');
        insert commProd;

    Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert cont;

    csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
      csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);

     csord__Service__c serv = new csord__Service__c();
    serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
    serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order2.id;
    serv.Primary_Contact__c = cont.Id;
    insert serv;
        system.debug('serv1'+serv);
    serv.csordtelcoa__Service_Number__c = 'SVC-000056370';
        update serv;
        system.debug('serv+' +serv);
        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobileHandsetModel';
        attr1.cscfga__Value__c=commProd.id;
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='MobileHandsetColour';
        attr2.cscfga__Value__c=commProd.id;
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        insert lstAttr;

        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Device';
        attr.cscfga__Value__c=testProductConfiguration1.id;
        attr.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attr;
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobile Subscription';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        testProductConfiguration.Type__c='Modify';
        testProductConfiguration.name='PPHH Standalone';
        testProductConfiguration.cscfga__Product_Definition__c=pd.id;
    testProductConfiguration.csordtelcoa__Replaced_Service__c=serv.id;
        update testProductConfiguration;
        PCId=testProductConfiguration.id;
       List<Number__c> lstNum= new List<Number__c>();
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId, Service_Id__c=serv.csordtelcoa__Service_Number__c);
        lstNum.add(num);
        Number__c num2= new Number__c(Service_Number__c='62384723',Type__c='FNN', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId, Service_Id__c=serv.csordtelcoa__Service_Number__c,Start_Range__c='62384722',End_Range__c='62384724');
        lstNum.add(num2);
        Number__c num1= new Number__c(Service_Number__c='62384721',Type__c='Port In',Basket__c=basketId,Product_Configuration__c= PCId);
        lstNum.add(num1);
        insert lstNum;
        lstNumbers=lstNum;
        system.debug('lstNummodify==>'+lstNum);
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        //prodConfigs = new List<String>();
        //prodConfigs.add(testProductConfiguration.id);
        //EDGE-92546 - Data Set up for getQuantityDetailTest method.
        /*cscfga__Product_Configuration__c testProductConfiguration2 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr4= new cscfga__Attribute__c();
        attr4.name ='NumberofPhoneNumbers';
        attr4.cscfga__Value__c='10';
        attr4.cscfga__Product_Configuration__c=testProductConfiguration2.id;
        insert attr4;
        cscfga__Product_Configuration__c testProductConfiguration3 = new cscfga__Product_Configuration__c();
        system.debug(testProductConfiguration3);
        cscfga__Product_Definition__c pd1=TestDataFactory.generateProductDefinition();
        pd1.Name='Next Generation Voice';
        pd1.product_Specification__c='DMCAT_ProductSpecification_000871';
        update pd1;  
        testProductConfiguration3.Type__c='Modify';
        testProductConfiguration3.name='Next Generation Voice';
        testProductConfiguration3.cscfga__Product_Definition__c=pd1.id;
        testProductConfiguration3.csordtelcoa__Replaced_Service__c=serv.id;
        testProductConfiguration3.csordtelcoa__Replaced_Product_Configuration__c = testProductConfiguration2.id;
        insert testProductConfiguration3;
        cscfga__Attribute__c attr5= new cscfga__Attribute__c();
        attr5.name ='NumberofPhoneNumbers';
        attr5.cscfga__Value__c='5';
        attr5.cscfga__Product_Configuration__c=testProductConfiguration3.id;
        insert attr5;
        //PCId=testProductConfiguration3.id;
        prodConfigs = new List<String>();
        prodConfigs.add(testProductConfiguration3.id);*/
    }

     //EDGE-92546
    //Author: Sandip Deshmane 
    public static void setQuantityData(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cspmb__Price_Item__c commProd= new cspmb__Price_Item__c(Colour__C='Red', Model__C='Apple');
        insert commProd;
    
    Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert cont;

    csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
      csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
     
     csord__Service__c serv = new csord__Service__c();
    serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
    serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order2.id;    
    serv.Primary_Contact__c = cont.Id;
    insert serv;
        system.debug('serv1'+serv);
    serv.csordtelcoa__Service_Number__c = 'SVC-000056370';  
        update serv;
        system.debug('serv+' +serv);
        
        //EDGE-92546 - Data Set up for getQuantityDetailTest method.
        cscfga__Product_Configuration__c testProductConfiguration2 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr4= new cscfga__Attribute__c();
        attr4.name ='NumberofPhoneNumbers';
        attr4.cscfga__Value__c='10';
        attr4.cscfga__Product_Configuration__c=testProductConfiguration2.id;
        insert attr4;
        cscfga__Product_Configuration__c testProductConfiguration3 = new cscfga__Product_Configuration__c();
        system.debug(testProductConfiguration3);
        cscfga__Product_Definition__c pd1=TestDataFactory.generateProductDefinition();
        pd1.Name='Next Generation Voice';
        pd1.product_Specification__c='DMCAT_ProductSpecification_000871';
        update pd1;  
        testProductConfiguration3.Type__c='Modify';
        testProductConfiguration3.name='Next Generation Voice';
        testProductConfiguration3.cscfga__Product_Definition__c=pd1.id;
        testProductConfiguration3.csordtelcoa__Replaced_Service__c=serv.id;
        testProductConfiguration3.csordtelcoa__Replaced_Product_Configuration__c = testProductConfiguration2.id;
        insert testProductConfiguration3;
        cscfga__Attribute__c attr5= new cscfga__Attribute__c();
        attr5.name ='NumberofPhoneNumbers';
        attr5.cscfga__Value__c='5';
        attr5.cscfga__Product_Configuration__c=testProductConfiguration3.id;
        insert attr5;
        //PCId=testProductConfiguration3.id;
        prodConfigs = new List<String>();
        prodConfigs.add(testProductConfiguration3.id);
    }

    //EDGE-96503
    //Author: Mahima Gandhe
    public static void setupdataUnMapped(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();

        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobilityPlanSelected';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='ModelString';
        attr2.cscfga__Value__c='testProductConfiguration1.id';
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        insert lstAttr;

        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Mobile Device';
        attr.cscfga__Value__c=testProductConfiguration1.id;
        attr.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attr;
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;

        testProductConfiguration.name='CWP Mobile Seat';
        testProductConfiguration.cscfga__Product_Definition__c=pd.id;
        update testProductConfiguration;
        PCId=testProductConfiguration.id;
       List<Number__c> lstNum= new List<Number__c>();
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basketId);
        lstNum.add(num);
        Number__c num1= new Number__c(Service_Number__c='62384721',Type__c='Port In',Basket__c=basketId);
        lstNum.add(num1);
        Number__c num2 = new Number__c(Service_Number__c='6142384724',Type__c='FNN',Basket__c=basketId);
        num2.Start_Range__c = '6142384723';
        num2.End_Range__c='6142384725';
        lstNum.add(num2);
        insert lstNum;
        lstNumbers=lstNum;
        system.debug('lstNum==>'+lstNum);
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
    }


    //EDGE-93081
    //Author: Mahima Gandhe/Ila
    @isTest
    public static void getProdConfigTest(){
        setupdata();
        system.debug(basketId);
        Test.startTest();
        //List<NumberReservationHandler.prodConfigWrapper> pcList = NumberReservationHandler.getProdConfig(basketId,'Mobile');
        //List<NumberReservationHandler.prodConfigWrapper> ngucpcList = NumberReservationHandler.getNGUCProdConfig(basketId,'Fixed');
        NumberReservationHandler.finishReservation(basketId);
        Test.stopTest();
       // System.assertEquals(pcList!=null, true);
    }

    //EDGE-93081
    //Author: Mahima Gandhe/Ila
  /*@isTest
    public static void getNumberListTest(){
        setupdata();
        Test.startTest();
        List<NumberReservationHandler.NumberWrapper> numList = NumberReservationHandler.getNumberList(basketId,'Mobile');
        Test.stopTest();
        //System.assertEquals(numList.size()!=1, true);
        System.assertEquals(numList !=Null, true);
    }*/


    //EDGE-97390
    //Author: Mahima Gandhe/Ila
  /*@isTest
    public static void getNumberListPCModifyTest(){
        setupdataModify();
        Test.startTest();
        List<NumberReservationHandler.NumberWrapper> numList = NumberReservationHandler.getNumberList(basketId,'Mobile');
        Test.stopTest();
        System.assertEquals(basketId !=Null, true);
    }*/

    //EDGE-93081
    //Author: Mahima Gandhe/Ila
    /*@isTest
    public static void reserveNumbersTest(){
         setupdata();
        List<string> selectedNumbers= new List<string>();
        for(Number__c num :lstNumbers)
        {
            selectedNumbers.add(num.id);
        }
        List<string> selectedPc= new List<string>();
        selectedPc.add(PCId);
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        selectedPc.add(testProductConfiguration.Id);
        Test.startTest();
        Boolean reserve = NumberReservationHandler.reserveNumbers(selectedPc,selectedNumbers,'Mobile',basketId);
    Boolean reserve1 = NumberReservationHandler.reserveNumbers(selectedPc,selectedNumbers,'Fixed',basketId);
        Boolean reserve2 = NumberReservationHandler.reserveNumbers(null,selectedNumbers,'Mobile',basketId);
        Test.stopTest();
        System.assertEquals(reserve!=null, true);
    }*/
/*************************************************************************************************
Name : reserveNumbersFixedTest
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
    /* @isTest
    public static void reserveNumbersFixedTest(){
        setupdata();
        List<string> selectedNumbersFixed= new List<string>();
     selectedNumbersFixed.add('61359834532 - 61359834534');

        List<string> selectedPc= new List<string>();
        //selectedPc.add(PCId);
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        selectedPc.add(testProductConfiguration.Id);
        Test.startTest();
    Boolean reserve1 = NumberReservationHandler.reserveNumbers(selectedPc,selectedNumbersFixed,'Fixed',basketId);
        Test.stopTest();
        System.assertEquals(reserve1!=null, true);
    }
*/
    //EDGE-93081
    //Author: Mahima Gandhe/Ila
    /*@isTest
    public static void unreserveNumbersTest(){
        setupdata();
        List<string> selectedNumbers= new List<string>();
        for(Number__c num :lstNumbers)
        {
            selectedNumbers.add(num.Service_Number__c);
        }
        system.debug('selectedNumbers=='+selectedNumbers);
        List<string> selectedPc= new List<string>();
        selectedPc.add(PCId);
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        selectedPc.add(testProductConfiguration.Id);
        system.debug('selectedPc=='+selectedPc);
        basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Test.startTest();
        NumberReservationHandler.unReserveNumbers(selectedPc,selectedNumbers,basketId);
        Test.stopTest();
        List<Number__c> lstnum= [select id, Type__c, Service_Number__c , Basket__c from Number__c 
                                where Basket__c=:basketId];
        System.assertEquals(lstnum.size()!=0, true);
    }*/

    //EDGE-96503
    //Author: Mahima Gandhe
   /* @isTest
    public static void finishReservationTest(){
        setupdataUnMapped();
        system.debug(basketId);
        Test.startTest();
        List<NumberReservationHandler.prodConfigWrapper> pcList = NumberReservationHandler.getProdConfig(basketId,'Mobile');
        NumberReservationHandler.ValidationWrapper vw= NumberReservationHandler.finishReservation(basketId);
        Test.stopTest();
        System.assertEquals(pcList!=null, true);
        System.assertEquals(vw.IsValid!=true, true);
    }*/

    //EDGE-96503
    //Author: Mahima Gandhe
    /*@isTest
    public static void unAssignPCNumberTest(){
        setupdata();
         Test.startTest();
        setupdataModify();
        system.debug(basketId);
        List<string> selectedPc= new List<string>();
        selectedPc.add(PCId);
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        selectedPc.add(testProductConfiguration.Id);
        system.debug('selectedPc=='+selectedPc);
        //Test.startTest();
        List<NumberReservationHandler.prodConfigWrapper> pcList = NumberReservationHandler.getProdConfig(basketId,'Mobile');
        NumberReservationHandler.unAssignPCNumber(selectedPc,basketId);
        Test.stopTest();
        System.assertEquals(pcList!=null, true);
    }*/


  //EDGE-97392,89299
    //Author: Aishwarya
    /*@isTest
    public static void getbasketStageTest(){
        setupdata();
        system.debug('basketId'+basketId);
        Test.startTest();
        String basketStage ='';
        //basketStage = NumberReservationHandler.getBasketStage(basketId);
        //Boolean isPortInValid=NumberReservationHandler.isPortInValid(basketId);
        Boolean isPopupValidation=NumberReservationHandler.isPopupValidation(basketId);
        Test.stopTest();
        System.assertEquals(basketId!=null, true);
    }*/
 //EDGE-97392
    //Author: Kalashree Borgaonkar
    /*@isTest
    public static void checkShowPortinTrueTest(){
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='ShowPortinOnScreen';
        env_var.value__c='True';
        insert env_var;
        Boolean checkPortin;
        Test.startTest();
        checkPortin = NumberReservationHandler.checkShowPortin();
        Test.stopTest();
        System.assertEquals(checkPortin==true,true,'Show Port');
    }*/
//EDGE-97392
    //Author: Kalashree Borgaonkar
    /*@isTest
    public static void checkShowPortinFalseTest(){
        EnvironmentVariable__c envVar=  new EnvironmentVariable__c();
        envVar.name='ShowPortinOnScreen';
        envVar.value__c='False';
        insert envVar;
        Boolean checkPortin;
        Test.startTest();
        checkPortin = NumberReservationHandler.checkShowPortin();
        Test.stopTest();
        System.assertEquals(checkPortin,false,'Hide Port');
    }*/

   /* //EDGE-59982
    //Author:Aishwarya Yeware
      @isTest
    public static void testDelFromReservationPool(){

    Number__c msisdn1 = new Number__c(Service_Number__c='12345678',Basket__c=basketId);
    insert msisdn1;
        Number__c msisdn2 = new Number__c(Service_Number__c='612345683',Basket__c=basketId);
        msisdn2.Start_Range__c='612345680';
        msisdn2.End_range__c='612345684';
        insert msisdn2;
        Integer count  = [SELECT count() FROM Number__c];
    //System.debug(count);
    List<String> msisdnList = new List<String>();
    msisdnList.add(msisdn1.Service_Number__c);
        List<String> msisdnListRange =  new List<String>();
        msisdnListRange.add(msisdn2);
        System.debug('msisdnList'+msisdnList);
    Test.startTest();

    NumberReservationHandler.deleteFromPoolFixed(msisdnList,basketId,msisdnListRange);

        Test.stopTest();
        System.assertEquals([SELECT count() FROM Number__c]==0,true,'Record deleted');
  }*/
 /*************************************************************************************************
Name : unreserveFNNTest
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
   /* @isTest
    public static void unreserveFNNTest(){
        setupdata();
        List<string> selectedNumbers= new List<string>{'61359834532 - 61359834534','61359810332'};

        system.debug('selectedNumbers=='+selectedNumbers);
        List<string> selectedPc= new List<string>();
        selectedPc.add(PCId);
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        selectedPc.add(testProductConfiguration.Id);
        system.debug('selectedPc=='+selectedPc);

        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('partialSuccessRange'));
        //NumberReservationFixedHandler.ResponseWrapper unres = NumberReservationHandler.unReserveFNN(selectedNumbers,basketId,'Rollback');
        NumberReservationFixedHandler.ResponseWrapper okunres = NumberReservationHandler.OKunReserveFNN(basketId);
        //NumberReservationHandler.getJobStatus(unres);
        Test.stopTest();
        System.assertEquals(testProductConfiguration!=null, true);
    }*/
 /*************************************************************************************************
Name : deleteFromPoolTest
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
    /*@isTest
    public static void deleteFromPoolTest(){
      setupdata();
        List<string> selectedNumbers= new List<string>{'61359834532 - 61359834534','61359810332'};
        List<String> startRange = new List<String>{'61359834532'};
               Test.startTest();
            NumberReservationHandler.deleteFromPoolFixed(selectedNumbers,basketId,startRange);
        Test.stopTest();
        System.assertEquals(selectedNumbers!=null, true);
    }*/
 /*************************************************************************************************
Name : splitRangeofNumTest
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
    @isTest
    public static void splitRangeofNumTest(){
        setupdata();
        String stNum='61359834532';
        String endNum = '61359834534';
        String pcId='';
        Set<String> resSet= new Set<String>{'61359834531'};
         Account acc=[Select id from Account where name ='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id limit 1];
        //EDGE-201122
        List<Number_Group__c> numGrp = [SELECT Id FROM Number_Group__c];
        Test.startTest();
        List<Number__c> numList =   NumberReservationHandler.splitRangeofNumbers(stNum,endNum,basket.Id,acc.Id,'RESERVED','FNN',null,numGrp[0].Id);
        Test.stopTest();
        system.assertEquals(numList!=null, true);
    }
    /*************************************************************************************************
Name : getQuantityDetail
Author: Sandip Deshmane
Story: EDGE-92546
***************************************************************************************************/     
    /*@isTest
    public static void getQuantityDetailTest(){
        setQuantityData();
        Test.startTest();
        Integer quantity = NumberReservationHandler.getQuantityDetail(prodConfigs);
        Test.stopTest();
        system.assertEquals(5, quantity);
    }*/
    /*************************************************************************************************
Name : ngucValidationOnEnrichTest
Author: Kalashree Borgaonkar
Story: EDGE-128633
***************************************************************************************************/ 
	/*@isTest
    public static void ngucValidationOnEnrichPositiveTest(){
        setupdataForNgUc();
        Test.startTest();
        NumberReservationHandler.ValidationWrapper vw= NumberReservationHandler.ngucValidationOnEnrich(basketId);
        Test.stopTest();
        System.assertEquals(vw.IsValid==true, true);
    }*/
    /*************************************************************************************************
Name : ngucValidationOnEnrichTest
Author: Kalashree Borgaonkar
Story: EDGE-128633
***************************************************************************************************/ 
	/*@isTest
    public static void ngucValidationOnEnrichNegativeTest(){
        setupdataForNgUc();
        List<Number__c> numberList = [SELECT id FROM Number__c where Basket__c=:basketId LIMIT 1];
        if(!numberList.isEmpty()){
            numberList[0].Product_Configuration__c=null;
        }
        update numberList;
        Test.startTest();
        NumberReservationHandler.ValidationWrapper vw= NumberReservationHandler.ngucValidationOnEnrich(basketId);
        Test.stopTest();
        System.assertEquals(vw.IsValid!=true, true);
    }*/
    
    

}