/*
*   Test class for CalloutResponseAddressCheck2 - that handles the Callout Responses for Address Check via basket
*/
@isTest
public class CalloutResponseSqAvltyNewOrdHdlrTest{
    
   @isTest
    private static void runTestMethodSQCheck() {
		Account acc = AccountTestFactory.buildAccount('Test Account') ;
		acc.Customer_Status__c = 'ACTIVE';
		acc.CIDN__c='1234567891';
		acc.ABN__c='1235';
		insert acc;		
		Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
		insert contact;
		cscrm__Address__c address= AccountTestFactory.buildAddressFull('141671646');
		insert address;		
		Billing_Account__c billingAccount=new Billing_Account__c();
		billingAccount.Billing_Account_Number__c='123456789322';
		billingAccount.Billing_Address__c=address.id;
		billingAccount.Billing_Account_Owner__c=contact.Id;
		billingAccount.Account__c=acc.Id;
		insert billingAccount;		
		cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
		site.Primary_Contact__c = contact.Id;
		site.cscrm__Installation_Address__r = address;
		insert site;
	
        CalloutResponseSqAvltyNewOrdHdlr sqC = new CalloutResponseSqAvltyNewOrdHdlr();
        Map<String, csbb.CalloutResponse> mapCR=new Map<String, csbb.CalloutResponse>();
        Map<String, Object> inputMap = new Map<String, Object>();
        String SQResponse = '{"response":'+getSQResponse_withSuccess()+'}';
        inputMap.put('availabilityResponseRaw',SQResponse);
        inputMap.put('httpStatusCode',200);
        inputMap.put('context','{calloutServiceMethodName=SqAvltyNewOrdHdlr_callSQService, calloutServiceMethodType=availability}');
        Map<String, Object> outputMap = sqC .processResponseRaw(inputMap);
		//CalloutResponseSqAvltyNewOrdHdlr.saveSQErrorResponse('141671646', 'Error occurred', acc.Id);
        System.assert(outputMap!=null);
        System.assertEquals(1, sqC .getDynamicRequestParameters(new Map<String, Object>()).size());
        System.assert(sqC.canOffer(new Map<String, String>(), new Map<String, String>(), new csbb.CalloutProduct.ProductResponse()) != null);                     
        //sqC.runBusinessRules('SqAvltyNewOrdHdlr');
    }
    @isTest
    private static void runTestCalloutService() {
        Map<String, csbb.CalloutResponse> mapCR=new Map<String, csbb.CalloutResponse>();
        csbb.CalloutResponse crPrimary=new csbb.CalloutResponse();
        /*crPrimary.displayMessage='';
        calloutresponse.endTime='';
        crPrimary.httpStatus='Unprocessable Entity';
        calloutresponse.httpStatusCode='422';
        calloutresponse.internalException='';
        crPrimary.jsonRequest='"{\"#SID\" : \"SESSION_ID_REMOVED\", \"ADBORID\" : \"143233719\"}"';
        crPrimary.methodName=callSQService;
        crPrimary.methodShort=null;
        crPrimary.nodeReplace='';
        crPrimary.pathToShortCut=null;
        crPrimary.rawResponse='{"response":{"correlationId":"18255df5-7d6f-40e3-ec70-3b16375e3f57","request":{"correlationId":"18255df5-7d6f-40e3-ec70-3b16375e3f57","requestId":"01ae3888-a0ac-4d5c-941b-a99f9251c28d","method":"GET","path":"/service-addresses","data":{},"params":{"addressId":"143233719","serviceFilter":"Internet"}},"message":"NBN Location id is not available for this address","time":"2019-03-18T18:59:06+10:00","status":422,"code":5019}}';
        crPrimary.response='{response={code=5019, correlationId=18255df5-7d6f-40e3-ec70-3b16375e3f57, message=NBN Location id is not available for this address, request={correlationId=18255df5-7d6f-40e3-ec70-3b16375e3f57, data={}, method=GET, params={addressId=143233719, serviceFilter=Internet}, path=/service-addresses, requestId=01ae3888-a0ac-4d5c-941b-a99f9251c28d}, status=422, time=2019-03-18T18:59:06+10:00}}';
        sObjectId='';
        calloutresponse.serviceName='SqAvltyNewOrdHdlr';
        calloutresponse.shortCuts=null;
        calloutresponse.soapRequest='143233719';
        calloutresponse.soapResponse=null;
        calloutresponse.status='Success';*/
        csbb.CalloutProduct.ProductResponse PR= new csbb.CalloutProduct.ProductResponse();
        PR.available='';
        PR.displayMessage=null;
        PR.fields=new Map<String,String>();
        PR.fields.put('PrimaryCallout','SqAvltyNewOrdHdlr');//={PrimaryCallout=SqAvltyNewOrdHdlr};
        //PR.listexs=null; 
        //PR.product=null; 
        ///PR.productid=null;
        cscfga__Product_Category__c prodCategory=new cscfga__Product_Category__c();
        prodCategory.name='Site Specific';
        insert prodCategory;
        csbb.ProductCategory productCategory=new csbb.ProductCategory(prodCategory.id);
        CalloutResponseSqAvltyNewOrdHdlr sqC = new CalloutResponseSqAvltyNewOrdHdlr(mapCR,productCategory,PR);
        sqC.crPrimary=crPrimary;
        sqc.mapCR=mapCR;
        sqC.productCategory=productCategory;
        sqc.productResponse=PR;
        sqC.runBusinessRules('SqAvltyNewOrdHdlr');
    }    
    public static String getSQResponse_withSuccess(){
    
    //String jsonString ='{"response":{"correlationId":"2cc94865-ae8d-4eff-dece-376cb80e511c","request":{"correlationId":"25c53bbf-6884-4435-619b-5dc7d589efc4","requestId":"d29072cd-4fa2-436b-9b0c-ca09577f120d","method":"GET","path":"/service-addresses","data":{},"params":{"serviceFilter":"Internet","addressId":"141671646"}},"data":{"scheduledDates":{"orderStabilityPeriodDate":"","ceaseSaleDate":""},"messages":[{"message":"The dates cannot be retrieved due to downstream errors","code":"SQNTT002"}],"serviceTypeQualifications":[{"appointmentRequired":"No","readyForServiceDate":"2011-10-09","copperPairIndicator":"Y","characteristics":[{"value":"100 Mbps","name":"TC4 Downstream Upper Rate"},{"value":"75 Mbps","name":"TC4 Downstream Lower Rate"},{"value":"40 Mbps","name":"TC4 Upstream Upper Rate"},{"value":"20 Mbps","name":"TC4 Upstream Lower Rate"}],"statusReason":"NBN Internet is serviceable at this address","providerResources":[{"serviceabilityClass":"13","status":"Line Not In Use","id":"CPI170808084915","resourceType":"Copper Pair"}],"status":"Available","locationId":"LOC170808084915","serviceType":"Internet","serviceTransferIndicator":"N","csaId":"CSA700000000406","newDevelopmentChargesApply":"No","technologyType":"Fibre To The Node","serviceabilityClass":"13"}],"additionalTrafficClassAvailability":[{"value":"No","name":"High Speed TC2 (greater or equal to 20Mbps)"},{"value":"No","name":"TC2"},{"value":"No","name":"NCAS TC2 5Mbps Capacity"},{"value":"No","name":"NCAS TC2 10Mbps Capacity"},{"value":"No","name":"NCAS TC2 20Mbps Capacity"},{"value":"No","name":"NCAS TC2 30Mbps Capacity"},{"value":"No","name":"NCAS TC2 40Mbps Capacity"},{"value":"No","name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)"},{"value":"Yes","name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)"},{"value":"Yes","name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)"},{"value":"No","name":"Multicast"}],"addressId":"141671646"},"time":"2019-03-13T17:41:23+10:00","status":200,"code":200}}';
	String jsonString ='{"correlationId":"2cc94865-ae8d-4eff-dece-376cb80e511c","request":{"correlationId":"25c53bbf-6884-4435-619b-5dc7d589efc4","requestId":"d29072cd-4fa2-436b-9b0c-ca09577f120d","method":"GET","path":"/service-addresses","data":{},"params":{"serviceFilter":"Internet","addressId":"141671646"}},"data":{"scheduledDates":{"orderStabilityPeriodDate":"","ceaseSaleDate":""},"messages":[{"message":"The dates cannot be retrieved due to downstream errors","code":"SQNTT002"}],"serviceTypeQualifications":[{"appointmentRequired":"No","readyForServiceDate":"2011-10-09","copperPairIndicator":"Y","characteristics":[{"value":"100 Mbps","name":"TC4 Downstream Upper Rate"},{"value":"75 Mbps","name":"TC4 Downstream Lower Rate"},{"value":"40 Mbps","name":"TC4 Upstream Upper Rate"},{"value":"20 Mbps","name":"TC4 Upstream Lower Rate"}],"statusReason":"NBN Internet is serviceable at this address","providerResources":[{"serviceabilityClass":"13","status":"Line Not In Use","id":"CPI170808084915","resourceType":"Copper Pair"}],"status":"Available","locationId":"LOC170808084915","serviceType":"Internet","serviceTransferIndicator":"N","csaId":"CSA700000000406","newDevelopmentChargesApply":"No","technologyType":"Fibre To The Node","serviceabilityClass":"13"}],"additionalTrafficClassAvailability":[{"value":"No","name":"High Speed TC2 (greater or equal to 20Mbps)"},{"value":"No","name":"TC2"},{"value":"No","name":"NCAS TC2 5Mbps Capacity"},{"value":"No","name":"NCAS TC2 10Mbps Capacity"},{"value":"No","name":"NCAS TC2 20Mbps Capacity"},{"value":"No","name":"NCAS TC2 30Mbps Capacity"},{"value":"No","name":"NCAS TC2 40Mbps Capacity"},{"value":"No","name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)"},{"value":"Yes","name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)"},{"value":"Yes","name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)"},{"value":"No","name":"Multicast"}],"addressId":"141671646"},"time":"2019-03-13T17:41:23+10:00","status":200,"code":200}';        
        return jsonString;
    }
}