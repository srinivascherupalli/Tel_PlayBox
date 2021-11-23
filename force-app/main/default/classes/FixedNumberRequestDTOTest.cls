/*************************************************************************************************
Name : FixedNumberResponseDTOTest
Description : Test class for FixedNumberResponseDTO
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
@isTest
public class FixedNumberRequestDTOTest {
 @isTest
        public static void testparsesuccess(){
         String json ='{"data":{"resourceState":"Held Order","resources":[{"resourceId":"61212345678"},{"startRange":"61339185736","endRange":"61339185737"}]}}';
            Test.startTest();
            FixedNumberRequestDTO req= FixedNumberRequestDTO.parse(json);
            Test.stopTest();
            system.assert(req.data.resourceState=='Held Order');
            system.assert(req.data.resources[0].resourceId=='61212345678');
            system.assert(req.data.resources[1].startRange=='61339185736');
            system.assert(req.data.resources[1].endRange=='61339185737');
            
    }
}