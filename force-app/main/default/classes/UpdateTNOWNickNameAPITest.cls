//DIGI-22527 Update TNOW NickName REST API. Test class for UpdateTNOWNickNameAPI
@isTest
public class UpdateTNOWNickNameAPITest {
    static RestRequest request = New RestRequest();
    static RestResponse response = new RestResponse();

    @testSetup static Void testSetUp()
    {
        Account acc = new Account();
        acc.Name = 'test NN Account' ;
        acc.Type = 'Enterprise' ;
        insert acc;

        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'T-MDM', product_Specification__c='DMCAT_ProductSpecification_000420',cscfga__Description__c = 'Tenancy');
        pdList.add(CW_PD);
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'T-MDM';
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        insert prodconfigList;
                
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c = 'Active';
        subs.csordtelcoa__Product_Configuration__c = testConfig.Id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
                
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'SVC-000004394';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        insert serv;
    }
	
    static testMethod void testDoPatch() {
        csord__Subscription__c sub = [select Id, csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name='test subs' limit 1];
        request.requestURI = '/services/apexrest/subNicknameUpdate'; //Request URL
        request.httpMethod = 'PATCH'; //Request Method
		String strBody = '{"UpdateNicknameRequest":{"subRec":[{"subNumber":"'+sub.csordtelcoa__Subscription_Number__c+'","nickName":"nn1"},{"subNumber":"123","nickName":"n@n2"},{"subNumber":"456","nickName":"nn2"},{"subNumber":"789","nickName":"uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu"}]}}';
        request.requestBody = Blob.valueOf(strBody);
        Test.startTest();
			testSetUp();
			RestContext.request = request;
			RestContext.response = response; 
			UpdateTNOWNickNameAPI.doPatch();
        Test.stopTest();  
        system.assertNotEquals(null,response);
		system.debug('response::::'+string.valueOf(response.responseBody));
	}

    static testMethod void testNoContent() {
        request.requestURI = '/services/apexrest/subNicknameUpdate'; //Request URL
        request.httpMethod = 'PATCH'; //Request Method
		String strBody = '{"subRec":[{"subNumber":"SN-00229934","nickName":"nn1"}]}';
        request.requestBody = Blob.valueOf(strBody);
        Test.startTest();
			testSetUp();
			RestContext.request = request;
			RestContext.response = response; 
			UpdateTNOWNickNameAPI.doPatch();
        Test.stopTest();  
        system.assertEquals(204,response.statusCode);
		system.debug('response::::'+string.valueOf(response.responseBody));
	}
    
	static testMethod void testParse() {
		String json = '{'+
		'   \"UpdateNicknameResponse\": {'+
		'      \"errorRec\": ['+
		'         {'+
		'            \"subNumber\": \"123\",'+
		'            \"errorReason\": \"not active subscription\"'+
		'         },'+
		'         {'+
		'            \"subNumber\": \"456\",'+
		'            \"errorReason\": \"invalid nickname\"'+
		'         }'+
		'      ]'+
		'   }'+
		'}';
		UpdateNicknameResponseDto obj = UpdateNicknameResponseDto.parse(json);
		System.assert(obj != null);
	}   
}