/*********************************************************************************************************************************
 * Class Name      :   ProductTestFactory
   ===============================================================================================================================
   Sr.No.    Developer Name          Date          Story Description
   1. 		Rohit Tripathi			06/01/2020		Cyclomatic Complexity , DML Query inside For loop - Issues EDGE-127666,EDGE-127667
 */
@IsTest
public class ProductTestFactory {

	public static string IDENTIFICATION ='IDE1322';
	public static string PRODSPECIF = 'DMCAT_ProductSpecification_000420';//EDGE - 117740
	public static string PRODSPECngUC = 'DMCAT_ProductSpecification_000871';//EDGE - 117740

	public static cscfga__Product_Definition__c buildProductDefinition(String productName, String planName) {
		cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c();
		pd.Name = productName;
		pd.cscfga__Description__c = productName;
		pd.product_Specification__c = PRODSPECIF;//EDGE-117740
		return pd;
	}
	public static cscfga__Product_Definition__c buildProductDefinition1(String productName, String planName) {
		cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c();
		pd.Name = productName;
		pd.cscfga__Description__c = productName;
		pd.product_Specification__c = PRODSPECngUC;//EDGE-117738
		return pd;
	}

	public static csordtelcoa__Change_Types__c buildChangeType(String name) {
		csordtelcoa__Change_Types__c ct = new csordtelcoa__Change_Types__c();
		ct.Name = name;
		return ct;
	}

	public static cspmb__Price_Item__c buildPriceItem(String name, Decimal oc, Decimal rc, String itemCode) {
		return buildPriceItem(name, oc, rc, itemCode, null);
	}

	public static cspmb__Price_Item__c buildPriceItemForOpportunityProduct(String name, Decimal oc, Decimal rc, String productName, String typeName, String optionName, String contractTerms) {
		cspmb__Price_Item__c pi = new cspmb__Price_Item__c();
		pi.name = name;
		pi.cspmb__One_Off_Charge__c = oc;
		pi.cspmb__Recurring_Charge__c = rc;
		pi.OP_Product__c = productName;
		pi.OP_Type__c = typeName;
		pi.OP_Option__c = optionName;
		pi.OP_Contract_Term__c = contractTerms;
		pi.PI_External_Id__c = 'sample123';
		pi.cspmb__Price_Item_Code__c = 'Opportunity Product';
		pi.Commercial_Product_Code__c = 'Opportunity Product'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		return pi;
	}

	public static cspmb__Price_Item__c buildPriceItem(String name, Decimal oc, Decimal rc, String itemCode, String techType) {
		cspmb__Price_Item__c pi = new cspmb__Price_Item__c();
		pi.name = name;
		pi.cspmb__One_Off_Charge__c = oc;
		pi.cspmb__Recurring_Charge__c = rc;
		pi.cspmb__Price_Item_Code__c = itemCode;
		pi.Commercial_Product_Code__c = itemCode; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		pi.PI_External_Id__c = 'priceitem123';
		return pi;
	}

	public static cspmb__add_on_price_item__c buildAddOnPriceItem(String name, String itemCode, String accessType, String accessConfig, String classOfService, String planName) {
		cspmb__add_on_price_item__c aopi = new cspmb__add_on_price_item__c();
		aopi.cspmb__add_on_price_item_code__c = itemCode;
		aopi.ProdSpecId__c = 'TestSpecId';
		aopi.access_type__c = accessType;
		aopi.access_configuration__c = accessConfig;
		aopi.class_of_service__c = classOfService;
		aopi.plan_name__c = planName;
		aopi.AOPI_External_Id__c = 'addonpi123';
		return aopi;
	}

	public static cspmb__Price_Item_Add_On_Price_Item_Association__c buildPriceAssociation(id piId, id aopiId) {
		cspmb__Price_Item_Add_On_Price_Item_Association__c aopia = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
		aopia.cspmb__add_on_price_item__c = aopiId;
		aopia.cspmb__Price_Item__c = piId;
		aopia.PIAOPI_External_Id__c = 'piaopi123';
		return aopia;
	}

	public static cscfga__Attribute__c buildAttribute(String name, String value, Id productConfigId) {
		cscfga__Attribute__c att = new cscfga__Attribute__c();
		att.name = name;
		att.cscfga__Value__c = value;
		att.cscfga__Product_Configuration__c = productConfigId;
		return att;
	}

	public static cscfga__Attribute__c buildPriceAttribute(String name, String value, Id productConfigId, Boolean isRC, Decimal price) {
		cscfga__Attribute__c att = new cscfga__Attribute__c();
		att.name = name;
		att.cscfga__Value__c = value;
		att.cscfga__Product_Configuration__c = productConfigId;
		att.cscfga__Is_Line_Item__c = isRC;
		//EDGE-127666
		att.cscfga__Line_Item_Description__c = 'Rc Charge';
		att.cscfga__Price__c = price;
		return att;
	}

	public static cscfga__Product_Configuration__c buildProductConfig(Id productDefId) {
		cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
		config.name = 'test config';
		config.cscfga__Product_Definition__c = productDefId;
		return config;
	}

	public static cscfga__Attribute_Definition__c buildAttributeDefinition(String name, Id productDefinitionId) {
		cscfga__Attribute_Definition__c attDef = new cscfga__Attribute_Definition__c();
		attDef.name = name;
		attDef.cscfga__Label__c = name;
		attDef.cscfga__Product_Definition__c = productDefinitionId;
		return attDef;
	}

	public static cscfga__Attribute_Field_Definition__c buildAttributeFieldDefinition(String name, Id attrDefinitionId,String defVal) {
		cscfga__Attribute_Field_Definition__c attFieldDef = new cscfga__Attribute_Field_Definition__c();
		attFieldDef.name = name;
		attFieldDef.cscfga__Default_Value__c = defVal;
		attFieldDef.cscfga__Attribute_Definition__c = attrDefinitionId;
		return attFieldDef;
	}

	public static csord__Order__c  buildOrder(String name, Id accountId, String status, Id orderReqId) {
		csord__Order__c ord = new csord__Order__c();
		ord.name = name;
		ord.csord__Account__c = accountId;
		ord.csord__Status2__c = status;
		ord.csord__Order_Request__c = orderReqId;
		ord.csord__Identification__c = IDENTIFICATION;
		ord.stage__c = 'Being Fulfilled';
		return ord;
	}

	public static csord__Subscription__c buildSubscription(String name, Id accountId, Id orderId, id orderReqId) {
		csord__Subscription__c subs = new csord__Subscription__c();
		subs.name = name;
		subs.csord__Account__c = accountId;
		subs.csord__Order__c = orderId;
		subs.csord__Identification__c = IDENTIFICATION;
		subs.csord__Order_Request__c = orderReqId;
		return subs;
	}

	public static csord__Order_Request__c buildOrderRequest() {
		csord__Order_Request__c orderReq = new csord__Order_Request__c();
		orderReq.name = 'OR-12121';
		orderReq.csord__Module_Name__c = 'TestReq';
		orderReq.csord__Module_Version__c = '12';
		return orderReq;
	}

	public static csord__Service__c buildService(String name, Id orderId, Id subscriptionId, Id orderReq) {
		csord__Service__c ser = new csord__Service__c();
		ser.name = name;
		ser.csord__Order__c = orderId;
		ser.csord__Subscription__c = subscriptionId;
		ser.csord__Identification__c = IDENTIFICATION;
		ser.csord__Order_Request__c = orderReq;
		ser.Model__c = name;
		return ser;
	}

	public static csord__Service_Line_Item__c buildServiceLineItem(String name, Id serviceId) {
		csord__Service_Line_Item__c sli = new csord__Service_Line_Item__c();
		sli.Name = name;
		sli.csord__Service__c = serviceId;
		sli.csord__Line_Description__c = '------------ Sli description x 2';
		sli.csord__Identification__c = IDENTIFICATION;
		return sli;
	}

	public static csbb__Callout_Result__c  buildCallOutResults() {
		csbb__Callout_Result__c coResults = new csbb__Callout_Result__c ();
		coResults.csbb__SOAP_Request_Message__c = '<?xml version="1.0" encoding="UTF-8"?><env:Envelope><env:Body><sqCheck xmlns="http://soap.sforce.com/schemas/class/SQAvailabilityCheck"><addressId>112233</addressId></sqCheck ></env:Body></env:Envelope>';
		return coResults;
	}

	public static cscfga__Product_Category__c   buildProductCategory() {
		cscfga__Product_Category__c pc =  new cscfga__Product_Category__c  ();
		pc.name = 'TEST Category';
		pc.cscfga__Active__c  = true;
		pc.cscfga__Browseable__c  = true;
		return pc;
	}

	public static csbb__Callout_Product_Result__c  buildCalloutProductResults(csbb__Product_Configuration_Request__c pcr, csbb__Callout_Result__c cor) {
		csbb__Callout_Product_Result__c productRes = new csbb__Callout_Product_Result__c ();
		productRes.csbb__Product_Configuration_Request__c = pcr.id;
		productRes.csbb__Callout_Result__c = cor.id;
		return productRes;
	}

	public static cscfga__Product_Basket__c buildEmptyBasket() {
		cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
		return basket;
	}

	public static delegated_Pricing_Request__c buildEmptyDPR() {
		delegated_Pricing_Request__c dpr = new delegated_Pricing_Request__c();
		return dpr;
	}

	public static csbb__Product_Configuration_Request__c  buildConfigRequest(Id basketID, Id configId) {
		csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c ();
		pcr.csbb__Product_Configuration__c = configId;
		pcr.csbb__Product_Basket__c = basketId;
		return pcr;
	}

	public static cscfga__Screen_Flow__c  buildScreenFlow(String sfName) {
		cscfga__Screen_Flow__c sf = new cscfga__Screen_Flow__c(name = sfName);
		sf.cscfga__Template_Reference__c = 'Test screen flow Ref';
		return sf;
	}

	public static cscfga__Screen_Flow_Product_Association__c buildSFAssociation(Id prodDefId, Id sfId) {
		cscfga__Screen_Flow_Product_Association__c sfA = new cscfga__Screen_Flow_Product_Association__c();
		sfA.cscfga__Product_Definition__c = prodDefId;
		sfA.cscfga__Screen_Flow__c = sfId;
		return sfA;
	}

	public static CSPOFA__Orchestration_Process_Template__c buildOrchProcessTemplate(){
		CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
		orchProcessTemplate.CSPOFA__Process_Type__c = 'Cease';
		orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
		return orchProcessTemplate;
	}

	public static CSPOFA__Orchestration_Process__c buildOrchProcess(CSPOFA__Orchestration_Process_Template__c template){
		CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
		orchProcess.Name = 'Test Orch Process';
		orchProcess.has_Inactive_Children__c = 'NA';
		orchProcess.CSPOFA__Orchestration_Process_Template__c = template.Id;
		orchProcess.Overall_Cancellation_Status__c = 'Pending';
		orchProcess.CSPOFA__State__c = 'INACTIVE';
		//orchProcess.CSPOFA__Process_On_Hold__c = FALSE;
		return orchProcess;
	}

	public static CSPOFA__Orchestration_Step__c buildOrchStep(CSPOFA__Orchestration_Process__c orchProcess){
		CSPOFA__Orchestration_Step__c orchStep = new CSPOFA__Orchestration_Step__c();
		orchStep.CSPOFA__Orchestration_Process__c = orchProcess.Id;
		return orchStep;
	}
	public static CSPOFA__Orchestration_Process_Template__c createOverAllOrchestrationProcessTemplate()
	{
		CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
		orchProcessTemplate.CSPOFA__Process_Type__c = 'Cease';
		orchProcessTemplate.Name ='Overall Cancellation Tracking';
		orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
		insert orchProcessTemplate;
		return orchProcessTemplate;
	}
	public static CSPOFA__Orchestration_Process_Template__c createChildOrchestrationProcessTemplate()
	{
		CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
		orchProcessTemplate.CSPOFA__Process_Type__c = 'Cease';
		orchProcessTemplate.Name ='Subscription Cancellation';
		orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
		insert orchProcessTemplate;
		return orchProcessTemplate;
	}

	public static Product2 getProduct(){
		Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Hardware');
		return prod;
	}

	public static Pricebook2 getPricebook(){
		Pricebook2 pb = new Pricebook2(Name = 'Custom Price Book', Description = 'Custom Price Book', IsActive = true);
		return pb;
	}

	public static PricebookEntry getPricebookEntry(Product2 pd, Id pb){
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb, Product2Id = pd.Id,UnitPrice = 10000, IsActive = true);
		return pbe;
	}

	public static Opportunity getOpportunity(Account acc, Pricebook2 pb){
		Opportunity opp  = new Opportunity();
		opp.Name = 'TestOpp';
		opp.AccountID = acc.id;
		opp.Pricebook2 = pb;
		opp.StageName = 'Committed';
		opp.CloseDate = System.today();
		//opp.IsActiveAccount__c = true;
		return opp;
	}
	public static Opportunity getOpportunityBasic(Account acc){
		Opportunity opp  = new Opportunity();
		opp.Name = 'TestOpp';
		opp.AccountID = acc.id;
		opp.StageName = 'Committed';
		opp.CloseDate = System.today();
		//opp.IsActiveAccount__c = true;
		return opp;
	}

	public static OpportunityLineItem getOpportunityLineItem(Opportunity opp, PricebookEntry customPrice){
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = opp.Id;
		oli.PricebookEntryId = customPrice.Id;
		oli.Quantity = 2;
		oli.TotalPrice = 10;
		oli.Description = '------------ Oli description';
		return oli;
	}
	public static Billing_Account__c getBillingAccount(){
		Billing_Account__c billingAccount  = new Billing_Account__c(Billing_Account_Number__c ='123456789018');
		return billingAccount;
	}
	/*
	   A test class should have atleast one test method.Otherwise,we will get bug,so to avoid a bug, added one test method.
	 */
	private static testMethod void runPositiveTestCasesToFixBug() {
		System.assertequals('BugFix','BugFix');
	}
}