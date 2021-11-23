@IsTest
public class TramasBatchResponseDTOTest {
  
    /*
     * Test Parse method of SiteSQRequestDTO
     */
    @IsTest
  static void testParse() {
    String jsonString = '{ "links": [ { "rel": "self", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/batch/85ad590c-602a-47cc-8aea-099c8f55587f" } ], "batchId": "85ad590c-602a-47cc-8aea-099c8f55587f", "operations": { "links": [ { "rel": "self", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/batch/85ad590c-602a-47cc-8aea-099c8f55587f" } ], "data": [ { "output": { "links": [ { "rel": "self", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/418368ec-8b40-45a2-a93a-aa30a59b3787" } ], "transitionId": "418368ec-8b40-45a2-a93a-aa30a59b3787", "transitions": [ { "type": "service", "target": { "type": "cwp" }, "properties": { "identifiers": [ { "identifier": "0314419400", "attributes": null }, { "identifier": "0385990400-0385990499", "attributes": null } ], "family": "isdn2" } } ], "states": [ { "state": "created", "timestamp": "2019-11-15T09:40:53.802Z" } ], "metadata": { "batchId": "85ad590c-602a-47cc-8aea-099c8f55587f", "createdAt": "2019-11-15T09:40:53.806Z", "updatedAt": "2019-11-15T09:40:56.163Z", "correlationId": "17bfa155-aea4-473a-8c0d-cd51f4714407" }, "resource": { "data": [], "links": [ { "rel": "self", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/418368ec-8b40-45a2-a93a-aa30a59b3787/resources" } ] } }, "result": "success", "type": "transition::create", "properties": { "transitions": [ { "type": "service", "target": { "type": "cwp" }, "properties": { "identifiers": [ { "identifier": "0314419400", "attributes": null }, { "identifier": "0385990400-0385990499", "attributes": null } ], "family": "isdn2" } } ], "metadata": { "batchId": "85ad590c-602a-47cc-8aea-099c8f55587f", "createdAt": "2019-11-15T09:40:53.806Z", "updatedAt": "2019-11-15T09:40:53.806Z" } } } ] } }';  
    TramasBatchResponseDTO obj = TramasBatchResponseDTO.parse(jsonString);
    System.assert(obj != null);
    System.assert(obj.operations != null);
    System.assert(obj.operations.data != null);
    //obj.operations.data.output = 'jhgj';
    //System.assert(obj.datalstdto != null);
  }
 }