/**================================================================
 * Appirio, Inc
 * Name: Orchestration_MSISDNHeldOrderToReservedTest
 * Class: Orchestration_MSISDNHeldOrderToReserved
 * Created Date: July 8, 2020
 * Created By: Shweta Khandelwal/Martand Atrey
 ==================================================================*/
@isTest
public with sharing class Orchestration_MSISDNHeldOrderToResvTest {
	@Testsetup
	static void dataSetup() {
		Governor_Limits__c governerLimit = new Governor_Limits__c();
		List<account> accountList = new List<account>();
		List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
		List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
		List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
		List<csord__Service__c> servlist = new List<csord__Service__c>();
		List<csord__Service__c> servO1List = new List<csord__Service__c>();
		List<csord__Service__c> servO2List = new List<csord__Service__c>();
		List<csord__Service__c> servO3List = new List<csord__Service__c>();
		List<csord__Order__c> orderList = new List<csord__Order__c>();
		list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
		list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
		List<Marketable_Offer__c> marketableList = new List<Marketable_Offer__c>();
		List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
		List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();
		List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();

		governerLimit = Orchestration_TestUtility.buildLimits();

		accountList = Orchestration_TestUtility.buildAccount(false, 2);
		accountList[1].Customer_Status__c = 'Acquired';
		insert accountList;

		orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
		orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 4);
		orderList[0].isAppointmentRequired__c = 'false';
		orderList[0].isMSISDNHeld__c = true;
		orderList[0].isMSISDNReserved__c = false;
		orderList[1].isMSISDNReserved__c = true;
		orderList[2].csord__Order_Request__c = null;
		insert orderList;
		processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
		productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 3);
		productconfiglistList[1].Type__c = 'cancel';
		productconfiglistList[2].Type__c = null;
		insert productconfiglistList;

		List<cscfga__attribute__c> attrList = new List<cscfga__attribute__c>{
			new cscfga__attribute__c(Name = 'MSISDN', cscfga__Product_Configuration__c = productconfiglistList[0].Id, cscfga__value__c = 'TEST'),
			new cscfga__attribute__c(Name = 'MSISDN', cscfga__Product_Configuration__c = productconfiglistList[1].Id, cscfga__value__c = 'TEST'),
			new cscfga__attribute__c(Name = 'MSISDN', cscfga__Product_Configuration__c = productconfiglistList[2].Id, cscfga__value__c = 'TEST')
		};
		insert attrList;

		solutionList = Orchestration_TestUtility.buildSolution(false, 1);
		solutionList[0].Name = 'Testing';
		insert solutionList;

		marketableList = Orchestration_TestUtility.buildMarkertableOffer(false, 1);
		marketableList[0].Auto_Expired_Entity__c = true;
		insert marketableList;

		siteList = Orchestration_TestUtility.buildsite(true, 1, accountList);

		subscriptionList = Orchestration_TestUtility.buildSubscription(false, 4, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
		subscriptionList[0].csord__Account__c = accountList[1].id;
		subscriptionList[0].MarketableOffer__c = marketableList[0].id;
		subscriptionList[0].Site__c = siteList[0].id;
		subscriptionList[1].csordtelcoa__Replacement_Subscription__c = null;
		subscriptionList[1].Site__c = siteList[0].id;
		subscriptionList[2].Site__c = siteList[0].id;
		subscriptionList[3].Site__c = siteList[0].id;
		subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].Id;
		subscriptionList[3].csordtelcoa__Product_Configuration__c = productconfiglistList[2].Id;
		subscriptionList[1].csord__Order__c = orderList[1].Id;
		subscriptionList[2].csord__Order__c = orderList[2].Id;
		subscriptionList[3].csord__Order__c = orderList[3].Id;
		insert subscriptionList;

		//Below Will create Services for each Order
		servlist = Orchestration_TestUtility.buildService(false, 4, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
		servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
		servlist[0].Name = 'IP Site  0';
		servlist[1].Name = 'IP Site  1';
		servlist[2].Name = 'IP Site  2';
		servlist[3].Name = 'IP Site  3';
		servlist[0].Zone__c = '1';
		servlist[1].Zone__c = '3';
		servlist[2].Zone__c = '1';
		servlist[3].Zone__c = '2';
		servlist[0].SiteId__c = siteList[0].id;
		servlist[1].SiteId__c = siteList[0].id;
		servlist[2].SiteId__c = siteList[0].id;
		servlist[3].SiteId__c = siteList[0].id;
		servlist[1].csord__Subscription__c = subscriptionList[1].id;
		servlist[2].csord__Subscription__c = subscriptionList[2].id;
		servlist[3].csord__Subscription__c = subscriptionList[3].id;
		servlist[2].Cust_Req_Disconn_Date__c = Date.today();
		servlist[0].Cust_Req_Disconn_Date__c = Date.today();
		servlist[1].Cust_Req_Disconn_Date__c = Date.today();
		servlist[3].Cust_Req_Disconn_Date__c = Date.today();
		servlist[0].Not_Before_CRD__c = Date.today();
		servlist[1].Not_Before_CRD__c = Date.today();
		servlist[2].Not_Before_CRD__c = Date.today();
		servlist[3].Not_Before_CRD__c = Date.today();
		insert servlist;
		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servO1List = Orchestration_TestUtility.buildService(false, 1, subscriptionList[1].id, orderReqList[0].id, orderList[1].id, productconfiglistList[0].id);
		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servO2List = Orchestration_TestUtility.buildService(false, 2, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[0].id);
		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servO3List = Orchestration_TestUtility.buildService(false, 3, subscriptionList[3].id, orderReqList[0].id, orderList[3].id, productconfiglistList[0].id);
		servO1List[0].Name = 'IP Site 001';
		servO2List[0].Name = 'IP Site 011';
		servO2List[1].Name = 'IP Site 012';
		servO3List[0].Name = 'IP Site 021';
		servO3List[1].Name = 'IP Site 022';
		servO3List[2].Name = 'IP Site 023';
		servlist[3].csordtelcoa__Replaced_Service__c = null;
		servO1List[0].csordtelcoa__Replaced_Service__c = null;
		servO2List[0].csordtelcoa__Replaced_Service__c = null;
		servO2List[1].csordtelcoa__Replaced_Service__c = null;
		servO3List[0].csordtelcoa__Replaced_Service__c = null;
		servO3List[1].csordtelcoa__Replaced_Service__c = null;
		servO3List[2].csordtelcoa__Replaced_Service__c = null;
		System.debug(servO1List + '===>servO1List');
		System.debug(servO2List + '===>servO2List');
		System.debug(servO3List + '===>servO3List');
		insert servO1List;
		insert servO2List;
		insert servO3List;

		//Main processes and Steps to run
		processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
		processList[2].Order__c = null;
		insert processList;

		orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
		orchStepList[3].JSON__C = null;
		insert orchStepList;

		//App Log to check the Data is fetched from this.
		appLog = Orchestration_TestUtility.buildApp(false, 4, orchStepList, processList);
		appLog[0].Related_Record_Id__c = servlist[1].id;
		appLog[0].Status_Code__c = '200';
		appLog[0].Step__c = orchStepList[0].id;
		appLog[0]
			.Message__c = '{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"9828200076","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"9828200076"}]}}}';

		appLog[3].Related_Record_Id__c = servO2List[0].id;
		appLog[3].Status_Code__c = '200';
		appLog[3].Step__c = orchStepList[3].id;

		appLog[3]
			.Message__c = '{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"9828200076","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"9828200076"}]}}}';
		appLog[2].Related_Record_Id__c = servO2List[1].id;
		appLog[2].Status_Code__c = '400';
		appLog[2].Step__c = orchStepList[3].id;

		appLog[2]
			.Message__c = '{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"9828200076","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"9828200076"}]}}}';

		appLog[1].Related_Record_Id__c = servO1List[0].id;
		appLog[1].Status_Code__c = '200';
		appLog[1].Step__c = orchStepList[1].id;
		appLog[1]
			.Message__c = '{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"9828200076","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"9828200076"}]}}}';

		appLog[0].Reference_Info__c = 'HeldToReserveMSISDNHandler';
		appLog[1].Reference_Info__c = 'HeldToReserveMSISDNHandler';
		appLog[2].Reference_Info__c = 'HeldToReserveMSISDNHandler';
		appLog[3].Reference_Info__c = 'HeldToReserveMSISDNHandler';
		insert appLog;
	}

	// Main Test to Test the Main Functionality
	@isTest
	static void calloutTest() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		System.debug(orchStepList + '===>orchStepList');
		List<csord__Service__c> serviceLIst = [
			SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c
			FROM csord__service__c
			WHERE csord__order__c != null AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND NAME LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null
		];

		List<csord__Order__c> orderIds = [SELECT ID FROM csord__Order__c];
		System.debug(
			[
				SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c
				FROM csord__service__c
				WHERE csord__order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND NAME LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null
			] + '===>[SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c FROM csord__service__c WHERE csord__order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null]'
		);
		System.debug(orderIds + '===>orderIds');

		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(202));
		CSPOFA__Orchestration_Process__c orchProcess = [SELECT ID, Order__c FROM CSPOFA__Orchestration_Process__c WHERE Id = :orchStepList[0].CSPOFA__Orchestration_Process__c LIMIT 1];
		orchProcess.Order__c = serviceLIst[0].csord__Order__c;
		update orchProcess;
		csord__Order__c ord = new csord__Order__c(Id = orchProcess.Order__c, isMSISDNHeld__c = true, isMSISDNReserved__c = false);
		update ord;
		System.debug(ord + '===>ord');
		Test.startTest();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);
		Test.stopTest();
		System.assertEquals(true, result);
		System.assert([SELECT ID, isMSISDNReserved__c FROM csord__Order__c WHERE Id = :ord.Id][0].isMSISDNReserved__c);
	}

	@isTest
	static void calloutreservedTest() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		List<csord__Service__c> serviceLIst = [
			SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c
			FROM csord__service__c
			WHERE csord__order__c != null AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND NAME LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null
		];
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.Order__c = :serviceLIst[0].csord__Order__c LIMIT 1];
		csord__Order__c order = [SELECT id FROM csord__Order__c WHERE Id = :serviceLIst[0].csord__Order__c];
		order.isMSISDNReserved__c = true;
		order.isMSISDNHeld__c = true;
		update order;
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(202));

		Test.startTest();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		Test.stopTest();
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

		System.assertEquals(true, result);

		System.assertEquals(result1[0].get('CSPOFA__Status__c'), OrchestratorConstants.OrchestratorStep.Complete);
	}

	@isTest
	static void calloutHELDTest() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

		csord__Order__c order = [SELECT id FROM csord__Order__c WHERE Name = 'order10'];
		order.isMSISDNHeld__c = false;
		update order;
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(202));

		Test.startTest();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		Test.stopTest();
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

		System.assertEquals(true, result);
	}

	@isTest
	static void breakingLimitsInStart() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Governor_Limits__c governerLimit = new Governor_Limits__c();
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.SOQL_limit__c = '0';

		update governerLimit;
		Test.startTest();
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Boolean callout = submitOrder.performCallouts(orchStepList);
		submitOrder.process(orchStepList);
		boolean isNull = orchStepList == null ? true : false;
		System.assertEquals(isNull, false);
		Test.stopTest();
	}

	static testMethod void performCallNullTest() {
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();

		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(202));

		Test.startTest();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		//Test.startTest();
		try {
			submitOrder.performCallouts(null);
			submitOrder.process(null);
		} catch (Exception ex) {
			System.assert(String.isNotBlank(ex.getMessage()));
		}
		Test.stopTest();
	}

	// Where dml hit
	@isTest
	static void performCalloutsTestdmlHit() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		Governor_Limits__c governerLimit = new Governor_Limits__c();
		governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
		governerLimit.DML_Rows_limit__c = '1';
		update governerLimit;

		Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Orchestration_MSISDNHeld_MockResponse mockresponse = new Orchestration_MSISDNHeld_MockResponse(202);
		HTTPResponse response = mockresponse.respond(new HttpRequest());
		Test.setMock(HttpCalloutMock.class, mockresponse);

		Test.startTest();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

		Test.stopTest();
		System.assertEquals(true, result);
	}

	// App response message != null
	static testMethod void exceptionStepAppResponse() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(404));

		Test.startTest();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
		orchStepList[0].CSPOFA__Message__c = null;
		update orchStepList;
		Boolean callout = submitOrder.performCallouts(orchStepList);
		orchStepList = submitOrder.process(orchStepList);

		System.assert(orchStepList != null);
		Test.stopTest();
	}

	//Partial case
	static testMethod void breakingPartialCase() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(202));

		//Test.startTest();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');

		Governor_Limits__c governerLimit = new Governor_Limits__c();
		governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
		governerLimit.DML_Rows_limit__c = '1';
		update governerLimit;
		Test.startTest();
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Boolean callout = submitOrder.performCallouts(orchStepList);
		orchStepList = submitOrder.process(orchStepList);

		System.assert(orchStepList != null);
		Test.stopTest();
	}

	//Partial case
	static testMethod void noTokenCase() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		System.debug(orchStepList + '===>orchStepList');
		List<csord__Service__c> serviceLIst = [
			SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c
			FROM csord__service__c
			WHERE csord__order__c != null AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND NAME LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null
		];
		/* 	System.debug(
			[
				SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c
				FROM csord__service__c
				WHERE csord__order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND NAME LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null
			] +
			'===>[SELECT Id, csord__Order__c, csord__Service__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c FROM csord__service__c WHERE csord__order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null]'
		);
		System.debug(orderIds + '===>orderIds'); */

		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Test.setMock(HttpCalloutMock.class, new Orchestration_MSISDNHeld_MockResponse(202));
		CSPOFA__Orchestration_Process__c orchProcess = [SELECT ID, Order__c FROM CSPOFA__Orchestration_Process__c WHERE Id = :orchStepList[0].CSPOFA__Orchestration_Process__c LIMIT 1];
		orchProcess.Order__c = serviceLIst[0].csord__Order__c;
		update orchProcess;
		csord__Order__c ord = new csord__Order__c(Id = orchProcess.Order__c, isMSISDNHeld__c = true, isMSISDNReserved__c = false);
		update ord;
		Test.startTest();
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Boolean callout = submitOrder.performCallouts(orchStepList);
		orchStepList = submitOrder.process(orchStepList);

		System.assert(orchStepList != null);
		Test.stopTest();
	}

	static testMethod void breakingCallLimits() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		Governor_Limits__c governerLimit = new Governor_Limits__c();
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.SOQL_limit__c = '2';
		update governerLimit;

		Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Orchestration_MSISDNHeld_MockResponse mockresponse = new Orchestration_MSISDNHeld_MockResponse(202);
		HTTPResponse response = mockresponse.respond(new HttpRequest());
		Test.setMock(HttpCalloutMock.class, mockresponse);

		Test.startTest();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

		//String jobId = System.enqueueJob(new AppointmentServiceCalloutQ(subList,ord.id));
		Test.stopTest();
		// System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
		System.assertEquals(false, result);
	}

	static testMethod void breakingCallLimits1() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		Governor_Limits__c governerLimit = new Governor_Limits__c();
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.SOQL_limit__c = '1';
		update governerLimit;

		Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Orchestration_MSISDNHeld_MockResponse mockresponse = new Orchestration_MSISDNHeld_MockResponse(404);
		HTTPResponse response = mockresponse.respond(new HttpRequest());
		Test.setMock(HttpCalloutMock.class, mockresponse);

		Test.startTest();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

		//String jobId = System.enqueueJob(new AppointmentServiceCalloutQ(subList,ord.id));
		Test.stopTest();
		// System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
		System.assertEquals(false, result);
	}

	static testMethod void breakingCallLimits5() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

		Governor_Limits__c governerLimit = new Governor_Limits__c();
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.SOQL_limit__c = '5';
		update governerLimit;

		Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
		String handler = 'HeldToReserveMSISDNHandler';
		Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
		Orchestration_MSISDNHeld_MockResponse mockresponse = new Orchestration_MSISDNHeld_MockResponse(202);
		HTTPResponse response = mockresponse.respond(new HttpRequest());
		Test.setMock(HttpCalloutMock.class, mockresponse);

		Test.startTest();

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
		List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

		Test.stopTest();
		System.assertEquals(false, result);
	}

	@isTest
	static void hasLimitsViolatedTest() {
		Governor_Limits__c gl = [SELECT ID FROM Governor_Limits__c];
		gl.DML_Rows_limit__c = '0';
		update gl;
		Boolean limitsRes;
		Test.startTest();
		Orchestration_MSISDNHeldOrderToReserved submitOrder = new Orchestration_MSISDNHeldOrderToReserved();
		limitsRes = submitOrder.hasDMLRowsLimitExceeded();

		Test.stopTest();
		System.assert(limitsRes);
	}
}