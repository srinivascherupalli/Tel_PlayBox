/*************************************************************************************************
Name        : NumberReservationController
Description :Controller class for Modified Number Reservation 
Author      :Kalashree Borgaonkar
Story       : EDGE-140792
modification: 
1.DIGI-3161  added by shubhi 
***************************************************************************************************/
@isTest
public class NumberReservationControllerTest {
    public static Id cmpbasketId;
    public static Id ngucbasketId;
    @testSetup 
    public static void setupdata(){
        setupdataForMobile();
        setupdataForNgUc();
        System.debug('ngucbasketId::::'+ngucbasketId);
    }
    public static void setupdataForMobile(){    
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cscfga__Product_Configuration__c prodConfig = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobilityPlanSelected';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=prodConfig.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='ModelString';
        attr2.cscfga__Value__c='prodConfig.id';
        attr2.cscfga__Product_Configuration__c=prodConfig.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=prodConfig.id;
        lstAttr.add(attr3);
        insert lstAttr;
        cscfga__Product_Configuration__c prodConfig2 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Mobile Device';
        attr.cscfga__Value__c=prodConfig.id;
        attr.cscfga__Product_Configuration__c=prodConfig2.id;
        insert attr;
        system.debug(prodConfig2);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobility';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        prodConfig2.name='CWP Mobile Seat';
        prodConfig2.cscfga__Product_Definition__c=pd.id;
        update prodConfig2;
        cmpbasketId= prodConfig2.cscfga__Product_Basket__c;
        List<Number__c> lstNum= new List<Number__c>();
        Number__c num= new Number__c(Service_Number__c='61359839532',Type__c='New', Mobile__c='Mobile', Basket__c=prodConfig2.cscfga__Product_Basket__c,Product_Configuration__c=prodConfig2.id);
        lstNum.add(num);
        Number__c num1= new Number__c(Service_Number__c='62384721',Type__c='Port In',Basket__c=prodConfig2.cscfga__Product_Basket__c,Product_Configuration__c= prodConfig2.id);
        lstNum.add(num1);
        Number__c num2= new Number__c(Service_Number__c='61359834532',Type__c='FNN', Mobile__c='Mobile', Basket__c=prodConfig2.cscfga__Product_Basket__c,Product_Configuration__c= prodConfig2.id,Start_Range__c='61359834532',End_Range__c='61359834534');
        lstNum.add(num2);
        Number__c num3= new Number__c(Service_Number__c='61359810332',Type__c='FNN', Mobile__c='Mobile', Basket__c=prodConfig2.cscfga__Product_Basket__c,Product_Configuration__c= prodConfig2.id);
        lstNum.add(num3);
        Number__c num4= new Number__c(Service_Number__c='61359810334',Type__c='FNN', Mobile__c='Mobile',Status__c ='RESERVED', 
                                      Basket__c=prodConfig2.cscfga__Product_Basket__c);
        lstNum.add(num4);
        insert lstNum;
    }
    public static void setupdataForNgUc(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cscfga__Product_Configuration__c prodConfig1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobilityPlanSelected';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=prodConfig1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='ModelString';
        attr2.cscfga__Value__c='prodConfig1.id';
        attr2.cscfga__Product_Configuration__c=prodConfig1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=prodConfig1.id;
        lstAttr.add(attr3);
        insert lstAttr;
        
        cscfga__Product_Configuration__c prodConfig2 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Mobile Device';
        attr.cscfga__Value__c=prodConfig1.id;
        attr.cscfga__Product_Configuration__c=prodConfig2.id;
        insert attr;
        cscfga__Attribute__c attrnguc= new cscfga__Attribute__c();
        attrnguc.name ='NumberofPhoneNumbers';
        attrnguc.cscfga__Value__c='2';
        attrnguc.cscfga__Product_Configuration__c=prodConfig2.id;
        insert attrnguc;
        system.debug(prodConfig2);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Next Generation Voice';
        pd.product_Specification__c='DMCAT_ProductSpecification_000871';
        update pd;       
        prodConfig2.name='CWP Mobile Seat';
        prodConfig2.cscfga__Product_Definition__c=pd.id;
        update prodConfig2;
        ngucbasketid= prodConfig2.cscfga__Product_Basket__c;
        List<Number__c> lstNum= new List<Number__c>();
        Number__c num2= new Number__c(Service_Number__c='61359834532',Type__c='FNN', Mobile__c='Mobile', Basket__c=ngucbasketId,Product_Configuration__c= prodConfig2.id,Start_Range__c='61359834532',End_Range__c='61359834534');
        lstNum.add(num2);
        Number__c num3= new Number__c(Service_Number__c='61359810332',Type__c='FNN', Mobile__c='Mobile', Basket__c=ngucbasketId,Product_Configuration__c= prodConfig2.id);
        lstNum.add(num3);
        insert lstNum;    
    }
    @isTest
    public static void getProdConfigMobileReactivateTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> mobileDetailsWrapper = NumberReservationController.getAllProductConfig(Config.cscfga__Product_Basket__c,'Mobile','reactiveServices');
        System.assertEquals(mobileDetailsWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
     @isTest
    public static void getProdConfigMobileTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> mobileDetailsWrapper = NumberReservationController.getAllProductConfig(Config.cscfga__Product_Basket__c,'Mobile','New');
        System.assertEquals(mobileDetailsWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void getProdConfigFixedTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> FixedDetailsWrapper = NumberReservationController.getAllProductConfig(Config.cscfga__Product_Basket__c,'Fixed','New');
        System.assertEquals(FixedDetailsWrapper!=null,true,'Fixed details fetched');
        Test.stopTest();
    }
    @isTest
    public static void SearchInitialdataMobileTest(){
        Test.startTest();
        NumberReservationController.NumberReserve mobileInitialize = NumberReservationController.SearchInitialdata('Mobile');
        System.assertEquals(mobileInitialize!=null,true,'Mobile details');
        Test.stopTest();
    }
    @isTest
    public static void SearchInitialdataFixedTest(){
        Test.startTest();
        NumberReservationController.NumberReserve mobileInitialize = NumberReservationController.SearchInitialdata('Fixed');
        System.assertEquals(mobileInitialize!=null,true,'Fixed details');
        Test.stopTest();
    }
    @IsTest public static void checkForPartnerUserTest(){
        Test.startTest();
        Boolean isPartner= NumberReservationController.checkForPartnerUser();
        Test.stopTest();
        system.assertEquals(isPartner, false);
    }
    @IsTest public static void searchNumbersMobileTest(){
        NumberReservationController.NumberReserve numReserve = new  NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        String searchString = JSON.serialize(numReserve);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        NumberReservationController.searchResult lrmWrpperList = NumberReservationController.searchNumbers(searchString,'Mobile');
        Test.stopTest();
        system.assertEquals(lrmWrpperList!=null,true,'Search for Mobile numbers');
    }
    @IsTest public static void searchNumbersFixedTest(){ 
        Test.startTest();
        NumberReservationController.NumberReserve numReserve = new  NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        String searchString = JSON.serialize(numReserve);
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        NumberReservationController.searchResult lrmWrpperList = NumberReservationController.searchNumbers(searchString,'Fixed');
        Test.stopTest();
        system.assertEquals(lrmWrpperList!=null,true,'Search for Mobile numbers');
    }
    @IsTest public static void autoReserveMSISDNTest(){ 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        String result = NumberReservationController.autoReserveMSISDN(cmpbasketId,1);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Auto reserve');
    }
    @IsTest public static void reserveNumbersSuccessTest(){ 
        List<String> numberList = new List<String>{'61352326786','61352326186'};
        String reserveString = JSON.serialize(numberList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        String result = NumberReservationController.reserveNumbers(reserveString,'Mobile',cmpbasketId);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Reserve Success');
    }
    @IsTest public static void reserveNumbersFailureTest(){ 
        List<String> numberList = new List<String>{'61352326786','61352326186'};
        String reserveString = JSON.serialize(numberList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('errorResponse'));
        String result = NumberReservationController.reserveNumbers(reserveString,'Mobile',cmpbasketId);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Reserve Failure');
    }
    @IsTest public static void removeNumbersFromPoolFixedTest(){ 
        List<String> numberList = new List<String>{'61359834532'};
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        System.debug('ngucbasketId::::'+Config.cscfga__Product_Basket__c);
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationFixedHandler.ResponseWrapper responseWrapper = NumberReservationController.removeNumbersFromPool(numberList,Config.cscfga__Product_Basket__c,'Fixed');
        Test.stopTest();
        system.assertEquals(responseWrapper!=null,true,'UnReserve success');
    }
        @IsTest public static void removeNumbersFromPoolMobileTest(){ 
        List<String> numberList = new List<String>{'62384723'};
        cscfga__Product_Configuration__c Config = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationFixedHandler.ResponseWrapper responseWrapper = NumberReservationController.removeNumbersFromPool(numberList,Config.cscfga__Product_Basket__c,'Mobile');
        Test.stopTest();
        system.assertEquals(responseWrapper!=null,true,'UnReserve success');
    }
    @IsTest public static void removeAssignedNumbersMobileTest(){ 
        
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        Test.startTest();
        String result = NumberReservationController.removeAssignedNumbers(pcList,configList[0].cscfga__Product_Basket__c,'Mobile');
        Test.stopTest();
        system.assertEquals(result!=null,true,'Unassigned Mobile numbers');
    }
    @IsTest public static void removeAssignedNumbersFixedTest(){ 
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        Test.startTest();
        String basketid= ngucbasketId;
        String result = NumberReservationController.removeAssignedNumbers(pcList,configList[0].cscfga__Product_Basket__c,'Fixed');
        Test.stopTest();
        system.assertEquals(result!=null,true,'Unassigned Fixed numbers');
    }
    @IsTest public static void assignNumbersFixedTest(){ 
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numberList = new List<Number__c> ();
        Number__c numbers = TestUtil.createNumber('61259834532', configList[0].cscfga__Product_Basket__c, null);
        insert numbers;
        numberList.add(numbers);
        List<String> selectedNumList = new List<String>();
        for(Number__c num : numberList){
            selectedNumList.add(num.Service_Number__c);
        }
        selectedNumList.add('61359810332');
        Test.startTest();
         String transitionWrapperList='[{"Service_Id":"0394726200-0394726299","Id":"0394726200-0394726299","Reserve_status":"completed","Reason":"","productConfigId":"'+configList[0].Id+'","transitionId":"61591d79-017a-4072-9f71-7b0004d00016","CIDN":"2804506976","FNN":"0394726200","basketId":"'+configList[0].cscfga__Product_Basket__c+'","fromNumber":"0394726200","toNumber":"0394726299","accountId":"0012N00000DuSriQAF","service_type":"Fixed","productFamily":"TIPT-SIPC","tramasStatus":"Completed","tramasReason":"","isgreyedout":true,"ADBOR_Id":"L9256 QUEEN ST       MELBOURNE"}]';
        Object result = NumberReservationController.assignNumbers(pcList,selectedNumList,'Fixed',ngucbasketid,'SIM Card','Existing Active SIM','Transition',transitionWrapperList);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Unassigned Fixed numbers');
    }
    @IsTest public static void assignNumbersFixed2Test(){ 
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numberList = new List<Number__c> ();
        Number__c numbers = TestUtil.createNumber('61259834532', configList[0].cscfga__Product_Basket__c, null);
        insert numbers;
        numberList.add(numbers);
        List<String> selectedNumList = new List<String>();
        for(Number__c num : numberList){
            selectedNumList.add(num.Service_Number__c);
        }
        selectedNumList.add('61359810332');
        Test.startTest();
        Object result = NumberReservationController.assignNumbers(pcList,selectedNumList,'Fixed',configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Others','');
        Test.stopTest();
        system.assertEquals(result!=null,true,'Unassigned Fixed numbers');
    }
        @IsTest public static void assignNumbersMobileTest(){ 
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE  name = 'CWP Mobile Seat' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numberList = new List<Number__c> ();
        Number__c numbers = TestUtil.createNumber('61259834532', configList[0].cscfga__Product_Basket__c, null);
        insert numbers;
        numberList.add(numbers);
        List<String> selectedNumList = new List<String>();
        for(Number__c num : numberList){
            selectedNumList.add(num.Service_Number__c);
        }
        selectedNumList.add('62384723');
        Test.startTest();
        Object result = NumberReservationController.assignNumbers(pcList,selectedNumList,'Mobile',configList[0].id,'SIM Card','Existing Active SIM','Others','');
        Test.stopTest();
        system.assertEquals(result!=null,true,'Unassigned Fixed numbers');
    }
     @IsTest public static void getreserveNumbersTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Test.startTest();
        List<NumberReservationHelper.EachRecord> eachRecordList= NumberReservationController.getreserveNumbers(Config.cscfga__Product_Basket__c,'New');
        Test.stopTest();
        system.assertEquals(eachRecordList!=null, true,'table created');
        
    }
    @IsTest public static void finishReservationMobileTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationController.finishReservationbtn(Config.cscfga__Product_Basket__c,'Mobile');
        Test.stopTest();
        //system.assertEquals(validationWrapper!=null, true,'table created');
        
    }
     @IsTest public static void finishReservationFixedTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationController.finishReservationbtn(Config.cscfga__Product_Basket__c,'Fixed');
        Test.stopTest();
        system.assertEquals(validationWrapper!=null, true,'table created');
        
    }
    @IsTest public static void OKunReserveFNNTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        Test.startTest();
        NumberReservationFixedHandler.ResponseWrapper validationWrapper = NumberReservationController.OKunReserveFNN(Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(validationWrapper!=null, true,'table created');
        
    }
    @IsTest public static void getsimDetailsTest(){ 
       
        Test.startTest();
        NumberReservationController.simDetails details= NumberReservationController.getsimDetails();
        Test.stopTest();
        system.assertEquals(details!=null, true,'Details received');
        
    }
    /* @IsTest public static void getPortOutReversalRadioTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        Test.startTest();
        Boolean showRadio = NumberReservationController.getPortOutReversalRadio(Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(showRadio==false, true,'Hide port out radio');
        
    }*/
    @isTest
    public static void getRadioOptionsTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        Config.subtype__c = Label.Reactivate_subScenario;
        update Config;
        
        Test.startTest();
        NumberReservationHelper.RadioOptionsWrapper radioOptions = NumberReservationController.getRadioOptions(Config.cscfga__Product_Basket__c);
        System.assertEquals(radioOptions.showPortOutReversal,false,'Show Portout Reversal button');
        Test.stopTest();
    }
    @IsTest public static void updateNumberRecsTest(){
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359834532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM card';
            recs.newExistingSim = 'Existing Active SIM';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data);
        Test.startTest();
          String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'reactiveServices');
            List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                         WHERE Service_Number__c=:recs.assignedNumber limit 1];
            system.assertEquals(objnumber[0].SimAvailabilityType__c == 'Existing Active SIM', true);
          system.assertEquals(objnumber[0].SIM_Type__c == 'SIM card', true);
        Test.stopTest();
        system.debug('response>>>>>'+response);
    }
   @IsTest public static void updateNumberRecsTest2(){
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359834532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM Card';
            recs.newExistingSim = 'Existing Active SIM';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data);
           Test.startTest();
               String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'New');
               List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                            WHERE Service_Number__c=:recs.assignedNumber limit 1];
               system.assertEquals(objnumber[0].SimAvailabilityType__c != 'Existing Active SIM', false);
           Test.stopTest();
        system.debug('response>>>>>'+response);
    }
     @IsTest public static void updateNumberRecsNewSimTest(){
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359834532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM card';
            recs.newExistingSim = 'New SIM';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data);
        Test.startTest();
          String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'reactiveServices');
            List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                         WHERE Service_Number__c=:recs.assignedNumber limit 1];
            system.assertEquals(objnumber[0].SimAvailabilityType__c == 'New SIM', true);
          system.assertEquals(objnumber[0].SIM_Type__c == 'SIM card', true);
        Test.stopTest();
        system.debug('response>>>>>'+response);
    }
     @IsTest public static void updateNumberRecsBlankSimTest(){
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359834532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM card';
            recs.newExistingSim = 'Existing Blank SIM';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data);
        Test.startTest();
          String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'reactiveServices');
            List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                         WHERE Service_Number__c=:recs.assignedNumber limit 1];
            system.assertEquals(objnumber[0].SimAvailabilityType__c == 'Existing Blank SIM', true);
          system.assertEquals(objnumber[0].SIM_Type__c == 'SIM card', true);
        Test.stopTest();
        system.debug('response>>>>>'+response);
    }
    @IsTest 
    public static void updateNumberRecsBlankNoSIMTest(){
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Number__c num = [SELECT Sim_Serial_Number__c FROM Number__c WHERE Service_Number__c = '61359839532'];
        num.Sim_Serial_Number__c = '14587458965';
        update num;
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359839532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM card';
            recs.newExistingSim = 'Existing Blank SIM';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data); 
        Test.startTest();
          String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'reactiveServices');
            List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                         WHERE Service_Number__c=:recs.assignedNumber limit 1];
            system.assertEquals(objnumber[0].SimAvailabilityType__c == 'Existing Blank SIM', true);
          system.assertEquals(objnumber[0].SIM_Type__c == 'SIM card', true);
        Test.stopTest();
        system.debug('response>>>>>'+response);
    }
    @IsTest 
    public static void updateNumberRecsBlankWithSIMTest(){
        List<String> NumList = new List<String>();
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Number__c num = [SELECT Sim_Serial_Number__c FROM Number__c WHERE Service_Number__c = '61359839532'];
        num.Sim_Serial_Number__c = '14587458965';
        update num;
        NumList.add(num.Sim_Serial_Number__c);
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359839532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM card';
            recs.newExistingSim = 'Existing Blank SIM';
         recs.simSerialNumber = '14587458965';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data); 
        Test.startTest();
          String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'reactiveServices');
            List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                         WHERE Service_Number__c=:recs.assignedNumber limit 1];
            system.assertEquals(objnumber[0].SimAvailabilityType__c == 'Existing Blank SIM', true);
          system.assertEquals(objnumber[0].SIM_Type__c == 'SIM card', true);
        NumberReservationController.validateSimSerNumberCtrl(NumList);
        Test.stopTest();
        system.debug('response>>>>>'+response);
    }
     @IsTest 
    public static void updateNumberRecsActiveWithSIMTest(){
        List<NumberReservationController.pcrecords> lstrec = new List<NumberReservationController.pcrecords>();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        Number__c num = [SELECT Sim_Serial_Number__c FROM Number__c WHERE Service_Number__c = '61359839532'];
        num.Sim_Serial_Number__c = '14587458965';
        num.SimAvailabilityType__c = 'Existing Active SIM';
        update num;
        NumberReservationController.pcrecords recs = new NumberReservationController.pcrecords();
            recs.assignedNumber = '61359839532';
            recs.id = Config.id;
            recs.planName = 'Handheld-Enhanced';
            recs.simType = 'SIM card';
            recs.newExistingSim = 'Existing Active SIM';
         recs.simSerialNumber = '145874585';
        lstrec.add(recs);
        String data = JSON.serialize(lstrec);
        system.debug('data>>>>>'+data); 
        Test.startTest();
          String response = NumberReservationController.updateNumberRecs(Config.cscfga__Product_Basket__c, data,'SIM card', false,'reactiveServices');
            List<Number__c> objnumber = [Select id,SimAvailabilityType__c,SIM_Type__c FROM Number__c 
                                         WHERE Service_Number__c=:recs.assignedNumber limit 1];
           
          system.assertEquals(objnumber[0].SIM_Type__c == 'SIM card', true);
        Test.stopTest();
        system.debug('response>>>>>'+response);
    }
     
     //EDGE-168641 : code coverage for SIM Configurration from custom meta data
     @IsTest public static void getSIMConfigurationTest()
     { 
        Test.startTest();
        List<Object> customRecords=NumberReservationController.getSIMConfiguration();
        Test.stopTest();
        system.assertEquals(customRecords.size()>0,true);
    }
     @IsTest public static void validatSimSerialCalloutTest()
     { 
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE name = 'CWP Mobile Seat'];
        String prodConfig  = '[{"assignedNumber":"61459834542","basketName":"BT000-199-877","color":"BLACK","config.Id":"'+Config.id+'","Id":"'+Config.id+'","isDisabled":true,"isngEMPresent":false,"isSelected":true,"model":"APPLE IPHONE 11 128GB 4GX","newExistingSim":"Existing Blank SIM","planName":"Committed Data-Professional","productConfig":"Committed Data-Professional","simSerialNumber":"8200050137412","simType":"SIM card"}]';
        String selectedProductConfig  = '[{"assignedNumber":"61459834542","basketName":"BT000-199-877","color":"BLACK","config.Id":"'+Config.id+'","Id":"'+Config.id+'","isDisabled":true,"isngEMPresent":false,"isSelected":true,"model":"APPLE IPHONE 11 128GB 4GX","newExistingSim":"Existing Blank SIM","planName":"Committed Data-Professional","productConfig":"Committed Data-Professional","simSerialNumber":"8200050137412","simType":"SIM card"}]';
         Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));

         Test.startTest();
        List<NumberReservationHelper.prodConfigWrapper>  prodConfigList=NumberReservationController.validatSimSerialCallout(selectedProductConfig,prodConfig,Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(prodConfigList.size()>0,true,'Product config list retrieved');
    }
     @isTest
    public static void assignSIMTest(){
        Test.startTest();
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c,Id,Name 
                                                   FROM cscfga__Product_Configuration__c WHERE name = 'CWP Mobile Seat'];
        String pcWrapper = '[{"assignedNumber":"61459834542","basketName":"BT000-200-757","configId":"'+Config.id+'","Id":"'+Config.id+'","isDisabled":true,"isngEMPresent":true,"isSelected":true,"planName":"Handheld-Essential","productConfig":"Handheld-Essential","solution":"Handheld-Essential"}]';
        String result = NumberReservationController.assignSIM(pcWrapper,Config.cscfga__Product_Basket__c,'SIM Card','Existing Active SIM');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }

     @isTest
    public static void checkReactivateServicesAbsentTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT subtype__c,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c  WHERE name = 'CWP Mobile Seat'];
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        Boolean isReactivateServicePresent = NumberReservationController.checkReactivateServices(Config.cscfga__Product_Basket__c);
        System.assertEquals(isReactivateServicePresent,false,'Reactivate service not present');
        Test.stopTest();
    }
    //DIGI-3161 added by shubhi 
    @isTest
    public static void logTransactionTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        NumberReservationController.logTransaction('Auto Reserve',Config.cscfga__Product_Basket__c,'10','Auto Reserve initiated');
        string correlationid='%'+Config.cscfga__Product_Basket__c+'%';
        List<Transaction_log__c> getTransactionLog = [select Id from Transaction_log__c where CorrelationId__c LIKE :correlationid ];
        System.assertEquals(correlationid,'%'+Config.cscfga__Product_Basket__c+'%');
        Test.stopTest();
    }
   

 }