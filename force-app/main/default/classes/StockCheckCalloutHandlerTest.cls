/*******************************************************************************************************************
Name : StockCheckCalloutHandlerTest 
EDGE-> 80857
Description : Test class for callout to the Stock Check API to get the stock availability details of the selected product
====================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Ravi Shankar     12/06/2019   As a salesforce user, I want to Perform Stock Check for the selected device
                                        so that I can present the information to customer : Stock Enquiry API Consumption
2.    Kalashree Borgaonkar	14/10/2019	As a salesforce user, I want to Perform Stock Check for the multiple selected
										devices								
====================================================================================================================
********************************************************************************************************************/
@isTest
public class StockCheckCalloutHandlerTest {
    @isTest
    public static void callStockCheckService_Success(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Search'));
        StockCheckCalloutHandler hdlr = new StockCheckCalloutHandler();
        StockCheckResponseDto dto = hdlr.syncExecute('2433222');
        System.assertEquals((dto!=null), true, 'Callout Failed');
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Error'));
        dto = hdlr.syncExecute('8876366');
        System.assertEquals((dto!=null), true, 'Callout Failed');       
        Test.stopTest();    
    }
		    /*-------------------------------------------------------- 
EDGE-80860
Method: callStockCheckMultipleSuccess
Description: Test method for calloutToStockCheck Success
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
	 @isTest
    public static void callStockCheckMultipleSuccess(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_multiple'));
        String success_multiple = '{"idSource":"string","products":[{"id":"100158856","isServiceable":true,"availableQuantity":10,"description":"string","nextReplenishmentDate":"2019-10-14"},{"id":"100157169","isServiceable":true,"availableQuantity":0,"description":"string","nextReplenishmentDate":"2019-10-14"},{"id":"100115460","isServiceable":true,"availableQuantity":0,"description":"string","nextReplenishmentDate":""},{"id":"100159379","isServiceable":true,"availableQuantity":30,"description":"string","nextReplenishmentDate":"2019-10-14"}],"lineOfBusinessCode":"string"}';
		StockCheckRequestDto requestDto = StockCheckRequestDto.parse(success_multiple);
		StockCheckResponseDto responseDto = StockCheckCalloutHandler.calloutToStockCheck(requestDto);
        System.assertEquals((responseDto!=null && !responseDto.products.isEmpty()), true, 'Callout SuccessFull');
		
	}
	    /*-------------------------------------------------------- 
EDGE-80860
Method: callStockCheckMultipleFailure
Description: Test method for calloutToStockCheck Failure
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
	 @isTest
    public static void callStockCheckMultipleFailure(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Error'));
		String success_Error = '{"status":422,"code": "MMF-GW-INVALIDTOKEN","message": "Invalid or no credentials passed in the request"}';
		StockCheckRequestDto requestDto = StockCheckRequestDto.parse(success_Error);
		StockCheckResponseDto responseDto = StockCheckCalloutHandler.calloutToStockCheck(requestDto);
        System.assertEquals((responseDto!=null && responseDto.products ==null), true, 'Callout Failed');
		Test.stopTest();
	}
 /*-------------------------------------------------------- 
EDGE-80860
Method: createPayload
Author:Kalashree Borgaonkar
--------------------------------------------------------*/        
    @isTest
    public static void createPayloadTest(){
        List<String> skuidList = new List<String>{'100158856','100157169','100115460','100159379'};
        Test.startTest();
        StockCheckRequestDto dto = StockCheckCalloutHandler.createPayload(skuidList);
        Test.stopTest();
        System.assertEquals(dto!=null , true, 'Dto created');
        
    }            
    
}