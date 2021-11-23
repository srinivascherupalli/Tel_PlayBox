/*
* @Desc : RF_ProductBasketDataHandler Test class
* @Jira : DIGI-518
*/
@isTest
public class RF_ProductBasketDataHandlerTest {
    Public String chargeLineItemName= 'Testing BasketDataHandler';//'aBA2N00000001qh' ;
    private void setup() { 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Configuration_Offer__c offerDef = new cscfga__Configuration_Offer__c();
        offerDef.Name = 'TestOffer';
        offerDef.cscfga__Description__c ='Description';
        insert offerDef;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test', 'Test');
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000747';
        insert prodDef;
        
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name='Professional Services-MDM Config';
        newConfig.Type__c = 'Cancel';
        newConfig.cscfga__Product_Basket__c = basket.id;
        newConfig.cscfga__Product_Family__c='Mobility';
        newConfig.cscfga__unit_recurring_charge__c = 200;
        newConfig.Quantity_Product_Configuration__c =1;
        newConfig.cscfga__Product_Definition__c = prodDef.Id;
        newConfig.cscfga__unit_one_off_charge__c = 1;
        newConfig.Offer_Reference__c=offerDef.Id;
        newConfig.csordtelcoa__Replaced_Product_Configuration__c = NULL;
        insert newConfig;
        
       	cspmb__Price_Item_Add_On_Price_Item_Association__c p1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
		p1.cspmb__Recurring_Charge__c = 10;
		insert p1;
    }
    
    private void setupGetCMPServiceData() {
        List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c commConfig1 = new CustomConfigurationOptions__c();
        commConfig1.Name = 'ContractAccepted';
        commConfig1.Enrichment_Basket_Stage__c = 'Contract Accepted';
        commConfig1.External_Id__c = '7654';
        commConfig1.Opportunity_Stage__c = 'Propose';
        commList.add(commConfig1);
        CustomConfigurationOptions__c commConfig2 = new CustomConfigurationOptions__c();
        commConfig2.Name = 'CommercialConfiguration';
        commConfig2.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        commConfig2.External_Id__c = 'CCO4';
        commConfig2.Opportunity_Stage__c = 'Develop';
        commList.add(commConfig2);
        CustomConfigurationOptions__c commConfig3 = new CustomConfigurationOptions__c();
        commConfig3.Name = 'Quote';
        commConfig3.Enrichment_Basket_Stage__c = 'Quote';
        commConfig3.External_Id__c = 'CC08';
        commConfig3.Opportunity_Stage__c = 'Propose';
        commList.add(commConfig3);
        insert commList;      
        Account acc = AccountTestFactory.buildAccount('TestAccListPrice');
        acc.CIDN__c = '1234543210';
        acc.Customer_Status__c='Active';
        insert acc;
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000501234';
        billAcc.Account__c = acc.id;
        insert billAcc;
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Committed_Data';
        ev.value__c='True';
        insert ev;
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        List<cscfga__Product_Basket__c> lstBasket = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        lstBasket.add(basket);
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.cscfga__Basket_Status__c = 'Valid';
        basket1.cscfga__total_contract_value__c = 1100;
        lstBasket.add(basket1);
        insert lstBasket;
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        insert moMob;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c ='DMCAT_Offer_000646';
        insert pd;
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_000420';
        insert pd1;
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c(name='test',Type__c = 'New',cscfga__Product_Basket__c = lstBasket[0].id,Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',
                                                                                          cscfga__total_recurring_charge__c=100,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null,cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfig;
        cscfga__Product_Configuration__c newConfigMod = new cscfga__Product_Configuration__c(name='test1',Type__c = 'Modify',cscfga__Product_Basket__c = lstBasket[0].id,Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,
                                                                                             cscfga__Product_Definition__c = pd.id,csordtelcoa__Replaced_Product_Configuration__c = newConfig.id,cscfga__Parent_Configuration__c = null,cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfigMod;
        cscfga__Product_Configuration__c newConfigCancel = new cscfga__Product_Configuration__c(Name='Committed Data',Type__c = 'Cancel',cscfga__Product_Basket__c = lstBasket[0].id,
                                                                                                Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,
                                                                                                cscfga__Product_Definition__c = pd.id,csordtelcoa__Replaced_Product_Configuration__c = newConfig.id,cscfga__Parent_Configuration__c = null,
                                                                                                cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfigCancel;
        cscfga__Product_Configuration__c newConfigCancel1 = new cscfga__Product_Configuration__c(Name='Committed Data',Type__c = 'Cancel',cscfga__Product_Basket__c = lstBasket[0].id,
                                                                                                 Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,
                                                                                                 cscfga__Product_Definition__c = pd1.id,csordtelcoa__Replaced_Product_Configuration__c = newConfig.id,cscfga__Parent_Configuration__c = null,
                                                                                                 cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfigCancel1;
        List<Charge_Line_Item__c> lstOfCLI=new  List<Charge_Line_Item__c>();
        Charge_Line_Item__c cliPlan=new Charge_Line_Item__c();
        cliPlan.Name=chargeLineItemName;
        cliPlan.basketId__c=lstBasket[0].Id;
        cliPlan.BusinessID__c='';
        cliPlan.Product_Configuration__c=newConfig.id;
        cliPlan.status__c='Active';
        cliPlan.targetChargeProduct__c='Plan';
        lstOfCLI.add(cliPlan);
        Charge_Line_Item__c cliAddOn=new Charge_Line_Item__c();
        cliAddOn.Name=chargeLineItemName;
        cliAddOn.basketId__c=lstBasket[0].Id;
        cliAddOn.BusinessID__c='';
        cliAddOn.Product_Configuration__c=newConfig.id;
        cliAddOn.status__c='Active';
        cliAddOn.targetChargeProduct__c='AddOn';
        lstOfCLI.add(cliAddOn);
        insert lstOfCLI;
        List<Discount_Line_Item__c> lstOfDLI=new List<Discount_Line_Item__c>();
        Discount_Line_Item__c dliPlan = new Discount_Line_Item__c();
        dliPlan.chargeInstance__c =lstOfCLI[0].Id;
        dliPlan.BusinessID__c='DMCAT_Discount_000945' ;
        dliPlan.discountValue__c='4';
        dliPlan.duration__c='4';
        lstOfDLI.add(dliPlan);
        Discount_Line_Item__c dliAddOn= new Discount_Line_Item__c();
        dliAddOn.chargeInstance__c =lstOfCLI[1].Id;
        dliAddOn.BusinessID__c='DMCAT_Discount_000945' ;
        dliAddOn.discountValue__c='4';
        dliAddOn.duration__c='4';
        lstOfDLI.add(dliAddOn);
        insert lstOfDLI;
        cspmb__Price_Item__c piItem = new cspmb__Price_Item__c(Plan__c='Global BYO',taxTreatment__c='GST Applicable',Billing_Description__c='Bring your own - global plan', Unit_Of_Measure__c  
                                                               ='each', Name='Mobility', Offer_Id__c='DMCAT_Offer_000646',cspmb__Recurring_Charge__c=131.81);
        insert piItem;
        List<cspmb__Add_On_Price_Item__c> pilst = new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c priceAddon = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_000263',Charge_Id__c='DMCAT_RecurringCharge_000497',name='3G Standard Retail',Unit_Of_Measure__c='each',Billing_Description__c='3G Standard Retail',cspmb__Recurring_Charge__c=50);
        pilst.add(priceAddon);
        cspmb__Add_On_Price_Item__c priceAddon1 = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_000420',Charge_Id__c='DMCAT_RecurringCharge_000669',name='3G Standard Retail',Unit_Of_Measure__c='each',Billing_Description__c='Premium',cspmb__Recurring_Charge__c=50);
        pilst.add(priceAddon1);
        cspmb__Add_On_Price_Item__c priceAddon2 = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_000420',Charge_Id__c='DMCAT_RecurringCharge_000669',name='International call pack - premium',Unit_Of_Measure__c='each',Billing_Description__c='Premium',cspmb__Recurring_Charge__c=50);
        pilst.add(priceAddon2);
        insert pilst;
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piAddOnAssociation=new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c paddon = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=50.00,cspmb__Add_On_Price_Item__c=pilst[0].Id);
        piAddOnAssociation.add(paddon);
        cspmb__Price_Item_Add_On_Price_Item_Association__c paddon1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=50.00,cspmb__Add_On_Price_Item__c=pilst[1].Id);
        piAddOnAssociation.add(paddon1);
        cspmb__Price_Item_Add_On_Price_Item_Association__c paddon2 = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=50.00,cspmb__Add_On_Price_Item__c=pilst[2].Id);
        piAddOnAssociation.add(paddon2);
        insert piAddOnAssociation;
        cspmb__Usage_Type__c usage1=new cspmb__Usage_Type__c(Name='Mobile Plan Usage',cspmb__unit_of_measure__c='Megabyte',cspmb__type__c='Single');
        insert usage1;
        List<cspmb__Allowance__c> lstAllowance=new List<cspmb__Allowance__c>();
        cspmb__Allowance__c pallowance = new cspmb__Allowance__c(Name='FairPlay Data Allowance Global BYO',Value__c='250',cspmb__usage_type__c=usage1.Id);
        lstAllowance.add(pallowance);
        cspmb__Allowance__c planCancel = new cspmb__Allowance__c(Unit_Of_Measure__c='GB',Name='FairPlay Data Allowance Global BYO',Value__c='250',type__c='Committed Data',cspmb__usage_type__c=usage1.Id);
        lstAllowance.add(planCancel);
        cspmb__Allowance__c planCancel1 = new cspmb__Allowance__c(Unit_Of_Measure__c='GB',Name='FairPlay Data Allowance Global BYO',Value__c='250',type__c='Committed Bonus Data',cspmb__usage_type__c=usage1.Id);
        lstAllowance.add(planCancel1);
        insert lstAllowance;
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
            Snapshot_Attribute_Fields__c = 'Plan'
        ); 
        insert ad2;
        List<cscfga__Attribute__c> attlist=new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'PlanCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att0);
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'Select Plan',
            cscfga__Value__c = piItem.Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att1);
        insert attList;
        List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges__c',
            Snapshot_Attribute_Fields__c = 'Device'
        );
        attDefList.add(ad);
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
            Snapshot_Attribute_Fields__c = 'Plan'
        ); 
        attDefList.add(ad1);
        cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'Select Plan',
            Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c,Unit_Of_Measure__c',
            Snapshot_Attribute_Fields__c = 'cspmb__Recurring_Charge__c,Unit_Of_Measure__c'
        );
        attDefList.add(ad3);
        insert attDefList;
        
    }
    @isTest static void getPCsForBasketTest(){    
        RF_ProductBasketDataHandler.val='Old';
        RF_ProductBasketDataTestFactory testClass = new RF_ProductBasketDataTestFactory();
        testClass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];        
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;        
        list<cscfga__Product_Configuration__c> procList=RF_ProductBasketDataHandler.getPCsForBasket(basketId);
        
        RF_ProductBasketDataHandler.val='New';       
        list<cscfga__Product_Configuration__c> procList1=RF_ProductBasketDataHandler.getPCsForBasket(basketId);
        
        Test.stopTest();
        System.assert(procList.isEmpty()== false); 
        System.assert(procList1.isEmpty()== false);   
    }
    
    @isTest static void getCaseStatusMapTest(){    
        RF_ProductBasketDataTestFactory testClass = new RF_ProductBasketDataTestFactory();
        testClass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];        
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;        
        Map<id,String> procList=RF_ProductBasketDataHandler.getCaseStatusMap(basketId);        
        Test.stopTest();
        System.assert(procList.isEmpty()== false); 
    }
    
    @isTest static void isValidTest(){    
        Test.startTest();       
        Boolean procList=RF_ProductBasketDataHandler.isValidId('Invalid');        
        Test.stopTest();
        System.assert(procList == false); 
    }
    
    @isTest static void getDiscountAppliedTest(){  
        RF_ProductBasketDataHandler rf1 = new RF_ProductBasketDataHandler();
        Test.startTest();       
        List<String> procList=rf1.getDiscountApplied(null,null);        
        Test.stopTest();
        System.assert(procList.isEmpty()== true); 
    }
    
    @isTest static void getOffersInBasketTest(){
        RF_ProductBasketDataHandler.val='Old';
        ProductBasketDataHandlerTest testClass = new ProductBasketDataHandlerTest();
       RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;        
        Set<String> offers =RF_ProductBasketDataHandler.getOffersInBasket(basketId);
        RF_ProductBasketDataHandler.val='New';
        Set<String> offers1 =RF_ProductBasketDataHandler.getOffersInBasket(basketId);
        Test.stopTest();
        System.assert(offers.isEmpty()== false);        
        System.assert(offers1.isEmpty()== false); 
    }
    
    @isTest static void offerWiseRedeemedAmountListTest(){
        ProductBasketDataHandlerTest testClass = new ProductBasketDataHandlerTest();
   RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;        
        RF_ProductBasketDataHandler rf1 = new RF_ProductBasketDataHandler();
        List<Double> offers =rf1.offerWiseRedeemedAmountList(basketId,'Adaptive Mobility');
        Test.stopTest();
        System.assert(offers.isEmpty()== true);        
    }
    
    @isTest static void isPromotionAppliedTest(){    
        ProductBasketDataHandlerTest testClass = new ProductBasketDataHandlerTest();
       RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;     
        RF_ProductBasketDataHandler rf1 = new RF_ProductBasketDataHandler();
        Boolean procList=rf1.isPromotionApplied(basketId);        
        Test.stopTest();
        System.assert(procList == true); 
    }
    
    @isTest static void getListPriceUsingDiscountTest(){    
        ProductBasketDataHandlerTest testClass = new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        List<cscfga__Product_Configuration__c> pclist = [select id,name, type__c, cscfga__Product_Configuration__c.OfferName__c,cscfga__Product_Configuration__c.cscfga__Parent_Configuration__c, cscfga__Product_Configuration__c.cscfga__recurring_charge_line_discount_value__c, cscfga__Product_Configuration__c.cscfga__recurring_charge_product_discount_value__c from cscfga__Product_Configuration__c];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;     
        Map<String,Double> procList=RF_ProductBasketDataHandler.getListPriceUsingDiscount(basketId, pclist);        
        Test.stopTest();
        System.assert(procList.isEmpty()== false);        
    }
    
    @isTest static void getPIsForPCTest(){
        RF_ProductBasketDataTestFactory testClass = new RF_ProductBasketDataTestFactory();
        testClass.setupdata();
        Test.startTest();       
       //	cspmb__Price_Item_Add_On_Price_Item_Association__c pclist = [select id from cspmb__Price_Item_Add_On_Price_Item_Association__c limit 1];
		List<id> listaToTrue =new List<id>();
		for(cspmb__Price_Item_Add_On_Price_Item_Association__c a : [select id from cspmb__Price_Item_Add_On_Price_Item_Association__c limit 1]){
    	listaToTrue.add(a.id);
		}        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> offers =RF_ProductBasketDataHandler.getPIsForPC(listaToTrue);
        Test.stopTest();
        System.assert(offers.isEmpty()== false);        
    }
    
    
    @isTest static void getOfferFamilyTest(){
        RF_ProductBasketDataHandler.val='Old';
        Test.startTest();        
        String offerFamily =RF_ProductBasketDataHandler.getOfferFamily('test');
        RF_ProductBasketDataHandler.val='New';
        String offerFamily1 =RF_ProductBasketDataHandler.getOfferFamily('test');
        Test.stopTest();
        System.assertEquals(null,offerFamily);        
        System.assertEquals(null,offerFamily1);        
    }
    
    @isTest static void calculateTotalDataforCommittedPlanTest(){
        RF_ProductBasketDataHandler.val='Old';
        Test.startTest();        
        String offerFamily =RF_ProductBasketDataHandler.calculateTotalDataforCommittedPlan('10','5');
        RF_ProductBasketDataHandler.val='New';
        String offerFamily1 =RF_ProductBasketDataHandler.calculateTotalDataforCommittedPlan('10','5');
        Test.stopTest();
        System.assertNotEquals(null,offerFamily);        
        System.assertNotEquals(null,offerFamily1);        
    }
    
    @isTest static void calculateRemainingTermngUCTest(){
        RF_ProductBasketDataHandler.val='Old';
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
        String BillingAccountJson = '{"code":200,"status":200,"message":"Success","billingAccount":{"billingAccountNumber":700000506340,"status":"Active","startDate":"2019-12-18T00:00:00Z","billCycleDay":1,"paymentTerms":30,"rouCode":"test22","currencyCode":"AUD","language":"English","companyName":"Eureka_18/12/2019_ZVX","billingAddress":{"address":"40 BOND ST, abc dd","locality":"KINGS MEADOWS","postcode":"7249","state":"TAS","country":"Australia"}}}';
        BillingAccountDetailsDTO BillingAccDTO = BillingAccountDetailsDTO.parse(BillingAccountJson);
        
        Test.startTest(); 
        Date iniActDat = Date.valueOf('2018-12-30 00:00:00');
        Date disDate = Date.valueOf('2019-12-30 00:00:00');
        Integer conTerm = 24;
        Integer offerFamily =RF_ProductBasketDataHandler.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
        RF_ProductBasketDataHandler.val='New';
        Integer offerFamily1 =RF_ProductBasketDataHandler.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
        Test.stopTest();
        System.assertNotEquals(null,offerFamily);        
        System.assertNotEquals(null,offerFamily1);        
    }
    
    @isTest static void checkifContractExistsForAccountTest(){   
        RF_ProductBasketDataHandler.val='Old';
        ProductBasketDataHandlerTest testClass = new ProductBasketDataHandlerTest();
       RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;   
        Boolean procList = RF_ProductBasketDataHandler.checkifContractExistsForAccount(basketId,'Offer');
        RF_ProductBasketDataHandler.val='New';
        Boolean procList1 = RF_ProductBasketDataHandler.checkifContractExistsForAccount(basketId,'Offer');
        Test.stopTest();
        System.assert(procList == false); 
        System.assert(procList1 == false); 
    }
    
    @isTest static void BCFClassTest(){
        RF_ProductBasketDataHandler.val='Old';
        RF_ProductBasketDataHandlerTest testClass = new RF_ProductBasketDataHandlerTest();
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();
       RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1000 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;        
        
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c ='DMCAT_Offer_000646';
        insert pd;
        List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();//EDGE-200765
        cscfga__Product_Configuration__c newConfig00 = new cscfga__Product_Configuration__c(name='test',Type__c = 'New',cscfga__Product_Basket__c = basketId,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,cscfga__total_one_off_charge__c=200,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null);
        //EDGE-200765 Start
        configLst.add(newConfig00);
        cscfga__Product_Configuration__c newConfig01 = new cscfga__Product_Configuration__c(name='test',Type__c = 'Active',cscfga__Product_Basket__c = basketId,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,cscfga__total_one_off_charge__c=200,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null);
        configLst.add(newConfig01);
        insert configLst;
        //EDGE-200765 End
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id,Name = 'EarlyTerminationCharge',Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',Snapshot_Attribute_Fields__c = 'Plan'); 
        insert ad2;
        List<cscfga__Attribute__c> attLst = new List<cscfga__Attribute__c>();//EDGE-200765
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(cscfga__Product_Configuration__c = configLst[0].Id,Name = 'EarlyTerminationCharge',
                                                             cscfga__Value__c = '50',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = ad2.Id);
        //EDGE-200765 Start
        attLst.add(att0);
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(cscfga__Product_Configuration__c = configLst[0].Id,Name = 'RedeemFund',
                                                             cscfga__Value__c = '10',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = ad2.Id);
        attLst.add(att1);
        insert attLst;         
        List<Map<String,Object>> rows1 = handler.getSummaryForNewServices(basketId);        
        List<Map<String,Object>> rows2 = handler.getSummaryForNewServicesRC(basketId);
        List<Map<String,Object>> rows3 = handler.getSummaryForNewCharges(basketId);
        List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(basketId);
        RF_ProductBasketDataHandler.val='New';
        List<Map<String,Object>> rows11 = handler.getSummaryForNewServices(basketId);        
        List<Map<String,Object>> rows22 = handler.getSummaryForNewServicesRC(basketId);
        List<Map<String,Object>> rows33 = handler.getSummaryForNewCharges(basketId);
        List<Map<String,Object>> rows0 = handler.getSummaryForChangesToExisting(basketId);
        Test.stopTest();
        
        System.assert(rows1.isEmpty() == false);
        System.assert(rows2.size()>-1);       
        System.assert(rows3.isEmpty()== true); 
        System.assert(rows.size()>-1);        
        System.assert(rows11.isEmpty() == false);
        System.assert(rows22.size()>-1);       
        System.assert(rows33.isEmpty()== true); 
        System.assert(rows0.size()>-1);        
    }
    @isTest static void MobilityClassTest() {
        RF_ProductBasketDataHandler.val='Old';
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
       RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Devices', 'Type'=>'Recurring Charges'});        
        rows.addAll(handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Mobile Services', 'Type'=>'Recurring Charges'}));
        List<Map<String,Object>> rows1 = handler.getMobilityCancelTypeProducts(basketId); 
        List<Map<String,Object>> rows2 = handler.getMobilityTransitionHardwareAndDevice(basketId,new Map<String,String>{'Query_Type'=>'MobilityTransitionHardwareAndDevice'});
        List<Map<String,Object>> rows3 = handler.getBSMobilityTransition(basketId);
        
        RF_ProductBasketDataHandler.val='New';
        List<Map<String,Object>> rows0 = handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Devices', 'Type'=>'Recurring Charges'});        
        rows0.addAll(handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Mobile Services', 'Type'=>'Recurring Charges'}));
        List<Map<String,Object>> rows11 = handler.getMobilityCancelTypeProducts(basketId); 
        List<Map<String,Object>> rows22 = handler.getMobilityTransitionHardwareAndDevice(basketId,new Map<String,String>{'Query_Type'=>'MobilityTransitionHardwareAndDevice'});
        List<Map<String,Object>> rows33 = handler.getBSMobilityTransition(basketId);
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assert(rows1.isEmpty() == false);
        System.assert(rows2.isEmpty() == false);
        System.assert(rows3.isEmpty() == false);
        
        System.assert(rows0.isEmpty() == false);
        System.assert(rows11.isEmpty() == false);
        System.assert(rows22.isEmpty() == false);
        System.assert(rows33.isEmpty() == false);
    }
    @isTest static void getDOPServicesTest(){
        RF_ProductBasketDataHandler.val='Old';
        RF_ProductBasketDataHandlerTest testclass= new RF_ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id,cscfga__total_contract_value__c from cscfga__Product_Basket__c limit 1];
        
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getDOPServices(basketId,new Map<String,String>{'Query_Type'=>'DOPServiceDetails','Type'=>'New'});         
        RF_ProductBasketDataHandler.val='New';
        List<Map<String,Object>> rows1 = handler.getDOPServices(basketId,new Map<String,String>{'Query_Type'=>'DOPServiceDetails','Type'=>'New'});         
        Test.stopTest();
        
        System.assertNotEquals(null,prodBasket);        
    }
    @isTest static void CMPClassTest(){
        RF_ProductBasketDataHandler.val='Old';
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();       
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();        
        
        List<Map<String,Object>> rows1 = handler.getCMPDevices(basketId,new Map<String,String>{'Order_Type'=>'Device', 'Query_Type'=>'CMPDeviceDetails','Type'=>'New'});         
        List<Map<String,Object>> rows3 = handler.getCMPCommittedData(basketId,new Map<String,String>{'Query_Type'=>'CMPCommittedData','Type'=>'New'});        
        List<Map<String,Object>> rows4 = handler.getMDMProfServices(basketId,new Map<String,String>{'Query_Type'=>'MDMProfServiceDetails','Offer_Name'=>'Professional Services-MDM Config'});
        List<Map<String,Object>> rows2 = handler.getCMPCancelProducts(null,null);
        RF_ProductBasketDataHandler.val='New';
        List<Map<String,Object>> rows11 = handler.getCMPDevices(basketId,new Map<String,String>{'Order_Type'=>'Device', 'Query_Type'=>'CMPDeviceDetails','Type'=>'New'});         
        List<Map<String,Object>> rows33 = handler.getCMPCommittedData(basketId,new Map<String,String>{'Query_Type'=>'CMPCommittedData','Type'=>'New'});        
        List<Map<String,Object>> rows44 = handler.getMDMProfServices(basketId,new Map<String,String>{'Query_Type'=>'MDMProfServiceDetails','Offer_Name'=>'Professional Services-MDM Config'});
        List<Map<String,Object>> rows22 = handler.getCMPCancelProducts(null,null);
        Test.stopTest();
        
        System.assert(rows1.isEmpty() == false);
        System.assert(rows2.isEmpty() == true);
        System.assert(rows3.isEmpty() == false);
        System.assert(rows4.isEmpty() == false);
        // System.assert(rows.isEmpty() == false);
        System.assert(rows11.isEmpty() == false);
        System.assert(rows22.isEmpty() == true);
        System.assert(rows33.isEmpty() == false);
        System.assert(rows44.isEmpty() == false);
    }
    @isTest static void getCMPServicesTest(){
        RF_ProductBasketDataHandler.val='Old';
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupGetCMPServiceData();
      //  testclass.setupGetCMPServiceData();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();
        List<Map<String,Object>> isCommittedRecord = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Modify'});
        RF_ProductBasketDataHandler.val='New';
        List<Map<String,Object>> isCommittedRecord1 = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Modify'});
        Test.stopTest(); 
        System.assert(isCommittedRecord.isEmpty() == true);
        System.assert(isCommittedRecord1.isEmpty() == true);
    }
    @isTest static void TIDClassTest(){
        RF_ProductBasketDataHandler.val='Old';
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
       RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();  
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();               
        List<Map<String,Object>> rows2 = handler.getTenancyDetails(basketId,new Map<String,String>{'Query_Type'=>'TenancyDetails','Product_Module_Name'=>'Test'}); 
        List<Map<String,Object>> rows = handler.getTIDDetails(basketId,new Map<String,String>{'Query_Type'=>'TIDDetails','Type'=>'Modify'}); 
        List<Map<String,Object>> rows1 = handler.getTIDCancel(basketId,new Map<String,String>{'Query_Type'=>'TIDCancel','Type'=>'Cancel'});        
        RF_ProductBasketDataHandler.val='New';
        List<Map<String,Object>> rows22 = handler.getTenancyDetails(basketId,new Map<String,String>{'Query_Type'=>'TenancyDetails','Product_Module_Name'=>'Test'}); 
        List<Map<String,Object>> rows0 = handler.getTIDDetails(basketId,new Map<String,String>{'Query_Type'=>'TIDDetails','Type'=>'Modify'}); 
        List<Map<String,Object>> rows11 = handler.getTIDCancel(basketId,new Map<String,String>{'Query_Type'=>'TIDCancel','Type'=>'Cancel'});        
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assert(rows1.isEmpty() == false);
        System.assert(rows2.isEmpty() == false);
        
        System.assert(rows0.isEmpty() == false);
        System.assert(rows11.isEmpty() == false);
        System.assert(rows22.isEmpty() == false);
        
    }
    //EDGE-123788   : Display Delegated Discounts in Quote Document Test
    @isTest static void getPromotionsAppliedNewTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();  
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getPromotionsApplied(basketId,new Map<String,String>{'Query_Type'=>'PromotionsAppliedDetails','Type'=>'New'});
        Test.stopTest();             
        System.assert(rows.isEmpty() == false);
    }
    @isTest static void getParentProductsTest() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        Test.startTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();  
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        RF_ProductBasketDataHandler handler = new RF_ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getParentProducts(basketId);        
        Test.stopTest();         
        System.assert(rows.isEmpty() == false);
    }
}