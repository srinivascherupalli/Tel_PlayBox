@isTest
public class FNNDTOTest 
{
    @isTest
    public static void TestFNNDTO()
    {
    	String json = '{"data":{"geoParam":"Country","geoParamValue":"India","addressId":"141300879","type":"PREMIUM","quantity":1,"pattern":"031234567*","searchType":"RANDOM","systemId":"SFDC","serviceIds":["0123456987"],"poolName":"Postpaid","activityName":"DIRECT HOLD","categoryType":[{"value":"Regular"},{"value":"Telstra Numbers"}],"searchStatus":"AVAILABLE"}}';
    	Test.startTest();
    	FNNDTO fnnDto = FNNDTO.parse(json);
        System.debug('fnnDto::' + fnnDto);
    	Test.stopTest();
        System.assert(fnnDto.data.geoParam == 'Country');
        System.assert(fnnDto.data.geoParamValue == 'India');
        System.assert(fnnDto.data.addressId == '141300879');
        System.assert(fnnDto.data.pattern == '031234567*');
        System.assert(fnnDto.data.searchType == 'RANDOM');
        System.assert(fnnDto.data.systemId == 'SFDC');
        System.assert(fnnDto.data.poolName == 'Postpaid');
        System.assert(fnnDto.data.activityName == 'DIRECT HOLD');
        System.assert(fnnDto.data.searchStatus == 'AVAILABLE');
        System.assert(fnnDto.data.quantity == 1);
        System.assert(fnnDto.data.categoryType[0].value == 'Regular');
        System.assert(fnnDto.data.serviceIds[0] == '0123456987');
    }
}