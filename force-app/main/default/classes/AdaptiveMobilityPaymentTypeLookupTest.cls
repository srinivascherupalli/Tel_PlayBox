/*******************************************************************
   @Author : Krunal Taak / Ila Verma
   @Description : Lookup Custom class to fetch the Payment Type in MobileAccessory in Adaptive Mobility
   @Release : Sprint 20.16 - DPG-3506

   S.No.  Date         User Story   Owner      Description
   1      15-12-2020   DPG-3506     Krunal T.  Test Class for Apex class "AdaptiveMobilityPaymentTypeLookup"
   2.     13-08-2021   DIGI-12691   Sayantan H. Code blocks added line no.123 onwards to provision Apec class "AdaptiveMobilityContractTermLookup"
*******************************************************************/
@isTest
public class AdaptiveMobilityPaymentTypeLookupTest{
  @testSetup
  static void testData(){
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
    
    List<Hardware_Repayment_Metadata__c> hroList = new List<Hardware_Repayment_Metadata__c>();
    Hardware_Repayment_Metadata__c hro1 = new Hardware_Repayment_Metadata__c();
    hro1.Name = 'Payment_Mock';
    hro1.Override_Attribute_Name__c = 'PaymentTypeLookup';
    hro1.Minimum_Value__c = 120.00;
    hro1.Maximum_Value__c = 240.00;
    hro1.isActive__c = TRUE;
    hro1.Override_Attribute_Value__c = 'Hardware Repayment';
    hro1.Offer_ID__c = 'Offer1';
    hroList.add(hro1);
    Hardware_Repayment_Metadata__c hro2 = new Hardware_Repayment_Metadata__c();
    hro2.Name = 'ContractTerm_Mock';
    hro2.Override_Attribute_Name__c = 'ContractTerm';
    hro2.Minimum_Value__c = 120.00;
    hro2.Maximum_Value__c = 240.00;
    hro2.isActive__c = TRUE;
    hro2.Override_Attribute_Value__c = '12';
    hro2.Offer_ID__c = 'Offer1';
    hroList.add(hro2);
    insert hroList;
}

  @isTest
  static void lookupSearchforType(){
    cspmb__Price_Item__c commercialProd = [Select id,Name, Offer_Id__c,Device_Type__c,Model__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];

    Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId',commercialProd.Offer_Id__c);
    searchFields.put('ItemCode',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
    searchFields.put('searchValue','Modem');
    searchFields.put('ModelName',commercialProd.Model__c);
    searchFields.put('paymentTypeShadow','Hardware Repayment');

    cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();

    AdaptiveMobilityPaymentTypeLookup UCDeviceModelLookup = new AdaptiveMobilityPaymentTypeLookup();
    UCDeviceModelLookup.getRequiredAttributes();
    Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
    List<Hardware_Repayment_Metadata__c> resultList = (List<Hardware_Repayment_Metadata__c>)lookupResult;
    System.assertEquals(true,lookupResult != null);
    //System.assertEquals(true,resultList[0].Check_todays_date__c == true);
  }
  @isTest
  static void lookupSearchforModel(){
    cspmb__Price_Item__c commercialProd = [Select id,Name, Type__c,Offer_Id__c,Device_Type__c,Model__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];

    Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId',commercialProd.Offer_Id__c);
    searchFields.put('ItemCode',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
    searchFields.put('TypeName',commercialProd.Type__c);
    searchFields.put('searchValue','Modem');
    searchFields.put('ModelName',commercialProd.Model__c);    
    searchFields.put('paymentTypeShadow','Hardware Repayment');

    cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();

    AdaptiveMobilityPaymentTypeLookup UCDeviceModelLookup = new AdaptiveMobilityPaymentTypeLookup();
    Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
    List<Hardware_Repayment_Metadata__c> resultList = (List<Hardware_Repayment_Metadata__c>)lookupResult;
    System.assertEquals(true,lookupResult != null);
    //System.assertEquals(true,resultList[0].Check_todays_date__c == true);
  }
  @isTest
  static void lookupSearchNegativeScenario(){
    cspmb__Price_Item__c commercialProd = [Select id,Name, Type__c,Offer_Id__c,Device_Type__c,Model__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];
    commercialProd.cspmb__Effective_Start_Date__c = Date.newInstance(2008, 1, 30);
    commercialProd.cspmb__Effective_End_Date__c = Date.newInstance(2008, 1, 30);
    update commercialProd;
    Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId','negative');
    searchFields.put('ItemCode','negative');
    searchFields.put('TypeName','negative');
    searchFields.put('searchValue','negative');
    searchFields.put('ModelName','negative');    
    searchFields.put('paymentTypeShadow','negative');

    cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();

    AdaptiveMobilityPaymentTypeLookup UCDeviceModelLookup = new AdaptiveMobilityPaymentTypeLookup();
    Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
    System.assertEquals(0,lookupResult.size());
  }
    //Start of change for DIGI-12691, 12706
    @isTest
  static void lookupSearchforTypeCT(){
    cspmb__Price_Item__c commercialProd = [Select id,Name, Offer_Id__c,Device_Type__c,Model__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];

    Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId',commercialProd.Offer_Id__c);
    searchFields.put('ItemCode',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
    searchFields.put('searchValue','Modem');
    searchFields.put('ModelName',commercialProd.Model__c);
    searchFields.put('paymentTypeShadow','Hardware Repayment');

    cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();

    AdaptiveMobilityContractTermLookup UCDeviceModelLookup = new AdaptiveMobilityContractTermLookup();
    UCDeviceModelLookup.getRequiredAttributes();
    Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
    List<Hardware_Repayment_Metadata__c> resultList = (List<Hardware_Repayment_Metadata__c>)lookupResult;
    System.assertEquals(true,lookupResult != null);
    //System.assertEquals(true,resultList[0].Check_todays_date__c == true);
  }
  @isTest
  static void lookupSearchforModelCT(){
    cspmb__Price_Item__c commercialProd = [Select id,Name, Type__c,Offer_Id__c,Device_Type__c,Model__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];

    Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId',commercialProd.Offer_Id__c);
    searchFields.put('ItemCode',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
    searchFields.put('TypeName',commercialProd.Type__c);
    searchFields.put('searchValue','Modem');
    searchFields.put('ModelName',commercialProd.Model__c);    
    searchFields.put('paymentTypeShadow','Hardware Repayment');

    cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();

    AdaptiveMobilityContractTermLookup UCDeviceModelLookup = new AdaptiveMobilityContractTermLookup();
    Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
    List<Hardware_Repayment_Metadata__c> resultList = (List<Hardware_Repayment_Metadata__c>)lookupResult;
    System.assertEquals(true,lookupResult != null);
    //System.assertEquals(true,resultList[0].Check_todays_date__c == true);
  }
  @isTest
  static void lookupSearchNegativeScenarioCT(){
    cspmb__Price_Item__c commercialProd = [Select id,Name, Type__c,Offer_Id__c,Device_Type__c,Model__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];
    commercialProd.cspmb__Effective_Start_Date__c = Date.newInstance(2008, 1, 30);
    commercialProd.cspmb__Effective_End_Date__c = Date.newInstance(2008, 1, 30);
    update commercialProd;
    Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId','negative');
    searchFields.put('ItemCode','negative');
    searchFields.put('TypeName','negative');
    searchFields.put('searchValue','negative');
    searchFields.put('ModelName','negative');    
    searchFields.put('paymentTypeShadow','negative');

    cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();

    AdaptiveMobilityContractTermLookup UCDeviceModelLookup = new AdaptiveMobilityContractTermLookup();
    Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
    System.assertEquals(0,lookupResult.size());
  }
  //End of change for DIGI-12691,12706
	
}