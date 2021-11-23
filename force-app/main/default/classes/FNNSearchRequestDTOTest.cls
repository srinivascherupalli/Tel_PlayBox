/*************************************************************************************************
Name : FNNSearchRequestDTO
Description : Test class for FNNSearchRequestDTO
Author: Aishwarya
Story: EDGE-100659
***************************************************************************************************/
@isTest
public class FNNSearchRequestDTOTest{
 @isTest
        public static void testparsesuccess(){
	     String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Non-Contiguous","pattern":"%1%","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';
            Test.startTest();
            FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
            Test.stopTest();
            system.assert(req.data.activityName=='Search');
            system.assert(req.data.resourceType=='Fixed');
            system.assert(req.data.searchType=='Non-Contiguous');
            system.assert(req.data.pattern=='%1%');
			system.assert(req.data.patternType=='Contains');
			system.assert(req.data.quantity==12);
			system.assert(req.data.nationalDestinationCode=='02');
            
	}
}