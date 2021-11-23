/*************************************************************************************************
Name 		: PortOutReversalHelperTest
Description : test class for PortOutReversalHelper
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
@isTest class PortOutReversalHelperTest {
    @testSetup 
    public static void setupdata(){
        setupdataForMobile();
    }
    public static void setupdataForMobile(){    
        cscfga__Product_Configuration__c prodConfig = TestDataFactory.generateProductConfiguration();
        system.debug(prodConfig);
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='UseExitingSIM';
        attr1.cscfga__Value__c='Yes';
        attr1.cscfga__Product_Configuration__c=prodConfig.id;
        insert attr1;
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobility';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        System.debug('pd: '+pd);
        prodConfig.name='FairPlay Data - Local Data SIM';
        prodConfig.cscfga__Product_Definition__c=pd.id;
        update prodConfig;
        System.debug('prodConfig: '+prodConfig+' spec'+prodConfig.cscfga__Product_Definition__r.product_Specification__c);
        cscfga__Product_Configuration__c testconfig = [SELECT cscfga__Product_Definition__r.product_Specification__c 
                                                       FROM cscfga__Product_Configuration__c 
                                                       WHERE id=:prodConfig.id];
        System.debug('testconfig: '+testconfig.cscfga__Product_Definition__r.product_Specification__c);
        String cmpbasketId= prodConfig.cscfga__Product_Basket__c;
        List<Number__c> lstNum= new List<Number__c>();
        Number__c num= new Number__c(Service_Number__c='61459834542',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234');
        lstNum.add(num);
        Number__c num1= new Number__c(Service_Number__c='61459812342',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234');
        lstNum.add(num1);
        System.debug('lstNum'+lstNum);
        insert lstNum; 
        csord__Service__c service=TestDataFactory.generateService(); 
        service.csord__Status__c='Pending';
        service.csord__Deactivation_Date__c = Date.today().addDays((-1)*28);
        service.csordtelcoa__Service_Number__c = 'SVC-000167823';
        update service;
        System.debug('service.csordtelcoa__Service_Number__c: '+service.csordtelcoa__Service_Number__c);
        num.Service_Id__c= service.csordtelcoa__Service_Number__c;
        update num;
        system.debug('num: '+num.Service_Id__c);

    }
    @isTest
    public static void getProductConfigDetailsTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c 
                                                   FROM cscfga__Product_Configuration__c 
                                                   WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        List<PortOutReversalHelper.ProductConfigWrapper> mobileDetailsWrapper = PortOutReversalHelper.getProductConfigDetails(Config.cscfga__Product_Basket__c);
        System.assertEquals(('FairPlay Data - Local Data SIM').equalsIgnoreCase(mobileDetailsWrapper[0].name),true,'Mobile details fetched');
        Test.stopTest();
    }
     @isTest
    public static void getProductConfigDetailsWithnumberTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c 
                                                   FROM cscfga__Product_Configuration__c 
                                                   WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        Number__c num= new Number__c(Service_Number__c='61459834112',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Product_Configuration__c=Config.id);
        insert num;
        List<PortOutReversalHelper.ProductConfigWrapper> mobileDetailsWrapper = PortOutReversalHelper.getProductConfigDetails(Config.cscfga__Product_Basket__c);
        System.assertEquals(('1234567890123').equalsIgnoreCase(mobileDetailsWrapper[0].simSerial),true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void isExistingSimYesTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c 
                                                   FROM cscfga__Product_Configuration__c 
                                                   WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Number__c num= new Number__c(Service_Number__c='61459834112',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Product_Configuration__c=Config.id);
        insert num;
        cscfga__Attribute__c attr = [SELECT id, cscfga__Value__c 
                                     FROM cscfga__Attribute__c 
                                     WHERE name = 'UseExitingSIM']; 
        Boolean isExistingSim = PortOutReversalHelper.isExistingSim(attr);
        System.assertEquals(isExistingSim,true,'UseExisting selected');
        Test.stopTest();
    }
    @isTest
    public static void isExistingSimNoTest(){
        Test.startTest();
        cscfga__Attribute__c attr = [SELECT id, cscfga__Value__c FROM cscfga__Attribute__c WHERE name = 'UseExitingSIM']; 
        attr.cscfga__Value__c='No';
        update attr;
        Boolean isExistingSim = PortOutReversalHelper.isExistingSim(attr);
        System.assertEquals(isExistingSim,false,'UseExisting not selected');
        Test.stopTest();
    }
    @isTest
    public static void getSIMnumberTest(){
        Test.startTest();

        //EDGE-164617
        PortOutReversalHelper.NumberWithDaysLeft numb = PortOutReversalHelper.getSimAndImsiNumber('61459834542');
        System.assertEquals(numb.numberDetail.Sim_Serial_Number__c=='1234567890123',true,'Sim number retrieved');
        Test.stopTest();
    }

    @isTest
    public static void getSimAndImsiNumberNotFoundTest(){
        Test.startTest();
        //EDGE-164617
        PortOutReversalHelper.NumberWithDaysLeft numb = PortOutReversalHelper.getSimAndImsiNumber('61459834511');
        System.assertEquals(numb.numberDetail.Sim_Serial_Number__c==null,true,'Number not found');
        Test.stopTest();
    }

            //EDGE-164617
     @isTest
    public static void getSimAndImsiNumberExpiryTest(){
       csord__Service__c  service = [SELECT id,csord__Deactivation_Date__c, lastmodifiedDate
                                      FROM csord__Service__c 
                                      WHERE csordtelcoa__Service_Number__c = 'SVC-000167823'];
        service.csord__Deactivation_Date__c = Date.today().addDays((-1)*27);
        update service;
        Test.startTest();
        PortOutReversalHelper.NumberWithDaysLeft numb = PortOutReversalHelper.getSimAndImsiNumber('61459834542');
        System.assertEquals(numb.numberDetail.Sim_Serial_Number__c=='1234567890123',true,'Sim number retrieved');

        Test.stopTest();
    }
    @isTest
    public static void getisNumberValidTest(){
        Test.startTest();
        Boolean numCount = PortOutReversalHelper.isNumberValid('61459834542');
        System.assertEquals(numCount,true,'Number valid');
        Test.stopTest();
    }
    @isTest
    public static void getisNumberValidFalseTest(){
        Test.startTest();
        Boolean numCount = PortOutReversalHelper.isNumberValid('61459834111');
        System.assertEquals(numCount,false,'Number invalid');
        Test.stopTest();
    }
    @isTest
    public static void createNumberRecordTest(){
        //EDGE-165480 start
        csord__Service__c service = [SELECT Scenario_Type__c
                                     FROM csord__Service__c 
                                     WHERE csordtelcoa__Service_Number__c = 'SVC-000167823'];
        service.Scenario_Type__c = 'Port Out';
        update service;
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
       
        num.status__c='INACTIVE';
        num.SimAvailabilityType__c= 'Existing Blank SIM';
        num.Sim_Serial_Number__c = '89610182000501374304';
        num.isSimvalid__c =true;
        
        update num;
        //EDGE-165480 end
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        Test.startTest();
        String result = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        String resultFinal = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('SuccessMsg'),true,'Number created');
        
        Number__c numb = [SELECT SIM_Type__c,SimAvailabilityType__c FROM Number__c WHERE Service_Number__c= '61459834542' limit 1];
        System.assertEquals('SIM card',numb.SIM_Type__c);
        Test.stopTest();
    }
    
    //EDGE-165480
    @isTest
    public static void createNumberRecordInactiveTest(){
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
        num.status__c='RESERVED';
        update num;
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        String result = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'1234567890123','1234','SIM Card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('ErrorMsg'),true,'Number is not inactive');
        Test.stopTest();
    }
    //EDGE-165480 start
    @isTest
    public static void createNumberRecordNotPortOutTest(){
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
        num.status__c='INACTIVE';
        update num;
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        String result = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'1234567890123','1234','SIM Card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('ErrorMsg'),true,'Number is not ported out');
        Test.stopTest();
    }
     //EDGE-165480
    @isTest
    public static void createNumberRecordNotFoundTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        String result = PortOutReversalHelper.createNumberRecord('61459934512',Config.id,'1234567890123','1234','SIM Card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('ErrorMsg'),true,'Number is not found');
        Test.stopTest();
    }
    @isTest
    public static void removeSelectedExceptionTest(){
        Test.startTest();
        String result = PortOutReversalHelper.removeSelected('61459834542');
        System.assertEquals(result!='Success',true,'Number created');
        Test.stopTest();
    }
    @isTest
    public static void removeSelectedTest(){
        Test.startTest();
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Number__c num= new Number__c(Service_Number__c='61459834112',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Product_Configuration__c=Config.id);
        insert num;
        List<String> listString = new List<String>{Config.id};
        String result = PortOutReversalHelper.removeSelected(JSON.serialize(listString) );
        System.assertEquals(result=='Success',true,'Number created');
        Test.stopTest();
    }
    @isTest
    public static void finishReservationValidTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Number__c num= new Number__c(Service_Number__c='61459834112',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Product_Configuration__c=Config.id);
        insert num;
        Boolean result = PortOutReversalHelper.finishReservation(config.cscfga__Product_Basket__c );
        System.assertEquals(result,true,'Valid');
        Test.stopTest();
    }
    
     @isTest
    public static void finishReservationInvalidTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Boolean result = PortOutReversalHelper.finishReservation(config.cscfga__Product_Basket__c );
        System.assertEquals(result,false,'Invalid');
        Test.stopTest();
    }
    @isTest
    public static void getDaysLeftZeroTest(){
        Test.startTest();
        //EDGE-164617
        Integer daysLeft= PortOutReversalHelper.getDaysLeft('SVC-000167823');
        System.assertEquals(daysLeft==0,true,'SIM expired');
        Test.stopTest();
    }
    //EDGE-164617
    @isTest
    public static void getDaysLeftNegativeTest(){
        csord__Service__c service=TestDataFactory.generateService(); 
        service.csord__Status__c='Pending';
        service.csord__Deactivation_Date__c = Date.today().addDays((-1)*29);

        service.csordtelcoa__Service_Number__c = 'SVC-000160873';
        update service;
        System.debug('service.csordtelcoa__Service_Number__c: '+service.csordtelcoa__Service_Number__c);
        Number__c num= new Number__c(Service_Number__c='61459834142',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234');
        num.Service_Id__c= service.csordtelcoa__Service_Number__c;
        insert num;
         System.debug('service::'+service);
         System.debug('num::'+num.Service_Id__c);
        Test.startTest();
        Integer daysLeft= PortOutReversalHelper.getDaysLeft('SVC-000160873');
        System.assertEquals(daysLeft==-1,true,'SIM expired');
        Test.stopTest();
    }
    //EDGE-164617
    @isTest
    public static void getDaysLeftOneTest(){
         Number__c num = [SELECT Service_Id__c FROM Number__c WHERE service_number__c = '61459834542'];
        csord__Service__c service=TestDataFactory.generateService(); 
        service.csord__Status__c='Pending';
        service.csord__Deactivation_Date__c = Date.today().addDays((-1)*27);

        service.csordtelcoa__Service_Number__c = 'SVC-000167873';
        update service;
        System.debug('service.csordtelcoa__Service_Number__c: '+service.csordtelcoa__Service_Number__c);
        num.Service_Id__c= service.csordtelcoa__Service_Number__c;
        update num;
         System.debug('num::'+num.Service_Id__c);
        System.debug('service::'+service);
        Test.startTest();
        Integer daysLeft= PortOutReversalHelper.getDaysLeft('SVC-000167873');
        System.assertEquals(daysLeft==1,true,'SIM expires in one day');
        Test.stopTest();
    }
    //EDGE-164617
    @isTest
    public static void getDaysLeftNoDeactivationDateTest(){


        Test.startTest();
        Number__c num = [SELECT Service_Id__c FROM Number__c WHERE service_number__c = '61459834542'];
        csord__Service__c service=TestDataFactory.generateService(); 
        service.csord__Status__c='Pending';
        service.csord__Deactivation_Date__c = null;
        service.csordtelcoa__Service_Number__c = 'SVC-000167893';
        update service;
        System.debug('service.csordtelcoa__Service_Number__c: '+service.csordtelcoa__Service_Number__c);
        num.Service_Id__c= service.csordtelcoa__Service_Number__c;
        update num;
 System.debug('num::'+num.Service_Id__c);
        System.debug('service::'+service);
        Integer daysLeft= PortOutReversalHelper.getDaysLeft('SVC-000167893');
        System.assertEquals(daysLeft!=null,true,'SIM expires in one day');
        Test.stopTest();
    }

    //EDGE-165480
    @isTest
    public static void getcheckInactiveNumberTest(){
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
        num.status__c='RESERVED';
        update num;
        Test.startTest();
        String validationMsg= PortOutReversalHelper.checkInactiveAndPortedOutNumber('61459834542');
        System.assertEquals(validationMsg.contains('ErrorMsg'),true,'SIM is not inactive');
        Test.stopTest();
    }
    //EDGE-165480
    @isTest
    public static void getcheckPortedOutNumberTest(){
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
        num.status__c='INACTIVE';
        update num;
        Test.startTest();
        String validationMsg= PortOutReversalHelper.checkInactiveAndPortedOutNumber('61459834542');
        System.assertEquals(validationMsg.contains('ErrorMsg'),true,'Scenario Type is not port out');
        Test.stopTest();
    }
    @isTest
    public static void cafMandatoryOnEnrichBasketTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Boolean result = PortOutReversalHelper.cafMandatoryOnEnrichBasket(config.cscfga__Product_Basket__c );
        System.assertEquals(result,true,'Valid basket');
        Test.stopTest();
    }    
    @isTest
    public static void valiSIMSerialNumberTest(){
        //EDGE-170886 start
        csord__Service__c service = [SELECT Scenario_Type__c
                                     FROM csord__Service__c 
                                     WHERE csordtelcoa__Service_Number__c = 'SVC-000167823'];
        service.Scenario_Type__c = 'Port Out';
        update service;
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
       
        num.status__c='INACTIVE';
        num.SimAvailabilityType__c= 'Existing Blank SIM';
        num.Sim_Serial_Number__c = '8200050137442';
        num.isSimvalid__c =true;
        
        update num;
        //EDGE-165480 end
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        Test.startTest();
        String result = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        String resultFinal = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('SuccessMsg'),true,'Number created');
       
        Test.stopTest();
    }
    @isTest
    public static void inValiSIMSerialNumberTest(){
        //EDGE-170886 start
        csord__Service__c service = [SELECT Scenario_Type__c
                                     FROM csord__Service__c 
                                     WHERE csordtelcoa__Service_Number__c = 'SVC-000167823'];
        service.Scenario_Type__c = 'Port Out';
        update service;
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
       
        num.status__c='INACTIVE';
        num.SimAvailabilityType__c= 'New Sim';
        num.isSimvalid__c =true;
        
        update num;
        //EDGE-165480 end
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
       // Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        Test.startTest();
        
        String result = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        String resultFinal = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('ErrorMsg'),false,'Serial you entered is not valid');
                
        Test.stopTest();
    }
    @isTest
    public static void valiSIMSerialNumberCMPTest(){
        //EDGE-170886 start
        csord__Service__c service = [SELECT Scenario_Type__c
                                     FROM csord__Service__c 
                                     WHERE csordtelcoa__Service_Number__c = 'SVC-000167823'];
        service.Scenario_Type__c = 'Port Out';
        update service;
        Number__c num = [SELECT status__c FROM Number__c WHERE service_number__c = '61459834542'];
       
        num.status__c='INACTIVE';
        num.SimAvailabilityType__c= 'New Sim';
        num.Sim_Serial_Number__c = '89610182000501374304';
        num.isSimvalid__c =true;
        
        update num;
        //EDGE-165480 end
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        Test.startTest();
        
        String result = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        String resultFinal = PortOutReversalHelper.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('SuccessMsg'),true,'Number created');       
       
                
        Test.stopTest();
    }
}