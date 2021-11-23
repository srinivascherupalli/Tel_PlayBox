/********************************************************
Class Name      :   EventMSCallBackDTOTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil        13/12/19        EDGE-115932
**********************************************************
*/
@IsTest
public class EventMSCallBackDTOTest {
    
    static testMethod void testParse() {
        String json = '['+
        '        {'+
        '          \"msCorrelationId\": \"4ab54ade-6c3d-45f2-bb55-d1d53f508d4e\",'+
        '          \"orderItemId\": \"ON00021246|SVC-000039231|a3021bb8-fd0b-00f9-79ea-a16fbfb6d825\",'+
        '          \"status\": \"success\"'+
        '        },'+
        '        {'+
        '          \"msCorrelationId\": \"4ab54ade-7863-45g3-bb15-d1d53t458d4e\",'+
        '          \"orderItemId\": \"ON00021246|SVC-000039231|a3021bb8-fd0b-00f9-79ea-a16fbfb6d825\",'+
        '          \"status\": \"success\"'+
        '        },'+
        '        {'+
        '          \"msCorrelationId\": \"4ab54ade-6c3d-4d32-bb78-d1d53f508dd2\",'+
        '          \"orderItemId\": \"ON00021246|SVC-000039231|a3021bb8-fd0b-00f9-79ea-a16fbfb6d825\",'+
        '          \"status\": \"failure\"'+
        '        }'+
        '      ]';
        List<EventMSCallBackDTO> obj = EventMSCallBackDTO.parse(json);
        System.assert(obj != null);
    }
}