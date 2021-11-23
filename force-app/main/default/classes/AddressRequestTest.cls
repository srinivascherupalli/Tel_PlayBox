@isTest
public class AddressRequestTest 
{
    @isTest
    public static void test_parse() {
    	String json = '{"correlationId":"e36c958d-0adf-4d19-8658-a718c72c55af","data":{"searchOptions":{"sortType":"0","addressesToSkip":0,"addressesToReturn":1,"fuzzyOptions":{"enabled":true},"addressType":"serviceAddress"},"requestParams":{"adborId":"9854719"},"searchData":{"streetNumber":"3","streetName":"WeLlington","streetType":"roaD","suburb":"aubuRn","state":"NsW","streetSuffix":"telstra","addressLine1":"Street","addressLine2":"Melbourne","addressLine3":"Australia","addressType":"serviceAddress","addressSubType":"Address","unitNumber":"56A","postalDeliveryNumber":"400017","ruralMailNumber":"400019","planNumber":"5009","parcelNumber":"9005","postcode":"2144"}}}';
    	Test.startTest();
    	AddressRequest addDto = AddressRequest.parse(json);
        System.debug('addDto::' + addDto);
    	Test.stopTest();
        System.assert(addDto.correlationId == 'e36c958d-0adf-4d19-8658-a718c72c55af');
        System.assert(addDto.data.searchOptions.sortType == '0');
        System.assert(addDto.data.searchOptions.addressesToSkip == 0);
        System.assert(addDto.data.searchOptions.addressesToReturn == 1);
        System.assert(addDto.data.searchOptions.addressType == 'serviceAddress');
        System.assert(addDto.data.searchOptions.fuzzyOptions.enabled == True);
        System.assert(addDto.data.requestParams.adborId == '9854719');
        System.assert(addDto.data.searchData.streetNumber == '3');
        System.assert(addDto.data.searchData.streetName == 'WeLlington');
        System.assert(addDto.data.searchData.streetType == 'road');
        System.assert(addDto.data.searchData.suburb == 'aubuRn');
        System.assert(addDto.data.searchData.state == 'NsW');
        System.assert(addDto.data.searchData.postcode == '2144');
        System.assert(addDto.data.searchData.streetSuffix == 'telstra');
        System.assert(addDto.data.searchData.addressLine1 == 'Street');
        System.assert(addDto.data.searchData.addressLine2 == 'Melbourne');
        System.assert(addDto.data.searchData.addressLine3 == 'Australia');
        System.assert(addDto.data.searchData.addressType == 'serviceAddress');
        System.assert(addDto.data.searchData.addressSubType == 'Address');
        System.assert(addDto.data.searchData.unitNumber == '56A');
        System.assert(addDto.data.searchData.postalDeliveryNumber == '400017');
        System.assert(addDto.data.searchData.ruralMailNumber == '400019');
        System.assert(addDto.data.searchData.planNumber == '5009');
        System.assert(addDto.data.searchData.parcelNumber == '9005');
    }
	    @isTest
    public static void test_AutoComp() {
    	String json = '{"searchData": { "addressLine1": "242 Exhibition Street, Melbourne VIC"}}';
    	Test.startTest();
    	AddressRequest addDto = AddressRequest.parse(json);
        System.debug('addDto::' + addDto);
    	Test.stopTest();
        System.assert(addDto.searchData.addressLine1 == '242 Exhibition Street, Melbourne VIC');
	}
}