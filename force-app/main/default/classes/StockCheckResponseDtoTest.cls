/*******************************************************************************************************************
Name : StockCheckResponseDtoTest
EDGE-> 80860
Description : Test class for StockCheckResponseDto
====================================================================================================================
Sr.No.    Developer Name              Date          						Story Description
1.        Kalashree Borgoankar     10/07/2019   		As a salesforce user, I want to perform Stock Check for multiple selected 
Mobile/NGUC devices 
====================================================================================================================
********************************************************************************************************************/
@isTest
public class StockCheckResponseDtoTest {
	@isTest
    public static  void testParseSingle() {
		String json = '{"products":[{"id":"string","isServiceable":true,"availableQuantity":0,"description":"string","nextReplenishmentDate":"2019-10-09"}],"idSource":"string","lineOfBusinessCode":"string"}';
		StockCheckResponseDto obj = StockCheckResponseDto.parse(json);
		System.assert(obj != null);
	}
    @isTest
    public static  void testParseMultiple() {
		String json = '{"idSource":"string","productId":"string","warehouseId":"string","isServiceable":true,"inventory":[{"colour":"string","size":"string","hardwareType":"string","availableQuantity":0,"description":"string","nextReplenishmentDate":"2019-10-09"}]}';
		StockCheckResponseDto obj = StockCheckResponseDto.parse(json);
		System.assert(obj != null);
	}
}