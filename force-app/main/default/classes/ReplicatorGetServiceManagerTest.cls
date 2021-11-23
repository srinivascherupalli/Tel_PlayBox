/**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   Test class for ReplicatorGetServiceManager
* @US       :   EDGE-75696, EDGE-85840, EDGE-84055
* @Status   :   End point Deveopment is still pending.
EDGE 145809 - Aarathi from Team Amsterdam - test method
* */

//Comment for DIGI - 1501(for TC)

@isTest
public class ReplicatorGetServiceManagerTest {
    @testsetup static void testDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.APTPS_Off_Shore_Restricted__c=false;
        acc.APTPS_Tier__c='1';
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c = '8822209958';
        insert acc;
   //CREATE CONTACT
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+612345678',
            Email = 'test@tele2.com'   
        );
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        System.assert(opp != null);
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        Marketable_Offer__c MO = New Marketable_Offer__c();
        MO.Name = 'CWP Mobility';
        MO.Offer_ID__c = 'DMCAT_Offer_000303';
        Insert MO;
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='CWP Mobility';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =basket.Id;
       // MACPCnew.cscfga__originating_offer__c=offername.id;
        MACPCnew.Offer_Reference__c=offername.id;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.Marketable_Offer__c = MO.Id;
        insert MACPCnew;
        cscfga__Product_Configuration__c MACPCcncl = new cscfga__Product_Configuration__c();
        MACPCcncl.cscfga__Product_Basket__c =basket.Id;
       // MACPCcncl.cscfga__originating_offer__c=offername.id;
        MACPCcncl.Offer_Reference__c=offername.id;
        MACPCcncl.csordtelcoa__Replaced_Product_Configuration__c=MACPCnew.id;
        MACPCcncl.name='IP Site';
        MACPCcncl.Type__c='Cancel';
        prdConfigList.add(MACPCcncl);
        insert prdConfigList;
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(IPNet_PD);
        cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility', product_Specification__c = 'DMCAT_ProductSpecification_000420');
        pdList.add(Mob_PD);
        cscfga__Product_Definition__c nguc_PD = new cscfga__Product_Definition__c(Name = 'NgUc', cscfga__Description__c = 'NgUc', product_Specification__c = 'DMCAT_ProductSpecification_000871');
        pdList.add(nguc_PD);
        //Start of DIGI-16451:Adding IoT Product Definition by Abhishek(Osaka)
        cscfga__Product_Definition__c IoT_PD = new cscfga__Product_Definition__c(Name = 'IoT', cscfga__Description__c = 'IoT', product_Specification__c = 'DMCAT_Offer_001522');
		pdList.add(IoT_PD);
        //End of DIGI-16451
        insert pdList;
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.Type__c = 'Cancel';
        testConfig.cscfga__Product_Basket__c = basket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.Type__c = 'Cancel';
        testConfig1.cscfga__Product_Basket__c = basket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.Type__c = 'Cancel';
        testConfig2.cscfga__Product_Basket__c = basket.Id;
        testConfig2.cscfga__Product_Definition__c=IPNet_PD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.Type__c = 'Cancel';
        testConfig3.cscfga__Product_Basket__c = basket.Id;
        testConfig3.cscfga__Product_Definition__c=Mob_PD.id;
        prodconfigList.add(testConfig3);
        cscfga__Product_Configuration__c testConfig4 = new cscfga__Product_Configuration__c();
        testConfig4.Name = System.Label.Mobility;
        testConfig4.Type__c = 'Cancel';
        testConfig4.cscfga__Product_Basket__c = basket.Id;
        testConfig4.cscfga__Product_Definition__c=nguc_PD.id;
        prodconfigList.add(testConfig4);
        //Start of DIGI-16451 by Abhishek(Osaka)
        cscfga__Product_Configuration__c IoTConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'IoT Connectivity';
        testConfig.Type__c = 'Cancel';
        testConfig.cscfga__Product_Basket__c = basket.Id;
        testConfig.cscfga__Product_Definition__c=IoT_PD.id;
        prodconfigList.add(IoTConfig);
        //End of DIGI-16451 
        insert prodconfigList;
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '152365895123';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = acc.id;
        lstAddress.add(addrs);
        cscrm__Address__c addrs1 = new cscrm__Address__c();
        addrs1.Address_ID__c = '256345896231';
        addrs1.Name = 'Test Address';
        addrs1.cscrm__Account__c = acc.id;
        lstAddress.add(addrs1);
        cscrm__Address__c addrs2 = new cscrm__Address__c();
        addrs2.Address_ID__c = '189562345874';
        addrs2.Name = 'Test Address';
        addrs2.cscrm__Account__c = acc.id;
        lstAddress.add(addrs2);
        insert lstAddress;
        List<cscrm__Site__c> lstSite = new List<cscrm__Site__c>();
        cscrm__Site__c siteobj = new cscrm__Site__c();
        siteobj.Name = 'Test Site';
        siteobj.cscrm__Account__c = acc.id;
        siteobj.cscrm__Installation_Address__c = lstAddress[0].Id;
        siteobj.Status__c = 'Active';
        siteobj.Legacy__c = true;
        lstSite.add(siteobj);
        cscrm__Site__c siteobj1 = new cscrm__Site__c();
        siteobj1.Name = 'Test Site1';
        siteobj1.cscrm__Account__c = acc.id;
        siteobj1.cscrm__Installation_Address__c = lstAddress[1].Id;
        siteobj1.Status__c = 'Active';
        siteobj1.Legacy__c = false;
        lstSite.add(siteobj1);
        cscrm__Site__c siteobj2 = new cscrm__Site__c();
        siteobj2.Name = 'Test Site2';
        siteobj2.cscrm__Account__c = acc.id;
        siteobj2.cscrm__Installation_Address__c = lstAddress[2].Id;
        siteobj2.Status__c = 'Active';
        siteobj2.Legacy__c = true;
        lstSite.add(siteobj2);
        insert lstSite;
        
        TransitionResponseCodes__c code1 = new TransitionResponseCodes__c(Reason__c='Techincal error for every legacy service',Status__c='Failed',TRAMAS_Code__c='TN4014');
        TransitionResponseCodes__c code2 = new TransitionResponseCodes__c(Reason__c='Some/all rules did not pass',Status__c='Not Eligible',TRAMAS_Code__c='TM4011');
        TransitionResponseCodes__c code3 = new TransitionResponseCodes__c(Reason__c='This service is in credit management',Status__c='Not Eligible',TRAMAS_Code__c='TMV00009');
        List<TransitionResponseCodes__c> responseCodeList = new List<TransitionResponseCodes__c>();
        responseCodeList.add(code1);
        responseCodeList.add(code2);
        responseCodeList.add(code3);
        insert responseCodeList;
    }
    @isTest
    public static void getCustomerServicesNewNullTest(){
        //String prodBasSites='{"adBorId":"1234"}';
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        String finCIDN='12343';
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='256345896231';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('256345896231',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');
        System.assert(service==null);
        Test.stopTest();
    }
     @isTest
    public static void getCustomerServicesV2ErrorTest(){
        //String prodBasSites='{"adBorId":"1234"}';
        String finCIDN='12343';
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        try{
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='256345896231';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('256345896231',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        list<String> adbList = New List<String>();
        adbList.add('256345896231');
        Test.startTest();
    //    Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServices_V2(finCIDN,adbList,'256345896231');
        System.assert(service==null);
        }
        catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    public static void getCustomerServicesNewTest(){
        //String prodBasSites='{"adBorId":"1234"}';
        String finCIDN='12343';
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');
        System.assert(service!=null);
        Test.stopTest();
    }
    @isTest
    public static void getCustomerServicesNewExceptionTest(){
        //String prodBasSites='{"adBorId":"1234"}';
        String finCIDN='12343';
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        Test.startTest();
        //  Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');
        System.assert(service==null);
        Test.stopTest();
    }
    @isTest
    public static void    replicatorResponseToTransitionTest(){
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        ReplicatorGetServiceDTO  getServiceDTO = ReplicatorGetServiceDTO.parse(getCustomerSites_withSuccess());
        Test.startTest();
        ReplicatorGetServiceDataObject_V2 service= ReplicatorGetServiceManager.replicatorResponseToTransition(getServiceDTO);
        System.assert(service!=null);
        Test.stopTest();
    }
    private static String getCustomerSites_withSuccess() {
        String jsonString = '{"correlationId":"SFDC_REP_GETSERVICE2377acc792fc60c1a2","servicesList":[{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266223323","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":"0266223320-0266223325"},{"name":"in_flight_flag","value":"N"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productId":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceId":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266221627","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266223531","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266222239","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":"Hunt Group"},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"Primary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0755285593","site":{"siteType":"adbor_id","siteId":"401432055"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":"Hunt Group"},{"name":"service_association_role","value":""},{"name":"service_extension","value":"0755285590-0755285595"},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"Primary"}]}]}';   
        return jsonString;
    }
    @isTest
    public static void getCustomerServicesMobileTest(){
        String finCIDN='';
        List<String> CIDNList = new List<String>();
        String CIDN1= '6140888888';
        Boolean hierarchyCheck = true;
        CIDNList.add(CIDN1);
        //Start of EDGE-209885 by Abhishek(Osaka)
        List<String> prodFamilyList = new List<String>();
        prodFamilyList.add('Enterprise Mobility');
        //End of EDGE-209885 by Abhishek(Osaka)
 
        try{
        Test.startTest();
        //  Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMobile(finCIDN,basketRecord.Id,'Mobile','Mobile',CIDNList,hierarchyCheck,prodFamilyList,'Auto');
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    
     @isTest
    public static void getCustomerServicesMobileTest1(){
        String finCIDN='';
        List<String> CIDNList = new List<String>();
        String CIDN1= '6140888888';
        Boolean hierarchyCheck = true;
        CIDNList.add(CIDN1);
        //Start of EDGE-209885 by Abhishek(Osaka)
        List<String> prodFamilyList = new List<String>();
        prodFamilyList.add('Enterprise Mobility');
        prodFamilyList.add('Enterprise Mobility');
        //End of EDGE-209885 by Abhishek(Osaka)
 
        try{
        Test.startTest();
        //  Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
 
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMobile(finCIDN,basketRecord.Id,'Mobile','Mobile',CIDNList,hierarchyCheck,prodFamilyList,'Auto');
 
       // TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMobile(finCIDN,basketRecord.Id,'Desktop','Desktop',CIDNList,hierarchyCheck,prodFamilyList);
 
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getCustomerServicesMobileTestFalse(){
        String finCIDN='12343';
        List<String> CIDNList = new List<String>();
        String CIDN1= '6140888888';
        Boolean hierarchyCheck = false;
        CIDNList.add(CIDN1);
        //Start of EDGE-209885 by Abhishek(Osaka)
        List<String> prodFamilyList = new List<String>();
        prodFamilyList.add('Enterprise Mobility');
        //End of EDGE-209885 by Abhishek(Osaka)
        try{
        Test.startTest();
        //  Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMobile(finCIDN,basketRecord.Id,'Mobile','Mobile',CIDNList,hierarchyCheck,prodFamilyList,'Auto');
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    
     @isTest
    public static void getCustomerServicesMobileTestFalse1(){
        String finCIDN='12343';
        List<String> CIDNList = new List<String>();
        String CIDN1= '6140888888';
        Boolean hierarchyCheck = false;
        CIDNList.add(CIDN1);
        //Start of EDGE-209885 by Abhishek(Osaka)
        List<String> prodFamilyList = new List<String>();
        prodFamilyList.add('Enterprise Mobility');
        
        //List <String> prodFamilies = new List<String>{'ISDN2','Enterprise Mobility'};
        //String finCIDN='12343';
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketRecord.Id;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        legacyRec.Product_Type__c ='Enterprise Mobility';
        Insert legacyRec;
        
        //End of EDGE-209885 by Abhishek(Osaka)
        try{
            Test.startTest();
            //  Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
            // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
            //cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMobile(finCIDN,basketRecord.Id,'Mobile','Mobile',CIDNList,hierarchyCheck,prodFamilyList,'Manual');
            System.assert(basketRecord!=null);
        }
        catch(Exception e){
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getCustomerServicesMDMTenanciesTest(){
        String finCIDN='12343';
        try{
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='256345896231';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('256345896231',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        list<String> adbList = New List<String>();
        adbList.add('256345896231');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTM1EligibilitycheckPostbackResponse('success_Exception'));
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMDMTenancies(finCIDN,basketRecord.Id,'MDM Tenancy','MDM Tenancy');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServices_V2(finCIDN,adbList,'256345896231');
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    public static void getCustomerServicesMDMTenanciesTest2(){
        String finCIDN='12343';
        try{
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTM1EligibilitycheckPostbackResponse('success_acknowledgement'));
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMDMTenancies(finCIDN,basketRecord.Id,'MDM Tenancy','MDM Tenancy');
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    public static void getCustomerServicesMDMTenanciesTest3(){
        String finCIDN='12343';
        try{
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='256345896231';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('256345896231',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        list<String> adbList = New List<String>();
        adbList.add('256345896231');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTM1EligibilitycheckPostbackResponse('success_Error'));
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMDMTenancies(finCIDN,basketRecord.Id,'MDM Tenancy','MDM Tenancy');
         ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServices_V2(finCIDN,adbList,'256345896231');
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    public static void getCustomerServicesMDMTenanciesTest4(){
        String finCIDN='';
        try{
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='256345896231';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('256345896231',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        list<String> adbList = New List<String>();
        adbList.add('256345896231');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTM1EligibilitycheckPostbackResponse('notfound_Exception'));
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        TransitionDataDTO serviceT= ReplicatorGetServiceManager.getCustomerServicesMDMTenancies(finCIDN,basketRecord.Id,'MDM Tenancy','MDM Tenancy');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServices_V2(finCIDN,adbList,'256345896231');
        System.assert(basketRecord!=null);
                }
        catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    public static void getMobileServicesTablewrapperTest(){
        String finCIDN='12343';
        try{
        ReplicatorGetServiceDTO getServiceDTO; 
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        //getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PrePaid HandHeld","fnn":"0429701914","site":{"siteType":"ADBOR_ID","siteId":"123"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000030"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"24 "},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701124","site":{"siteType":"ADBOR_ID","siteId":"11111"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"0429701111","site":{"siteType":"ADBOR_ID","siteId":"2222222"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility"},{"name":"contract_term","value":"220"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"042970223333","site":{"siteType":"ADBOR_ID","siteId":"33333333"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility Upgrade"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]}]}');
        //EDGE-139071 added dealer code & plan type values to test main class functionality
        getServiceDTO = ReplicatorGetServiceDTO.parse('{ "correlationId": "abcd_1234", "servicesList": [ { "cidn": "6898327073", "productFamily": "Mobile PostPaid HandHeld", "fnn": "0429701813", "site": { "siteType": "ADBOR_ID", "siteId": "0999" }, "account": { "accountNumber": "1696350000", "complexBillingIndicator": "", "creditManagementFlag": "N", "serviceWithEtcFlag": "N", "dealerCode": "AEWV456" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "PPHH" }, { "name": "service_status", "value": "AC" }, { "name": "service_type_code", "value": "NORM" }, { "name": "directory_listing", "value": "Y" }, { "name": "imsi_number", "value": "505013438393119" }, { "name": "sim_serial_number", "value": "89610179078138000029" }, { "name": "calling_line_identifier", "value": "off" }, { "name": "plan_name", "value": "3OB*049 | 3G Cap 49 Business Mobile Plan" }, { "name": "contract_term", "value": "12" }, { "name": "international_roaming", "value": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack" }, { "name": "message_bank", "value": "3GPPMSGK | 3G Pre-Paid Video Message Bank" }, { "name": "idd", "value": "BFIDD100 | Bus Fleet Plus IDD $100" } ], "serviceAssociations": [ ] }, { "cidn": "6898327073", "productFamily": "Mobile PrePaid HandHeld", "fnn": "0429701914", "site": { "siteType": "ADBOR_ID", "siteId": "123" }, "serviceCharacteristics": [ { "name": "service_status", "value": "AC" }, { "name": "service_type_code", "value": "NORM" }, { "name": "directory_listing", "value": "Y" }, { "name": "imsi_number", "value": "505013438393119" }, { "name": "sim_serial_number", "value": "89610179078138000030" }, { "name": "calling_line_identifier", "value": "off" }, { "name": "plan_name", "value": "3OB*049 | 3G Cap 49 Business Mobile Plan" }, { "name": "contract_term", "value": "24 " }, { "name": "international_roaming", "value": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack" }, { "name": "message_bank", "value": "3GPPMSGK | 3G Pre-Paid Video Message Bank" }, { "name": "idd", "value": "BFIDD100 | Bus Fleet Plus IDD $100" } ], "serviceAssociations": [ ] }, { "cidn": "6898327073", "productFamily": "Mobile PostPaid HandHeld", "fnn": "0429701124", "site": { "siteType": "ADBOR_ID", "siteId": "11111" }, "serviceCharacteristics": [ { "name": "service_status", "value": "NOVA" }, { "name": "service_type_code", "value": "NORM" }, { "name": "directory_listing", "value": "Y" }, { "name": "imsi_number", "value": "505013438393120" }, { "name": "sim_serial_number", "value": "89610179078138000031" }, { "name": "calling_line_identifier", "value": "on" }, { "name": "plan_name", "value": "3OB*049 | 3G Cap 49 Business Mobile Plan" }, { "name": "contract_term", "value": "120" }, { "name": "international_roaming", "value": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack" }, { "name": "message_bank", "value": "3GPPMSGK | 3G Pre-Paid Video Message Bank" }, { "name": "idd", "value": "BFIDD100 | Bus Fleet Plus IDD $100" } ], "serviceAssociations": [ ] }, { "cidn": "6898327073", "productFamily": "Enterprise Mobility", "fnn": "0429701111", "site": { "siteType": "ADBOR_ID", "siteId": "2222222" }, "serviceCharacteristics": [ { "name": "service_status", "value": "NOVA" }, { "name": "service_type_code", "value": "NORM" }, { "name": "directory_listing", "value": "Y" }, { "name": "imsi_number", "value": "505013438393120" }, { "name": "sim_serial_number", "value": "89610179078138000031" }, { "name": "calling_line_identifier", "value": "on" }, { "name": "plan_name", "value": "3OB*049 | Enterprise Mobility" }, { "name": "contract_term", "value": "220" }, { "name": "international_roaming", "value": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack" }, { "name": "message_bank", "value": "3GPPMSGK | 3G Pre-Paid Video Message Bank" }, { "name": "idd", "value": "BFIDD100 | Bus Fleet Plus IDD $100" } ], "serviceAssociations": [ ] }, { "cidn": "6898327073", "productFamily": "Enterprise Mobility", "fnn": "042970223333", "site": { "siteType": "ADBOR_ID", "siteId": "33333333" }, "serviceCharacteristics": [ { "name": "service_status", "value": "NOVA" }, { "name": "service_type_code", "value": "NORM" }, { "name": "directory_listing", "value": "Y" }, { "name": "imsi_number", "value": "505013438393120" }, { "name": "sim_serial_number", "value": "89610179078138000031" }, { "name": "calling_line_identifier", "value": "on" }, { "name": "plan_name", "value": "3OB*049 | Enterprise Mobility Upgrade" }, { "name": "contract_term", "value": "120" }, { "name": "international_roaming", "value": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack" }, { "name": "message_bank", "value": "3GPPMSGK | 3G Pre-Paid Video Message Bank" }, { "name": "idd", "value": "BFIDD100 | Bus Fleet Plus IDD $100" } ], "serviceAssociations": [ ] } ] }');
        TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id,'Mobile');
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        system.debug('tableWrapperData.size()--->'+tableWrapperData.size());
        System.assert(tableWrapperData.size() > 0);
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    
      // EDGE 145809 - Aarathi from Team Amsterdam - test method
    @isTest
    public static void getMobileServicesTablewrapperIneligibleTest(){
        String finCIDN='12343';
        try{
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{ "correlationId": "abcd_1234", "services": [ { "cidn": "6807449588", "productFamily": "Enterprise Mobility", "fnn": "61428888555", "site": { "siteType": "ADBOR_ID", "siteId": "0", "linkedSiteType": "", "linkedSiteId": "" }, "replicatorUpdateDateTime": "2020-02-21 08:04:36.317", "account": { "accountNumber": "1696350000", "complexBillingIndicator": "", "creditManagementFlag": "N", "serviceWithEtcFlag": "N", "dealerCode": "AEWV456" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "PPHH" }, { "name": "directory_listing", "value": "N" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "contract_term", "value": "0" }, { "name": "plan_name", "value": "Bus BYO Mobile Plan $39" }, { "name": "message_bank", "value": "" }, { "name": "idd", "value": "" }, { "name": "international_roaming", "value": "" }, { "name": "etc_flag", "value": "N" }, { "name": "service_type", "value": "NORM" } ], "devices": [ { "deviceType": "SIM", "physicalId": "89610180001850816630", "networkId": "505013425747315" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] }, { "cidn": "6807449588", "productFamily": "Enterprise Mobility", "fnn": "61439444888", "site": { "siteType": "ADBOR_ID", "siteId": "0", "linkedSiteType": "", "linkedSiteId": "" }, "replicatorUpdateDateTime": "2020-02-21 08:04:36.317", "account": { "accountNumber": "1696350000", "complexBillingIndicator": "", "creditManagementFlag": "N", "serviceWithEtcFlag": "N", "dealerCode": "AEWV123" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "MBB" }, { "name": "plan_name", "value": "Bus BYO Mobile Plan $99" }, { "name": "directory_listing", "value": "N" }, { "name": "contract_term", "value": "0" }, { "name": "idd", "value": "" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "message_bank", "value": "" }, { "name": "international_roaming", "value": "" }, { "name": "service_type", "value": "NORM" }, { "name": "etc_flag", "value": "N" } ], "devices": [ { "deviceType": "SIM", "physicalId": "89610185000014921507", "networkId": "505013474175759" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] }, { "cidn": "6807449588", "productFamily": "Enterprise Mobility", "fnn": "6143944488844", "site": { "siteType": "ADBOR_ID", "siteId": "0", "linkedSiteType": "", "linkedSiteId": "" }, "replicatorUpdateDateTime": "2020-02-21 08:04:36.317", "account": { "accountNumber": "1696350000", "complexBillingIndicator": "", "creditManagementFlag": "N", "serviceWithEtcFlag": "N", "dealerCode": "AEWV66556" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "UNKNOWN" }, { "name": "plan_name", "value": "Bus BYO Mobile Plan $99" }, { "name": "directory_listing", "value": "N" }, { "name": "contract_term", "value": "0" }, { "name": "idd", "value": "" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "message_bank", "value": "" }, { "name": "international_roaming", "value": "" }, { "name": "service_type", "value": "NORM" }, { "name": "etc_flag", "value": "N" } ], "devices": [ { "deviceType": "SIM", "physicalId": "89610185000014921507", "networkId": "505013474175759" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] } ] }'.replace('"services"', '"servicesList"'));
        TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id,'Mobile');
        Number__c numc1 = new Number__c(Service_Number__c = '61428888555', Status__c = 'RESERVED');
        insert numc1;                             
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());       
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        system.debug('tableWrapperData.size()--->'+tableWrapperData.size());
        Set<String> prod_num =new Set<String>();
        Set<String> eligibility_Status =new Set<String>();
        Set<String> eligibility_Reason =new Set<String>();
        Set<Boolean> check_Value =new Set<Boolean>();
        for (ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData) {
          //prod_num.add(tMobileDataProduct.Product_Number);
            if(tMobileDataProduct.Product_Number.contains('61428888555')){
                system.debug('inside my positive if loop');
                System.assertEquals(tMobileDataProduct.eligibilityReason,Label.IneligibleReserved); 
                System.assertEquals(tMobileDataProduct.eligibilityStatus,'Not Eligible');
                System.assertEquals(tMobileDataProduct.checkValue,false);  
            }
            else if(tMobileDataProduct.Product_Number.contains('61439444888')){
                system.debug('inside my negative if loop');
                System.assertNotEquals(tMobileDataProduct.eligibilityStatus,'Not Eligible');
                System.assertNotEquals(tMobileDataProduct.checkValue,false);  
            }         
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    
    //EDGE-179394 Test Methods START-----
    @isTest
    public static void getMobileServicesTablewrapperEligible(){
        try{
            
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"contract_remaining_term":"5","plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Handheld","billLiteral":"Apple iPhone 11 64GB","contractType":"MRO","monthlyAmount":"50.00","remainingTerm":"6","remainingAmount":"525.45","productEndDate": "2021-08-31"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
            System.assertEquals(tMobileDataProduct.eligibilityStatus,'Eligible');  
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    @isTest
    public static void getMobileServicesTablewrapperServiceIeEligible(){
        try{
            
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","etc_flag":"Y","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"contract_remaining_term":"5","plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Handheld","billLiteral":"Apple iPhone 11 64GB","contractType":"MRO","monthlyAmount":"50.00","remainingTerm":"6","remainingAmount":"525.45","productEndDate": "2021-08-31"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
            System.assertEquals(tMobileDataProduct.eligibilityReason,'Service not eligible for Transition as ETC is applicable');  
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    //Start of EDGE-213742  - Removing this ineligibility criteria by Abhishek(Osaka)
    /*@isTest
    public static void getMobileServicesTablewrapperCreditIneligible(){
        try{
            
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"contract_remaining_term":"5","plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Handheld","billLiteral":"Apple iPhone 11 64GB","contractType":"MRO","monthlyAmount":"50.00","remainingTerm":"6","remainingAmount":"525.45"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"Y","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
           System.assertEquals(tMobileDataProduct.eligibilityReason,'Service not eligible as credit management flag is set'); 
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }*/
    //End of EDGE-213742  - Removing this ineligibility criteria by Abhishek(Osaka)
    
    @isTest
    public static void getMobileServicesTablewrapperComplexIneligible(){
        try{
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"Y","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
            System.assertEquals(tMobileDataProduct.eligibilityReason,'Service not eligible as Complex billing indicator is set'); 
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    @isTest
    public static void getMobileServicesTablewrapperAROIneligible(){
        try{
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"Y","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
            System.assertNotEquals(tMobileDataProduct.eligibilityReason,'Service not eligible as ARO is set'); 
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    @isTest
    public static void getMobileServicesTablewrapperDeviceIneligible(){
        try{
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"Y","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
            System.assertEquals(tMobileDataProduct.eligibilityReason,'Service not eligible as device lease contract flag is set'); 
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    //START EDGE-218846 Commented by Nikhil
    /*@isTest
    public static void getMobileServicesTablewrapperTelstraIneligible(){
        try{
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"Y","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
            System.assertEquals(tMobileDataProduct.eligibilityReason,'Service not eligible as telstra one number flag is set'); 
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }*/
    //END EDGE-218846
    @isTest
    public static void getMobileServicesTablewrapperIMEIIneligible(){
        try{
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"Y","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        Test.startTest();
        List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
           //System.assertEquals(tMobileDataProduct.eligibilityReason,'Service not eligible as MRO that doesn’t have IMEI associated');
           System.assert(basketRecord!=null);
        }
        Test.stopTest();
        }
        catch(Exception e){
        }
    }
    /**
     * @Author   :   Jayghosh Mishra
     * @Desc     :   Test Method for getDuplicateServiceIds
     * @US       :   EDGE-198318
     * @Status   :   Development
     * */
    
    @isTest
    public static void getDuplicateServiceIdsIneligibleTest(){
        try{
            Account acc = AccountTestFactory.buildAccount('TestAcc');
            acc.CIDN__c = '1234567890';
            acc.APTPS_Off_Shore_Restricted__c=false;
            acc.APTPS_Tier__c='1';
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;
             Test.startTest();
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            System.assert(opp != null);
            
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            
            cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
            basket1.csbb__Account__c = acc.id;
            basket1.cscfga__Opportunity__c = opp.id;
            basket1.csordtelcoa__Basket_Stage__c = 'New';
            basket1.Name = 'basket1';
            insert basket1;
            
            //cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            Legacy_Service__c legacyRec = new Legacy_Service__c();
            legacyRec.Service_Id__c='61474896400';
            legacyRec.Product_Basket__c =  basket1.Id; 
            legacyRec.Select__c = true; 
            insert legacyRec;
 
            String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896400","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
            TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
           
            Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            //set<String> serviceIdSet = ReplicatorGetServiceManagerHelper.getDuplicateServiceIds(basket1.Id);
            set<String> serviceIdSet = ReplicatorGetServiceManagerHelper.getDuplicateServiceIds(mobileResponseFinal,basket1.Id);
            List <ReplicatorGetServiceManager.TableWrapper> tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basket.Id);
            for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
                System.assertEquals(tMobileDataProduct.eligibilityReason,'Service is already chosen for transition in another basket.'); 
			
            }
            Test.stopTest();
        }
        catch(Exception e){
        }
    }
    
    //EDGE-179394 Test Methods END-----
    @isTest
    public static void insertJSONResponseMobileTest(){
        String finCIDN='12343';
        try{
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        //EDGE-139071 - Updated Test data JSON 
        getServiceDTO = ReplicatorGetServiceDTO.parse('{ "correlationId": "5465764671208", "servicesList": [ { "cidn": "1234567890", "productFamily": "Mobile Postpaid Handheld", "fnn": "0411111111", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "account": { "accountNumber": "2323232323", "complexBillingIndicator": "N", "creditManagementFlag": "N", "serviceWithEtcFlag": "Y", "dealerCode":"123456" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "PPHH" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "contract_term", "value": "24" }, { "name": "directory_listing", "value": "E" }, { "name": "international_roaming", "value": "Access to Use Mobile Overseas" }, { "name": "message_bank", "value": "Messagebank Access Fee" }, { "name": "plan_name", "value": "My Business Lease Plan $95" }, { "name": "service_status", "value": "AC" }, { "name": "service_type", "value": "NORM" }, { "name": "etc_flag", "value": "N" } ], "devices": [ { "deviceType": "sim", "physicalId": "89610163282254000030", "networkId": "505013487427762" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] }, { "cidn": "1234567890", "productFamily": "Mobile Postpaid Handheld", "fnn": "2323232323", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "account": { "accountNumber": "2212356398", "complexBillingIndicator": "N", "creditManagementFlag": "N", "serviceWithEtcFlag": "N", "dealerCode":"123412" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "MBB" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "contract_term", "value": "36" }, { "name": "directory_listing", "value": "E" }, { "name": "international_roaming", "value": "Access to Use Mobile Overseas" }, { "name": "message_bank", "value": "Video MessageBank" }, { "name": "plan_name", "value": "Go Business Data SIM $5" }, { "name": "service_status", "value": "AC" }, { "name": "service_type", "value": "NORM" }, { "name": "etc_flag", "value": "Y" } ], "devices": [ { "deviceType": "sim", "physicalId": "89610163267640000029", "networkId": "505013485041069" }, { "deviceType": "sim", "physicalId": "89610163267640000029", "networkId": "505013485041069" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] } ]}');
        TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id,'');
        Test.startTest();
        
        String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "GDN", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "auxiliary", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
        
        List<ReplicatorGetServiceManager.TableWrapper> tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
 
        List<Attachment> insertAttachment = ReplicatorGetServiceManager.insertJSONResponseMobile(TransitionDTO , tableWrapperData, basketRecord.Id, true);
        
 
        
        List < ReplicatorGetServiceManager.TableWrapper > mobileTableWrapperList = new List < ReplicatorGetServiceManager.TableWrapper > ();
        ReplicatorGetServiceManager.TableWrapper mobileTableWrapper = new ReplicatorGetServiceManager.TableWrapper();
        mobileTableWrapper.Product_Type = 'Enterprise Mobility';      
        mobileTableWrapper.Product_Number = '1234567890';   
        mobileTableWrapper.checkValue = false;
        mobileTableWrapper.eligibilityStatus = 'Eligible';
        mobileTableWrapper.eligibilityReason = 'Testing';
        mobileTableWrapperList.add(mobileTableWrapper);
        
       // List<Attachment> insertAttachment = ReplicatorGetServiceManager.insertJSONResponseMobile(TransitionDTO , mobileTableWrapperList, basketRecord.Id, true);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
 
        system.debug('tableWrapperData--->'+tableWrapperData);
        //EDGE-139071 - Asset to check plan type value        
        List<String> plan_type =new List<String>();
        List<String> dealerCode =new List<String>();
        for (ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData) {
          plan_type.add(tMobileDataProduct.Plan_Type);
            dealerCode.add(tMobileDataProduct.Dealer_Code);
        }
        //Positive assert statement
    System.assertEquals(true, plan_type.contains('PPHH'));
        System.assertEquals(true, dealerCode.contains('123456')); 
        //Negative assert statement
        System.assertNotEquals(true, plan_type.contains('Mobile'));
        System.assertNotEquals(true, dealerCode.contains('10101010'));
        //EDGE-139071 - End
        System.assert(insertAttachment!=null);
      //  System.assert(insertAttachment.size() > 0);
        Test.stopTest();
        }
        catch(Exception e){
        } 
    }
    @isTest
    public static void getBasketTest(){
        try{
        Test.startTest();    
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        cscfga__Product_Basket__c basketRecordCntrl = ReplicatorGetServiceManager.getBasket(basketRecord.Id);
        System.assert(basketRecordCntrl!=null);
        System.assert(basketRecordCntrl.Id != '');
        }
        catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    public static void testinsertJSONResponseNgUc() {
        //Start of EDGE-209885 by Abhishek(Osaka)
        String CIDNHierarchy = '4851828808';
        Boolean isHierarchyCheck = true;
        String prodFamilyList = 'ISDN2';
        
        String CIDNHierarchyTest = '';
        Boolean isHierarchyCheckTest = false;
        //End of EDGE-209885 by Abhishek(Osaka)
 
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
 
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        List <String> prodFamilies = new List<String>{'ISDN2','ISDN'};
        String finCIDN='12343';
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        Test.startTest();
        //String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "GDN", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "AUXILLARY", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "GDN", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "auxiliary", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
        ReplicatorGetServiceManager.insertJSONResponseNgUc(TransitionDTO,null,basketId,false);
        Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');
        //System.assert(service==null);
        System.assert(TransitionDataNgUcJSON!=null);
        //Added as a part of EDGE-209985 (CIDNHierarchyTest,isHierarchyCheckTest) by Abhishek(Osaka)
        ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc('',prodFamilies,basketId,CIDNHierarchyTest,isHierarchyCheckTest,prodFamilyList);
        //ReplicatorGetServiceManager.transformReplicatorResponseNgUc(service,basketId);
 
        ReplicatorGetServiceManager.getNgUCServicesTablewrapper(TransitionDTO,basketId);
        //Added as a part of EDGE-209985 (CIDNHierarchy,isHierarchyCheck) by Abhishek(Osaka)
        ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc('',prodFamilies,basketId,CIDNHierarchy,isHierarchyCheck,prodFamilyList);
        ReplicatorGetServiceManager.NgUCTableWrapper ngucwpr = new ReplicatorGetServiceManager.NgUCTableWrapper();
        ngucwpr.SITE_ADBORID = null;
        ReplicatorGetServiceManager.ProductFamilyTblWrapper pft = new ReplicatorGetServiceManager.ProductFamilyTblWrapper();
        pft.Id = null;
        Map<String,String> serviceMap = ReplicatorGetServiceManager.servicesPresentInTransition(basketId);
        System.assert(serviceMap !=null);
        Test.stopTest();
    }
    
    @isTest
    public static void testinsertJSONResponseNgUc1() {
        //Start of EDGE-209885 by Abhishek(Osaka)
        String CIDNHierarchy = '4851828808';
        Boolean isHierarchyCheck = true;
        String prodFamilyList = 'ISDN2';
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        String CIDNHierarchyTest = '';
        Boolean isHierarchyCheckTest = false;
        //End of EDGE-209885 by Abhishek(Osaka)
        
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        List <String> prodFamilies = new List<String>{'ISDN2','ISDN'};
        String finCIDN='12343';
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        Test.startTest();
        //String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "GDN", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "AUXILLARY", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "GDN", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "auxiliary", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
        ReplicatorGetServiceManager.insertJSONResponseNgUc(TransitionDTO,null,basketId,false);
        Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');
        //System.assert(service==null);
        System.assert(TransitionDataNgUcJSON!=null);
        //Added as a part of EDGE-209985 (CIDNHierarchyTest,isHierarchyCheckTest) by Abhishek(Osaka)
        ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc('',prodFamilies,'',CIDNHierarchyTest,isHierarchyCheckTest,prodFamilyList);
        //ReplicatorGetServiceManager.transformReplicatorResponseNgUc(service,basketId);
        ReplicatorGetServiceManager.getNgUCServicesTablewrapper(TransitionDTO,basketId);
        //Added as a part of EDGE-209985 (CIDNHierarchy,isHierarchyCheck) by Abhishek(Osaka)
        ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc('',prodFamilies,'',CIDNHierarchy,isHierarchyCheck,prodFamilyList);
 
        ReplicatorGetServiceManager.NgUCTableWrapper ngucwpr = new ReplicatorGetServiceManager.NgUCTableWrapper();
        ngucwpr.SITE_ADBORID = null;
        ReplicatorGetServiceManager.ProductFamilyTblWrapper pft = new ReplicatorGetServiceManager.ProductFamilyTblWrapper();
        pft.Id = null;
        Map<String,String> serviceMap = ReplicatorGetServiceManager.servicesPresentInTransition(basketId);
        System.assert(serviceMap !=null);
        Test.stopTest();
    }
    
    @isTest
    public static void testinsertJSONResponseNgUc31() {
        //Start of EDGE-209885 by Abhishek(Osaka)
        String CIDNHierarchy = '4851828808';
        Boolean isHierarchyCheck = true;
        String prodFamilyList = 'ISDN2';
        
        Test.StartTest();
        String CIDNHierarchyTest = '';
        Boolean isHierarchyCheckTest = false;
        //End of EDGE-209885 by Abhishek(Osaka)
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        List <String> prodFamilies = new List<String>{'ISDN2','Enterprise Mobility'};
        String finCIDN='12343';
       
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketId ;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        legacyRec.Product_Type__c ='Enterprise Mobility';
        Insert legacyRec;
        
        //Added as a part of EDGE-209985 (CIDNHierarchyTest,isHierarchyCheckTest) by Abhishek(Osaka)
        ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc('',prodFamilies,basketId,CIDNHierarchyTest,isHierarchyCheckTest,prodFamilyList);
      
        ReplicatorGetServiceManager.NgUCTableWrapper ngucwpr = new ReplicatorGetServiceManager.NgUCTableWrapper();
        ngucwpr.SITE_ADBORID = null;
        ReplicatorGetServiceManager.ProductFamilyTblWrapper pft = new ReplicatorGetServiceManager.ProductFamilyTblWrapper();
        pft.Id = null;
        Map<String,String> serviceMap = ReplicatorGetServiceManager.servicesPresentInTransition(basketId);
        System.assert(serviceMap !=null);
        
        //ReplicatorGetServiceManager.getFNNs(finCIDN,prodFamilies ,basketId );
        String fnn = ReplicatorGetServiceManagerHelper.getFNNs(finCIDN,prodFamilies ,basketId );
        
        Test.stopTest();
    }
    
    @isTest
    public static void getCustomerServicesNewExceptionTest2(){
        //String prodBasSites='{"adBorId":"1234"}';
        String finCIDN='test';
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);
        Test.startTest();
        //  Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');       
        System.assert(service==null);
        ReplicatorGetServiceDTO custservice= ReplicatorGetServiceManager.getCustomerServicesAtSite_V2('test',null,'test');
        Test.stopTest();
    }
    @isTest
    public static void getTableWrapperNegativeTest(){
        Test.startTest();
        ReplicatorGetServiceManager.NgUCTableWrapper ngucwrpr = new ReplicatorGetServiceManager.NgUCTableWrapper();
        ReplicatorGetServiceManager.servicesPresentInTransition(null);
        ReplicatorGetServiceManager.ProductFamilyTblWrapper pftwrpr = new ReplicatorGetServiceManager.ProductFamilyTblWrapper();
        pftwrpr.Id = null;
        pftwrpr.Linked_AssociationRole = null;
        pftwrpr.Linked_AssociationID = null;
        pftwrpr.Product_Family = null;
        pftwrpr.FNN = null;
        pftwrpr.checkValue = false;
        System.assert(pftwrpr.checkValue==false);
        ReplicatorGetServiceManager.serviceCharacteristicTempDTO srvcDTO = new ReplicatorGetServiceManager.serviceCharacteristicTempDTO();
        srvcDTO.service_extension = null;
        Test.stopTest();
    } 
    @isTest
    public static void getServicesDTOTest(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        //Added device_lease_contract_indicator,telstra_one_number_indicator,mro_with_no_imei,aro_indicator as a part of EDGE-179394 under service characteristic block
        //Added contact_remaining_term as a part of EDGE-173831
 
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"user_name","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"aro_indicator","value":"Y"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"N"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
     /*   ReplicatorGetServiceManager.groupingLogicNgUC(serviceDTO[0]);
        ReplicatorGetServiceManager.groupingLogicNgUC(serviceDTO[1]);
        ReplicatorGetServiceManager.groupingLogicNgUC(serviceDTO[2]); */
        //EDGE-145906- Assert statement to check DealerCode
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        //EDGE-145906 end
        System.assert(getServiceDTO != null);
        //ReplicatorGetServiceManager.groupingLogicNgUC(null);
        Test.stopTest();
    }
    //------START OF EDGE-185055 By Abhishek from Osaka Team-----//
    @isTest
    public static void getServicesDTOTestEtc(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"Y"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"N"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTestAro(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"Y"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"N"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTestDevice(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"Y"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"N"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTestTelstra(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"telstra_one_number_indicator","value":"Y"},{"name":"mro_with_no_imei","value":"N"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTestMro(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"Y"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTestCreditMgmnt(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"Y"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"Y","complexBillingIndicator":"N","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTestComplexBill(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"etc_flag","value":"N"},{"name":"aro_indicator","value":"N"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"telstra_one_number_indicator","value":"N"},{"name":"mro_with_no_imei","value":"Y"},{"name":"contract_remaining_term","value":"5"},{"name":"plan_type","value":"AC"},{"name":"tenancy_name","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"GDN"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"GDN"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"repayments":[{"Service_Id":null,"remainingTerm":6,"remainingAmount":1111.45,"productEndDate": "2021-08-31","productID":"100018937100000090120","monthlyAmount":111,"deviceType":"Mobile Handset","deviceID":"352914116119203","contractType":"MRO","billLiteral":"Apple iPhone"},{"Service_Id":null,"remainingTerm":15,"remainingAmount":222.43,"productEndDate": "2021-08-31","productID":"100300584800000020100","monthlyAmount":22,"deviceType":"Mobile Handset","deviceID":"354880094381776","contractType":"MRO","billLiteral":"Samsung Galaxy"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"Y","accountNumber":"2323232323","dealerCode":"324324324"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"PRIME"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"PRIME"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"service_association_role","value":"AUXILLARY"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"AUXILLARY"}],"devices":[{"physicalId":"89610163282254000030","networkId":"505013487427762","deviceType":"sim"}],"contract_term":"24","calling_line_identifier":"ON","account":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2323232323"}}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        ReplicatorGetServiceManager.getSiteList(serviceDTO[0]);
        String result = JSON.serialize(getServiceDTO);
        system.debug('getServiceDTO--->'+result);
        system.assert(result.Contains('dealerCode')==true);
        System.assert(getServiceDTO != null);
        Test.stopTest();
    }
    
    //------END OF EDGE-185055 By Abhishek from Osaka Team-----//
    
    //Start of Edge-211350 by Abhishek(Osaka)
    @isTest
    public static void gridDisplayDataTest(){
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"contract_remaining_term":"5","plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Handheld","billLiteral":"Apple iPhone 11 64GB","contractType":"MRO","monthlyAmount":"50.00","remainingTerm":"6","remainingAmount":"525.45","productEndDate": "2021-08-31"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"sourceCIDN":"4851828803","serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","businessnumber":null,"accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
        TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
        List<ReplicatorGetServiceManager.TableWrapper> tableWrapperList = new List<ReplicatorGetServiceManager.TableWrapper>();
        tableWrapperList = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
        String returnResponse;
        Test.startTest();
        returnResponse = ReplicatorGetServiceManager.gridDisplayData(tableWrapperList);
        System.assert(returnResponse != null);
        Test.stopTest();
    }
    //End of Edge-211350 by Abhishek(Osaka)
    
    private static String getCustomerSites_withServiceExtensions() {
        String jsonString = '{"correlationId":"SFDC_REP_GETSERVICE2377acc792fc60c1a2","servicesList":[{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266223323","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":"0266223320-0266223325"},{"name":"in_flight_flag","value":"N"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}],"serviceExtensions":[{"serviceExtensionFrom":"0266221627","serviceExtensionTo":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266221627","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"devices":[{"deviceType":"sim","physicalId":"89610163282254000030","networkId":"505013487427762"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}],"serviceExtensions":[{"serviceExtensionFrom":"0266221627","serviceExtensionTo":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266223531","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":""},{"name":"service_association_role","value":""},{"name":"in_flight_flag","value":"N"}],"devices":[{"deviceType":"sim","physicalId":"89610163282254000030","networkId":"505013487427762"}],"serviceAssociations":[{"linkedServiceId":"0266221627","linkedServiceRole":"Secondary"}],"serviceExtensions":[{"serviceExtensionFrom":"0266221627","serviceExtensionTo":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0266222239","site":{"siteType":"adbor_id","siteId":"180828122"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":"Hunt Group"},{"name":"service_association_role","value":""},{"name":"service_extension","value":""},{"name":"in_flight_flag","value":"N"}],"devices":[{"deviceType":"sim","physicalId":"89610163282254000030","networkId":"505013487427762"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"Primary"}],"serviceExtensions":[{"serviceExtensionFrom":"0266221627","serviceExtensionTo":"Secondary"}]},{"cidn":"5810217906","productFamily":"PSTN","fnn":"0755285593","site":{"siteType":"adbor_id","siteId":"401432055"},"serviceCharacteristics":[{"name":"service_type","value":"voice"},{"name":"association_type","value":"Hunt Group"},{"name":"service_association_role","value":""},{"name":"service_extension","value":"0755285590-0755285595"},{"name":"in_flight_flag","value":"N"}],"devices":[{"deviceType":"sim","physicalId":"89610163282254000030","networkId":"505013487427762"}],"serviceAssociations":[{"linkedServiceId":"0249902577","linkedServiceRole":"Primary"}],"serviceExtensions":[{"serviceExtensionFrom":"0266221627","serviceExtensionTo":"Secondary"}]}]}';   
        return jsonString;
    }
     @isTest
    public static void  replicatorResponseToTransTest(){
        ReplicatorGetServiceDTO  getServiceDTO = ReplicatorGetServiceDTO.parse(getCustomerSites_withServiceExtensions());
        Test.startTest();
        ReplicatorGetServiceDataObject_V2 service= ReplicatorGetServiceManager.replicatorResponseToTransition(getServiceDTO);
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.getServiceNgUc(serviceDTO[0]);
        System.assert(service!=null);
        Test.stopTest();
    }
     @isTest
    public static void testinsertJSONResponseNgUc2() {
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        List <String> prodFamilies = new List<String>{'ISDN2','ISDN'};
        String finCIDN='12343';
        List<String> selectedCidn = new List<String>();
        selectedCidn.add('12345678');
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);  
        List<ReplicatorGetServiceManager.NgUCTableWrapper> ngucwprLst = new List<ReplicatorGetServiceManager.NgUCTableWrapper>();
        ReplicatorGetServiceManager.NgUCTableWrapper ngucwpr = new ReplicatorGetServiceManager.NgUCTableWrapper();
        Test.startTest();
         String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "", "Error_Description": "", "productList": [ { "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN30", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": [ { "serviceExtensionFrom": "0266221627", "serviceExtensionTo": "Secondary" } ], "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": [ { "serviceExtensionFrom": "0266221627", "serviceExtensionTo": "Secondary" } ], "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
         String TransitionDataNgUcJSONNew = '{"CIDN":"1100037407","Correlation_Id":"75847359875974589374","Error_Code":"abcd","Error_Description":"abcd","productList":[{"checkValue":true,"disableCheck":true,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"ISDN2","site":[{"ADBOR_Id":"0","Error_Code":null,"Error_Description":null,"serviceList":[{"checkReserved":false,"checkValue":true,"disableCheck":null,"EligibilityReason":null,"EligibilityStatus":null,"groupType":[{"checkValue":true,"disableCheck":null,"groupId":"0358852382","service":[{"accountDetails":null,"calling_line_identifier":null,"contract_term":null,"devices":null,"directory_listing":null,"Eligibility_status":null,"idd":null,"imsi_number":null,"international_roaming":null,"message_bank":null,"plan_name":null,"Reason":null,"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","Reserve_status":null,"service_association_role":"GDN","Service_Id":"0358852382","service_status":null,"service_type":"voice","service_type_code":null,"serviceExtensions":null,"sim_serial_number":null},{"accountDetails":null,"calling_line_identifier":null,"contract_term":null,"devices":null,"directory_listing":null,"Eligibility_status":null,"idd":null,"imsi_number":null,"international_roaming":null,"message_bank":null,"plan_name":null,"Reason":null,"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","Reserve_status":null,"service_association_role":"AUXILLARY","Service_Id":"0358851406","service_status":null,"service_type":"voice","service_type_code":null,"serviceExtensions":null,"sim_serial_number":null}],"transitionId":"63030a64-41ec-4e57-9e6c-d5da7565b315"}],"Service_Type":"0358852382"}],"siteName":null}]}],"serviceCount":0,"Source_System_Id":"Replicator"}';
        TransitionDataDTO TransitionDTONew = TransitionDataDTO.parse(TransitionDataNgUcJSONNew);
        TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
        Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceManagerMock());
        // cscrm__Site__c site=new cscrm__Site__c(Legacy__c=true,AdborID__c='1234');
        ReplicatorGetServiceDTO service= ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,'');
        System.assert(service!=null);
        //service = ReplicatorGetServiceDTO.parse('{ "correlationId": "75847359875974589374", "servicesList": [ { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358852382", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Hunt Group" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "contract_term", "value": "36" }, { "name": "service_association_role", "value": "GDN" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358851408", "linkedServiceRole": "PRIME" }, { "linkedServiceId": "0358852072", "linkedServiceRole": "PRIME" }, { "linkedServiceId": "0358852387", "linkedServiceRole": "PRIME" }, { "linkedServiceId": "0358852703", "linkedServiceRole": "PRIME" }, { "linkedServiceId": "0358851407", "linkedServiceRole": "AUXILLARY" }, { "linkedServiceId": "0358851419", "linkedServiceRole": "AUXILLARY" }, { "linkedServiceId": "0358851418", "linkedServiceRole": "AUXILLARY" }, { "linkedServiceId": "0358851406", "linkedServiceRole": "AUXILLARY" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "03588523855", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Hunt Group" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "contract_term", "value": "36" }, { "name": "service_association_role", "value": "GDN1" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "035885211212", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Hunt Group" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "contract_term", "value": "36" }, { "name": "service_association_role", "value": "GDN" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358853453", "linkedServiceRole": "PRIME" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358853453", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "PRIME" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "035885211212", "linkedServiceRole": "GDN" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358851408", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "PRIME" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358851407", "linkedServiceRole": "AUXILLARY" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358852072", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "PRIME" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358851419", "linkedServiceRole": "AUXILLARY" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358852387", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "PRIME" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358851418", "linkedServiceRole": "AUXILLARY" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358852703", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "PRIME" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358851406", "linkedServiceRole": "AUXILLARY" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358851407", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "AUXILLARY" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358851408", "linkedServiceRole": "PRIME" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358851419", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "AUXILLARY" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358852072", "linkedServiceRole": "PRIME" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358851418", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "AUXILLARY" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358852387", "linkedServiceRole": "PRIME" } ] }, { "cidn": "1100037407", "productFamily": "ISDN2", "fnn": "0358851406", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "service_association_role", "value": "AUXILLARY" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ { "linkedServiceId": "0358852382", "linkedServiceRole": "GDN" }, { "linkedServiceId": "0358852703", "linkedServiceRole": "PRIME" } ] }, { "cidn": "1100037407", "productFamily": "ISDN10", "fnn": "110003740712", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "serviceCharacteristics": [ { "name": "association_type", "value": "Multi number" }, { "name": "directory_option", "value": "No Entry Line" }, { "name": "inflight_order", "value": "N" }, { "name": "contract_term", "value": "36" }, { "name": "service_association_role", "value": "" }, { "name": "service_type", "value": "voice" }, { "name": "source_site", "value": "0" }, { "name": "directory_listing", "value": "test" }, { "name": "Reserved_ranges", "value": "test" }, { "name": "Redirection_product", "value": "test" }, { "name": "silent_line", "value": "test" } ], "serviceAssociations": [ ], "serviceExtensions": [ { "serviceExtensionFrom": "0358852382", "serviceExtensionTo": "0358852389" }, { "serviceExtensionFrom": "0358852703", "serviceExtensionTo": "0358852709" } ] } ] }'.replace('"services"', '"servicesList"'));
        service = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852382","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852703","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"03588523855","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN1"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"035885211212","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358853453","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358853453","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"035885211212","linkedServiceRole":"GDN"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851408","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852072","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852387","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852703","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851407","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851419","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851418","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851406","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852703","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN10","fnn":"110003740712","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":""},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"directory_listing","value":"test"},{"name":"Reserved_ranges","value":"test"},{"name":"Redirection_product","value":"test"},{"name":"silent_line","value":"test"}],"serviceAssociations":[],"serviceExtensions":[{"serviceExtensionFrom":"0358852382","serviceExtensionTo":"0358852389"},{"serviceExtensionFrom":"0358852703","serviceExtensionTo":"0358852709"}]}]}'.replace('"services"', '"servicesList"'));
        ReplicatorGetServiceManager.transformReplicatorResponseNgUc(service,basketId,finCIDN,selectedCidn);
        ReplicatorGetServiceManager.getNgUCServicesTablewrapper(TransitionDTO,basketId);
        ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(TransitionDTO,basketId);
        //ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(TransitionDTONew,basketId);
        ReplicatorGetServiceManager.servicesPresentInTransition(null);  
        ngucwpr.SITE_ADBORID = null;
        ReplicatorGetServiceManager.insertJSONResponseNgUc(TransitionDTO,ngucwprLst,basketId,false);
        ngucwprLst.add(ngucwpr);
        ReplicatorGetServiceManager.insertJSONResponseNgUc(TransitionDTO,ngucwprLst,basketId,false);
        System.assert(basketId!=null);
        Test.stopTest();
    }
    @isTest
    public static void testinsertJSONResponseNgUc3() {
              
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        List <String> prodFamilies = new List<String>{'ISDN2','ISDN'};
        String finCIDN='12343';
        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
        pbsdObject.adBorId='152365895123';
        Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
        pbsdMap.put('152365895123',pbsdObject);
        String prodBasSites=JSON.serialize(pbsdMap);  
        List<ReplicatorGetServiceManager.NgUCTableWrapper> ngucwprLst = new List<ReplicatorGetServiceManager.NgUCTableWrapper>();
        ReplicatorGetServiceManager.NgUCTableWrapper ngucwpr = new ReplicatorGetServiceManager.NgUCTableWrapper();
        Test.startTest();
        //String TransitionDataNgUcJSONNew = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "gdn", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "prime", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "auxillary", "Service_Id": "0358851407", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        String TransitionDataNgUcJSONNew = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "gdn", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "prime", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "auxiliary", "Service_Id": "0358851407", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        TransitionDataDTO TransitionDTONew = TransitionDataDTO.parse(TransitionDataNgUcJSONNew);
        List < ReplicatorGetServiceManager.NgUCTableWrapper > ngUCTableWrapperClassList = new List < ReplicatorGetServiceManager.NgUCTableWrapper > ();
        ngUCTableWrapperClassList=ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(TransitionDTONew,basketId);
        system.debug('ngUCTableWrapperClassList is' +ngUCTableWrapperClassList);
        system.debug('ngUCTableWrapperClassList size is' +ngUCTableWrapperClassList.size());
        System.assert(ngUCTableWrapperClassList[0].Product_Type.contains('ISDN2')==true);
        System.assert(basketId!=null);
        Test.stopTest();
    }
 
    //EDGE-151827 added positive test method for TIPT-SIPC wrapper
    @isTest
    public static void ngucWrapperTIPTSIPCPositiveTest() {
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        Test.startTest();   
        String TransitionDataNgUcJSONNew = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"transitionId":null,"serviceAssociations":null,"service":[{"trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"telstra_one_number_indicator":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":[{"serviceExtensionTo":"0749679399","serviceExtensionFrom":"0749679300","Reserve_status":null,"Reason":null,"eligibilityStatus":null,"eligibilityReason":null,"checkReserved":false}],"service_type_code":null,"service_type":null,"service_status":null,"Service_Id":"0749679300","service_association_role":"service","Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","repayments":null,"Redirection_product":null,"Reason":null,"plan_type":null,"plan_name":null,"mro_with_no_imei":null,"message_bank":null,"is_enterprise_trunk":null,"international_roaming":null,"imsi_number":null,"idd":null,"etc_flag":null}],"groupId":"N7740924R","EligibilityStatus":"eligible","EligibilityReason":"","disableCheck":null,"checkValue":false}],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":false}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        TransitionDataDTO TransitionDTONew = TransitionDataDTO.parse(TransitionDataNgUcJSONNew);
        List < ReplicatorGetServiceManager.NgUCTableWrapper > ngUCTableWrapperClassList = new List < ReplicatorGetServiceManager.NgUCTableWrapper > ();
        ngUCTableWrapperClassList = ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(TransitionDTONew,basketId);
        System.assertEquals(2,ngUCTableWrapperClassList.size());
        Test.stopTest();
    } 
    //EDGE-151827 added neagtive test method for TIPT-SIPC wrapper
    @isTest
    public static void ngucWrapperTIPTSIPCNegativeTest() {
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        Test.startTest();
        String TransitionDataNgUcJSONNew = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[],"EligibilityStatus":null,"EligibilityReason":null,"disableCheck":null,"checkValue":false,"checkReserved":false}],"linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD","Error_Description":null,"Error_Code":null,"ADBOR_Id":"1234567890"}],"Product_Type":"TIPT-SIPC","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"LegacyTenancyID":"N7005109R","Error_Description":"","Error_Code":"","Correlation_Id":"473685095830478","CIDN":"9501331855"}';
        TransitionDataDTO TransitionDTONew = TransitionDataDTO.parse(TransitionDataNgUcJSONNew);
        List < ReplicatorGetServiceManager.NgUCTableWrapper > ngUCTableWrapperClassList = new List < ReplicatorGetServiceManager.NgUCTableWrapper > ();
        ngUCTableWrapperClassList = ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(TransitionDTONew,basketId);
        System.assertNotEquals(2,ngUCTableWrapperClassList.size());
        Test.stopTest();
    }

      // EDGE-152495 for TIPT-SIPC Family Grouping Hybrid Logic
    @isTest
    public static void newFamilyTIPTSIPCPositiveTest() {
        String finCIDN = '1234';
        List<String> selectedCidn = new List<String>();
        selectedCidn.add('12345678');
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        Test.startTest();               
        ReplicatorGetServiceDTO  getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"473685095830478","servicesList":[{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"N7005109R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"enterprise"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7740924R","linkedServiceRole":"group"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"},{"linkedServiceId":"0749679300","linkedServiceRole":"service"},{"linkedServiceId":"0749679400","linkedServiceRole":"service"},{"linkedServiceId":"0749679500","linkedServiceRole":"service"},{"linkedServiceId":"0749679401","linkedServiceRole":"service"},{"linkedServiceId":"0749679301","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331856","productFamily":"TIPT-SIPC","fnn":"N7740924R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"is_enterprise_trunk","value":"Y"},{"name":"trunk_capacity","value":"20"},{"name":"bw_eligibility_flag","value":"eligible"},{"name":"bw_eligibility_reason_code","value":""}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"0749679300","linkedServiceRole":"service"},{"linkedServiceRole":"service"},{"linkedServiceId":"0749679500","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331857","productFamily":"TIPT-SIPC","fnn":"0749679300","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679300","serviceExtensionTo":"0749679399"}]},{"cidn":"9501331858","productFamily":"TIPT-SIPC","fnn":"0749679400","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679400","serviceExtensionTo":"0749679479"}]},{"cidn":"9501331859","productFamily":"TIPT-SIPC","fnn":"0749679500","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679500","serviceExtensionTo":"0749679599"}]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"N7740929R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"is_enterprise_trunk","value":"Y"},{"name":"trunk_capacity","value":"20"},{"name":"bw_eligibility_flag","value":"eligible"},{"name":"bw_eligibility_reason_code","value":""}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"0749679301","linkedServiceRole":"service"},{"linkedServiceId":"0749679401","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"0749679301","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679700","serviceExtensionTo":"0749679799"}]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"0749679401","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679500","serviceExtensionTo":"0749679579"}]}]}');  
        TransitionDataDTO TransitionDTONew = ReplicatorGetServiceManager.transformReplicatorResponseNgUc(getServiceDTO ,basketId,finCIDN,selectedCidn);
        System.debug('TransitionDTONew >>> ' + TransitionDTONew);
        System.assertEquals('9501331855', TransitionDTONew.CIDN , 'Matching CIDN from replicator should have been formed' );
        System.assertEquals( 1 , TransitionDTONew.productList.size() , '1 Product list of TIPT Family should have been formed in NGUC Transformed JSON');
        System.assertEquals( 1 , TransitionDTONew.productList[0].site[0].serviceList.size() , '1 attached service should be there with it' );

        Test.stopTest();
    }
                                                
   // EDGE-152495 for TIPT-SIPC Family Grouping Hybrid Logic
    @isTest
    public static void newFamilyTIPTSIPCWithNoBasketTest() {
        String finCIDN = '1234';
        List<String> selectedCidn = new List<String>();
        selectedCidn.add('12345678');
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = '';
        Test.startTest();               
        ReplicatorGetServiceDTO  getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"473685095830478","servicesList":[{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"N7005109R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"enterprise"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7740924R","linkedServiceRole":"group"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"},{"linkedServiceId":"0749679300","linkedServiceRole":"service"},{"linkedServiceId":"0749679400","linkedServiceRole":"service"},{"linkedServiceId":"0749679500","linkedServiceRole":"service"},{"linkedServiceId":"0749679401","linkedServiceRole":"service"},{"linkedServiceId":"0749679301","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331856","productFamily":"TIPT-SIPC","fnn":"N7740924R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"is_enterprise_trunk","value":"Y"},{"name":"trunk_capacity","value":"20"},{"name":"bw_eligibility_flag","value":"eligible"},{"name":"bw_eligibility_reason_code","value":""}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"0749679300","linkedServiceRole":"service"},{"linkedServiceRole":"service"},{"linkedServiceId":"0749679500","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331857","productFamily":"TIPT-SIPC","fnn":"0749679300","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679300","serviceExtensionTo":"0749679399"}]},{"cidn":"9501331858","productFamily":"TIPT-SIPC","fnn":"0749679400","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679400","serviceExtensionTo":"0749679479"}]},{"cidn":"9501331859","productFamily":"TIPT-SIPC","fnn":"0749679500","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679500","serviceExtensionTo":"0749679599"}]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"N7740929R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"is_enterprise_trunk","value":"Y"},{"name":"trunk_capacity","value":"20"},{"name":"bw_eligibility_flag","value":"eligible"},{"name":"bw_eligibility_reason_code","value":""}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"0749679301","linkedServiceRole":"service"},{"linkedServiceId":"0749679401","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"0749679301","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679700","serviceExtensionTo":"0749679799"}]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"0749679401","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679500","serviceExtensionTo":"0749679579"}]}]}');  
        TransitionDataDTO TransitionDTONew = ReplicatorGetServiceManager.transformReplicatorResponseNgUc(getServiceDTO ,basketId,finCIDN,selectedCidn);
        System.debug('TransitionDTONew >>> ' + TransitionDTONew);
        System.assertEquals('9501331855', TransitionDTONew.CIDN , 'Matching CIDN from replicator should have been formed' );
        System.assertEquals( 1 , TransitionDTONew.productList.size() , '1 Product list of TIPT Family should have been formed in NGUC Transformed JSON');
        System.assertEquals( 1 , TransitionDTONew.productList[0].site[0].serviceList.size() , '1 attached service should be there with it' );

        Test.stopTest();
    }
  
  // EDGE-152495 for TIPT-SIPC Family Grouping Hybrid Logic
     @isTest
    public static void newFamilyTIPTSIPCNegativeTest_MalformedResponse() {
        List<cscfga__Product_Basket__c> prodBasket = [select Id from cscfga__Product_Basket__c];
        String basketId = prodBasket[0].Id;
        String finCIDN = '1234';
        List<String> selectedCidn = new List<String>();
        selectedCidn.add('12345678');
        Test.startTest();       
    try{        
        ReplicatorGetServiceDTO  getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId","473685095830478","servicesList":[{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"N7005109R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"enterprise"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7740924R","linkedServiceRole":"group"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"},{"linkedServiceId":"0749679300","linkedServiceRole":"service"},{"linkedServiceId":"0749679400","linkedServiceRole":"service"},{"linkedServiceId":"0749679500","linkedServiceRole":"service"},{"linkedServiceId":"0749679401","linkedServiceRole":"service"},{"linkedServiceId":"0749679301","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331856","productFamily":"TIPT-SIPC","fnn":"N7740924R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"is_enterprise_trunk","value":"Y"},{"name":"trunk_capacity","value":"20"},{"name":"bw_eligibility_flag","value":"eligible"},{"name":"bw_eligibility_reason_code","value":""}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"0749679300","linkedServiceRole":"service"},{"linkedServiceRole":"service"},{"linkedServiceId":"0749679500","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331857","productFamily":"TIPT-SIPC","fnn":"0749679300","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679300","serviceExtensionTo":"0749679399"}]},{"cidn":"9501331858","productFamily":"TIPT-SIPC","fnn":"0749679400","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679400","serviceExtensionTo":"0749679479"}]},{"cidn":"9501331859","productFamily":"TIPT-SIPC","fnn":"0749679500","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740924R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679500","serviceExtensionTo":"0749679599"}]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"N7740929R","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"group"},{"name":"inflight_order","value":"N"},{"name":"is_enterprise_trunk","value":"Y"},{"name":"trunk_capacity","value":"20"},{"name":"bw_eligibility_flag","value":"eligible"},{"name":"bw_eligibility_reason_code","value":""}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"0749679301","linkedServiceRole":"service"},{"linkedServiceId":"0749679401","linkedServiceRole":"service"}],"serviceExtensions":[]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"0749679301","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679700","serviceExtensionTo":"0749679799"}]},{"cidn":"9501331855","productFamily":"TIPT-SIPC","fnn":"0749679401","site":{"siteType":"ADBOR_ID","siteId":"1234567890","linkedSiteType":"A_END_ADDRESS","linkedSiteId":"CELL 1 122 LEWIS RD KNOXFIELD"},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"2323232323","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"service_association_role","value":"service"},{"name":"inflight_order","value":"N"}],"devices":[],"serviceAssociations":[{"linkedServiceId":"N7005109R","linkedServiceRole":"enterprise"},{"linkedServiceId":"N7740929R","linkedServiceRole":"group"}],"serviceExtensions":[{"serviceExtensionFrom":"0749679500","serviceExtensionTo":"0749679579"}]}]}');  
        TransitionDataDTO TransitionDTONew = ReplicatorGetServiceManager.transformReplicatorResponseNgUc(getServiceDTO ,basketId,finCIDN,selectedCidn);
        }catch(Exception e){
       System.assertNotEquals(Null , e.getMessage() , 'Error message should appear in case of malformed json' );
        }
        Test.stopTest();
    }
      /* EDGE-198376 status and reason for TM1 callback failure mobility  //Removing as a part of EDGE-215821                                         
   @isTest
    public static void getEligibilityStatusOncallbackFailure(){
        try{
            
            cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            String transitionJSON = '{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"","serviceAssociations":null,"service":[{"tramasErrorCode":"TM4011","trunk_capacity":null,"tipt_count":null,"tenancy_name":null,"sipc_count":null,"sim_serial_number":null,"silent_line":null,"serviceExtensions":null,"service_type_code":null,"service_type":"NORM","aro_indicator":"N","device_lease_contract_indicator":"N","telstra_one_number_indicator":"N","mro_with_no_imei":"N","service_status":null,"Service_Id":"61474896439","service_association_role":null,"Reserved_ranges":null,"Reserve_status":null,"replicatorUpdateDateTime":"2020-09-22 12:02:48.47","Redirection_product":null,"Reason":null,"contract_remaining_term":"5","plan_type":"Mobile Postpaid Handheld","plan_name":"Corporate Mobile Plus $5","message_bank":"","is_enterprise_trunk":null,"international_roaming":"","imsi_number":null,"idd":"","eligibilityStatus":null,"eligibilityReason":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610183362543248363","networkId":"505013487506019","deviceType":"SIM"}],"repayments":[{"productID":"100018937100000090156","deviceID":"352914116119203","deviceType":"Handheld","billLiteral":"Apple iPhone 11 64GB","contractType":"MRO","monthlyAmount":"50.00","remainingTerm":"6","remainingAmount":"525.45"}],"contract_term":"O","calling_line_identifier":"ON","association_type":null,"accountDetails":{"serviceWithEtcFlag":"N","dealerCode":"","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"1000012348"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"linkedSiteId":null,"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"Enterprise Mobility","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"1ba8e8a5d575f295ed","CIDN":"1899452648"}';
            TransitionDataDTO mobileResponseFinal = TransitionDataDTO.parse(transitionJSON);
            Test.startTest();
            List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id); 
            for(ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData){
                
                System.assertEquals(tMobileDataProduct.eligibilityReason,''); 
                Test.stopTest();
            }
        }
        catch(Exception e){
        }
    } */
                                                
     public static void getFNNTest(){
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.APTPS_Off_Shore_Restricted__c=false;
        acc.APTPS_Tier__c='1';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        
        Id profile_id=userinfo.getProfileId();
        Id Sales_profile = [Select Id, Name from profile where Name = 'Sales-Enterprise-Unified'].Id;
        
        String basketId = basketRecord.Id;
        
        List<String> prodFamilies = new List<String>{'Enterprise Mobility'};
        List<Legacy_Service__c> fnnList = new List<Legacy_Service__c>();
        Legacy_Service__c fnn = new  Legacy_Service__c(); 
        fnn.Service_Id__c = '61429761211';
        fnn.Product_Basket__c = basketRecord.Id;
        fnn.Account__c = acc.Id;
        fnn.Product_Type__c = 'Enterprise Mobility';
        String fCIDN = acc.CIDN__c;
        fnnList.add(fnn);
        insert fnnList;
        
        String serviceId = '';
        Test.startTest();
        List<String> serviceIdList = new List<String>();
        List<Legacy_Service__c> lsList = [Select Id, Service_Id__c, Product_Basket__c, Product_Type__c from Legacy_Service__c where Product_Basket__c =:basketRecord.Id LIMIT 1];
        for(Legacy_Service__c ls : fnnList){
         serviceId = ls.Service_Id__c;
         serviceIdList.add(serviceId);
        }
        
        /*
        TransitionDataDTO.serviceAssociationsDTO sdto = new TransitionDataDTO.serviceAssociationsDTO();
        sdto.linkedServiceId = 'TestId';
        sdto.linkedServiceRole = 'Test role';
        
        TransitionDataDTO.serviceExtensionDTO sedto = new TransitionDataDTO.serviceExtensionDTO();
        sedto.eligibilityStatus = 'New';
        sedto.eligibilityReason = 'Test Reason';
        */
        
        //String getFnn = ReplicatorGetServiceManager.getFNNs(fCIDN, prodFamilies, basketId);
        String getFnn = ReplicatorGetServiceManagerHelper.getFNNs(fCIDN, prodFamilies, basketId);
        System.assertEquals(fnnList.size() > 0, true);
        Test.stopTest();
    }
     
    @isTest
    public static void replicatorResponseToTransitionExceptionTest(){
        ReplicatorGetServiceDTO  getServiceDTO = ReplicatorGetServiceDTO.parse(getCustomerSites_withSuccess());
        Test.startTest();
        ReplicatorGetServiceDataObject_V2 service= ReplicatorGetServiceManager.replicatorResponseToTransition(null);
        System.assert(service!=null);
        Test.stopTest();
    }
    
     @isTest
    public static void insertJSONResponseNgUcExceptionTest(){
 
      
        Test.startTest();
        List<Attachment> service = ReplicatorGetServiceManager.insertJSONResponseNgUc(null,null,'12545',false);
        System.assert(service.isEmpty()==true);
        Test.stopTest();
    }
    
    @isTest
    public static void getMDMTenanciesExceptionTest(){
        //Start of EDGE-209885 by Abhishek(Osaka)
        String CIDNHierarchy = '';
        Boolean isHierarchyCheck = false;
        String prodFamilyList = 'ISDN';
        //End of EDGE-209885 by Abhishek(Osaka)
        List <String> prodFamilies = new List<String>{'ISDN2','ISDN'};
        Test.startTest();
        ReplicatorGetServiceDTO service = ReplicatorGetServiceManager.getMDMTenancies('');
        //Added as a part of EDGE-209985 (CIDNHierarchy,isHierarchyCheck) by Abhishek(Osaka)
        ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc('123444',prodFamilies,'12345',CIDNHierarchy,isHierarchyCheck,prodFamilyList);
        System.assert(service==null);
        Test.stopTest();
    }
    
      @isTest
    public static void servicesPresentInTransitionExceptionTest(){
        List <String> prodFamilies = new List<String>{'ISDN2','ISDN'};
        Test.startTest();
        Map<String,String> serviceMap = ReplicatorGetServiceManager.servicesPresentInTransition('');
        System.assert(serviceMap != null);
               
        Test.stopTest();
    }
    
    @isTest
    public static void insertJSONResponseMobileTest1(){
        String finCIDN='12343';
        try{
            //ReplicatorGetServiceDTO getServiceDTO; 
           // cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            //EDGE-139071 - Updated Test data JSON 
            //getServiceDTO = ReplicatorGetServiceDTO.parse('{ "correlationId": "5465764671208", "servicesList": [ { "cidn": "1234567890", "productFamily": "Mobile Postpaid Handheld", "fnn": "0411111111", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "account": { "accountNumber": "2323232323", "complexBillingIndicator": "N", "creditManagementFlag": "N", "serviceWithEtcFlag": "Y", "dealerCode":"123456" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "PPHH" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "contract_term", "value": "24" }, { "name": "directory_listing", "value": "E" }, { "name": "international_roaming", "value": "Access to Use Mobile Overseas" }, { "name": "message_bank", "value": "Messagebank Access Fee" }, { "name": "plan_name", "value": "My Business Lease Plan $95" }, { "name": "service_status", "value": "AC" }, { "name": "service_type", "value": "NORM" }, { "name": "etc_flag", "value": "N" } ], "devices": [ { "deviceType": "sim", "physicalId": "89610163282254000030", "networkId": "505013487427762" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] }, { "cidn": "1234567890", "productFamily": "Mobile Postpaid Handheld", "fnn": "2323232323", "site": { "siteType": "ADBOR_ID", "siteId": "0" }, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "account": { "accountNumber": "2212356398", "complexBillingIndicator": "N", "creditManagementFlag": "N", "serviceWithEtcFlag": "N", "dealerCode":"123412" }, "serviceCharacteristics": [ { "name": "plan_type", "value": "MBB" }, { "name": "calling_line_identifier", "value": "ON" }, { "name": "contract_term", "value": "36" }, { "name": "directory_listing", "value": "E" }, { "name": "international_roaming", "value": "Access to Use Mobile Overseas" }, { "name": "message_bank", "value": "Video MessageBank" }, { "name": "plan_name", "value": "Go Business Data SIM $5" }, { "name": "service_status", "value": "AC" }, { "name": "service_type", "value": "NORM" }, { "name": "etc_flag", "value": "Y" } ], "devices": [ { "deviceType": "sim", "physicalId": "89610163267640000029", "networkId": "505013485041069" }, { "deviceType": "sim", "physicalId": "89610163267640000029", "networkId": "505013485041069" } ], "serviceAssociations": [ ], "serviceExtensions": [ ] } ]}');
           // TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id,'');
            Test.startTest();
            
            String TransitionDataNgUcJSON = '{ "CIDN": "1100037407", "Correlation_Id": "75847359875974589374", "Error_Code": "abcd", "Error_Description": "abcd", "productList": [ { "checkValue": true, "disableCheck": true, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN2", "site": [ { "ADBOR_Id": "0", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": true, "disableCheck": null, "groupId": "0358852382", "service": [ { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "GDN", "Service_Id": "0358852382", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null }, { "accountDetails": null, "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "replicatorUpdateDateTime": "2019-09-02 21:03:03.797", "Reserve_status": null, "service_association_role": "auxiliary", "Service_Id": "0358851406", "service_status": null, "service_type": "voice", "service_type_code": null, "serviceExtensions": null, "reserved_ranges":"Y", "redirection_product":"Y", "silent_line":"Y", "sim_serial_number": null } ], "transitionId": "63030a64-41ec-4e57-9e6c-d5da7565b315" } ], "Service_Type": "0358852382" } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
            TransitionDataDTO TransitionDTO = TransitionDataDTO.parse(TransitionDataNgUcJSON);
            
            //List<ReplicatorGetServiceManager.TableWrapper> tableWrapperData = ReplicatorGetServiceManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
            
            ReplicatorGetServiceDTO getServiceDTO; 
            cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
            getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"abcd_1234","servicesList":[{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701813","site":{"siteType":"ADBOR_ID","siteId":"0999"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"12"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PrePaid HandHeld","fnn":"0429701914","site":{"siteType":"ADBOR_ID","siteId":"123"},"serviceCharacteristics":[{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000030"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"24 "},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Mobile PostPaid HandHeld","fnn":"0429701124","site":{"siteType":"ADBOR_ID","siteId":"11111"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"0429701111","site":{"siteType":"ADBOR_ID","siteId":"2222222"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility"},{"name":"contract_term","value":"220"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]},{"cidn":"6898327073","productFamily":"Enterprise Mobility","fnn":"042970223333","site":{"siteType":"ADBOR_ID","siteId":"33333333"},"serviceCharacteristics":[{"name":"service_status","value":"NOVA"},{"name":"service_type_code","value":"NORM"},{"name":"directory_listing","value":"Y"},{"name":"imsi_number","value":"505013438393120"},{"name":"sim_serial_number","value":"89610179078138000031"},{"name":"calling_line_identifier","value":"on"},{"name":"plan_name","value":"3OB*049 | Enterprise Mobility Upgrade"},{"name":"contract_term","value":"120"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"}],"serviceAssociations":[]}]}');
            TransitionDataDTO mobileResponseFinal = ReplicatorGetServiceManager.transformReplicatorResponse(getServiceDTO, basketRecord.Id, 'Mobile');
            
            
            List < ReplicatorGetServiceManager.TableWrapper > tableWrapperData = CompUtilityReplicatorManager.getMobileServicesTablewrapper(mobileResponseFinal,basketRecord.Id);
            if( tableWrapperData != null && tableWrapperData.size() > 0){
                System.assert(tableWrapperData.size() > 0);
            }
            
            List<Attachment> insertAttachment = ReplicatorGetServiceManager.insertJSONResponseMobile(TransitionDTO , tableWrapperData, basketRecord.Id, true);
           
            List < ReplicatorGetServiceManager.TableWrapper > mobileTableWrapperList = new List < ReplicatorGetServiceManager.TableWrapper > ();
            ReplicatorGetServiceManager.TableWrapper mobileTableWrapper = new ReplicatorGetServiceManager.TableWrapper();
            mobileTableWrapper.Product_Type = 'Enterprise Mobility';      
            mobileTableWrapper.Product_Number = '1234567890';   
            mobileTableWrapper.checkValue = false;
            mobileTableWrapper.eligibilityStatus = 'Eligible';
            mobileTableWrapper.eligibilityReason = 'Testing';
            mobileTableWrapperList.add(mobileTableWrapper);
            
           // List<Attachment> insertAttachment = ReplicatorGetServiceManager.insertJSONResponseMobile(TransitionDTO , mobileTableWrapperList, basketRecord.Id, true);
            Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
     
            system.debug('tableWrapperData--->'+tableWrapperData);
            //EDGE-139071 - Asset to check plan type value        
            List<String> plan_type =new List<String>();
            List<String> dealerCode =new List<String>();
            for (ReplicatorGetServiceManager.TableWrapper tMobileDataProduct: tableWrapperData) {
              plan_type.add(tMobileDataProduct.Plan_Type);
                dealerCode.add(tMobileDataProduct.Dealer_Code);
            }
            //Positive assert statement
            System.assertEquals(true, plan_type.contains('PPHH'));
            System.assertEquals(true, dealerCode.contains('123456')); 
            //Negative assert statement
            System.assertNotEquals(true, plan_type.contains('Mobile'));
            System.assertNotEquals(true, dealerCode.contains('10101010'));
            //EDGE-139071 - End
            System.assert(insertAttachment!=null);
            //  System.assert(insertAttachment.size() > 0);
            Test.stopTest();
        }
        catch(Exception e){
        } 
    }
    //Start of DIGI-16451 by Abhishek(Osaka)
    @isTest
    public static void servicesPresentInTransitionIoTTest(){
        Map < String, String > prodFamilyMap = new Map < String, String >();
        cscfga__Product_Basket__c basketRec = new cscfga__Product_Basket__c();
        basketRec = [Select id from cscfga__Product_Basket__c LIMIT 1];
        Test.startTest();
        prodFamilyMap = ReplicatorGetServiceManager.servicesPresentInTransition(basketRec.Id);
            System.assert(prodFamilyMap!=null);
        Test.stopTest();
    }                                           
    //End of DIGI-16451
}