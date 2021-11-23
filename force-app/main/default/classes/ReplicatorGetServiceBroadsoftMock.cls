@isTest
global class ReplicatorGetServiceBroadsoftMock implements HttpCalloutMock{
	protected String resType;
    
    global ReplicatorGetServiceBroadsoftMock(String resType){
        this.resType = resType;
    }
     global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success = '{"correlationId":"473685095830478","services":[{"cidn":"9501331855","productFamily":"BW-TENANCY","fnn":"N7005109R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD  KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"enterprise"},{"name":"inflight_order","value":"N"},{"name":"bw_product_family","value":"TIPT"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7740924R","linkedServiceRole":"group","linkedServiceCidn":"9501331855"},{"linkedServiceId":"0749679700","linkedServiceRole":"service","linkedServiceCidn":"9501331855"}],"serviceExtensions":[]},{"cidn":"9501331855","productFamily":"BW-TENANCY","fnn":"N7740924R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD  KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"eligibility_flag","value":"No"},{"name":"eligibility_reason","value":"ER5.1 - Enterprise Trunking,ER2.1 - not aligned to 100 block ranges"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise","linkedServiceCidn":"9501331855"},{"linkedServiceId":"0749679700","linkedServiceRole":"service","linkedServiceCidn":"9501331855"}],"serviceExtensions":[]},{"cidn":"9501331855","productFamily":"BW-TENANCY","fnn":"N7005109U","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD  KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise","linkedServiceCidn":"9501331855"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group","linkedServiceCidn":"9501331855"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679700","serviceExtensionTo":"0749679729"},{"serviceExtensionFrom":"0749679735","serviceExtensionTo":"0749679735"},{"serviceExtensionFrom":"0749679748","serviceExtensionTo":"0749679748"},{"serviceExtensionFrom":"0749679750","serviceExtensionTo":"0749679799"},{"serviceExtensionFrom":"0749679800","serviceExtensionTo":"0749679899"},{"serviceExtensionFrom":"0749679900","serviceExtensionTo":"0749679999"}]}]}';
        String error='{"code":"404","message":"Error String"}';
        String noServices='{"correlationId":"9747ee0018d7ac6226","services":[]}';
        
        if(resType.equals('success')){
            res.setBody(success);
            res.setStatusCode(200);
            
        }
        else if(resType.equals('error')){
            res.setBody(error);
            res.setStatusCode(404);
        }
         else if(resType.equals('noServices')){
            res.setBody(noServices);
            res.setStatusCode(200);
             System.debug('noServices block');
        }
       
        return res;
    }
}