/**************************************************************************************************
 * @Author : Kamlesh Kumar
 * @Date : 18th July 2020
 * @Description : The test class cover the code for BasketSnapshotUtility.
 * @Jira :
 * **************************************************************************************************/

@isTest
public class BasketSnapshotUtilityTest {
  static blob b = [SELECT body FROM staticResource WHERE name = 'ServiceJSON'].body;
  static String serviceDTO = b.toString();
  static String serviceDTO_V2 = '{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"serviceExtension":[{"Services_To":"0246315099","Services_From":"0246315001","disableCheck":null,"checkValue":null}],"Service_Type":"Voice","Service_Id":"0246315000","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"checkValue":true}],"disableCheck":null,"checkValue":null}],"Product_Type":"ISDN-BRA","disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"266049834"}],"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICEa5f369527219745b8c","CIDN":"6892971200"}';
   
    /**
   *@Date : 18th July 2020
   *@Desc : This method creates dataset
   */
    private void setup() {
    EnvironmentVariable__c transitionClone = new EnvironmentVariable__c();
    transitionClone.name = 'TransitionClone';
    transitionClone.value__c = '3';
    insert transitionClone;
    // BasketSnapshot_DataHandler_Mapping_mdt mdt = new BasketSnapshot_DataHandler_Mapping_mdt();
    // mdt.Label = 'CMPServiceDetails';
    // mdt.QueryType = 'CMPServiceDetails';
    // mdt.Mapping_Class = 'MobilityDataHandler';
    // mdt.isActive = true;
    //insert mdt;
    Account acc = AccountTestFactory.buildAccount('TestAcc');
    acc.CIDN__c = '1234567890';
    acc.Customer_Status__c = 'Active';
    insert acc;
    //EDGE-127817 Start
    Billing_Account__c billAcc = new Billing_Account__c();
    billAcc.Billing_Account_Number__c = '700000506340';
    //billAcc.name = 'BA-0004772';
    billAcc.Account__c = acc.id;
    insert billAcc;
    EnvironmentVariable__c ev = new EnvironmentVariable__c();
    ev.name = 'Committed_Data';
    ev.value__c = 'True';
    insert ev;
    system.debug('billAcc@@::' + billAcc);
    //EDGE-127817 End
    Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
    opp.Product_Type__c = 'Modular';
    insert opp;
    cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
    basket.cscfga__Opportunity__c = opp.id;
    basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
    basket.csbb__Synchronised_With_Opportunity__c = true;
    basket.cscfga__Basket_Status__c = 'Valid';
    basket.cscfga__total_contract_value__c = 1000;
    insert basket;
    //EDGE-144228 Start
    cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
    basket1.cscfga__Opportunity__c = opp.id;
    basket1.csordtelcoa__Synchronised_with_Opportunity__c = true;
    basket1.csbb__Synchronised_With_Opportunity__c = true;
    basket1.cscfga__Basket_Status__c = 'Valid';
    basket1.cscfga__total_contract_value__c = 1100;
    insert basket1;
    //EDGE-144228 End
    //EDGE-147419-Test Data
    List<cscfga__Product_Basket__c> pbList = new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c pbBasket = ProductTestFactory.buildEmptyBasket();
    pbBasket.cscfga__Opportunity__c = opp.id;
    pbBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
    pbBasket.csbb__Synchronised_With_Opportunity__c = true;
    pbBasket.cscfga__Basket_Status__c = 'Valid';
    pbBasket.cscfga__total_contract_value__c = 1234;
    pbList.add(pbBasket);
    insert pbList;
    //EDGE-147419-End
    List<cscfga__Product_Basket__c> prodBasketList = new List<cscfga__Product_Basket__c>();
    cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test', 'Test');
    pd.product_Specification__c = 'DMCAT_ProductSpecification_000935';
    insert pd;
    cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test', 'Test');
    pd1.product_Specification__c = 'DMCAT_ProductSpecification_000871';
    insert pd1;
    cscfga__Product_Definition__c pd2 = ProductTestFactory.buildProductDefinition('Test', 'Test');
    pd2.product_Specification__c = 'DMCAT_ProductSpecification_000420';
    insert pd2;
    //EDGE-98336 - Start
    cscfga__Product_Definition__c pd3 = ProductTestFactory.buildProductDefinition('Test', 'Test');
    pd3.product_Specification__c = 'DMCAT_ProductSpecification_000747';
    insert pd3;
    //EDGE-140420 AND EDGE-143435--Changes Start here
    cscfga__Product_Definition__c pd4 = ProductTestFactory.buildProductDefinition('Test', 'Test');
    pd4.product_Specification__c = 'DMCAT_Offer_000646';
    insert pd4;
    //EDGE-140420 AND EDGE-143435--Changes Start here
    //EDGE-98336 - End
    List<cscfga__Configuration_Offer__c> listOffers = new List<cscfga__Configuration_Offer__c>();
    cscfga__Configuration_Offer__c offernameCWP = new cscfga__Configuration_Offer__c();
    offernameCWP.name = 'Connected Workplace';
    offernameCWP.cscfga__Active__c = true;
    offernameCWP.cscfga__Description__c = 'Connected Workplace';
    listOffers.add(offernameCWP);
    //DPG - 598
    cscfga__Configuration_Offer__c offernameIOT = new cscfga__Configuration_Offer__c();
    offernameIOT.Offer_Spec_Id__c = 'DMCAT_Offer_000964';
    offernameIOT.name = 'IOT Offer'; //EDGE-162365 Defect Fix
    offernameIOT.cscfga__Active__c = true;
    offernameIOT.cscfga__Description__c = '';
    listOffers.add(offernameIOT);
    cscfga__Configuration_Offer__c offernameCWP1 = new cscfga__Configuration_Offer__c();
    offernameCWP1.name = 'Connected Workplace Package';
    offernameCWP.cscfga__Active__c = true;
    offernameCWP.cscfga__Description__c = 'Connected Workplace Package';
    listOffers.add(offernameCWP1);
    cscfga__Configuration_Offer__c offernameMobility = new cscfga__Configuration_Offer__c();
    offernameMobility.name = 'CWP Mobility';
    offernameMobility.cscfga__Active__c = true;
    offernameMobility.cscfga__Description__c = 'CWP Mobility';
    listOffers.add(offernameMobility);
    cscfga__Configuration_Offer__c offernamePPHH = new cscfga__Configuration_Offer__c();
    offernamePPHH.Offer_Spec_Id__c = 'DMCAT_Offer_000646';
    offernamePPHH.name = 'Postpaid handheld - Individual';
    offernamePPHH.cscfga__Active__c = true;
    offernamePPHH.cscfga__Description__c = 'PPHH Individual S';
    listOffers.add(offernamePPHH);
    cscfga__Configuration_Offer__c offernameCMP = new cscfga__Configuration_Offer__c();
    offernameCMP.Offer_Spec_Id__c = 'DMCAT_Offer_000646';
    offernameCMP.name = 'Corporate Mobile Plus';
    offernameCMP.cscfga__Active__c = true;
    offernameCMP.cscfga__Description__c = '';
    listOffers.add(offernameCMP);
    //EDGE - 99894 - Start(Added by Aman Soni)
    cscfga__Configuration_Offer__c offernameDOP = new cscfga__Configuration_Offer__c();
    offernameDOP.Offer_Spec_Id__c = 'DMCAT_Offer_000783';
    offernameDOP.name = 'Device Outright Purchase';
    offernameDOP.cscfga__Active__c = true;
    offernameDOP.cscfga__Description__c = '';
    listOffers.add(offernameDOP);
    //EDGE - 99894 - End(Added by Aman Soni)
    //EDGE - 98374 - Start
    cscfga__Configuration_Offer__c offernameTC = new cscfga__Configuration_Offer__c();
    offernameTC.Offer_Spec_Id__c = 'DMCAT_Offer_000618';
    //DIGI-3352 : Name Change
    offernameTC.name = 'Adaptive Collaboration';
    offernameTC.cscfga__Active__c = true;
    offernameTC.cscfga__Description__c = '';
    listOffers.add(offernameTC);
    //EDGE - 98374 - End
    insert listOffers;
    List<Marketable_Offer__c> listOfOffers1 = new List<Marketable_Offer__c>();
    Marketable_Offer__c mo = new Marketable_Offer__c();
    mo.OfferDefinationName__c = 'Connected Workplace';
    mo.Name = 'Test MO';
    //mo.Offer_ID__c = 'D12333';
    mo.Offer_ID__c = 'DMCAT_Offer_000303';
    listOfOffers1.add(mo);
    Marketable_Offer__c mo1 = new Marketable_Offer__c();
    mo1.OfferDefinationName__c = 'Connected Workplace Solution';
    mo1.Name = 'Test MOdf';
    //mo1.Offer_ID__c = 'D12sd333';
    mo1.Offer_ID__c = 'DMCAT_Offer_000303';
    listOfOffers1.add(mo1);
    Marketable_Offer__c momdm = new Marketable_Offer__c();
    momdm.OfferDefinationName__c = 'MDM Tenancy';
    momdm.Name = 'Test MOdfs';
    //momdm.Offer_ID__c = 'D12sd333s';
    momdm.Offer_ID__c = 'DMCAT_Offer_000681';
    listOfOffers1.add(momdm);
    Marketable_Offer__c moMob = new Marketable_Offer__c();
    moMob.OfferDefinationName__c = 'Corporate Mobile Plus';
    moMob.Name = 'Corporate Mobile Plus';
    moMob.Offer_ID__c = 'DMCAT_Offer_000618';
    listOfOffers1.add(moMob);
    Marketable_Offer__c ngemId = new Marketable_Offer__c();
    ngemId.OfferDefinationName__c = 'Corporate Mobile Plus';
    ngemId.Name = 'Corporate Mobile Plus';
    ngemId.Offer_ID__c = 'DMCAT_Offer_001231';
    listOfOffers1.add(ngemId);
    //Marketable_Offer__c moTC = new Marketable_Offer__c();
    //EDGE - 98374 - Start
    Marketable_Offer__c moTC = new Marketable_Offer__c();
    //DIGI-3352 : Name Change
    moTC.OfferDefinationName__c = 'Adaptive Collaboration';
    //DIGI-3352 : Name Change
    moTC.Name = 'Adaptive Collaboration';
    moTC.Offer_ID__c = 'D12sd333z';
    listOfOffers1.add(moTC);
    //EDGE - 98374 - End
    // DPG 598
    Marketable_Offer__c ioTMob = new Marketable_Offer__c();
    ioTMob.OfferDefinationName__c = 'IoT solutions';
    ioTMob.Name = 'IoT Connectivity';
    ioTMob.Offer_ID__c = 'DMCAT_Offer_000964';
    listOfOffers1.add(ioTMob);
    //EDGE - 109389 - Start
    Marketable_Offer__c mongUCDevice = new Marketable_Offer__c();
    //DIGI-3352 : Name Change
    mongUCDevice.OfferDefinationName__c = 'Adaptive Collaboration';
    //DIGI-3352 : Name Change
    mongUCDevice.Name = 'Adaptive Collaboration';
    mongUCDevice.Offer_ID__c = 'D12sd333z';
    listOfOffers1.add(mongUCDevice);
    //EDGE - 109389 - End
    //EDEG-80783 :Start
    Marketable_Offer__c moPS = new Marketable_Offer__c();
    moPS.OfferDefinationName__c = 'Professional Services';
    moPS.Name = 'Professional Services-MDM Config';
    moPS.Offer_ID__c = 'DMCAT_Offer_000750';
    listOfOffers1.add(moPS);
    //EDEG-80783 :End
    //EDGE - 99894 - Start(Added by Aman Soni)
    Marketable_Offer__c moDOP = new Marketable_Offer__c();
    moDOP.OfferDefinationName__c = 'Device Outright Purchase Solution';
    moDOP.Name = 'Device Outright Purchase';
    moDOP.Offer_ID__c = 'DMCAT_Offer_000783';
    listOfOffers1.add(moDOP);
    //EDGE - 99894 - End(Added by Aman Soni)
    //EDGE - 105921 & EDGE-148067- Start
    Marketable_Offer__c moCMPCD = new Marketable_Offer__c();
    moCMPCD.OfferDefinationName__c = 'Corporate Mobile Plus';
    moCMPCD.Name = 'Corporate Mobile Plus';
    moCMPCD.Offer_ID__c = 'DMCAT_Offer_000646';
    listOfOffers1.add(moCMPCD);
    //EDGE - 105921 & EDGE-148067 - End
    //EDGE-98336 - Start
    Marketable_Offer__c moTID = new Marketable_Offer__c();
    moTID.OfferDefinationName__c = 'Telstra Internet Direct';
    moTID.Name = 'Telstra Internet Direct';
    moTID.Offer_ID__c = 'DMCAT_Offer_000709';
    listOfOffers1.add(moTID);
    //EDGE-144574 MDM Offer name updates in Quote, Order form, CIS and service terms documents
    Marketable_Offer__c tmdmOffer = new Marketable_Offer__c();
    tmdmOffer.OfferDefinationName__c = 'MDM Tenancy';
    tmdmOffer.Name = 'Telstra Mobile Device Management - VMware';
    tmdmOffer.Offer_ID__c = 'DMCAT_Offer_000681';
    listOfOffers1.add(tmdmOffer);
    //EDGE-98336 - End
    insert listOfOffers1;
    csord__Order__c ord = new csord__Order__c();
    ord.csord__Identification__c = 'test identification';
    ord.Name = 'test order';
    ord.csord__Status2__c = 'Pending';
    insert ord;
    csord__Subscription__c subs = new csord__Subscription__c();
    subs.name = 'Connected Workplace';
    subs.csord__Identification__c = 'test identity';
    subs.csord__Status__c = 'Pending';
    subs.csord__Order__c = ord.id;
    insert subs;
    //EDGE-127817 Start
    csord__Subscription__c subngUC = new csord__Subscription__c();
    subngUC.name = 'IADs-OneAccess One100 (8 Port)';
    subngUC.csord__Identification__c = 'test identity';
    subngUC.csord__Status__c = 'Pending';
    subngUC.csord__Order__c = ord.id;
    //subngUC.Billing_Account__r.Billing_Account_Number__c = billAcc.Billing_Account_Number__c;
    subngUC.Billing_Account__c = billAcc.id;
    insert subngUC;
    csord__Service__c servngUC = new csord__Service__c();
    servngUC.name = 'IADs-OneAccess One100 (8 Port)';
    servngUC.Initial_Activation_Date__c = Date.valueOf('2018-12-30');
    servngUC.csord__Identification__c = 'test identity';
    servngUC.csord__Subscription__c = subngUC.id;
    insert servngUC;
    //EDGE-147419-Test PC
    List<cscfga__Product_Configuration__c> tccinfig = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c pconfig = new cscfga__Product_Configuration__c();
    pconfig.cscfga__Product_Definition__c = pd.id;
    pconfig.cscfga__Product_Basket__c = pbBasket.id;
    pconfig.cscfga__Description__c = 'test Description';
    pconfig.cscfga__Contract_Term__c = 36;
    pconfig.Commercial_Config__c = 'Yes';
    pconfig.Quantity_Product_Configuration__c = 1;
    pconfig.cscfga__total_one_off_charge__c = 100.23; //EDGE-162365 Defect Fix
    pconfig.cscfga__total_recurring_charge__c = 100;
    pconfig.name = 'Unified Communication';
    pconfig.Type__c = 'New';
    pconfig.Marketable_Offer__c = moTC.id;
    pconfig.cscfga__Product_Family__c = 'Unified Communication Enterprise';
    pconfig.cscfga__total_recurring_charge__c = 46.26;
    pconfig.Marketable_Offer__c = mo.id;
    tccinfig.add(pconfig);
    insert tccinfig;
    //EDGE-147419-End
    //EDGE-127817 End
    cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
    replacedConfig.name = 'Replaced Product Configuration record';
    replacedConfig.cscfga__Product_Definition__c = pd.id;
    replacedConfig.cscfga__Product_Basket__c = basket.id;
    replacedConfig.cscfga__Description__c = 'test Description';
    replacedConfig.cscfga__Contract_Term__c = 36;
    replacedConfig.Commercial_Config__c = 'Yes';
    replacedConfig.Quantity_Product_Configuration__c = 1;
    replacedConfig.cscfga__total_one_off_charge__c = 100;
    replacedConfig.cscfga__total_recurring_charge__c = 100;
    insert replacedConfig;
    system.debug('replacedConfig ' + replacedConfig.id);
    List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
    List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
    for (Integer i = 0; i <= 39; i++) {
      cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
      config.cscfga__Product_Definition__c = pd.id;
      config.cscfga__Product_Basket__c = basket.id;
      config.cscfga__Description__c = 'test Description ' + i;
      config.cscfga__Contract_Term__c = 36;
      config.Commercial_Config__c = 'Yes';
      config.Quantity_Product_Configuration__c = 1;
      config.cscfga__total_one_off_charge__c = 100.12; //EDGE-162365 Defect Fix
      config.cscfga__total_recurring_charge__c = 100;
      if (i == 0) {
        config.name = 'IP Site';
        config.Type__c = 'New';
        config.Marketable_Offer__c = mo.id;
        config.Offer_Reference__c = offernameCWP.id;
      }
      if (i == 1) {
        config.name = 'IP Site';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameCWP.id;
      }

      if (i == 2) {
        config.name = 'IP Site';
        config.Type__c = 'New';
        config.Marketable_Offer__c = ngemId.id;
        config.Offer_Reference__c = offernameCWP.id;
      }

      if (i == 3) {
        config.name = 'IP Site';
        config.Type__c = 'Cancel';
        config.Offer_Reference__c = offernameCWP.id;
        config.Marketable_Offer__c = mo.id;
        config.csordtelcoa__Replaced_Subscription__c = subs.id;
      }
      if (i == 4) {
        config.name = 'IP Site';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = mo.id;
        config.Offer_Reference__c = offernameCWP1.id;
        config.csordtelcoa__Replaced_Subscription__c = subs.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      if (i == 5) {
        config.name = 'V2T Samsung Galaxy S9+ 256GB Black first';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameMobility.id;
        config.cscfga__Product_Family__c = 'Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
      }
      if (i == 6) {
        config.name = 'Samsung Galaxy S9+ 256GB Black second';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameMobility.id;
        config.cscfga__Product_Family__c = 'Mobile Device';
        config.cscfga__unit_recurring_charge__c = 200;
      }
      if (i == 7) {
        config.name = 'Samsung Galaxy S9+ 256GB Black';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameMobility.id;
        config.cscfga__Product_Family__c = 'Mobile Device';
        config.cscfga__unit_recurring_charge__c = 200;
        config.csordtelcoa__Replaced_Subscription__c = subs.id;
      }
      if (i == 8) {
        config.name = 'FairPlay Data - Global';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Mobile Subscription';
        config.cscfga__unit_recurring_charge__c = 200;
        //config.csordtelcoa__Replaced_Subscription__c =subs.id ;
      }
      if (i == 9) {
        config.name = 'Samsung Galaxy S9+ 256GB Black';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Device';
        config.cscfga__unit_recurring_charge__c = 200;
        //config.csordtelcoa__Replaced_Subscription__c =subs.id ;
      }
      if (i == 10) {
        config.name = 'FairPlay Data - Global BYO';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = moMob.id;
        //config.Offer_Reference__c = offernameCWP1.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Mobile Subscription';
        config.cscfga__unit_recurring_charge__c = 200;
        config.csordtelcoa__Replaced_Subscription__c = subs.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      //EDGE - 98374 Start
      if (i == 11) {
        config.name = 'Auto Attendant';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moTC.id;
        config.Offer_Reference__c = offernameTC.id;
        config.cscfga__Product_Family__c = 'Auto Attendant';
        config.cscfga__unit_recurring_charge__c = 200;
      }
      //EDGE - 98374 End
      //EDGE - 80783 Start
      if (i == 12) {
        config.name = 'Professional Services-MDM Config';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moPS.id;
        config.cscfga__Product_Family__c = 'Professional Services-MDM Config';
      }
      //EDGE - 80783 End
      //EDGE - 109389 Start
      if (i == 13) {
        config.name = 'Camera-Polycom EagleEye Mini Camera for VVX Handset';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c = 'Accessory';
        config.cscfga__total_recurring_charge__c = 0;
      }
      if (i == 14) {
        config.name = 'IADs-OneAccess One100 (8 Port)';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c = 'Unified Communication Device';
        config.cscfga__total_recurring_charge__c = 46.26;
      }
      //EDGE - 109389 End
      //EDGE - 113930 Start
      if (i == 15) {
        config.name = 'Unified Communication';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c = 'Unified Communication Enterprise';
        config.cscfga__total_recurring_charge__c = 46.26;
      }
      if (i == 16) {
        config.name = 'Samsung Galaxy S9+ 256GB Black';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Device';
        config.cscfga__unit_recurring_charge__c = 200;
      }
      //EDGE - 113930 End
      //EDGE - 99894 - Start(Added by Aman Soni)
      if (i == 17) {
        config.name = 'Device Outright Purchase Solution';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moDOP.id;
        config.Offer_Reference__c = offernameDOP.id;
        config.cscfga__Product_Family__c = 'Device Outright Purchase Solution';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
      }
      //EDGE - 99894 - Start(Added by Aman Soni)
      //EDGE - 105921 & EDGE-148067 - Start
      if (i == 18) {
        config.name = 'Corporate Mobile Plus-Committed Data';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Product_Definition__c = pd4.id; //EDGE-140420 AND EDGE-143435--Added Changes
      }
      if (i == 19) {
        config.name = 'Corporate Mobile Plus-Committed Data';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1; //EDGE - 117740
        config.cscfga__Product_Definition__c = pd4.id; //EDGE-140420 AND AND EDGE-143435--Added Changes
      }
      //EDGE - 105921 & EDGE-148067 - End
      // EDGE - 117740
      //EDGE - 105921 Start
      if (i == 20) {
        config.name = 'Corporate Mobile Plus-Committed Data';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Product_Definition__c = pd2.id;
      }
      if (i == 21) {
        config.name = 'Committed Data - Data SIM $5';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Mobile Subscription';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd2.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
        //config.cscfga__Product_Basket__c = basket1.id;//EDGE-148534
      }
      if (i == 22) {
        config.name = 'Next Generation Voice';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Next Generation Voice';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd1.id;
      }
      //EDGE-127817 Start
      if (i == 23) {
        config.name = 'IADs-OneAccess One100 (8 Port)';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c = 'Unified Communication Device';
        config.cscfga__total_recurring_charge__c = 46.26;
        config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
      }
      if (i == 24) {
        config.name = 'Next Generation Voice';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c = 'Next Generation Voice';
        config.cscfga__total_recurring_charge__c = 46.26;
        config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
      }
      if (i == 25) {
        config.name = 'Camera-Polycom EagleEye Mini Camera for VVX Handset';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c = 'Unified Communication Device';
        config.cscfga__total_recurring_charge__c = 46.26;
        config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
      }
      //EDGE-127817 End
      //DPG 598
      if (i == 26) {
        config.name = 'FairPlay Data-Telstra IOT Data Plan 100KB';
        config.Type__c = 'New';
        config.name = 'IoT Connectivity';
        config.Marketable_Offer__c = ioTMob.id;
        config.Offer_Reference__c = offernameIOT.id;
        config.cscfga__Product_Family__c = 'IOT Subscription';
        config.cscfga__unit_recurring_charge__c = 2.53;
      }
      //EDGE-98336 - Start
      if (i == 27) {
        config.name = 'Internet Site - TestSite - New';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moTID.id;
        config.cscfga__Product_Family__c = 'Internet Site';
        config.cscfga__total_recurring_charge__c = 4000.00;
      }
      //EDGE-98336 - End
      //EDGE-127780 - Start
      if (i == 28) {
        config.name = 'Internet Site - TestSite - New';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moTID.id;
        config.cscfga__Product_Family__c = 'Internet Site';
        config.cscfga__total_recurring_charge__c = 4000.00;
        config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[27].id;
        config.cscfga__Product_Definition__c = pd3.id; //EDGE-148534
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      //EDGE-127780 - End
      //EDGE-137773 Start
      if (i == 29) {
        config.name = 'Corporate Mobile Plus-FairPlay Data';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
      }
      //EDGE-137773 End
      //EDGE-127778 - Start
      if (i == 30) {
        config.name = 'Internet Site - TestSite - New';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = moTID.id;
        config.cscfga__Product_Family__c = 'Internet Site';
        config.cscfga__total_recurring_charge__c = 4000.00;
        config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[27].id;
      }
      if (i == 31) {
        config.name = 'FairPlay Data-Telstra IOT Data Plan 100KB';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = ioTMob.id;
        config.cscfga__Product_Family__c = 'IOT Subscription';
        config.cscfga__total_recurring_charge__c = 2.82;
        system.debug('Replaced PC[14]--> ' + replacedConfig.id);
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      if (i == 32) {
        config.name = 'FairPlay Data-Telstra IOT Data Plan 100KB';
        config.Type__c = 'New';
        config.Marketable_Offer__c = ioTMob.id;
        config.cscfga__Product_Family__c = 'IOT Subscription';
        config.cscfga__total_recurring_charge__c = 2.82;
        system.debug('Replaced PC[14]--> ' + replacedConfig.id);
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      //EDGE-127778 - End
      //EDGE-144228 Start
      if (i == 33) {
        config.name = 'Corporate Mobile Plus-FairPlay Data - Test';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Product_Basket__c = basket1.id;
      }
      //EDGE-144228 End
      //EDGE-144779 Start
      if (i == 34) {
        config.name = 'Corporate Mobile Plus-Committed Data Test';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Product_Basket__c = basket1.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      if (i == 35) {
        config.name = 'Corporate Mobile Plus-Committed Data Test';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Product_Basket__c = basket.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      //EDGE-144779 End
      //EDGE-132608 Start
      if (i == 36) {
        config.name = 'Business Calling';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Business Calling';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd1.id;
      }
      //EDGE-132608 End
      //EDGE-142319 Start
      if (i == 37) {
        config.name = 'Business Calling';
        config.Type__c = 'Modify';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Business Calling';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd1.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      //EDGE-142319 End
      //EDGE-144732 START
      if (i == 38) {
        config.name = 'Business Calling';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Business Calling';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd1.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
      }
      //EDGE-144732 END
      //EDGE-148534 Start
      if (i == 39) {
        config.name = 'Committed Data - Data SIM $5-Test';
        config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moCMPCD.id;
        config.Offer_Reference__c = offernameCMP.id;
        config.cscfga__Product_Family__c = 'Mobile Subscription';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c = 1;
        config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd2.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
        config.cscfga__Product_Basket__c = basket1.id; //EDGE-148534
      }
      //EDGE-148534 End
      prodConfigList.add(config);
    }
    //EDGE-140420 AND EDGE-143435--Start Changes
    cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
    newConfig.name = 'test';
    newConfig.Type__c = 'Cancel';
    newConfig.cscfga__Product_Basket__c = basket.id;
    //config.Marketable_Offer__c = moCMPCD.id;
    //config.Offer_Reference__c =offernameCMP.id;
    newConfig.cscfga__Product_Family__c = 'Enterprise Mobility';
    newConfig.cscfga__unit_recurring_charge__c = 200;
    newConfig.Quantity_Product_Configuration__c = 1;
    newConfig.cscfga__Product_Definition__c = pd4.id;
    prodConfigList.add(newConfig);
    //EDGE-140420 AND EDGE-143435--End Changes
    insert prodConfigList;
    system.debug('Size of prodConfigList--> ' + prodConfigList.size());
    system.debug('prodConfigList[23]@@123::' + prodConfigList[14].name);
    system.debug('prodConfigList[23]@@id::' + prodConfigList[14].id);
    system.debug('prodConfigList[23]@@Family::' + prodConfigList[23].cscfga__Product_Family__c);
    system.debug('prodConfigList[23]@@Replace::' + prodConfigList[23].csordtelcoa__Replaced_Product_Configuration__c);
    system.debug('DeviceProductconfigurationName' + prodConfigList[5].name);
    prodConfigList[5].cscfga__Parent_Configuration__c = prodConfigList[8].id; //EDGE-154662 Fix
    prodConfigList[1].cscfga__Parent_Configuration__c = prodConfigList[0].id;
    prodConfigList[6].cscfga__Parent_Configuration__c = prodConfigList[5].id;
    prodConfigList[9].cscfga__Parent_Configuration__c = prodConfigList[8].id;
    //prodConfigList[10].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[9].id;
    //prodConfigList[4].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[0].id;
    //EDGE-127780
    //prodConfigList[28].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[27].id;
    //upsert prodConfigList[28];
    //EDGE-127780
    //prodConfigList[21].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[20].id;//EDGE-140420
    //upsert prodConfigList[21];
    //EDGE-148534 Start
    //prodConfigList[39].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[20].id;
    //upsert prodConfigList[39];
    //EDGE-148534 End
    //EDGE-127778
    //prodConfigList[30].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[27].id;
    //upsert prodConfigList[30];
    //EDGE-127778
    List<cscfga__Product_Configuration__c> pcUpsertlist = new List<cscfga__Product_Configuration__c>();
    pcUpsertlist.add(prodConfigList[1]);
    //upsert prodConfigList[1];
    //upsert prodConfigList[10];
    //upsert prodConfigList[4];
    //EDGE-127817 Start
    prodConfigList[23].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
    prodConfigList[23].csordtelcoa__Replaced_Service__c = servngUC.id;
    prodConfigList[23].csordtelcoa__Replaced_Subscription__c = subngUC.id;
    pcUpsertlist.add(prodConfigList[23]);
    pcUpsertlist.add(prodConfigList[5]); //EDGE-154662 Fix
    //upsert prodConfigList[23];
    //upsert prodConfigList[5];
    upsert pcUpsertlist;
    system.debug('prodConfigList[5]' + prodConfigList[5].cscfga__Parent_Configuration__c);
    //prodConfigList[24].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
    //upsert prodConfigList[24];
    //prodConfigList[25].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
    //upsert prodConfigList[25];
    //EDGE-127817 End
    cscfga__Product_Category__c prodCat = new cscfga__Product_Category__c();
    prodCat.Name = 'Modular Products';
    insert prodCat;
    Attachment attm = new Attachment();
    attm.Name = 'TransitionJSONData.json';
    attm.ParentId = prodConfigList[8].Id;
    attm.Body = Blob.valueOf(serviceDTO_V2);
    insert attm;
    //EDGE - 117740 Start
    Attachment atta = new Attachment();
    atta.Name = 'TransitionJSONData.json';
    atta.ParentId = prodConfigList[2].Id;
    atta.Body = Blob.valueOf(serviceDTO_V2);
    insert atta;
    Attachment att = new Attachment();
    att.Name = 'TransitionJSONData.json';
    att.ParentId = prodConfigList[1].Id;
    att.Body = Blob.valueOf(serviceDTO_V2);
    insert att;
    Attachment attch2 = new Attachment();
    attch2.Name = 'TransitionJSONData.json';
    attch2.ParentId = prodConfigList[20].Id;
    attch2.Body = Blob.valueOf(serviceDTO_V2);
    insert attch2;
    Attachment attch3 = new Attachment();
    attch3.Name = 'TransitionJSONData.json';
    attch3.ParentId = prodConfigList[21].Id;
    attch3.Body = Blob.valueOf(serviceDTO_V2);
    insert attch3;
    //EDGE - 117740 End
    // EDGE-117738
    Attachment attach1 = new Attachment();
    attach1.Name = 'TransitionJSONData.json';
    attach1.ParentId = prodConfigList[22].Id;
    attach1.Body = Blob.valueOf(serviceDTO_V2);
    insert attach1;
    // EDGE-117738 end
    List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
    List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
    cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AD1',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Device'
    );
    attDefList.add(ad);
    cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AD1',
      Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
      Snapshot_Attribute_Fields__c = 'MessageBank'
    );
    attDefList.add(ad1);
    cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AD1',
      Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
      Snapshot_Attribute_Fields__c = 'Plan'
    );
    attDefList.add(ad2);
    cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AD1',
      Snapshot_Attribute_Value_Field__c = 'Rate__c',
      Snapshot_Attribute_Fields__c = 'Device'
    );
    attDefList.add(ad3);
    cscfga__Attribute_Definition__c ad4 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AD1',
      Snapshot_Attribute_Value_Field__c = 'Quantity__c',
      Snapshot_Attribute_Fields__c = 'Device,Plan,MessageBank'
    );
    attDefList.add(ad4);
    cscfga__Attribute_Definition__c ad5 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AD1',
      Snapshot_Attribute_Value_Field__c = 'GSTIncl_Total_Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Device'
    );
    attDefList.add(ad5);
    cscfga__Attribute_Definition__c ad6 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Select Plan',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c,Unit_Of_Measure__c',
      Snapshot_Attribute_Fields__c = 'cspmb__Recurring_Charge__c,Unit_Of_Measure__c'
    );
    attDefList.add(ad6);
    cscfga__Attribute_Definition__c ad7 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'PaymentTypeLookup',
      Snapshot_Attribute_Value_Field__c = 'Term__c,Recurring_Charges__c,Unit_Of_Measure__c',
      Snapshot_Attribute_Fields__c = 'cspmb__Contract_Term__c,cspmb__Recurring_Charge__c,Unit_Of_Measure__c'
    );
    attDefList.add(ad7);
    cscfga__Attribute_Definition__c ad8 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalPlanBonus',
      Snapshot_Attribute_Value_Field__c = 'PlanDiscount__c',
      Snapshot_Attribute_Fields__c = 'Plan'
    );
    attDefList.add(ad8);
    //EDGE - 98374 Start
    cscfga__Attribute_Definition__c ad9 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'UnitPrice',
      Snapshot_Attribute_Value_Field__c = 'Rate__c',
      Snapshot_Attribute_Fields__c = 'Rate__c'
    );
    attDefList.add(ad9);
    cscfga__Attribute_Definition__c ad10 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Quantity',
      Snapshot_Attribute_Value_Field__c = 'Quantity__c',
      Snapshot_Attribute_Fields__c = 'Quantity__c'
    );
    attDefList.add(ad10);
    cscfga__Attribute_Definition__c ad11 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringPrice',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'GSTExcl_Total_Recurring_Charges__c'
    );
    attDefList.add(ad11);
    cscfga__Attribute_Definition__c ad12 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Price_id',
      Snapshot_Attribute_Value_Field__c = 'Unit_Of_Measure__c',
      Snapshot_Attribute_Fields__c = 'Unit_Of_Measure__c'
    );
    attDefList.add(ad12);
    //EDGE - 98374 End
    //EDGE - 109389 Start
    cscfga__Attribute_Definition__c ad13 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'ContractType',
      Snapshot_Attribute_Value_Field__c = 'Unit_Of_Measure__c',
      Snapshot_Attribute_Fields__c = 'Unit_Of_Measure__c'
    );
    attDefList.add(ad13);
    cscfga__Attribute_Definition__c ad14 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Quantity',
      Snapshot_Attribute_Value_Field__c = 'Quantity__c',
      Snapshot_Attribute_Fields__c = 'Quantity__c'
    );
    attDefList.add(ad14);
    cscfga__Attribute_Definition__c ad15 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalOneOffPrice',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Onceoff_Charges__c',
      Snapshot_Attribute_Fields__c = 'GSTExcl_Total_Onceoff_Charges__c'
    );
    attDefList.add(ad15);
    cscfga__Attribute_Definition__c ad16 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'UnitPrice',
      Snapshot_Attribute_Value_Field__c = 'Rate__c',
      Snapshot_Attribute_Fields__c = 'Rate__c'
    );
    attDefList.add(ad16);
    cscfga__Attribute_Definition__c ad17 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'ContractType',
      Snapshot_Attribute_Value_Field__c = 'Unit_Of_Measure__c',
      Snapshot_Attribute_Fields__c = 'Unit_Of_Measure__c'
    );
    attDefList.add(ad17);
    cscfga__Attribute_Definition__c ad18 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Quantity',
      Snapshot_Attribute_Value_Field__c = 'Quantity__c',
      Snapshot_Attribute_Fields__c = 'Quantity__c'
    );
    attDefList.add(ad18);
    cscfga__Attribute_Definition__c ad19 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringPrice',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'GSTExcl_Total_Recurring_Charges__c'
    );
    attDefList.add(ad19);
    cscfga__Attribute_Definition__c ad20 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'UnitPrice',
      Snapshot_Attribute_Value_Field__c = 'Rate__c',
      Snapshot_Attribute_Fields__c = 'Rate__c'
    );
    attDefList.add(ad20);
    //EDGE - 109389 End
    //EDGE - 113930 Start
    cscfga__Attribute_Definition__c ad21 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'ResponseTime',
      Snapshot_Attribute_Value_Field__c = 'Response_time__c',
      Snapshot_Attribute_Fields__c = 'Response_time__c'
    );
    attDefList.add(ad21);
    cscfga__Attribute_Definition__c ad22 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'RestorationTime',
      Snapshot_Attribute_Value_Field__c = 'Restoration_time__c',
      Snapshot_Attribute_Fields__c = 'Restoration_time__c'
    );
    attDefList.add(ad22);
    //EDGE - 113930 End
    //EDGE - 99894 - Start(Added by Aman Soni)
    cscfga__Attribute_Definition__c ad23 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'OneOffCharge',
      Snapshot_Attribute_Value_Field__c = 'Once_Off__c',
      Snapshot_Attribute_Fields__c = 'cspmb__One_Off_Charge__c'
    );
    attDefList.add(ad23);
    //EDGE - 99894 - End(Added by Aman Soni)
    //EDGE - 105921 & EDGE-148067 - Start
    cscfga__Attribute_Definition__c ad24 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'BonusDataAllowance',
      Snapshot_Attribute_Value_Field__c = 'Bonus_Data__c',
      Snapshot_Attribute_Fields__c = 'Bonus_Data__c'
    );
    attDefList.add(ad24);
    cscfga__Attribute_Definition__c ad25 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Data Pack Allowance',
      Snapshot_Attribute_Value_Field__c = 'Plan_Data__c',
      Snapshot_Attribute_Fields__c = 'Plan_Data__c'
    );
    attDefList.add(ad25);
    cscfga__Attribute_Definition__c ad26 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Data Pack RC',
      Snapshot_Attribute_Value_Field__c = 'Plan_Rate__c',
      Snapshot_Attribute_Fields__c = 'Plan_Rate__c'
    );
    attDefList.add(ad26);
    cscfga__Attribute_Definition__c ad27 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id, Name = 'FeatureLevelShadow');
    attDefList.add(ad27);
    cscfga__Attribute_Definition__c ad28 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id, Name = 'TechnicalSupportShadow');
    attDefList.add(ad28);
    cscfga__Attribute_Definition__c ad29 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id, Name = 'TenancyID');
    attDefList.add(ad29);
    //EDGE - 105921 & EDGE-148067 - End
    //EDGE - 117740
    cscfga__Attribute_Definition__c ad30 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'DataPackPlan',
      Snapshot_Attribute_Value_Field__c = 'Unit_Of_Measure__c',
      Snapshot_Attribute_Fields__c = 'Unit_Of_Measure__c'
    );
    attDefList.add(ad30);
    //EDGE - 117740
    // EDGE - 117738
    cscfga__Attribute_Definition__c ad31 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'UCUserQuantity',
      Snapshot_Attribute_Value_Field__c = 'Offer_Name__c',
      Snapshot_Attribute_Fields__c = 'Offer_Name__c'
    );
    attDefList.add(ad31);
    cscfga__Attribute_Definition__c ad32 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'RecurringChargePerNumber',
      Snapshot_Attribute_Value_Field__c = 'Offer_Name__c',
      Snapshot_Attribute_Fields__c = 'Offer_Name__c'
    );
    attDefList.add(ad32);
    cscfga__Attribute_Definition__c ad33 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Recurring Charge',
      Snapshot_Attribute_Value_Field__c = 'Rate__c',
      Snapshot_Attribute_Fields__c = 'Rate__c'
    );
    attDefList.add(ad33);
    cscfga__Attribute_Definition__c ad34 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'RCUser',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad34);
    cscfga__Attribute_Definition__c ad35 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'RCHuntGroup',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad35);
    cscfga__Attribute_Definition__c ad36 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'RCHostedUC',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad36);
    cscfga__Attribute_Definition__c ad37 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'RCAutoAttendant',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad37);
    cscfga__Attribute_Definition__c ad38 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'NumberofPhoneNumbers',
      Snapshot_Attribute_Value_Field__c = 'Quantity__c',
      Snapshot_Attribute_Fields__c = 'Quantity__c'
    );
    attDefList.add(ad38);
    cscfga__Attribute_Definition__c ad39 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'Number',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad39);
    cscfga__Attribute_Definition__c ad40 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'HuntGroupQuantity',
      Snapshot_Attribute_Value_Field__c = 'Offer_Name__c',
      Snapshot_Attribute_Fields__c = 'Offer_Name__c'
    );
    attDefList.add(ad40);
    cscfga__Attribute_Definition__c ad41 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'HostedUCQuantity',
      Snapshot_Attribute_Value_Field__c = 'Offer_Name__c',
      Snapshot_Attribute_Fields__c = 'Offer_Name__c'
    );
    attDefList.add(ad41);
    cscfga__Attribute_Definition__c ad42 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'AutoAttendantQuantity',
      Snapshot_Attribute_Value_Field__c = 'Offer_Name__c',
      Snapshot_Attribute_Fields__c = 'Offer_Name__c'
    );
    attDefList.add(ad42);
    cscfga__Attribute_Definition__c ad43 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'callingPlans',
      Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
      Snapshot_Attribute_Fields__c = 'Product_Module_Name__c'
    );
    attDefList.add(ad43);
    //EDGE-127817 Start
    cscfga__Attribute_Definition__c ad44 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'DisconnectionDate',
      Snapshot_Attribute_Value_Field__c = 'Query_Type__c',
      Snapshot_Attribute_Fields__c = 'Query_Type__c'
    );
    attDefList.add(ad44);
    cscfga__Attribute_Definition__c ad45 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'EarlyTerminationCharge',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_TotalETC__c',
      Snapshot_Attribute_Fields__c = 'GSTExcl_TotalETC__c'
    );
    attDefList.add(ad45);
    cscfga__Attribute_Definition__c ad46 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'concurrencyLimit',
      Snapshot_Attribute_Value_Field__c = 'Quantity__c',
      Snapshot_Attribute_Fields__c = 'Quantity__c'
    );
    attDefList.add(ad46);
    //EDGE-127817 End
    //DPG -598
    cscfga__Attribute_Definition__c ad47 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'OneOffCharge',
      Snapshot_Attribute_Value_Field__c = 'Once_Off__c',
      Snapshot_Attribute_Fields__c = 'cspmb__One_Off_Charge__c'
    );
    attDefList.add(ad47);
    //EDGE-98336 - Start
    cscfga__Attribute_Definition__c ad53 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id, Name = 'RecurringPrice');
    attDefList.add(ad53);
    //EDGE-98336 - END
    //EDGE-132903 - we are just changing attribute data source, there is no change in input & output values in flow
    cscfga__Attribute_Definition__c ad48 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringChargeforNumber',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad48);
    cscfga__Attribute_Definition__c ad49 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringChargeforUser',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad49);
    cscfga__Attribute_Definition__c ad50 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringChargeforHostedUC',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad50);
    cscfga__Attribute_Definition__c ad51 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringChargeforAutoAttendant',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad51);
    cscfga__Attribute_Definition__c ad52 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'TotalRecurringChargeforHuntGroup',
      Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
      Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
    );
    attDefList.add(ad52);
    //EDGE-132903 - End
    //EDGE-127780 Start
    cscfga__Attribute_Definition__c ad54 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd3.Id, //EDGE-148534
      Name = 'Contract Term',
      Snapshot_Attribute_Value_Field__c = 'Term__c',
      Snapshot_Attribute_Fields__c = 'Term__c'
    );
    attDefList.add(ad54);
    cscfga__Attribute_Definition__c ad55 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd3.Id, //EDGE-148534
      Name = 'DisconnectionDate',
      Snapshot_Attribute_Value_Field__c = 'PAYG_GT_5__c',
      Snapshot_Attribute_Fields__c = 'PAYG_GT_5__c'
    );
    attDefList.add(ad55);
    cscfga__Attribute_Definition__c ad56 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd3.Id, //EDGE-148534
      Name = 'EarlyTerminationCharge',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_TotalETC__c',
      Snapshot_Attribute_Fields__c = 'GSTExcl_TotalETC__c'
    );
    attDefList.add(ad56);
    //EDGE-127780 End
    //EDGE-144228 Start
    //EDGE-121387, EDGE-133760
    cscfga__Attribute_Definition__c ad57 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'OfferTypeString',
      Snapshot_Attribute_Value_Field__c = 'Order_Type__c',
      Snapshot_Attribute_Fields__c = 'Order_Type__c'
    );
    attDefList.add(ad57);
    //EDGE-121387, EDGE-133760
    //EDGE-144228 End
    //EDGE-144779 Start
    cscfga__Attribute_Definition__c ad58 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'OfferTypeString',
      Snapshot_Attribute_Value_Field__c = 'Order_Type__c',
      Snapshot_Attribute_Fields__c = 'Order_Type__c'
    );
    attDefList.add(ad58);
    cscfga__Attribute_Definition__c ad59 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'OfferTypeString',
      Snapshot_Attribute_Value_Field__c = 'Order_Type__c',
      Snapshot_Attribute_Fields__c = 'Order_Type__c'
    );
    attDefList.add(ad59);
    //EDGE-144779 End
    //EDGE-132608 Start
    cscfga__Attribute_Definition__c ad60 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd.Id,
      Name = 'callingPlans',
      Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
      Snapshot_Attribute_Fields__c = 'Product_Module_Name__c'
    );
    attDefList.add(ad60);
    //EDGE-132608 End
    //EDGE-148534 Start
    cscfga__Attribute_Definition__c ad61 = new cscfga__Attribute_Definition__c(
      cscfga__Product_Definition__c = pd2.Id,
      Name = 'EarlyTerminationCharge',
      Snapshot_Attribute_Value_Field__c = 'GSTExcl_TotalETC__c',
      Snapshot_Attribute_Fields__c = 'GSTExcl_TotalETC__c'
    );
    attDefList.add(ad61);
    //EDGE-148534 End
    insert attDefList;
    system.debug('attDefList@@::' + attDefList[61]);
    cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
    testPriceItem.Name = 'Mobile Device';
    testPriceItem.Manufacturer__c = 'TestMan';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.cspmb__Recurring_Charge__c = 75;
    testPriceItem.cspmb__One_Off_Charge__c = 750;
    testPriceItem.ProdSpecId__c = 'TestOffer';
    testPriceItem.Feature_Level__c = 'Advanced';
    testPriceItem.Technical_Support__c = '24X7';
    testPriceItem.rangeFrom__c = '1';
    testPriceItem.rangeTo__c = '500';
    //EDGE-121387, EDGE-133760
    testPriceItem.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    testPriceItem.Billing_Description__c = 'Test';
    testPriceItem.taxTreatment__c = 'GST Applicable';
    testPriceItem.Unit_Of_Measure__c = 'per device';
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c>{ testPriceItem };
    insert PIList;
    //EDGE-132608 Start
    cspmb__Price_Item__c testPriceItemBusCal = new cspmb__Price_Item__c();
    testPriceItemBusCal.Name = 'Business Calling';
    testPriceItemBusCal.ChargeType__c = 'RC';
    testPriceItemBusCal.cspmb__Recurring_Charge__c = 75;
    testPriceItemBusCal.cspmb__One_Off_Charge__c = 750;
    testPriceItemBusCal.ProdSpecId__c = 'DMCAT_ProductSpecification_000871';
    testPriceItemBusCal.rangeFrom__c = '501';
    testPriceItemBusCal.rangeTo__c = '99999';
    testPriceItemBusCal.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    testPriceItemBusCal.Billing_Description__c = 'Standard calling plan - shared line';
    testPriceItemBusCal.taxTreatment__c = 'GST Applicable';
    testPriceItemBusCal.Mode__c = 'Shared Line';
    testPriceItemBusCal.Plan__c = 'Standard';
    List<cspmb__Price_Item__c> PIListBusCal = new List<cspmb__Price_Item__c>{ testPriceItemBusCal };
    insert PIListBusCal;
    //EDGE-132608 End
    //EDGE - 105921 & EDGE-148067- Start
    List<cspmb__Usage_Type__c> UsageList = new List<cspmb__Usage_Type__c>();
    cspmb__Usage_Type__c testUsage = new cspmb__Usage_Type__c();
    testUsage.cspmb__type__c = 'Group';
    testUsage.cspmb__unit_of_measure__c = 'Minute';
    testUsage.Name = 'Data Pack Usage';
    UsageList.add(testUsage);
    insert UsageList;
    cspmb__Allowance__c testAllowance = new cspmb__Allowance__c();
    testAllowance.Name = 'Committed Bonus Data Allowance 40 GB';
    testAllowance.billingSpecId__c = 'BSUSG004_CB';
    testAllowance.specId__c = 'DMCAT_Allowance_000877';
    testAllowance.ocsProdId__c = 'T22EM_CD-B06';
    testAllowance.Value__c = '40';
    testAllowance.type__c = 'Committed Bonus Data';
    testAllowance.Unit_Of_Measure__c = 'GB';
    testAllowance.plan__c = '20GB';
    testAllowance.cspmb__usage_type__c = UsageList[0].id;
    cspmb__Allowance__c testAllowance1 = new cspmb__Allowance__c();
    testAllowance1.Name = 'Committed Data Plan Allowance 20 GB';
    testAllowance1.billingSpecId__c = 'BSUSG001_CB';
    testAllowance1.specId__c = 'DMCAT_Allowance_000805';
    testAllowance1.ocsProdId__c = 'Dummy OCS ID';
    testAllowance1.Value__c = '20';
    testAllowance1.type__c = 'Committed Data';
    testAllowance1.Unit_Of_Measure__c = 'GB';
    testAllowance1.cspmb__usage_type__c = UsageList[0].id;
    List<cspmb__Allowance__c> AllowanceList = new List<cspmb__Allowance__c>{ testAllowance, testAllowance1 };
    insert AllowanceList;
    //EDGE - 105921 & EDGE-148067 - End
    //EDGE - 117740
    cspmb__Price_Item__c testPriceItemCD = new cspmb__Price_Item__c();
    testPriceItemCD.Name = 'Committed Data Plan';
    testPriceItemCD.Manufacturer__c = 'TestMan';
    testPriceItemCD.Model__c = 'TestMod';
    testPriceItemCD.Colour__c = 'TestCol';
    testPriceItemCD.cspmb__Contract_Term__c = '12';
    testPriceItemCD.ChargeType__c = 'RC';
    testPriceItemCD.cspmb__Recurring_Charge__c = 75;
    testPriceItemCD.cspmb__One_Off_Charge__c = 750;
    testPriceItemCD.ProdSpecId__c = 'TestOffer';
    testPriceItemCD.Feature_Level__c = 'Advanced';
    testPriceItemCD.Technical_Support__c = '24X7';
    testPriceItemCD.rangeFrom__c = '1';
    testPriceItemCD.rangeTo__c = '500';
    //EDGE-121387, EDGE-133760
    testPriceItemCD.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    testPriceItemCD.Billing_Description__c = 'Test';
    testPriceItemCD.taxTreatment__c = 'GST Applicable';
    testPriceItemCD.Unit_Of_Measure__c = 'per month per service';
    List<cspmb__Price_Item__c> PIListCD = new List<cspmb__Price_Item__c>{ testPriceItemCD };
    insert PIListCD;
    //EDGE - 117740
    //EDGE - 98374 Start
    cspmb__Price_Item__c testPriceItemTC = new cspmb__Price_Item__c();
    testPriceItemTC.Name = 'Auto Attendants';
    //testPriceItem.Manufacturer__c = 'TestMan';
    //testPriceItem.Model__c = 'TestMod';
    //testPriceItem.Colour__c = 'TestCol';
    testPriceItemTC.cspmb__Contract_Term__c = '12';
    testPriceItemTC.Contract_Type__c = 'Rental';
    //testPriceItem.ChargeType__c = 'RC';
    //testPriceItem.cspmb__Recurring_Charge__c = 75;
    //EDGE-121387, EDGE-133760
    testPriceItemCD.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    testPriceItemTC.Unit_Of_Measure__c = 'per Auto Attendant';
    testPriceItemTC.Billing_Description__c = 'Virtual Receptionist';
    List<cspmb__Price_Item__c> PIListTC = new List<cspmb__Price_Item__c>{ testPriceItemTC };
    insert PIListTC;
    //EDGE - 98374 End
    // DPG-598
    cspmb__Price_Item__c testPriceItemIOT = new cspmb__Price_Item__c();
    testPriceItemIOT.Name = 'Telstra IOT Data Plan 100KB';
    //testPriceItem.Manufacturer__c = 'TestMan';
    //testPriceItem.Model__c = 'TestMod';
    //testPriceItem.Colour__c = 'TestCol';
    testPriceItemIOT.cspmb__Contract_Term__c = '1';
    //testPriceItem.ChargeType__c = 'RC';
    //testPriceItem.cspmb__Recurring_Charge__c = 75;
    testPriceItemIOT.Unit_Of_Measure__c = '';
    testPriceItemIOT.Billing_Description__c = 'Telstra IOT Data Plan 100KB Charge';
    List<cspmb__Price_Item__c> PIListIOT = new List<cspmb__Price_Item__c>{ testPriceItemIOT };
    insert PIListIOT;
    //EDGE-127817 Start
    cspmb__Price_Item__c testPriceItemngUC = new cspmb__Price_Item__c();
    testPriceItemngUC.Name = 'IADs-OneAccess One100 (8 Port)';
    testPriceItemngUC.cspmb__Contract_Term__c = '';
    testPriceItemngUC.Contract_Type__c = 'Hardware Repayment';
    //EDGE-121387, EDGE-133760
    testPriceItemCD.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    List<cspmb__Price_Item__c> PIListngUC = new List<cspmb__Price_Item__c>{ testPriceItemngUC };
    insert PIListngUC;
    //EDGE-127817 End
    //EDGE-121387, EDGE-133760
    cspmb__Add_On_Price_Item__c testPriceItemAddon = new cspmb__Add_On_Price_Item__c(
      Name = 'Basic',
      ProdSpecId__c = '1213',
      Billing_Description__c = 'abc',
      cspmb__Recurring_Charge__c = 10
    );
    insert testPriceItemAddon;
    //EDGE-121387, EDGE-133760
    cspmb__Price_Item_Add_On_Price_Item_Association__c testPriceItemAddonAssoc = new cspmb__Price_Item_Add_On_Price_Item_Association__c(
      cspmb__Recurring_Charge__c = 10,
      cspmb__Add_On_Price_Item__c = testPriceItemAddon.Id
    );
    insert testPriceItemAddonAssoc;
    cscfga__Attribute__c att1 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[6].Id,
      Name = 'GSTIncl_Total_Onceoff_Charges__c',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[0].Id
    );
    attList.add(att1);
    cscfga__Attribute__c att2 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[5].Id,
      Name = 'GSTIncl_Total_Onceoff_Charges__c',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[1].Id
    );
    attList.add(att2);
    cscfga__Attribute__c att3 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[5].Id,
      Name = 'GSTIncl_Total_Onceoff_Charges__c',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[2].Id
    );
    attList.add(att3);
    cscfga__Attribute__c att4 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[6].Id,
      Name = 'GSTIncl_Total_Onceoff_Charges__c',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[3].Id
    );
    attList.add(att4);
    cscfga__Attribute__c att5 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[6].Id,
      Name = 'GSTIncl_Total_Onceoff_Charges__c',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[4].Id
    );
    attList.add(att5);
    /******************/
    cscfga__Attribute__c a5 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[12].Id,
      Name = 'Quantity',
      cscfga__Value__c = '100',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[8].Id
    );
    attList.add(a5);
    /*********/
    cscfga__Attribute__c att6 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[6].Id,
      Name = 'GSTIncl_Total_Onceoff_Charges__c',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[5].Id
    );
    attList.add(att6);
    cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('CaseStatus', '100.00', prodConfigList[3].id);
    attList.add(attr0);
    cscfga__Attribute__c att7 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[8].Id,
      Name = 'Select Plan',
      cscfga__Value__c = PIList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[5].Id
    );
    attList.add(att7);
    cscfga__Attribute__c att9 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[8].Id,
      Name = 'AddOn',
      cscfga__Value__c = testPriceItemAddon.id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[5].Id
    );
    attList.add(att9);
    cscfga__Attribute__c att10 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[8].Id,
      Name = 'AddOn',
      cscfga__Value__c = testPriceItemAddonAssoc.id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[5].Id
    );
    attList.add(att10);
    cscfga__Attribute__c att11 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[8].Id,
      Name = 'TotalPlanBonus',
      cscfga__Value__c = '22',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[8].Id
    );
    attList.add(att11);
    cscfga__Attribute__c att8 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[9].Id,
      Name = 'PaymentTypeLookup',
      cscfga__Value__c = PIList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[6].Id
    );
    attList.add(att8);
    cscfga__Attribute__c att12 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[10].Id,
      Name = 'Select Plan',
      cscfga__Value__c = PIList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[5].Id
    );
    attList.add(att12);
    //EDGE - 98734 - Start
    cscfga__Attribute__c att13 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[11].Id,
      Name = 'UnitPrice',
      cscfga__Value__c = '9',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[9].Id
    );
    attList.add(att13);
    cscfga__Attribute__c att14 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[11].Id,
      Name = 'Quantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[10].Id
    );
    attList.add(att14);
    cscfga__Attribute__c att15 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[11].Id,
      Name = 'TotalRecurringPrice',
      cscfga__Value__c = '9',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[11].Id
    );
    attList.add(att15);
    cscfga__Attribute__c att16 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[11].Id,
      Name = 'Price_id',
      cscfga__Value__c = PIListTC[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[12].Id
    );
    attList.add(att16);
    //EDGE - 98374 - End
    //EDEG-80783 :Start
    cscfga__Attribute__c att17 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[12].Id,
      Name = 'Quantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[9].Id
    );
    attList.add(att17);
    cscfga__Attribute__c att18 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[12].Id,
      Name = 'UnitPrice',
      cscfga__Value__c = '250',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[8].Id
    );
    attList.add(att18);
    //EDGE - 109389 Start
    cscfga__Attribute__c att19 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[13].Id,
      Name = 'ContractType',
      cscfga__Value__c = PIListTC[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[13].Id
    );
    attList.add(att19);
    cscfga__Attribute__c att20 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[13].Id,
      Name = 'Quantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[14].Id
    );
    attList.add(att20);
    cscfga__Attribute__c att21 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[13].Id,
      Name = 'TotalOneOffPrice',
      cscfga__Value__c = '100',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[15].Id
    );
    attList.add(att21);
    cscfga__Attribute__c att22 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[13].Id,
      Name = 'UnitPrice',
      cscfga__Value__c = '100',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[16].Id
    );
    attList.add(att22);
    cscfga__Attribute__c att23 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'ContractType',
      cscfga__Value__c = PIListTC[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[17].Id
    );
    attList.add(att23);
    cscfga__Attribute__c att24 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'Quantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[18].Id
    );
    attList.add(att24);
    cscfga__Attribute__c att25 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'TotalRecurringPrice',
      cscfga__Value__c = '100',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[19].Id
    );
    attList.add(att25);
    cscfga__Attribute__c att26 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'UnitPrice',
      cscfga__Value__c = '100',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[20].Id
    );
    attList.add(att26);
    //EDGE - 109389 End
    //EDGE - 113930 Start
    cscfga__Attribute__c att27 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[15].Id,
      Name = 'ResponseTime',
      cscfga__Value__c = '2',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[21].Id
    );
    attList.add(att27);
    cscfga__Attribute__c att28 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[15].Id,
      Name = 'RestorationTime',
      cscfga__Value__c = '4',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[22].Id
    );
    attList.add(att28);
    //EDGE - 113930 End
    //EDGE - 99894 - Start(Added by Aman Soni)
    cscfga__Attribute__c att29 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[17].Id,
      Name = 'OneOffCharge',
      cscfga__Value__c = PIList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[23].Id
    );
    attList.add(att29);
    //EDGE - 99894 - End(Added by Aman Soni)
    //EDGE - 105921 & EDGE-148067 - Start
    cscfga__Attribute__c att30 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'BonusDataAllowance',
      cscfga__Value__c = AllowanceList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[24].Id
    );
    attList.add(att30);
    cscfga__Attribute__c att31 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'Data Pack Allowance',
      cscfga__Value__c = AllowanceList[1].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[25].Id
    );
    attList.add(att31);
    cscfga__Attribute__c att32 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'Data Pack RC',
      cscfga__Value__c = '50.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[26].Id
    );
    attList.add(att32);
    cscfga__Attribute__c att34 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'FeatureLevelShadow',
      cscfga__Value__c = 'Advanced',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[27].Id
    );
    attList.add(att34);
    cscfga__Attribute__c att35 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'TechnicalSupportShadow',
      cscfga__Value__c = '24X7',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[28].Id
    );
    attList.add(att35);
    cscfga__Attribute__c att36 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'TenancyID',
      cscfga__Value__c = 'Test123',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[29].Id
    );
    attList.add(att36);
    //EDGE - 105921 & EDGE-148067 - End
    //EDGE - 117740
    cscfga__Attribute__c att37 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'DataPackPlan',
      cscfga__Value__c = PIListCD[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[30].Id
    );
    attList.add(att37);
    //EDGE - 117740
    //EDGE-117631 Start
    cscfga__Attribute__c att38 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'Quantity',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[0].Id
    );
    attList.add(att38);
    cscfga__Attribute__c att39 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'Type',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[1].Id
    );
    attList.add(att39);
    cscfga__Attribute__c att40 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'TC',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[2].Id
    );
    attList.add(att40);
    cscfga__Attribute__c att41 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'OC',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[3].Id
    );
    attList.add(att41);
    cscfga__Attribute__c att42 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'OperationalHours',
      cscfga__Value__c = '01I28000002B08w',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[4].Id
    );
    attList.add(att42); //EDGE-117631 End
    // EDGE - 117738
    cscfga__Attribute__c att43 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'callingPlans',
      cscfga__Value__c = PIList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[43].Id
    );
    attList.add(att43);
    cscfga__Attribute__c att44 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'concurrencyLimit',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[42].Id
    );
    attList.add(att44);
    cscfga__Attribute__c att45 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'HostedUCQuantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[41].Id
    );
    attList.add(att45);
    cscfga__Attribute__c att46 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'HuntGroupQuantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[40].Id
    );
    attList.add(att46);
    cscfga__Attribute__c att47 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'Number',
      cscfga__Value__c = ' ',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[39].Id
    );
    attList.add(att47);
    cscfga__Attribute__c att48 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'NumberofPhoneNumbers',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[38].Id
    );
    attList.add(att48);
    cscfga__Attribute__c att49 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'RCAutoAttendant',
      cscfga__Value__c = '9.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[37].Id
    );
    attList.add(att49);
    cscfga__Attribute__c att50 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'RCHostedUC',
      cscfga__Value__c = '14.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[36].Id
    );
    attList.add(att50);
    cscfga__Attribute__c att51 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'RCHuntGroup',
      cscfga__Value__c = '14.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[35].Id
    );
    attList.add(att51);
    cscfga__Attribute__c att52 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'RCUser',
      cscfga__Value__c = '14.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[34].Id
    );
    attList.add(att52);
    cscfga__Attribute__c att53 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'Recurring Charge',
      cscfga__Value__c = '14.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[33].Id
    );
    attList.add(att53);
    cscfga__Attribute__c att54 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'RecurringChargePerNumber',
      cscfga__Value__c = '14.00',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[32].Id
    );
    attList.add(att54);
    cscfga__Attribute__c att55 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'UCUserQuantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[12].Id
    );
    attList.add(att55);
    cscfga__Attribute__c att56 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'AutoAttendantQuantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[42].Id
    );
    attList.add(att56);
    //EDGE - 117738 Start
    cscfga__Attribute__c att57 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'ContractTypeString',
      cscfga__Value__c = 'Hardware Repayment',
      cscfga__is_active__c = true,
      cscfga__Display_Value__c = 'Hardware Repayment'
      //cscfga__Attribute_Definition__c = attDefList[16].Id
    );
    attList.add(att57);
    cscfga__Attribute__c att58 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'ContractTypeString',
      cscfga__Value__c = 'Rental',
      cscfga__is_active__c = true,
      cscfga__Display_Value__c = 'Rental'
      //cscfga__Attribute_Definition__c = attDefList[16].Id
    );
    attList.add(att58);
    //EDGE - 117738 End
    //EDGE-127817 Start
    cscfga__Attribute__c att59 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[23].Id,
      Name = 'DisconnectionDate',
      cscfga__Value__c = '2019-12-30',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[44].Id
    );
    attList.add(att59);
    cscfga__Attribute__c att60 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[23].Id,
      Name = 'EarlyTerminationCharge',
      cscfga__Value__c = '555.84',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[45].Id
    );
    attList.add(att60);
    cscfga__Attribute__c att61 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[23].Id,
      Name = 'ContractType',
      cscfga__Value__c = PIListTC[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[13].Id
    );
    attList.add(att61);
    cscfga__Attribute__c att62 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[23].Id,
      Name = 'EarlyTerminationCharge',
      cscfga__Value__c = '0',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[45].Id
    );
    attList.add(att62);
    cscfga__Attribute__c att63 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[25].Id,
      Name = 'ContractType',
      cscfga__Value__c = PIListngUC[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[13].Id
    );
    attList.add(att63);
    cscfga__Attribute__c att64 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[24].Id,
      Name = 'AutoAttendantQuantity',
      cscfga__Value__c = '1',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[42].Id
    );
    attList.add(att64);
    cscfga__Attribute__c att65 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[24].Id,
      Name = 'concurrencyLimit',
      cscfga__Value__c = '2',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[46].Id
    );
    attList.add(att65);
    //EDGE-127817 End
    //DPG-598
    cscfga__Attribute__c att66 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'OneOffCharge',
      cscfga__Value__c = PIList[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[47].Id
    );
    attList.add(att66);
    //EDGE-117967 : Capture POS redemption information in Quotes
    cscfga__Attribute__c att67 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[17].Id,
      Name = 'RedeemFund',
      cscfga__Value__c = '100',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[18].Id
    );
    attList.add(att67);
    //EDGE-132903 - we are just changing attribute data source, there is no change in input & output values in flow
    cscfga__Attribute__c att68 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'TotalRecurringChargeforNumber',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[48].Id
    );
    attList.add(att68);
    cscfga__Attribute__c att69 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'TotalRecurringChargeforUser',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[49].Id
    );
    attList.add(att69);
    cscfga__Attribute__c att70 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'TotalRecurringChargeforHostedUC',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[50].Id
    );
    attList.add(att70);
    cscfga__Attribute__c att71 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'TotalRecurringChargeforAutoAttendant',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[51].Id
    );
    attList.add(att71);
    cscfga__Attribute__c att72 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[22].Id,
      Name = 'TotalRecurringChargeforHuntGroup',
      cscfga__Value__c = '10',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[52].Id
    );
    attList.add(att72);
    //EDGE-132903 - END
    //EDGE-98336 - Start
    cscfga__Attribute__c att73 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[26].Id,
      Name = 'RecurringPrice',
      cscfga__Value__c = '555.84',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[52].Id
    );
    attList.add(att73);
    //EDGE-98337 - End
    //EDGE-127780 - Start
    cscfga__Attribute__c att74 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[28].Id,
      Name = 'Contract Term',
      cscfga__Value__c = '12',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[54].Id
    );
    attList.add(att74);
    cscfga__Attribute__c att75 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[28].Id,
      Name = 'DisconnectionDate',
      cscfga__Value__c = '2020-05-30',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[55].Id
    );
    attList.add(att75);
    cscfga__Attribute__c att76 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[28].Id,
      Name = 'EarlyTerminationCharge',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[56].Id
    );
    attList.add(att76);
    cscfga__Attribute__c att77 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'RC',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[56].Id
    );
    attList.add(att77);
    cscfga__Attribute__c att78 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[15].Id,
      Name = 'IDD Charge',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[56].Id
    );
    attList.add(att78);
    cscfga__Attribute__c att79 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[16].Id,
      Name = 'MessageBank RC',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[56].Id
    );
    attList.add(att79);
    cscfga__Attribute__c att80 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[16].Id,
      Name = 'Device',
      cscfga__Value__c = prodConfigList[14].Id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[56].Id
    );
    attList.add(att80);
    cscfga__Attribute__c att81 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[14].Id,
      Name = 'ChangeTypeDevice',
      cscfga__Value__c = '!=PayOut',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[56].Id
    );
    attList.add(att81);
    //EDGE-127780 - End
    //EDGE-144228 Start
    cscfga__Attribute__c att82 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[18].Id,
      Name = 'OfferTypeString',
      cscfga__Value__c = 'Committed Data',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[57].Id
    );
    attList.add(att82);
    //EDGE-144228 End
    //EDGE-144779 Start
    cscfga__Attribute__c att83 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[34].Id,
      Name = 'OfferTypeString',
      cscfga__Value__c = 'Committed Data',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[58].Id
    );
    attList.add(att83);
    cscfga__Attribute__c att84 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[35].Id,
      Name = 'OfferTypeString',
      cscfga__Value__c = 'XYZ',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[59].Id
    );
    attList.add(att84);
    //EDGE-145184/INC000092558413 Changes Start Here
    cscfga__Attribute__c att85 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[29].Id,
      Name = 'OfferTypeString',
      cscfga__Value__c = 'FairPlay Data',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[59].Id
    );
    attList.add(att85);
    //EDGE-145184/INC000092558413 Changes End Here
    //EDGE-144779 End
    // EDGE-132608 Start
    cscfga__Attribute__c att86 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[36].Id,
      Name = 'callingPlans',
      cscfga__Value__c = PIListBusCal[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[60].Id
    );
    attList.add(att86);
    // EDGE-132608 End
    //EDGE-142319 Start
    cscfga__Attribute__c att87 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[37].Id,
      Name = 'callingPlans',
      cscfga__Value__c = PIListBusCal[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[60].Id
    );
    attList.add(att87);
    //EDGE-142319 End
    //EDGE-144732 - START
    cscfga__Attribute__c att88 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[38].Id,
      Name = 'callingPlans',
      cscfga__Value__c = PIListBusCal[0].id,
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[60].Id
    );
    attList.add(att88);
    //EDGE-144732 - END
    //EDGE-148534 Start
    cscfga__Attribute__c att89 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[39].Id,
      Name = 'EarlyTerminationCharge',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[61].Id
    );
    attList.add(att89);
    //EDGE-148534 End
    //EDGE-148722 Start
    cscfga__Attribute__c att90 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[21].Id,
      Name = 'EarlyTerminationCharge',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[61].Id
    );
    attList.add(att90);
    cscfga__Attribute__c att91 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[38].Id,
      Name = 'EarlyTerminationCharge',
      cscfga__Value__c = '555',
      cscfga__is_active__c = true,
      cscfga__Attribute_Definition__c = attDefList[61].Id
    );
    attList.add(att91);
    //EDGE-148722 End
    insert attList;
    List<Charge_Line_Item__c> lstOfCLI = new List<Charge_Line_Item__c>();
    Charge_Line_Item__c cliPlan = new Charge_Line_Item__c();
    cliPlan.Name = 'aBA2N00000001qh';
    cliPlan.basketId__c = basket.Id;
    cliPlan.BusinessID__c = '';
    cliPlan.Product_Configuration__c = prodConfigList[14].id;
    cliPlan.status__c = 'Active';
    cliPlan.targetChargeProduct__c = 'Plan';
    lstOfCLI.add(cliPlan);
    Charge_Line_Item__c cliAddOn = new Charge_Line_Item__c();
    cliAddOn.Name = 'aBA2N00000001qh';
    cliAddOn.basketId__c = basket.Id;
    cliAddOn.BusinessID__c = '';
    cliAddOn.Product_Configuration__c = prodConfigList[14].id;
    cliAddOn.status__c = 'Active';
    cliAddOn.targetChargeProduct__c = 'AddOn';
    lstOfCLI.add(cliAddOn);
    Charge_Line_Item__c cliPlan1 = new Charge_Line_Item__c();
    cliPlan1.Name = 'aBA2N00000001qh';
    cliPlan1.basketId__c = basket.Id;
    cliPlan1.BusinessID__c = '';
    cliPlan1.Product_Configuration__c = prodConfigList[15].id;
    cliPlan1.status__c = 'Active';
    cliPlan1.targetChargeProduct__c = 'Plan';
    lstOfCLI.add(cliPlan1);
    Charge_Line_Item__c cliAddOn1 = new Charge_Line_Item__c();
    cliAddOn1.Name = 'aBA2N00000001qh';
    cliAddOn1.basketId__c = basket.Id;
    cliAddOn1.BusinessID__c = '';
    cliAddOn1.Product_Configuration__c = prodConfigList[15].id;
    cliAddOn1.status__c = 'Active';
    cliAddOn1.targetChargeProduct__c = 'AddOn';
    lstOfCLI.add(cliAddOn1);
    Charge_Line_Item__c cliPlan2 = new Charge_Line_Item__c();
    cliPlan2.Name = 'aBA2N00000001qh';
    cliPlan2.basketId__c = basket.Id;
    cliPlan2.BusinessID__c = '';
    cliPlan2.Product_Configuration__c = prodConfigList[14].id;
    cliPlan2.status__c = 'Active';
    cliPlan2.targetChargeProduct__c = 'Plan';
    lstOfCLI.add(cliPlan2);
    Charge_Line_Item__c cliAddOn2 = new Charge_Line_Item__c();
    cliAddOn2.Name = 'aBA2N00000001qh';
    cliAddOn2.basketId__c = basket.Id;
    cliAddOn2.BusinessID__c = '';
    cliAddOn2.Product_Configuration__c = prodConfigList[14].id;
    cliAddOn2.status__c = 'Active';
    cliAddOn2.targetChargeProduct__c = 'AddOn';
    lstOfCLI.add(cliAddOn2);
    Charge_Line_Item__c cliPlan4 = new Charge_Line_Item__c();
    cliPlan4.Name = 'aBA2N00000001qh';
    cliPlan4.basketId__c = basket.Id;
    cliPlan4.BusinessID__c = '';
    cliPlan4.Product_Configuration__c = prodConfigList[16].id;
    cliPlan4.status__c = 'Active';
    cliPlan4.targetChargeProduct__c = 'Plan';
    lstOfCLI.add(cliPlan4);
    Charge_Line_Item__c cliAddOn4 = new Charge_Line_Item__c();
    cliAddOn4.Name = 'aBA2N00000001qh';
    cliAddOn4.basketId__c = basket.Id;
    cliAddOn4.BusinessID__c = '';
    cliAddOn4.Product_Configuration__c = prodConfigList[16].id;
    cliAddOn4.status__c = 'Active';
    cliAddOn4.targetChargeProduct__c = 'AddOn';
    lstOfCLI.add(cliAddOn4);
    Charge_Line_Item__c cliPlan5 = new Charge_Line_Item__c();
    cliPlan5.Name = 'aBA2N00000001qh';
    cliPlan5.basketId__c = basket.Id;
    cliPlan5.BusinessID__c = '';
    cliPlan5.Product_Configuration__c = prodConfigList[18].id;
    cliPlan5.status__c = 'Active';
    cliPlan5.targetChargeProduct__c = 'Plan';
    lstOfCLI.add(cliPlan5);
    //EDGE-121387, EDGE-133760 start
    Charge_Line_Item__c cliAddOn5 = new Charge_Line_Item__c();
    cliAddOn5.Name = 'aBA2N00000001qh';
    cliAddOn5.basketId__c = basket.Id;
    cliAddOn5.BusinessID__c = '';
    cliAddOn5.Product_Configuration__c = prodConfigList[18].id;
    cliAddOn5.status__c = 'Active';
    cliAddOn5.targetChargeProduct__c = 'AddOn';
    lstOfCLI.add(cliAddOn5);
    Charge_Line_Item__c cliAddOn6 = new Charge_Line_Item__c();
    cliAddOn6.Name = 'aBA2N00000001qh';
    cliAddOn6.basketId__c = basket.Id;
    cliAddOn6.BusinessID__c = '';
    cliAddOn6.Product_Configuration__c = prodConfigList[8].id;
    cliAddOn6.status__c = 'Active';
    cliAddOn6.targetChargeProduct__c = 'AddOn';
    lstOfCLI.add(cliAddOn6);
    Charge_Line_Item__c cliAddOn7 = new Charge_Line_Item__c();
    cliAddOn7.Name = 'aBA2N00000001qh';
    cliAddOn7.basketId__c = basket.Id;
    cliAddOn7.BusinessID__c = 'DMCAT_RecurringCharge_000814';
    cliAddOn7.Product_Configuration__c = prodConfigList[22].id;
    cliAddOn7.status__c = 'Active';
    cliAddOn7.targetChargeProduct__c = 'Feature';
    lstOfCLI.add(cliAddOn7);
    Charge_Line_Item__c cliAddOn8 = new Charge_Line_Item__c();
    cliAddOn8.Name = 'aBA2N00000001qh';
    cliAddOn8.basketId__c = basket.Id;
    cliAddOn8.BusinessID__c = 'DMCAT_RecurringCharge_000816';
    cliAddOn8.Product_Configuration__c = prodConfigList[22].id;
    cliAddOn8.status__c = 'Active';
    cliAddOn8.targetChargeProduct__c = 'Feature';
    lstOfCLI.add(cliAddOn8);
    Charge_Line_Item__c cliAddOn9 = new Charge_Line_Item__c();
    cliAddOn9.Name = 'aBA2N00000001qh';
    cliAddOn9.basketId__c = basket.Id;
    cliAddOn9.BusinessID__c = 'DMCAT_RecurringCharge_000816';
    cliAddOn9.Product_Configuration__c = prodConfigList[22].id;
    cliAddOn9.status__c = 'Active';
    cliAddOn9.targetChargeProduct__c = 'Device';
    lstOfCLI.add(cliAddOn9);
    //EDGE-121387, EDGE-133760 End
    insert lstOfCLI;
    List<Discount_Line_Item__c> lstOfDLI = new List<Discount_Line_Item__c>();
    Discount_Line_Item__c dliPlan = new Discount_Line_Item__c();
    dliPlan.chargeInstance__c = lstOfCLI[0].Id;
    dliPlan.BusinessID__c = 'DMCAT_Discount_000945';
    dliPlan.discountValue__c = '4';
    dliPlan.duration__c = '4';
    lstOfDLI.add(dliPlan);
    Discount_Line_Item__c dliAddOn = new Discount_Line_Item__c();
    dliAddOn.chargeInstance__c = lstOfCLI[1].Id;
    dliAddOn.BusinessID__c = 'DMCAT_Discount_000945';
    dliAddOn.discountValue__c = '4';
    dliAddOn.duration__c = '4';
    lstOfDLI.add(dliAddOn);
    Discount_Line_Item__c dliPlan1 = new Discount_Line_Item__c();
    dliPlan1.chargeInstance__c = lstOfCLI[2].Id;
    dliPlan1.BusinessID__c = 'DMCAT_Discount_000945';
    dliPlan1.discountValue__c = '4';
    dliPlan1.duration__c = '4';
    lstOfDLI.add(dliPlan1);
    Discount_Line_Item__c dliAddOn1 = new Discount_Line_Item__c();
    dliAddOn1.chargeInstance__c = lstOfCLI[3].Id;
    dliAddOn1.BusinessID__c = 'DMCAT_Discount_000945';
    dliAddOn1.discountValue__c = '4';
    dliAddOn1.duration__c = '4';
    lstOfDLI.add(dliAddOn1);
    Discount_Line_Item__c dliPlan3 = new Discount_Line_Item__c();
    dliPlan3.chargeInstance__c = lstOfCLI[4].Id;
    dliPlan3.BusinessID__c = 'DMCAT_Discount_000945';
    dliPlan3.discountValue__c = '4';
    dliPlan3.duration__c = '4';
    lstOfDLI.add(dliPlan3);
    Discount_Line_Item__c dliAddOn3 = new Discount_Line_Item__c();
    dliAddOn3.chargeInstance__c = lstOfCLI[5].Id;
    dliAddOn3.BusinessID__c = 'DMCAT_Discount_000945';
    dliAddOn3.discountValue__c = '4';
    dliAddOn3.duration__c = '4';
    lstOfDLI.add(dliAddOn3);
    Discount_Line_Item__c dliPlan4 = new Discount_Line_Item__c();
    dliPlan4.chargeInstance__c = lstOfCLI[6].Id;
    dliPlan4.BusinessID__c = 'DMCAT_Discount_000945';
    dliPlan4.discountValue__c = '4';
    dliPlan4.duration__c = '4';
    lstOfDLI.add(dliPlan4);
    Discount_Line_Item__c dliAddOn4 = new Discount_Line_Item__c();
    dliAddOn4.chargeInstance__c = lstOfCLI[7].Id;
    dliAddOn4.BusinessID__c = 'DMCAT_Discount_000945';
    dliAddOn4.discountValue__c = '4';
    dliAddOn4.duration__c = '4';
    lstOfDLI.add(dliAddOn4);
    Discount_Line_Item__c dliPlan5 = new Discount_Line_Item__c();
    dliPlan5.chargeInstance__c = lstOfCLI[8].Id;
    dliPlan5.BusinessID__c = 'DMCAT_Discount_000945';
    dliPlan5.discountValue__c = '4';
    dliPlan5.duration__c = '4';
    lstOfDLI.add(dliPlan5);
    //EDGE-121387, EDGE-133760 start
    Discount_Line_Item__c dliAddOn5 = new Discount_Line_Item__c();
    dliAddOn5.chargeInstance__c = lstOfCLI[9].Id;
    dliAddOn5.BusinessID__c = 'DMCAT_Discount_000945';
    dliAddOn5.discountValue__c = '4';
    dliAddOn5.duration__c = '4';
    lstOfDLI.add(dliAddOn5);
    Discount_Line_Item__c dliPlan6 = new Discount_Line_Item__c();
    dliPlan6.chargeInstance__c = lstOfCLI[10].Id;
    dliPlan6.BusinessID__c = 'DMCAT_Discount_000945';
    dliPlan6.discountValue__c = '4';
    dliPlan6.duration__c = '4';
    lstOfDLI.add(dliPlan6);
    Discount_Line_Item__c dliAddOn6 = new Discount_Line_Item__c();
    dliAddOn6.chargeInstance__c = lstOfCLI[10].Id;
    dliAddOn6.BusinessID__c = 'DMCAT_Discount_000899';
    dliAddOn6.discountValue__c = '4';
    dliAddOn6.duration__c = '4';
    lstOfDLI.add(dliAddOn6);
    Discount_Line_Item__c dliAddOn7 = new Discount_Line_Item__c();
    dliAddOn7.chargeInstance__c = lstOfCLI[11].Id;
    dliAddOn7.BusinessID__c = 'DMCAT_Discount_000945';
    dliAddOn7.discountValue__c = '4';
    dliAddOn7.duration__c = '4';
    lstOfDLI.add(dliAddOn7);
    Discount_Line_Item__c dliAddOn8 = new Discount_Line_Item__c();
    dliAddOn8.chargeInstance__c = lstOfCLI[12].Id;
    dliAddOn8.BusinessID__c = 'DMCAT_Discount_000899';
    dliAddOn8.discountValue__c = '4';
    dliAddOn8.duration__c = '4';
    lstOfDLI.add(dliAddOn8);
    Discount_Line_Item__c dliAddOn9 = new Discount_Line_Item__c();
    dliAddOn9.chargeInstance__c = lstOfCLI[13].Id;
    dliAddOn9.BusinessID__c = 'DMCAT_Discount_000899';
    dliAddOn9.discountValue__c = '4';
    dliAddOn9.duration__c = '4';
    lstOfDLI.add(dliAddOn9);
    Discount_Line_Item__c dliAddOn10 = new Discount_Line_Item__c();
    dliAddOn10.chargeInstance__c = lstOfCLI[13].Id;
    //dliAddOn10.BusinessID__c = 'DMCAT_Discount_000899';
    dliAddOn10.discountValue__c = '4';
    dliAddOn10.duration__c = '4';
    lstOfDLI.add(dliAddOn10);
    //EDGE-121387, EDGE-133760 End
    insert lstOfDLI;
    // EDGE-132608 Test Data
    List<cspmb__Price_Item__c> PIList1 = new List<cspmb__Price_Item__c>();
    Date enddate = Date.Today().addDays(1);
    Date startdate = Date.Today().addDays(-1);
    cspmb__Price_Item__c pi1 = new cspmb__Price_Item__c();
    pi1.Mode__c = 'Individual Line';
    pi1.plan__c = 'Standard';
    pi1.cspmb__Recurring_Charge__c = 75;
    pi1.Technical_Support__c = '24X7';
    pi1.rangeFrom__c = '1';
    pi1.rangeTo__c = '10';
    pi1.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    pi1.cspmb__Effective_End_Date__c = enddate;
    pi1.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi1);
    cspmb__Price_Item__c pi2 = new cspmb__Price_Item__c();
    pi2.Mode__c = 'Individual Line';
    pi2.plan__c = 'Standard';
    pi2.cspmb__Recurring_Charge__c = 75;
    pi2.Technical_Support__c = '24X7';
    pi2.rangeFrom__c = '11';
    pi2.rangeTo__c = '20';
    pi2.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    pi2.cspmb__Effective_End_Date__c = enddate;
    pi2.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi2);
    cspmb__Price_Item__c pi3 = new cspmb__Price_Item__c();
    pi3.Mode__c = 'Individual Line';
    pi3.plan__c = 'Standard';
    pi3.cspmb__Recurring_Charge__c = 75;
    pi3.Technical_Support__c = '24X7';
    pi3.rangeFrom__c = '21';
    pi3.rangeTo__c = '50';
    pi3.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    pi3.cspmb__Effective_End_Date__c = enddate;
    pi3.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi3);
    cspmb__Price_Item__c pi4 = new cspmb__Price_Item__c();
    pi4.Mode__c = 'Individual Line';
    pi4.plan__c = 'Standard';
    pi4.cspmb__Recurring_Charge__c = 75;
    pi4.Technical_Support__c = '24X7';
    pi4.rangeFrom__c = '51';
    pi4.rangeTo__c = '200';
    pi4.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    pi4.cspmb__Effective_End_Date__c = enddate;
    pi4.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi4);
    cspmb__Price_Item__c pi5 = new cspmb__Price_Item__c();
    pi5.Mode__c = 'Individual Line';
    pi5.plan__c = 'Standard';
    pi5.cspmb__Recurring_Charge__c = 75;
    pi5.Technical_Support__c = '24X7';
    pi5.rangeFrom__c = '201';
    pi5.rangeTo__c = '500';
    pi5.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    pi5.cspmb__Effective_End_Date__c = enddate;
    pi5.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi5);
    cspmb__Price_Item__c pi6 = new cspmb__Price_Item__c();
    pi6.Mode__c = 'Individual Line';
    pi6.plan__c = 'Standard';
    pi6.cspmb__Recurring_Charge__c = 75;
    pi6.Technical_Support__c = '24X7';
    pi6.rangeFrom__c = '501';
    pi6.rangeTo__c = '3000';
    pi6.Charge_Id__c = ' DMCAT_RecurringCharge_000814';
    pi6.cspmb__Effective_End_Date__c = enddate;
    pi6.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi6);
    cspmb__Price_Item__c pi7 = new cspmb__Price_Item__c();
    pi7.cspmb__Recurring_Charge__c = 75;
    pi7.rangeFrom__c = '1';
    pi7.rangeTo__c = '10';
    pi7.Charge_Id__c = ' DMCAT_RecurringCharge_000813';
    pi7.cspmb__Effective_End_Date__c = enddate;
    pi7.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi7);
    cspmb__Price_Item__c pi8 = new cspmb__Price_Item__c();
    pi8.cspmb__Recurring_Charge__c = 75;
    pi8.rangeFrom__c = '11';
    pi8.rangeTo__c = '20';
    pi8.Charge_Id__c = ' DMCAT_RecurringCharge_000813';
    pi8.cspmb__Effective_End_Date__c = enddate;
    pi8.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi8);
    cspmb__Price_Item__c pi9 = new cspmb__Price_Item__c();
    pi9.cspmb__Recurring_Charge__c = 75;
    pi9.rangeFrom__c = '21';
    pi9.rangeTo__c = '50';
    pi9.Charge_Id__c = ' DMCAT_RecurringCharge_000813';
    pi9.cspmb__Effective_End_Date__c = enddate;
    pi9.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi9);
    cspmb__Price_Item__c pi10 = new cspmb__Price_Item__c();
    pi10.cspmb__Recurring_Charge__c = 75;
    pi10.rangeFrom__c = '51';
    pi10.rangeTo__c = '200';
    pi10.Charge_Id__c = ' DMCAT_RecurringCharge_000813';
    pi10.cspmb__Effective_End_Date__c = enddate;
    pi10.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi10);
    cspmb__Price_Item__c pi11 = new cspmb__Price_Item__c();
    pi11.cspmb__Recurring_Charge__c = 75;
    pi11.rangeFrom__c = '201';
    pi11.rangeTo__c = '500';
    pi11.Charge_Id__c = ' DMCAT_RecurringCharge_000813';
    pi11.cspmb__Effective_End_Date__c = enddate;
    pi11.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi11);
    cspmb__Price_Item__c pi12 = new cspmb__Price_Item__c();
    pi12.cspmb__Recurring_Charge__c = 75;
    pi12.rangeFrom__c = '501';
    pi12.rangeTo__c = '3000';
    pi12.Charge_Id__c = ' DMCAT_RecurringCharge_000813';
    pi12.cspmb__Effective_End_Date__c = enddate;
    pi12.cspmb__Effective_Start_Date__c = startdate;
    PIList1.add(pi12);
    insert PIList1;
    //EDGE-132608 Test Data End
  }

  /**
   * @Date : 18th July 2020
   *@Desc : Creating negative dataset
   */
  private void setupNegative() {
    EnvironmentVariable__c transitionClone = new EnvironmentVariable__c();
    transitionClone.name = 'TransitionClone';
    transitionClone.value__c = '3';
    insert transitionClone;
    Account acc = AccountTestFactory.buildAccount('TestAcc');
    acc.CIDN__c = '1234567890';
    acc.Customer_Status__c = 'Active';
    insert acc;
    Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
    opp.Product_Type__c = 'Modular';
    insert opp;
    cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
    basket.cscfga__Opportunity__c = opp.id;
    basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
    basket.csbb__Synchronised_With_Opportunity__c = true;
    basket.cscfga__Basket_Status__c = 'Valid';
    basket.cscfga__total_contract_value__c = 1000;
    insert basket;
    cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test', 'Test');
    insert pd;
  }

  /**
   *@Date : 20th July 2020
   *@Desc : This method covers the code for getParentProduct()
   */
  @isTest
  static void getParentProductsTestSuccess() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    
    testclass.setup();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    if (prodBasket != null)
      basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    Test.startTest();
    List<Map<String, Object>> rows = handler.getParentProducts(basketId);
    List<Map<String, Object>> rows1 = handler.getParentProducts(basketId);
    //EDGE-144228 Start
    system.debug('row@@::' + rows);
    system.debug('row.get@@::' + rows[0].get('isCommittedData'));
    Test.stopTest();
    system.assert(rows[0].get('isCommittedData') != null);
    system.assert(rows[0].get('Type') == true); //INC000093040240
    //EDGE-144228 End
    System.assert(rows.isEmpty() == false);
  }

  /**
   *@Date :
   *@Desc :
   */
  @isTest
  static void getParentProducts_TCTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    Test.startTest();
    testclass.setup();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__total_contract_value__c = 1234 LIMIT 1];
    String basketId = '';
    if (prodBasket != null)
      basketId = prodBasket.Id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    List<Map<String, Object>> rows = handler.getParentProducts(basketId);
    Test.stopTest();
    system.debug('row@@::' + rows);
    system.assert(rows[0].get('Order_Type') == true);
  }

  /**
   *@Date : 20th July 2020
   *@Desc : This method covers the getParentProduct() with negative data
   */
  @isTest
  static void getParentProductsTestFailure() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setupNegative();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    List<Map<String, Object>> rows = handler.getParentProducts(basketId);
    Test.stopTest();
    System.assert(rows.isEmpty() == false);
  }

  /**
   *@Date : 18th July 2020
   *@Desc : This method covers the isValid()
   */
  @isTest
  static void isValidIdTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
     
    testclass.setup();
    
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    Test.startTest();
    Boolean result = handler.isValidId(basketId);
    Test.stopTest();
    System.assert(result == true);
  }

  /**
   *@Date : 18th July 2020
   *@Desc : This method covers calculateGSTIncludedPrice()
   */
  @isTest
  static void calculateGSTIncludedPriceTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setup();
    
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    Test.startTest();
    Decimal result = handler.calculateGSTIncludedPrice(22.20);
    Test.stopTest();
  }

  /**
   *@Date : 18th July 2020
   *@Desc : This method covers the calculateTotalDataforCommittedPlan()
   */
  @isTest
  static void calculateTotalDataforCommittedPlan() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setup();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    string result = handler.calculateTotalDataforCommittedPlan('220', '50');
    Test.stopTest();
  }

  /**
   *@Date : 18th Julyy 2020
   *@Desc : This method isPromotionApplied()
   */
  @isTest
  static void isPromotionAppliedTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setup();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    boolean result = handler.isPromotionApplied(basketId);
    Test.stopTest();
  }

  /**
   *@Date : 18th July 2020
   *@Desc : This method covers getCaseStatusMap()
   */
  @isTest
  static void getCaseStatusMapTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setup();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    Map<id, String> result = new Map<id, String>();
    result.putAll(handler.getCaseStatusMap(basketId));
    Test.stopTest();
  }

  /**
   *@Date : 18th July 2020
   *@Desc : This method covers checkifContractExistsForAccount()
   */
  @isTest
  static void checkifContractExistsForAccountTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setup();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
    String basketId = '';
    basketId = prodBasket.id;
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    Boolean result = handler.checkifContractExistsForAccount(basketId, 'abc');
    Test.stopTest();
  }

  /**
   *@Date : 20th July 2020
   *@Desc : This method covers getDiscountApplied()
   */
   @isTest
  static void getDiscountAppliedTest() {
    BasketSnapshotUtilityTest testclass = new BasketSnapshotUtilityTest();
    testclass.setup();
    Test.startTest();
    cscfga__Product_Configuration__c pcId = [SELECT id FROM cscfga__Product_Configuration__c LIMIT 1];
    String pId = pcId.id;
    List<Discount_Line_Item__c> lstOfDLI = new List<Discount_Line_Item__c>();
    Map<String, List<Discount_Line_Item__c>> mapOfDiscounts = new Map<String, List<Discount_Line_Item__c>>();
    for(Discount_Line_Item__c ll : [SELECT id, chargeInstance__c, BusinessID__c, discountValue__c, duration__c  FROM Discount_Line_Item__c])
    {
      lstOfDLI.add(ll);
    }
    mapOfDiscounts.put(pId,lstOfDLI);
    BasketSnapshotUtility handler = new BasketSnapshotUtility();
    List<String> result = new List<String>();
    result.addAll(handler.getDiscountApplied(pId, mapOfDiscounts));
    Test.stopTest();
  }
}