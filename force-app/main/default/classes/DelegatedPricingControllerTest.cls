/********************************************************************
   EDGE        : 114351
   Class        : DelegatedPricingController
   Description : Test clas of DPR Controller
   Author      : Deepak Kumar
   Last Modified By: T Badri Narayan Subudhi
 *******************************************************************/
@isTest
public class DelegatedPricingControllerTest
{
    @isTest
    public static void getOpportunityDetailsTest()
    {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        test.startTest();
        DelegatedPricingController.getOpportunityDetails(orpportunityDetailsRecord.Id);
        System.assertNotEquals(NUll, orpportunityDetailsRecord.Id);
        test.stopTest();
    }

    @isTest
    public static void fetchDelPricingRequestTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        test.startTest();
        DelegatedPricingController.fetchDelPricingRequest(insertDelegatedPricingRequest.Id);
        System.assertNotEquals(NULL, insertDelegatedPricingRequest);
        DelegatedPricingController.insertDelegatedPricingRequest(insertDelegatedPricingRequest);
        System.assertNotEquals(NULL, insertDelegatedPricingRequest);
        DelegatedPricingController.insertDelegatedPricingRequest(insertDelegatedPricingRequest);
        System.assertNotEquals(NULL, insertDelegatedPricingRequest);
        test.stopTest();
    }
    @isTest
    public static void getMarketableofferDetailesTest(){
        Marketable_Offer__c getMarketableofferDetailes = new Marketable_Offer__c();
        getMarketableofferDetailes.name = 'Test';
        getMarketableofferDetailes.Offer_ID__c = 'DMCAT_Offer_000646';
        insert getMarketableofferDetailes;
        test.startTest();
        DelegatedPricingController.getMarketableofferDetailes('Test','Test');
        System.assertNotEquals(NULL, getMarketableofferDetailes);
        test.stopTest();
    }

    // Added By Badri Start
    @isTest
    public static void fetchDPROfferTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.fetchDPROffer('Corporate Mobile Plus',insertDelegatedPricingRequest.Id));
        test.stopTest();
    }

    /*   @isTest
       public static void getPlanTypeValuesTest(){
           Marketable_Offer__c getMarketableofferDetailes = new Marketable_Offer__c();
           getMarketableofferDetailes.name='Corporate Mobile Plus';
           getMarketableofferDetailes.Offer_ID__c='DMCAT_Offer_000646';
           insert getMarketableofferDetailes;
           test.startTest();
           System.assertNotEquals(NULL, DelegatedPricingController.getPlanTypeValues('Corporate Mobile Plus','Committed Data'));
           test.stopTest();
       } */

    @isTest
    public static void fetchMroBonCredAmtTest(){
        cspmb__Discount_Level__c objdisclev = new cspmb__Discount_Level__c();
        objdisclev.cspmb__Minimum_Discount_Value__c = 5;
        objdisclev.cspmb__Maximum_Discount_Value__c = 6;
        insert objdisclev;
        test.startTest();
        System.assertEquals(NULL, DelegatedPricingController.fetchMroBonCredAmt(objdisclev.Id));
        test.stopTest();
    }

    /*  @isTest
       public static void fetchMinMaxValIDDTest(){
          cspmb__Discount_Level__c objdisclev=new cspmb__Discount_Level__c();
          objdisclev.cspmb__Minimum_Discount_Value__c=5;
          objdisclev.cspmb__Maximum_Discount_Value__c=6;
          insert objdisclev;
          test.startTest();
          System.assertNotEquals(NULL, DelegatedPricingController.fetchMinMaxValIDD(objdisclev.Id));
          test.stopTest();
       } */

/*    @isTest
    public static void fetchMinMaxValMMCTest(){
        cspmb__Discount_Level__c objdisclev=new cspmb__Discount_Level__c();
        objdisclev.cspmb__Minimum_Discount_Value__c=5;
        objdisclev.cspmb__Maximum_Discount_Value__c=6;
        insert objdisclev;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.fetchMinMaxValMMC(objdisclev.Id));
        test.stopTest();
    } */

    /*  @isTest
       public static void fetchMinMaxValActivationTest(){
          cspmb__Discount_Level__c objdisclev=new cspmb__Discount_Level__c();
          objdisclev.cspmb__Minimum_Discount_Value__c=5;
          objdisclev.cspmb__Maximum_Discount_Value__c=6;
          insert objdisclev;
          test.startTest();
          System.assertNotEquals(NULL, DelegatedPricingController.fetchMinMaxValActivation(objdisclev.Id));
          test.stopTest();
       }

       @isTest
       public static void fetchMinMaxValReconTest(){
          cspmb__Discount_Level__c objdisclev=new cspmb__Discount_Level__c();
          objdisclev.cspmb__Minimum_Discount_Value__c=5;
          objdisclev.cspmb__Maximum_Discount_Value__c=6;
          insert objdisclev;
          test.startTest();
          System.assertNotEquals(NULL, DelegatedPricingController.fetchMinMaxValRecon(objdisclev.Id));
          test.stopTest();
       }

       @isTest
       public static void getPlanValuesTest(){
          test.startTest();
          System.assertNotEquals(NULL, DelegatedPricingController.getPlanValues('Corporate Mobile Plus','FairPlay Data','Data'));
          test.stopTest();
       }
       @isTest
       public static void getAddOnDataTest(){
          test.startTest();
          System.assertNotEquals(NULL, DelegatedPricingController.getAddOnData('Corporate Mobile Plus','FairPlay Data','Global','Voice and Data'));
          test.stopTest();
       } */

    @isTest
    public static void getDiscountDataTest(){
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.getDiscountData('Corporate Mobile Plus','FairPlay Data','Global','Voice and Data','1 GB'));
        test.stopTest();
    }

    @isTest
    public static void getDiscountValueTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;

        Marketable_Offer__c marketableObj = new Marketable_Offer__c();
        marketableObj.Offer_ID__c = 'DMCAT_Offer_000646';
        marketableObj.Name = 'Corporate Mobile Plus';
        String dprId = insertDelegatedPricingRequest.id;
        insert marketableObj;
        test.startTest();
        System.assertEquals(NULL, DelegatedPricingController.getDiscountValue('Corporate Mobile Plus','FairPlay Data',insertDelegatedPricingRequest.Id, dprId,'MRO/BYO',marketableObj.Id,'Data','Local Data SIM BYO','Mobile Workspace Discount 2'));
        test.stopTest();
    }

    @isTest
    public static void upsertPlanAndDiscountTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        //insertDelegatedPricingRequest.Deal_Status__c = '';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;

        List<cspmb__Price_Item__c> cpiList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c insertPriceItem = new cspmb__Price_Item__c();
        insertPriceItem.Plan__c = 'Global';
        insertPriceItem.cspmb__Recurring_charge__c = 27.3;
        insertPriceItem.offer_type__c = 'Committed Data';
        insertPriceItem.offer__c = 'Committed Data';
        insertPriceItem.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItem.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItem.Type__c = 'Voice and Data';
        //  insertPriceItem.Check_todays_date__c = true;
        insertPriceItem.Offer_Id__c = 'DMCAT_Offer_000646';
        cpiList.add(insertPriceItem);

        cspmb__Price_Item__c insertPriceItem1 = new cspmb__Price_Item__c();
        insertPriceItem1.Plan__c = 'Global';
        insertPriceItem1.cspmb__Recurring_charge__c = 27.3;
        insertPriceItem1.offer_type__c = 'FairPlay Data';
        insertPriceItem1.offer__c = 'FairPlay Data';
        insertPriceItem1.Type__c = 'Voice and Data';
        //   insertPriceItem1.Check_todays_date__c = true;
        insertPriceItem1.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItem1.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItem1.Offer_Id__c = 'DMCAT_Offer_000646';
        cpiList.add(insertPriceItem1);

        cspmb__Price_Item__c insertPriceItem2 = new cspmb__Price_Item__c();
        insertPriceItem2.Plan__c = '3 GB';
        insertPriceItem2.cspmb__Recurring_charge__c = 27.3;
        insertPriceItem2.offer_type__c = 'Committed Data';
        insertPriceItem2.offer__c = 'Committed Data';
        insertPriceItem2.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItem2.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItem2.Type__c = 'Voice and Data';
        //  insertPriceItem.Check_todays_date__c = true;
        insertPriceItem2.Offer_Id__c = 'DMCAT_Offer_000646';
        cpiList.add(insertPriceItem2);

        insert cpiList;
        //Start of : EDGE-146942 - Discrepancy in the Add On list price in DP and SC
        /*cspmb__Price_Item_Add_On_Price_Item_Association__c insertAddonPriceItemAssociation = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
           insertAddonPriceItemAssociation.cspmb__Recurring_Charge__c = 20;
           insert insertAddonPriceItemAssociation;*/
        //End of : EDGE-146942 - Discrepancy in the Add On list price in DP and SC

        cspmb__Add_On_Price_Item__c insertAddonPriceItem = new cspmb__Add_On_Price_Item__c();
        insertAddonPriceItem.Name = 'Premium';
        insertAddonPriceItem.cspmb__Recurring_Charge__c = 15;
        //insertAddonPriceItem.Check_todays_date__c=true;
        insertAddonPriceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_000263';
        insert insertAddonPriceItem;

        ////Osaka Start of EDGE-146942
        cspmb__Price_Item__c insertPriceItemrec = new cspmb__Price_Item__c();
        insertPriceItemrec.Plan__c = 'Global';
        insertPriceItemrec.cspmb__Effective_End_Date__c = system.today()+2;
        //insertPriceItemrec.Check_todays_date__c=true;
        insertPriceItemrec.cspmb__Recurring_charge__c = 15;
        insertPriceItemrec.offer_type__c = 'Committed Data';
        insertPriceItemrec.offer__c = 'Committed Data';
        insertPriceItemrec.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItemrec.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItemrec.Type__c = 'Voice and Data';
        insert insertPriceItemrec;

        cspmb__Add_On_Price_Item__c insertAddonPriceItemrec = new cspmb__Add_On_Price_Item__c();
        insertAddonPriceItemrec.Name = 'Premium';
        insertAddonPriceItemrec.cspmb__Recurring_Charge__c = 15;
        insertAddonPriceItemrec.ProdSpecId__c = 'DMCAT_ProductSpecification_000263';
        insert insertAddonPriceItemrec;

        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addonListitem = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1rec = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Add_On_Price_Item__c = insertAddonPriceItemrec.id,cspmb__Price_Item__c = insertPriceItemrec.id,cspmb__Recurring_Charge__c = 10);
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc2rec = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Add_On_Price_Item__c = insertAddonPriceItemrec.id,cspmb__Price_Item__c = insertPriceItemrec.id,cspmb__Recurring_Charge__c = 10);
        addonListitem.add(addonassoc1rec);
        addonListitem.add(addonassoc2rec);
        insert addonListitem;
        system.debug('------>addonListitem'+addonListitem);
        ////Osaka Start of EDGE-146942

        DPR_Offer__c objDPROffer = new DPR_Offer__c();
        objDPROffer.Name = 'Corporate Mobile Plus';
        objDPROffer.ActualOfferPrice__c = 1234;
        objDPROffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.id;
        //  objDPROffer.Data_Pack_Plan__c = '3 GB';
        insert objDPROffer;
        String dprOfferId = objDPROffer.Id;

        // List<String> planList = new List<String>();
        Marketable_Offer__c marketableObj = new Marketable_Offer__c();
        marketableObj.Offer_ID__c = 'DMCAT_Offer_000646';
        marketableObj.Name = 'Corporate Mobile Plus';
        insert marketableObj;

        //Activation Credit Months Discount
        cspmb__Discount_Level__c DiscLevl = new cspmb__Discount_Level__c();
        DiscLevl.Name = 'Activation Credits Months Discount';
        DiscLevl.cspmb__Discount_Values__c = '0';
        DiscLevl.Effective_End_Date__c = null;
        DiscLevl.Effective_Start_Date__c = null;
        DiscLevl.Is_Delegated__c = true;
        DiscLevl.account__c = null;
        DiscLevl.cspmb__Minimum_Discount_Value__c = 1.0;
        DiscLevl.cspmb__Maximum_Discount_Value__c = 100.0;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl;

        cspmb__Discount_Association__c DiscAsscociation = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation.cspmb__Discount_Level__c = DiscLevl.Id;
        DiscAsscociation.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation;

        cspmb__Discount_Association__c DiscAsscociation10 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation10.cspmb__Discount_Level__c = DiscLevl.Id;
        DiscAsscociation10.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation10;

        //Recontracting Credit Months Discount
        cspmb__Discount_Level__c DiscLevl1 = new cspmb__Discount_Level__c();
        DiscLevl1.Name = 'Recontracting Credits Months Discount';
        DiscLevl1.cspmb__Discount_Values__c = '1';
        DiscLevl1.Effective_End_Date__c = Date.today()+2;
        DiscLevl1.Effective_Start_Date__c = Date.today()-2;
        DiscLevl1.Is_Delegated__c = true;
        DiscLevl1.account__c = null;
        DiscLevl1.cspmb__Minimum_Discount_Value__c = 1.0;
        DiscLevl1.cspmb__Maximum_Discount_Value__c = 100.0;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl1;

        cspmb__Discount_Association__c DiscAsscociation1 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation1.cspmb__Discount_Level__c = DiscLevl1.Id;
        DiscAsscociation1.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation1;

        cspmb__Discount_Association__c DiscAsscociation11 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation11.cspmb__Discount_Level__c = DiscLevl1.Id;
        DiscAsscociation11.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation11;

        //IDD Call Pack Discount
        cspmb__Discount_Level__c DiscLevl2 = new cspmb__Discount_Level__c();
        DiscLevl2.Name = 'IDD Call Pack Discount';
        DiscLevl2.cspmb__Discount_Values__c = '1';
        DiscLevl2.Effective_End_Date__c = Date.today()+2;
        DiscLevl2.Effective_Start_Date__c = Date.today()-2;
        DiscLevl2.Is_Delegated__c = true;
        DiscLevl2.account__c = null;
        DiscLevl2.cspmb__Minimum_Discount_Value__c = 1.0;
        DiscLevl2.cspmb__Maximum_Discount_Value__c = 100.0;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl2;

        cspmb__Discount_Association__c DiscAsscociation2 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation2.cspmb__Discount_Level__c = DiscLevl2.Id;
        DiscAsscociation2.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation2;

        cspmb__Discount_Association__c DiscAsscociation9 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation9.cspmb__Discount_Level__c = DiscLevl2.Id;
        DiscAsscociation9.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation9;

        //MMC Discount
        cspmb__Discount_Level__c DiscLevl3 = new cspmb__Discount_Level__c();
        DiscLevl3.Name = 'MMC Discount';
        DiscLevl3.cspmb__Discount_Values__c = '1';
        DiscLevl3.Effective_End_Date__c = Date.today()+2;
        DiscLevl3.Effective_Start_Date__c = Date.today()-2;
        DiscLevl3.Is_Delegated__c = true;
        DiscLevl3.account__c = null;
        DiscLevl3.cspmb__Minimum_Discount_Value__c = 1.0;
        DiscLevl3.cspmb__Maximum_Discount_Value__c = 100.0;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl3;

        cspmb__Discount_Association__c DiscAsscociation3 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation3.cspmb__Discount_Level__c = DiscLevl3.Id;
        DiscAsscociation3.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation3;

        cspmb__Discount_Association__c DiscAsscociation12 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation12.cspmb__Discount_Level__c = DiscLevl3.Id;
        DiscAsscociation12.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation12;

        //MRO Bonus Credit Discount
        cspmb__Discount_Level__c DiscLevl4 = new cspmb__Discount_Level__c();
        DiscLevl4.Name = 'MRO Bonus Credit';
        DiscLevl4.cspmb__Discount_Values__c = '1';
        DiscLevl4.Effective_End_Date__c = Date.today()+2;
        DiscLevl4.Effective_Start_Date__c = Date.today()-2;
        DiscLevl4.Is_Delegated__c = true;
        DiscLevl4.account__c = null;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl4;
        test.startTest();
        cspmb__Discount_Association__c DiscAsscociation4 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation4.cspmb__Discount_Level__c = DiscLevl4.Id;
        DiscAsscociation4.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation4;

        cspmb__Discount_Association__c DiscAsscociation13 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation13.cspmb__Discount_Level__c = DiscLevl4.Id;
        DiscAsscociation13.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation13;

        //Mobile Workspace Discount 1
        cspmb__Discount_Level__c DiscLevl5 = new cspmb__Discount_Level__c();
        DiscLevl5.Name = 'Mobile Workspace Discount 1';
        DiscLevl5.cspmb__Discount_Values__c = '1';
        DiscLevl5.Effective_End_Date__c = Date.today()+2;
        DiscLevl5.Effective_Start_Date__c = Date.today()-2;
        DiscLevl5.Is_Delegated__c = true;
        DiscLevl5.account__c = null;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl5;

        cspmb__Discount_Association__c DiscAsscociation5 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation5.cspmb__Discount_Level__c = DiscLevl5.Id;
        DiscAsscociation5.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation5;

        cspmb__Discount_Association__c DiscAsscociation14 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation14.cspmb__Discount_Level__c = DiscLevl5.Id;
        DiscAsscociation14.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation14;

        //Mobile Workspace Discount 2
        cspmb__Discount_Level__c DiscLevl6 = new cspmb__Discount_Level__c();
        DiscLevl6.Name = 'Mobile Workspace Discount 2';
        DiscLevl6.cspmb__Discount_Values__c = '1';
        DiscLevl6.Effective_End_Date__c = Date.today()+2;
        DiscLevl6.Effective_Start_Date__c = Date.today()-2;
        DiscLevl6.Is_Delegated__c = true;
        DiscLevl6.account__c = null;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl6;

        cspmb__Discount_Association__c DiscAsscociation6 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation6.cspmb__Discount_Level__c = DiscLevl6.Id;
        DiscAsscociation6.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation6;

        cspmb__Discount_Association__c DiscAsscociation15 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation15.cspmb__Discount_Level__c = DiscLevl6.Id;
        DiscAsscociation15.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation15;

        //Mobile Workspace Discount 3
        cspmb__Discount_Level__c DiscLevl7 = new cspmb__Discount_Level__c();
        DiscLevl7.Name = 'Mobile Workspace Discount 3';
        DiscLevl7.cspmb__Discount_Values__c = '1';
        DiscLevl7.Effective_End_Date__c = Date.today()+2;
        DiscLevl7.Effective_Start_Date__c = Date.today()-2;
        DiscLevl7.Is_Delegated__c = true;
        DiscLevl7.account__c = null;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl7;

        cspmb__Discount_Association__c DiscAsscociation7 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation7.cspmb__Discount_Level__c = DiscLevl7.Id;
        DiscAsscociation7.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation7;

        cspmb__Discount_Association__c DiscAsscociation16 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation16.cspmb__Discount_Level__c = DiscLevl7.Id;
        DiscAsscociation16.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation16;

        //National Byo Discount
        cspmb__Discount_Level__c DiscLevl8 = new cspmb__Discount_Level__c();
        DiscLevl8.Name = 'National BYO Discount';
        DiscLevl8.cspmb__Discount_Values__c = '1';
        DiscLevl8.Effective_End_Date__c = Date.today()+2;
        DiscLevl8.Effective_Start_Date__c = Date.today()-2;
        DiscLevl8.Is_Delegated__c = true;
        DiscLevl8.account__c = null;
        // DiscLevl.Check_todays_date__c = true;
        insert DiscLevl8;

        cspmb__Discount_Association__c DiscAsscociation8 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation8.cspmb__Discount_Level__c = DiscLevl8.Id;
        DiscAsscociation8.cspmb__price_item__c = insertPriceItem1.Id;
        insert DiscAsscociation8;

        cspmb__Discount_Association__c DiscAsscociation17 = new cspmb__Discount_Association__c();
        //DiscAsscociation.Name = 'DA-00000411';
        DiscAsscociation17.cspmb__Discount_Level__c = DiscLevl8.Id;
        DiscAsscociation17.cspmb__price_item__c = insertPriceItem.Id;
        insert DiscAsscociation17;

        String planList = '[{"PlanId":"","DPROfferId":"","PlanType":"Voice and Data","Qplan":"Global","MMC":50,"ActivatedSIOs":"1","RecontractingSIOs":"1","MRO":true,"AddOn":"Premium","AddOnID":"","IDDCallPackDiscount":"1","IDDCallPackDiscountID":"","MobileWorkspaceDiscount1":"Yes","MobileWorkspaceDiscount3":"Yes","MobileWorkspaceDiscount2":"Yes","MMCDiscount":"1","MMCDiscountExGST":"0.75","ActivationCreditsMonthsDiscount":"1","RecontractingCreditsMonthsDiscount":"1","RecontractingCMDiscountID":"","MROBonusCredit":"10","MROBonusCreditID":"","NationalBYODiscount":"Yes","addOnCount":2}]';
        //  String planList='[{"discountValue":"10","reccharge":"8","mmc":"4","Idd":"20","mobileWorkspaceDiscount":"Mobile Workspace Discount 2","MROBonCred":"41","QPlan":"Global","PlanType":"Voice and Data","reconstracting":"5","activation":"4","addOn":"Premium","activationCreditMonth":"4","recontractCredmonth":"4","MMCdisc":"4"}]';
        //planList.add(plan);
        //test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.upsertPlanAndDiscount(planList,'Corporate Mobile Plus','MRO/BYO','FairPlay Data','3 GB',insertDelegatedPricingRequest.Id,objDPROffer.Id));
        System.assertNotEquals(NULL, DelegatedPricingController.upsertPlanAndDiscount(planList,'Corporate Mobile Plus','MRO/BYO','Committed Data','3 GB',insertDelegatedPricingRequest.Id,objDPROffer.Id));
        System.assertNotEquals(NULL, DelegatedPricingController.upsertPlanAndDiscount(planList,'Corporate Mobile Plus','MRO/BYO','Committed Data','3 GB',insertDelegatedPricingRequest.Id,dprOfferId));
        System.assertNotEquals(NULL, DelegatedPricingController.upsertDPROffer(insertDelegatedPricingRequest.Id,dprOfferId,'Corporate Mobile Plus','MRO/BYO','FairPlay Data','3 GB'));
        System.assertNotEquals(NULL, DelegatedPricingController.getEditScreenWrapper(insertDelegatedPricingRequest.Id,dprOfferId));
        System.assertNotEquals(NULL, DelegatedPricingController.fetchPickValues('Corporate Mobile Plus'));
        System.assertNotEquals(NULL, DelegatedPricingController.fetchMinMaxValuesForDiscounts());
        test.stopTest();
        //String planList1='[{"discountValue":"10","reccharge":"8","mmc":"4","Idd":"20","mobileWorkspaceDiscount":"Mobile Workspace Discount 2","MROBonCred":"41","plan":"Global","reconstracting":"5","activation":"4","addOn":"Premium","activationCreditMonth":"4","recontractCredmonth":"4","MMCdisc":"4"}]';
        insertDelegatedPricingRequest.Deal_Status__c = 'Pending';
        update insertDelegatedPricingRequest;
        // test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.upsertPlanAndDiscount(planList,'Corporate Mobile Plus','MRO/BYO','FairPlay Data','3 GB',insertDelegatedPricingRequest.Id,objDPROffer.Id));

        // test.stopTest();

    }

    /* @istest
       Public static void fetchDataOnPlanTypeAndPlanDTest(){
          cspmb__Price_Item__c  getplans= new cspmb__Price_Item__c();
          getplans.Plan__c ='Local';
          getplans.name='Corporate Mobile Plus';
          getplans.Plan_Type__c ='Voice and Data';
          getplans.cspmb__Recurring_Charge__c = 2;
          getplans.Offer_Id__c = 'DMCAT_Offer_000646';
          getplans.Offer__c='FairPlay Data';
          //getplans.Check_todays_date__c = true;
          insert getplans;
          test.startTest();
          System.assertNotEquals(NULL, DelegatedPricingController.fetchDataOnPlanTypeAndPlanD('Voice and Data','Local BYO'));
          test.stopTest();
        } */
    @istest
    Public static void fetchCommercialProductTest(){
        cspmb__Price_Item__c getplans = new cspmb__Price_Item__c();
        getplans.Plan__c = 'Local';
        getplans.name = 'Corporate Mobile Plus';
        getplans.Plan_Type__c = 'Voice and Data';
        getplans.cspmb__Recurring_Charge__c = 2;
        getplans.Offer_Id__c = 'DMCAT_Offer_000646';
        insert getplans;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.fetchCommercialProduct(1));
        test.stopTest();
    }

    /* @istest
       Public static void getCommitteddataplanTest(){
         Marketable_Offer__c marketableObj=new Marketable_Offer__c();
         marketableObj.Offer_ID__c ='DMCAT_Offer_000646';
         insert marketableObj;
         cspmb__Price_Item__c  getplans= new cspmb__Price_Item__c();
         getplans.name='Corporate Mobile Plus';
         getplans.Offer_Id__c = 'DMCAT_Offer_000646';
         getplans.cspmb__Price_Item_Code__c ='Committed Data';
         getplans.Offer_Type__c='Committed Data';
         insert getplans;

         test.startTest();
         System.assertNotEquals(NULL, DelegatedPricingController.getCommitteddataplan('Corporate Mobile Plus','Committed Data'));

         test.stopTest();

       } */

    @isTest
    public static void getDPROfferlistTest(){
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        // insertDelegatedPricingRequest.Opportunity__c =orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.getDPROfferlist(insertDelegatedPricingRequest.Id));
        test.stopTest();
    }

    @isTest
    public static void deleteDPROfferByIdTest(){
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        //insertDelegatedPricingRequest.Opportunity__c =orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.deleteDPROfferById(insertDelegatedPricingRequest.Id));
        test.stopTest();
    }

    @isTest
    public static void   fetchDelegatedPricingCurrentLoggedUserTest(){
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Deal_Status__c = 'Draft';
        insertDelegatedPricingRequest.is_Deal_Escalated__c = False;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';

        insert insertDelegatedPricingRequest;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.fetchDelegatedPricingCurrentLoggedUser(insertDelegatedPricingRequest.id));
        test.stopTest();

    }
    @isTest
    public static void getDealScoreFromPREServerTest(){
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        //insertDelegatedPricingRequest.Opportunity__c =orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        String correlationId = DelegatedPricingController.getDPRCorrelationID();
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.getDealScoreFromPREServer(insertDelegatedPricingRequest.id,correlationId));
        test.stopTest();

    }
    @isTest
    public static void getDelegationUserTest() {

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        //insertDelegatedPricingRequest.Opportunity__c =orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        test.startTest();
        System.assertNotEquals(NULL, DelegatedPricingController.getDelegationUser(insertDelegatedPricingRequest.id));
        test.stopTest();

    }

    @istest
    Public static void getRDTest(){
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft');
        insert dpr;

        DPR_Offer__c dprOffer = new DPR_Offer__c(ActualOfferPrice__c = 100,
                                                 PoorMinimalValue__c = 200,
                                                 MinimalMarginalValue__c = 300,
                                                 MarginalGoodValue__c = 400,
                                                 GoodBetterValue__c = 500,
                                                 BetterBestValue__c = 600,
                                                 BestMaxValue__c = 700,
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer;
        String offerId = dprOffer.Id;
        test.startTest();

        //DPR_Offer__c dprOfferlist = DelegatedPricingController.getDPROfferDetails(offerId);
        List<String> finalDelegationOutcomeList = DelegatedPricingController.getFinalDelegationOutcome(dpr.id);
        system.assertNotEquals(NULL, finalDelegationOutcomeList);
        List<DPR_Delegation_Outcome__c> modifiedDelOutList = DelegatedPricingController.getDelegationOutcomeTable(dpr.id);
        system.assertNotEquals(NULL, modifiedDelOutList);
        List<DPR_Offer_Line_Item__c> offerRecordLineItemList = DelegatedPricingController.getOfferPlans(offerId);
        system.assertNotEquals(NULL, offerRecordLineItemList);
        test.stopTest();

    }

    @isTest
    public static void fetchMMCTest(){
        cspmb__Price_Item__c PriceItem = new cspmb__Price_Item__c();
        PriceItem.cspmb__Recurring_Charge__c = 50;
        PriceItem.Type__c = 'Voice and Data';
        PriceItem.Plan__c = 'Local';
        insert PriceItem;

        test.startTest();
        system.assertNotEquals(NULL, DelegatedPricingController.fetchMMC('Voice and Data','Local'));
        test.stopTest();

    }

    @isTest
    public static void fetchGroupMemberTest(){
        test.startTest();
        system.assertNotEquals(NULL, DelegatedPricingController.fetchGroupMember());
        test.stopTest();
    }

    @isTest
    public static void insertOpportunityTeamMemberTest()
    {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        //OpportunityTeamMember OppTeamMember = new OpportunityTeamMember();
        List<OpportunityTeamMember> OppTeamMemberList = [Select ID, UserId, OpportunityAccessLevel, OpportunityId from OpportunityTeamMember where OpportunityId  =:orpportunityDetailsRecord.id];
        test.startTest();
        if(!OppTeamMemberList.isEmpty())
        DelegatedPricingController.insertOpportunityTeamMember(orpportunityDetailsRecord.Id, OppTeamMemberList.get(0).UserId);
        System.assertNotEquals(NUll, orpportunityDetailsRecord.Id);
        test.stopTest();
    }

    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    @isTest
    public static void insertContractJunctionTest()
    {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Approved',Opportunity__c = orpportunityDetailsRecord.Id);
        insert dpr;
        Delegated_Pricing_Request__c dpr2 = [Select Name, id,Deal_Status__c,Opportunity__c from Delegated_Pricing_Request__c where id =: dpr.Id];
        test.startTest();
        String contJuncId = DelegatedPricingController.insertContJunc(dpr2);
        Case relatedCase = new Case(Deal__c = dpr2.id, ContractJunction__c = contJuncId);
        insert relatedCase;
        Opportunity opprtyRecord = [Select id,StageName from Opportunity where id =:orpportunityDetailsRecord.id];
        System.assertNotEquals(null, opprtyRecord.StageName);
        DelegatedPricingController.rejectContract(dpr2.id);
        test.stopTest();
    }
    public Static Id CSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Support').getRecordTypeId();
    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    @isTest
    public static void getContractSupportCaseRecordTypeTest()
    {
        Id contractJunctionRecordTypeId = DelegatedPricingController.getContractSupportCaseRecordType();

        System.assertEquals(CSRecordTypeId, contractJunctionRecordTypeId);
    }
//EDGE:123784 | Generate the pricing contract after the deal has been approved.
    @isTest
    public static void getcaserecordTest()
    {
        string objectName1='test';
        string strRecordTypeName1='test1';
        Id contractJunctionRecordTypeId = DelegatedPricingController.getRecordTypeIdbyName(objectName1, strRecordTypeName1);

        System.assertNotEquals(CSRecordTypeId, contractJunctionRecordTypeId);
    }
    //Start EDGE-145563: Code coverage for fetchDataPlanCharge
    @isTest
    public static void fetchDataPlanChargeTestPostive()
    {
        List<cspmb__Price_Item__c> cpiList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c insertPriceItem = new cspmb__Price_Item__c();
        insertPriceItem.Plan__c = 'Global';
        insertPriceItem.cspmb__Recurring_charge__c = 27.3;
        insertPriceItem.offer_type__c = 'Committed Data';
        insertPriceItem.offer__c = 'Committed Data';
        insertPriceItem.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItem.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItem.Type__c = 'Data';
        cpiList.add(insertPriceItem);
        insert cpiList;
        String plan = 'Global';
        Test.startTest();
        Decimal result = DelegatedPricingController.fetchDataPlanCharge(plan);
        System.assertEquals(result,27.3);
        Test.stopTest();
    }

    @isTest
    public static void fetchDataPlanChargeTestNegative()
    {
        String plan = 'Global';
        Test.startTest();
        Decimal result = DelegatedPricingController.fetchDataPlanCharge(plan);
        System.assertEquals(result,null);
        Test.stopTest();
    }
    //End of EDGE-145563

    @isTest
    public static void checkInitContTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        List<cspmb__Price_Item__c> cpiList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c insertPriceItem = new cspmb__Price_Item__c();
        insertPriceItem.Plan__c = 'Global';
        insertPriceItem.cspmb__Recurring_charge__c = 27.3;
        insertPriceItem.offer_type__c = 'Committed Data';
        insertPriceItem.offer__c = 'Committed Data';
        insertPriceItem.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItem.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItem.Type__c = 'Data';
        cpiList.add(insertPriceItem);
        insert cpiList;
        String planType = 'Data';
        String plan = 'Global';

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.deal_status__c = 'Contract Initiated';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insert insertDelegatedPricingRequest;
        Test.startTest();
        Boolean result = DelegatedPricingController.checkInitCont(insertDelegatedPricingRequest.id);
        Boolean resultValue = DelegatedPricingController.getSentForApprovalDPR(orpportunityDetailsRecord.id);
        cspmb__Price_Item__c resultPlan = DelegatedPricingController.fetchDataOnPlanTypeAndPlanD(planType,plan);
        Test.stopTest();
        System.assertNotEquals(result,false);
    }
    //Start of EDGE--145558: code coverage for fetchAddonDataCharge

    @isTest
    public static void fetchAddonDataChargeTestPostive()
    {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        cspmb__Price_Item__c insertPriceItem = new cspmb__Price_Item__c();
        insertPriceItem.Plan__c = 'Basic';
        insertPriceItem.cspmb__Recurring_charge__c = 15;
        insertPriceItem.offer_type__c = 'Committed Data';
        insertPriceItem.offer__c = 'Committed Data';
        insertPriceItem.cspmb__Price_Item_Code__c = 'Corporate Mobile Plus';
        insertPriceItem.Commercial_Product_Code__c = 'Corporate Mobile Plus';//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        insertPriceItem.Type__c = 'Voice and Data';
        insert insertPriceItem;

        cspmb__Add_On_Price_Item__c insertAddonPriceItem = new cspmb__Add_On_Price_Item__c();
        insertAddonPriceItem.Name = 'Premium';
        insertAddonPriceItem.cspmb__Recurring_Charge__c = 15;
        insertAddonPriceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_000263';
        insert insertAddonPriceItem;

        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Add_On_Price_Item__c = insertAddonPriceItem.id,cspmb__Price_Item__c = insertPriceItem.id,cspmb__Recurring_Charge__c = 10);
        insert addonassoc1;

        String plan = 'Premium';
        String planDataValue = 'Basic';
        Test.startTest();
        Decimal result = DelegatedPricingController.fetchAddonDataCharge(plan,planDataValue);
        System.assertEquals(result,10);
        Test.stopTest();
    }

    @isTest
    public static void fetchAddonDataChargeTestNegative()
    {
        String plan = 'Premium';
        String planDataValue = 'Global';
        Test.startTest();
        Decimal result = DelegatedPricingController.fetchAddonDataCharge(plan,planDataValue);
        System.assertEquals(result,null);
        Test.stopTest();
    }
    
    @isTest
    public static void updateDelpricRequestTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        
       csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
         fam.Opportunity__c=orpportunityDetailsRecord.id;
       fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
      insert fam;
        
        Test.startTest();
     
      
        DelegatedPricingController cntrl = new DelegatedPricingController();
        DelegatedPricingController.updateDelPriReq(insertDelegatedPricingRequest.Id);
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('method','getDocuSignRestrictedFlag');
        inputMAp.put('acId',a.Id);
        String param =  JSON.serialize(inputMap);
        cntrl.performAction(param);
        //EDGE-190520 FAM Contract Initiation
        /*DelegatedPricingController.insertContJuncFA(fam.Id, null, null);
        DelegatedPricingController.fetchFAPricingRequest(fam.Id);
        DelegatedPricingController.getDocuSignRestrictedFlag(a.Id); 
   
        
        DelegatedPricingController.updatefaPri(fam.Id);
        Delegated_Pricing_Request__c dpr = [select Id from Delegated_Pricing_Request__c LIMIT1];
        System.assertEquals(insertDelegatedPricingRequest.Id, dpr.Id);*/
        Test.stopTest();
        //System.assertEquals(insertFrameAgreement.Id, dpr.Id);
    }
    
    @isTest
    public static void updateDelpricRequestTest_2(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        Test.startTest();
       csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
         fam.Opportunity__c=orpportunityDetailsRecord.id;
       fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
      insert fam;
        
        
     
      
        /*DelegatedPricingController cntrl = new DelegatedPricingController();
        DelegatedPricingController.updateDelPriReq(insertDelegatedPricingRequest.Id);
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('method','getDocuSignRestrictedFlag');
        inputMAp.put('acId',a.Id);
        String param =  JSON.serialize(inputMap);
        cntrl.performAction(param);*/
        //EDGE-190520 FAM Contract Initiation
        DelegatedPricingController.insertContJuncFA(fam.Id, null, null,null);
        //DelegatedPricingController.fetchFAPricingRequest(fam.Id);
        //DelegatedPricingController.getDocuSignRestrictedFlag(a.Id); 
   
        
        /*DelegatedPricingController.updatefaPri(fam.Id);
        Delegated_Pricing_Request__c dpr = [select Id from Delegated_Pricing_Request__c LIMIT1];
        System.assertEquals(insertDelegatedPricingRequest.Id, dpr.Id);
        Test.stopTest();*/
        //System.assertEquals(insertFrameAgreement.Id, dpr.Id);
    }
    
    @isTest
    public static void updateDelpricRequestTest_3(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        
       csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
         fam.Opportunity__c=orpportunityDetailsRecord.id;
       fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
      insert fam;
        
        Test.startTest();
     
      
        /*DelegatedPricingController cntrl = new DelegatedPricingController();
        DelegatedPricingController.updateDelPriReq(insertDelegatedPricingRequest.Id);
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('method','getDocuSignRestrictedFlag');
        inputMAp.put('acId',a.Id);
        String param =  JSON.serialize(inputMap);
        cntrl.performAction(param);
        //EDGE-190520 FAM Contract Initiation
        DelegatedPricingController.insertContJuncFA(fam.Id, null, null);*/
        DelegatedPricingController.fetchFAPricingRequest(fam.Id);
        DelegatedPricingController.getDocuSignRestrictedFlag(a.Id); 
   
        
        DelegatedPricingController.updatefaPri(fam.Id);
        Delegated_Pricing_Request__c dpr = [select Id from Delegated_Pricing_Request__c LIMIT1];
        System.assertEquals(insertDelegatedPricingRequest.Id, dpr.Id);
        Test.stopTest();
        //System.assertEquals(insertFrameAgreement.Id, dpr.Id);
    }
    
    @isTest
    public static void updateDelpricRequestTest_4(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        
        Test.startTest();
       csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
         fam.Opportunity__c=orpportunityDetailsRecord.id;
       fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
      insert fam;
        
        
     
      
        /*DelegatedPricingController cntrl = new DelegatedPricingController();
        DelegatedPricingController.updateDelPriReq(insertDelegatedPricingRequest.Id);
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('method','getDocuSignRestrictedFlag');
        inputMAp.put('acId',a.Id);
        String param =  JSON.serialize(inputMap);
        cntrl.performAction(param);
        //EDGE-190520 FAM Contract Initiation
        DelegatedPricingController.insertContJuncFA(fam.Id, null, null);
        DelegatedPricingController.fetchFAPricingRequest(fam.Id);*/
        DelegatedPricingController.getDocuSignRestrictedFlag(a.Id); 
   
        
        DelegatedPricingController.updatefaPri(fam.Id);
        Delegated_Pricing_Request__c dpr = [select Id from Delegated_Pricing_Request__c LIMIT1];
        System.assertEquals(insertDelegatedPricingRequest.Id, dpr.Id);
        Test.stopTest();
        //System.assertEquals(insertFrameAgreement.Id, dpr.Id);
    }

    //End of EDGE--145558
    static testMethod void VerifygetDPROfferRecords() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Contact c = new Contact();
        c.FirstName = 'Paul';
        c.LastName  = 'Test';
        c.AccountId = a.id;
        c.MailingStreet = '298 S. Ringo Street';
        c.MailingCity = 'Little Rock';
        c.MailingState = 'AR';
        c.MailingPostalCode = '72201'; 
        insert c;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        orpportunityDetailsRecord.Contract_Term__c = 36;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
        insertDelegatedPricingRequest.Tech_Reward_Type__c = 'Advance';
        insert insertDelegatedPricingRequest;
                
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c = UserInfo.getUserId();
        fam.csconta__Status__c = 'Active';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        fam.csconta__Account__c=a.Id;
        fam.Mark_as_Variation__c = false;
        fam.csconta__effective_start_date__c = DateTime.now(); 
        fam.csconta__effective_end_date__c = DateTime.now().addMonths(36);
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        dpo.Fund_Increment_Frequency__c = 'Annual In Advance';
        dpo.Fund_Amount__c = 9000;
        insert dpo;
        
        Test.startTest();
        List<DPR_Offer__c> Dpr_offer_list = DelegatedPricingController.getDPROfferRecords(fam.Id);
        System.assert(Dpr_offer_list.size()==1);
        Dpr_offer_list = DelegatedPricingController.getDPROfferRecords('123456');
        //System.assertEquals(Dpr_offer_list,null);
        Test.stopTest();
    }
    @isTest static void AgreementDecisionException(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insert insertDelegatedPricingRequest;
        Test.startTest();
        String exceptionDesc;
        try{
            
            AgreementUtilities.AgreementDecision agmtDecResult = DelegatedPricingController.resolveSAType(insertDelegatedPricingRequest.id);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
         
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }

}