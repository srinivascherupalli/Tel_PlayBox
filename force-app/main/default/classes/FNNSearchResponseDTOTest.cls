/*************************************************************************************************
Name : FNNSearchResponseDTOTest
Description : Test class for FNNSearchResponseDTO
Author: Aishwarya
Story: EDGE-100659
***************************************************************************************************/

@isTest
public class FNNSearchResponseDTOTest{
    @isTest
    public static void TestFNNSearchResponseDTO() {
        //String jsonStr = '{"status": 200,"code": 200,"responseCode": "LRM-SUCCESS","method": "POST","message": "ResponseMessage","time": "2018-07-26T05:03:20.299+0000","correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","path": "/networks/v2/logical-resources/locks?attributes=all","data": {"result":[{"fnn":"0282345560","status":"SUCCESS"}],"resources": [{"resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION","poolId": 25,"characteristics": [{"name": "ESA","value": "APPX"},{"name": "Potential Line Type","value": "SS"}],"relatedResources": [{"relationshipType": "FNN_Type","resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION"}],"category": [{"type": "FNN_Type","value": "Regular"}]}]},"request": {"data": {"geoParam": "ESA","geoParamValues": "BULA","type": "REGULAR","quantity": 1,"pattern": "*2","searchType": "RANDOM","systemId": "MSPA"}}},"st();
        //ring jsonStr = '{"status": 200,"code": 200,"responseCode": "LRM-SUCCESS","method": "POST","message": "ResponseMessage","time": "2018-07-26T05:03:20.299+0000","correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","path": "/networks/v2/logical-resources/locks?attributes=all","data": {"result":[{"fnn":"0282345560","status":"SUCCESS"}],"resources": [{"resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION","poolId": 25,"characteristics": [{"name": "ESA","value": "APPX"},{"name": "Potential Line Type","value": "SS"}],"relatedResources": [{"relationshipType": "FNN_Type","resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION"}],"category": [{"type": "FNN_Type","value": "Regular"}]}]},"request": {"data": {"geoParam": "ESA","geoParamValues": "BULA","type": "REGULAR","quantity": 1,"pattern": "*2","searchType": "RANDOM","systemId": "MSPA"}},"errors":[{"fnn":"38347922","system":"SNRM","code":"soapenv:Server.userException","message":"amdocs.rm3g.exceptions.RMValidateException","activityStatus":"-1"}]}';
        // String jsonStr='{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"POST","responseCode":"UNMS-SUCCESS","data":{"requestedQuantity":"8","returnedQuantity":"5","ageOut":"25",resources":[{ "resourceType":"Fixed","startRange":"61359816905","endRange":"61359816908","poolNAME":"xyz","premiumType":"Gold","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]}}';
        String jsonStr='{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"POST","responseCode":"UNMS-SUCCESS","data":{"requestedQuantity":"8","returnedQuantity":"5","ageOut":"25","resources":[{"resourceType":"Fixed","startRange":"61359816905","endRange":"61359816908","poolNAME":"xyz","premiumType":"Gold","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]}}';
        FNNSearchResponseDTO fnnResDto = FNNSearchResponseDTO.parse(jsonStr);
        System.debug('fnnResDto::' + fnnResDto);
        Test.startTest();
        System.assert(fnnResDto.responseCode == 'UNMS-SUCCESS');
        System.assert(fnnResDto.correlationId == '53425d83-1d66-4bfe-80af-a3e4e5665750');
        System.assert(fnnResDto.path == '/v1/logical-resources/dialable-numbers');
        System.assert(fnnResDto.time_x=='2019-09-13T06:52:36.542+0000');
        System.assert(fnnResDto.status == 200);
        System.assert(fnnResDto.code == 200);
        System.assert(fnnResDto.method == 'POST');
        //ystem.assert(fnnResDto.message == 'ResponseMessage');
        //ystem.assertEquals(fnnResDto.data.fnns,null );
        
        System.assert(fnnResDto.data.requestedQuantity== '8');
        System.assert(fnnResDto.data.returnedQuantity == '5');
        System.assert(fnnResDto.data.resources[0].resourceType == 'Fixed');
        //stem.assert(fnnResDto.data.resources[0].resourceId == '0732722177');
        System.assert(fnnResDto.data.resources[0].countryCode == '61');
        System.assert(fnnResDto.data.resources[0].countryName == 'AU');
        System.assert(fnnResDto.data.resources[0].nationalDestinationCode == '3');
        System.assert(fnnResDto.data.resources[0].startRange == '61359816905');
        System.assert(fnnResDto.data.resources[0].endRange == '61359816908');
        System.assert(fnnResDto.data.resources[0].poolName == 'xyz');
        System.assert(fnnResDto.data.resources[0].premiumType == 'Gold');
        System.assert(fnnResDto.data.resources[0].providedToKey == '2d1bfa7b-790b-4dcf-becf-5cd0e36c525d');
        System.assert(fnnResDto.data.resources[0].activityStatus == 'SUCCESS');
        System.assert(fnnResDto.data.resources[0].resourceState == 'Held Order');
        System.assert(fnnResDto.data.resources[0].ageOut == '180');
        System.assert(fnnResDto.data.resources[0].ageOutDate == '2020-03-11T06:52:36.000372Z');
        System.assert(fnnResDto.data.ageOut== '25');
        
        
        Test.stopTest();
    }
}