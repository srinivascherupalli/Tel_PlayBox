/*************************************************************************************************
Name : FixedNumberResponseDTOTest
Description : Test class for FixedNumberResponseDTO
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
@isTest
public class FixedNumberResponseDTOTest {
@isTest
        public static void testparseError(){
            String json='{"status":409,"code":409,"time":"2019-09-13T06:57:22.263+0000","correlationId":"08865a82-594a-4568-bbbf-cb913025b7ad","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order","data":{},"errors":[{"resourceId":"61386479994","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"},{"resourceId":"61386479914","startRange":"61386479913","endRange":"61386479914","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"}],"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"61386479994"},{"startRange":"61386479913","endRange":"61386479914"}]}}}';
            Test.startTest();
            FixedNumberResponseDTO res= FixedNumberResponseDTO.parse(json);
            Test.stopTest();            
            system.assert(res.status==409);
            system.assert(res.code==409);
            system.assert(res.responseCode=='UNMS-INVALID_ACTION');
            system.assert(res.message=='The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order');
            system.assert(res.time_x=='2019-09-13T06:57:22.263+0000');
            system.assert(res.correlationId=='08865a82-594a-4568-bbbf-cb913025b7ad');
            system.assert(res.path=='/v1/logical-resources/dialable-numbers');
            system.assert(res.method=='PATCH');
            system.assert(res.request.params==null);
            system.assert(res.errors[0].resourceId=='61386479994');
            system.assert(res.errors[0].system_Z=='UNMS');
            system.assert(res.errors[0].code=='UNMS-INVALID_ACTION');
            system.assert(res.errors[0].message=='The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order');
            
            system.assert(res.errors[1].resourceId=='61386479914');
            system.assert(res.errors[1].startRange=='61386479913');
            system.assert(res.errors[1].endRange=='61386479914');
            system.assert(res.errors[1].system_Z=='UNMS');
            system.assert(res.errors[1].code=='UNMS-INVALID_ACTION');
            system.assert(res.errors[1].message=='The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order');
            
            system.assert(res.request.method=='PATCH');
            system.assert(res.request.path=='/v1/logical-resources/dialable-numbers');
            system.assert(res.request.data.resourceState=='Held Order');
            system.assert(res.request.data.resources[0].resourceId=='61386479994');
            system.assert(res.request.data.resources[1].startRange=='61386479913');
            system.assert(res.request.data.resources[1].endRange=='61386479914');
        }    
    
    @isTest
        public static void testparseSuccess(){
            String json='{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"61359816905","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"},{"countryCode":"61","countryName":"AU","nationalDestinationCode":"2","providedToKey":"70843ac2-f2fc-4219-a693-70a8a3c24d3e","startRange":"61298660348","endRange":"61298660349","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T07:01:14.000930Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"61359816905"},{"startRange":"61298660348","endRange":"61298660349"}]}}}';
            Test.startTest();
            FixedNumberResponseDTO res= FixedNumberResponseDTO.parse(json);
            Test.stopTest();  

            system.assert(res.status==200);
            system.assert(res.code==200);
            system.assert(res.time_x=='2019-09-13T06:52:36.542+0000');
            system.assert(res.correlationId=='53425d83-1d66-4bfe-80af-a3e4e5665750');
            system.assert(res.path=='/v1/logical-resources/dialable-numbers');
            system.assert(res.method=='PATCH');
            system.assert(res.responseCode=='UNMS-SUCCESS');
            system.assert(res.data.resources[0].resourceId=='61359816905');
            system.assert(res.data.resources[0].countryCode=='61');
            system.assert(res.data.resources[0].countryName=='AU');
            system.assert(res.data.resources[0].nationalDestinationCode=='3');
            system.assert(res.data.resources[0].providedToKey=='2d1bfa7b-790b-4dcf-becf-5cd0e36c525d');
            system.assert(res.data.resources[0].activityStatus=='SUCCESS');
            system.assert(res.data.resources[0].resourceState=='Held Order');
            system.assert(res.data.resources[0].ageOut=='180');
            system.assert(res.data.resources[0].ageOutDate=='2020-03-11T06:52:36.000372Z');
            
            system.assert(res.data.resources[1].countryCode=='61');
            system.assert(res.data.resources[1].countryName=='AU');
            system.assert(res.data.resources[1].nationalDestinationCode=='2');
            system.assert(res.data.resources[1].providedToKey=='70843ac2-f2fc-4219-a693-70a8a3c24d3e');
            system.assert(res.data.resources[1].startRange=='61298660348');
            system.assert(res.data.resources[1].endRange=='61298660349');
            system.assert(res.data.resources[1].activityStatus=='SUCCESS');
            system.assert(res.data.resources[1].resourceState=='Held Order');
            system.assert(res.data.resources[1].ageOut=='180');
            system.assert(res.data.resources[1].ageOutDate=='2020-03-11T07:01:14.000930Z');
            
            
            //system.assert(res.request.params_x);
            system.assert(res.request.method=='PATCH');
            system.assert(res.request.path=='/v1/logical-resources/dialable-numbers');
            system.assert(res.request.data.resourceState=='Held Order');
            system.assert(res.request.data.resources[0].resourceId=='61359816905');
            system.assert(res.request.data.resources[1].startRange=='61298660348');
            system.assert(res.request.data.resources[1].endRange=='61298660349');
    
        }       
       
}