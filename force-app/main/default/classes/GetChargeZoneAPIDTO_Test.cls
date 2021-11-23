/*******************************************************************************************************
Name          : GetChargeZoneAPIDTO_Test 
Created By    : Aman Soni
Created Date  : Nov 29 2019
Description   : This is the test class for GetChargeZoneAPIDTO
-------
History
-------
VERSION     AUTHOR          DATE            DETAIL     
-------     ------          -----           ---------
1.1         Aman Soni       29-11-2019      Class created as part of EDGE-98299
*******************************************************************************************************/
@IsTest
public class GetChargeZoneAPIDTO_Test {
    
     @isTest static void testParse() {
        String json = '{\"esaId\":1,\"czpId\":1,\"contractStartDate\":\"2019-11-08\",\"zone\":{\"rental\":2,\"sla\":\"URBAN\",\"mdn\":\"URBAN\"},\"maintenance\":[{\"vendor\":\"Cisco Smartnet\",\"availability\":\"24X7X2\"},{\"vendor\":\"Cisco Telstra Onsite\",\"availability\":\"24X7X4\"},{\"vendor\":\"Juniper\",\"availability\":\"24X7X4\"},{\"vendor\":\"Riverbed\",\"availability\":\"24X7X4\"}]}';
        GetChargeZoneAPIDTO obj = GetChargeZoneAPIDTO.parse(json);
        System.assert(obj != null);
    } 
}