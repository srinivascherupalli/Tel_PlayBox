/*
* @Author : Aniket/Rahul
* @Date : 5th April 2021
* @Desc : Test class for TCDataHandler
* @Jira : EDGE-210438, EDGE-207338,EDGE-210440 and EDGE-210441
*/
 
@isTest
public class TCDataHandlerTest {
    private void setup() { 
  Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        system.debug('acc: '+acc);
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
       
        billAcc.Account__c = acc.id;
        insert billAcc;
        system.debug('billAcc@@::' + billAcc);
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        system.debug('opp '+opp);
      
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
       
        system.debug('basket '+basket);

        List<cscfga__Product_Basket__c> lstBasket = new List<cscfga__Product_Basket__c>();
        lstBasket.add(basket);
        insert lstBasket;
        
        List<cscfga__Product_Definition__c> ngucPDList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c ngucPD = ProductTestFactory.buildProductDefinition('Test','Test');
        ngucPD.product_Specification__c='DMCAT_ProductSpecification_000871';
        ngucPDList.add(ngucPD);
        
         cscfga__Product_Definition__c ngucPD01 = ProductTestFactory.buildProductDefinition('Test','Test');
        ngucPD01.product_Specification__c='DMCAT_ProductSpecification_000935';
        ngucPDList.add(ngucPD01);
        
         cscfga__Product_Definition__c ngucPD02 = ProductTestFactory.buildProductDefinition('Test','Test');
        ngucPD02.product_Specification__c='DMCAT_ProductSpecification_000623';
        ngucPDList.add(ngucPD02);
        insert ngucPDList;
        
        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
        Marketable_Offer__c ngucMO = new Marketable_Offer__c();
        ngucMO.OfferDefinationName__c ='Telstra Collaboration Solution' ; // Modified as per real data DPG-3508
        ngucMO.Name = 'Telstra Collaboration';  // Modified as per real data DPG-3508
        ngucMO.Offer_ID__c = 'DMCAT_Offer_000618';
        listOfOffers.add(ngucMO);
        insert listOfOffers;
        
        /*Marketable_Offer__c moTC = new Marketable_Offer__c();
        moTC.OfferDefinationName__c ='Telstra Collaboration';
        moTC.Name = 'Telstra Collaboration';
        moTC.Offer_ID__c = 'DMCAT_Offer_000618';
        listOfOffers.add(moTC);*/
        
        
        
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        
        
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name='Replaced Product Configuration record';
        replacedConfig.cscfga__Product_Definition__c=ngucPDList[0].id;
        //replacedConfig.cscfga__Product_Basket__c=lstBasket[0].id;
        replacedConfig.cscfga__Description__c = 'test Description';
        replacedConfig.cscfga__Contract_Term__c = 36;
        replacedConfig.Commercial_Config__c='Yes';
        replacedConfig.Quantity_Product_Configuration__c=1;
        replacedConfig.cscfga__total_one_off_charge__c=100;
        replacedConfig.cscfga__total_recurring_charge__c=100;
        insert replacedConfig;
        
        for (Integer i=0; i < =4; i++){
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(ngucPDList[0].id);
            config.cscfga__Product_Basket__c = lstBasket[0].id;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Commercial_Config__c='Yes';
            config.Quantity_Product_Configuration__c=1;
            config.cscfga__total_one_off_charge__c=100;
            config.cscfga__total_recurring_charge__c=100;
            if(i == 0)     
            {
                config.cscfga__Product_Definition__c = ngucPDList[0].id;
                config.name='Business Calling';
                config.Type__c = 'New';
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Business Calling';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Product_Configuration__c =null;
            }
            system.debug('config::' + i +' ' +  config);
            
            if(i == 1){
                config.name = 'Camera-Polycom EagleEye Mini Camera for VVX Handset';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Accessory';
                config.cscfga__total_recurring_charge__c = 0;
                config.cscfga__Product_Definition__c=ngucPDList[1].Id;
            }
            
            if(i==2)
            {
                config.name = 'IADs-OneAccess One100 (8 Port)';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 46.26;
                config.cscfga__Product_Definition__c=ngucPDList[2].Id;// EDGE-165831 - PD updates
            } 
            if(i==3)
            {
                config.name = 'IADs-OneAccess One100 (8 Port)';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 0;//46.26;
                config.cscfga__Product_Definition__c=ngucPDList[2].Id;// EDGE-165831 - PD updates
            } 
            
            if(i==4)
            {
                config.name = 'IADs-OneAccess One100 (8 Port)_Cancel';
                config.Type__c = 'Cancel'; 
                config.Marketable_Offer__c = listOfOffers[0].id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 0;//46.26;
                config.cscfga__Product_Definition__c=ngucPDList[2].Id;// EDGE-165831 - PD updates
                config.csordtelcoa__Replaced_Product_Configuration__c=replacedConfig.id;
            } 
            prodConfigList.add(config); 
            
        }
        insert prodConfigList;
        system.debug('prodConfigList0::' + prodConfigList[4]);
        
        List<cspmb__Price_Item__c> commercialProdList= new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c priceItem00 = new cspmb__Price_Item__c();
        priceItem00.Name = 'Individual line - standard calling plan';
        priceItem00.cspmb__Recurring_Charge__c = 45;
        priceItem00.Billing_Description__c='Individual line - standard calling plan';
        priceItem00.Mode__c='Individual Line';
        priceItem00.Plan__c='Standard';
        commercialProdList.add(priceItem00);
        
        cspmb__Price_Item__c priceItem01 = new cspmb__Price_Item__c();
        priceItem01.Name = 'Unified Communication Device';
        priceItem01.cspmb__Recurring_Charge__c = 13.70;
        priceItem01.Billing_Description__c='Cisco 8851 MPP IP phone repayment';
        commercialProdList.add(priceItem01);
        
        cspmb__Price_Item__c priceItem02 = new cspmb__Price_Item__c();
        priceItem02.Name = 'Auto Attendants';
        priceItem02.cspmb__Contract_Term__c = '12';
        priceItem02.Contract_Type__c = 'Rental';
        priceItem02.Charge_Id__c=' DMCAT_RecurringCharge_000814';
        priceItem02.Unit_Of_Measure__c='per Auto Attendant';
        priceItem02.Billing_Description__c = 'Virtual Receptionist';
        
        commercialProdList.add(priceItem02);
        insert commercialProdList;
        
        List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        cscfga__Attribute_Definition__c ad00 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngucPDList[0].Id,
            Snapshot_Attribute_Value_Field__c = 'ABC',
            Name = 'AD1'
        );
        attDefList.add(ad00);
        cscfga__Attribute_Definition__c ad01 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = ngucPD01.Id,
                Name = 'Quantity',
                Snapshot_Attribute_Value_Field__c = 'Quantity__c',
                Snapshot_Attribute_Fields__c = 'Quanity__c'
            ); 
         attDefList.add(ad01);
        cscfga__Attribute_Definition__c ad02 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = ngucPD01.Id,
                Name = 'OC',
                Snapshot_Attribute_Value_Field__c = 'OC',
                Snapshot_Attribute_Fields__c = 'OC'
            ); 
         attDefList.add(ad02);
         cscfga__Attribute_Definition__c ad03 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = ngucPD01.Id,
                Name = 'ContractType',
                Snapshot_Attribute_Value_Field__c = 'Unit_Of_Measure__c',
                Snapshot_Attribute_Fields__c = 'Unit_Of_Measure__c'
            ); 
         attDefList.add(ad03);
        
        cscfga__Attribute_Definition__c ad04 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = ngucPDList[1].Id,
                Name = 'EarlyTerminationCharge',
                Snapshot_Attribute_Value_Field__c = 'GSTExcl_TotalETC__c',
                Snapshot_Attribute_Fields__c = 'GSTExcl_TotalETC__c'
            ); 
         attDefList.add(ad04);
        insert attDefList;
        
        cscfga__Attribute__c att00 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[0].Id,
            Name = 'callingPlans',
            cscfga__Value__c = commercialProdList[0].id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att00);
         cscfga__Attribute__c att01 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[1].Id,
                Name = 'Quantity',
                cscfga__Value__c = '1',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[1].Id
            );
        attList.add(att01);
        cscfga__Attribute__c att02 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[1].Id,
                Name = 'OC',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[2].Id
            );
        attList.add(att02);
        cscfga__Attribute__c att03 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[1].Id,
                Name = 'TC',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[2].Id
            );
        attList.add(att03);
        cscfga__Attribute__c att04 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[1].Id,
                Name = 'Type',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[2].Id
            );
        attList.add(att04);
        cscfga__Attribute__c att05 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[1].Id,
                Name = 'OperationalHours',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[2].Id
            );
        attList.add(att05);
        cscfga__Attribute__c att06 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[2].Id,
                Name = 'ContractType',
                cscfga__Value__c = commercialProdList[2].id,
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
          attList.add(att06);
        cscfga__Attribute__c att07 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[2].Id,
                Name = 'ContractTypeString',
                cscfga__Value__c = 'Hardware Repayment',
                cscfga__is_active__c = true,
                cscfga__Display_Value__c = 'Hardware Repayment'
                //cscfga__Attribute_Definition__c = attDefList[16].Id
            );
        attList.add(att07);
        cscfga__Attribute__c att08 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[2].Id,
                Name = 'test',
                cscfga__Value__c = '1',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
          attList.add(att08);
        cscfga__Attribute__c att09 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[3].Id,
                Name = 'ContractTypeString',
                cscfga__Value__c = 'Hardware Repayment',
                cscfga__is_active__c = true,
                cscfga__Display_Value__c = 'Hardware Repayment'
                //cscfga__Attribute_Definition__c = attDefList[16].Id
            );
        attList.add(att09);
        cscfga__Attribute__c att10 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[3].Id,
                Name = 'test',
                cscfga__Value__c = '1',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
          attList.add(att10);
        cscfga__Attribute__c att11 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[3].Id,
                Name = 'ContractType',
                cscfga__Value__c = commercialProdList[2].id,
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
          attList.add(att11);
        cscfga__Attribute__c att12 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[3].Id,
                Name = 'RedeemFund',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
        attList.add(att12);
        
        cscfga__Attribute__c att13 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[4].Id,
                Name = 'ContractType',
                cscfga__Value__c = commercialProdList[1].id,
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
        attList.add(att13);
        
        cscfga__Attribute__c att14 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[4].Id,
                Name = 'EarlyTerminationCharge',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[4].Id
            );
        attList.add(att14);
        
        cscfga__Attribute__c att15 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[4].Id,
                Name = 'RedeemFund',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[4].Id
            );
        attList.add(att15);
        
        
        
        insert attList;
        
    }
    @isTest static void getTCServicesTest(){
            TCDataHandlerTest testclass= new TCDataHandlerTest();
            testclass.setup();
            Test.startTest();
            cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
            
            String basketId = '';
            if(prodBasket !=null)
                basketId = prodBasket.id;
            system.debug('basketId::' + basketId);
            TCDataHandler handler = new TCDataHandler();
            List<Map<String,Object>> rows = handler.getTCServices(basketId,new Map<String,String>{'Query_Type'=>'BSTCServices','Type'=>'New'});
            System.debug('-----rows'+rows.isEmpty());
            System.debug('-----rows'+rows); 
            Test.stopTest();
            system.assert(rows[0].get('UserMode') =='<b>Adaptive Collaboration Calling Plan:</b> Individual Line - Standard');
    
    }
    
    @isTest static void getTelstraCollaborationPSTest(){//EDGE-117631
        TCDataHandlerTest testclass= new TCDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TCDataHandler handler = new TCDataHandler();
        List<Map<String,Object>> rows = handler.getTelstraCollaborationPS(basketId,new Map<String,String>{'Query_Type'=>'Test','Offer_Name'=>'DMCAT_ProductSpecification_000935'});
        System.debug('rows_getTelstraCollaborationPSTest@@::' + rows[0].get('GSTIncl_Total_Onceoff_Charges'));
        Test.stopTest();
        system.assert(rows[0].get('GSTIncl_Total_Onceoff_Charges') == '11.00');
        
    } 
    
    @isTest static void getngUCRCDevicesRepayTestSuccess(){
        TCDataHandlerTest testclass= new TCDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TCDataHandler handler = new TCDataHandler();
        List<Map<String,Object>> rows = handler.getngUCDevicesRCRepayment(basketId,new Map<String,String>{'Query_Type'=>'ngUCDevicesRepayment','Type'=>'New'});
        System.debug('rows@@::' + rows); 
        Test.stopTest();
        System.assert(rows[0].get('Unit_Of_Measure')=='per accessory');
    }   
    
    @isTest static void getngUCOCDevicesTestSuccess(){
        TCDataHandlerTest testclass= new TCDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         TCDataHandler handler = new TCDataHandler();
         List<Map<String,Object>> rows = handler.getngUCDevicesOC(basketId,new Map<String,String>{'Query_Type'=>'ngUCDevicesOCDetails','Type'=>'New'});
         Test.stopTest();
         system.debug('rows_getngUCOCDevicesTestSuccess::'+rows[0].get('Unit_Of_Measure'));
         System.assert(rows[0].get('Unit_Of_Measure')=='per accessory');
    }
    
    @isTest static void getngUCCancelTestSuccess(){
        TCDataHandlerTest testclass= new TCDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TCDataHandler handler = new TCDataHandler();
        List<Map<String,Object>> rows = handler.getngUCCancel(basketId,new Map<String,String>{'Query_Type'=>'ngUCCancelDetails','Type'=>'Cancel'});
        Test.stopTest();
        system.debug('rows::'+rows);
        system.debug('rows::'+rows[0].get('GSTIncl_TotalETC'));
        
        system.assert(rows[0].get('GSTIncl_TotalETC') ==110.00);
    } 
    
    @isTest static void getCalculateRemainingTermngUCSuccess(){
         TCDataHandlerTest testclass= new TCDataHandlerTest();
         Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
         String BillingAccountJson = '{"code":200,"status":200,"message":"Success","billingAccount":{"billingAccountNumber":700000506340,"status":"Active","startDate":"2019-12-18T00:00:00Z","billCycleDay":1,"paymentTerms":30,"rouCode":"test22","currencyCode":"AUD","language":"English","companyName":"Eureka_18/12/2019_ZVX","billingAddress":{"address":"40 BOND ST, abc dd","locality":"KINGS MEADOWS","postcode":"7249","state":"TAS","country":"Australia"}}}';
         //String BillingAccountJson = '[billingAccount=BillingAccount:[billCycleDay=1, billingAccountNumber=700000506340, billingAccountOwner=null, billingAddress=BillingAddress:[address=40 BOND ST, abc dd, country=Australia, locality=KINGS MEADOWS, postcode=7249, state=TAS], currencyCode=AUD, language=English, paymentTerms=30, rouCode=test22, startDate=2019-12-18T00:00:00Z, status=Active], code=200, correlationId=null, errors=null, message=Success, status=200]';
         BillingAccountDetailsDTO BillingAccDTO = BillingAccountDetailsDTO.parse(BillingAccountJson);
         testclass.setup();
         Test.startTest();
         system.debug('BillingAccountDetailsDTO@@::' + BillingAccDTO);
         Date iniActDat = Date.valueOf('2018-12-30 00:00:00');
         Date disDate = Date.valueOf('2019-12-30 00:00:00');
         Integer conTerm = 24;
         TCDataHandler handler = new TCDataHandler();
         //List<Map<String,Object>> rows = handler.getngUCDevicesRC(basketId,new Map<String,String>{'Query_Type'=>'ngUCDevicesRCDetails','Type'=>'New'});
         Integer rowsTerms = TCDataHandler.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
         //rowsTerms = handler.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
         system.debug('rowsTerms::' + rowsTerms);
         Test.stopTest();
         System.assert(rowsTerms==12);
    } 
}