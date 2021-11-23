/*************************************************************************************************
Name     : NumberReservationController
Description :Controller class for Modified Number Reservation 
Author    :Kalashree Borgaonkar
Story    :  EDGE-140792

***************************************************************************************************/
 
@isTest
public class NumberReservationHelperFnnTest {
     @testSetup 
    public static void setupdata(){
         setupdataForNgUc();  
    }  
    public static void setupdataForNgUc(){
        String ngucbasketid;
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
        prodConfig2.name='Next Generation Voice';
        prodConfig2.cscfga__Product_Definition__c=pd.id;
        update prodConfig2;
        ngucbasketid= prodConfig2.cscfga__Product_Basket__c;
        List<Number__c> lstNum= new List<Number__c>();
        Number__c num2= new Number__c(Service_Number__c='61359834532',Type__c='FNN', Mobile__c='Fixed', Basket__c=ngucbasketId,Product_Configuration__c= prodConfig2.id,Start_Range__c='61359834532',End_Range__c='61359834534');
        lstNum.add(num2);
        Number__c num3= new Number__c(Service_Number__c='61359810352',Type__c='FNN', Mobile__c='Fixed', Basket__c=ngucbasketId,Product_Configuration__c= prodConfig2.id);
        lstNum.add(num3);
        System.debug('lstNum'+lstNum);
        
        insert lstNum;  
       
    }
    @isTest
    public static void createPayloadContiguousNoPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Contiguous';
        numReserve.selectedPatternType='None';
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
     @isTest
    public static void createPayloadNonContiguousMobileTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='None';
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Mobile');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadContiguousStartswithPatternTest(){
        cscrm__Address__c address = TestUtil.createAddress();
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Contiguous';
        numReserve.selectedPatternType='Starts With';
        numReserve.reqPattern=123;
        numReserve.selectedAreaCode = '123';
        numReserve.deliveryAddress = address;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousStartwithPatternTest(){       
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='Starts With';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadContiguousContainsPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Contiguous';
        numReserve.selectedPatternType='Contains';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousContainsPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='Contains';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousEndwithPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='Ends With';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
     /******************************************************************
EDGE-126317
Method:getPatternType 
Author:Kalashree Borgaonkar
*******************************************************************/ 
    @isTest
    public static void getPatternTypeTest(){
        Test.startTest();
        List<SelectOptionz> selectOptions = NumberReservationHelper.getPatternType('Contiguous');
        Test.stopTest();
        System.assertEquals(selectOptions!=null,true,'Options retrieved');
    }
     @isTest
    public static void assignFixedNumbersRangeTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
    List<String> numberList = new List<String> ();
        numberList.add('61359834532 -61359834534');
        String result = NumberReservationHelper.assignFixedNumbers(pcList,numberList,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Fixed','Others');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }

     @isTest
    public static void assignFixedNumbersTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Definition__r.name = 'Next Generation Voice' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
    List<String> numberList = new List<String> ();
        numberList.add('61359834552');
        String result = NumberReservationHelper.assignFixedNumbers(pcList,numberList,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Fixed','Others');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }

       
    
     @IsTest public static void reserveNumbersFixedSuccessTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        List<String> numberList = new List<String>{'61352326786','61352326186'};
        String reserveString = JSON.serialize(numberList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        String result = NumberReservationHelper.reserveNumbers(reserveString,'Fixed',Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Reserve Success');
        }
    @IsTest public static void removeNumbersFromPoolFixedTest(){ 
        List<String> numberList = new List<String>{'61359834532'};
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        System.debug('ngucbasketId::::'+Config.cscfga__Product_Basket__c);
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationFixedHandler.ResponseWrapper responseWrapper = NumberReservationHelper.unreserveFixedNumbers(numberList,Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(responseWrapper!=null,true,'UnReserve success');
    }

    @IsTest public static void deleteFromPoolFixedTest(){ 
        List<String> numberList = new List<String>{'61459834542'};
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationHelper.deleteFromPoolFixed(numberList,Config.cscfga__Product_Basket__c,null);
        Test.stopTest();
        system.assertEquals(numberList!=null,true,'UnReserve success');
    }
    @IsTest public static void deleteFromPoolFixedRangeTest(){ 
        List<String> numberList = new List<String>{'61459834542'};
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        List<String> startRange = new List<String>{'61359834532'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationHelper.deleteFromPoolFixed(numberList,Config.cscfga__Product_Basket__c,startRange);
        Test.stopTest();
        system.assertEquals(startRange!=null,true,'UnReserve success');
    }
    @IsTest public static void deleteFromPoolFixedRangeOnlyTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        List<String> startRange = new List<String>{'61359834532'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationHelper.deleteFromPoolFixed(null,Config.cscfga__Product_Basket__c,startRange);
        Test.stopTest();
        system.assertEquals(startRange!=null,true,'UnReserve success');
    }

     @isTest
    public static void getProdConfigFixedTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.finishReservationFixed(Config.cscfga__Product_Basket__c);
        System.assertEquals(validationWrapper!=null,true,'Fixed details fetched');
        Test.stopTest();
    }
     @isTest
    public static void finishReservationFixedTest(){
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> fixedDetailsWrapper = NumberReservationHelper.getNGUCProdConfig(Config.cscfga__Product_Basket__c,'Fixed');
        System.assertEquals(fixedDetailsWrapper!=null,true,'Fixed details fetched');
        Test.stopTest();
    }
    @IsTest public static void unreserveFNNTest(){ 
        List<String> numberList = new List<String>{'61459834542'};
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Next Generation Voice'];
        List<String> startRange = new List<String>{'61359834532'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationFixedHandler.ResponseWrapper wrapper=NumberReservationHelper.unReserveFNN(numberList,Config.cscfga__Product_Basket__c,'Rollback');
        Test.stopTest();
        system.assertEquals(wrapper!=null,true,'UnReserve success');
    }
}