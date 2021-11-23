/**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   Mock for ReplicatorGetServiceManager
* @US       :   EDGE-75696, EDGE-85840, EDGE-84055
* @Status   :   End point Deveopment is still pending.
* */
@isTest
global class ReplicatorGetServiceManagerMock implements HttpCalloutMock {
    
        global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        String endPoint = req.getEndpoint();
        String reqBody = req.getBody();
        res.setBody(getCustomerSites_withSuccess());   
        res.setStatusCode(200);
        
       /*  if(endPoint.contains('CIDN')) {
      
			if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_404_CODE);
            	}
             else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_500_CODE);
            }
              else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_503_CODE);
            }
            else if(endPoint.contains('errorId')) {
            	res.setBody(getCustomerSites_Error());
            }
             else{
                res.setBody(getCustomerSites_withSuccess());   
                res.setStatusCode(200);
             }
          
        }*/
       
         return res;  
    }
    
    
     private static String getCustomerSites_withSuccess() {
        String jsonString = '{"correlationId":"SFDC_REP_GETSERVICE2377acc792fc60c1a2","servicesList":[{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266223323","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":"0266223320-0266223325"},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266221627","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266223531","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266222239","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":"Hunt Group"},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"Primary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0755285593","site":{"siteType":"adbor_id","siteId":"401432055"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":"Hunt Group"},{"name":"service_association_role","value":""},{"name":"service_extension","value":"0755285590-0755285595"},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"Primary"}]}]}';   
            
        return jsonString;
    }

}