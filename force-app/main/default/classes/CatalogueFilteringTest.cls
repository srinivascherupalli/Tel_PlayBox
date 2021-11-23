/**
* Test Class for CatalogueFiltering Class.
* ModifiedBy    Gnana   Edge-132211   16-02-2020
*/
@isTest
public class CatalogueFilteringTest 
{   
    @isTest
    private static void testAllConfigurations()
    {
        cscfga__Product_Basket__c basket = prepareData('AllConfigurations');
        EnvironmentVariable__c ev = new EnvironmentVariable__c(Name = 'EnableB2B4', Value__c = 'true');
        insert ev;
        Test.startTest();
        CatalogueFiltering cfRec = new CatalogueFiltering();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        Test.stopTest();
        System.assertNotEquals(null, idList, 'idList should not be null');
        
    }

    @isTest
    private static void testNonModular()
    {
        cscfga__Product_Basket__c basket = prepareData('Non_Modular');
        Test.startTest();
        CatalogueFiltering cfRec = new CatalogueFiltering();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        Test.stopTest();
        System.assertEquals(6, idList.size(), 'idList size is correct');
        
    }
    

    @isTest
    private static void testUCEOnly()
    {
        cscfga__Product_Basket__c basket = prepareData('UCEOnly');
        Test.startTest();
        CatalogueFiltering cfRec = new CatalogueFiltering();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        Test.stopTest();
        System.assertNotEquals(null, idList, 'idList should not be null');
        
    }

    @isTest
    private static void testIPOnly()
    {
        cscfga__Product_Basket__c basket = prepareData('IPOnly');
        Test.startTest();
        CatalogueFiltering cfRec = new CatalogueFiltering();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        System.assertNotEquals(null, idList, 'idList should not be null');
        
    }
    
    @isTest
    private static void testCWPPackage()
    {
        cscfga__Product_Basket__c basket = prepareData('CWP_PACKAGE');
        Test.startTest();
        CatalogueFiltering cfRec = new CatalogueFiltering();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        Test.stopTest();
        System.assertNotEquals(null, idList, 'idList should not be null');
        
    }
    

    @isTest
    private static void testPPHH()
    {
        cscfga__Product_Basket__c basket = prepareData('AllConfigurations');
        EnvironmentVariable__c ev = new EnvironmentVariable__c(Name = 'EnableB2B4', Value__c = 'true');
        insert ev;

        CatalogueFiltering cfRec = new CatalogueFiltering();
        Test.startTest();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        Test.stopTest();
        System.assertNotEquals(null, idList, 'idList should not be null');
    }

    @isTest
    private static void testCWPMobilityWithPPHH()
    {
        cscfga__Product_Basket__c basket = prepareData('UCEOnly');
        EnvironmentVariable__c ev = new EnvironmentVariable__c(Name = 'EnableB2B4', Value__c = 'true');
        insert ev;

        CatalogueFiltering cfRec = new CatalogueFiltering();
        Test.startTest();
        List<Id> idList = (List<Id>)cfRec.invoke(new Map<String, String>{'basketId' => basket.Id});
        Test.stopTest();
        System.assertNotEquals(null, idList, 'idList should not be null');
    }
    
    public static cscfga__Product_Basket__c prepareData(String variation){
        // Gnana - Added to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - Start
        List<cscfga__Product_Definition__c> lstPD = new List<cscfga__Product_Definition__c>();
        List<cscfga__Product_Configuration__c> lstPC = new List<cscfga__Product_Configuration__c>();
        List<csord__Subscription__c> lstSub = new List<csord__Subscription__c>();
        List<cscfga__Product_Category__c> lstPCat = new List<cscfga__Product_Category__c>();
        // Gnana - Added to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - End

        Account acc = ProductTestService.getNewAccount('TestMyAccount'); 
        acc.Customer_Status__c = 'ACTIVE';
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_type__c = 'Modular';
        //opp.IsActiveAccount__c = true;
        opp.RetiedAccOpp__c = true;
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Basket_Stage__c='Draft';
        basket.cscfga__Opportunity__c = opp.id;
        insert basket;
        
        /*Data creation for Product definitions and Configurations */
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Connected Workplace', null);
        cscfga__Product_Definition__c pd2 = ProductTestFactory.buildProductDefinition(System.Label.IP_Network, null);
        cscfga__Product_Definition__c pd3 = ProductTestFactory.buildProductDefinition(System.Label.UC_Enterprise, null);
        // Gnana - Changed to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - Start
        // insert pd;        
        // insert pd2;
        // insert pd3;
        lstPD.add(pd);
        lstPD.add(pd2);
        lstPD.add(pd3);
        insert lstPD;
        // Gnana - Changed to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - End

        cscfga__Product_Configuration__c pc = ProductTestFactory.buildProductConfig(pd.id);
        pc.cscfga__Product_Definition__c = pd.id;
        pc.cscfga__Product_Basket__c = basket.id;
        
        cscfga__Product_Configuration__c pc2 = ProductTestFactory.buildProductConfig(pd2.id);
        pc2.cscfga__Product_Definition__c = pd2.id;
        pc2.cscfga__Product_Basket__c = basket.id;

        cscfga__Product_Configuration__c pc3 = ProductTestFactory.buildProductConfig(pd3.id);
        pc3.cscfga__Product_Definition__c = pd3.id;
        pc3.cscfga__Product_Basket__c = basket.id;
        
        cscfga__Product_Configuration__c pc4 = ProductTestFactory.buildProductConfig(pd.id);
        pc4.cscfga__Product_Definition__c = pd.id;
        pc4.cscfga__Product_Basket__c = basket.id;

        if(variation == 'AllConfigurations'){
            // Gnana - Changed to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - Start
            lstPC.add(pc);
            lstPC.add(pc2);
            lstPC.add(pc3);
            lstPC.add(pc4);
            // insert pc;
            // insert pc2;
            // insert pc3;
            // insert pc4;
            insert lstPC;
            // Gnana - Changed to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - End
            csord__Subscription__c subs = ProductTestService.getNewSubscriptionForAccount(acc);
            subs.Name = System.Label.IP_Network;
            update subs;
            csord__Subscription__c subs1 = ProductTestService.getNewSubscriptionForAccount(acc);
            subs1.Name = System.Label.UC_Config_Name;
            update subs1;
            
            csord__Subscription__c subs2 = ProductTestService.getNewSubscriptionForAccount(acc);
            subs2.Name = System.Label.Connected_Workplace;
            update subs2;

            // Gnana - Added to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - Start
            lstSub.add(subs);
            lstSub.add(subs1);
            lstSub.add(subs2);
            update lstSub;
            // Gnana - Added to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - End
        }

        List<csord__Subscription__c> lstSub2 = new List<csord__Subscription__c>();// Gnana Edge-132211

        if(variation == 'UCEOnly'){
            insert pc3;
            csord__Subscription__c subs1 = ProductTestService.getNewSubscriptionForAccount(acc);
            subs1.Name = System.Label.UC_Config_Name;
            // update subs1; // Gnana Edge-132211
            lstSub2.add(subs1); // Gnana Edge-132211
        }

        if(variation == 'IPOnly'){
            insert pc2;
            csord__Subscription__c subs = ProductTestService.getNewSubscriptionForAccount(acc);
            subs.Name = System.Label.IP_Network;
            // update subs;
            lstSub2.add(subs); // Gnana Edge-132211
        }

        if(lstSub2.size()>0)    // Gnana Edge-132211
            update lstSub2;     // Gnana Edge-132211

        if(variation == 'CWP_PACKAGE'){
   
        }
        if(variation == 'Non_Modular'){
        opp.Product_type__c = null;
        update opp;
        }

        /*Data creation for Catefories and Offer */
        cscfga__Product_Category__c cat = ProductTestFactory.buildProductCategory();
        cat.name = 'Modular Products';
        // insert cat; // Gnana Edge-132211
        
        cscfga__Product_Category__c cat2 = ProductTestFactory.buildProductCategory();
        cat2.name = 'Mobility';
        // insert cat2; // Gnana Edge-132211
        
        cscfga__Product_Category__c cat4 = ProductTestFactory.buildProductCategory();
        cat4.name = 'Site Specific';
        // insert cat4; // Gnana Edge-132211
        
        cscfga__Product_Category__c cat3 = ProductTestFactory.buildProductCategory();
        cat3.name = 'Site Agnostic';
        // insert cat3; // Gnana Edge-132211

        // Gnana - Added to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - Start
        lstPCat.add(cat);
        lstPCat.add(cat2);
        lstPCat.add(cat3);
        lstPCat.add(cat4);
        insert lstPCat;
        // Gnana - Added to fix PB Edge-132211-> Associate Product Configuration to CLI - SOQL Issue - End
        
        List<cscfga__Configuration_Offer__c> offerList= new List<cscfga__Configuration_Offer__c>();
        cscfga__Configuration_Offer__c Offer = ProductTestService.createOffer('Connected Workplace');
        cscfga__Configuration_Offer__c Offer2 = ProductTestService.createOffer('Connected Workplace Package');
        cscfga__Configuration_Offer__c Offer3 = ProductTestService.createOffer('CWP Site');
        cscfga__Configuration_Offer__c Offer4 = ProductTestService.createOffer(System.Label.Modular_Products);
        cscfga__Configuration_Offer__c Offer5 = ProductTestService.createOffer('IP Network');
        cscfga__Configuration_Offer__c Offer6 = ProductTestService.createOffer('Mobile Seats');
        
        // Gnana - Added to fix PB -> Associate Product Configuration to CLI - SOQL Issue - Start
        offerList.add(offer);
        offerList.add(offer2);
        offerList.add(offer3);
        offerList.add(offer4);
        offerList.add(offer5);
        offerList.add(offer6);
        ProductTestService.createProductConfiguration(offerList);
        // Gnana - Added to fix PB -> Associate Product Configuration to CLI - SOQL Issue - End

        Date d = Date.today();
        cspmb__Price_Item__c pi = new cspmb__Price_Item__c();
        pi.cspmb__Product_Definition_Name__c = 'User';
        pi.Package_Name__c = 'Connected Workplace';
        pi.cspmb__Effective_End_Date__c = d.addDays(7);
        pi.cspmb__Effective_Start_Date__c = d.addDays(-14);
        pi.User_Type__c = 'Fax Line';
        pi.ProdSpecId__c = '123456';
        insert pi;

        return basket;
    }
    
}