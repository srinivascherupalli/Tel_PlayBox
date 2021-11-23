/***********************************************************************************************
Name          : SCAddressSearchControllerTest
Created By    : Mahaboob Basha
Created Date  : Jun 17 2019
Description   : This is a test class to simulate and test the logic of SCAddressSearchController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        17-06-2019      Created
1.1         Mahaboob        17-06-2019      Added methods SCAddressSearchControllerTest
1.2         Mahaboob        03-07-2019      Added methods SCAddressSearchControllerTest1
                                                        , runSearchTest, runSearchTest1
                                                        , runSearchTest2, makeSQCalloutTest
                                                        , makeSQCalloutTest1
                                                        , saveSelectedSitesToSfdcTest
                                                        , saveSelectedSitesToSfdcTest1
1.3         Pawan           27-09-2019      Added methods makeSQCalloutTest3
                                                        , SCAddressSearchControllerTest2
                                                        , getCustomerSitesV2Test
                                                        , getCustomerSitesTest   
1.4         Samish          30-11-2019      Modified for EDGE-98322
***********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SCAddressSearchControllerTest {
    
    /**********************************************************************************************
    * Method Name : SCAddressSearchControllerTest
    * Description : Used to simulate and test the logic of constructor in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    @isTest static void SCAddressSearchControllerTestMethod() {
        Test.startTest();
            SCAddressSearchController scAddr = new SCAddressSearchController();
        Test.stopTest();
        System.assertEquals('No', scAddr.sqCheckEnabled);
    }
    
    /**********************************************************************************************
    * Method Name : SCAddressSearchControllerTest1
    * Description : Used to simulate and test the logic of constructor in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    @isTest static void SCAddressSearchControllerTest1() {
        SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;
        Test.startTest();
            SCAddressSearchController scAddr = new SCAddressSearchController();
        Test.stopTest();
        System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
     @isTest static void makeSQCalloutTest5() {
         Test.startTest();
            SCAddressSearchController scAddr = new SCAddressSearchController();
            SCAddressSearchController.testCheck = true;
            List<String> eligibleAdborIds = new List<String>();
            String token = null;
            String techType = 'Telstra Fibre';
            scAddr.isSQCheckEnabled();
            scAddr.getCustomerSitesV2('Test');
            scAddr.makeSQCallout(techType);
            scAddr.initiateSQService(techType, eligibleAdborIds);
             Map<String,HttpResponse> addressToResponseMap = scAddr.callSQService(token,eligibleAdborIds); //private
            scAddr.clearVar(); //private
            SCAddressSearchController.testCheck = false;
        Test.stopTest();
        System.assertNotEquals(null,addressToResponseMap );
 
 }
    
    /***************************************************************************************************
    * Method Name : runSearchTest
    * Description : Used to simulate and test the logic of runSearch method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************/
    @isTest static void runSearchTest() {
        /*SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;*/
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
      /***************************************************************************************************
    * Method Name : runSearchTestV2
    * Description : Used to simulate and test the logic of runSearch method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************/
        @isTest static void runSearchTestV2() {
        /*SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;*/
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'True');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
    /***************************************************************************************************
    * Method Name : runSearchTest1
    * Description : Used to simulate and test the logic of runSearch method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************/
    @isTest static void runSearchTest1() {
        /*SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;*/
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SCAddressSearchCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
    /***************************************************************************************************
    * Method Name : runSearchTest2
    * Description : Used to simulate and test the logic of runSearch method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************/
    @isTest static void runSearchTest2() {
        /*SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;*/
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '265742187', cscrm__Account__c = acc.Id, cscrm__External_Address_Id__c = '123');
        INSERT addr;
        cscrm__Site__c site = new cscrm__Site__c(cscrm__Installation_Address__c = addr.Id, Composite_Key__c = '1234', cscrm__Account__c = acc.Id);
        INSERT site;
        Service_qualification__c sq = new Service_qualification__c(Address_ID__c = '265742187', Site__c = site.Id);
        INSERT sq;
        
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SCAddressSearchCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
            sq.Technology_Type__c = 'Fibre To The Node';
            UPDATE sq;
            scAddr.runSearch();
            sq.Technology_Type__c = 'Fibre To The Building';
            UPDATE sq;
            scAddr.runSearch();
            sq.Technology_Type__c = 'Fibre To The Curb';
            UPDATE sq;
            scAddr.runSearch();
            /*sq.Technology_Type__c = 'Fibre To The Premise';
            UPDATE sq;
            scAddr.runSearch();*/
            sq.Technology_Type__c = 'Fibre';
            UPDATE sq;
            scAddr.runSearch();
            sq.Technology_Type__c = 'Wireless';
            UPDATE sq;
            scAddr.runSearch();
            sq.Copper_Pair_Indicator__c = 'Yes';
            UPDATE sq;
            scAddr.runSearch();
            sq.Ready_for_Service_Date__c = System.today().addDays(10);
            UPDATE sq;
            scAddr.runSearch();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }

    /**
     * EDGE-108959 Providing coverage for newly introduced methods/logic
     */
    @isTest static void runSearchTest3() {
        SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        UPSERT sqCheck;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '265742187', cscrm__Account__c = acc.Id, cscrm__External_Address_Id__c = '123');
        INSERT addr;
        cscrm__Site__c site = new cscrm__Site__c(cscrm__Installation_Address__c = addr.Id, Composite_Key__c = '12345265742187', cscrm__Account__c = acc.Id);
        INSERT site;
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c(SqCheckNotRequired__c = true, Offer_ID__c = 'DMCAT_Offer_000709');
        insert marketableOffer;
        Service_qualification__c sq = new Service_qualification__c(Address_ID__c = '265742187', Site__c = site.Id);
        INSERT sq;
        
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            pageRef.getParameters().put('offerId', 'DMCAT_Offer_000709');
            pageRef.getParameters().put('adborIds', 'dummyAdborId');
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SCAddressSearchCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
            sq.Technology_Type__c = 'Fibre To The Node';
            UPDATE sq;
            scAddr.runSearch();
            sq.Technology_Type__c = 'Fibre To The Building';
            UPDATE sq;
            scAddr.runSearch();
            sq.Technology_Type__c = 'Fibre To The Curb';
            UPDATE sq;
            scAddr.runSearch();
            /*sq.Technology_Type__c = 'Fibre To The Premise';
            UPDATE sq;
            scAddr.runSearch();*/
            sq.Technology_Type__c = 'Fibre';
            UPDATE sq;
            scAddr.runSearch();
            sq.Technology_Type__c = 'Wireless';
            UPDATE sq;
            scAddr.runSearch();
            sq.Copper_Pair_Indicator__c = 'Yes';
            UPDATE sq;
            scAddr.runSearch();
            sq.Ready_for_Service_Date__c = System.today().addDays(10);
            UPDATE sq;
            scAddr.runSearch();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
    /*******************************************************************************************************
    * Method Name : makeSQCalloutTest
    * Description : Used to simulate and test the logic of makeSQCallout method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    @isTest static void makeSQCalloutTest() {
        SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            List<SCAddressSearchController.AddressSummary> addressList = new List<SCAddressSearchController.AddressSummary>();
            SCAddressSearchController.AddressSummary addrSumm = new SCAddressSearchController.AddressSummary();
            addrSumm.adborID = '262583977';
            addrSumm.addressDisplayName = 'BG 1 L 27 0-0 EAGLE ST BRISBANE CITY QLD 4000';
            addrSumm.addressId = '262583977';
            addrSumm.addressLine1 = null;
            addrSumm.addressLine2 = null;
            addrSumm.addressName = '0 - 0 EAGLE ST BRISBANE CITY';
            addrSumm.addressType = null;
            addrSumm.copperPairIndicator = '';
            addrSumm.ipSiteconfigId = null;
            addrSumm.isSelected = TRUE;
            addrSumm.legacysite = 'Yes';
            addrSumm.nbnAvailability = '';
            addrSumm.nbnCompatibility = '';
            addrSumm.nbnMaxDownloadSpeed = '';
            addrSumm.nbnMaxUploadSpeed = '';
            addrSumm.nbnRFSDate = '';
            addrSumm.nbnTechnologyType = '';
            addrSumm.nbnTechnologyTypeAcrnym = '';
            addrSumm.sqStatus = false;
            addrSumm.sqStatusDesc = '';
            addressList.add(addrSumm);
            scAddr.addressList = addressList;
            scAddr.makeNBNSQCallout();          //changed for EDGE-98322 by Samish
            scAddr.makeTelstraFibreSQCallout();         //added for EDGE-98322 by Samish
            scAddr.saveSelectedSitesToSfdc();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
    /*******************************************************************************************************
    * Method Name : makeSQCalloutTest1
    * Description : Used to simulate and test the logic of makeSQCallout method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    @isTest static void makeSQCalloutTest1() {
        SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SCSQCheckCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            List<SCAddressSearchController.AddressSummary> addressList = new List<SCAddressSearchController.AddressSummary>();
            SCAddressSearchController.AddressSummary addrSumm = new SCAddressSearchController.AddressSummary();
            addrSumm.adborID = '262583977';
            addrSumm.addressDisplayName = 'BG 1 L 27 0-0 EAGLE ST BRISBANE CITY QLD 4000';
            addrSumm.addressId = '262583977';
            addrSumm.addressLine1 = null;
            addrSumm.addressLine2 = null;
            addrSumm.addressName = '0 - 0 EAGLE ST BRISBANE CITY';
            addrSumm.addressType = null;
            addrSumm.copperPairIndicator = '';
            addrSumm.ipSiteconfigId = null;
            addrSumm.isSelected = TRUE;
            addrSumm.legacysite = 'Yes';
            addrSumm.nbnAvailability = '';
            addrSumm.nbnCompatibility = '';
            addrSumm.nbnMaxDownloadSpeed = '';
            addrSumm.nbnMaxUploadSpeed = '';
            addrSumm.nbnRFSDate = '';
            addrSumm.nbnTechnologyType = '';
            addrSumm.nbnTechnologyTypeAcrnym = '';
            addrSumm.sqStatus = false;
            addrSumm.sqStatusDesc = '';
            addressList.add(addrSumm);
            scAddr.addressList = addressList;
            scAddr.makeNBNSQCallout();              //changed for EDGE-98322 by Samish
            scAddr.makeTelstraFibreSQCallout();         //added for EDGE-98322 by Samish
            scAddr.saveSelectedSitesToSfdc();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
 
    /*********************************************************************************************************************
    * Method Name : saveSelectedSitesToSfdcTest
    * Description : Used to simulate and test the logic of saveSelectedSitesToSfdcTest method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************************************/
    @isTest static void saveSelectedSitesToSfdcTest() {
        /*SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;*/
        Map<String,HttpResponse> addressToSQResponseMap = new  Map<String,HttpResponse>() ;
        list <string> adborId = new list<string>();

        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '265742187', cscrm__Account__c = acc.Id, cscrm__External_Address_Id__c = '123');
        INSERT addr;
        cscrm__Site__c site = new cscrm__Site__c(cscrm__Installation_Address__c = addr.Id, Composite_Key__c = '1234', cscrm__Account__c = acc.Id);
        INSERT site;
        Service_qualification__c sq = new Service_qualification__c(Address_ID__c = '265742187', Site__c = site.Id);
        INSERT sq;
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SCAddressSearchCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
            scAddr.addressList[0].isSelected = TRUE;
            scAddr.allowedToAdd = 'Yes';
            scAddr.sqRecordToBeInserted=new List<Service_Qualification__c>();
            Service_Qualification__c sqRecord=new Service_Qualification__c();
            adborId.add('265742187');
            sqRecord.Address_ID__c='265742187';
            scAddr.addressToSQResponseMap = scAddr.initiateSQService ('NBN',adborId);
            System.debug('addressToSQResponseMaptest'+ addressToSQResponseMap);
            scAddr.sqRecordToBeInserted.add(sqRecord);        
            scAddr.saveSelectedSitesToSfdc();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }

    /*********************************************************************************************************************
    * Method Name : saveSelectedSitesToSfdcTest2
    * Description : Used to simulate and test the logic of saveSelectedSitesToSfdcTest method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************************************/
    @isTest static void saveSelectedSitesToSfdcTest2() {
        /*SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;*/
        Map<String,HttpResponse> addressToSQResponseMap = new  Map<String,HttpResponse>() ;
        list <string> adborId = new list<string>();

        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '265742187', cscrm__Account__c = acc.Id, cscrm__External_Address_Id__c = '123');
        INSERT addr;
        cscrm__Site__c site = new cscrm__Site__c(cscrm__Installation_Address__c = addr.Id, Composite_Key__c = '1234', cscrm__Account__c = acc.Id);
        INSERT site;
        Service_qualification__c sq = new Service_qualification__c(Address_ID__c = '265742187', Site__c = site.Id);
        INSERT sq;
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;
        
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SiteSqContractCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
            scAddr.addressList[0].isSelected = TRUE;
            scAddr.allowedToAdd = 'Yes';
            scAddr.sqRecordToBeInserted=new List<Service_Qualification__c>();
            Service_Qualification__c sqRecord=new Service_Qualification__c();
            adborId.add('265742187');
            sqRecord.Address_ID__c='265742187';
            scAddr.addressToSQResponseMap = scAddr.initiateSQService ('NBN',adborId);
            System.debug('addressToSQResponseMaptest'+ addressToSQResponseMap);
            scAddr.sqRecordToBeInserted.add(sqRecord);        
            scAddr.saveSelectedSitesToSfdc();

        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
    
    /*****************************************************************************************************************
    * Method Name : saveSelectedSitesToSfdcTest1
    * Description : Used to simulate and test the logic of saveSelectedSitesToSfdc method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    *****************************************************************************************************************/
    @isTest static void saveSelectedSitesToSfdcTest1() {
        SQ_Check_Enablement__c sqCheck = new SQ_Check_Enablement__c(Name = 'SQ Check', Is_SQ_Check_Enabled__c = TRUE);
        INSERT sqCheck;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            List<SCAddressSearchController.AddressSummary> addressList = new List<SCAddressSearchController.AddressSummary>();
            SCAddressSearchController.AddressSummary addrSumm = new SCAddressSearchController.AddressSummary();
            addrSumm.adborID = '262583977';
            addrSumm.addressDisplayName = 'BG 1 L 27 0-0 EAGLE ST BRISBANE CITY QLD 4000';
            addrSumm.addressId = '262583977';
            addrSumm.addressLine1 = null;
            addrSumm.addressLine2 = null;
            addrSumm.addressName = '0 - 0 EAGLE ST BRISBANE CITY';
            addrSumm.addressType = null;
            addrSumm.copperPairIndicator = '';
            addrSumm.ipSiteconfigId = null;
            addrSumm.isSelected = TRUE;
            addrSumm.legacysite = 'Yes';
            addrSumm.nbnAvailability = '';
            addrSumm.nbnCompatibility = '';
            addrSumm.nbnMaxDownloadSpeed = '';
            addrSumm.nbnMaxUploadSpeed = '';
            addrSumm.nbnRFSDate = '';
            addrSumm.nbnTechnologyType = '';
            addrSumm.nbnTechnologyTypeAcrnym = '';
            addrSumm.sqStatus = false;
            addrSumm.sqStatusDesc = '';
            addressList.add(addrSumm);
            scAddr.addressList = addressList;
            scAddr.saveSelectedSitesToSfdc();
            scAddr.sqCheckRequired = 'Yes';
            scAddr.sqCheckCompleted = 'No';
            scAddr.saveSelectedSitesToSfdc();
            scAddr.allowedToAdd = 'Yes';
            scAddr.saveSelectedSitesToSfdc();
            scAddr.addressList[0].nbnAvailability = 'Available';
            scAddr.saveSelectedSitesToSfdc();
            sqCheck.Is_SQ_Check_Enabled__c = FALSE;
            UPDATE sqCheck;
            scAddr = new SCAddressSearchController();
            scAddr.addressList = addressList;
            scAddr.saveSelectedSitesToSfdc();
        Test.stopTest();
        System.assertEquals(true, scAddr.selectedAddressList!=null);
        //System.assertEquals('Yes', scAddr.sqCheckEnabled);
    }
    
    
  /**********************************************************************************************
    * Method Name : makeSQCalloutTest3
    * Description : Used to simulate and test the logic of makeSQCallout method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
   @isTest static void makeSQCalloutTest3() {

      Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', null);
            cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
            basket.csbb__Account__c = basket.csordtelcoa__Account__c;
            UPDATE basket;
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new SCSQCheckCalloutMock());
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.makeNBNSQCallout();              //changed for EDGE-98322 by Samish
            scAddr.makeTelstraFibreSQCallout();         //added for EDGE-98322 by Samish
            scAddr.saveSelectedSitesToSfdc();
            Test.stopTest();System.debug('PD1 '+scAddr.selectedAddressList);
            System.assertEquals(true, scAddr.selectedAddressList!=null);
            
        
    }
    
 /**********************************************************************************************
    * Method Name : SCAddressSearchControllerTest2
    * Description : Used to simulate and test the logic of constructor in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    @isTest static void SCAddressSearchControllerTest2() {
        SQ_Check_Enablement__c sqCheck = null;
        Test.startTest();
            SCAddressSearchController scAddr = new SCAddressSearchController();
        Test.stopTest();System.debug('PD2 '+scAddr.sqCheckEnabled);
         System.assertEquals('No', scAddr.sqCheckEnabled);
      
    }
    
    /**********************************************************************************************
    * Method Name : getCustomerSitesV2Test
    * Description : Used to simulate and test the logic of getCustomerSitesV2 method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
   @isTest static void getCustomerSitesV2Test() {
       
       cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'true');
        insert envrn;

      Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            
            SCSQCheckCalloutMock sCSQCheckCalloutMock = new SCSQCheckCalloutMock(IntegrationRecordHandlerUtil.ERROR_500_CODE,'Complete','sForceTest1',null);
            Test.setMock(HttpCalloutMock.class, sCSQCheckCalloutMock );
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
            
            SCSQCheckCalloutMock  sCSQCheckCalloutMock1 = new SCSQCheckCalloutMock(IntegrationRecordHandlerUtil.ERROR_404_CODE,'Complete','sForceTest1',null);
            Test.setMock(HttpCalloutMock.class, sCSQCheckCalloutMock1 );
            scAddr.runSearch();
            
            SCSQCheckCalloutMock  sCSQCheckCalloutMock2 = new SCSQCheckCalloutMock(IntegrationRecordHandlerUtil.ERROR_503_CODE,'Complete','sForceTest1',null);
            Test.setMock(HttpCalloutMock.class, sCSQCheckCalloutMock2 );
            scAddr.runSearch();
            
        Test.stopTest();System.debug('PD3 '+scAddr.selectedAddressList);
        System.assertEquals(true, scAddr.selectedAddressList!=null);
     
    }
      
      
  /**********************************************************************************************
    * Method Name : getCustomerSitesTest
    * Description : Used to simulate and test the logic of getCustomerSites method in SCAddressSearchController
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
   @isTest static void getCustomerSitesTest() {
    cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        Account acc = new Account(Id = basket.csbb__Account__c, CIDN__c = '12345', Enterprise_ID__c = '12345');
        UPDATE acc;
        
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='Enable_GetSiteReplicatorV2', Value__c = 'false');
        insert envrn;

      Test.startTest();
            PageReference pageRef = Page.SCAddressSearchPage;
            pageRef.getParameters().put('basketId', basket.Id);
            Test.setCurrentPage(pageRef);
            SCSQCheckCalloutMock sCSQCheckCalloutMock = new SCSQCheckCalloutMock(IntegrationRecordHandlerUtil.ERROR_500_CODE,'Complete','sForceTest1',null);
            Test.setMock(HttpCalloutMock.class, sCSQCheckCalloutMock );
            SCAddressSearchController scAddr = new SCAddressSearchController();
            scAddr.runSearch();
            
            SCSQCheckCalloutMock  sCSQCheckCalloutMock1 = new SCSQCheckCalloutMock(IntegrationRecordHandlerUtil.ERROR_404_CODE,'Complete','sForceTest1',null);
            Test.setMock(HttpCalloutMock.class, sCSQCheckCalloutMock1 );
            scAddr.runSearch();
            
            SCSQCheckCalloutMock  sCSQCheckCalloutMock2 = new SCSQCheckCalloutMock(IntegrationRecordHandlerUtil.ERROR_503_CODE,'Complete','sForceTest1',null);
            Test.setMock(HttpCalloutMock.class, sCSQCheckCalloutMock2 );
            scAddr.runSearch();
            
        Test.stopTest();System.debug('PD4 '+scAddr.selectedAddressList);
        System.assertEquals(true, scAddr.selectedAddressList!=null);
      }

      
}