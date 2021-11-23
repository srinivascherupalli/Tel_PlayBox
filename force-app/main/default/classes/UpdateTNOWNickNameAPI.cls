//Story number: DIGI-22527
//Description: Update Nickname in Subscriptions based on request from TNOW via microservices

@RestResource(urlMapping='/subNicknameUpdate')
global class UpdateTNOWNickNameAPI {
  	@HttpPatch
    global static void doPatch() {
		RestRequest req = RestContext.request;
		RestResponse res = UpdateTNOWNickNameAPIHandler.generateResponse(RestContext.response, req);
    }   
}