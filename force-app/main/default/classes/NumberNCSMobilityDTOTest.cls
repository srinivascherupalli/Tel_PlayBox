@isTest
public class NumberNCSMobilityDTOTest {
    @isTest
    public static void TestNumberNCSMobilityDTO(){
        String json='{"configurations":[{"listCode":"No Entry Line","Status":"RESERVED","MobileNumber":"987234556","guid":"4b31c4a1-d554-dec6-dfb0-b898ebf8cbf8"},{"listCode":"No Entry Line","Status":"UNRESERVED","MobileNumber":"987234555","guid":"2ce0e784-c297-a502-07fa-2655664001f4"}],"schema":{"name":"MobileNumberManagementv1","id":"a792O0000000156QAA","attributes":[{"type":"String","showInUI":true,"required":false,"name":"MobileNumber"},{"type":"String","showInUI":true,"required":false,"name":"Status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}],"description":"Mobile numbers"}}';
        Test.startTest();
        NumberNCSMobilityDTO mobilityNCSDto = NumberNCSMobilityDTO.parse(json);
        System.debug('mobilityNCSDto::' + mobilityNCSDto);
        Test.stopTest();
        if(mobilityNCSDto !=NULL){
            System.assert(mobilityNCSDto.schema.attributes[0].showInUI == true);
            System.assert(mobilityNCSDto.schema.attributes[0].required == false);
            System.assert(mobilityNCSDto.schema.attributes[0].type == 'String');
            System.assert(mobilityNCSDto.schema.attributes[0].name == 'MobileNumber');
            System.assert(mobilityNCSDto.schema.name == 'MobileNumberManagementv1');
            System.assert(mobilityNCSDto.schema.Id == 'a792O0000000156QAA');
            System.assert(mobilityNCSDto.configurations[0].guid == '4b31c4a1-d554-dec6-dfb0-b898ebf8cbf8');
            System.assert(mobilityNCSDto.configurations[0].MobileNumber == '987234556');
            System.assert(mobilityNCSDto.configurations[0].Status == 'RESERVED');
            System.assert(mobilityNCSDto.configurations[0].listCode == 'No Entry Line');
        }
    }
}