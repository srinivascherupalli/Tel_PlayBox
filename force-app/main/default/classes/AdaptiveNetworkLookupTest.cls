/******************************************************************************************************************************
Name          : AdaptiveNetworkLookupTest
Created By    : Ravi Kumar Jain
Created Date  : Nov 12 2021
Description   : Test class for Adaptive Network lookups
-------
History
-------
VERSION     AUTHOR                       DATE            DETAIL
-------     ------                       -----           ---------
1.1         Ravi Kumar Jain            OCT 12 2021      Created
1.2      Ravi Kumar Jain        Nov 15 2021     Updated : Test method for AN_RedundancyCosLookup class added
******************************************************************************************************************************/

@isTest
public class AdaptiveNetworkLookupTest {
    @testSetup
    public static void dataSetup() {
        List<cspmb__Price_Item__c> piList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c price_item = new cspmb__Price_Item__c();
        price_item.Name = 'Telstra Fibre';       
        price_item.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item.cspmb__Effective_Start_Date__c = Date.newInstance(2021,09,10);
        price_item.cspmb__Is_Active__c = true;
        price_item.cspmb__Price_Item_Code__c = 'AD_1234567890ui';
        price_item.Commercial_Product_Code__c = 'AD_1234567890ui';
        price_item.External_Id__c = 'dmcat_112'+math.random();
        price_item.BillingSpecId__c = 'DMCAT_007234';
        price_item.Technology_Type__c = 'Telstra Fibre';
        price_item.ProdSpecId__c = '123Y67';
        price_item.Zone__c = 'Zone 1';
        price_item.RedundancyType__c = 'Single';
        price_item.cspmb__Is_Active__c = True;
        price_item.cspmb__Type__c = 'Commercial Product';
        price_Item.cspmb__Role__c = 'Basic';
        piList.add(price_Item);
        
        cspmb__Price_Item__c price_item1 = new cspmb__Price_Item__c();
        price_item1.Name = 'nbn Enterprise Ethernet';       
        price_item1.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item1.cspmb__Effective_Start_Date__c = Date.newInstance(2021,09,10);
        price_item1.cspmb__Is_Active__c = true;
        price_item1.cspmb__Price_Item_Code__c = 'AD_12134567890ui';
        price_item1.Commercial_Product_Code__c = 'AD_12134567890ui';
        price_item1.External_Id__c = 'dmcat_112'+math.random();
        price_item1.BillingSpecId__c = 'DMCAT_007234';
        price_item1.Technology_Type__c = 'nbn Enterprise Ethernet';
        price_item1.ProdSpecId__c = '123Y67';
        price_item1.Zone__c = 'Zone 1';
        price_item1.classofservice__c = 'High';
        price_item1.cspmb__Is_Active__c = True;
        price_item1.cspmb__Type__c = 'Commercial Product';
        price_Item1.cspmb__Role__c = 'Basic';
        piList.add(price_Item1);
        
        INSERT piList;
        
        cspmb__add_on_price_item__c add_on = new cspmb__add_on_price_item__c();
        add_on.Adapt_Service__c = 'BIP Adapt';
        add_on.Access_Type__c = 'Telstra Fibre';
        add_on.SLA_Zone__c = 'Urban';
        add_on.SLA_Type__c = 'Premium';
        add_on.Service_Management__c = '4+';
        add_on.cspmb__Is_Active__c = TRUE;
        add_on.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        add_on.ProdSpecId__c = '123456';
        
        INSERT add_on;
        
        cspmb__Price_Item_Add_On_Price_Item_Association__c addOn_Assoc = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        addOn_Assoc.cspmb__Add_On_Price_Item__c = add_on.Id;
        addOn_Assoc.cspmb__Price_Item__c = price_Item.Id;
        
        INSERT addOn_Assoc;
    }
    
    public static testmethod void getSLAAddonTest() {
        Map<String, String> searchFields = new Map<String, String> ();
        Map<String, String> searchFields1 = new Map<String, String> ();
        Map<String, String> searchFields2 = new Map<String, String> ();
        
        //search data for Adaptive network
        searchFields.put('Access Type', 'Telstra Fibre');
        searchFields.put('SLA Zone', 'Urban');
        
        //search data for Sla Type
        searchFields1.put('Access Type', 'Telstra Fibre');
        searchFields1.put('SLA Zone', 'Urban');
        searchFields1.put('Adapt Service Value','BIP Adapt');
        
        //Search data for Service Management
        searchFields2.put('Access Type', 'Telstra Fibre');
        searchFields2.put('SLA Zone', 'Urban');
        searchFields2.put('Adapt Service Value','BIP Adapt');
        searchFields2.put('SLA Type Value','Premium');
        
        Test.startTest();
        AdaptiveNetworkSlaLookup sla = new AdaptiveNetworkSlaLookup();
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> res = (List<cspmb__Price_Item_Add_On_Price_Item_Association__c>)sla.doLookupSearch(searchFields, '',null,0,0);
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> res1 = (List<cspmb__Price_Item_Add_On_Price_Item_Association__c>)sla.doLookupSearch(searchFields1, '',null,0,0);  
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> res2 = (List<cspmb__Price_Item_Add_On_Price_Item_Association__c>)sla.doLookupSearch(searchFields2, '',null,0,0);
        Test.stopTest();
        system.assertEquals('BIP Adapt', res[0].cspmb__Add_On_Price_Item__r.Adapt_Service__c);
        system.assertEquals('Premium', res[0].cspmb__Add_On_Price_Item__r.sla_type__c);
        system.assertEquals('4+', res[0].cspmb__Add_On_Price_Item__r.service_management__c);
        
    }
    
    public static testmethod void redundancyLookupTest() {
        Map<String, String> searchFields = new Map<String, String> ();
        Map<String, String> searchFields1 = new Map<String, String> ();
        //search data for Redundancy Type
        searchFields.put('Access Type', 'Telstra Fibre');
        searchFields.put('Zone', 'Zone 1');
        searchFields.put('searchValue', 'Si');
        
        //search data for Class of service Type
        searchFields1.put('Access Type', 'nbn Enterprise Ethernet');
        searchFields1.put('Zone', 'Zone 1');
        
        Test.startTest();
        AN_RedundancyCosLookup redun = new AN_RedundancyCosLookup();
        List<cspmb__Price_Item__c> res = (List<cspmb__Price_Item__c> )redun.doLookupSearch(searchFields, '', null, 0, 0);
        List<cspmb__Price_Item__c> res1 = (List<cspmb__Price_Item__c> )redun.doLookupSearch(searchFields1, '', null, 0, 0);
        Test.stopTest();
        system.assertEquals('Single', res[0].RedundancyType__c);
        system.assertEquals('High', res1[0].classofservice__c);
    }
}