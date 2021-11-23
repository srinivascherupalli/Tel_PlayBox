@isTest
public class MSISDNServiceTest {
    @isTest
    public static void testSearchMSISDN(){
        FNNDTO dto = new FNNDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        fdo.geoParam = '1234';
        fdo.geoParamValue =  '1234';
        fdo.addressId = '123456789';
        fdo.quantity = 1;
        fdo.pattern = 'horz';
        fdo.searchType = 'Random';
        fdo.systemId = 'SFDC';
        dto.data = fdo;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('success_Search'));
        FNNResponseDTO fnnRes=MSISDNService.searchMSISDN(dto);
        System.debug('Search_Success::' + fnnRes);
        Test.stopTest();
        System.assertNotEquals(fnnRes, NULL);
    }
    
    @isTest
    public static void testSearchError(){
        MSISDNService.searchMSISDN(NULL);
        FNNDTO dto = new FNNDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Error'));
        FNNResponseDTO fnnRes=MSISDNService.searchMSISDN(dto);
        System.debug('Search_Error::' + fnnRes);
        Test.stopTest();
        System.assertNotEquals(fnnRes, NULL);
    }
    
    @isTest
    public static void testMSISDNService(){
        Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
        List<String> fnnListToReserve = new List<String>();
        fnnListToReserve.add('7282345560');
        fnnListToReserve.add('7282345561');
        fnnListToReserve.add('7282345564');
        for(String fnn : fnnListToReserve){
            FNNDTO dto = new FNNDTO();
            FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
            FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
            List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
            cto.value = 'Regular';
            cto.value = 'Telstra Numbers';
            ctoList.add(cto);
            fdo.poolName = 'Postpaid';
            fdo.activityName = 'DIRECT HOLD';
            fdo.categoryType = ctoList;
            fdo.searchStatus = 'AVAILABLE';
            dto.data = fdo;
            fnnMap.put(fnn,dto);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Reserve'));
        //MockMSISDNServiceResponse mockRes=new MockMSISDNServiceResponse('Reserve');
        Test.stopTest();
        //System.assertNotEquals(mockRes,Null);
        String jobId = System.enqueueJob(new MSISDNService(fnnMap,'ReserveMSISDNHandler','a3Q2O00000086It','a3T2O000000FCITUA4'));
        //System.debug('reserveJobId::' + jobId);
        String jobId1 = System.enqueueJob(new MSISDNService(fnnMap,'SearchReserveMSISDNHandler','a3Q2O00000086It','a3T2O000000FCITUA4'));
        
        String jobIdR = System.enqueueJob(new MSISDNService(fnnMap,'UnReserveMSISDNHandler','a3Q2O00000086It','a3T2O000000FCITUA4'));
        System.assertNotEquals(jobId,Null);
    }
    
    @isTest
    public static void testNcsOperation(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product','Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000323';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'MobileNumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
        String encodedContentsString ='{"schema":{"attributes": [{ "showInUI": true, "required": false, "type": "String", "name": "MobileNumber" },{ "showInUI": true, "required": false, "type": "String", "name": "Status" },{ "showInUI": true, "required": false, "type": "String", "name": "listCode" }],"name": "MobileNumberManagementv1","description": "Mobile numbers"},"configurations":[{"guid":"4b31c4a1-d554-dec6-dfb0-b898ebf8cbf8","MobileNumber":"987234556","Status":"RESERVED","listCode":"No Entry Line"},{"guid":"2ce0e784-c297-a502-07fa-2655664001f4","MobileNumber":"987234555","Status":"UNRESERVED","listCode":"No Entry Line"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = String.valueOf('MobileNumberManagementv1_schema.json');
        attachment.ParentId = config.Id; 
        insert attachment;
        List<NumberNCSMobilityDTO.Configuration> numberList = new List<NumberNCSMobilityDTO.Configuration>();
        NumberNCSMobilityDTO ncsdt=  NumberNCSMobilityDTO.parse(encodedContentsString);
        System.debug(ncsdt);
        numberList.addAll(ncsdt.configurations);
        List<String> fnnReqList = new List<String>();
        fnnReqList.add('7282345560');
        fnnReqList.add('7282345561');
        MSISDNService msHelp = new MSISDNService();
        msHelp.ncsOperation('ReserveMSISDNHandler',fnnReqList);
        msHelp.ncsOperation('UnReserveMSISDNHandler',fnnReqList);
        System.assertNotEquals(fnnReqList,NULL);
    }
    /*------------------------------------------------------------------
EDGE -93081
Method: deleteFromReservationPool
Description: Method to save LRM MSISDN Numbers in Number__c object
Author:Kalashree
-----------------------------------------------------------------*/
    @isTest
    public static void testsaveReserveMSISDNSuccess(){
        Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
        List<String> fnnListToReserve = new List<String>();
        fnnListToReserve.add('7282345560');
        fnnListToReserve.add('7282345561');
        fnnListToReserve.add('7282345564');
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Reserve'));
        String status = MSISDNService.saveReserveMSISDN(fnnListToReserve,basket.id);
         Test.stopTest();
        System.assertEquals(status!=null,true,'Record saved');
    }
      /*------------------------------------------------------------------
EDGE -93081
Method: deleteFromReservationPool
Description: Method to save LRM MSISDN Numbers in Number__c object
Author:Kalashree
-----------------------------------------------------------------*/
    @isTest
    public static void testsaveReserveMSISDNFailure(){
        Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
        List<String> fnnListToReserve = null;
       
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Reserve'));
         String statusFail = MSISDNService.saveReserveMSISDN(fnnListToReserve,'basket.id');
        String status = MSISDNService.saveReserveMSISDN(fnnListToReserve,basket.id);
          Test.stopTest();
        System.assertEquals(status!=null,true,'Record saved');
    }
     /*-------------------------------------------------------- 
EDGE -93081
Method: deleteFromReservationPool
Description:  method to delete from Number__c 
Author:Kalashree
--------------------------------------------------------*/
	@isTest
    public static void testDelFromReservationPool(){
	    Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
		Number__c msisdn1 = new Number__c(Service_Number__c='12345678',Basket__c=basket.id);
		insert msisdn1;
        Integer count  = [SELECT count() FROM Number__c];
		System.debug(count);
		List<String> msisdnList = new List<String>();
		msisdnList.add(msisdn1.Service_Number__c);
        System.debug('msisdnList'+msisdnList);
		Test.startTest();
        MSISDNService service = new MSISDNService();
        service.basketid=basket.id;
		service.deleteFromReservationPool(msisdnList);
        
        Test.stopTest(); 
        System.assertEquals([SELECT count() FROM Number__c]==0,true,'Record deleted');
	}
}