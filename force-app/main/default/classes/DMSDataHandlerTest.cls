/******************************************************************************************************************************
* @Author       : Murugula Srinivasarao from Radium Salesforce team
* @Desc         : Test class for DMSDataHandler
* @Created Date : 30th Aug 2021
* @JIRA         : DIGI-6141
*******************************************************************************************************************************/
@isTest
private class DMSDataHandlerTest { 
@TestSetup static void dataSetup() 
 {
//Account creation
       Account testAccount = AccountTestFactory.buildAccount('TestDMSOfferAccount');
       testAccount.Customer_Status__c = 'ACTIVE';
       testAccount.CIDN__c = '1234567870';
Insert testAccount;
// Billing Account Creation
      list<Billing_Account__c> BlAcntlist = new list<Billing_Account__c>();        
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506240';
        billAcc.Account__c = testAccount.id;
        BlAcntlist.add(billAcc);
Insert BlAcntlist;
//Opportunity creation
       list<Opportunity> Optylist = new list<Opportunity>();
      Opportunity testOpp  = ProductTestFactory.getOpportunityBasic(testAccount);
        testOpp.AccountId  = testAccount.Id;
        testOpp.Name = 'TestDMSOpportunity';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'New To Market';
        testOpp.Product_Domain__c = 'FIXED TELEPHONY';
        testOpp.Pricing_Method__c = 'PET';
        testOpp.Billing_Solution__c = 'Non Standard';
        Optylist.add(testOpp);
Insert Optylist;
//Cancel Opportunity creation
       list<Opportunity> Optylist1 = new list<Opportunity>();
      Opportunity testOpptyCancel  = ProductTestFactory.getOpportunityBasic(testAccount);
        testOpptyCancel.AccountId  = testAccount.Id;
        testOpptyCancel.Name = 'TestDMSCancelOpportunity';
        testOpptyCancel.StageName = 'Define';
        testOpptyCancel.Product_Type__c = 'Modular';
        testOpptyCancel.CloseDate = System.Date.today();
        testOpptyCancel.Type = 'New To Market';
        testOpptyCancel.Product_Domain__c = 'FIXED TELEPHONY';
        testOpptyCancel.Pricing_Method__c = 'PET';
        testOpptyCancel.Billing_Solution__c = 'Non Standard';
        Optylist1.add(testOpptyCancel);
Insert Optylist1;     
//Product basket creation
      List<cscfga__Product_Basket__c> PBlist = new List<cscfga__Product_Basket__c>();
      cscfga__Product_Basket__c testBasket = ProductTestFactory.buildEmptyBasket();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        testBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        testBasket.csbb__Synchronised_With_Opportunity__c =true;
        testBasket.cscfga__Basket_Status__c = 'Valid';
        testBasket.cscfga__total_contract_value__c = 11112;
        PBlist.add(testBasket);
Insert PBlist;
//Product basket creation for Cancel Service
      List<cscfga__Product_Basket__c> PBlistChange = new List<cscfga__Product_Basket__c>();
      cscfga__Product_Basket__c testBasketChange = ProductTestFactory.buildEmptyBasket();
        testBasketChange.csbb__Account__c = testAccount.Id;
        testBasketChange.cscfga__Opportunity__c = testOpptyCancel.Id;
        testBasketChange.csordtelcoa__Synchronised_with_Opportunity__c =true;
        testBasketChange.csbb__Synchronised_With_Opportunity__c =true;
        testBasketChange.cscfga__Basket_Status__c = 'Valid';
        testBasketChange.cscfga__total_contract_value__c = 11114;
     	testBasketChange.csordtelcoa__Change_Type__c = 'Change Solution';
        PBlistChange.add(testBasketChange);
Insert PBlistChange;
//Product Definition creation
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c PrdDef = ProductTestFactory.buildProductDefinition('DMS Product', 'Test Plan');
        PrdDef.product_Specification__c = 'DMCAT_ProductSpecification_001541';
        PrdDef.csordtelcoa__Product_Type__c = 'Subscription';
        PrdDef.cscfga__Label__c = 'DMS Product';
        PrdDef.cscfga__Active__c = true;
        PrdDef.cscfga__Description__c='DMS Product';
        PrdDef.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(PrdDef);
Insert prodDefList;
// DMS Marketable Offer Creation
        list<Marketable_Offer__c> DMSMF = new list<Marketable_Offer__c>();
        Marketable_Offer__c DMS_MO = new Marketable_Offer__c();
        DMS_MO.OfferDefinationName__c ='Digital Managed Service';
        DMS_MO.Name = 'Digital Managed Service';
        DMS_MO.Offer_ID__c = 'DMCAT_Offer_001540';
        DMS_MO.Product_Family__c = 'Digital Managed Service';
        DMS_MO.Invoice_Definition__c = 'Invoice_Def_1';
        DMS_MO.Configurations__c = '{"skipBasketSyncValidations":false}';
        DMS_MO.Config__c = '{"noLineItem":true,"skipBasketSyncValidations":true,"validateBillAccEnrich":true,"isConsumptionBasedCharge":true}';
        DMSMF.add(DMS_MO);
Insert DMSMF;
//Product configuration creation
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c Prdcon = ProductTestFactory.buildProductConfig(PrdDef.id);
        Prdcon.name= 'DMS Product';
        Prdcon.Type__c = 'New';
        Prdcon.Marketable_Offer__c = DMS_MO.id;
        Prdcon.cscfga__Product_Family__c='Digital Managed Service';
        Prdcon.cscfga__Product_Definition__c =PrdDef.id;
        Prdcon.cscfga__unit_recurring_charge__c = 0.00;
        Prdcon.cscfga__Product_Basket__c = testBasket.id;
        prodConfigList.add(Prdcon);     
Insert prodConfigList;
//Cancel Product Configuration
      List<cscfga__Product_Configuration__c> prodConfigListCancel = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c PrdconCancel = ProductTestFactory.buildProductConfig(PrdDef.id);
        PrdconCancel.name= 'DMS Product';
        PrdconCancel.Type__c = 'Cancel';
        PrdconCancel.Marketable_Offer__c = DMS_MO.id;
        PrdconCancel.cscfga__Product_Family__c='Digital Managed Service';
        PrdconCancel.cscfga__Product_Definition__c =PrdDef.id;
        PrdconCancel.cscfga__unit_recurring_charge__c = 0.00;
        PrdconCancel.cscfga__Product_Basket__c = testBasketChange.id;
        PrdconCancel.csordtelcoa__Replaced_Product_Configuration__c=Prdcon.id;
        ProdConfigListCancel.add(PrdconCancel);     
Insert prodConfigListCancel;
}
//@purpose : To create test class for getDMSServices
@isTest 
    static void  getDMSServicesTest(){ 
        Test.startTest();
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE cscfga__Opportunity__r.Name = 'TestDMSOpportunity'
                                                    LIMIT 1];
           String basketId = '';
            if(prodBasket !=null){
                basketId = prodBasket.id;
            }
            DMSDataHandler handler = new DMSDataHandler();
            List<Map<String,Object>> rows = handler.getDMSServices(basketId,new Map<String,String>{'Query_Type'=>'DMSServices','Type'=>'New'});
            DMSDataHandler.logException('getDMSServices','','123', 'Error', 'Telstra: Generate Quote/Contract order form for DMS failed.','DMSDataHandler');
            List<Exception_Log__c> logExceptionList = [SELECT ID FROM Exception_Log__c];
        Test.stopTest();
           System.assert(logExceptionList.size() > 0, 'There should be atleast one log in the list' );
           System.assert(!rows.isEmpty(),false);
           System.assertEquals('Digital Managed Service', rows[0].get('Offer_Name'));
           System.assertEquals('DMSServices', rows[0].get('Query_Type'));
    }
//@purpose : To create test class for getDMSCancelServices   
    @isTest 
    static void  getDMSCancelServicesTest(){ 
        Test.startTest();
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE csordtelcoa__Change_Type__c = 'Change Solution'
                                                    LIMIT 1];
          	String basketId = '';
            if(prodBasket !=null){
                basketId = prodBasket.id;
            }
            DMSDataHandler handlerCancel = new DMSDataHandler();
             List<Map<String,Object>> rows = handlerCancel.getDMSCancelServices(basketId,new Map<String,String>{'Query_Type'=>'DMSCancelServices','Type'=>'Cancel'});
            DMSDataHandler.logException('getDMSCancelServices','','1234', 'Error', 'Telstra: Generate Quote/Contract order form for Cancelling DMS offer has been failed','DMSDataHandler');
            List<Exception_Log__c> logExceptionList = [SELECT ID FROM Exception_Log__c];
       Test.stopTest();
            System.assert(logExceptionList.size() > 0, 'There should be atleast one log in the list');
       		System.assert(!rows.isEmpty(),false);
            System.assertEquals('Digital Managed Service',rows[0].get('Offer_Name'));
            System.assertEquals('DMSCancelServices', rows[0].get('Query_Type'));
            System.assertEquals('Cancel', rows[0].get('Type'));
            System.assertEquals('DMS Product',rows[0].get('Product_Module_Name'));
            System.assertEquals(0,rows[0].get('GSTExcl_TotalETC'));
            System.assertEquals(0.00,rows[0].get('GSTIncl_TotalETC'));
    }
    }