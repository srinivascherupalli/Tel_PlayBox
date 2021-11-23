/*************************************************************************************************************
 * @name			Coms_TestDataFactory
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			13 / 09 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-13		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
@isTest
public with sharing class Coms_TestDataFactory {
    public static User getAdminUser(){
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'adminus',
                          Email='adminuser@testorg.com',
                          EmailEncodingKey='UTF-8',
                          LastName='Testing',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        return u;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @return List<Account> 
    **/
    public static List<Account> createAccount(){
        List<Account> lstOfAccount = new List<Account>();
        for(Integer i=0;i<10;i++){
            Account testAccount = new Account();
            testAccount.Name='Test Account000'+i ;
            testAccount.Customer_Status__c='ACTIVE';
            lstOfAccount.add(testAccount);
        }
        return lstOfAccount;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param lstOfAccount 
    * @return List<Billing_Account__c> 
    **/
    public static List<Billing_Account__c> createBillingAccount(List<Account> lstOfAccount){
        List<Billing_Account__c> lstOfBillingAccount=new List<Billing_Account__c>();
       // for(Integer i=0;i<2;i++){
            Billing_Account__c billAccount = new Billing_Account__c();
            billAccount.Account__c = lstOfAccount[0].Id;
            billAccount.Billing_Account_Number__c = '123123122234';
            lstOfBillingAccount.add(billAccount);
       // }
        return lstOfBillingAccount;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param lstOfAccount 
    * @return List<Opportunity> 
    **/
    public static List<Opportunity> createOpportunity(List<Account> lstOfAccount){
        List<Opportunity> lstOfOpportunity=new List<Opportunity>();
        for(Integer i=0;i<10;i++){
        Opportunity testOpp = new Opportunity();
        testOpp.Account = lstOfAccount[i];
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Develop';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        lstOfOpportunity.add(testOpp);
        }
        return lstOfOpportunity;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @return List<cscfga__Product_Definition__c> 
    **/
    public static List<cscfga__Product_Definition__c> createCWPD(){
        List<cscfga__Product_Definition__c> lstOFCWPD=new List<cscfga__Product_Definition__c>();
        for(Integer i=0;i<10;i++){
        cscfga__Product_Definition__c cWPD = new cscfga__Product_Definition__c(
            Name = 'Mobile device', 
            cscfga__Description__c = 'Mobile device',
            product_Specification__c='DMCAT_ProductSpecification_000423');
            lstOFCWPD.add(cWPD); 
        }
        return lstOFCWPD;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param lstOfAccount 
    * @param lstOfOpportunity 
    * @return List<cscfga__Product_Basket__c> 
    **/
    public static List<cscfga__Product_Basket__c> createBasket(List<Account> lstOfAccount,List<Opportunity> lstOfOpportunity){
        List<cscfga__Product_Basket__c> lstOFTestBasket=new List<cscfga__Product_Basket__c>();
        for(Integer i=0;i<10;i++){
            cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
            testBasket.csbb__Account__c = lstOfAccount[i].Id;
            testBasket.Name = 'ShowSubTestBasket';
            testBasket.cscfga__Opportunity__c = lstOfOpportunity[i].Id;
            lstOFTestBasket.add(testBasket); 
        }
        return lstOFTestBasket;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param lstOFTestBasket 
    * @param lstOFCWPD 
    * @return List<cscfga__Product_Configuration__c> 
    **/
    public static List<cscfga__Product_Configuration__c> createConfig(List<cscfga__Product_Basket__c> lstOFTestBasket,List<cscfga__Product_Definition__c> lstOFCWPD){
        List<cscfga__Product_Configuration__c> lstOFTestConfig=new List<cscfga__Product_Configuration__c>();
        for(Integer i=0;i<10;i++){
            cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
            testConfig.Name = 'Connected Workplace';
            testConfig.cscfga__Product_Basket__c = lstOFTestBasket[i].Id;
            testConfig.cscfga__Product_Definition__c=lstOFCWPD[i].id;
            lstOFTestConfig.add(testConfig);
        }
        return lstOFTestConfig;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param orderId 
    * @param accountIds 
    * @param configList 
    * @param billingAccId 
    * @return List<csord__Subscription__c> 
    **/
    public static List<csord__Subscription__c> createSubscription(Id orderId,List<Account> accountIds,List<cscfga__Product_Configuration__c> configList,Id billingAccId){
        List<csord__Subscription__c> lstOFSubscription=new List<csord__Subscription__c>();
       
        for(Integer i=0;i<3;i++){
            csord__Subscription__c testSub1 = new csord__Subscription__c();
            testSub1.Name = 'TestSub1';
            testSub1.csord__Account__c = accountIds[i].Id;
            testSub1.csord__Order__c = orderId;
            testSub1.csord__Identification__c = 'test1';
            testSub1.csordtelcoa__Product_Configuration__c = configList[i].Id;
            testSub1.Billing_Account__c = billingAccId;
            testSub1.csord__Status__c = 'Active';
            lstOFSubscription.add(testSub1);
        }
        return lstOFSubscription;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param orderId 
    * @param subscriptionIds 
    * @return List<csord__Service__c> 
    **/
    public static List<csord__Service__c> createService(Id orderId,List<csord__Subscription__c> subscriptionIds){
        List<csord__Service__c> lstOFTestservice=new List<csord__Service__c>();
        for(Integer i=0;i<3;i++){
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.Appointment_Required__c='true'; 
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Is_Converted_To_Technical_Object__c=false;
            serv.csord__Subscription__c = subscriptionIds[i].Id;
            serv.csord__Status__c = 'Connected'; 
            serv.csord__Order__c = orderId;
            lstOFTestservice.add(serv);
        }
        return lstOFTestservice;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-13-2021 
    * @param servId 
    * @return List<Attachment> 
    **/
    public static List<Attachment> createAttach(Id servId){
        List<Attachment> lstOFAttach=new List<Attachment>();
        for(Integer i=0;i<2;i++){
            String jsona='{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId":"a3T2N000000CgThUAK","name":"871_RC_810","metadata":{},"instanceId":"","includeBilling":false,"guid":"19d37d80-ea8a-4b0b-48e4-cc5057ff15ae","endDate":"","description":"BusinessCalling_Billing_RecurringCharge_000810","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","attributes":{"billDescription":"FeatureUsageCharges","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_8336","chargeId":"DMCAT_RecurringCharge_000810","billingSpecId":"BSUSG005_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GSTApplicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId":"a3T2N000000CgThUAK","name":"871_RC_814","metadata":{},"instanceId":"","includeBilling":false,"guid":"99e2b523-f057-382f-0b7c-805ac88ef48a","endDate":"","description":"BusinessCalling_Billing_RecurringCharge_000814","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes":{"billDescription":"Individualline-standardcallingplan","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329","concurrencyLimitMode":"IndividualLine","callingPlans":"Standard","chargeId":"DMCAT_RecurringCharge_000814","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GSTApplicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","productConfigurationId":"a3T2N000000CgThUAK","name":"871_AW_876","metadata":{},"instanceId":"","includeBilling":false,"guid":"2b9cf572-7e02-5473-d225-24059b0b6304","endDate":"","description":"BusinessCallingUCPlanAllowance_Billing_DMCAT_Allowance_000876","code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","attributes":{"chargeId":"DMCAT_Allowance_000876","ocsProdID":"T22E_FVOICE-S","billDescription":"IncludedPayG","value":"FixedVoicePlan-Standard","type":"FixedVoice","billingSpecId":"BSUSG004_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871","productConfigurationId":"a3T2N000000CgThUAK","name":"BusinessCalling_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"54549246-82fb-a289-76c0-f6a2deab6da0","endDate":"","description":"BusinessCalling_Fulfilment","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"BSTenancyProductInstanceId":"","concurrencyLimitMode":"inferred","CustomerFacingServiceId":"","NetworkServiceId":"","Number":[{"attributes":{"FNN":"61262072638","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"130242b6-06e7-8e1a-ee83-d83cf31c1a71"},{"attributes":{"FNN":"61262072641","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"25ed7e7b-96c9-c16c-5085-5eab2f92be68"},{"attributes":{"FNN":"61262072642","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"d0f37d0c-e7ab-ea67-a39d-158e07cb14c8"},{"attributes":{"FNN":"61262072643","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"a83159ae-de18-9868-2d7f-6189106bcff5"},{"attributes":{"FNN":"61262072645","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"160c0c25-49c5-136f-33d0-8c07104286cb"},{"attributes":{"FNN":"61262072646","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"a170a0cc-9524-962c-e7bd-a531599916f0"},{"attributes":{"FNN":"61262072647","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"f5b71c1f-fd5a-04d3-e1c3-b59b6e3bb6fe"},{"attributes":{"FNN":"61262072650","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"2281c3a7-f1bb-e12a-fc0f-1863ea4840aa"},{"attributes":{"FNN":"61262072651","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"e1d90ad1-df51-28b2-39ae-f24ae242dd81"},{"attributes":{"FNN":"61262072652","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"NoEntryLine"},"schemaId":"5aee04ff-679c-4a31-0cd1-1d5e31794ddb"}],"__targetSystem":"FULFILMENT","type":"ucServiceSiteAgnosticConcurrencyOffer"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","productConfigurationId":"a3T2N000000CgThUAK","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"2890b3b0-4dff-ea60-1eec-51cdd8f87aac","endDate":"","description":"IncidentManagement_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010002","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2N000000CgThUAK","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"d8c3baa9-d1e5-42af-880e-e525ca3f2c82","endDate":"","description":"TelstraManagedServiceOption1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"additionalAttributes":{}}],"serviceId":"a4e2N0000005QVkQAM","legacyAttributes":[]}}';
            Attachment attc = new Attachment();
            attc.Body = blob.valueof(jsona);
            attc.Name =  'ServiceSpecifications.json';
            attc.parentId=servId;
            lstOFAttach.add(attc);
        }
        return lstOFAttach;
    }

    Public static List<csord__Order__c> createOrder(List<Account> lstOfAccount,List<Opportunity> lstOfOpportunity){
        List<csord__Order__c> lstOFOrder=new List<csord__Order__c>();
        for(Integer i=0;i<10;i++){
            csord__Order__c testOrder = new csord__Order__c();
            testOrder.csord__Account__c = lstOfAccount[i].Id;
            testOrder.csordtelcoa__Opportunity__c = lstOfOpportunity[i].Id;
            testOrder.Name = 'TestOrderNameForTest';
            testOrder.csord__Identification__c = 'test';
            testOrder.isMSISDNHeld__c = false;
            
            lstOFOrder.add(testOrder);
        }
        return lstOFOrder;
    }
    Public static List<csord__Subscription__c> createSubscription(List<Account> lstOfAccount,List<csord__Order__c> testOrder){
        List<csord__Subscription__c> lstOFSubscription=new List<csord__Subscription__c>();
        for(Integer i=0;i<10;i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            testSubscription.Name = 'TestSubsforTest';
            testSubscription.csord__Account__c = lstOfAccount[i].Id;
            testSubscription.csord__Order__c = testOrder[i].Id;
            testSubscription.csord__Identification__c = 'test';
            testSubscription.CorrelationId__c ='345678'+i;
            //testSubscription.ConfigSpecID__c = 'DMCAT_ProductSpecification_000537';
            testSubscription.csord__Status__c = 'Active';
            
            lstOFSubscription.add(testSubscription);
        }
        return lstOFSubscription;
    }
    Public static List<csord__Service__c> createServicesWithOrders(List<csord__Subscription__c> testSubscription,List<csord__Order__c> testOrder){
        List<csord__Service__c> lstOFServices=new List<csord__Service__c>();
        for(Integer i=0;i<10;i++){
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = testSubscription[i].id;
            serv.csord__Order__c = testOrder[i].id;
            serv.csordtelcoa__Service_Number__c = '3';
            lstOFServices.add(serv);
        }
        return lstOFServices;
    }
    Public static List<Orchestration_Technical__c> createOrchestration(List<csord__Service__c> testServices){
        List<Orchestration_Technical__c> lstOForchestrationTech=new List<Orchestration_Technical__c>();
        for(Integer i=0;i<10;i++){
            Orchestration_Technical__c orchestrationTech = new Orchestration_Technical__c();
            orchestrationTech.Field_1__c  = 'test field 1';
            orchestrationTech.Field_10__c='test field 10';
            orchestrationTech.Service__c  = testServices[i].id;
            lstOForchestrationTech.add(orchestrationTech);
        }
        return lstOForchestrationTech;
    }
    Public static List<Technical_Child_Attribute__c> createOrchestrationChild(List<Orchestration_Technical__c> testOrchestration){
        List<Technical_Child_Attribute__c> lstOForchestrationTech=new List<Technical_Child_Attribute__c>();
        for(Orchestration_Technical__c eachParentRecord:testOrchestration){
        for(Integer i=0;i<5;i++){
            Technical_Child_Attribute__c orchestrationChild = new Technical_Child_Attribute__c();
            orchestrationChild.Field_1__c  = 'test field 1';
            orchestrationChild.Field_2__c='test field 10';
            orchestrationChild.Category__c  = 'Additional Attributes';
            orchestrationChild.Orchestration_Technical__c=eachParentRecord.Id;
            orchestrationChild.Complex_Attribute_Schema_Id__c='45678'+i+eachParentRecord.Id;
            orchestrationChild.CorrelationId__c='234567'+i+eachParentRecord.Id;
            lstOForchestrationTech.add(orchestrationChild);
        }
        }
        return lstOForchestrationTech;
    }
    Public static List<Charge_Line_Item__c> createChargeLIneItem(List<csord__Service__c> testServices){
        List<Charge_Line_Item__c> lstOFChargeLIneItem=new List<Charge_Line_Item__c>();
        for(Integer i=0;i<10;i++){
            Charge_Line_Item__c cli= new Charge_Line_Item__c();
            cli.Name='test';
            cli.CorrelationId__c='1234566'+i;
            cli.status__c='new';
            cli.serviceId__c=testServices[i].id;
            cli.BusinessID__c='DMCAT_Billing_000420';
            lstOFChargeLIneItem.add(cli);
        }
        return lstOFChargeLIneItem;
    }
    Public static List<Number__c> createNumber(List<Account> lstOfAccount,List<Charge_Line_Item__c> testCLT){
        List<Number__c> lstOFNumber=new List<Number__c>();
        for(Integer i=0;i<10;i++){
            Number__c num = new Number__c();
            num.Service_Number__c = '61260452045';
            num.Subscription_Number__c = 'SN-000223173';
            num.Status__c = 'Reserved';
            num.Account__c = lstOfAccount[i].Id ;
            //num.Charge_Line_Item__c = testCLT[i].Id;
            lstOFNumber.add(num);
        }
        return lstOFNumber;
    }
    public static List<Price_Schedule_Line_Item__c> createPSLI(List<Charge_Line_Item__c> cli){
        List<Price_Schedule_Line_Item__c> psliList=new List<Price_Schedule_Line_Item__c>();
        for(Integer i=0;i<10;i++){
            Price_Schedule_Line_Item__c psli=new Price_Schedule_Line_Item__c();
            psli.fromPeriod__c='0';
            psli.toPeriod__c='20';
            psli.status__c='new';
            psli.chargeInstance__c=cli[i].id;
            psli.applicationDuration__c=15.1;
            psli.unitPrice__c=20.0;
            psli.CorrelationId__c='234567'+i;
            psliList.add(psli);
        }
        return psliList;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-19-2021 
    * @param cli 
    * @return List<Price_Schedule_Discount_Association__c> 
    **/
    public static List<Price_Schedule_Discount_Association__c> createPSDA(List<Price_Schedule_Line_Item__c> cli){
        List<Price_Schedule_Discount_Association__c> psdaliList=new List<Price_Schedule_Discount_Association__c>();
        for(Integer i=0;i<10;i++){
            Price_Schedule_Discount_Association__c psda=new Price_Schedule_Discount_Association__c();
            psda.Name  = cli[i].id;
            psda.isActive__c =true;
            psda.priceScheduleInstance__c=cli[i].id;
            psdaliList.add(psda);
        }
        return psdaliList;
    }


    Public static List<Discount_Line_Item__c> createDLI(List<Charge_Line_Item__c> cli){
        List<Discount_Line_Item__c> dliList=new List<Discount_Line_Item__c>();
        for(Integer i=0;i<10;i++){
            Discount_Line_Item__c dliPlan = new Discount_Line_Item__c();
            dliPlan.chargeInstance__c = cli[i].Id;
            dliPlan.BusinessID__c = 'DMCAT_Discount_000945';
            dliPlan.CorrelationId__c='45678'+i;
            dliPlan.discountValue__c = '4';
            dliPlan.duration__c = '4';
            dliList.add(dliPlan);
        }
        return dliList;
    }

    public static List<Tier_Line_Item__c> createTLI(List<Price_Schedule_Line_Item__c> cli){
        List<Tier_Line_Item__c> tliList=new List<Tier_Line_Item__c>();
        for(Integer i=0;i<10;i++){
            Tier_Line_Item__c tLIPlan = new Tier_Line_Item__c();
            tLIPlan.Name = 'Test'+i;
            tLIPlan.PSLIInstance__c = cli[0].id;
            tLIPlan.CorrelationId__c = '45678'+i;
            tLIPlan.Platform_Cache_Timestamp__c =system.now();
            tliList.add(tLIPlan);
        }
        return tliList;
    }
    

    Public static Technical_Object_Creation_Event__e createpublishTechnicalObjectEvent(string strAttachmentId,
                                                                                         string strServiceId){
        Technical_Object_Creation_Event__e objTechnicalObjectCreationEvent = new Technical_Object_Creation_Event__e();
        objTechnicalObjectCreationEvent.Attachment_Id__c = strAttachmentId;
        objTechnicalObjectCreationEvent.Service_Id__c = strServiceId;
        return objTechnicalObjectCreationEvent;
    }
    Public static List<Coms_Step_PE__e> createStepPEEvent(Integer stepnumber,String sequenceNum){
        List<Coms_Step_PE__e> lstOfstepPE = new List<Coms_Step_PE__e>();
        for(Integer i=0;i<10;i++){
            Coms_Step_PE__e eachStepPE=new Coms_Step_PE__e();
            eachStepPE.Orchestration_Process_Name__c='Order Fulfilment Process_New';
            eachStepPE.Payload__c='teststepOnePayload';
            eachStepPE.Sequence__c=sequenceNum;
            eachStepPE.Step_Number__c=stepnumber;
            lstOfstepPE.add(eachStepPE);
        }
        
        return lstOfstepPE;
    }
    Public static List<Coms_Service_PE__e> createServicePEEvent(Integer stepnumber,String sequenceNum){
        List<Coms_Service_PE__e> lstOfservicePE = new List<Coms_Service_PE__e>();
        for(Integer i=0;i<10;i++){
            Coms_Service_PE__e eachServicePE=new Coms_Service_PE__e();
            eachServicePE.Orchestration_Process_Name__c='Service Fulfilment Process_New';
            eachServicePE.Payload__c='teststepOnePayload';
            eachServicePE.Sequence__c=sequenceNum;
            eachServicePE.Step_Number__c=stepnumber;
            lstOfservicePE.add(eachServicePE);
        }
        
        return lstOfservicePE;
    }
    Public static List<Coms_Subscription_PE__e> createSubscriptionPEEvent(Integer stepnumber,String sequenceNum){
        List<Coms_Subscription_PE__e> lstOfSubscriptionPE = new List<Coms_Subscription_PE__e>();
        for(Integer i=0;i<10;i++){
            Coms_Subscription_PE__e eachSubscriptionPE=new Coms_Subscription_PE__e();
            eachSubscriptionPE.Orchestration_Process_Name__c='Order Fulfilment Process_New';
            eachSubscriptionPE.Payload__c='teststepOnePayload';
            eachSubscriptionPE.Sequence__c=sequenceNum;
            eachSubscriptionPE.Step_Number__c=stepnumber;
            lstOfsubscriptionPE.add(eachSubscriptionPE);
        }
        
        return lstOfsubscriptionPE;
    }
   
}