/***********************************************************************************************************
Name          : SCAddressSearchCalloutMock
Created By    : Mahaboob Basha
Created Date  : July 03 2019
Description   : This is a Mock class to simulate the callouts of Address Search in SCAddressSearchController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        03-07-2019      Created
1.1         Mahaboob        03-07-2019      Added methods respond, getCalloutResponse, getDefaultResponse
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
global class SCAddressSearchCalloutMock implements HttpCalloutMock {
 
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('HTTP Endpoint: '+ req.getEndpoint());
        System.debug('HTTP Method: '+ req.getMethod());
        System.debug('HTTP Request: '+ req.getBody());
        if(req.getEndpoint().contains('publish/publication?')){
            return getCalloutResponse();
        }
        return getDefaultResponse(200);
    }

    private HttpResponse getCalloutResponse(){
        HttpResponse res = getDefaultResponse(202);
        res.setBody('{"response": [{"publicationInstructionId": 123},{"publicationInstructionId": 456}]}');
        return res;
    }
    
    private HttpResponse getDefaultResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        String mockBody = '{"Correlation_Id":"SFDC_REP_GETSITE4bb6c0d465a20ac41b","CIDN":"3501165339","Enterprise_ID":null,"Error_Code":"","Error_Description":"","Site":[{"Media_Type":"Copper","Site_Nick_Name":"","ADBoR_ID":"265742187","Sub1_CodeSet_Abbrev":"BG","Sub1_Descriptor_1":"1","Sub1_Descriptor_2":"","Sub2_CodeSet_Abbrev":"L","Sub2_Descriptor_1":"10","Sub2_Descriptor_2":"","Sub3_CodeSet_Abbrev":"","Sub3_Descriptor_1":"","Sub3_Descriptor_2":"","Sub4_CodeSet_Abbrev":"","Sub4_Descriptor_1":"","Sub4_Descriptor_2":"","Address_No_From":"0","Address_No_To":"0","Suffix_From":"","Suffix_To":"","Street_Name":"ST GEORGES","Street_Type":"TCE","Loc_Name":"PERTH","ADBoR_Postcode":"6000","State":"WA","Name":"","Address1":"NULL","Address2":"NULL","Disconnection_Date":"","Last_Replicator_Update_Date":"22-01-2019:16:15:07","In_Flight_Order":"N","NBN_Location_Id":"Unknown","RFS_Date":"","Serviceability":"Non-Serviceable","NBN_Access_Type":"Unknown","Disconnect_Wave":"","Site_Address_Status":"CO","Site_Composition":"Legacy","Complex_Site_Flag":"N","Site_Migration_Flag":"N","Order_Stability_Date":"","Service_Class":"Unknown","Error_Code":"","Error_Description":"","Contact":[{"Site_Contact_Telephone":"","Site_Contact_Mobile":"","Site_Contact_Fax":"","Site_Contact_Email":"","Site_Contact_First_Name":"","Site_Contact_Last_Name":""}]},{"Media_Type":"Copper","Site_Nick_Name":"","ADBoR_ID":"264417331","Sub1_CodeSet_Abbrev":"BG","Sub1_Descriptor_1":"","Sub1_Descriptor_2":"","Sub2_CodeSet_Abbrev":"L","Sub2_Descriptor_1":"15","Sub2_Descriptor_2":"","Sub3_CodeSet_Abbrev":"","Sub3_Descriptor_1":"","Sub3_Descriptor_2":"","Sub4_CodeSet_Abbrev":"","Sub4_Descriptor_1":"","Sub4_Descriptor_2":"","Address_No_From":"0","Address_No_To":"0","Suffix_From":"","Suffix_To":"","Street_Name":"ALBERT","Street_Type":"AVE","Loc_Name":"CHATSWOOD","ADBoR_Postcode":"2067","State":"NSW","Name":"","Address1":"NULL","Address2":"NULL","Disconnection_Date":"","Last_Replicator_Update_Date":"22-01-2019:16:15:07","In_Flight_Order":"N","NBN_Location_Id":"Unknown","RFS_Date":"","Serviceability":"Non-Serviceable","NBN_Access_Type":"Unknown","Disconnect_Wave":"","Site_Address_Status":"CO","Site_Composition":"Legacy","Complex_Site_Flag":"N","Site_Migration_Flag":"N","Order_Stability_Date":"","Service_Class":"Unknown","Error_Code":"","Error_Description":"","Contact":[{"Site_Contact_Telephone":"","Site_Contact_Mobile":"","Site_Contact_Fax":"","Site_Contact_Email":"","Site_Contact_First_Name":"","Site_Contact_Last_Name":""}]}]}';
        res.setBody(mockBody);
        res.setStatusCode(StatusCode);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }

}