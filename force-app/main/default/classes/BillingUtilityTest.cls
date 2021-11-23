/********************************************************
 Class Name      :   BillingUtilityTest
Test Class : BillingUtilityTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
    1.     Vaibhav Deshpande      09/09/2020      EDGE-165967 
**********************************************************
*/
@isTest
public class BillingUtilityTest {
public static Governor_Limits__c governerLimit = new Governor_Limits__c();
public static List<account> accountList = new List<account>();
public static List<Opportunity> OpportunityList = new List<Opportunity>();
public static List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
public static List<csord__Service__c> servlist = new List<csord__Service__c>();
public static List<csord__Order__c> orderList = new List<csord__Order__c>();
public static list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
public static list<cscfga__Product_Configuration__c> productconfiglistList1 = new List<cscfga__Product_Configuration__c>();
public static list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
public static List<Marketable_Offer__c> marketableList = new List<Marketable_Offer__c>();
public static List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
public static List<Charge_Line_Item__c> cLIs = new List<Charge_Line_Item__c>();
public static List<Discount_Line_Item__c> dSLIs = new List<Discount_Line_Item__c>();
public static List<Price_Schedule_Line_Item__c> pSLIs = new List<Price_Schedule_Line_Item__c>();
public static List<Tier_Line_Item__c> tLIS = new List<Tier_Line_Item__c>();
public static List<Number__c> numberLst = new List<Number__c>();
public static List<PricingMSResponseObject__c> pmsList = new List<PricingMSResponseObject__c>();
public static String handlerName = 'PostSubscriptionHandler';
public static List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();
public static List<cscrm__Site__c> sites = new List<cscrm__Site__c>();

@Testsetup
static void dataSetup() {
governerLimit = Orchestration_TestUtility.buildLimits();

accountList = Orchestration_TestUtility.buildAccount(false, 2);
accountList[1].Customer_Status__c = 'Acquired';
insert accountList;

OpportunityList = Orchestration_TestUtility.buildOpp(false, 1, accountList);
OpportunityList[0].Model_Change__c = false;
insert OpportunityList;
Billing_Account__c ba = new Billing_Account__c();
ba.Account__c = accountList[0].Id;
ba.Billing_Account_Number__c = '123123122234';
insert ba;

sites = Orchestration_TestUtility.buildsite(true, 1, accountList);
cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c(Name = 'test', cscfga__Opportunity__c = OpportunityList[0].Id);
insert pb;
List<cscfga__Product_Definition__c> productDefList = new List<cscfga__Product_Definition__c>();
cscfga__Product_Definition__c productDef = new cscfga__Product_Definition__c(
  Name = 'Mobile Subscription', // Name
  csordtelcoa__Product_Type__c = 'Subscription', // Product Type
  cscfga__Description__c = 'Mobile Subscription', // Description
  cscfga__Label__c = 'Mobile Subscription', // Label
  product_Specification__c = 'DMCAT_ProductSpecification_000420' // product Specification 
  
);
productDefList.add(productDef);
cscfga__Product_Definition__c productDefNGUC = new cscfga__Product_Definition__c(
                Name = 'User Support', // Name
                csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                cscfga__Description__c = 'User Support', // Description
                cscfga__Label__c = 'User Support', // Label
                product_Specification__c = 'DMCAT_ProductSpecification_000871' // product Specification
                
            );
            
productDefList.add(productDefNGUC);
insert productDefList;

orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 2);
orderList[0].Billing_Account__c = ba.Id;
orderList[1].Billing_Account__c = ba.Id;
insert orderList;

//orderList[0].csord__Primary_Order__c = orderList[0].Id;
orderList[1].csord__Primary_Order__c = orderList[0].Id;
update orderList;

processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
Orchestration_TestUtility.productconfiglistList = new list<cscfga__Product_Configuration__c>();
productconfiglistList1 = Orchestration_TestUtility.buildProductConfiguration(true, 1);
Orchestration_TestUtility.productconfiglistList = new list<cscfga__Product_Configuration__c>();
productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 8);
productconfiglistList[0].ConfigurationType1__c = '';
productconfiglistList[0].cscfga__Product_Definition__c = productDef.Id;
productconfiglistList[0].cscfga__Product_Basket__c = pb.Id;
productconfiglistList[0].csordtelcoa__Replaced_Product_Configuration__c = productconfiglistList1[0].id;
productconfiglistList[7].ConfigurationType1__c = '';
productconfiglistList[7].cscfga__Product_Definition__c = productDefList[1].Id;
productconfiglistList[7].cscfga__Product_Basket__c = pb.Id;  
update productconfiglistList;

solutionList = Orchestration_TestUtility.buildSolution(false, 2);
solutionList[0].Name = 'TestSubsforTest0';
insert solutionList;

marketableList = Orchestration_TestUtility.buildMarkertableOffer(false, 2);
marketableList[0].Auto_Expired_Entity__c = true;
marketableList[0].Offer_ID__c = 'DMCAT_Offer_000646';
marketableList[0].Invoice_Definition__c = 'TEST_DEFINITION';
// marketableList[0].Auto_Expired_Entity__c = true;
marketableList[1].Auto_Expired_Entity__c = true;
marketableList[1].Offer_ID__c = 'DMCAT_Offer_000618';
marketableList[1].Invoice_Definition__c = 'Invoice_Def_1';
insert marketableList;

subscriptionList = Orchestration_TestUtility.buildSubscription(false, 2, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
csord__Subscription__c sbs = [SELECT Id FROM csord__Subscription__c];
subscriptionList[0].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
subscriptionList[0].Name = 'Unified Communication Tenancy Solution';
subscriptionList[0].MarketableOffer__c = marketableList[0].id;
subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
subscriptionList[0].Billing_Account__c = ba.Id;
subscriptionList[0].Site__c = sites[0].Id;
subscriptionList[0].isAggregationPoint__c = true;
subscriptionList[0].oldServiceMSISDN__c = 'Testing';
subscriptionList[1].csordtelcoa__Replaced_Subscription__c = sbs.Id;
subscriptionList[0].csordtelcoa__Replaced_Subscription__c = sbs.Id;
subscriptionList[0].autoExpiry__c = true;
subscriptionList[1].autoExpiry__c = true;
subscriptionList[0].TenancyID__c = 'T1002';
csord__Subscription__c subPrdChar=new csord__Subscription__c();
subPrdChar.name  = 'TestPrdChar';
subPrdChar.csord__Identification__c = 'TestPrdChar';
subPrdChar.csord__Status__c='Provisioned';
subPrdChar.csord__Order__c = orderList[0].Id;
subPrdChar.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
//subPrdChar.Billing_Account__c=billingAccount.id;
subscriptionList.add(subPrdChar);

csord__Subscription__c subFNN=new csord__Subscription__c();
subFNN.name  = 'TestPrdCharFNN';
subFNN.csord__Identification__c = 'TestPrdCharFNN';
subFNN.csord__Status__c='Provisioned';
subFNN.csord__Order__c = orderList[0].Id;
subFNN.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
subscriptionList.add(subFNN);

csord__Subscription__c subCOMN =new csord__Subscription__c();
subCOMN.name  = 'TestChangeOfNum';
subCOMN.csord__Identification__c = 'TestChangeOfNum';
subCOMN.csord__Status__c='Provisioned';
subCOMN.csord__Order__c = orderList[0].Id;
subCOMN.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
subCOMN.serviceMSISDN__c = '61244547317';
subCOMN.oldServiceMSISDN__c = '61244547316';
subscriptionList.add(subCOMN);
    
csord__Subscription__c subPrdChar1=new csord__Subscription__c();
subPrdChar1.name  = 'TestRFA';
subPrdChar1.csord__Identification__c = 'TestRFA';
subPrdChar1.csord__Status__c='Ready for Activation';
subPrdChar1.Trigger_RFA__c= true;
subPrdChar1.csord__Order__c = orderList[0].Id;
subPrdChar1.csordtelcoa__Product_Configuration__c=productconfiglistList[1].id;
subscriptionList.add(subPrdChar1);
csord__Subscription__c testSubscription = new csord__Subscription__c();
              testSubscription.MarketableOffer__c = marketableList[1].id;
              testSubscription.Name = 'test Subscription for NGUC';
              testSubscription.csord__Account__c = accountList[1].id;
              testSubscription.csord__Identification__c = 'test';
              testSubscription.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
              testSubscription.csord__Order__c = orderList[0].id; // used in Orchestration_EvaluateOrderStatusTest
              testSubscription.csordtelcoa__Product_Configuration__c = productconfiglistList[7].id;   
              testSubscription.triggerBill_RTB__c = false;
              //testSubscription.Billing_Account__c = ba[0];
              testSubscription.cssdm__solution_association__c = solutionList[0].id;
              testSubscription.isAggregationPoint__c = true;
              testSubscription.oldServiceMSISDN__c = 'Testing';
              testSubscription.autoExpiry__c = true;
              testSubscription.TenancyID__c = 'T1002';
              subscriptionList.add(testSubscription);

csord__Subscription__c subChown1=new csord__Subscription__c();
subChown1.name  = 'subChownrep';
subChown1.csord__Identification__c = 'subChownrep';
subChown1.csord__Status__c='Provisioned';
subChown1.Billing_Account__c = ba.Id;
subChown1.csord__Order__c = orderList[0].Id;
subChown1.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
subscriptionList.add(subChown1);
              
csord__Subscription__c subChown=new csord__Subscription__c();
subChown.name  = 'subChown';
subChown.csord__Identification__c = 'subChown';
subChown.csord__Status__c='Provisioned';
subChown.csord__Order__c = orderList[0].Id;
subChown.csordtelcoa__Replaced_Subscription__c = subChown1.id;
//subChown.Action_Type__c='CHOWN';
subChown.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
subscriptionList.add(subChown);
insert subscriptionList;

servlist = Orchestration_TestUtility.buildService(false, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
servList[0].Scenario_Type__c = 'Change of Mobile Number';
servList[1].Scenario_Type__c = 'Replace SIM';
servList[0].Offer_Type__c = 'Committed Data';
servList[0].Mobility_Plan__c = 'Local Data SIM BYO';
servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;

csord__Service__c prdCharServ = new csord__Service__c();
prdCharServ.name ='TestProdChar';
prdCharServ.csord__Identification__c  = 'TestProdChar';
prdCharServ.csord__Subscription__c = subPrdChar.Id;
prdCharServ.csord__Status__c = 'Connected'; 
prdCharServ.csord__Order__c = orderList[0].Id;
servlist.add(prdCharServ);

csord__Service__c prdCharFNN = new csord__Service__c();
prdCharFNN.name ='TestProdCharFNN';
prdCharFNN.csord__Identification__c  = 'TestProdCharFNN';
prdCharFNN.csord__Subscription__c = subFNN.Id;
prdCharFNN.csord__Status__c = 'Connected'; 
prdCharFNN.csord__Order__c = orderList[0].Id;
servlist.add(prdCharFNN);
    
csord__Service__c prdCharCOMN = new csord__Service__c();
prdCharCOMN.name ='TestProdCharFNN';
prdCharCOMN.csord__Identification__c  = 'TestProdCharFNN';
prdCharCOMN.csord__Subscription__c = subCOMN.Id;
prdCharCOMN.csord__Status__c = 'Connected'; 
prdCharCOMN.csord__Order__c = orderList[0].Id;
prdCharCOMN.Scenario_Type__c = 'Change of Mobile Number';
servlist.add(prdCharCOMN);
    
csord__Service__c prdCharServ1 = new csord__Service__c();
prdCharServ1.name ='TestProdChar1';
prdCharServ1.csord__Identification__c  = 'TestProdChar1';
prdCharServ1.csord__Subscription__c = subPrdChar1.Id;
prdCharServ1.csord__Status__c = 'In Progress'; 
prdCharServ1.csord__Order__c = orderList[0].Id;
servlist.add(prdCharServ1);
csord__Service__c ngucService = new csord__Service__c();
ngucService.csord__Order__c = orderList[0].Id;
ngucService.csord__Status__c = 'created';
ngucService.csord__Identification__c  = 'ngucService';
ngucService.csord__Subscription__c = testSubscription.Id;
ngucService.csordtelcoa__Product_Configuration__c = productconfiglistList[7].id;
ngucService.Scenario_Type__c = 'NGUC Service';
servlist.add(ngucService);

csord__Service__c servChown = new csord__Service__c();
servChown.name ='servChown';
servChown.csord__Identification__c  = 'servChown';
servChown.csord__Subscription__c = subChown.Id;
servChown.csord__Status__c = 'Connected'; 
servChown.Scenario_Type__c = 'CHOWN';
//servChown.Action_Type__c = 'CHOWN';
servChown.csord__Order__c = orderList[0].Id;
servlist.add(servChown);
insert servlist;

cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
cLIs[0].chargeType__c = 'Tiered Recurring';
cLIs[1].chargeType__c = 'Tiered Recurring';
//cLIs[1].
insert cLIs;

dSLIs.addAll(Orchestration_TestUtility.buildDLIs(true, 3, cLIs));
pSLIs.addAll(Orchestration_TestUtility.buildPSLIs(true, 3, cLIs));

tLIS.addAll(Orchestration_TestUtility.buildTLIs(true, 3, pSLIs));

numberLst = Orchestration_TestUtility.buildNumber(false, 7, productconfiglistList, servlist[0].id, subscriptionList[0].id);
numberLst[0].Status__c = 'RESERVED';
numberLst[1].Status__c = 'DISCONNECT PENDING';
numberLst[2].Status__c = 'Disconnect In Progress';
numberLst[3].Status__c = 'Provisioning In Progress';
numberLst[4].Status__c = 'Provisioned';
numberLst[5].Status__c = 'Disconnected';
numberLst[6].Status__c = 'In Progress';
    
Number__c num = new Number__c();
num.Product_Configuration__c = productconfiglistList[0].id;
num.Subscription_number__c = subFNN.id;
num.Service_Id__c = prdCharFNN.id;
num.Service_Number__c = '61244547317';
num.Status__c = 'Provisioned';
numberLst.add(num);

insert numberLst;

List<Attachment> attachmentList = Orchestration_TestUtility.buildAttachment(false, 1, servlist, productconfiglistList[0].id);
attachmentList[0].Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].Id+'","specifications":[{"additionalAttributes":{},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"G001","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","CustomerFacingServiceId":"","RequiredPoolTypes":"Static"},"code":"DMCAT_ProductSpecification_000622","description":"","endDate":"","guid":"4d9f3701-912a-fc43-48d7-b3b565a135d0","includeBilling":false,"instanceId":"","metadata":{},"name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O000000JFlPUAW","specification":"DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000018","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"G004","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"G005","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Disconnected","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000313_Billing","description":"","endDate":"","guid":"G006","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":"","billingSpecId":"BSUSG003_CB"},"code":"DMCAT_ProductSpecification_000537_Fulfilment","description":"","endDate":"","guid":"G007","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000690_Fulfilment","description":"","endDate":"","guid":"G008","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB"},"code":"DMCAT_ProductSpecification_000966_Fulfilment","description":"","endDate":"","guid":"G009","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"CustomerFacingServiceId":"test","tenancyId":"test1","IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"G010","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"CustomerFacingServiceId":"test","tenancyId":"test1","IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB","customRate":[{"schemaId":"37a354d3-1aac-7718-5439-7c941add6706","attributes":{"rangeFrom":"11","rangeTo":"20","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946"}},{"schemaId":"e84bb967-88f0-129a-8b0b-4d77900eb7ed","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952"}},{"schemaId":"eda8a53d-ae35-6485-d6fd-accbf47ebccb","attributes":{"rangeFrom":"201","rangeTo":"500","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950"}},{"schemaId":"050bb815-38b3-caba-29e2-7ed80785468b","attributes":{"rangeFrom":"51","rangeTo":"200","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949"}}]},"code":"DMCAT_ProductSpecification_000313_Billing","description":"","endDate":"","guid":"G011","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{"CustomerFacingServiceId":"test","tenancyId":"test1","IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"Test","SIMSerialNumber":"",'
+'"billingSpecId":"BSUSG001_CB","CustomerFacingServiceId":"test","tenancyId":"test1"},"code":"DMCAT_ProductSpecification_000313_Billing","description":"","endDate":"","guid":"G012","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Disconnect","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"Test","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB","featureID":"featureValue","quantity":"2","rateExcludeGST":"234","billDescription":"billDescriptionval","frequency":"2","currency":"10","billInAdvance":"20","prorate":"20","ocsProdID":"ocsProdIDval","billingSubtype":"subtype","taxTreatment":"Valid","otcDescription":"otcDescriptionVal","creditDescription":"creditDescriptionval", "refundFlag":"true", "ContractTerm":12, "contractType":"Purchase",  "chargeId":"Purchase", "externalId":"Purchase"},'
+'"code":"DMCAT_ProductSpecification_000313_Billing_Allowance_000494_3","description":"","endDate":"","guid":"G013","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"In Progress","version":"1"}]}');

System.debug(attachmentList[0].Body.toString() + '===>attachmentList[0].Body.toString()');

Attachment attprdchr= new Attachment();
attprdchr.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharServ.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
attprdchr.Name = 'ServiceSpecifications.json';
attprdchr.ParentId = prdCharServ.Id;
attachmentList.add(attprdchr);    

Attachment attprdFNN= new Attachment();
attprdFNN.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharFNN.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"ucUsers","billDescription":"Cloud user","customRate":[{"schemaId":"8a887be9-e2c0-aedb-f047-aa7bd636408b","attributes":{"rangeFrom":"1","rangeTo":"10","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6971"}},{"schemaId":"5feac23a-15b7-159e-0cb8-0af3745d2939","attributes":{"rangeFrom":"11","rangeTo":"20","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6972"}},{"schemaId":"bdc2f1af-eb82-839b-2b7f-e382edbd0418","attributes":{"rangeFrom":"21","rangeTo":"50","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6973"}},{"schemaId":"48462240-1733-835c-54d4-2f83eb88298c","attributes":{"rangeFrom":"51","rangeTo":"200","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6974"}},{"schemaId":"761f16d7-27de-ad36-d7cf-77ec5e5c855c","attributes":{"rangeFrom":"201","rangeTo":"500","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6975"}},{"schemaId":"98039cd9-a053-a575-d235-c73d6fa62cf6","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","description":"Business Calling_Billing_RecurringCharge_000813","endDate":"","guid":"997878ff-9abe-3023-e5e1-a8b19592dec4","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_813","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"Hosted UC","billDescription":"Cloud user add-on - unified communications","customRate":[{"schemaId":"4516b180-3248-22c0-cb2c-76bbb638483b","attributes":{"rangeFrom":"51","rangeTo":"200","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6977"}},{"schemaId":"316b741a-7af0-f123-7200-1c83cd607050","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6982"}},{"schemaId":"112ab8b4-1daa-b2ba-0b13-4b6aca254fb7","attributes":{"rangeFrom":"201","rangeTo":"500","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6981"}},{"schemaId":"a8e68904-3188-d659-ab09-56f513c6fcbf","attributes":{"rangeFrom":"21","rangeTo":"50","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6980"}},{"schemaId":"4cf56aa0-f04f-c21e-3d21-2d4df51c3d76","attributes":{"rangeFrom":"11","rangeTo":"20","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6979"}},{"schemaId":"19cea5ed-d550-b395-64e9-3fade6adf6a7","attributes":{"rangeFrom":"1","rangeTo":"10","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6978"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","description":"Business Calling_Billing_RecurringCharge_000816","endDate":"","guid":"6f3812f3-1db5-e67b-edc2-63ca7128a38d","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_816","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"ucAutoAttendants","billDescription":"Group feature - auto attendant","customRate":[{"schemaId":"56a360f8-80a7-8b6d-cf99-a92ca3e545ce","attributes":{"rangeFrom":"11","rangeTo":"20","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946"}},{"schemaId":"85683ae9-18ae-998d-01ef-9962eaed2a73","attributes":{"rangeFrom":"1","rangeTo":"10","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6947"}},{"schemaId":"cd30e9b0-f9a2-4491-a846-08af6b6a1732","attributes":{"rangeFrom":"21","rangeTo":"50","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6948"}},{"schemaId":"da2c4355-363f-921a-321b-98ae50dee49d","attributes":{"rangeFrom":"51","rangeTo":"200","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949"}},{"schemaId":"18bf7bdb-4595-79d0-fddb-2ec4dd3248f2","attributes":{"rangeFrom":"201","rangeTo":"500","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950"}},{"schemaId":"bc2e5ae6-78e7-83c0-6c11-e768ef42cdd7","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","description":"Business Calling_Billing_RecurringCharge_000810","endDate":"","guid":"22140270-069d-824d-6c23-b1f1c22d0e51","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_810","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"ucHuntGroups","billDescription":"Group feature - hunt group","customRate":[{"schemaId":"c703e5c3-7853-58a1-680e-36e8435b1b84","attributes":{"rangeFrom":"1","rangeTo":"10","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7020"}},{"schemaId":"a20997ca-fcd9-9f35-8080-09803ae395ec","attributes":{"rangeFrom":"11","rangeTo":"20","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7021"}},{"schemaId":"cb690468-273e-480d-4e2f-80f15d8f4821","attributes":{"rangeFrom":"21","rangeTo":"50","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7022"}},{"schemaId":"2359d186-2348-8983-1a28-968148659e6e","attributes":{"rangeFrom":"51","rangeTo":"200","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7023"}},{"schemaId":"3dc387d2-d48a-13fd-51c9-74fcfafc741f","attributes":{"rangeFrom":"201","rangeTo":"500","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7024"}},{"schemaId":"068a85f1-91ca-82ca-732a-3637070472fb","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7025"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","description":"Business Calling_Billing_RecurringCharge_000811","endDate":"","guid":"a529da14-23fb-d2cf-16b4-e1a2c2ae1389","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_811","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"concurrencyLimit","customRate":[{"schemaId":"ab911548-7c8b-d73b-2b3c-3aa3d17c6933","attributes":{"rangeFrom":"1","rangeTo":"10","price":"20.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6959"}},{"schemaId":"2194574d-2817-5ca3-0f54-9cfe4bd22ee2","attributes":{"rangeFrom":"21","rangeTo":"50","price":"20.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6961"}},{"schemaId":"dc16e0e0-74be-35ed-bc71-6ac31256b5fd","attributes":{"rangeFrom":"11","rangeTo":"20","price":"20.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6960"}},{"schemaId":"1eaea7ee-e599-630b-724e-736691723c79","attributes":{"rangeFrom":"51","rangeTo":"200","price":"18.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6962"}},{"schemaId":"9958da67-cb32-9bd6-0e2a-9e7d6b40e0c2","attributes":{"rangeFrom":"201","rangeTo":"500","price":"18.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6963"}},{"schemaId":"38466da7-6e61-03ae-4b9e-eeaf9b2581c8","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"17.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6964"}}],"callingPlans":"Standard","billDescription":"Standard calling plan - shared line","concurrencyLimitMode":"Shared Line"},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","description":"Business Calling_Billing_RecurringCharge_000814","endDate":"","guid":"4b695fe3-efca-37da-ce41-02d9d79aa512","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_814","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG004_CB","type":"Fixed Voice","value":"Fixed Voice Plan - Standard","billDescription":"Included PayG","ocsProdID":"T22E_FVOICE-S"},"code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","description":"Business Calling UC Plan Allowance_Billing_DMCAT_Allowance_000876","endDate":"","guid":"fd4de340-cbde-88d9-8e5d-2cc188a8bee6","includeBilling":false,"instanceId":"","metadata":{},"name":"871_AW_876","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"BSTenancyProductInstanceId":"c8031013-24a7-1009-c652-2cfcd944b3bd"},"attributes":{"__targetSystem":"FULFILMENT","BSTenancyProductInstanceId":"DMCAT_ProductSpecification_000311_Fulfilment","type":"ucServiceSiteAgnosticConcurrencyOffer","Number":[{"schemaId":"e8da8f27-adf1-16f2-8114-db8d73be4425","attributes":{"FNN":"61244547317","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}}],"concurrencyLimitMode":"explicit","CustomerFacingServiceId":"","NetworkServiceId":""},"code":"DMCAT_ProductSpecification_000871_Fulfilment","description":"Business Calling_Fulfilment","endDate":"","guid":"c0e71224-7363-88d5-6ad6-a7f73ec67db3","includeBilling":false,"instanceId":"","metadata":{},"name":"Business Calling_Fulfilment","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010002"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"56121be1-d4c7-8b8b-ae98-eb9734987364","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"133e533c-492a-6709-b2e8-388e24b111b6","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"}]}');
attprdFNN.Name = 'ServiceSpecifications.json';
attprdFNN.ParentId = prdCharFNN.Id;
attachmentList.add(attprdFNN);

Attachment attprdchrCOM= new Attachment();
attprdchrCOM.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharCOMN.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
attprdchrCOM.Name = 'ServiceSpecifications.json';
attprdchrCOM.ParentId = prdCharCOMN.Id;
attachmentList.add(attprdchrCOM);

Attachment attprdchr1= new Attachment();
attprdchr1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharServ1.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
attprdchr1.Name = 'ServiceSpecifications.json';
attprdchr1.ParentId = prdCharServ1.Id;
attachmentList.add(attprdchr1);  


Attachment attservChown= new Attachment();
attservChown.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servChown.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
attservChown.Name = 'ServiceSpecifications.json';
attservChown.ParentId = servChown.Id;
attachmentList.add(attservChown); 
insert attachmentList;
}

static testMethod void performCalloutsTest() {
CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
Account objAccount = [SELECT id FROM Account LIMIT 1];
List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
List<csord__Subscription__c> subList = [
  SELECT
    Id,
    Name,
    csordtelcoa__Subscription_Number__c,
    csord__Order__c,
    csord__Identification__c,
    triggerBill_RTB__c,
    csord__Status__c,
    MarketableOffer__r.Auto_Expired_Entity__c,
    csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
    csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csordtelcoa__Replaced_Subscription__c
  FROM csord__Subscription__c
  WHERE MarketableOffer__c != null AND csordtelcoa__Replaced_Subscription__c != NULL
];
subList[0].csord__Order__c = orderLists[0].id;
update subList;

orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, services[0].id);
orchProcess[0].csordtelcoa__Service__c = services[0].Id;
update orchProcess;

List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
insert stepList;
    List<Number__c> numberLst = new List<Number__c>();
    numberLst = [SELECT ID,Subscription_number__c From Number__c];
    for(Number__c num: numberLst){
        num.Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
    }
    update numberLst;


Test.startTest();

stepList = [
  SELECT
    ID,
    Name,
    CSPOFA__Orchestration_Process__c,
    CSPOFA__Status__c,
    CSPOFA__Completed_Date__c,
    JSON__c,
    CSPOFA__Message__c,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c
  FROM CSPOFA__Orchestration_Step__c
  WHERE Id IN :stepList
];

Integration_Handler__mdt handleSettingRecord = null;
String queryStr =
  ' SELECT ' +
  String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Integration_Handler__mdt')) +
  '\n ' +
  ' FROM Integration_Handler__mdt \n ' +
  ' WHERE DeveloperName = \'' +
  String.escapeSingleQuotes('PostSubscriptionHandler') +
  '\' LIMIT 1 ';

List<Integration_Handler__mdt> handleSettingRecordList = Database.query(queryStr);

if (handleSettingRecordList != null && !handleSettingRecordList.isEmpty() && handleSettingRecordList.get(0) != null) {
  handleSettingRecord = handleSettingRecordList.get(0);
}

BillingUtility controller = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');

    Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(404, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
Orchestration_calloutResponse resonse1 = controller.processBillingCallout(subList[0].Id, 'MLhlJPHAFdP38Z1CsAnEI1EDts6h', handleSettingRecord);

Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(500, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
Orchestration_calloutResponse resonse2 = controller.processBillingCallout(subList[0].Id, 'MLhlJPHAFdP38Z1CsAnEI1EDts6h', handleSettingRecord);

Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(202, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
    Orchestration_calloutResponse resonse = controller.processBillingCallout(subList[0].Id, 'MLhlJPHAFdP38Z1CsAnEI1EDts6h', handleSettingRecord);

System.assert(resonse != null);

Test.stopTest();
//included DIGI-32340 changes in BillingUtility apex class
}

@isTest
static void populateBillingSpecificationsTest() {
List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
List<csord__Subscription__c> subList = [
  SELECT
    Id,
    Name,
    csordtelcoa__Subscription_Number__c,
    csord__Order__c,
    csord__Identification__c,
    triggerBill_RTB__c,
    csord__Status__c,
    ModelChange__c,
    csord__Order__r.csordtelcoa__Opportunity__c,
    MarketableOffer__r.Auto_Expired_Entity__c,
    csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
    csordtelcoa__Product_Configuration__r.ConfigurationType1__c
  FROM csord__Subscription__c
  WHERE MarketableOffer__c != null
];
subList[0].csord__Order__c = orderLists[0].id;
update subList;
Test.startTest();
Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c]);

BillingUtility controller = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');

List<id> serviceIdList = new List<Id>();

serviceIdList.addAll(serviceMap.keySet());
Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controller.getAllServSpecs(serviceIdList);
Map<String, CS_SpecificationDTO.ServiceSpecification> codeSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
for (String targetSystem : srvSpecMap.keySet()) {
  for (CS_SpecificationDTO.ServiceSpecification fulfillSrvSpec : srvSpecMap.get(targetSystem)) {
    System.debug(fulfillSrvSpec.code + '===>');
    if (fulfillSrvSpec.code.contains('_Fulfilment')) {
      codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Fulfilment'), fulfillSrvSpec);
    } else if (fulfillSrvSpec.code.contains('_Billing')) {
      codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Billing'), fulfillSrvSpec);
    }
  }
}
System.debug(srvSpecMap + '===>srvSpecMap.get(BILLING)');
System.debug(codeSpecMap + '===>codeSpecMap');
BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();
billingOrderItemDataObject.scenarioType = 'Change of Mobile Number';
String serviceInstanceId = serviceMap.values()[0].Id + ':DMCAT_ProductSpecification_000263';
//controller.populateServices(srvSpecMap.get('BILLING'), codeSpecMap, billingOrderItemDataObject, serviceInstanceId, subList[0], true, serviceIdList);

controller.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000966', serviceIdList);
System.assert(billingOrderItemDataObject.billingSpecifications != null);

Test.stopTest();
}

/*@isTest
static void populateServicesTest() {
List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
List<csord__Subscription__c> subList = [
  SELECT
    Id,
    Name,
    csordtelcoa__Subscription_Number__c,
    csord__Order__c,
    csord__Identification__c,
    triggerBill_RTB__c,
    csord__Status__c,
    ModelChange__c,
    csord__Order__r.csordtelcoa__Opportunity__c,
    MarketableOffer__r.Auto_Expired_Entity__c,
    csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
    csordtelcoa__Product_Configuration__r.ConfigurationType1__c
  FROM csord__Subscription__c
  WHERE MarketableOffer__c != null
];
subList[0].csord__Order__c = orderLists[0].id;
update subList;
Test.startTest();
Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c]);

BillingUtility controller = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');

List<id> serviceIdList = new List<Id>();

serviceIdList.addAll(serviceMap.keySet());
Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controller.getAllServSpecs(serviceIdList);
Map<String, CS_SpecificationDTO.ServiceSpecification> codeSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
for (String targetSystem : srvSpecMap.keySet()) {
  for (CS_SpecificationDTO.ServiceSpecification fulfillSrvSpec : srvSpecMap.get(targetSystem)) {
    System.debug(fulfillSrvSpec.code + '===>');
    if (fulfillSrvSpec.code.contains('_Fulfilment')) {
      codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Fulfilment'), fulfillSrvSpec);
    } else if (fulfillSrvSpec.code.contains('_Billing')) {
      codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Billing'), fulfillSrvSpec);
    }
  }
}
System.debug(srvSpecMap + '===>srvSpecMap.get(BILLING)');
System.debug(codeSpecMap + '===>codeSpecMap');
BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();
billingOrderItemDataObject.scenarioType = 'Change of Mobile Number';
String serviceInstanceId = serviceMap.values()[0].Id + ':DMCAT_ProductSpecification_000263';
controller.populateServices(srvSpecMap.get('BILLING'), codeSpecMap, billingOrderItemDataObject, serviceInstanceId, subList[0], true, serviceIdList);

//controller.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000313', serviceIdList);
System.assert(billingOrderItemDataObject.productCharacteristics.size() > 0);

Test.stopTest();
}*/

@isTest
static void populatePriceAlterationPSLITest() {
List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
List<csord__Subscription__c> subList = [
  SELECT
    Id,
    Name,
    csordtelcoa__Subscription_Number__c,
    csord__Order__c,
    csord__Identification__c,
    triggerBill_RTB__c,
    csord__Status__c,
    ModelChange__c,
    isAggregationPoint__c,
    MarketableOffer__r.Offer_ID__c,
    csord__Order__r.csordtelcoa__Opportunity__c,
    MarketableOffer__r.Auto_Expired_Entity__c,
    MarketableOffer__r.Invoice_Definition__c,
    csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
    csord__Order__r.csord__Primary_Order__r.Billing_Account__c,autoExpiry__c,expiryDuration__c,
    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Action_Type__c
  FROM csord__Subscription__c
  WHERE MarketableOffer__c != null
];
subList[0].csord__Order__c = orderLists[0].id;
update subList;
Test.startTest();
Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c]);

BillingUtility controller = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');

List<id> serviceIdList = new List<Id>();

serviceIdList.addAll(serviceMap.keySet());
Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controller.getAllServSpecs(serviceIdList);
Map<String, CS_SpecificationDTO.ServiceSpecification> codeSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
for (String targetSystem : srvSpecMap.keySet()) {
  for (CS_SpecificationDTO.ServiceSpecification fulfillSrvSpec : srvSpecMap.get(targetSystem)) {
    System.debug(fulfillSrvSpec.code + '===>');
    if (fulfillSrvSpec.code.contains('_Fulfilment')) {
      codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Fulfilment'), fulfillSrvSpec);
    } else if (fulfillSrvSpec.code.contains('_Billing')) {
      codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Billing'), fulfillSrvSpec);
    }
  }
}
System.debug(srvSpecMap + '===>srvSpecMap.get(BILLING)');
System.debug(codeSpecMap + '===>codeSpecMap');
BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();
billingOrderItemDataObject.scenarioType = 'Change of Mobile Number';
String serviceInstanceId = serviceMap.values()[0].Id + ':DMCAT_ProductSpecification_000263';
Map<Id, Map<String, List<Price_Schedule_Line_Item__c>>> serviceIdToListPriceSchedule = controller.getpriceScheduleRecordbyServId(new List<Id>{ subList[0].Id });

Price_Schedule_Line_Item__c priceScheduleLI = [SELECT Id FROM Price_Schedule_Line_Item__c LIMIT 1];

controller.getTLIbyPSLIId(priceScheduleLI.Id);
controller.populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(serviceIdList[0]), 'DMCAT_ProductSpecification_000263');
//controller.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000313', serviceIdList);
BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();

controller.populateProductOffering(subList[0], billingSpecDTOV2, 'test', 'add', serviceIdList);

System.assert(billingSpecDTOV2.ProductOffering != null);

Test.stopTest();
}

@isTest
static void populateServicesTest() { //added as part of EDGE-165967
    List<Id> subscriptionIdList = new List<Id>();
    csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='TestPrdChar' and csord__Identification__c='TestPrdChar'];
    system.debug('sub434'+sub);
    subscriptionIdList.add(sub.id);
    BillingUtility BU = new BillingUtility(subscriptionIdList,true, false, 'PostSubscriptionHandler');
    String payload = BU.buildBillPayload(sub.id, null, null);
    system.debug('requestBody439'+payload);  
    BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
    system.debug('billSpecDTO441'+billSpecDTO.orderItems[0].productCharacteristics);  
    for(BillingSpecDTOV2.orderItems orderitem : billSpecDTO.orderItems)
    {
        if(orderitem.productCharacteristics !=null){
            for(BillingSpecDTOV2.productCharacteristics prdChar : orderitem.productCharacteristics)
            { 
                system.assertNotEquals(0, prdChar.characteristics.size()); // negative scenario
                for(BillingSpecDTOV2.Characteristics charVal : prdChar.characteristics)
                {
                    if(charVal.name == 'IMSI')
                    {
                        system.assertEquals('5286475123', charVal.value);
                      }
                    
                    if(charVal.name == 'MSISDN')
                    {
                        system.assertEquals('61474663325', charVal.value);
                    }
                }
            }
        }
    }
}
    @isTest
        private static void populateBillingSpecificationsMsTmdmAcTest(){
            /*Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
            disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
            disabledTriggersProfile.Trigger_Name_List1__c = 'SubscriptionCustomTriggerHandler';
            insert disabledTriggersProfile;*/
             SYS_TriggerHandler.bypass('C2O_SubscriptionHandler'); // add new bypass logic
            Test.startTest();
            List<Account> accountForRateCardList = Orchestration_TestUtility.buildAccount(false, 2);
            insert accountForRateCardList;
            
            List<Opportunity> OpportunityRateCardList = Orchestration_TestUtility.buildOpp(false, 1, accountForRateCardList);
            insert OpportunityRateCardList;
            
            List<Billing_Account__c> billingAccountList = new List<Billing_Account__c>();
            Billing_Account__c ba = TestDataFactory.generateBillingAccount('123123122235',null,accountForRateCardList[0].Id,null);
            billingAccountList.add(ba);
    
            insert billingAccountList;
    
    
            cscfga__Product_Basket__c pbMsTmdm = new cscfga__Product_Basket__c(Name = 'test', cscfga__Opportunity__c = OpportunityRateCardList[0].Id);
            insert pbMsTmdm;
    
            List<cscfga__Product_Definition__c> productDefList = new List<cscfga__Product_Definition__c>();
            cscfga__Product_Definition__c productDefUS = new cscfga__Product_Definition__c(
                Name = 'User Support', // Name
                csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                cscfga__Description__c = 'User Support', // Description
                cscfga__Label__c = 'User Support', // Label
                product_Specification__c = 'DMCAT_ProductSpecification_000940' // product Specification
                
            );
            productDefList.add(productDefUS);
            cscfga__Product_Definition__c productDefPF = new cscfga__Product_Definition__c(
                Name = 'Platform', // Name
                csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                cscfga__Description__c = 'Platform', // Description
                cscfga__Label__c = 'Platform', // Label
                product_Specification__c = 'DMCAT_ProductSpecification_000537' // product Specification
                
            );
            productDefList.add(productDefPF);
            cscfga__Product_Definition__c productDefAC = new cscfga__Product_Definition__c(
                Name = 'Next Gen Mobility Adaptive Care', // Name
                csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                cscfga__Description__c = 'Next Gen Mobility Adaptive Care', // Description
                cscfga__Label__c = 'Next Gen Mobility Adaptive Care', // Label
                product_Specification__c = 'DMCAT_Offer_001251' // product Specification
                
            );
            productDefList.add(productDefAC);
            insert productDefList;
            
            List<csord__Order_Request__c> orderReqRateCardList = Orchestration_TestUtility.buildOrderRequest(true, 1);
            List<csord__Order__c> orderRateCardList = Orchestration_TestUtility.buildOrder('order1', accountForRateCardList[0].id, 'Complete', orderReqRateCardList[0].id, false, 2);
            orderRateCardList[0].Billing_Account__c = ba.Id;
    
            insert orderRateCardList;
    
            list<cscfga__Product_Configuration__c> productconfigList = new list<cscfga__Product_Configuration__c>();
            productconfigList = Orchestration_TestUtility.buildProductConfiguration(true, 3);
            productconfigList[0].ConfigurationType1__c = '';
            productconfigList[0].cscfga__Product_Definition__c = productDefList[0].Id;
            productconfigList[0].cscfga__Product_Basket__c = pbMsTmdm.Id;
            productconfigList[1].ConfigurationType1__c = '';
            productconfigList[1].cscfga__Product_Definition__c = productDefList[1].Id;
            productconfigList[1].cscfga__Product_Basket__c = pbMsTmdm.Id;
            productconfigList[2].ConfigurationType1__c = 'SolutionComponent';
            productconfigList[2].cscfga__Product_Definition__c = productDefList[2].Id;
            productconfigList[2].cscfga__Product_Basket__c = pbMsTmdm.Id;
    
            update productconfigList;
    
    
            list<csord__Solution__c> solutionRateCardList = Orchestration_TestUtility.buildSolution(false, 1);
            solutionRateCardList[0].Name = 'TestSubsforTestMSTMDMADP';
            insert solutionRateCardList;
            
            List<Marketable_Offer__c> marketableRateCardList = Orchestration_TestUtility.buildMarkertableOffer(false, 3);
            marketableRateCardList[0].Auto_Expired_Entity__c = true;
            marketableRateCardList[0].Offer_ID__c = 'DMCAT_Offer_000854';
            marketableRateCardList[0].Invoice_Definition__c = 'Invoice_Def_1';
            marketableRateCardList[1].Auto_Expired_Entity__c = true;
            marketableRateCardList[1].Offer_ID__c = 'DMCAT_Offer_000681';
            marketableRateCardList[1].Invoice_Definition__c = 'Invoice_Def_1';
            marketableRateCardList[2].Auto_Expired_Entity__c = true;
            marketableRateCardList[2].Offer_ID__c = 'DMCAT_Offer_001251';
            marketableRateCardList[2].Invoice_Definition__c = 'Invoice_Def_1';
            insert marketableRateCardList;
            
            
                List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
                csord__Subscription__c testSubscription = new csord__Subscription__c();
                testSubscription.MarketableOffer__c = marketableRateCardList[0].id;
                testSubscription.Name = 'TestSubsforTestUS';
                testSubscription.csord__Account__c = accountForRateCardList[1].id;
                testSubscription.csord__Identification__c = 'test';
                testSubscription.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
                testSubscription.csord__Order__c = orderRateCardList[0].id; // used in Orchestration_EvaluateOrderStatusTest
                testSubscription.csordtelcoa__Product_Configuration__c = productconfigList[0].id;   
                testSubscription.triggerBill_RTB__c = false;
                testSubscription.Billing_Account__c = billingAccountList[0].Id;
                testSubscription.cssdm__solution_association__c = solutionRateCardList[0].id;
                testSubscription.isAggregationPoint__c = true;
                testSubscription.oldServiceMSISDN__c = 'Testing';
                testSubscription.autoExpiry__c = true;
                testSubscription.TenancyID__c = 'T1002';
                subList.add(testSubscription);
    
                csord__Subscription__c testSubscriptionPF = new csord__Subscription__c();
                testSubscriptionPF.MarketableOffer__c = marketableRateCardList[1].id;
                testSubscriptionPF.Name = 'TestSubsforTestPF';
                testSubscriptionPF.csord__Account__c = accountForRateCardList[1].id;
                testSubscriptionPF.csord__Identification__c = 'test';
                testSubscriptionPF.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
                testSubscriptionPF.csord__Order__c = orderRateCardList[0].id; // used in Orchestration_EvaluateOrderStatusTest
                testSubscriptionPF.csordtelcoa__Product_Configuration__c = productconfigList[1].id;  
                testSubscriptionPF.triggerBill_RTB__c = false;
                testSubscriptionPF.Billing_Account__c = billingAccountList[0].Id;
                testSubscriptionPF.cssdm__solution_association__c = solutionRateCardList[0].id;
                testSubscriptionPF.isAggregationPoint__c = true;
                testSubscriptionPF.oldServiceMSISDN__c = 'Testing';
                testSubscriptionPF.autoExpiry__c = true;
                testSubscriptionPF.TenancyID__c = 'T1003';
                subList.add(testSubscriptionPF);
    
                csord__Subscription__c testSubscriptionAC = new csord__Subscription__c();
                testSubscriptionAC.MarketableOffer__c = marketableRateCardList[2].id;
                testSubscriptionAC.Name = 'TestSubsforTestAC';
                testSubscriptionAC.csord__Account__c = accountForRateCardList[1].id;
                testSubscriptionAC.csord__Identification__c = 'test';
                testSubscriptionAC.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
                testSubscriptionAC.csord__Order__c = orderRateCardList[0].id; // used in Orchestration_EvaluateOrderStatusTest
                testSubscriptionAC.csordtelcoa__Product_Configuration__c = productconfigList[2].id;  
                testSubscriptionAC.triggerBill_RTB__c = false;
                testSubscriptionAC.Billing_Account__c = billingAccountList[0].Id;
                testSubscriptionAC.cssdm__solution_association__c = solutionRateCardList[0].id;
                testSubscriptionAC.isAggregationPoint__c = true;
                testSubscriptionAC.oldServiceMSISDN__c = 'Testing';
                testSubscriptionAC.autoExpiry__c = true;
                testSubscriptionAC.TenancyID__c = 'T1004';
                subList.add(testSubscriptionAC);
    
                insert subList;


            List<csord__Service__c> servRateCardlist = Orchestration_TestUtility.buildService(false, 3, subList[0].id, orderReqRateCardList[0].id, orderRateCardList[0].id, productconfigList[0].id);
            servRateCardlist[0].csord__Status__c = 'created';
            servRateCardlist[0].csordtelcoa__Product_Configuration__c = productconfigList[0].id;
            servRateCardlist[0].Scenario_Type__c = 'User Support Scenario';
            servRateCardlist[0].csord__Subscription__c = subList[0].id;
            servRateCardlist[1].csord__Status__c = 'created';
            servRateCardlist[1].csordtelcoa__Product_Configuration__c = productconfigList[1].id;
            servRateCardlist[1].Scenario_Type__c = 'Platform';
            servRateCardlist[1].csord__Subscription__c = subList[1].id;
            servRateCardlist[2].csord__Status__c = 'created';
            servRateCardlist[2].csordtelcoa__Product_Configuration__c = productconfigList[2].id;
            servRateCardlist[2].Scenario_Type__c = 'Next Gen Mobility Adaptive Care';
            servRateCardlist[2].csord__Subscription__c = subList[2].id;
            insert servRateCardlist;
            
    
            List<cspmb__Price_Item__c> priceItemList = new List<cspmb__Price_Item__c>();
    
            cspmb__Price_Item__c price_item_user_support = new cspmb__Price_Item__c(
                Name = 'User Support',
                cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
                cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
                cspmb__Is_Active__c = true,
                cspmb__Price_Item_Code__c = 'User Support',
                cspmb__Product_Definition_Name__c = 'User Support',
                External_Id__c = 'DMCAT_Offer_000854_DMCAT_ProductSpecification_000940_DMCAT_RecurringCharge_000852_6411',
                Charge_Id__c='DMCAT_RecurringCharge_000852',
                BillingSpecId__c = 'BSUSG003_CB',
                Billing_Description__c = 'User support - Standard - business hours',
                Offer_Id__c = 'DMCAT_Offer_000854',
                cspmb__Role__c = 'Basic',
                cspmb__Type__c = 'Commercial Product'
            );
            priceItemList.add(price_item_user_support);
            
            cspmb__Price_Item__c price_item_platform = new cspmb__Price_Item__c(
                Name = 'Platform',
                cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
                cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
                cspmb__Is_Active__c = true,
                cspmb__Price_Item_Code__c = 'Platform',
                cspmb__Product_Definition_Name__c = 'Platform',
                External_Id__c = 'DMCAT_Offer_000681_DMCAT_ProductSpecification_000537_DMCAT_RecurringCharge_000699_7892',
                Charge_Id__c='DMCAT_RecurringCharge_000699',
                BillingSpecId__c = 'BSUSG005_CB',
                Billing_Description__c = 'Licence fee',
                Offer_Id__c = 'DMCAT_Offer_000681',
                cspmb__Role__c = 'Basic',
                cspmb__Type__c = 'Commercial Product'
            );
    
            priceItemList.add(price_item_platform);
            
            cspmb__Price_Item__c price_item_user_ADP = new cspmb__Price_Item__c(
                Name = 'Adaptive Mobility Care',
                cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
                cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
                cspmb__Is_Active__c = true,
                cspmb__Price_Item_Code__c = 'Adaptive Mobility Care',
                cspmb__Product_Definition_Name__c = 'Adaptive Mobility Care',
                External_Id__c = 'DMCAT_Offer_001251_DMCAT_ProductSpecification_001252_DMCAT_RecurringCharge_001268_7889',
                Charge_Id__c='DMCAT_RecurringCharge_001268',
                BillingSpecId__c = 'BSUSG005_CB',
                Billing_Description__c = 'Support fee',
                Offer_Id__c = 'DMCAT_Offer_001251',
                Type__c = 'NEW',
                cspmb__Role__c = 'Basic',
                cspmb__Type__c = 'Commercial Product'

            );
            priceItemList.add(price_item_user_ADP);
            insert priceItemList;
    
            List<cspmb__Rate_Card__c> rateCardList = new List<cspmb__Rate_Card__c>();
            cspmb__Rate_Card__c rateCard_user_data = new cspmb__Rate_Card__c(
                Name = 'User Support - Standard - Bus Hrs',
                Offer_Id__c ='DMCAT_Offer_000854',
                cspmb__Rate_Card_Code__c = '7900',  
                cspmb__Effective_End_Date__c = Date.today()+1,
                cspmb__Effective_Start_Date__c = Date.today()-1,
                cspmb__Is_Active__c = true);
            rateCardList.add(rateCard_user_data); 
            
            cspmb__Rate_Card__c rateCard_PF_data = new cspmb__Rate_Card__c(
                Name = 'Platform Rate Card',
                Offer_Id__c ='DMCAT_Offer_000681',
                cspmb__Rate_Card_Code__c = '7982',  
                cspmb__Effective_End_Date__c = Date.today()+1,
                cspmb__Effective_Start_Date__c = Date.today()-1,
                cspmb__Is_Active__c = true);
            rateCardList.add(rateCard_PF_data);
            
            cspmb__Rate_Card__c rateCard_AC_data = new cspmb__Rate_Card__c(
                Name = 'Adacptive Care Rate Card',
                Offer_Id__c ='DMCAT_Offer_001251',
                cspmb__Rate_Card_Code__c = '7999', 
                cspmb__Effective_End_Date__c = Date.today()+1,
                cspmb__Effective_Start_Date__c = Date.today()-1,
                cspmb__Is_Active__c = true);
            rateCardList.add(rateCard_AC_data);
            
            Insert rateCardList;
            
            List<cspmb__Price_Item_Rate_Card_Association__c> rateCardAssociationList = new List<cspmb__Price_Item_Rate_Card_Association__c>();
            cspmb__Price_Item_Rate_Card_Association__c userDataAssociation = new cspmb__Price_Item_Rate_Card_Association__c();
            userDataAssociation.cspmb__Price_Item__c = priceItemList[0].id;
            userDataAssociation.cspmb__Rate_Card__c = rateCardList[0].id;
            rateCardAssociationList.add(userDataAssociation);
            
            cspmb__Price_Item_Rate_Card_Association__c platformDataAssociation = new cspmb__Price_Item_Rate_Card_Association__c();
            platformDataAssociation.cspmb__Price_Item__c = priceItemList[1].id;
            platformDataAssociation.cspmb__Rate_Card__c = rateCardList[1].id;
            rateCardAssociationList.add(platformDataAssociation);
            
            cspmb__Price_Item_Rate_Card_Association__c adaptiveDataAssociation = new cspmb__Price_Item_Rate_Card_Association__c();
            adaptiveDataAssociation.cspmb__Price_Item__c = priceItemList[2].id;
            adaptiveDataAssociation.cspmb__Rate_Card__c = rateCardList[2].id;
            rateCardAssociationList.add(adaptiveDataAssociation);
            
            insert rateCardAssociationList;
            
            List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
            
            cspmb__Rate_Card_Line__c rcl1 =PricingTestDataFactory.generateRateCardLine(1,499,rateCardList[0].id,'1');
            rcl1.cspmb__rate_value__c = 1.5;
            rateCardLineList.add(rcl1);
            
            cspmb__Rate_Card_Line__c rcl2 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[0].id,'1');
            rcl2.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rcl2);
            
            cspmb__Rate_Card_Line__c rcl3 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCardList[0].id,'1');
            rcl3.cspmb__rate_value__c = 3.5;
            rateCardLineList.add(rcl3);
    
            cspmb__Rate_Card_Line__c rcl4 =PricingTestDataFactory.generateRateCardLine(499,1,rateCardList[0].id,'10');
            rcl4.cspmb__rate_value__c = 1.5;
            rateCardLineList.add(rcl4);
            
            cspmb__Rate_Card_Line__c rcl5 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[0].id,'10');
            rcl5.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rcl5);
    
            cspmb__Rate_Card_Line__c rcl6 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCardList[0].id,'10');
            rcl6.cspmb__rate_value__c = 3.5;
            rateCardLineList.add(rcl6);
    
    
            cspmb__Rate_Card_Line__c rcl7 =PricingTestDataFactory.generateRateCardLine(1,499,rateCardList[1].id,'1');
            rcl7.cspmb__rate_value__c = 1.5;
            rateCardLineList.add(rcl7);
            
            cspmb__Rate_Card_Line__c rcl8 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[1].id,'1');
            rcl8.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rcl8);
            
            cspmb__Rate_Card_Line__c rcl9 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCardList[1].id,'1');
            rcl9.cspmb__rate_value__c = 3.5;
            rateCardLineList.add(rcl9);
    
            cspmb__Rate_Card_Line__c rcl10 =PricingTestDataFactory.generateRateCardLine(499,1,rateCardList[1].id,'10');
            rcl10.cspmb__rate_value__c = 1.5;
            rateCardLineList.add(rcl10);
            
            cspmb__Rate_Card_Line__c rc11 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[1].id,'10');
            rc11.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rc11);
    
            cspmb__Rate_Card_Line__c rcl12 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCardList[1].id,'10');
            rcl12.cspmb__rate_value__c = 3.5;
            rateCardLineList.add(rcl12);
    
    
            cspmb__Rate_Card_Line__c rcl13 =PricingTestDataFactory.generateRateCardLine(1,499,rateCardList[2].id,'1');
            rcl13.cspmb__rate_value__c = 1.5;
            rateCardLineList.add(rcl13);
            
            cspmb__Rate_Card_Line__c rcl14 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[2].id,'1');
            rcl14.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rcl14);
            
            cspmb__Rate_Card_Line__c rcl15 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCardList[2].id,'1');
            rcl15.cspmb__rate_value__c = 3.5;
            rateCardLineList.add(rcl15);
    
            cspmb__Rate_Card_Line__c rcl16 =PricingTestDataFactory.generateRateCardLine(499,1,rateCardList[2].id,'10');
            rcl16.cspmb__rate_value__c = 1.5;
            rateCardLineList.add(rcl16);
            
            cspmb__Rate_Card_Line__c rc17 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[2].id,'10');
            rc17.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rc17);
    
            cspmb__Rate_Card_Line__c rc18 =PricingTestDataFactory.generateRateCardLine(999,500,rateCardList[2].id,'10');
            rc18.cspmb__rate_value__c = 2.5;
            rateCardLineList.add(rc18);
    
    
            insert rateCardLineList;
    
            List<Attachment> attachmentRateCardList = Orchestration_TestUtility.buildAttachment(false, 3, servRateCardlist, productconfigList[0].id);
            attachmentRateCardList[0].Body = Blob.valueOf('{"specifications" : [{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000940","productConfigurationId" : "'+productconfigList[0].id+'","name" : "User Support_SOMOpenAir","metadata" : { },"instanceId" : "","includeBilling" : false,"guid" : "42d888dc-2de4-889a-3717-e002d5731cc1","endDate" : "","description" : "User Support_SOMOpenAir","code" : "DMCAT_ProductSpecification_000853","attributes" : {"TechnicalSupport" : "Bus Hrs","FeatureLevel" : "Standard","TenancyID" : "","__targetSystem" : "SOMOpenAir"},"additionalAttributes" : { }},' +
                                                +'{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000940DMCAT_ProductSpecification_000940_Billing_RecurringCharge_000852","productConfigurationId" : "'+productconfigList[0].id+'","name" : "940_RC_852","metadata" : { },"instanceId" : "","includeBilling" : false,"guid" : "960b4eca-13a1-57f8-9fe3-41de85b60219", "endDate" : "","description" : "User Support_Billing_RecurringCharge_000852","code" : "DMCAT_ProductSpecification_000940_Billing_RecurringCharge_000852","attributes" : {"commercialProductId" : "'+priceItemList[0].id+'","chargeId" : "DMCAT_RecurringCharge_000852","currency" : "AUD","ContractTerm" : "24","contractType":"Hardware Repayment","isRedeemable":"false","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946","taxTreatment" : "GST Applicable","externalId":"TestExternalId","billDescription" : "User support - Standard - business hours","billingSpecId" : "BSUSG003_CB","TechnicalSupport" : "Bus Hrs","FeatureLevel" : "Standard","customRate" : [ ], "__targetSystem" : "BILLING"},"additionalAttributes" : { }} ],'+
                                                +'"serviceId" : "'+servRateCardlist[0].id+'","legacyAttributes" : [ ]}');
            
            attachmentRateCardList[1].Body =  Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537DMCAT_ProductSpecification_000537_Billing_RecurringCharge_000699","productConfigurationId":"'+productconfigList[1].id+'","name":"537_RC_699","metadata":{},"instanceId":"","includeBilling":false,"guid":"e8d77b7e-3e80-549b-85e9-b57b3484d9e8",'+
                                                +'"endDate":"","description":"Platform_Billing_RecurringCharge_000699","code":"DMCAT_ProductSpecification_000537_Billing_RecurringCharge_000699","attributes":{"discountUnit":"DAYS","discountDuration":"30","billDescription":"Licence fee","externalId":"","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},'+
                                                +'"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537DMCAT_ProductSpecification_000151","productConfigurationId":"'+productconfigList[1].id+'","name":"Platform_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"ae57d48d-52b7-4c77-4cd3-f8a320b2200c","endDate":"","description":"Platform_Fulfilment",'+
                                                +'"code":"DMCAT_ProductSpecification_000537_Fulfilment","attributes":{"Vendor":"VMware-MDM","TenancyID":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537DMCAT_ProductSpecification_000326","productConfigurationId":"'+productconfigList[0].id+'","name":"326_ASR","metadata":{},"instanceId":"",'+
                                                +'"includeBilling":false,"guid":"649f9d9e-7f1b-db40-945c-71ff9472e453","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537DMCAT_ProductSpecification_000151",'+
                                                +'"productConfigurationId":"'+productconfigList[1].id+'","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"d0933a73-fa47-9dbb-bffd-cc9de83822f9","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010006","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}}],"serviceId":"'+servRateCardlist[1].id+'","legacyAttributes":[]}');
            
            attachmentRateCardList[2].Body =  Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"b3e23bb6-264c-c283-b320-3f2567e92ed5","productConfigurationId":"'+productconfigList[2].id+'","name":"1251_RC_1268","metadata":{},"instanceId":"","includeBilling":false,"guid":"6a3d7d8d-5bd6-cfde-1f69-9d98071b561b","endDate":"","description":"NGAC_Billing_RecurringCharge_0001268",'+
                                                + '"code":"DMCAT_ProductSpecification_0001251_Billing_RecurringCharge_0001268","attributes":{"taxTreatment":"GST Applicable","billDescription":"Adaptive Care Charge","externalId":"","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","type":"NEW","currency":"AUD","id":"'+priceItemList[0].id+'","quantity":"1","description":"NGACRC","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRateCardlist[2].id+'","legacyAttributes":[]}');
            
    
            insert attachmentRateCardList;

            Test.stopTest();
            
            //User Support Scenario
            BillingUtility controllerManagedService = new BillingUtility(new List<Id>{ subList[0].Id }, true, false, 'PostSubscriptionHandler');
    
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c WHERE Scenario_Type__c = 'User Support Scenario']);
            List<Id> serviceList = new List<Id>();
            serviceList.addAll(serviceMap.keySet());
            Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = controllerManagedService.getAllServSpecs(serviceList);
            BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();

            if(!srvSpecMap.ContainsKey('BILLING')) {
            	controllerManagedService.populateBillingSpecifications(srvSpecMap.get('BILLING'), billingOrderItemDataObject, 'DMCAT_ProductSpecification_000940', serviceList);
            	System.assert(!controllerManagedService.commercialProductIdRateCardCodeMap.isEmpty());
            }
            
            //Platform Scenario
            BillingUtility controllerPlatform = new BillingUtility(new List<Id>{ subList[1].Id }, true, false, 'PostSubscriptionHandler');
    
            Map<Id, csord__Service__c> serviceMap2 = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c WHERE Scenario_Type__c = 'Platform']);
            List<Id> serviceList2 = new List<Id>();
            serviceList2.addAll(serviceMap2.keySet());
            Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap2 = controllerPlatform.getAllServSpecs(serviceList2);
            BillingSpecDTOV2.OrderItems billingOrderItemDataObject2 = new BillingSpecDTOV2.OrderItems();
    
            controllerPlatform.populateBillingSpecifications(srvSpecMap2.get('BILLING'), billingOrderItemDataObject2, 'DMCAT_ProductSpecification_000537', serviceList2);
            System.assert(!controllerPlatform.rateCardToRateCardLineItemMap.isEmpty());
            
            /*
            //Next GEN Adaptive Care Scenario
            BillingUtility controllerAdaptiveCare = new BillingUtility(new List<Id>{ subList[2].Id }, true, false, 'PostSubscriptionHandler');
    
            Map<Id, csord__Service__c> serviceMap3 = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c WHERE Scenario_Type__c = 'Platform']);
            List<Id> serviceList3 = new List<Id>();
            serviceList3.addAll(serviceMap3.keySet());
            Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap3 = controllerAdaptiveCare.getAllServSpecs(serviceList3);
            BillingSpecDTOV2.OrderItems billingOrderItemDataObject3 = new BillingSpecDTOV2.OrderItems(); 
    
            controllerAdaptiveCare.populateBillingSpecifications(srvSpecMap3.get('BILLING'), billingOrderItemDataObject3, 'DMCAT_ProductSpecification_001252', serviceList3);
            System.assert(!controllerAdaptiveCare.rateCardToRateCardLineItemMap.isEmpty());
            */
            
        }
@isTest
static void populateServicesChangeOfNumberTest() { //added as part of EDGE-165967
    List<Id> subscriptionIdList = new List<Id>();
    csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='TestChangeOfNum' and csord__Identification__c='TestChangeOfNum'];
    system.debug('sub498'+sub);
    subscriptionIdList.add(sub.id);
    BillingUtility BU = new BillingUtility(subscriptionIdList,true, false, 'PostSubscriptionHandler');
    String payload = BU.buildBillPayload(sub.id,null, null);
    system.debug('requestBody439'+payload);  
    BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
    system.debug('billSpecDTO441'+billSpecDTO.orderItems[0].productCharacteristics);  
    for(BillingSpecDTOV2.orderItems orderitem : billSpecDTO.orderItems)
    {
        system.debug('orderitem508'+orderitem);
        if(orderitem.productCharacteristics !=null){
            for(BillingSpecDTOV2.productCharacteristics prdChar : orderitem.productCharacteristics)
            {
                for(BillingSpecDTOV2.Characteristics charVal : prdChar.characteristics)
                {
                    if(charVal.name == 'IMSI')
                    {
                        system.assertEquals('5286475123', charVal.value);
                      }
                    
                    if(charVal.name == 'MSISDN')
                    {
                        system.assertEquals('61474663325', charVal.value);
                    }
                    
                    if(charVal.name == 'oldServiceId')
                    {
                        system.assertEquals('61244547316', charVal.value);
                    }
                }
                }
            }
        }
  }
    

  @isTest
  static void populateServicesFNNTest() { //added as part of EDGE-165967
      List<Id> subscriptionIdList = new List<Id>();
      csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='TestPrdCharFNN' and csord__Identification__c='TestPrdCharFNN'];
      system.debug('sub498'+sub);
      subscriptionIdList.add(sub.id);
      BillingUtility BU = new BillingUtility(subscriptionIdList,true, false, 'PostSubscriptionHandler');
      String payload = BU.buildBillPayload(sub.id,null,null);
      system.debug('requestBody439'+payload);  
      BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
      system.debug('billSpecDTO441'+billSpecDTO.orderItems[0].productCharacteristics);  
      for(BillingSpecDTOV2.orderItems orderitem : billSpecDTO.orderItems)
      {
          system.debug('orderitem508'+orderitem);
          if(orderitem.productCharacteristics !=null){
              for(BillingSpecDTOV2.productCharacteristics prdChar : orderitem.productCharacteristics)
              {
                  for(BillingSpecDTOV2.Characteristics charVal : prdChar.characteristics)
                  {
                      if(charVal.name == 'FNN')
                      {
                          system.assertEquals('61244547317', charVal.value);
                      }
                  }
              }
          }
      }
      
  }
                                  
    
  @isTest
  static void TestRFA() { 
      List<Id> subscriptionIdList = new List<Id>();
      csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='TestRFA' and csord__Identification__c='TestRFA'];
      system.debug('sub498'+sub);
      subscriptionIdList.add(sub.id);
      BillingUtility BU = new BillingUtility(subscriptionIdList,true, false, 'PostSubscriptionHandler');
      String payload = BU.buildBillPayload(sub.id,null,null);
      system.debug('requestBody439'+payload);  
      BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
      system.assertEquals('RFA', billSpecDTO.requestType);
          
      
  } 
   @isTest
  static void TestChown() { 
  
      List<Id> subscriptionIdList = new List<Id>();
      csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='subChown' and csord__Identification__c='subChown'];
      system.debug('sub498'+sub);
      subscriptionIdList.add(sub.id);
      BillingUtility BU = new BillingUtility(subscriptionIdList,true, false, 'PostSubscriptionHandler');
      String payload = BU.buildBillPayload(sub.id,null,null);
      system.debug('requestBody439'+payload);  
      BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
      system.assertEquals('CHOWN', billSpecDTO.orderItems[0].scenarioType);
    
      
  }
  @isTest
  static void TestDMS() {        
      List<Id> subscriptionIdList = new List<Id>();
      csord__Subscription__c sub=[select id,customerFacingServiceId__c,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='subChown' and csord__Identification__c='subChown'];
      sub.customerFacingServiceId__c = '12345';
      update sub;
      subscriptionIdList.add(sub.id);
      BillingUtility BU = new BillingUtility(subscriptionIdList,true, false, 'PostSubscriptionHandler');
      String payload = BU.buildBillPayload(sub.id,null,null);
      BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
      system.assert(String.isNotBlank(payload));
 } 
}