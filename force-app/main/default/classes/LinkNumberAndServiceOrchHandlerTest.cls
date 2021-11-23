/*************************************************************************************************************************
Test class :LinkNumberAndServiceOrchHandlerTest
Sr.No.    Developer Name          Date          Story Description
  1.      Prajakta Patil     27/04/2020    EDGE-142322 SIM Serial Number conversion to assetable attribute and order creation of both port out reversal and SIM Replacement order types 
  2.      Sandip Deshmane    22/5/2020   EDGE-149261 - ShippingRequired
  3.      Maq                06/07/2020  EDGE-155321 Bug Fix - Changes related to MACD bug fix
******************************************************************************************************************/

@isTest(SeeAllData=false)
public class LinkNumberAndServiceOrchHandlerTest {

    static testMethod void processTest() {
       

        Account acc = new Account(Name='Test Account');
        
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic(acc);
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
         cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
        productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert productDefinition;
        
         List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.Remaining_Term__c  = 24;
        insert productConfig;
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification';
        ord1.Name = 'test order';
        ord1.csord__Status2__c = 'Pending';
        ord1.csord__Order_Request__c=ordReq.id;
        ord1.csordtelcoa__Opportunity__c = testOpp.id;
        insert ord1;
        
         csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity cancel';
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003298';
        subs.csordtelcoa__Product_Configuration__c = productConfig.id;
        insert subs;
        
         csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify cancel';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord1.id;
        serv.csordtelcoa__Service_Number__c = 'SVC-373269';
        serv.contract_term__c ='24';
        serv.csordtelcoa__Product_Configuration__c = productConfig.Id;
        serv.csord__Service__c = null;
      //  serv.csordtelcoa__Service_Number__c = 'SVC-313267';
       insert serv;
        system.debug('*****serv****'+serv);
         
         Attachment att = new Attachment();
        att.Name = 'ServiceSpecifications.json';
        att.ParentId = serv.Id;
        att.Body = Blob.valueOf('{ "legacyAttributes": [], "serviceId": "'+serv.Id+'", "specifications": [ { "additionalAttributes": { "CustomerFacingServiceId": "61483353311", "parentSpec": "f4642633-9edf-6f55-a10d-c6ab535a47f0" }, "attributes": { "__targetSystem": "FULFILMENT", "IPWirelessProductInstanceID": "NA", "BillofMaterialID": "NA", "AccessRole": "Primary", "CONTEXT": "CUSTOMER", "parentSpec": "DMCAT_ProductSpecification_000420_Fulfilment", "SKU": "100119211", "SuspensionContext": "NA", "MESSAGEBANK": "3G Standard Retail", "CustomerFacingServiceId": "", "ShippingRequired": "TRUE", "IMSI": "", "SERVICEPROFILE": "NORMAL" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "Mobile Access_Fulfilment", "endDate": "", "guid": "11e24a6b-c49e-9d6c-bd27-28d6cbf590e2", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "ocsProdID": "T22E_IR_USAGE", "currency": "AUD", "type": "OC", "billingSubtype": "IR", "taxTreatment": "TAX Exempt", "billingSpecId": "BSUSG002_CB", "billDescription": "IR Pay as you go charge", "rateExcludeGST": "0.00", "unitofMeasure": "each", "externalId": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108" }, "code": "DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601", "description": "Mobile Access_Billing_NonRecurringCharge_000601", "endDate": "", "guid": "cca7ccd1-d3d5-ab2b-386d-51ee1466528d", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "263_NRC_601", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "FULFILMENT" }, "code": "DMCAT_ProductSpecification_000420_Fulfilment", "description": "Mobility_Fulfilment", "endDate": "", "guid": "f4642633-9edf-6f55-a10d-c6ab535a47f0", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobility_Fulfilment", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "currency": "AUD", "quantity": "1", "rateExcludeGST": 9.09, "type": null, "frequency": "Monthly", "billingSpecId": "BSRC001_CB", "billInAdvance": "true", "prorate": "false", "billDescription": "International call pack - basic", "externalId": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_101" }, "code": "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669", "description": "Mobility_Billing_RecurringCharge_000669", "endDate": "", "guid": "a688cc7b-ce54-29f4-42e1-32ecde88c949", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_RC_669", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "value": "20", "unitofMeasure": "GB", "type": "FairPlay Data", "ocsProdID": "T22EM_PLAN-S", "billingSpecId": "BSUSG001_CB", "billDescription": "Includes 20 GB Domestic Data+Unlimited Standard Voice+SMS+MMS" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000637", "description": "Mobility_Billing_DMCAT_Allowance_000637", "endDate": "", "guid": "36fc3220-e019-6de7-0dde-f6b4923c1c86", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_AW_637", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "quantity": "1", "recurringChargePeriod": "Months", "description": "MRO Bonus Plan Discount", "alteredPrice": 68.18, "applicationDuration": 24, "type": "Voice and Data", "currency": "AUD", "frequency": "Monthly", "billingSpecId": "BSRC001_CB", "billInAdvance": "true", "prorate": "false", "billDescription": "Corporate mobile plus - local plan", "rateExcludeGST": "68.18", "externalId": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_7206" }, "code": "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654", "description": "Mobility_Billing_RecurringCharge_000654", "endDate": "", "guid": "5ec52cba-069e-3681-bf06-eefe4bba4963", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_RC_654", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "value": "Basic", "type": "International Direct Dial", "ocsProdID": "T22E_EMOB_IDD1", "billingSpecId": "BSUSG001_CB", "billDescription": "International call pack - basic" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000644", "description": "Mobility_Billing_DMCAT_Allowance_000644", "endDate": "", "guid": "20f214ab-e841-49ff-401d-d8cd8bdcfed1", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_AW_644", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "billingSpecId": "BSUSG001_CB", "ocsProdID": "T22E_IRDAYPASS", "type": "International Roaming Data", "unitofMeasure": "MB", "value": "200", "billingSubtype": "IR", "billDescription": "IR Day Pass" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000606", "description": "Mobility_Billing_DMCAT_Allowance_000606", "endDate": "", "guid": "71ac0cb9-1e35-860f-ce2c-4425459c45a1", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "263_AW_606", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "billingSpecId": "BSUSG001_CB", "ocsProdID": "T22E_IR_AUTOTOPUP", "type": "International Roaming Data", "unitofMeasure": "MB", "value": "500", "billingSubtype": "IR", "billDescription": "IR Data Topup" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000607", "description": "Mobility_Billing_DMCAT_Allowance_000607", "endDate": "", "guid": "2b73b276-ea19-9014-5667-e244e5fd2f07", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "263_AW_607", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": { "parentSpec": "431a8083-61de-8d1a-4261-343ebeee3cd6" }, "attributes": { "__targetSystem": "ASSURANCE", "parentSpec": "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget": "SLA0010001", "RestoreTarget": "SLA0010006" }, "code": "DMCAT_ProductSpecification_000151_Assurance", "description": "Incident Management_Assurance", "endDate": "", "guid": "a9e74038-8f48-3340-ce7f-50b7aab44ca9", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "151_ASR", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "ServiceManagementOption": "1", "__targetSystem": "ASSURANCE" }, "code": "DMCAT_ProductSpecification_000326_Assurance", "description": "Telstra Managed Service Option 1_Assurance", "endDate": "", "guid": "431a8083-61de-8d1a-4261-343ebeee3cd6", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "326_ASR", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "ASSURANCE" }, "code": "DMCAT_ProductSpecification_000421_Assurance", "description": "Mobile Device Management_Assurance", "endDate": "", "guid": "471bf687-9d49-d7f8-caed-c787f37bd925", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "421_ASR", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421", "startDate": "", "status": "Created", "version": "1" } ] }');
         insert att;
        
       List<Number__c> numberList= new List<Number__c>();
       Number__c num2=new Number__c();
       num2.name='Num test2';
       num2.Product_Configuration__c=productConfig.id;
       num2.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num2.Type__c='New';
       num2.Service_Number__c='61474850547';
       num2.Status__c='RESERVED';
       num2.Account__c=acc.id;
       num2.Product_ID__c='gb58-89jk-yuit-fr46';
       num2.IMSI__c='5054567890';
       num2.Sim_Serial_Number__c ='6725383930'; 
       num2.Mobile__c ='Mobile';
       num2.Service_Id__c = serv.csordtelcoa__Service_Number__c;
       numberList.add(num2);
       
       Number__c num3=new Number__c();
       num3.name='Num test3';
       num3.Product_Configuration__c=productConfig.id;
       num3.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num3.Type__c='New';
       num3.Service_Number__c='61474850548';
       num3.Status__c='RESERVED';
       num3.Account__c=acc.id;
       num3.Product_ID__c='gb58-89jk-yuit-fr46';
       num3.Start_Range__c='1';
       num3.IMSI__c='50545675432';
       num3.Sim_Serial_Number__c ='65422383930';
       num3.Mobile__c ='Mobile';
       num3.Service_Id__c = serv.csordtelcoa__Service_Number__c;
       numberList.add(num3);
         insert numberList;
       system.debug('*****numberList****'+numberList);
        
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);
    
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
       
        parentOrchProcess.Order__c= ord1.Id;
        parentOrchProcess.CSPOFA__Opportunity__c=testOpp.id;
        parentOrchProcess.CSPOFA__Account__c=acc.id;
        update parentOrchProcess;
        system.debug('step'+parentOrchProcess);
        system.debug('ord1.csordtelcoa__Opportunity__c'+ord1.csordtelcoa__Opportunity__c);
        system.debug('parentOrchProcess.Order__c'+parentOrchProcess.Order__c);
        system.debug('parentOrchProcess.Order__r.csordtelcoa__Opportunity__c'+parentOrchProcess.Order__r.csordtelcoa__Opportunity__c);
        system.debug('parentOrchProcess.CSPOFA__Opportunity__c'+parentOrchProcess.CSPOFA__Opportunity__c);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        system.debug('step'+step);
        
    
        Test.startTest();
        List<Number__c> numlist = [select id,IMSI__c,Sim_Serial_Number__c from Number__c where (name='Num test2' OR name='Num test3')AND IMSI__c!=null AND Sim_Serial_Number__c != null ];
        LinkNumberAndServiceOrchHandler obj = new LinkNumberAndServiceOrchHandler();
        system.debug('steps'+steps);
        List<SObject> result = obj.process((List<SObject>)steps);
        if(!result.isEmpty()){        
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertNotEquals(null,numlist);
        }
        //EDGE-149261
        List<Attachment> att10 = [SELECT id, name, body, parentId FROM Attachment];
        System.debug('Attachment'+att10);
        Test.stopTest(); 
        System.assertEquals(true, att10[0].body.toString().contains('ShippingRequired'));
    }


    // test method to cover updateServiceSpec | EDGE-155321 Bug Fix - Changes related to MACD bug fix    
    static testMethod void updateServiceSpecTest() {
       

        Account acc = new Account(Name='Test Account');
        
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic(acc);
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
         cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
        productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert productDefinition;
        
         List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.Remaining_Term__c  = 24;
        insert productConfig;
        
        list<Id> orderList = New list<Id>();
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification';
        ord1.Name = 'test order';
        ord1.csord__Status2__c = 'Pending';
        ord1.csord__Order_Request__c=ordReq.id;
        ord1.csordtelcoa__Opportunity__c = testOpp.id;
        insert ord1;
        orderList.add(ord1.Id);
        
         csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity cancel';
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003298';
        subs.csordtelcoa__Product_Configuration__c = productConfig.id;
        insert subs;
        
         csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify cancel';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord1.id;
        serv.csordtelcoa__Service_Number__c = 'SVC-373269';
        serv.contract_term__c ='24';
        serv.csordtelcoa__Product_Configuration__c = productConfig.Id;
        serv.csord__Service__c = null;
      //  serv.csordtelcoa__Service_Number__c = 'SVC-313267';
       insert serv;
        system.debug('*****serv****'+serv);
         
         Attachment att = new Attachment();
        att.Name = 'ServiceSpecifications.json';
        att.ParentId = serv.Id;
        att.Body = Blob.valueOf('{ "legacyAttributes": [], "serviceId": "'+serv.Id+'", "specifications": [ { "additionalAttributes": { "CustomerFacingServiceId": "61483353311", "parentSpec": "f4642633-9edf-6f55-a10d-c6ab535a47f0" }, "attributes": { "__targetSystem": "FULFILMENT", "IPWirelessProductInstanceID": "NA", "BillofMaterialID": "NA", "AccessRole": "Primary", "CONTEXT": "CUSTOMER", "parentSpec": "DMCAT_ProductSpecification_000420_Fulfilment", "SKU": "100119211", "SuspensionContext": "NA", "MESSAGEBANK": "3G Standard Retail", "CustomerFacingServiceId": "", "ShippingRequired": "TRUE", "IMSI": "", "SERVICEPROFILE": "NORMAL" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "Mobile Access_Fulfilment", "endDate": "", "guid": "11e24a6b-c49e-9d6c-bd27-28d6cbf590e2", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "ocsProdID": "T22E_IR_USAGE", "currency": "AUD", "type": "OC", "billingSubtype": "IR", "taxTreatment": "TAX Exempt", "billingSpecId": "BSUSG002_CB", "billDescription": "IR Pay as you go charge", "rateExcludeGST": "0.00", "unitofMeasure": "each", "externalId": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108" }, "code": "DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601", "description": "Mobile Access_Billing_NonRecurringCharge_000601", "endDate": "", "guid": "cca7ccd1-d3d5-ab2b-386d-51ee1466528d", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "263_NRC_601", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "FULFILMENT" }, "code": "DMCAT_ProductSpecification_000420_Fulfilment", "description": "Mobility_Fulfilment", "endDate": "", "guid": "f4642633-9edf-6f55-a10d-c6ab535a47f0", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobility_Fulfilment", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "currency": "AUD", "quantity": "1", "rateExcludeGST": 9.09, "type": null, "frequency": "Monthly", "billingSpecId": "BSRC001_CB", "billInAdvance": "true", "prorate": "false", "billDescription": "International call pack - basic", "externalId": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_101" }, "code": "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669", "description": "Mobility_Billing_RecurringCharge_000669", "endDate": "", "guid": "a688cc7b-ce54-29f4-42e1-32ecde88c949", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_RC_669", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "value": "20", "unitofMeasure": "GB", "type": "FairPlay Data", "ocsProdID": "T22EM_PLAN-S", "billingSpecId": "BSUSG001_CB", "billDescription": "Includes 20 GB Domestic Data+Unlimited Standard Voice+SMS+MMS" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000637", "description": "Mobility_Billing_DMCAT_Allowance_000637", "endDate": "", "guid": "36fc3220-e019-6de7-0dde-f6b4923c1c86", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_AW_637", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "quantity": "1", "recurringChargePeriod": "Months", "description": "MRO Bonus Plan Discount", "alteredPrice": 68.18, "applicationDuration": 24, "type": "Voice and Data", "currency": "AUD", "frequency": "Monthly", "billingSpecId": "BSRC001_CB", "billInAdvance": "true", "prorate": "false", "billDescription": "Corporate mobile plus - local plan", "rateExcludeGST": "68.18", "externalId": "DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_7206" }, "code": "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654", "description": "Mobility_Billing_RecurringCharge_000654", "endDate": "", "guid": "5ec52cba-069e-3681-bf06-eefe4bba4963", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_RC_654", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "value": "Basic", "type": "International Direct Dial", "ocsProdID": "T22E_EMOB_IDD1", "billingSpecId": "BSUSG001_CB", "billDescription": "International call pack - basic" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000644", "description": "Mobility_Billing_DMCAT_Allowance_000644", "endDate": "", "guid": "20f214ab-e841-49ff-401d-d8cd8bdcfed1", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "420_AW_644", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "billingSpecId": "BSUSG001_CB", "ocsProdID": "T22E_IRDAYPASS", "type": "International Roaming Data", "unitofMeasure": "MB", "value": "200", "billingSubtype": "IR", "billDescription": "IR Day Pass" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000606", "description": "Mobility_Billing_DMCAT_Allowance_000606", "endDate": "", "guid": "71ac0cb9-1e35-860f-ce2c-4425459c45a1", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "263_AW_606", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "billingSpecId": "BSUSG001_CB", "ocsProdID": "T22E_IR_AUTOTOPUP", "type": "International Roaming Data", "unitofMeasure": "MB", "value": "500", "billingSubtype": "IR", "billDescription": "IR Data Topup" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000607", "description": "Mobility_Billing_DMCAT_Allowance_000607", "endDate": "", "guid": "2b73b276-ea19-9014-5667-e244e5fd2f07", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "263_AW_607", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": { "parentSpec": "431a8083-61de-8d1a-4261-343ebeee3cd6" }, "attributes": { "__targetSystem": "ASSURANCE", "parentSpec": "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget": "SLA0010001", "RestoreTarget": "SLA0010006" }, "code": "DMCAT_ProductSpecification_000151_Assurance", "description": "Incident Management_Assurance", "endDate": "", "guid": "a9e74038-8f48-3340-ce7f-50b7aab44ca9", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "151_ASR", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "ServiceManagementOption": "1", "__targetSystem": "ASSURANCE" }, "code": "DMCAT_ProductSpecification_000326_Assurance", "description": "Telstra Managed Service Option 1_Assurance", "endDate": "", "guid": "431a8083-61de-8d1a-4261-343ebeee3cd6", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "326_ASR", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "ASSURANCE" }, "code": "DMCAT_ProductSpecification_000421_Assurance", "description": "Mobile Device Management_Assurance", "endDate": "", "guid": "471bf687-9d49-d7f8-caed-c787f37bd925", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "421_ASR", "productConfigurationId": "a3T2N0000002FApUAM", "specification": "DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421", "startDate": "", "status": "Created", "version": "1" } ] }');
         insert att;
        list<csord__Service__c> sc = [select id, csordtelcoa__Service_Number__c from csord__Service__c];
        system.debug('^^^^^^^^>'+sc);
       List<Number__c> numberList= new List<Number__c>();
       Number__c num2=new Number__c();
       num2.name='Num test2';
       num2.Product_Configuration__c=productConfig.id;
       num2.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num2.Type__c='New';
       num2.Service_Number__c='61474850547';
       num2.Status__c='RESERVED';
       num2.Account__c=acc.id;
       num2.Product_ID__c='gb58-89jk-yuit-fr46';
       num2.IMSI__c='5054567890';
       num2.Sim_Serial_Number__c ='6725383930'; 
       num2.Mobile__c ='Mobile';
       num2.Service_Id__c = sc[0].csordtelcoa__Service_Number__c;
       numberList.add(num2);
       
       Number__c num3=new Number__c();
       num3.name='Num test3';
       num3.Product_Configuration__c=productConfig.id;
       num3.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num3.Type__c='New';
       num3.Service_Number__c='61474850548';
       num3.Status__c='RESERVED';
       num3.Account__c=acc.id;
       num3.Product_ID__c='gb58-89jk-yuit-fr46';
       num3.Start_Range__c='1';
       num3.IMSI__c='50545675432';
       num3.Sim_Serial_Number__c ='65422383930';
       num3.Mobile__c ='Mobile';
       num3.Service_Id__c = sc[0].csordtelcoa__Service_Number__c;
       numberList.add(num3);
         insert numberList;
       system.debug('*****numberList****'+numberList);
        
        Test.startTest();
        LinkNumberAndServiceOrchHandler obj = new LinkNumberAndServiceOrchHandler();
        obj.updateServiceSpec(orderList);
        List<Attachment> att10 = [SELECT id, name, body, parentId FROM Attachment];
        System.debug('Attachment'+att10);
        Test.stopTest(); 
        System.assertEquals(true, att10[0].body.toString().contains('ShippingRequired'));       
       
    }
}