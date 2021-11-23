@isTest
public class TransitionProductBasketCreationTest {

  static testMethod void  testCWPProdBasCreation() {
    List<ReplicatorGetServiceDataObject.SiteDTO> getSiteDTO = new List<ReplicatorGetServiceDataObject.SiteDTO>();
    List<ReplicatorGetServiceDataObject.ProductDTO> productDTOList = new List<ReplicatorGetServiceDataObject.ProductDTO>();
    List<ReplicatorGetServiceDataObject.ProductDTO> productDTOList1 = new List<ReplicatorGetServiceDataObject.ProductDTO>();
    List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
    List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList1 = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
    List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO> serviceCharList = new  List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO>();
    List<ReplicatorGetServiceDataObject.ServiceRelationshipDTO> servicerelList = new  List<ReplicatorGetServiceDataObject.ServiceRelationshipDTO>();
    List<ReplicatorGetServiceDataObject.ServiceExtensionDTO> serviceextList = new  List<ReplicatorGetServiceDataObject.ServiceExtensionDTO>();
    ReplicatorGetServiceDataObject.ServiceCharacteristicDTO schar = new ReplicatorGetServiceDataObject.ServiceCharacteristicDTO();
    schar.name = 'Zone';
    schar.value = '1';

    ReplicatorGetServiceDataObject.ServiceCharacteristicDTO schar1 = new ReplicatorGetServiceDataObject.ServiceCharacteristicDTO();
    schar1.name = 'Type';
    schar1.value = 'Fixed Seat';

    serviceCharList.add(schar);
    serviceCharList.add(schar1);

    ReplicatorGetServiceDataObject.ServiceExtensionDTO se = new ReplicatorGetServiceDataObject.ServiceExtensionDTO();
    se.Services_From = '003100';
    se.Services_To = '003149';
    serviceextList.add(se);
    ReplicatorGetServiceDataObject.ServiceExtensionDTO se1 = new ReplicatorGetServiceDataObject.ServiceExtensionDTO();
    se1.Services_From = '003151';
    se1.Services_To = '003200';
    serviceextList.add(se1);
    ReplicatorGetServiceDataObject.ServiceExtensionDTO se2 = new ReplicatorGetServiceDataObject.ServiceExtensionDTO();
    se2.Services_From = '003275';
    se2.Services_To = '003300';
    serviceextList.add(se2);

    ReplicatorGetServiceDataObject.ServiceRelationshipDTO sr = new ReplicatorGetServiceDataObject.ServiceRelationshipDTO();
    sr.serviceExtension = serviceextList;
    servicerelList.add(sr);

    ReplicatorGetServiceDataObject.ServiceDTO  service1 = new ReplicatorGetServiceDataObject.ServiceDTO();
    service1.Service_Id = '003150';
    service1.serviceRelationship = servicerelList;
    service1.serviceCharacteristic = serviceCharList;
    ReplicatorGetServiceDataObject.ServiceDTO  service2 = new ReplicatorGetServiceDataObject.ServiceDTO();
    service2.Service_Id = '0031501';
    service2.serviceCharacteristic = serviceCharList;
    ReplicatorGetServiceDataObject.ServiceDTO  service3 = new ReplicatorGetServiceDataObject.ServiceDTO();
    service3.Service_Id = '0031502';
    service3.serviceCharacteristic = serviceCharList;
    ReplicatorGetServiceDataObject.ServiceDTO  service4 = new ReplicatorGetServiceDataObject.ServiceDTO();
    service4.Service_Id = '0031503';
    service4.serviceCharacteristic = serviceCharList;

    serviceList.add(service1);
    serviceList.add(service3);
    serviceList1.add(service2);
    serviceList1.add(service4);

    ReplicatorGetServiceDataObject.ProductDTO pd1 = new ReplicatorGetServiceDataObject.ProductDTO();
    ReplicatorGetServiceDataObject.ProductDTO pd2 = new ReplicatorGetServiceDataObject.ProductDTO();

    pd1.service = serviceList;
    pd1.Product_Type = 'PSTN';
    pd2.service = serviceList1;
    pd2.Product_Type = 'ISDN';

    productDTOList.add(pd1);
    productDTOList1.add(pd2);

    ReplicatorGetServiceDataObject.SiteDTO sitedt1 = new ReplicatorGetServiceDataObject.SiteDTO();
    ReplicatorGetServiceDataObject.SiteDTO sitedt2 = new ReplicatorGetServiceDataObject.SiteDTO();

    sitedt1.ADBOR_Id = 'AddressID-1Test';
    sitedt1.productList = productDTOList;

    sitedt2.ADBOR_Id = 'AddressID-2Test';
    sitedt2.productList = productDTOList;

    getSiteDTO.add(sitedt1);
    getSiteDTO.add(sitedt2);

    ReplicatorGetServiceDataObject rsd = new ReplicatorGetServiceDataObject();
    rsd.Site = getSiteDTO;
    rsd.CIDN = 'Test Trans';


    Account acc = AccountTestFactory.buildAccount('Test Name');
    acc.CIDN__c = 'Test Trans';
    insert acc;
    cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1Test');
    insert address;
    cscrm__Address__c address1 = AccountTestFactory.buildAddress('AddressID-2Test');
    insert address1;

    List<Contact> contactInsertList = new List<Contact>();
    List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();

    Contact pc = AccountTestFactory.buildContact(acc, 'testPC', 'testabc122@test.com');
    contactInsertList.add(pc);
    Contact sc = AccountTestFactory.buildContact(acc, 'testSC', 'estabc13222@testdom.com');
    contactInsertList.add(sc);

    Contact pc1 = AccountTestFactory.buildContact(acc, 'testPC1', 'testabc122@test1.com');
    contactInsertList.add(pc1);
    Contact sc1 = AccountTestFactory.buildContact(acc, 'testSC1', 'estabc13222@testdom1.com');
    contactInsertList.add(sc1);

    insert contactInsertList;

    cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
    site.Primary_Contact__c = pc.id;
    site.Secondary_Contact__c = sc.id;
    insert site;

    cscrm__Site__c site1 = AccountTestFactory.buildSite(address1.id, acc.id);
    site.Primary_Contact__c = pc1.id;
    site.Secondary_Contact__c = sc1.id;
    insert site1;
    cscfga__Product_Category__c pcategory = ProductTestFactory.buildProductCategory();
    pcategory.name = 'Modular Products';
    insert pcategory;

    cscfga__Product_Definition__c pdef = ProductTestFactory.buildProductDefinition('Voice Numbers', '');
    insert pdef;
    cscfga__Product_Definition__c pdef1 = ProductTestFactory.buildProductDefinition('Voice FNN Details', '');
    insert pdef1;


    List<cscfga__Attribute_Definition__c> atrList = new List<cscfga__Attribute_Definition__c>();
    cscfga__Attribute_Definition__c attrd = ProductTestFactory.buildAttributeDefinition('Migrated', pdef.Id);
    atrList.add(attrd);
    cscfga__Attribute_Definition__c attrd1 = ProductTestFactory.buildAttributeDefinition('Product Specification', pdef.Id);
    atrList.add(attrd1);
    cscfga__Attribute_Definition__c attrd2 = ProductTestFactory.buildAttributeDefinition('Legacy Offer Name', pdef.Id);
    atrList.add(attrd2);

    attrd = ProductTestFactory.buildAttributeDefinition('Migrated', pdef1.Id);
    atrList.add(attrd);
    //attrd1 = ProductTestFactory.buildAttributeDefinition('Product Specification', pdef1.Id);
    //atrList.add(attrd1);
    attrd2 = ProductTestFactory.buildAttributeDefinition('Legacy Offer Name', pdef1.Id);
    atrList.add(attrd2);

    insert atrList;
    cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
    piSeat.Name = 'Standard - Zone1';
    piSeat.Package_Name__c = 'Connected Workplace';
    piSeat.Type__c = 'Standard';
    piSeat.External_Id__c = 'test';
    piSeat.cspmb__Product_Definition_Name__c = 'User';
    piSeat.Zone__c = 'Zone 1';
    insert piSeat;

    cscfga__Configuration_Offer__c  offer = new cscfga__Configuration_Offer__c();
    offer.Name = 'Connected Workplace Package';
    insert offer;

    cscfga__Configuration_Offer__c  offer1 = new cscfga__Configuration_Offer__c();
    offer.Name = 'Connected Workplace';
    insert offer1;

    cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
    config.cscfga__Description__c = 'test Description ';
    config.cscfga__Contract_Term__c = 36;
    config.Name = 'User 1';
    config.cscfga__configuration_offer__c = offer.id;
    config.cscfga__Product_Basket__c = null;
    config.Offer_Reference__c = offer.Id;
    update config;

    cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
    config1.cscfga__Description__c = 'test Description1 ';
    config1.cscfga__Contract_Term__c = 36;
    config1.Name = 'Site';
    config1.cscfga__configuration_offer__c = offer.id;
    config1.Offer_Reference__c = offer.Id;
    config1.cscfga__Product_Basket__c = null;
    update config1;

    cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
    config2.cscfga__Description__c = 'test Description ';
    config2.cscfga__Contract_Term__c = 36;
    config2.Name = 'User 1';
    config2.cscfga__configuration_offer__c = offer1.id;
    config2.Offer_Reference__c = offer1.Id;
    config2.cscfga__Product_Basket__c = null;
    update config2;


    List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
    cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('User', 'test', config.id);
    attList.add(attr0);

    cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('ZoneSelected', 'Zone 2', config.id);
    attList.add(attr1);

    cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('TypeUser', 'Standard', config.id);
    attList.add(attr2);

    cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '5', config.id);
    attList.add(attr3);

    cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('TOC', '500.00', config.id);
    attList.add(attr4);

    cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('TRC', '600', config.id);
    attList.add(attr5);

    cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('Zone', null, config.id);
    attList.add(attr6);

    insert attList;

    Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
    insert opp;
    System.assertNotEquals(null, opp);

    CatalogueFiltering__mdt cfilter = [Select Non_Package_Offer__c, Package_Offer__c from  CatalogueFiltering__mdt WHERE Package_Offer__c = 'Connected Workplace Package' LIMIT 1];

    String offerName = cfilter.Package_Offer__c;
    System.assertEquals('Connected Workplace Package', cfilter.Package_Offer__c);

    Test.startTest();
    List<String> offerList = TransitionProductBasketCreation.getEligibleOffersForTransition(rsd);
    PageReference pg = TransitionProductBasketCreation.createTransitionBasket(rsd, offerList, opp.Id);

    //for IPVPN account and Legacy Subscription
    List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
    csord__Subscription__c sub = ProductTestFactory.buildSubscription('IP VPN', acc.id, null, null);
    subList.add(sub);
    csord__Subscription__c sub1 = ProductTestFactory.buildSubscription('Legacy Subscription', acc.id, null, null);
    subList.add(sub1);
    insert subList;

    offerList = TransitionProductBasketCreation.getEligibleOffersForTransition(rsd);
    PageReference pg1 = TransitionProductBasketCreation.createTransitionBasket(rsd, offerList, opp.Id);
    Test.stopTest();
    System.assertNotEquals(null, pg1);
  }
}