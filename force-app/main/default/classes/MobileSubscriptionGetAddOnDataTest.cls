/*****************************************************************
Author : Venkata Ramanan G
Created Date : 25-07-2019 
Description : Test Classes for MobileSubscriptionGetAddOnData & SolutionGetPricingRecords class.
Version History : 

Version             Change                     Owner
1.0                Created                    Venkata Ramanan G
2.0             EDGE-160037                   Shubhi
*****************************************************************/

@isTest
public class MobileSubscriptionGetAddOnDataTest {
    
    @TestSetup
    static void testdatamethod()
    {
       //* added by shubhi start---------EDGE-160037
       List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c price_item =PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5176');
        price_item.name='Handheld';
        price_item_List.add(price_item);
        
        //cspmb__Price_Item__c price_item_1 =PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5177');
        //price_item_List.add(price_item_1);
        
        insert price_item_List;
        List<cspmb__Add_On_Price_Item__c> addonlist=new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c addon1 =PricingTestDataFactory.generateAddOn('DMCAT_RecurringCharge_000669','basic','DMCAT_RecurringCharge_000669');addonlist.add(addon1);
        cspmb__Add_On_Price_Item__c addon2 =PricingTestDataFactory.generateAddOn('DMCAT_RecurringCharge_000497','premium','DMCAT_RecurringCharge_000497');addonlist.add(addon2);
        addon1.addOn_Name__c='basic';
        addon2.addOn_Name__c='premium';
        insert addonlist;
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addonassoclst = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = PricingTestDataFactory.generateproceItemaddonAssociation(price_item,addon1);
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc2 = PricingTestDataFactory.generateproceItemaddonAssociation(price_item,addon2);
        addonassoclst.add(addonassoc1);
        addonassoc2.isdefault__c=true;
        addonassoclst.add(addonassoc2);
        insert addonassoclst;
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        /*----Fix for FDR by Shubhi 2/9/20 START-----*/
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        /*----Fix for FDR by Shubhi 2/9/20 END-----*/
       insert sales;
          //* added by shubhi end---------EDGE-160037  
          
        //cspmb__Price_Item__c prod = new cspmb__Price_Item__c(name='Test Prod',ProdSpecId__c='Test Product');
        //insert prod;
        
        //cspmb__Add_On_Price_Item__c addon = new cspmb__Add_On_Price_Item__c(name='Test Addon1',External_Id__c='TestDMCAT_RecurringCharge_000669',ProdSpecId__c='Test ProductAddon1');
        //insert addon;
        //cspmb__Add_On_Price_Item__c addon1 = new cspmb__Add_On_Price_Item__c(name='Test Addon2',External_Id__c='TestDMCAT_RecurringCharge_000497',ProdSpecId__c='Test ProductAddon2');
        //insert addon1;
        //List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addonassoclst = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        //cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = PricingTestDataFactory.generateproceItemaddonAssociation();
        //cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc2 = PricingTestDataFactory.generateproceItemaddonAssociation();
        //insert addonassoclst;
        cspmb__Usage_Type__c usage = new cspmb__Usage_Type__c(name='Test usage',cspmb__type__c='Group',cspmb__unit_of_measure__c='Minute');
        insert usage;
            cspmb__Allowance__c allowance1 = new cspmb__Allowance__c(name='Testallow',cspmb__unlimited__c=false,cspmb__usage_type__c=usage.id);
            insert allowance1;
            List<cspmb__Commercial_Product_Allowance_Assoc__c> allowassoclst = new List<cspmb__Commercial_Product_Allowance_Assoc__c>();
            cspmb__Commercial_Product_Allowance_Assoc__c allowassoc = new cspmb__Commercial_Product_Allowance_Assoc__c(cspmb__commercial_product__c=price_item.id,cspmb__allowance__c=allowance1.id);
            allowassoclst.add(allowassoc);
            cspmb__Commercial_Product_Allowance_Assoc__c allowassoc1 = new cspmb__Commercial_Product_Allowance_Assoc__c(cspmb__add_on__c=addon1.id,cspmb__allowance__c=allowance1.id);
            allowassoclst.add(allowassoc1);
            cspmb__Commercial_Product_Allowance_Assoc__c allowassoc2 = new cspmb__Commercial_Product_Allowance_Assoc__c(cspmb__add_on__c=addon2.id,cspmb__allowance__c=allowance1.id);
            allowassoclst.add(allowassoc2);
            insert allowassoclst;
            
    }
    @isTest
    static void testgetDataMobileSubscriptionGetAddOnData(){
        Map<String, Object> returnMap = new Map<String, Object>(); 
        //MobileSubscriptionGetAddOnData getaddondata = new MobileSubscriptionGetAddOnData();
        cspmb__Price_Item__c prod1 = [select id from cspmb__Price_Item__c limit 1];
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = [select id from cspmb__Price_Item_Add_On_Price_Item_Association__c limit 1];
        returnMap = MobileSubscriptionGetAddOnData.getData(new Map<String,Object>{'priceItemId'=>prod1.id});
        system.assertequals(2,returnMap.size());
    }
    @isTest
    static void testgetDataSolutionGetPricingRecords(){
        Map<String, Object> returnMap = new Map<String, Object>(); 
        
        //MobileSubscriptionGetAddOnData getaddondata = new MobileSubscriptionGetAddOnData();
        cspmb__Price_Item__c prod1 = [select id from cspmb__Price_Item__c limit 1];
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = [select id from cspmb__Price_Item_Add_On_Price_Item_Association__c limit 1];
        List<cspmb__Commercial_Product_Allowance_Assoc__c> lst = [select id from cspmb__Commercial_Product_Allowance_Assoc__c];
        SolutionGetPricingRecords.getData(new Map<String,Object>{addonassoc1.id=>'getAddOn'});
        SolutionGetPricingRecords.getData(new Map<String,Object>{addonassoc1.id=>'getPriceItem'});
        if(!lst.isEmpty()){
            SolutionGetPricingRecords.getData(new Map<String,Object>{lst[1].id=>'getAddOn'});
            SolutionGetPricingRecords.getData(new Map<String,Object>{lst[0].id=>'getPriceItem'});
            returnMap = SolutionGetPricingRecords.getData(new Map<String,Object>{lst[2].id=>'getAllowance'});
            system.assertequals(1,returnMap.size());
        }
    }
    //* added by shubhi ---------EDGE-160037
     @isTest
    static void getaddonAssociationRecordTest(){       
        cspmb__Price_Item__c plan=[Select id,name from cspmb__Price_Item__c where name='Handheld'];
        String addonName='Test Addon1';
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('getAddonPriceItemAssociation','');
        inputMap.put('offerid','DMCAT_Offer_000646');
        inputMap.put('plan',plan.id);
        inputMap.put('chargeid','DMCAT_RecurringCharge_000669');
        inputMap.put('addonName','basic');
        Test.startTest();
        User sales = [SELECT id,name FROM User Where email='salesuser@testsales.com' limit 1];     
        System.runAs(sales){
            returnMap= MobileSubscriptionGetAddOnData.getData(inputMap);
            System.assert(true, returnMap.containskey('setAddonPriceItemAssociation')); 
        }       
        Test.stopTest();
    }
    @isTest
    static void getaddonAssociationRecordBulkTest(){       
        cspmb__Price_Item__c plan=[Select id,name from cspmb__Price_Item__c where name='Handheld'];
        String addonName='Test Addon1';
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('getAddonPriceItemAssociationBulk','');
        inputMap.put('offerid','DMCAT_Offer_000646');
        inputMap.put('plan',plan.id);
        inputMap.put('chargeid','DMCAT_RecurringCharge_000669');
        inputMap.put('addonName','basic');
        Test.startTest();
        User sales = [SELECT id,name FROM User Where email='salesuser@testsales.com' limit 1];     
        System.runAs(sales){
            returnMap= MobileSubscriptionGetAddOnData.getData(inputMap);
            System.assert(true, returnMap.containskey('setAddonPriceItemAssociation')); 
        }       
        Test.stopTest();
    }
    @isTest
    static void getAddonAssociationRecordNegative(){
        cspmb__Price_Item__c plan=[Select id,name from cspmb__Price_Item__c where name='Handheld'];
        String addonName='Test Addon1';
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where  email='salesuser@testsales.com' limit 1];     
        System.runAs(sales){
            returnMap= MobileSubscriptionGetAddOnData.getData(inputMap);
            System.assertEquals(false, returnMap.containskey('setAddonPriceItemAssociation')); 
        }       
        Test.stopTest();
    }
    //* added by shubhi ---------EDGE-160037 end 
}