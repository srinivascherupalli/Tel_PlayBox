/*******************************************************************
   @Author : SarfraJ Ahmad
   @Description : @Description : Lookup Custom class to fetch the APN and Add On based on Account Id and Select Plan in Data Custom in Enterprise Mobility Plan
@Release : Sprint 21.07 - DPG-5295

   S.No.  Date         User Story   Owner       Description
   1      19-05-2021   DPG-5295     Sarfraj A.  APN lookup
*******************************************************************/
@isTest
public class AdaptiveMobilityDataCustomAPNLookupTest {

    @testSetup
    static void testData(){
        Account acc1 = new Account();
        acc1.name = 'TestAccount';
        insert acc1;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Network Product','Premium');
        insert pd;
        System.assertNotEquals(null,pd);
        List<cspmb__Price_Item__c> comProdList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Device',324,564.23,'User','Commercial');
        commercialPrd.Offer_Id__c = 'Offer1';
        commercialPrd.Type__c = 'Modem';
        commercialPrd.Model__c = 'CISCO Modem';
        commercialPrd.cspmb__Price_Item_Code__c = 'NET01';
        commercialPrd.Commercial_Product_Code__c = 'NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        commercialPrd.cspmb__Effective_Start_Date__c = Date.today();
        commercialPrd.cspmb__Effective_End_Date__c = Date.today()+4;
        comProdList.add(commercialPrd);
        cspmb__Price_Item__c commercialPrd1 = ProductTestFactory.buildPriceItem('New Device1',324,564.23,'User','Commercial');
        commercialPrd1.Offer_Id__c = 'Offer1';
        commercialPrd1.Type__c = 'Modem1';
        commercialPrd1.Model__c = 'CISCO Modem';
        commercialPrd1.cspmb__Price_Item_Code__c = 'NET01';
        commercialPrd1.Commercial_Product_Code__c = 'NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        commercialPrd1.cspmb__Effective_Start_Date__c = Date.newInstance(2008, 1, 30);
        commercialPrd1.cspmb__Effective_End_Date__c = Date.newInstance(2099, 1, 30);
        comProdList.add(commercialPrd1);
        insert comProdList;
        
        String Name1 = '3G Standard Retail';
        String adddonCode = 'DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000497_101';
        String accessType = 'TestAccess';
        String accessConfig = 'TestConfig';
        String classOfService = 'TestService';
        String planName = 'TestPlan';
        
        String Name2 = 'Accelerator';
        
        List<cspmb__Add_On_Price_Item__c> addOns = new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c addOn1 = ProductTestFactory.buildAddOnPriceItem(Name1,adddonCode,accessType,accessConfig,classOfService,planName);
        addOns.add(addOn1);
        cspmb__Add_On_Price_Item__c addOn2 = ProductTestFactory.buildAddOnPriceItem(Name2,adddonCode,accessType,accessConfig,classOfService,planName);
        addOns.add(addOn2);
        
        insert addOns;
        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> productAddonAssociations = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c productAddonAssociation1 = ProductTestFactory.buildPriceAssociation(commercialPrd.id,addOn1.id); 
        productAddonAssociations.add(productAddonAssociation1);
        cspmb__Price_Item_Add_On_Price_Item_Association__c productAddonAssociation2 = ProductTestFactory.buildPriceAssociation(commercialPrd1.id,addOn2.id);
        productAddonAssociations.add(productAddonAssociation2);
        insert productAddonAssociations;
        
       
        
        List<APN__c> apns = new List<APN__c>();
        APN__c apn1 = new APN__c();
        apn1.APN_ID__c = '123xz';
        apn1.APN_Type__c = 'Shared';
        apn1.Preferred__c= false;
        apn1.Status__c=true;
        apn1.Customer__c = acc1.id;
        apn1.Name = '3G Standard Retail';
        
        APN__c apn2 = new APN__c();
        apn2.APN_ID__c = '123acc';
        apn2.APN_Type__c = 'Shared';
        apn2.Preferred__c= true;
        apn2.Status__c=true;
        apn2.Customer__c = acc1.id;
        apn2.Name = 'Accelerator';
        apns.add(apn1);
        apns.add(apn2);
        
        insert apns;
        
    }
    
    @isTest
    static void lookupSearchforAPN(){
        cspmb__Price_Item__c commercialProd = [Select id,Name, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c,
                                               cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c 
                                               where Name = 'New Device1'];
        

        Account acc1 = [Select id, name from Account where Name='TestAccount' limit 1];
        Map<String,String> searchFields = new Map<String,String>();
        searchFields.put('AccountID',acc1.id);
        searchFields.put('Select Plan',commercialProd.id);
        searchFields.put('searchValue','Modem');
        
        cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
        List<Id> excludeIds = new List<Id>();
        
        AdaptiveMobilityDataCustomAPNLookup adaptiveMobilityDataCustomAPNLookup = new AdaptiveMobilityDataCustomAPNLookup();
        adaptiveMobilityDataCustomAPNLookup.getRequiredAttributes();
        Object[] lookupResult = adaptiveMobilityDataCustomAPNLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c > resultList = (List<cspmb__Price_Item_Add_On_Price_Item_Association__c >)lookupResult;
        System.assertEquals(true,lookupResult != null);
        
    }
}