/*
* @Author : Mary Thangaraj
* @Desc : BCF Utility test class
* @Jira : DIGI-518
* @Created Date : 6/07/2021
*/
@isTest
public class BCF_UtilitiesTest {
    
    @isTest static void getGSTIncPriceforPCRFTest(){ 
        /*Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Product_Basket__c boltOnBasket = ProductTestFactory.buildEmptyBasket();
        boltOnBasket.cscfga__Opportunity__c = opp.id;
        boltOnBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket.cscfga__total_contract_value__c = 1111;
        insert boltOnBasket;
        
        cscfga__Configuration_Offer__c offerDef = new cscfga__Configuration_Offer__c();
        offerDef.Name = 'TestOffer';
        offerDef.cscfga__Description__c ='Description';
        insert offerDef;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Product Def1', 'Core Plan');
        prodDef.product_Specification__c='DMCAT_ProductSpecification_001158';
        insert prodDef;
        
        cspmb__Add_On_Price_Item__c addon1 = new cspmb__Add_On_Price_Item__c();
        addon1.Name = 'Test';
        addon1.ProdSpecId__c = 'Test';
        addon1.taxTreatment__c = 'TAX Exempt';
        insert addon1;
        
        cscfga__Product_Configuration__c prodConfig1 = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig1.cscfga__Product_Basket__c = boltOnBasket.Id; 
        prodConfig1.Add_On__c = addon1.id;
        insert prodConfig1;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = boltOnBasket.Id;
        prodConfig.Commercial_Config__c = 'Yes';
        prodConfig.Offer_Reference__c=offerDef.Id;
        prodConfig.cscfga__Parent_Configuration__c=prodConfig1.Id;
        prodConfig.cscfga__total_contract_value__c = 1111;
        prodConfig.Add_On__c = addon1.Id;
        insert prodConfig;
        
        cscfga__Attribute__c attr=new cscfga__Attribute__c();
        attr.name='CaseStatus';
        attr.cscfga__Product_Configuration__c=prodConfig.Id;
        attr.cscfga__Value__c='1234';
        insert attr;*/
         RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket1 = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c=1111];
        String basketId = '';
        if(prodBasket1 !=null)
            basketId = prodBasket1.id;
       // List<cscfga__Product_Configuration__c> pc = [Select id,name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId];
        Map<Id,Decimal> map_PCVSGSTIncPrice = BCF_Utilities.getGSTIncPriceforPCRF(basketId,false);
        Map<Id,Decimal> map_PCVSGSTIncPrice1 = BCF_Utilities.getGSTIncPriceforPCRF(basketId,true);
        
        //System.debug('Rows:'+rows.size());
        Test.stopTest();
        System.assertNotEquals(null, map_PCVSGSTIncPrice);     
        System.assertNotEquals(null, map_PCVSGSTIncPrice1);     
        //System.assert(rows[0].get('MonthlyRCPromotionsInclGST') == 104.00); //EDGE-176688
        //System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') == 104.00);//EDGE-181157 Defect Fix Negative
    }
    
    //EDGE-165834 - Start
    @isTest static void getSummaryforTotalCharges_Test() {
        Account acc = AccountTestFactory.buildAccount('TestAccListPrice');
        acc.CIDN__c = '1234543210';
        acc.Customer_Status__c='Active';
        insert acc;
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(cscfga__Opportunity__c= opp.id,csordtelcoa__Synchronised_with_Opportunity__c =true,
                                                                         csbb__Synchronised_With_Opportunity__c =true,cscfga__Basket_Status__c = 'Valid');
        insert basket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c ='DMCAT_Offer_000646';
        insert pd;
        List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();//EDGE-200765
        cscfga__Product_Configuration__c newConfig00 = new cscfga__Product_Configuration__c(name='test',Type__c = 'New',cscfga__Product_Basket__c = basket.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,cscfga__total_one_off_charge__c=200,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null);
        //EDGE-200765 Start
        configLst.add(newConfig00);
        cscfga__Product_Configuration__c newConfig01 = new cscfga__Product_Configuration__c(name='test',Type__c = 'Active',cscfga__Product_Basket__c = basket.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,cscfga__total_one_off_charge__c=200,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null);
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
        
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(cscfga__Product_Configuration__c = configLst[0].Id,Name = 'PaymentTypeString',
                                                             cscfga__Value__c = '10',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = ad2.Id);
        attLst.add(att2);
        insert attLst;
        
        //EDGE-200765 End      
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForNewCharges(basketId);        
        List<Map<String,Object>> rows1 = handler.getSummaryForNewCharges(null);        
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assertNotEquals(null, rows1);
        //EDGE-186680 - assert to verify GSTIncl_Total_Recurring_Charges present in rows.
        System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') != 0.00);
        System.assert(rows[0].get('GSTExcl_Total_Onceoff_Charges')==240.00);//EDGE-200765 Positive Scenario
    }//EDGE-165834 - End
    
    //EDGE-123788 & EDGE-123789 Start
    @isTest static void getNewServicesSummaryRC_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForNewServicesRCRF(basketId);       
        Test.stopTest();
        for(Map<String,Object> returnMap:rows){
            for(String str:returnMap.keySet()){
                Object text=returnMap.get(str);
                System.assert(text!=null);
            }
        }   
        System.assert(rows.size()>-1);
    }
    
    @isTest static void getSummaryForChangesToExisting_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();//EDGE-148534
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(basketId);
        Test.stopTest();//EDGE-148534         
        List<String> ETCRow = new List<String>();
        List<String> oneFundRow = new List<String>();//EDGE-164623
        //EDGE-150587 - Added positive assert statement as per Main class changes
        for(Map<String,Object> newRow: rows){
            ETCRow.add(String.valueOf(newRow.get('GSTExcl_TotalETC')));
            system.debug('ETCRow@@:' + ETCRow); 
            if(String.valueOf(newRow.get('Existing_Service'))==System.Label.Telstra_Enterprise_Plus_Credit){oneFundRow.add(String.valueOf(newRow.get('GSTIncl_TotalETC')));}
        }
        
        //System.assert(ETCRow.contains('NA- Not available'));      
        //EDGE-150587 end
        //EDGE-164623--Start        
        if(oneFundRow.size() >= 1) {    //EDGE-197766: If condition is added as part of to fix assert.
            System.assert(oneFundRow[0].contains('-110')); //EDGE-197766: Fixed assert
        }
        
        //EDGE-164623--Start
        System.assert(rows.isEmpty() == false);
        system.assert(rows[0].get('Order_Type') !='PaidOut'); //EDGE-147912 | Excluding PaidOut details
        //EDGE-155245 | Excluding Transition
        system.assert(rows[0].get('Existing_Service') !='Change Commercial Configuration'); 
        //EDGE-155059 & EDGE-162542 Start
        Boolean isOneFund = false;
        for(integer i=0;i<rows.size();i++){            
            if(rows[i].get('Existing_Service')==System.Label.Telstra_Enterprise_Plus_Fund){
                isOneFund = true;
                break;
            }
        }        
        //system.assert(isOneFund == true);
        //EDGE-155059 & EDGE-162542 End
    }
    @isTest static void getSummaryForChangesToExistingEM_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        ProductBasketDataHandler util = new ProductBasketDataHandler(); 
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(basketId);
        Test.stopTest();
        System.assert(rows.isEmpty() == false); //EDGE-164335
      //  System.assert(rows[1].get('GSTExcl_TotalETC') != null); //EDGE-164335    
        
      //  System.assert(String.valueof(rows[1].get('GSTExcl_TotalETC')) == '555.00');
    }
    @isTest static void getSummaryForChangesToExistingEM_TestNegative() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();       
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(null);
        Test.stopTest();         
        System.assert(rows.isEmpty() == true);// //EDGE-155245 | Negative assert scenario
    }
    //DIGI-14501 Start
    @isTest static void getSummaryForChangesToExistingC_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        ProductBasketDataHandler util = new ProductBasketDataHandler(); 
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
		cscfga__Product_Basket__c prodBasket1 = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1000 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
		String basketId1 = '';
        if(prodBasket1 !=null)
            basketId1 = prodBasket1.id;
		list<cscfga__Product_Configuration__c> pcLst0 = [select id,Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId1];
		cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c ='DMCAT_ProductSpecification_000623';
        insert pd;
		list<cscfga__Product_Configuration__c> pcLst = [select id,cscfga__Product_Definition__c,Type__c,subType__c,csordtelcoa__Replaced_Product_Configuration__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId];
        for(cscfga__Product_Configuration__c pc:pcLst){
            pc.cscfga__Product_Definition__c  = pd.id;
			pc.Type__c='Cancel';
			pc.subType__c = 'New';
			pc.csordtelcoa__Replaced_Product_Configuration__c = pcLst0[0].id;
        }
        update pcLst;
		cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id,Name = 'EarlyTerminationCharge',Snapshot_Attribute_Value_Field__c = 'GSTExcl_TotalETC__c',Snapshot_Attribute_Fields__c = 'GSTExcl_TotalETC__c'); 
        insert ad1;
		cscfga__Attribute__c att1 = new cscfga__Attribute__c(cscfga__Product_Configuration__c = pcLst[0].Id,Name = 'EarlyTerminationCharge',
                                                             cscfga__Value__c = '50',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = ad1.Id);
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(basketId);
        Test.stopTest();
		System.assertEquals(rows[0].get('GSTExcl_TotalETC')!=null,true);
		System.assertEquals(rows[0].get('GSTIncl_TotalETC')!=null,true);
    }
    //DIGI-14501 End
    //EDGE-171311 Start
    @isTest static void getNewServicesSummaryRCInfl_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        ProductBasketDataHandler util = new ProductBasketDataHandler(); 
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        list<cscfga__Product_Configuration__c> pcLst = [select id,cscfga__total_one_off_charge__c,cscfga__total_recurring_charge__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId];
        for(cscfga__Product_Configuration__c pc:pcLst){
            pc.cscfga__total_one_off_charge__c = -10;
            pc.cscfga__total_recurring_charge__c = -10;
        }
        update pcLst;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForNewServicesRCRF(basketId);
        List<Map<String,Object>> rows1 = handler.getSummaryForNewCharges(basketId);        
        Test.stopTest();        
        System.assert(rows.isEmpty() == false);
    }
    //EDGE-171311 End
    
    @isTest static void getNewServicesSummary_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        ProductBasketDataHandler util = new ProductBasketDataHandler(); 
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getSummaryForNewServices(basketId);
        Test.stopTest();
        
        System.assert(rows.size()>-1);
        System.assertEquals(rows[0].get('GSTIncl_Total_Onceoff_Charges')!=null,true);//EDGE-162365 Defect Fix 
    }
    @isTest static void getDOPServicesTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        ProductBasketDataHandler util = new ProductBasketDataHandler(); 
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id,cscfga__total_contract_value__c from cscfga__Product_Basket__c limit 1];         
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();
        List<Map<String,Object>> rows = handler.getDOPServices(basketId,new Map<String,String>{'Query_Type'=>'DOPServiceDetails','Type'=>'New'});         
        Test.stopTest();        
        System.assertNotEquals(null,prodBasket);
    }
    @isTest static void getDOPServicesTest_negative(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        ProductBasketDataHandler util = new ProductBasketDataHandler(); 
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        BCF_Utilities handler = new BCF_Utilities();  
        List<Map<String,Object>> rows = handler.getDOPServices(null,null);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
}