/********************************************************************************************************
*This Test class is to handle request DTO for Custom wrapper API to support high volume orders.
* Developer: Vanita Mude
* Date: 11 June 2019
* Description: EDGE-86669 expose OrderSpecs via Custom wrapper API to support high volume orders
********************************************************************************************************/
@isTest
public class GetOrderSpecAPIRequestDTOTest {
    static testMethod void testParse() {
        String json=        '{'+
            '"OrderID__c":"a4b2O0000004Wbk",'+
            '"Order_Number__c":"ON00092202",'+
            '"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d",'+
            '"targetSystem":"FULFILMENT"'+
            '}'+
            '';
            
        GetOrderSpecAPIRequestDTO obj =GetOrderSpecAPIRequestDTO.parse(json);
        System.debug('obj==>'+obj.OrderID+'targetSystem==>'+obj.targetSystem);
        System.assert(obj != null);
    }
}