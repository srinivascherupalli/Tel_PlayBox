@isTest
public class FNNResponseDTOTest {
    @isTest
    public static void TestFNNResponseDTO() {
    	//String jsonStr = '{"status": 200,"code": 200,"responseCode": "LRM-SUCCESS","method": "POST","message": "ResponseMessage","time": "2018-07-26T05:03:20.299+0000","correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","path": "/networks/v2/logical-resources/locks?attributes=all","data": {"result":[{"fnn":"0282345560","status":"SUCCESS"}],"resources": [{"resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION","poolId": 25,"characteristics": [{"name": "ESA","value": "APPX"},{"name": "Potential Line Type","value": "SS"}],"relatedResources": [{"relationshipType": "FNN_Type","resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION"}],"category": [{"type": "FNN_Type","value": "Regular"}]}]},"request": {"data": {"geoParam": "ESA","geoParamValues": "BULA","type": "REGULAR","quantity": 1,"pattern": "*2","searchType": "RANDOM","systemId": "MSPA"}}},"st();
    	String jsonStr = '{"status": 200,"code": 200,"responseCode": "LRM-SUCCESS","method": "POST","message": "ResponseMessage","time": "2018-07-26T05:03:20.299+0000","correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","path": "/networks/v2/logical-resources/locks?attributes=all","data": {"result":[{"fnn":"0282345560","status":"SUCCESS"}],"resources": [{"resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION","poolId": 25,"characteristics": [{"name": "ESA","value": "APPX"},{"name": "Potential Line Type","value": "SS"}],"relatedResources": [{"relationshipType": "FNN_Type","resourceId": "0732722177","resourceType": "FNN","resourceState": "HELD PRESENTATION"}],"category": [{"type": "FNN_Type","value": "Regular"}]}]},"request": {"data": {"geoParam": "ESA","geoParamValues": "BULA","type": "REGULAR","quantity": 1,"pattern": "*2","searchType": "RANDOM","systemId": "MSPA"}},"errors":[{"fnn":"38347922","system":"SNRM","code":"soapenv:Server.userException","message":"amdocs.rm3g.exceptions.RMValidateException","activityStatus":"-1"}]}';
        FNNResponseDTO fnnResDto = FNNResponseDTO.parse(jsonStr);
        System.debug('fnnResDto::' + fnnResDto);
        Test.startTest();
        System.assert(fnnResDto.responseCode == 'LRM-SUCCESS');
        System.assert(fnnResDto.correlationId == '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e');
        System.assert(fnnResDto.path == '/networks/v2/logical-resources/locks?attributes=all');
        System.assert(fnnResDto.res_time == '2018-07-26T05:03:20.299+0000');
        System.assert(fnnResDto.status == 200);
        System.assert(fnnResDto.code == 200);
        System.assert(fnnResDto.method == 'POST');
        System.assert(fnnResDto.message == 'ResponseMessage');
        System.assertEquals(fnnResDto.data.fnns,null );
       
        System.assert(fnnResDto.data.resources[0].resourceId == '0732722177');
        System.assert(fnnResDto.data.resources[0].resourceType == 'FNN');
        System.assert(fnnResDto.data.resources[0].resourceState == 'HELD PRESENTATION');
        System.assert(fnnResDto.data.resources[0].poolId == 25);
        
        System.assert(fnnResDto.data.result[0].fnn == '0282345560');
        System.assert(fnnResDto.data.result[0].status == 'SUCCESS');
        
        System.assert(fnnResDto.data.resources[0].characteristics[0].name == 'ESA');
        System.assert(fnnResDto.data.resources[0].characteristics[0].value == 'APPX');
        
        System.assert(fnnResDto.data.resources[0].category[0].type == 'FNN_Type');
        System.assert(fnnResDto.data.resources[0].category[0].value == 'Regular');
		
		System.assert(fnnResDto.data.resources[0].relatedResources[0].relationshipType == 'FNN_Type');
		System.assert(fnnResDto.data.resources[0].relatedResources[0].resourceId == '0732722177');
		System.assert(fnnResDto.data.resources[0].relatedResources[0].resourceType == 'FNN');
		System.assert(fnnResDto.data.resources[0].relatedResources[0].resourceState == 'HELD PRESENTATION');
		
		System.assertNotEquals(fnnResDto.request, null);
        System.assert(fnnResDto.errors[0].fnn == '38347922');
        System.assert(fnnResDto.errors[0].res_system == 'SNRM');
        System.assert(fnnResDto.errors[0].code == 'soapenv:Server.userException');
        System.assert(fnnResDto.errors[0].message == 'amdocs.rm3g.exceptions.RMValidateException');
        System.assert(fnnResDto.errors[0].activityStatus == '-1');
    	Test.stopTest();
    }
}