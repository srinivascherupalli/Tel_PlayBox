@isTest
public class GetSubscriptionAPITest {
    
    @testsetup 
    public static void dataSetup(){
    
	Account acc = new Account();
	acc.name = 'Account1';
    acc.Type = 'Competitor' ;
	acc.Customer_ID__c = '12345';
    
	insert acc;
        
	cscfga__Configuration_Offer__c off = new cscfga__Configuration_Offer__c();
	off.Offer_Spec_Id__c='123456';
	insert off;
        
	cscrm__Site__c si= new cscrm__Site__c();
	si.name='TestSite';
    si.cscrm__Account__c = acc.id;
	insert si;
        
    csord__Order__c  ord = new csord__Order__c();
    ord.name = 'TestOrder';
    //ord.csord__Order_Number__c='ON00003147';
    ord.csord__Identification__c ='Test';
    insert ord;
        
	csord__Subscription__c subs = new csord__Subscription__c();
    subs.csordtelcoa__Subscription_Number__c = 'SN-000004523';
    subs.csord__Order__c = ord.id;
    subs.name = 'subsTest';
	subs.csord__Account__c = acc.id;
	subs.csordtelcoa__Subscription_Number__c = 'SN-000004523';
	subs.csord__Status__c = 'Complete';
	subs.Contract_Term__c='ABC';
	subs.Serviceability_Location__c='Mumbai';
	subs.Offer__c = off.id;
    subs.csord__Identification__c = 'test identity';
	subs.Site__c=si.id;
	insert subs;
        
	csord__Service__c serv= new csord__Service__c();
	serv.name = 'TestService';
	serv.csord__Subscription__c=subs.id;
    serv.csord__Identification__c='Test';
    insert serv;
	
	Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"null_chrgOC","productConfigurationId":"a3T2O000000932lUAA","name":"Mobile Access_Billing","instanceId":"","guid":"d9a9b4eb-f6c3-e8a8-d1be-2c80e297f39e","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing","attributes":{"__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O000000932lUAA","name":"Unified Communication Site_Fulfilment","instanceId":"","guid":"96ef7588-4e55-7906-41cc-205f994a031f","endDate":"","description":"","code":"DMCAT_ProductSpecification_000104_Fulfilment","attributes":{"PrimaryAccessProductInstanceID":"","DMCAT_ProductSpecification_000104_CPEDeliveryDate":"","ServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000083_Fulfilment","UCEnterpriseProductInstanceID":"DMCAT_ProductSpecification_000087_Fulfilment","RedundantAccessProductInstanceID":"","CustomerPreferredName":"","CustomerFacingServiceId":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{"UCEnterpriseProductInstanceID":"14f630f6-97bc-e5b0-881c-e0adc99bc249","ServiceTypeProductInstanceID":"84155b82-d397-ce83-41a1-aa89bdd3adb5"}},{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000009339UAA","name":"Voice Numbers_Fulfilment","instanceId":"","guid":"01c9cf4e-1682-b8e2-86d3-8a8381795cb7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000109_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"null_chrgOC","productConfigurationId":"a3T2O0000009339UAA","name":"Voice Numbers_Billing","instanceId":"","guid":"815eb403-7178-7684-09a5-86b18ffc9c84","endDate":"","description":"","code":"DMCAT_ProductSpecification_000109_Billing","attributes":{"__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"a4e2O0000004IsnQAE","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
    
    }
    
    @isTest
    public static void testMethodAPI(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String Correlation = 'SN-000004523';     
        req.requestURI = '/v1/subscription-details/SN-000004523';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        //System.debug('Response::' + res.responseBody());
        GetSubscriptionAPI.getSubscriptionDetails();
        system.assertNotEquals(null,res);
    }

}