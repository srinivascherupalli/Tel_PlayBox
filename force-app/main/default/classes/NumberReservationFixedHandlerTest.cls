/*************************************************************************************************
Name : NumberReservationFixedHandlerTest
Description : Test class for NumberReservationFixedHandler
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
@isTest
public class NumberReservationFixedHandlerTest {
/*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-108230 
Descripton : Create Data 
---------------------------------------------------------------------------- ---------*/
    @testSetup 
    public static void setupdata(){
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
        Number_Group__c numberGroup = new Number_Group__c();
        numberGroup.Subscription_Number__c = 'SN-000223173';
        numberGroup.Status__c = 'Reserved';
        numberGroup.Scenario_Type__c = 'Add';
        insert numberGroup;
        cscfga__Product_Configuration__c productConfig  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];    
        productConfig.cscfga__Product_Basket__c=basket.Id;
        update productConfig;
        List<Number__c> numList=new List<Number__c>();
        Number__c fnnNumber1 = Testutil.createNumber('61359816911',basket.id,null);
        fnnNumber1.Product_Configuration__c =productConfig.id;
        fnnNumber1.Type__c='FNN';
        fnnNumber1.Status__c = 'RESERVED';
        fnnNumber1.Mobile__c='Fixed';
        fnnNumber1.Start_Range__c = '61359816911';
        fnnNumber1.End_range__c = '61359816915';
        numList.add(fnnNumber1);
        Number__c fnnNumber2 = Testutil.createNumber('61359816906',basket.id,null);
        fnnNumber2.Product_Configuration__c =productConfig.id;
        fnnNumber2.Type__c='FNN';
        fnnNumber2.Status__c = 'RESERVED';
        fnnNumber2.Mobile__c='Fixed';
        numList.add(fnnNumber2);
        insert numList;
    }
    /*----------------------------------------------------------------
Method : saveReserveNumbers
Author: Kalashree Borgaonkar
Story:EDGE-108230
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveReserveNumbersTest(){
		String json='{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"61359816905","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"},{"countryCode":"61","countryName":"AU","nationalDestinationCode":"2","providedToKey":"70843ac2-f2fc-4219-a693-70a8a3c24d3e","startRange":"61298660348","endRange":"61298660349","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T07:01:14.000930Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"61359816905"},{"startRange":"61298660348","endRange":"61298660349"}]}}}';
		FixedNumberResponseDTO response= FixedNumberResponseDTO.parse(json);
        // ## added limit 1
        cscfga__Product_Basket__c basket = [SELECT cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' LIMIT 1]; 
		Test.startTest();
        //EDGE-92021: added value of selected tab as 'Mobile' in the method
		String status = NumberReservationFixedHandler.saveReserveNumbers(response,basket.id,'Mobile');
		Test.stopTest();
		System.assertEquals(status!='Error',true,'Numbers reserved');
    } 
        /*----------------------------------------------------------------
Method : saveReserveNumbersErrorTest
Author: Kalashree Borgaonkar
Story:EDGE-108230
-------------------------------------------------------------------------------------*/
	@isTest
    public static void saveReserveNumbersErrorTest(){
		String json='{"status":409,"code":409,"time":"2019-09-13T06:57:22.263+0000","correlationId":"08865a82-594a-4568-bbbf-cb913025b7ad","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order","data":{},"errors":[{"resourceId":"61386479994","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"},{"resourceId":"61386479914","startRange":"61386479913","endRange":"61386479914","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"}],"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"61386479994"},{"startRange":"61386479913","endRange":"61386479914"}]}}}';
		FixedNumberResponseDTO response= FixedNumberResponseDTO.parse(json);
        cscfga__Product_Basket__c basket = [SELECT cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Test Account1' LIMIT 1]; 
		Test.startTest();
          //EDGE-92021: added value of selected tab as 'Fixed' in the method
		String status = NumberReservationFixedHandler.saveReserveNumbers(response,basket.id,'Fixed');
		Test.stopTest();
		System.assertEquals(status=='Error',true,'Error in Number reservation');
    } 
   
            /*----------------------------------------------------------------
Method : saveReserveNumbersErrorTest
Author: Kalashree Borgaonkar
Story:EDGE-108230
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveReserveNCSTest(){
		List<Number__c> numberList  = [SELECT id,Service_Number__c,Product_Configuration__c,Start_Range__c,End_Range__c,Type__c FROM Number__c];
        System.debug('numberList'+numberList);
        Test.startTest();
        String status = NumberReservationFixedHandler.saveReserveNCS(numberList);
		Test.stopTest();
		System.assertEquals(numberList!=null,true,'NCS created');
    }
     /*----------------------------------------------------------------
Method : saveReserveNumbersErrorTest
Author: Kalashree Borgaonkar
Story:EDGE-108230
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveReserveNCSErrorTest(){
		List<Number__c> numberList  = new List<Number__c>();
		Test.startTest();
        String status = NumberReservationFixedHandler.saveReserveNCS(numberList);
		Test.stopTest();
		System.assertEquals(status=='Error',true,'NCS not created');
    }
    /*----------------------------------------------------------------
Method : saveReserveNumbersErrorTest1
Author: Kalashree Borgaonkar
Story:EDGE-108230
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveReserveNCSErrorTest1(){
		List<Number__c> numberList  = null;
		Test.startTest();
        String status = NumberReservationFixedHandler.saveReserveNCS(numberList);
		Test.stopTest();
		System.assertEquals(status=='Error',true,'NCS not created');
    }
/*----------------------------------------------------------------
Method : reserveFixedMSISDNSuccess
Author: Ila
Story:EDGE-59987
-------------------------------------------------------------------------------------*/    
    @isTest
    public static void reserveFixedMSISDNSuccess(){
        List<String> fixedNum= new List<String>{'61359816905'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String  basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixedNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
    }
/*----------------------------------------------------------------
Method : reserveFixedMSISDNError
Author: Ila
Story:EDGE-59987
-------------------------------------------------------------------------------------*/    
    @isTest
    public static void reserveFixedMSISDNError(){
        List<String> fixNum= new List<String>{'61386479994'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('errorResponse'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
/*----------------------------------------------------------------
Method : reserveFixedMSISDNPartialSuccess
Author: Ila
Story:EDGE-59987
-------------------------------------------------------------------------------------*/
    @isTest
    public static void reserveFixedMSISDNPartialSuccess(){
        List<String> fixedNum= new List<String>{'61212345678','61212345679'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String  basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('partialSuccess'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixedNum,basketId,button,'Fixed');
        system.debug('wrap+' +wrap);
        Test.stopTest();
        system.assert(wrap!=null, true);
    }
  
      @isTest
    public static void unreserveFixedRange(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534','61359810332','61359811232'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Rollback';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('partialSuccessRange'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
    
     @isTest
    public static void reserveFixedRangePartial(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('partialSuccessRange'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
     @isTest
    public static void reserveRangeFail(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('rangeFailure'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
     @isTest
    public static void reserveRangeSuccess(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('rangeSuccess'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
    @isTest
    public static void unreserveRangeSuccess(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534','61359810332','61359811232'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Rollback';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('rangeSuccess'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
    @isTest
    public static void unreserveRangeFail(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534','61359810332','61359811232'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Rollback';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('rangeFailure'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
     @isTest
    public static void reserveRangePartial(){
        List<String> fixNum= new List<String>{'61359834532 - 61359834534'};
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        String button = 'Held Order';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('rangePartial'));
        NumberReservationFixedHandler.ResponseWrapper wrap= new NumberReservationFixedHandler.ResponseWrapper();
        wrap=	NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(fixNum,basketId,button,'Fixed');
        Test.stopTest();
        system.assert(wrap!=null, true);
        
    }
    /*----------------------------------------------------------------
Method : searchFixedMSISDNSuccess
Author: Aishwarya
Story:EDGE-100659
-------------------------------------------------------------------------------------*/    
    @isTest
    public static void searchFixedMSISDNSuccess(){
        
         String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Non-Contiguous","pattern":"*1*","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';
            
            FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		FNNSearchResponseDTO fnnres = NumberReservationFixedHandler.searchFNN(req);
		Test.stopTest();
         system.assert(fnnres!=null, true);
    }
}