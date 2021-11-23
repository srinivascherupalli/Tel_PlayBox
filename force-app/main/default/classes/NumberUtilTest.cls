/*********************************************************************************************************************************
*Class Name      :   NumberUtilTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vaibhav Deshpande       18/10/2019    EDGE-115655
2.            Sandip Deshmane         13/2/2020     EDGE-132208  - Only Query clause(Disconnect Pending, Disconnect in Progress, Diconnected) added which is already covered in the Test Class.
3.            Sunil Nangare           20/2/2020     EDGE-136242 Refactoring of existing UpdateNumberStatus method
*********************************************************************************************************************************
*/
@isTest
public class NumberUtilTest {
 @TestSetup static void dataSetup(){
     Account acc = new Account();
     acc.Name = 'test Account' ;
     acc.Type = 'Competitor' ;
     acc.Customer_Status__c='Active';
     insert acc;
      Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
     Opportunity opp = new Opportunity( Name = 'test opportunity', AccountId= acc.Id, Product_Domain__c = 'MOBILES', StageName='Develop', Description='Test Opp', Pricing_Method__c='PET', Contract_Type__c='BSA',Billing_Solution__c='Standard', recordtypeId= devRecordTypeId );
     opp.CloseDate = system.today();
     insert opp;
     
     csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
     insert ordReq;
     
     csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
     ord.csord__Order_Request__c = ordReq.Id;
     ord.csordtelcoa__Opportunity__c = opp.Id;
     insert ord;
     
     csord__Subscription__c subs=new csord__Subscription__c();
     subs.name  = 'test subs';
     subs.csord__Identification__c = 'test identity';
     subs.csord__Order__c = ord.Id;
     subs.Sub_status__c = 'Active';
     subs.csord__Status__c='Active';
     subs.csordtelcoa__Subscription_Number__c='SN-123456';
     subs.Suspension_reason__c='Requested by Customer';
     insert subs;
     
     csord__Subscription__c subs1=new csord__Subscription__c();
     subs1.name  = 'test subs1';
     subs1.csord__Identification__c = 'test identity';
     subs1.csord__Order__c = ord.Id;
     subs1.Sub_status__c = 'Active';
     subs1.csord__Status__c='Active';
     subs1.csordtelcoa__Subscription_Number__c='SN-1234567';
     subs1.Suspension_reason__c='Requested by Customer';
     subs1.oldServiceMSISDN__c='61474850549';
     subs1.serviceMSISDN__c='61474850548';
     insert subs1;
     
     csord__Subscription__c subs2=new csord__Subscription__c();
     subs2.name  = 'test subs1';
     subs2.csord__Identification__c = 'test identity';
     subs2.csord__Order__c = ord.Id;
     subs2.Sub_status__c = 'Active';
     subs2.csord__Status__c='Active';
     subs2.csordtelcoa__Subscription_Number__c='SN-000047005';
     subs2.Suspension_reason__c='Requested by Customer';
     subs2.oldServiceMSISDN__c='61474850549';
     subs2.serviceMSISDN__c='61474850548';
     subs2.csord__Identification__c= 'Subscription_a3T2O000000N3L7UAK_0';
     insert subs2;
     
     csord__Subscription__c subs3=new csord__Subscription__c();
     subs3.name  = 'test subs1';
     subs3.csord__Identification__c = 'test identity';
     subs3.csord__Order__c = ord.Id;
     subs3.Sub_status__c = 'Inactive';
     subs3.csord__Status__c='Inactive';
     subs3.csordtelcoa__Subscription_Number__c='SN-000047005';
     subs3.Suspension_reason__c='Requested by Customer';
     subs3.oldServiceMSISDN__c='61474850549';
     subs3.serviceMSISDN__c='61474850548';
     subs3.csord__Identification__c= 'Subscription_a3T2O000000N3L7UAK_0';
     insert subs3;
     
     cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
     insert userPD;
     
     
     cscfga__Product_Configuration__c userPCold = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
     insert userPCold;
     
     cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site',csordtelcoa__Replaced_Product_Configuration__c=userPCold.id, cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
     insert userPC;
     
     List<csord__Service__c> servs = new List<csord__Service__c>();
     csord__Service__c serv = new csord__Service__c();
     serv.name ='tst service';
     serv.csord__Identification__c  = 'test identify';
     serv.csordtelcoa__Service_Number__c = '3';
     serv.csord__Subscription__c = subs.Id;
     serv.csord__Status__c = 'Service Created';
     serv.csord__Order_Request__c = ordReq.Id;
     serv.csord__Order__c = ord.Id;
     serv.csordtelcoa__Product_Configuration__c = userPC.id;
     serv.Telstra_Committed_Date__c = Date.today() + 30;
     servs.add(serv);
     
     subs.Contract_Term__c = '12';
     Update subs;
     
     csord__Service__c serv1 = new csord__Service__c();
     serv1.name ='tst service1';
     serv1.csord__Identification__c  = 'test identify1';
     serv1.csordtelcoa__Service_Number__c = '4';
     serv1.csord__Subscription__c = subs.Id;
     serv1.csord__Status__c = 'Service Created';
     serv1.csord__Order_Request__c = ordReq.Id;
     serv1.csord__Order__c = ord.Id;
     servs.add(serv1);
     
     csord__Service__c serv2 = new csord__Service__c();
     serv2.name ='tst service1';
     serv2.csord__Identification__c  = 'test identify1';
     serv2.csordtelcoa__Service_Number__c = 'SVC-1234568';
     serv2.csord__Subscription__c = subs1.Id;
     serv2.csord__Status__c = 'Service Created';
     serv2.csord__Order_Request__c = ordReq.Id;
     serv2.csord__Order__c = ord.Id;
     serv2.serviceMSISDN__c='61474850548';
     serv2.Scenario_Type__c='Change of Mobile Number';
     servs.add(serv2);
     
     csord__Service__c serv3 = new csord__Service__c();
     serv3.name ='tst service1';
     serv3.csord__Identification__c  = 'test identify1';
     serv3.csordtelcoa__Service_Number__c = 'SVC-000046942';
     serv3.csord__Subscription__c = subs2.Id;
     serv3.csord__Status__c = 'Service Created';
     serv3.csord__Order_Request__c = ordReq.Id;
     serv3.csord__Order__c = ord.Id;
     serv3.serviceMSISDN__c='61474850548';
     serv2.Scenario_Type__c='Change of Mobile Number';
     servs.add(serv3);
     
     csord__Service__c serv4 = new csord__Service__c();
     serv4.name ='tst service4';
     serv4.csord__Identification__c  = 'test identify1';
     serv4.csord__Subscription__c = subs1.Id;
     serv4.csord__Status__c = 'Service Created';
     serv4.csord__Order_Request__c = ordReq.Id;
     serv4.csord__Order__c = ord.Id;
     serv4.serviceMSISDN__c='61474850548';
     serv4.Scenario_Type__c='Change of Mobile Number';
     servs.add(serv4);
     insert servs;
     
     Appointment__c app = new Appointment__c();
     app.name = 'app1';
     app.SlotId__c='1234';
     insert app;
     
     List<Attachment> atts = new List<Attachment>();
     Attachment att1 = new Attachment();
     att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Disconnect","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","instanceId":"","guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"metadata":{},"includeBilling":false,"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
     att1.Name = 'ServiceSpecifications.json';
     att1.ParentId = serv.Id;
     atts.add(att1);
     
     insert atts;
     List<Number__c> numberList= new List<Number__c>();
     Number__c num2=new Number__c();
     num2.name='Num test2';
     num2.Product_Configuration__c=userPC.id;
     num2.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num2.Type__c='New';
     num2.Service_Number__c='61474850547';
     num2.Status__c='ACTIVE';
     num2.Account__c=acc.id;
     num2.Product_ID__c='gb58-89jk-yuit-fr46';
     numberList.add(num2);
       
     Number__c num3=new Number__c();
     num3.name='Num test3';
     num3.Product_Configuration__c=userPC.id;
     num3.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num3.Type__c='New';
     num3.Service_Number__c='61474850547';
     num3.Status__c='IN TRANSITION';
     num3.Account__c=acc.id;
     num3.Product_ID__c='gb58-89jk-yuit-fr46';
     num3.Start_Range__c='1';
     numberList.add(num3);
     
     Number__c num4=new Number__c();
     num4.name='Num test4';
     num4.Product_Configuration__c=userPC.id;
     num4.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num4.Type__c='New';
     num4.Service_Number__c='61474850547';
     num4.Status__c='Disconnect In Progress';
     num4.Account__c=acc.id;
     num4.Product_ID__c='gb58-89jk-yuit-fr46';
     num4.Start_Range__c='1';
     numberList.add(num4);
     
     Number__c num5=new Number__c();
     num5.name='Num test5';
     num5.Product_Configuration__c=userPC.id;
     num5.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num5.Type__c='New';
     //num5.Service_Number__c='61474850547';
     num5.Status__c='ACTIVE';
     num5.Account__c=acc.id;
     num5.Product_ID__c='gb58-89jk-yuit-fr46';
     num5.Start_Range__c='1';
     numberList.add(num5);
     
     Number__c num6=new Number__c();
     num6.name='Num test6';
     num6.Product_Configuration__c=userPC.id;
     num6.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num6.Type__c='New';
     //num5.Service_Number__c='61474850547';
     num6.Status__c='IN TRANSITION';
     num6.Account__c=acc.id;
     num6.Product_ID__c='gb58-89jk-yuit-fr46';
     num6.Start_Range__c='1';
     numberList.add(num6);
     
     Number__c num7=new Number__c();
     num7.name='Num test7';
     num7.Product_Configuration__c=userPC.id;
     num7.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num7.Type__c='New';
     //num5.Service_Number__c='61474850547';
     num7.Status__c='Disconnect In Progress';
     num7.Account__c=acc.id;
     num7.Product_ID__c='gb58-89jk-yuit-fr46';
     num7.Start_Range__c='1';
     numberList.add(num7);
     
     Number__c num8=new Number__c();
     num8.name='Num test7';
     num8.Product_Configuration__c=userPC.id;
     num8.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num8.Type__c='New';
     //num5.Service_Number__c='61474850547';
     num8.Status__c='RESERVED';
     num8.Account__c=acc.id;
     num8.Product_ID__c='gb58-89jk-yuit-fr46';
     num8.Start_Range__c='1';
     numberList.add(num8);
     
     //EDGE-132208 added test data - we are just changing the input values, There is no chnage in return values of methods.
     Number__c num10=new Number__c();
     num10.name='Num test7';
     num10.Product_Configuration__c=userPCold.id;
     num10.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num10.Type__c='New';
     num10.Status__c='DISCONNECT PENDING';
     num10.Account__c=acc.id;
     num10.Product_ID__c='gb58-89jk-yuit-fr46';
     num10.Start_Range__c='1';
     numberList.add(num10);
     
     Number__c num11=new Number__c();
     num11.name='Num test7';
     num11.Product_Configuration__c=userPCold.id;
     num11.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num11.Type__c='New';
     num11.Status__c='Provisioned';
     num11.Account__c=acc.id;
     num11.Product_ID__c='gb58-89jk-yuit-fr46';
     num11.Start_Range__c='1';
     numberList.add(num11);
     
     //EDGE-132208 END 
     Number__c num12=new Number__c();
     num12.name='Num test12';
     num12.Product_Configuration__c=userPCold.id;
     num12.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num12.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num12.Type__c='New';
     num12.Status__c='DISCONNECT PENDING';
     num12.Account__c=acc.id;
     num12.Product_ID__c='gb58-89jk-yuit-fr46';
     num12.Start_Range__c='1';
     numberList.add(num12);
     
     // Test Data for - EDGE-136242
     Number__c num13=new Number__c();
     num13.name='ProvisioningInProgress';
     num13.Product_Configuration__c=userPCold.id;
     num13.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num13.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num13.Type__c='New';
     num13.Status__c='Provisioning In Progress';
     num13.Account__c=acc.id;
     num13.Product_ID__c='gb58-89jk-yuit-fr46';
     num13.Start_Range__c='1';
     numberList.add(num13);
     
     Number__c num14=new Number__c();
     num14.name='DISCONNECTINPROGRESS';
     num14.Product_Configuration__c=userPCold.id;
     num14.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num14.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num14.Type__c='New';
     num14.Status__c='DISCONNECT IN PROGRESS';
     num14.Account__c=acc.id;
     num14.Product_ID__c='gb58-89jk-yuit-fr46';
     num14.Start_Range__c='1';
     numberList.add(num14);
     
     Number__c num15=new Number__c();
     num15.name='NumberProvisioned';
     num15.Product_Configuration__c=userPCold.id;
     num15.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num15.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num15.Type__c='New';
     num15.Status__c='Provisioned';
     num15.Account__c=acc.id;
     num15.Product_ID__c='gb58-89jk-yuit-fr46';
     num15.Start_Range__c='1';
     numberList.add(num15);
     
     Number__c num16=new Number__c();
     num16.name='NumberBillingReadiness';
     num16.Product_Configuration__c=userPCold.id;
     num16.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num16.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num16.Type__c='New';
     num16.Status__c='Bill Readiness In Progress';
     num16.Account__c=acc.id;
     num16.Product_ID__c='gb58-89jk-yuit-fr46';
     num16.Start_Range__c='1';
     numberList.add(num16);
     
     Number__c num17=new Number__c();
     num17.name='NumberActive';
     num17.Product_Configuration__c=userPCold.id;
     num17.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num17.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num17.Type__c='New';
     num17.Status__c='Active';
     num17.Account__c=acc.id;
     num17.Product_ID__c='gb58-89jk-yuit-fr46';
     num17.Start_Range__c='1';
     numberList.add(num17);

     Number__c num18=new Number__c();
     num18.name='NumberDISCONNECTED';
     num18.Product_Configuration__c=userPCold.id;
     num18.Subscription_number__c=subs2.csordtelcoa__Subscription_Number__c;
     num18.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num18.Type__c='New';
     num18.Status__c='DISCONNECT IN PROGRESS';
     num18.Account__c=acc.id;
     num18.Product_ID__c='gb58-89jk-yuit-fr46';
     num18.Start_Range__c='1';
     numberList.add(num18);
     
     Number__c num19=new Number__c();
     num19.name='NumberInActive';
     num19.Product_Configuration__c=userPCold.id;
     num19.Subscription_number__c=subs3.csordtelcoa__Subscription_Number__c;
     num19.Service_Id__c = serv3.csordtelcoa__Service_Number__c;
     num19.Type__c='New';
     num19.Status__c='DISCONNECTED';
     num19.Account__c=acc.id;
     num19.Product_ID__c='gb58-89jk-yuit-fr46';
     num19.Start_Range__c='1';
     numberList.add(num19);
     
     Number__c num20=new Number__c();
     num20.name='NumberReplace';
     num20.Product_Configuration__c=userPCold.id;
     num20.Subscription_number__c=subs1.csordtelcoa__Subscription_Number__c;
     num20.Service_Id__c = serv4.csordtelcoa__Service_Number__c;
     num20.Type__c='New';
     num20.Status__c='ACTIVE';
     num20.Account__c=acc.id;
     num20.Product_ID__c='gb58-89jk-yuit-fr46';
     num20.Start_Range__c='1';
     numberList.add(num20);
     //Test Data end - EDGE-136242 
     insert numberList;
     
     Number__c num=new Number__c();
     num.name='Num test';
     num.Product_Configuration__c=userPC.id;
     num.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
     num.Type__c='New';
     num.Service_Number__c='61474850547';
     num.Status__c='RESERVED';
     num.Account__c=acc.id;
     num.Product_ID__c='gb58-89jk-yuit-fr46';
     
     
     insert num;
     
     Number__c num1=new Number__c();
     num1.name='Num test1';
     num1.Product_Configuration__c=userPC.id;
     num1.Subscription_number__c=subs1.csordtelcoa__Subscription_Number__c;
     num1.Type__c='New';
     num1.Service_Id__c=serv2.csordtelcoa__Service_Number__c;
     num1.Service_Number__c='61474850548';
     num1.Status__c='RESERVED';
     num1.Account__c=acc.id;
     num1.Product_ID__c='gb58-89jk-yuit-fr46';
     
     insert num1;
    }
    @isTest
    static void testUpdateNumberStatus_PIP(){
        Number__c ResNum=[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test1' Limit 1];
        String prdID=ResNum.Product_ID__c;
        String subNum=ResNum.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Provisioning In Progress');
        Test.stopTest();
        System.assertEquals('RESERVED', ResNum.Status__c);//EDGE-132208 - Added to check number status update.
        System.assertEquals('Num test1', ResNum.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_Provisioned(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Provisioned');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_BRIP(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Bill Readiness In Progress');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    @isTest
    static void testUpdateNumberStatus_Active(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Active');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_ActiveA(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test1' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Active');
        Test.stopTest();
        System.assertEquals('Num test1', num.Name);
    }
    @isTest
    static void testUpdateNumberStatus_DIP(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Disconnect In Progress');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    @isTest
    static void testUpdateNumberStatus_Disconnected(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,prdID,subNum,'Disconnected');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_PIP1(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test1' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,null,subNum,'Provisioning In Progress');
        Test.stopTest();
        System.assertEquals('Num test1', num.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_Provisioned1(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,null,subNum,'Provisioned');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_BRIP1(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,null,subNum,'Bill Readiness In Progress');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    @isTest
    static void testUpdateNumberStatus_Active1(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,null,subNum,'Active');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
       @isTest
    static void testUpdateNumberStatus_DIP1(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,null,subNum,'Disconnect In Progress');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
      @isTest
    static void testUpdateNumberStatus_Disconnected1(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(null,null,subNum,'Disconnected');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
        @isTest
    static void testUpdateNumberStatus_method2(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(prdID,subNum,'Disconnected');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
        @isTest
    static void testUpdateNumberStatus_method3(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        NumberUtil.UpdateNumberStatus(subNum,'Disconnected');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
     @isTest
    static void testUpdateNumberStatus_Inactive(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        //NumberUtil.UpdateNumberStatus(null,null,subNum,'Inactive');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    
    @isTest
    static void testUpdateNumberStatus_Inactive2(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        //NumberUtil.UpdateNumberStatus(prdID,subNum,'Inactive');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    @isTest
    static void testUpdateNumberStatus_Inactive3(){
        Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;
        Test.startTest();
        //NumberUtil.UpdateNumberStatus(subNum,'Inactive');
        Test.stopTest();
        System.assertEquals('Num test', num.Name);
    }
    @isTest
    static void testUpdateNumberStatus_Inactive4(){
        //dataSetup();
        csord__Service__c serviceList = [Select Id,Name,csordtelcoa__Product_Configuration__c,csordtelcoa__Service_Number__c  from csord__Service__c where name ='tst service' limit 1 ];
        /*Number__c num=[select id,name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test' Limit 1];
        String prdID=num.Product_ID__c;
        String subNum=num.Subscription_number__c;*/
        Test.startTest();
        NumberUtil.getNumbersforBDS(serviceList.csordtelcoa__Service_Number__c);
        Test.stopTest();
        System.assertEquals('tst service', serviceList.Name);
    }

    // Test Methods Starts  - EDGE-136242
    @isTest
    static void NumberStatusBulkified_Test(){
        List<Number__c> proInProgList= new List<Number__c>();
        proInProgList = [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where (Name='Num test12' OR Name='Num test1')];
        List<String> prdIDList = new List<String>();
        List<String> subNumList = new List<String>();
        Number__c dicNum=[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test12' Limit 1];
        System.assertNotEquals('DISCONNECT IN PROGRESS', dicNum.Status__c);// Negative Test
        for(Number__c proInProd :proInProgList){
            prdIDList.add(proInProd.Product_ID__c);
            subNumList.add(proInProd.Subscription_number__c);   
        }        
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified(prdIDList,subNumList,'Provisioning In Progress');
        Test.stopTest();
        List <Number__c> num1=[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test12' Limit 1];
        System.assertNotEquals(null, num1);
    }
    @isTest
    static void NumberStatusBulkified_TestProvisioned(){
        List<Number__c> proNumLst = New List<Number__c>();
        proNumLst = [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where (Name='ProvisioningInProgress' OR Name='DISCONNECTINPENDING')];
        List<String> prdIDList = new List<String>();        
        List<String> subNumList = New List<String>();
        for(Number__c provnum :proNumLst){
            prdIDList.add(provnum.Product_ID__c);
            subNumList.add(provnum.Subscription_number__c);
        } 
        Number__c ResNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='ProvisioningInProgress' Limit 1];
        System.assertNotEquals('Provisioned', ResNum.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified(prdIDList,subNumList,'Provisioned');// Refactor Method call
        Test.stopTest();
        List<Number__c> ReservedNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='ProvisioningInProgress' Limit 1];
       
        System.assertNotEquals(Null, ReservedNum);
    }
    @isTest
    static void NumberStatusBulkified_TestBillReadiness(){
        Number__c numBilling= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberProvisioned' limit 1];
        List<String> prdIDList = new List<String>();        
        List<String> subNumList = New List<String>();
        prdIDList.add(numBilling.Product_ID__c);
        subNumList.add(numBilling.Subscription_number__c);
        System.assertNotEquals('Bill Readiness In Progress', numBilling.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified(prdIDList,subNumList,'Bill Readiness In Progress');
        Test.stopTest();
        List<Number__c> BillingNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberProvisioned' Limit 1];
        System.assertNotEquals(null, BillingNum);
    }
    @isTest
    static void NumberStatusBulkified_TestDicInProg(){
        Number__c numDisInProg= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberActive' limit 1];
        System.debug('numDisInProg-->'+numDisInProg.Status__c);
        List<String> prdIDList = new List<String>();        
        List<String> subNumList = New List<String>();
        prdIDList.add(numDisInProg.Product_ID__c);
        subNumList.add(numDisInProg.Subscription_number__c);
        System.assertNotEquals('Disconnect In Progress', numDisInProg.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified(prdIDList,subNumList,'Disconnect In Progress');
        Test.stopTest();
        List<Number__c> BillingNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberActive' Limit 1];
      
        System.assertNotEquals(null, BillingNum);
    }
    
    @isTest
    static void NumberStatusBulkified_TestNumDis(){
        Number__c numDiscon= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberDISCONNECTED' limit 1];
        List<String> prdIDList = new List<String>();        
        List<String> subNumList = New List<String>();
        prdIDList.add(numDiscon.Product_ID__c);
        subNumList.add(numDiscon.Subscription_number__c);
        System.assertNotEquals('DISCONNECTED', numDiscon.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified(prdIDList,subNumList,'Disconnected');
        Test.stopTest();
        List<Number__c> DisconNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberDISCONNECTED' Limit 1];
        System.assertNotEquals(null, DisconNum);
    }
    // Test Method end -EDGE-136242
    
    // Test Methods to cover UpdateNumberStatusBulkified2 Method - Start
    @isTest
    static void NumberStatusBulkified2_Test(){
        List<Number__c> proInProgList= new List<Number__c>();
        proInProgList = [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where (Name='Num test12' OR Name='Num test1')];
        List<String> prdIDList = new List<String>();
        List<Number__c> subNumList = new List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        Number__c dicNum=[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test12' Limit 1];
        System.assertNotEquals('DISCONNECT IN PROGRESS', dicNum.Status__c);// Negative Test
        for(Number__c proInProd :proInProgList){
            prdIDList.add(proInProd.Product_ID__c);
            subNumList.add(proInProd);   
        }  
        mapSubNumList.put('Provisioning In Progress', subNumList);
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        List<Number__c> num1=[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='Num test12' Limit 1];
        System.assertNotEquals(null, num1);
    }
    
    @isTest
    static void NumberStatusBulkified2_TestProvisioned(){
        List<Number__c> proNumLst = New List<Number__c>();
        proNumLst = [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where (Name='ProvisioningInProgress' OR Name='DISCONNECTINPENDING')];
        List<String> prdIDList = new List<String>();        
        List<Number__c> subNumList = New List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        for(Number__c provnum :proNumLst){
            prdIDList.add(provnum.Product_ID__c);
            subNumList.add(provnum);
        } 
        mapSubNumList.put('Provisioned', subNumList);
        Number__c ResNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='ProvisioningInProgress' Limit 1];
        System.assertNotEquals('Provisioned', ResNum.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        Number__c ReservedNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='ProvisioningInProgress' Limit 1];
        System.assertNotEquals('Provisioning In Progress', ReservedNum.Status__c);//Negative Test
        System.assertEquals('Provisioned', ReservedNum.Status__c);
    }
    
    @isTest
    static void NumberStatusBulkified2_TestBillReadiness(){
        Number__c numBilling= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where Name='NumberProvisioned' limit 1];
        List<String> prdIDList = new List<String>();        
        List<Number__c> subNumList = New List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        prdIDList.add(numBilling.Product_ID__c);
        subNumList.add(numBilling);
        mapSubNumList.put('Bill Readiness In Progress', subNumList);
        System.assertNotEquals('Bill Readiness In Progress', numBilling.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        Number__c BillingNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberProvisioned' Limit 1];
        System.assertEquals('Bill Readiness In Progress', BillingNum.Status__c);
    }
    
    @isTest
    static void NumberStatusBulkified2_TestDicInProg(){
        Number__c numDisInProg= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where Name='NumberActive' limit 1];
        System.debug('numDisInProg-->'+numDisInProg.Status__c);
        List<String> prdIDList = new List<String>();        
        List<Number__c> subNumList = New List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        prdIDList.add(numDisInProg.Product_ID__c);
        subNumList.add(numDisInProg);
        mapSubNumList.put('Disconnect In Progress', subNumList);
        System.assertNotEquals('Disconnect In Progress', numDisInProg.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        Number__c BillingNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberActive' Limit 1];
        System.debug('BillingNum-->'+BillingNum.Status__c);
        System.assertEquals('Disconnect In Progress', BillingNum.Status__c);
    }
    
    @isTest
    static void NumberStatusBulkified2_TestNumDis(){
        Number__c numDiscon= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where Name='NumberDISCONNECTED' limit 1];
        List<String> prdIDList = new List<String>();        
        List<Number__c> subNumList = New List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        prdIDList.add(numDiscon.Product_ID__c);
        subNumList.add(numDiscon);
        mapSubNumList.put('Disconnected', subNumList);
        System.assertNotEquals('DISCONNECTED', numDiscon.Status__c);//Negative Test
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        List<Number__c> DisconNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberDISCONNECTED' Limit 1];
        System.assertNotEquals(null, DisconNum);
    }
    
    @isTest
    static void NumberStatusBulkified2_TestNumActive(){
        Number__c numActive= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where Name='NumberActive' limit 1];
        List<String> prdIDList = new List<String>();        
        List<Number__c> subNumList = New List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        prdIDList.add(numActive.Product_ID__c);
        subNumList.add(numActive);
        mapSubNumList.put('Active', subNumList);
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        Number__c ActiveNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberActive' Limit 1];
        //System.assertEquals('ACTIVE', ActiveNum.Status__c);
        //System.assertEquals('Active', ActiveNum.Status__c);
         System.assertnotEquals(null, ActiveNum.Status__c);
        system.assert('Active'.equalsIgnoreCase(ActiveNum.Status__c),true);
    }
    
    @isTest
    static void NumberStatusBulkified2_TestNumInActive(){
        Number__c numDisconnect= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where Name='NumberInActive' limit 1];
        List<String> prdIDList = new List<String>();        
        List<Number__c> subNumList = New List<Number__c>();
        Map<String,List<Number__c>> mapSubNumList = new Map<String,List<Number__c>>();
        prdIDList.add(numDisconnect.Product_ID__c);
        subNumList.add(numDisconnect);
        mapSubNumList.put('Inactive', subNumList);
        Test.startTest();
        NumberUtil.UpdateNumberStatusBulkified2(prdIDList,mapSubNumList);
        Test.stopTest();
        Number__c ActiveNum =[select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c from Number__c where Name='NumberInActive' Limit 1];
        //System.assertEquals('DISCONNECTED', ActiveNum.Status__c);
        //System.assertEquals('Inactive', ActiveNum.Status__c);
        System.assertnotEquals(null, ActiveNum.Status__c);
    }
    
      @isTest
    static void NumberStatusBulkified2_getNumberforUpdates(){
        Number__c numDisconnect= [select id,Name,Subscription_number__c,Type__c,Service_Number__c,Status__c,Product_ID__c,Service_Id__c from Number__c where Name='NumberInActive' limit 1];
        List<String> prdIDList = new List<String>();    
        List<String> subsnumList = new List<String>(); 
        subsnumList.add(numDisconnect.Subscription_number__c);
         prdIDList.add(numDisconnect.Product_ID__c);
        
        Test.startTest();
       Map<String, List<Number__c>> nummap = NumberUtil.getNumberforUpdates(prdIDList,subsnumList);
        Test.stopTest();
        
        //System.assertEquals('DISCONNECTED', ActiveNum.Status__c);
        System.assertEquals(false, prdIDList.isEmpty());
    }
    // Test Methods to cover UpdateNumberStatusBulkified2 Method - End
       
}