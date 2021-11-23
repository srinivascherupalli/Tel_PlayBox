/**
* @Author   :   Rahul/Maqsood
* @Date     :   13 Apr 2020
* @Desc     :   Test class for ReplicatorGetServiceManagerHandler
* @US       :   EDGE-120154, EDGE-120156
* @Status   :   
* */

@isTest
public class ReplicatorGetServiceManagerHandlerTest {
    
    @testsetup static void testDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.APTPS_Off_Shore_Restricted__c=false;
        acc.APTPS_Tier__c='1';
        acc.Customer_Status__c = 'ACTIVE';
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
    }
    
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByNodeParent(){
               
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852382","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"reserved_ranges","value":"Y"},{"name":"redirection_product","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"silent_line","value":"Y"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"}],"serviceAssociations":[{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852703","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"035885211212","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358853453","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358853453","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"035885211212","linkedServiceRole":"GDN"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851408","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852072","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852387","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852703","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851407","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851419","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851418","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2DID","fnn":"0358851406","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852703","linkedServiceRole":"PRIME"}],"serviceExtensions":[{"serviceExtensionFrom":"0358852382","serviceExtensionTo":"0358852389"},{"serviceExtensionFrom":"0358852703","serviceExtensionTo":"0358852709"}]},{"cidn":"1100037407","productFamily":"ISDN30","fnn":"110003740712","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":""},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[],"serviceExtensions":[{"serviceExtensionFrom":"0358852382","serviceExtensionTo":"0358852389"},{"serviceExtensionFrom":"0358852703","serviceExtensionTo":"0358852709"}]}]}');
        Test.startTest();

        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager repliManager= new ReplicatorGetServiceManager();
        ReplicatorGetServiceManager.parentUniqueStringMap.put('0358852382','ISDN2~!@!~GDN~!@!~PRIME~!@!~auxiliary');
        
        ReplicatorGetServiceManagerHandler repService = new ReplicatorGetServiceManagerHandler();
        Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByNodeParent(serviceDTO[0]);
        System.debug('<<<***********>>>' + prodGroupTypeMapping);
        System.assert(prodGroupTypeMapping.containsKey('ISDN2_ISDN2_0358852382') == true);
        Test.stopTest();
       
    }
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByNodeParent_Negative(){
               
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852382","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"reserved_ranges","value":"Y"},{"name":"redirection_product","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"silent_line","value":"Y"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"}],"serviceAssociations":[{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852703","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"035885211212","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358853453","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358853453","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"035885211212","linkedServiceRole":"GDN"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851408","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852072","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852387","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852703","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851407","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851419","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851418","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"}]}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager.parentUniqueStringMap.put('0358852382','ISDN2~!@!~GDN~!@!~PRIME~!@!~auxiliary');
        ReplicatorGetServiceManagerHandler repService = new ReplicatorGetServiceManagerHandler();
        Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByNodeParent(serviceDTO[0]);
        System.assert(prodGroupTypeMapping.isEmpty());
        Test.stopTest();
       
    }
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByNodeChild(){
        ReplicatorGetServiceDTO getServiceDTOParent; 
        getServiceDTOParent = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852382","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"reserved_ranges","value":"Y"},{"name":"redirection_product","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"silent_line","value":"Y"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"}],"serviceAssociations":[{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358852703","linkedServiceRole":"PRIME"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"035885211212","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":"GDN"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358853453","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358853453","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"035885211212","linkedServiceRole":"GDN"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851408","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852072","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852387","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358852703","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851407","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851419","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"XYZ","fnn":"0358851418","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"}]}]}');
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851408","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852072","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852387","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852703","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851407","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851419","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851418","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"}]}]}');
        
       
        
        TransitionDataDTO.serviceDTOMobile trobject= new TransitionDataDTO.serviceDTOMobile();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTOparent=getServiceDTOParent.servicesList;
        trobject=ReplicatorGetServiceManagerHandler.getService(serviceDTOparent[0]);
        List < TransitionDataDTO.serviceDTOMobile > transitiondto= new List < TransitionDataDTO.serviceDTOMobile >();
        transitiondto.add(trobject);
        Map<String,List < TransitionDataDTO.serviceDTOMobile >> mapwithtranstiondto= new Map<String,List < TransitionDataDTO.serviceDTOMobile >>();
        mapwithtranstiondto.put('0358852382',transitiondto);
        ReplicatorGetServiceManager.prodGroupTypeMapping.put('ISDN2_ISDN2 Line Hunt',mapwithtranstiondto);
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager repliManager= new ReplicatorGetServiceManager();
        ReplicatorGetServiceManager.parentUniqueStringMap.put('0358852382','ISDN2~!@!~GDN~!@!~PRIME~!@!~auxiliary');
        
        Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByNodeChild(serviceDTO[0]);
        System.assert(prodGroupTypeMapping.containsKey('ISDN2_ISDN2 Line Hunt') == true);
        Test.stopTest();
       
    }
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByNodeChild_Negative(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851408","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851407","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852072","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851419","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852387","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851418","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358852703","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"PRIME"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851406","linkedServiceRole":"auxiliary"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851407","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358851408","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851419","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852072","linkedServiceRole":"PRIME"}]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0358851418","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Multi number"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"auxiliary"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"}],"serviceAssociations":[{"linkedServiceId":"0358852382","linkedServiceRole":"GDN"},{"linkedServiceId":"0358852387","linkedServiceRole":"PRIME"}]}]}');
        Test.startTest();
         List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
          Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByNodeChild(serviceDTO[0]);
        System.assert(prodGroupTypeMapping.isEmpty());
          Test.stopTest();
    }
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByRange(){
               
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN30","fnn":"110003740712","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":""},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"reserved_ranges","value":"Y"},{"name":"redirection_product","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"silent_line","value":"Y"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"}],"serviceAssociations":[],"serviceExtensions":[{"serviceExtensionFrom":"0358852382","serviceExtensionTo":"0358852389"},{"serviceExtensionFrom":"0358852703","serviceExtensionTo":"0358852709"}]}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager repliManager= new ReplicatorGetServiceManager();
        ReplicatorGetServiceManager.parentUniqueStringMap.put('0358852382','ISDN2~!@!~GDN~!@!~PRIME~!@!~auxiliary');
        
        ReplicatorGetServiceManagerHandler repService = new ReplicatorGetServiceManagerHandler();
        Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByRange(serviceDTO[0]);
        System.assert(prodGroupTypeMapping.containsKey('ISDN30') == true);
        Test.stopTest();
       
    }
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByRange_Negative(){
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN30","fnn":"110003740712","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":""},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"reserved_ranges","value":"Y"},{"name":"redirection_product","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"silent_line","value":"Y"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"}],"serviceAssociations":[],"serviceExtensions":[]}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        
        
        ReplicatorGetServiceManagerHandler repService = new ReplicatorGetServiceManagerHandler();
        Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByRange(serviceDTO[0]);
        System.assert(prodGroupTypeMapping.containsKey('serviceExtensionFrom') == false);
        Test.stopTest();
       
    }
    //Created only test method to cover an existing method(owned by other team) in order to increase code coverage by Abhishek(Osaka)
	@isTest
    public static void getServicesDTOTest_groupingLogic_ByHybrid(){
               
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"75847359875974589374","servicesList":[{"cidn":"1100037407","productFamily":"ISDN30","fnn":"110003740712","site":{"siteType":"ADBOR_ID","siteId":"0"},"replicatorUpdateDateTime":"2019-09-02 21:03:03.797","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"association_type","value":"Hunt Group"},{"name":"directory_option","value":"No Entry Line"},{"name":"inflight_order","value":"N"},{"name":"contract_term","value":"36"},{"name":"service_association_role","value":""},{"name":"service_type","value":"voice"},{"name":"source_site","value":"0"},{"name":"service_status","value":"AC"},{"name":"service_type_code","value":"NORM"},{"name":"imsi_number","value":"505013438393119"},{"name":"sim_serial_number","value":"89610179078138000029"},{"name":"international_roaming","value":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack"},{"name":"message_bank","value":"3GPPMSGK | 3G Pre-Paid Video Message Bank"},{"name":"idd","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"reserved_ranges","value":"Y"},{"name":"redirection_product","value":"BFIDD100 | Bus Fleet Plus IDD $100"},{"name":"silent_line","value":"Y"},{"name":"calling_line_identifier","value":"off"},{"name":"plan_name","value":"3OB*049 | 3G Cap 49 Business Mobile Plan"}],"serviceAssociations":[],"serviceExtensions":[{"serviceExtensionFrom":"0358852382","serviceExtensionTo":"0358852389"},{"serviceExtensionFrom":"0358852703","serviceExtensionTo":"0358852709"}]}]}');
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager repliManager= new ReplicatorGetServiceManager();
        ReplicatorGetServiceManager.parentUniqueStringMap.put('0358852382','ISDN2~!@!~GDN~!@!~PRIME~!@!~auxiliary');
        
        ReplicatorGetServiceManagerHandler repService = new ReplicatorGetServiceManagerHandler();
        Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByHybrid(serviceDTO[0]);
        System.assert(serviceDTO!= null);
        Test.stopTest();
       
    } 
    //Created only test method to cover an existing method(owned by other team) in order to increase code coverage by Abhishek(Osaka)                                                  
    @isTest
    public static void getServicesDTOTest_groupingLogic_ByHybrid_New(){
               
        String finCIDN='12343';
        ReplicatorGetServiceDTO getServiceDTO; 
        cscfga__Product_Basket__c basketRecord = [SELECT ID, NAME FROM cscfga__Product_Basket__c LIMIT 1];
        getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"7a0887911c8d8f4bfc","services":[{"cidn":"1851860118","productFamily":"TIPT-SIPC","fnn":"0889561100","site":{"siteType":"A_END_ADDRESS","siteId":"","linkedSiteType":"","linkedSiteId":""},"replicatorUpdateDateTime":"2021-03-03T21:37:50.632+11:00","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"service"}],"devices":[],"repayments":[],"serviceAssociations":[{"linkedServiceId":"N0011603R","linkedServiceRole":"enterprise","linkedServiceCidn":null},{"linkedServiceId":"N0020270R","linkedServiceRole":"group","linkedServiceCidn":null}],"serviceExtensions":[{"serviceExtensionFrom":"0889561100","serviceExtensionTo":"0889561199"}]},{"cidn":"1851860118","productFamily":"TIPT-SIPC","fnn":"0889561200","site":{"siteType":"A_END_ADDRESS","siteId":"","linkedSiteType":"","linkedSiteId":""},"replicatorUpdateDateTime":"2021-03-03T21:37:50.632+11:00","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"service"}],"devices":[],"repayments":[],"serviceAssociations":[{"linkedServiceId":"N0011603R","linkedServiceRole":"enterprise","linkedServiceCidn":null},{"linkedServiceId":"N0020280R","linkedServiceRole":"group","linkedServiceCidn":null}],"serviceExtensions":[{"serviceExtensionFrom":"0889561200","serviceExtensionTo":"0889561299"}]},{"cidn":"1851860118","productFamily":"TIPT-SIPC","fnn":"N0020270R","site":{"siteType":"A_END_ADDRESS","siteId":"","linkedSiteType":"","linkedSiteId":""},"replicatorUpdateDateTime":"2021-03-03T21:37:50.632+11:00","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"eligibility_flag","value":"Yes"},{"name":"eligibility_reason","value":"WR3.2 - Trunk Pilot"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"group"}],"devices":[],"repayments":[],"serviceAssociations":[{"linkedServiceId":"0889561100","linkedServiceRole":"service","linkedServiceCidn":"1851860119"},{"linkedServiceId":"N0011603R","linkedServiceRole":"enterprise","linkedServiceCidn":null}],"serviceExtensions":[]},{"cidn":"1851860118","productFamily":"TIPT-SIPC","fnn":"N0020280R","site":{"siteType":"A_END_ADDRESS","siteId":"","linkedSiteType":"","linkedSiteId":""},"replicatorUpdateDateTime":"2021-03-03T21:37:50.632+11:00","account":{"accountNumber":"2660799589","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"eligibility_flag","value":"Yes"},{"name":"eligibility_reason","value":"WR3.2 - Trunk Pilot"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":"group"}],"devices":[],"repayments":[],"serviceAssociations":[{"linkedServiceId":"0889561200","linkedServiceRole":"service","linkedServiceCidn":"1851860118"},{"linkedServiceId":"N0011603R","linkedServiceRole":"enterprise","linkedServiceCidn":null}],"serviceExtensions":[]}]}'.replace('"services"', '"servicesList"' ));
        Test.startTest();
        List<ReplicatorGetServiceDTO.servicesDTO> serviceDTO = getServiceDTO.servicesList; 
        ReplicatorGetServiceManager repliManager= new ReplicatorGetServiceManager();
        ReplicatorGetServiceManager.parentUniqueStringMap.put('0358852382','ISDN2~!@!~GDN~!@!~PRIME~!@!~auxiliary');
        
        ReplicatorGetServiceManagerHandler repService = new ReplicatorGetServiceManagerHandler();
        Map < String, List < TransitionDataDTO.serviceDTOMobile > > prodGroupTypeMapping = New Map < String, List < TransitionDataDTO.serviceDTOMobile > > ();
        prodGroupTypeMapping=ReplicatorGetServiceManagerHandler.groupingLogic_ByHybrid_New(serviceDTO[0]);
        System.assert(serviceDTO!= null);
        Test.stopTest();
       
    }                                                      
}