/*************************************************************************************************
Name 		: PortOutReversalControllerTest
Description : test class for PortOutReversalController
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
@isTest
public class PortOutReversalControllerTest {
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
        Number__c num= new Number__c(Service_Number__c='61459834542',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',status__c='inactive');
        lstNum.add(num);
        Number__c num1= new Number__c(Service_Number__c='61459812342',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',status__c='inactive');
        lstNum.add(num1);
        System.debug('lstNum'+lstNum);
        insert lstNum; 
    }
    @isTest
    public static void createNumberRecordTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        Test.startTest();
        String result = PortOutReversalController.createNumberRecord('61459834542',Config.id,'89610182000501374304','1234','SIM card','New SIM','Existing Blank SIM');
        System.assertEquals(result.contains('SuccessMsg'),true,'Number created');
        Test.stopTest();
    }
     @isTest
    public static void finishReservationValidTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Number__c num= new Number__c(Service_Number__c='61459834112',Type__c='New', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Product_Configuration__c=Config.id);
        insert num;
        Boolean result = PortOutReversalController.finishReservation(config.cscfga__Product_Basket__c );
        System.assertEquals(result,true,'Valid');
        Test.stopTest();
    }
    
     @isTest
    public static void finishReservationInvalidTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Boolean result = PortOutReversalController.finishReservation(config.cscfga__Product_Basket__c );
        System.assertEquals(result,false,'Invalid');
        Test.stopTest();
    }
     @isTest
    public static void getisNumberValidTest(){
        Test.startTest();
        Boolean numCount = PortOutReversalController.isNumberValid('61459834542');
        System.assertEquals(numCount,true,'Number valid');
        Test.stopTest();
    }
    @isTest
    public static void getisNumberValidFalseTest(){
        Test.startTest();
        Boolean numCount = PortOutReversalController.isNumberValid('61459834111');
        System.assertEquals(numCount,false,'Number invalid');
        Test.stopTest();
    }
     @isTest
    public static void getSIMnumberTest(){
        Test.startTest();
        //EDGE-164617
       PortOutReversalHelper.NumberWithDaysLeft numb= PortOutReversalController.getSIMnumber('61459834542');
        System.assertEquals(numb.numberDetail.Sim_Serial_Number__c=='1234567890123',true,'Sim number retrieved');
        Test.stopTest();
    }

    public static void removeSelectedExceptionTest(){
        Test.startTest();
        String result = PortOutReversalController.removeSelected('61459834542');
        System.assertEquals(result!='Success',true,'Number created');
        Test.stopTest();
    }
    @isTest
    public static void removeSelectedTest(){
        Test.startTest();
        List<String> listString = new List<String>{'61459834542'};
        String result = PortOutReversalController.removeSelected(JSON.serialize(listString) );
        System.assertEquals(result!='Success',true,'Number created');
        Test.stopTest();
    }
    @isTest
    public static void getProductConfigDetailsTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c 
                                                   FROM cscfga__Product_Configuration__c 
                                                   WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        List<PortOutReversalHelper.ProductConfigWrapper> mobileDetailsWrapper = PortOutReversalController.getProductConfigDetails(Config.cscfga__Product_Basket__c);
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
        List<PortOutReversalHelper.ProductConfigWrapper> mobileDetailsWrapper = PortOutReversalController.getProductConfigDetails(Config.cscfga__Product_Basket__c);
        System.assertEquals(('1234567890123').equalsIgnoreCase(mobileDetailsWrapper[0].simSerial),true,'Mobile details fetched');
        Test.stopTest();
    }
}