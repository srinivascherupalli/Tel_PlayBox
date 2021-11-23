/*
* @Author : Rahul/Ritika
* @Date : 5th May 2019
* @Desc : Test class for ProductBasketDataHandler
* @Jira : EDGE-66165, EDGE-66484
*/
/***History of Updates
 * Ritika Jaiswal:  19/08/2019  EDGE-98246  For CMP services and devices
 * Purushottam Sahu: 19/09/2019 EDGE-80783  FOR MDM Professional Services
 * Vishal Arbune:   25/01/2020  EDGE-117967 : Capture POS redemption information in Quotes
 * Aniket S: 12/02/2020 EDGE-127780 : Quote changes for TID cancellation
 * Aniket S: 25/02/2020:EDGE : EDGE-137773 - Prod Incident - INC000092084866
 * Jayesh : 31/01/2020 DPG-1311 : Logic to retrieve Recurring charges for IOT Services
 * Jayesh : 20/02/2020 DPG-1454 DPG-1033 : method to fetch IoT Cancellation details
 * Vishal Arbune:   30/03/2020 : EDGE-121387 : Telstra Collaboration (Next Gen UC): EAP discounts to be displayed in the Quote and Order form documents(New Orders)
 * Vishal Arbune:   10/04/2020 : EDGE-133760 : Telstra Collaboration (Next Gen UC): EAP discounts to be displayed in the Quote and Order form documents(MAC Orders)
 * Aniket : 14/04/2020 : EDGE-144228 - INC000092458895 fixing 
 * Aniket : 16/04/2020 : EDGE-144779 - INC000092510399 Fixing
 * Aniket/Sunil : 01/05/2020 : EDGE-132608
 * Aniket/Sunil : 01/05/2020 : EDGE-142319
 * Tejes : 06/05/2020 : EDGE-140501,EDGE-142033 | Getting list price from Product Configuration using discount value (Strategic solution)
 * Aniket:21/05/2020 :EDGE-148534 Incident INC000092761770 Fix
 * Yash/Aniket : 2/07/2020 EDGE-148722 | NGEM Devices
*  Aniket : 13/07/2020 | EDGE-162365 Defect Fix
 * Jayesh/Aruna : 20 July 2020 | DPG-1481 - Method to fetch IoT Shared Data Plan Rate Matrix details
* Sunil Nangare/Manish Berad: 31 July 2020 : EDGE-162025 -B2B - Prod INC - Consolidation of Voice to text International call pack - premium & 3G Standard Retail
* Shradha -15-Oct-2020 : EDGE-169456 - Pricing Service & Frame Agreements Package.
* Mukta EDGE-189346 Added positive and negative test method for fetchRateCard_TelstraCollaboration method
* Aruna 23-Mar-2021  DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
* Puneeth Kamath 10-Aug-2021 DIGI-3352 B2B-1762 - Offer Name Change
* Lokesh Thathuru DIGI-20532 Prod Incident Fix 
 ***/ 
@isTest
public class ProductBasketDataHandlerTest  { 
      static blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
      static String serviceDTO = b.toString();
      Public String configObjectId = '10';//01I28000002B08w
      Public String chargeLineItemName= 'Testing BasketDataHandler';//'aBA2N00000001qh' ;
      static String serviceDTO_V2 = '{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"serviceExtension":[{"Services_To":"0246315099","Services_From":"0246315001","disableCheck":null,"checkValue":null}],"Service_Type":"Voice","Service_Id":"0246315000","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"checkValue":true}],"disableCheck":null,"checkValue":null}],"Product_Type":"ISDN-BRA","disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"266049834"}],"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICEa5f369527219745b8c","CIDN":"6892971200"}';
      private void setup() { 
        Environment_Configurations__c settings=new Environment_Configurations__c();
        settings.No_Triggers__c=true;
        insert settings; 
        EnvironmentVariable__c transitionClone =  new EnvironmentVariable__c();
        transitionClone .name='TransitionClone';
        transitionClone .value__c='3';
        insert transitionClone ;
    List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
    CustomConfigurationOptions__c commConfig1 = new CustomConfigurationOptions__c(); 
    commConfig1.Name = 'ContractAccepted';
    commConfig1.Enrichment_Basket_Stage__c = 'Contract Accepted';
    commConfig1.External_Id__c = '7654';
    commConfig1.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig1);
    CustomConfigurationOptions__c commConfig2 = new CustomConfigurationOptions__c();
    commConfig2.Name = 'CommercialConfiguration';
    commConfig2.Enrichment_Basket_Stage__c = 'Commercial Configuration';
    commConfig2.External_Id__c = 'CCO4';
    commConfig2.Opportunity_Stage__c = 'Develop';
    commList.add(commConfig2);
    CustomConfigurationOptions__c commConfig3 = new CustomConfigurationOptions__c();
    commConfig3.Name = 'Quote';
    commConfig3.Enrichment_Basket_Stage__c = 'Quote';
    commConfig3.External_Id__c = 'CC08';
    commConfig3.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig3);
    insert commList;        
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        //EDGE-127817 Start
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        //billAcc.name = 'BA-0004772';
        billAcc.Account__c = acc.id;
        insert billAcc;
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Committed_Data';
        ev.value__c='True';
        insert ev;
        system.debug('billAcc@@::' + billAcc);
        //EDGE-127817 End
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        //EDGE-144228 Start
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.cscfga__Basket_Status__c = 'Valid';
        basket1.cscfga__total_contract_value__c = 1100;
        insert basket1;
        //EDGE-144228 End
        //EDGE-147419-Test Data
        List<cscfga__Product_Basket__c> pbList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c pbBasket = ProductTestFactory.buildEmptyBasket();
        pbBasket.cscfga__Opportunity__c = opp.id;
        pbBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        pbBasket.csbb__Synchronised_With_Opportunity__c =true;
        pbBasket.cscfga__Basket_Status__c = 'Valid';
        pbBasket.cscfga__total_contract_value__c = 1234;
        pbList.add(pbBasket);
    //EDGE-166406 Start
    cscfga__Product_Basket__c boltOnBasket = ProductTestFactory.buildEmptyBasket();
        boltOnBasket.cscfga__Opportunity__c = opp.id;
        boltOnBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket.cscfga__total_contract_value__c = 1111;
        pbList.add(boltOnBasket);
    //EDGE-166406 End
  //EDGE-176737 Start
    cscfga__Product_Basket__c boltOnIRBasket = ProductTestFactory.buildEmptyBasket();
        boltOnIRBasket.cscfga__Opportunity__c = opp.id;
        boltOnIRBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnIRBasket.csbb__Synchronised_With_Opportunity__c =true;
        boltOnIRBasket.cscfga__Basket_Status__c = 'Valid';
        boltOnIRBasket.cscfga__total_contract_value__c = 2233;
        pbList.add(boltOnIRBasket);
    //EDGE-176737 End
     //EDGE-171429 - Start
     cscfga__Product_Basket__c ngemIdentifierBasketNeg = ProductTestFactory.buildEmptyBasket();
     ngemIdentifierBasketNeg.cscfga__Opportunity__c = opp.id;
     ngemIdentifierBasketNeg.csordtelcoa__Synchronised_with_Opportunity__c =true;
     ngemIdentifierBasketNeg.csbb__Synchronised_With_Opportunity__c =true;
     ngemIdentifierBasketNeg.cscfga__Basket_Status__c = 'Valid';
     ngemIdentifierBasketNeg.cscfga__total_contract_value__c = 191919.19;
     
     cscfga__Product_Basket__c pbIoTBasket = ProductTestFactory.buildEmptyBasket();
        pbIoTBasket.cscfga__Opportunity__c = opp.id;
        pbIoTBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        pbIoTBasket.csbb__Synchronised_With_Opportunity__c =true;
        pbIoTBasket.cscfga__Basket_Status__c = 'Valid';
        pbIoTBasket.cscfga__total_contract_value__c = 900;
        pbList.add(pbIoTBasket);
          
     pbList.add(ngemIdentifierBasketNeg);
     //EDGE-171429 - End

        insert pbList;
        //EDGE-147419-End
    List<cscfga__Product_Basket__c> prodBasketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c='DMCAT_ProductSpecification_000965';
    insert pd;         
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_000871';
        insert pd1;
    cscfga__Product_Definition__c pd2 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd2.product_Specification__c='DMCAT_ProductSpecification_000420';
        insert pd2;  
     //EDGE-98336 - Start
        cscfga__Product_Definition__c pd3 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd3.product_Specification__c='DMCAT_ProductSpecification_000423';
        insert pd3;
        //EDGE-140420 AND EDGE-143435--Changes Start here
        cscfga__Product_Definition__c pd4 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd4.product_Specification__c='DMCAT_Offer_000854';
        insert pd4;
        //EDGE-140420 AND EDGE-143435--Changes Start here
        //EDGE-98336 - End
        List<cscfga__Configuration_Offer__c> listOffers = new List<cscfga__Configuration_Offer__c>();
        cscfga__Configuration_Offer__c offernameCWP= new cscfga__Configuration_Offer__c();
        offernameCWP.name='Connected Workplace';
        offernameCWP.cscfga__Active__c=true;
        offernameCWP.cscfga__Description__c='Connected Workplace';
        listOffers.add(offernameCWP);
            //DPG - 598
         cscfga__Configuration_Offer__c offernameIOT= new cscfga__Configuration_Offer__c();
        offernameIOT.Offer_Spec_Id__c='DMCAT_Offer_000964';
        offernameIOT.name='IOT Offer';//EDGE-162365 Defect Fix
        offernameIOT.cscfga__Active__c=true;
        offernameIOT.cscfga__Description__c='';
        listOffers.add(offernameIOT);  
        cscfga__Configuration_Offer__c offernameCWP1= new cscfga__Configuration_Offer__c();
        offernameCWP1.name='Connected Workplace Package';
        offernameCWP.cscfga__Active__c=true;
        offernameCWP.cscfga__Description__c='Connected Workplace Package';
        listOffers.add(offernameCWP1);
        cscfga__Configuration_Offer__c offernameMobility= new cscfga__Configuration_Offer__c();
        offernameMobility.name='CWP Mobility';
        offernameMobility.cscfga__Active__c=true;
        offernameMobility.cscfga__Description__c='CWP Mobility';
        listOffers.add(offernameMobility);
        cscfga__Configuration_Offer__c offernamePPHH= new cscfga__Configuration_Offer__c();
        offernamePPHH.Offer_Spec_Id__c='DMCAT_Offer_000646';
        offernamePPHH.name='Postpaid handheld - Individual';
        offernamePPHH.cscfga__Active__c=true;
        offernamePPHH.cscfga__Description__c='PPHH Individual S';
        listOffers.add(offernamePPHH);
        cscfga__Configuration_Offer__c offernameCMP= new cscfga__Configuration_Offer__c();
        offernameCMP.Offer_Spec_Id__c='DMCAT_Offer_000646';
        offernameCMP.name='Corporate Mobile Plus';
        offernameCMP.cscfga__Active__c=true;
        offernameCMP.cscfga__Description__c='';
        listOffers.add(offernameCMP);
        //EDGE - 99894 - Start(Added by Aman Soni)
        cscfga__Configuration_Offer__c offernameDOP= new cscfga__Configuration_Offer__c();
        offernameDOP.Offer_Spec_Id__c='DMCAT_Offer_000783';
        offernameDOP.name='Device Outright Purchase';
        offernameDOP.cscfga__Active__c=true;
        offernameDOP.cscfga__Description__c='';
        listOffers.add(offernameDOP);
        //EDGE - 99894 - End(Added by Aman Soni) 
        //EDGE - 98374 - Start
        cscfga__Configuration_Offer__c offernameTC= new cscfga__Configuration_Offer__c();
        offernameTC.Offer_Spec_Id__c='DMCAT_Offer_000618';
        offernameTC.name='Adaptive Collaboration';
        offernameTC.cscfga__Active__c=true;
        offernameTC.cscfga__Description__c='';
        listOffers.add(offernameTC);  
        //EDGE - 98374 - End
        //EDGE-172118 - Start
        cscfga__Configuration_Offer__c offernameAMD= new cscfga__Configuration_Offer__c();
        offernameAMD.Offer_Spec_Id__c='DMCAT_Offer_000618';
        offernameAMD.name='Adaptive Mobility Device';
        offernameAMD.cscfga__Active__c=true;
        offernameAMD.cscfga__Description__c='';
        listOffers.add(offernameAMD);
        cscfga__Configuration_Offer__c offernameAMP= new cscfga__Configuration_Offer__c();
        offernameAMP.Offer_Spec_Id__c='DMCAT_Offer_000618';
        offernameAMP.name='Adaptive Mobility';        //EDGE-184269- Changed the offer name from 'Adaptive Mobility Plan' to 'Adaptive Mobility'
        offernameAMP.cscfga__Active__c=true;
        offernameAMP.cscfga__Description__c='';
        listOffers.add(offernameAMP);   
        //EDGE-172118 - End
        insert listOffers;
          //EDGE-165831 - updated offer code.
    List<Marketable_Offer__c> listOfOffers1= new List<Marketable_Offer__c>();
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Connected Workplace' ;
        mo.Name = 'Test MO';
        //mo.Offer_ID__c = 'D12333';
        mo.Offer_ID__c = 'DMCAT_Offer_000303';
        listOfOffers1.add(mo);
        Marketable_Offer__c mo1 = new Marketable_Offer__c();
        mo1.OfferDefinationName__c ='Connected Workplace Solution' ;
        mo1.Name = 'Test MOdf';
        //mo1.Offer_ID__c = 'D12sd333';
        mo1.Offer_ID__c = 'DMCAT_Offer_000303';
        listOfOffers1.add(mo1);
        Marketable_Offer__c momdm = new Marketable_Offer__c();
        momdm.OfferDefinationName__c ='MDM Tenancy' ;
        momdm.Name = 'Test MOdfs';
        //momdm.Offer_ID__c = 'D12sd333s';
          momdm.Offer_ID__c = 'DMCAT_Offer_000681';
        listOfOffers1.add(momdm);
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        listOfOffers1.add(moMob);
        //Marketable_Offer__c moTC = new Marketable_Offer__c();  
        //EDGE - 98374 - Start
        Marketable_Offer__c moTC = new Marketable_Offer__c();
        moTC.OfferDefinationName__c ='Adaptive Collaboration';
        moTC.Name = 'Adaptive Collaboration';
        moTC.Offer_ID__c = 'DMCAT_Offer_000618';
        listOfOffers1.add(moTC);
        //EDGE - 98374 - End
          // DPG 598  
        Marketable_Offer__c ioTMob = new Marketable_Offer__c();
        ioTMob.OfferDefinationName__c ='IoT solutions' ;
        ioTMob.Name = 'IoT Connectivity';
        ioTMob.Offer_ID__c = 'DMCAT_Offer_000964';
        listOfOffers1.add(ioTMob);
        //EDGE - 109389 - Start
        Marketable_Offer__c mongUCDevice = new Marketable_Offer__c();
        mongUCDevice.OfferDefinationName__c ='Adaptive Collaboration';
        mongUCDevice.Name = 'Adaptive Collaboration';
        mongUCDevice.Offer_ID__c = 'DMCAT_Offer_000618';
        listOfOffers1.add(mongUCDevice);       
        //EDGE - 109389 - End
    //EDEG-80783 :Start
        Marketable_Offer__c moPS = new Marketable_Offer__c();
        moPS.OfferDefinationName__c ='Professional Services';
        moPS.Name = 'Professional Services-MDM Config';
        moPS.Offer_ID__c = 'DMCAT_Offer_000750';
        listOfOffers1.add(moPS);
        //EDEG-80783 :End
        //EDGE - 99894 - Start(Added by Aman Soni)
        Marketable_Offer__c moDOP = new Marketable_Offer__c();
        moDOP.OfferDefinationName__c ='Device Outright Purchase Solution';
        moDOP.Name = 'Device Outright Purchase';
        moDOP.Offer_ID__c = 'DMCAT_Offer_000783';
        listOfOffers1.add(moDOP);
        //EDGE - 99894 - End(Added by Aman Soni)
        //EDGE - 105921 & EDGE-148067- Start
        Marketable_Offer__c moCMPCD = new Marketable_Offer__c();
        moCMPCD.OfferDefinationName__c ='Corporate Mobile Plus';
        moCMPCD.Name = 'Corporate Mobile Plus';
        moCMPCD.Offer_ID__c = 'DMCAT_Offer_000646';
        listOfOffers1.add(moCMPCD);
        //EDGE - 105921 & EDGE-148067 - End
        //EDGE-98336 - Start
        Marketable_Offer__c moTID = new Marketable_Offer__c();
        moTID.OfferDefinationName__c ='Telstra Internet Direct';
        moTID.Name = 'Telstra Internet Direct';
        moTID.Offer_ID__c = 'DMCAT_Offer_000709';
        listOfOffers1.add(moTID);
          //EDGE-144574 MDM Offer name updates in Quote, Order form, CIS and service terms documents
          Marketable_Offer__c tmdmOffer = new Marketable_Offer__c();
          tmdmOffer.OfferDefinationName__c ='MDM Tenancy';
          tmdmOffer.Name = 'Telstra Mobile Device Management - VMware';
          tmdmOffer.Offer_ID__c = 'DMCAT_Offer_000681';
          listOfOffers1.add(tmdmOffer);
        //EDGE-98336 - End
        //EDGE-165326 - Start
        Marketable_Offer__c moNGEM = new Marketable_Offer__c();
        moNGEM.OfferDefinationName__c ='Next Generation Enterprise Mobility';
        moNGEM.Name = 'Next Generation Plan';
        moNGEM.Offer_ID__c = 'DMCAT_Offer_001233';
        listOfOffers1.add(moNGEM);
        //EDGE-165326 - End
        insert listOfOffers1;
            // Product spec PD creation
        List<cscfga__Product_Definition__c> lstPDs = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pd10 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd10.product_Specification__c='DMCAT_ProductSpecification_000623';
        lstPDs.add(pd10);
    cscfga__Product_Definition__c pd11 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd11.product_Specification__c='DMCAT_Offer_000646';
        lstPDs.add(pd11);
    cscfga__Product_Definition__c pd12 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd12.product_Specification__c='DMCAT_ProductSpecification_000747';
        lstPDs.add(pd12);
    cscfga__Product_Definition__c pd13 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd13.product_Specification__c='DMCAT_ProductOffering_000323';
        lstPDs.add(pd13);
    cscfga__Product_Definition__c pd14 = ProductTestFactory.buildProductDefinition('Test','Test');    
    pd14.product_Specification__c='DMCAT_ProductOffering_000304';
    lstPDs.add(pd14);
    cscfga__Product_Definition__c pd15 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd15.product_Specification__c='DMCAT_ProductSpecification_000657';
        lstPDs.add(pd15);
    cscfga__Product_Definition__c pd16 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd16.product_Specification__c='DMCAT_ProductSpecification_000718';
        lstPDs.add(pd16);
    cscfga__Product_Definition__c pd17 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd17.product_Specification__c='DMCAT_ProductSpecification_000622';
        lstPDs.add(pd17);
    cscfga__Product_Definition__c pd18 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd18.product_Specification__c='DMCAT_ProductSpecification_001196';
        lstPDs.add(pd18);
    cscfga__Product_Definition__c pd19 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd19.product_Specification__c='DMCAT_ProductSpecification_000935';
        lstPDs.add(pd19);
        cscfga__Product_Definition__c pd20 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd20.product_Specification__c='DMCAT_ProductSpecification_000623';
        lstPDs.add(pd20);
          //EDGE-164623 start 
        cscfga__Product_Definition__c pd21 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd21.product_Specification__c='DMCAT_ProductSpecification_001208';
        lstPDs.add(pd21);
          //EDGE-164623 End 
          //EDGE-171429 - Start
        cscfga__Product_Definition__c pd22 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd22.product_Specification__c='DMCAT_ProductSpecification_001211';
        lstPDs.add(pd22);
        //EDGE-171429 - End  
        //EDGE-176737 Start
        cscfga__Product_Definition__c pd23 = ProductTestFactory.buildProductDefinition('Test','Test');
    pd23.product_Specification__c='DMCAT_ProductSpecification_001341';  
        lstPDs.add(pd23);
        //EDGE-176737 End
        insert lstPDs; 
            //EDGE-147419-Test PC
        List<cscfga__Product_Configuration__c> tccinfig = new list<cscfga__Product_Configuration__c>();
            cscfga__Product_Configuration__c pconfig = new cscfga__Product_Configuration__c();
            pconfig.cscfga__Product_Definition__c = pd.id;
            pconfig.cscfga__Product_Basket__c = pbBasket.id;
            pconfig.cscfga__Description__c = 'test Description';
            pconfig.cscfga__Contract_Term__c = 36;            
            pconfig.subtype__c = 'No Fault Return';
            pconfig.Commercial_Config__c='Yes';
            pconfig.Quantity_Product_Configuration__c=1;
        pconfig.cscfga__total_one_off_charge__c=100.23;//EDGE-162365 Defect Fix
            pconfig.cscfga__total_recurring_charge__c=100;
            pconfig.name = 'Unified Communication';
            pconfig.Type__c = 'New'; 
            pconfig.Marketable_Offer__c = moTC.id;
            pconfig.cscfga__Product_Family__c='Unified Communication Enterprise';
      pconfig.cscfga__Product_Definition__c=lstPDs[3].Id;
            pconfig.cscfga__total_recurring_charge__c = 46.26;
            pconfig.Marketable_Offer__c = mo.id;
            tccinfig.add(pconfig);
        insert tccinfig;
    csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.Name = 'test order';
        ord.csord__Status2__c = 'Pending';
        insert ord;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'Connected Workplace';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;

          subs.csordtelcoa__Product_Configuration__c=tccinfig[0].id;
          subs.MarketableOffer__c=moNGEM.id;
          subs.Billing_Account__c = billAcc.id;

        insert subs;   
        //EDGE-127817 Start
        csord__Subscription__c subngUC=new csord__Subscription__c();
        subngUC.name  = 'IADs-OneAccess One100 (8 Port)';
        subngUC.csord__Identification__c = 'test identity';
        subngUC.csord__Status__c = 'Pending';
        subngUC.csord__Order__c = ord.id;
        //subngUC.Billing_Account__r.Billing_Account_Number__c = billAcc.Billing_Account_Number__c;
        subngUC.Billing_Account__c = billAcc.id;

            subngUC.csordtelcoa__Product_Configuration__c=tccinfig[0].id;
          subngUC.MarketableOffer__c=moNGEM.id;

        insert subngUC; 
        csord__Service__c servngUC=new csord__Service__c();
        servngUC.name  = 'IADs-OneAccess One100 (8 Port)';
        servngUC.Initial_Activation_Date__c = Date.valueOf('2018-12-30');
        servngUC.csord__Identification__c  = 'test identity';
        servngUC.csord__Subscription__c = subngUC.id;
        insert servngUC;   


        //EDGE-147419-End
        //EDGE-127817 End
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name='Replaced Product Configuration record';
        replacedConfig.cscfga__Product_Definition__c=pd.id;
        replacedConfig.cscfga__Product_Basket__c=basket.id;
        replacedConfig.cscfga__Description__c = 'test Description';
        replacedConfig.cscfga__Contract_Term__c = 36;
        replacedConfig.Commercial_Config__c='Yes';
        replacedConfig.Quantity_Product_Configuration__c=1;
        replacedConfig.cscfga__total_one_off_charge__c=100;
        replacedConfig.cscfga__total_recurring_charge__c=100;
        insert replacedConfig;
         system.debug('replacedConfig ' + replacedConfig.id);
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
    // EDGE-165831 - Updates PDs for PCs
        for (Integer i=0; i <= 54; i++){
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
            config.cscfga__Product_Definition__c = pd.id;
            config.cscfga__Product_Basket__c = basket.id;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Commercial_Config__c='Yes';
            config.Quantity_Product_Configuration__c=1;
            config.cscfga__total_one_off_charge__c=100.12;//EDGE-162365 Defect Fix
            config.cscfga__total_recurring_charge__c=100;
            if (i >= 0 && i<=2)
            {
                config.name='IP Site';
                config.Type__c = 'New';
        config.Marketable_Offer__c = mo.id;
                config.Offer_Reference__c = offernameCWP.id;
config.cscfga__Product_Definition__c = lstPDs[4].Id;
            }
            if (i == 3)
            {
                config.name='IP Site';
                config.Type__c = 'Cancel';
                config.Offer_Reference__c = offernameCWP.id;
        config.Marketable_Offer__c = mo.id;
                config.csordtelcoa__Replaced_Subscription__c =subs.id ;
config.cscfga__Product_Definition__c = lstPDs[4].Id;
            }
            if (i == 4)
            {
                config.name='IP Site';
                config.Type__c = 'Modify';
        config.Marketable_Offer__c = mo.id;
                config.Offer_Reference__c = offernameCWP1.id;
                config.csordtelcoa__Replaced_Subscription__c =subs.id ;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
        config.cscfga__Product_Definition__c = lstPDs[4].Id;
            }   
            if(i == 5)     
            {
                config.name='V2T Samsung Galaxy S9+ 256GB Black first';
                config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
        config.cscfga__Product_Definition__c = pd2.id;
            }
            if(i == 6)     
            {
                config.name='Samsung Galaxy S9+ 256GB Black second';
                config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
        config.cscfga__Product_Definition__c = pd3.id;
            }
            if(i == 7)     
            {
                config.name='Samsung Galaxy S9+ 256GB Black';
                config.Type__c = 'Cancel';
        config.Marketable_Offer__c = moMob.id;
                config.Offer_Reference__c =offernameMobility.id;
                config.cscfga__Product_Family__c='Mobile Device';
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Subscription__c =subs.id ;
config.cscfga__Product_Definition__c = pd3.id;
            }
            if(i == 8)     
            {
                config.name='FairPlay Data - Global';
                config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Mobile Subscription';
                config.cscfga__unit_recurring_charge__c = 200;
        config.cscfga__Product_Definition__c = pd2.id;
                //config.csordtelcoa__Replaced_Subscription__c =subs.id ;
            }
            if(i == 9)     
            {
                config.name='Samsung Galaxy S9+ 256GB Black';
                config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Device';
                config.cscfga__unit_recurring_charge__c = 200;
                config.cscfga__Product_Definition__c = pd3.id;
                //config.csordtelcoa__Replaced_Subscription__c =subs.id ;
            }
            if(i == 10)     
            {
                config.name='FairPlay Data - Global BYO';
                config.Type__c = 'Modify'; 
        config.Marketable_Offer__c = moMob.id;        
                //config.Offer_Reference__c = offernameCWP1.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Mobile Subscription';
        config.cscfga__Product_Definition__c = pd2.id;
                config.cscfga__unit_recurring_charge__c = 200;
                config.csordtelcoa__Replaced_Subscription__c =subs.id ;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE - 98374 Start
            if(i==11)
            {
                config.name = 'Auto Attendant';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moTC.id;
                config.Offer_Reference__c =offernameTC.id;
                config.cscfga__Product_Family__c='Auto Attendant';
        config.cscfga__Product_Definition__c = lstPDs[5].Id;
                config.cscfga__unit_recurring_charge__c = 200;
            } 
            //EDGE - 98374 End
      //EDGE - 80783 Start
            if(i==12)
            {
                config.name = 'Professional Services-MDM Config';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moPS.id;
                config.cscfga__Product_Family__c='Professional Services-MDM Config';
config.cscfga__Product_Definition__c = lstPDs[6].Id;
            } 
            //EDGE - 80783 End
            //EDGE - 109389 Start
            if(i==13)
            {
                config.name = 'Camera-Polycom EagleEye Mini Camera for VVX Handset';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Accessory';
                config.cscfga__total_recurring_charge__c = 0;
                config.cscfga__Product_Definition__c=lstPDs[0].Id;
            } 
            if(i==14)
            {
                config.name = 'IADs-OneAccess One100 (8 Port)';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 46.26;
                config.cscfga__Product_Definition__c=lstPDs[9].Id;// EDGE-165831 - PD updates
            } 
            //EDGE - 109389 End
            //EDGE - 113930 Start
            if(i==15)
            {
                config.name = 'Unified Communication';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Unified Communication Enterprise';
                config.cscfga__total_recurring_charge__c = 46.26;
        config.cscfga__Product_Definition__c=lstPDs[3].Id;
            }
            if(i==16)
            {
                config.name='Samsung Galaxy S9+ 256GB Black';
                config.Type__c = 'Modify';
            config.Marketable_Offer__c = moMob.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Device';
                config.cscfga__Product_Definition__c = pd3.id;
                config.cscfga__unit_recurring_charge__c = 200;
            }    
            //EDGE - 113930 End
            //EDGE - 99894 - Start(Added by Aman Soni)
            if(i==17)
            {
                config.name='Device Outright Purchase Solution';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moDOP.id;
                config.Offer_Reference__c =offernameDOP.id;
                config.cscfga__Product_Family__c='Device Outright Purchase Solution';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Product_Definition__c=pd2.Id;
            }
            //EDGE - 99894 - Start(Added by Aman Soni)
            //EDGE - 105921 & EDGE-148067 - Start
            if(i==18)
            {
                config.name='Corporate Mobile Plus-Committed Data';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Product_Definition__c = lstPDs[1].Id;//EDGE-140420 AND EDGE-143435--Added Changes 
            }
            if(i==19)
            {
                config.name='Corporate Mobile Plus-Committed Data';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;//EDGE - 117740
                config.cscfga__Product_Definition__c = lstPDs[1].Id;//EDGE-140420 AND AND EDGE-143435--Added Changes 
            }
            //EDGE - 105921 & EDGE-148067 - End
            // EDGE - 117740
            //EDGE - 105921 Start
             if(i==20)
            {
                config.name='Corporate Mobile Plus-Committed Data';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
        config.cscfga__Product_Definition__c = lstPDs[1].Id;
            }
            if(i==21)
            {
                config.name='Committed Data - Data SIM $5';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Mobile Subscription';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;
                config.cscfga__Product_Definition__c = pd2.id;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
        //config.cscfga__Product_Basket__c = basket1.id;//EDGE-148534
            }
            if(i==22)
            {
                config.name='Next Generation Voice';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Next Generation Voice';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;
                config.cscfga__Product_Definition__c = pd1.id;
            }
            //EDGE-127817 Start
            if(i==23)
            {
                config.name = 'IADs-OneAccess One100 (8 Port)';
                config.Type__c = 'Cancel'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 46.26;
                config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
                config.cscfga__Product_Definition__c=lstPDs[7].Id;
            }
            if(i==24)
            {
                config.name = 'Next Generation Voice';
                config.Type__c = 'Cancel'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Next Generation Voice';
        config.cscfga__Product_Definition__c=pd1.Id;
                config.cscfga__total_recurring_charge__c = 46.26;
                config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
            }
            if(i==25)
            {
                config.name = 'Camera-Polycom EagleEye Mini Camera for VVX Handset';
                config.Type__c = 'Cancel'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 46.26;
                config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
                config.cscfga__Product_Definition__c=lstPDs[7].Id;
            }
      //EDGE-127817 End
      //DPG 598
            if(i==26)
            {
                config.name= 'IoT Right Plan';
                config.Type__c = 'New';
                config.Marketable_Offer__c = ioTMob.id;
                config.Offer_Reference__c =offernameIOT.id;
                config.cscfga__Product_Family__c='IOT Subscription';
        config.cscfga__Product_Definition__c =pd.Id;
                config.cscfga__total_one_off_charge__c=2.32;
            } 
    //EDGE-98336 - Start
          if(i==27){
              config.name = 'Internet Site - TestSite - New';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moTID.id;
                config.cscfga__Product_Family__c='Internet Site';
                config.cscfga__total_recurring_charge__c = 4000.00;
        config.cscfga__Product_Definition__c =lstPDs[2].Id;
            }
        //EDGE-98336 - End      
    //EDGE-127780 - Start
          if(i==28){
              config.name = 'Internet Site - TestSite - New';
                config.Type__c = 'Cancel'; 
                config.Marketable_Offer__c = moTID.id;
                config.cscfga__Product_Family__c='Internet Site';
                config.cscfga__total_recurring_charge__c = 4000.00;
                config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[27].id;
                config.cscfga__Product_Definition__c =lstPDs[2].Id;//EDGE-148534
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
        //EDGE-127780 - End  
        //EDGE-137773 Start
         if(i==29)
            {
                config.name='Corporate Mobile Plus-FairPlay Data';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
        config.cscfga__Product_Definition__c = lstPDs[1].Id;
            }
         //EDGE-137773 End
    //EDGE-127778 - Start
          if(i==30){
              config.name = 'Internet Site - TestSite - New';
                config.Type__c = 'Modify'; 
                config.Marketable_Offer__c = moTID.id;
                config.cscfga__Product_Family__c='Internet Site';
                config.cscfga__total_recurring_charge__c = 4000.00;
        config.csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[27].id;
        config.cscfga__Product_Definition__c =lstPDs[2].Id;
            }
             if(i==31)
            {
                config.name='FairPlay Data-Telstra IOT Data Plan 100KB';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = ioTMob.id;
                config.cscfga__Product_Family__c='IOT Subscription';
config.cscfga__Product_Definition__c =pd.Id;
                config.cscfga__total_recurring_charge__c = 2.82;
                system.debug('Replaced PC[14]--> ' + replacedConfig.id);
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
              if(i==32)
            {
                config.name='FairPlay Data-Telstra IOT Data Plan 100KB';
                config.Type__c = 'New';
                config.Marketable_Offer__c = ioTMob.id;
                config.cscfga__Product_Family__c='IOT Subscription';
config.cscfga__Product_Definition__c =pd.Id;
                config.cscfga__total_recurring_charge__c = 2.82;
                system.debug('Replaced PC[14]--> ' + replacedConfig.id);
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
        //EDGE-127778 - End  
          //EDGE-144228 Start
            if(i==33)
            {
                config.name='Corporate Mobile Plus-FairPlay Data - Test';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Product_Basket__c = basket1.id;
        config.cscfga__Product_Definition__c = lstPDs[1].Id;
            } 
            //EDGE-144228 End
            //EDGE-144779 Start
            if(i==34)
            {
                config.name='Corporate Mobile Plus-Committed Data Test';
                config.Type__c = 'Modify';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Product_Basket__c = basket1.id;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
        config.cscfga__Product_Definition__c = lstPDs[1].Id;
            }
            if(i==35)
            {
                config.name='Corporate Mobile Plus-Committed Data Test';
                config.Type__c = 'Modify';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
config.cscfga__Product_Definition__c = lstPDs[1].Id;
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Product_Basket__c = basket.id;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-144779 End
            //EDGE-132608 Start
            if(i==36)
            {
                config.name='Business Calling';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Business Calling';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;
                config.cscfga__Product_Definition__c = pd1.id;
            }
      //EDGE-132608 End
      //EDGE-142319 Start
      if(i==37)
            {
                config.name='Business Calling';
                config.Type__c = 'Modify';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Business Calling';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;
                config.cscfga__Product_Definition__c = pd1.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
             //EDGE-142319 End
             //EDGE-144732 START
            if(i==38)
            {
                config.name='Business Calling';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Business Calling';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;
                config.cscfga__Product_Definition__c = pd1.id;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-144732 END
      //EDGE-148534 Start
      if(i==39)
            {
                config.name='Committed Data - Data SIM $5-Test';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = moCMPCD.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Mobile Subscription';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;
        config.cscfga__Product_Definition__c = pd2.id;
        config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
        config.cscfga__Product_Basket__c = basket1.id;//EDGE-148534
            }
            if(i==40)
            {
                config.name= 'IoT Right Plan';
                config.Type__c = 'New';
                config.Marketable_Offer__c = ioTMob.id;
                config.Offer_Reference__c =offernameIOT.id;
                config.cscfga__Product_Family__c='IoT solutions';
                config.cscfga__Product_Basket__c = pbIoTBasket.id;
                config.cscfga__unit_recurring_charge__c = 2.53;
            } 
            if(i==41)
            {
                config.name= 'IoT Shared Data';
                config.Type__c = 'New';
                config.Marketable_Offer__c = ioTMob.id;
                config.Offer_Reference__c =offernameIOT.id;
                config.cscfga__Product_Family__c='IoT solutions';
                config.cscfga__total_one_off_charge__c = 2.53;
            } 
      //EDGE-148534 End
            //EDGE-165326 Start
            if(i==42)
            {
                config.name='Mobile Broadband-Enterprise Lite';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moNGEM.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;

                config.cscfga__Product_Definition__c = lstPDs[8].Id;

            }
            //EDGE-165326 End
            //EDGE-155059 & EDGE-162542 Start
            if(i==43)
            {
                config.name='Mobile Broadband-Enterprise Lite-Cancel';
                config.Type__c = 'Cancel';
                config.Marketable_Offer__c = moNGEM.id;
                config.Offer_Reference__c =offernameCMP.id;
                config.cscfga__Product_Family__c='Enterprise Mobility Plan';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
                config.cscfga__Quantity__c = 1;


                config.cscfga__Product_Definition__c = lstPDs[8].Id;
            }
            //EDGE-165831 - Retrofit
            if(i==44)
            {
                config.name = 'IADs-OneAccess One100 (8 Port)';
                config.Type__c = 'New'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Unified Communication Device';
                config.cscfga__total_recurring_charge__c = 46.26;
                config.cscfga__Product_Definition__c=lstPDs[10].Id;
            } 
            //EDGE-164623 start 
            if(i==45)
            {
                config.name = 'Mobile Device Care Purchase';
                config.Type__c = 'Cancel'; 
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Mobile Device Care';
                config.cscfga__total_recurring_charge__c = 0.00;
                config.cscfga__Product_Definition__c=lstPDs[11].Id;
                config.csordtelcoa__Replaced_Product_Configuration__c = replacedConfig.id;
            }
            //EDGE-164623 End 
            //EDGE-165831 - Retrofit end


            //EDGE-155059 & EDGE-162542 End
      //EDGE-166406 Start
      if(i==46)
            {
          config.cscfga__Product_Definition__c=lstPDs[8].Id;
          config.name='Enterprise Wireless-Epic-Agg';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moTC.id;
        config.cscfga__Product_Family__c='Enterprise Mobility Plan';
        config.cscfga__Product_Basket__c = pbList[1].id;
        config.cscfga__total_recurring_charge__c = 100.00;
            }
      if(i==47)
            {
                config.cscfga__Product_Definition__c = lstPDs[8].Id;
                config.name='Data Features';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moTC.id;
                config.cscfga__Product_Family__c='Enterprise Mobility Data';
                config.cscfga__Product_Basket__c = pbList[1].id;
            }
      //EDGE-166406 End

      //EDGE-171429 - Start
      if(i==48)
            {
            config.cscfga__Product_Definition__c=lstPDs[8].Id;
            config.name='Enterprise Wireless - New Identifier';
            config.Marketable_Offer__c = moNGEM.id;
            config.Offer_Reference__c =offernameCMP.id;
            config.Type__c = 'New';
            config.cscfga__Product_Family__c='Enterprise Mobility Plan';
            config.cscfga__total_recurring_charge__c = 00.00;
            config.cscfga__total_one_off_charge__c=00.00;
            }
        if(i==49)
            {
            config.cscfga__Product_Definition__c=lstPDs[12].Id;
            config.name='AM Device - New Identifier';
            config.Type__c = 'New';
            config.Marketable_Offer__c = moNGEM.id;
            config.Offer_Reference__c =offernameCMP.id;
            config.cscfga__Product_Family__c='Enterprise Mobility Plan';
            config.cscfga__total_recurring_charge__c = 00.00;
            config.cscfga__total_one_off_charge__c=00.00;
            }
        if(i==50)
            {
            config.cscfga__Product_Definition__c=lstPDs[8].Id;
            config.name='AM Plan - MAC Identifier';
            config.Type__c = 'Modify';
            config.Marketable_Offer__c = moNGEM.id;
            config.Offer_Reference__c =offernameCMP.id;
            config.cscfga__Product_Family__c='Enterprise Mobility Plan';
            config.cscfga__total_recurring_charge__c = 00.00;
            config.cscfga__total_one_off_charge__c=00.00;
            }
      //EDGE-171429 - End
      //EDGE-176737 Start
        if(i==51)
            {
            config.cscfga__Product_Definition__c=lstPDs[13].Id;
            config.name='International Roaming Month Pass';
            config.Type__c = 'New';
            config.Marketable_Offer__c = moNGEM.id;
           // config.Offer_Reference__c =offernameCMP.id;
            config.cscfga__Product_Family__c='EM International Roaming Month Pass';
            config.cscfga__total_recurring_charge__c = 60.00;
            config.cscfga__total_one_off_charge__c=00.00;
      config.cscfga__Product_Basket__c = pbList[1].id;
            }
    if(i==52)
            {
      config.cscfga__Product_Definition__c=lstPDs[8].Id;
      config.name='Enterprise Wireless-Epic-Agg_Neg';
      config.Type__c = 'New';
      config.Marketable_Offer__c = moTC.id;
      config.cscfga__Product_Family__c='Enterprise Mobility Plan';
      config.cscfga__Product_Basket__c = pbList[2].id;
      config.cscfga__total_recurring_charge__c = 100.00;
            }
    if(i==53)
            {
            config.cscfga__Product_Definition__c=lstPDs[13].Id;
            config.name='International Roaming Month Pass_Neg';
            config.Type__c = 'New';
            config.Marketable_Offer__c = moNGEM.id;
            config.cscfga__Product_Family__c='EM International Roaming Month Pass';
            config.cscfga__total_recurring_charge__c = 60.00;
            config.cscfga__total_one_off_charge__c=00.00;
      config.cscfga__Product_Basket__c = pbList[2].id;
            }
             if(i==54){
                config.name= 'IoT Utilities Data Plan';
                config.Type__c = 'New';
                config.Marketable_Offer__c = ioTMob.id;
                config.Offer_Reference__c =offernameIOT.id;
                config.cscfga__Product_Family__c='IOT Subscription';
                config.cscfga__Product_Definition__c =pd.Id;
                config.cscfga__total_one_off_charge__c = 2.53;
            }
        //EDGE-176737 End
            prodConfigList.add(config);         
        }
        //EDGE-140420 AND EDGE-143435--Start Changes 
         cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name='test';
                newConfig.Type__c = 'Cancel';
                 newConfig.cscfga__Product_Basket__c = basket.id;
                //config.Marketable_Offer__c = moCMPCD.id;
                //config.Offer_Reference__c =offernameCMP.id;
                newConfig.cscfga__Product_Family__c='Enterprise Mobility';
                newConfig.cscfga__unit_recurring_charge__c = 200;
                newConfig.Quantity_Product_Configuration__c =1;
                newConfig.cscfga__Product_Definition__c = lstPDs[1].Id;
                prodConfigList.add(newConfig);
        //EDGE-140420 AND EDGE-143435--End Changes 
    //EDGE-170932 Start
      cscfga__Product_Configuration__c newAMConfig = new cscfga__Product_Configuration__c();
      newAMConfig.name='testAMChg';
      newAMConfig.Type__c = 'New';
      newAMConfig.cscfga__Product_Basket__c = basket.id;
      newAMConfig.cscfga__Product_Family__c='Enterprise Mobility';
      newAMConfig.cscfga__unit_recurring_charge__c = 200;
      newAMConfig.Quantity_Product_Configuration__c =1;
      newAMConfig.cscfga__Product_Definition__c = lstPDs[8].Id;
      prodConfigList.add(newAMConfig);    
    //EDGE-170932 End    
        insert prodConfigList;
        system.debug('prodConfigList[47]@@47::' + prodConfigList[46].name + '::' + prodConfigList[46].cscfga__Product_Basket__r.cscfga__total_contract_value__c);
        system.debug('Size of prodConfigList--> ' + prodConfigList.size());
        system.debug('prodConfigList[23]@@123::' + prodConfigList[14].name);
        system.debug('prodConfigList[23]@@id::' + prodConfigList[14].id);
        system.debug('prodConfigList[23]@@Family::' + prodConfigList[23].cscfga__Product_Family__c); 
        system.debug('prodConfigList[23]@@Replace::' + prodConfigList[23].csordtelcoa__Replaced_Product_Configuration__c); 
         system.debug('DeviceProductconfigurationName' +prodConfigList[5].name);        
         prodConfigList[5].cscfga__Parent_Configuration__c = prodConfigList[8].id;//EDGE-154662 Fix
        prodConfigList[1].cscfga__Parent_Configuration__c = prodConfigList[0].id;
        prodConfigList[6].cscfga__Parent_Configuration__c = prodConfigList[5].id;
        prodConfigList[9].cscfga__Parent_Configuration__c = prodConfigList[8].id; 


        List<cscfga__Product_Configuration__c> pcUpsertlist= new List<cscfga__Product_Configuration__c>();
        pcUpsertlist.add(prodConfigList[1]);
        //EDGE-127817 Start
        prodConfigList[23].csordtelcoa__Replaced_Product_Configuration__c = prodConfigList[14].id;
        prodConfigList[23].csordtelcoa__Replaced_Service__c = servngUC.id;
        prodConfigList[23].csordtelcoa__Replaced_Subscription__c = subngUC.id;  
    system.debug('Child-->' + prodConfigList[47].name + '::Parent-->' + prodConfigList[46].name);


    prodConfigList[47].cscfga__Parent_Configuration__c = prodConfigList[46].id;//EDGE-166406  
    pcUpsertlist.add(prodConfigList[47]);//EDGE-166406
  //EDGE-176737 Start
  prodConfigList[51].cscfga__Parent_Configuration__c = prodConfigList[46].id;
  pcUpsertlist.add(prodConfigList[51]);
  prodConfigList[53].cscfga__Parent_Configuration__c = prodConfigList[52].id;
  pcUpsertlist.add(prodConfigList[53]);
  //EDGE-176737 End
           pcUpsertlist.add(prodConfigList[23]);
           pcUpsertlist.add(prodConfigList[5]);//EDGE-154662 Fix
        upsert pcUpsertlist;
        system.debug('prodConfigDatafeature@@' + prodConfigList[47].name + '::' + prodConfigList[47].cscfga__Parent_Configuration__r.name);
    system.debug('prodConfigIRMonthPass@@' + prodConfigList[51].name + '::' + prodConfigList[51].cscfga__Parent_Configuration__r.name);
    system.debug('prodConfigListattrbparent@@' + prodConfigList[46].name);
        //EDGE-127817 End
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        List<Attachment> lstattach = new List<Attachment>();
        Attachment attm = new Attachment();
        attm.Name = 'TransitionJSONData.json';
        attm.ParentId = prodConfigList[8].Id;
        attm.Body = Blob.valueOf(serviceDTO_V2);
        lstattach.add(attm);
        //EDGE - 117740 Start
        Attachment atta = new Attachment();
        atta.Name = 'TransitionJSONData.json';
        atta.ParentId = prodConfigList[2].Id;
        atta.Body = Blob.valueOf(serviceDTO_V2);
        lstattach.add(atta);
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        att.ParentId = prodConfigList[1].Id;
        att.Body = Blob.valueOf(serviceDTO_V2);
        lstattach.add(att);
    Attachment attch2 = new Attachment();
        attch2.Name = 'TransitionJSONData.json';
        attch2.ParentId = prodConfigList[20].Id;
        attch2.Body = Blob.valueOf(serviceDTO_V2);
        lstattach.add(attch2);
    Attachment attch3 = new Attachment();
        attch3.Name = 'TransitionJSONData.json';
        attch3.ParentId = prodConfigList[21].Id;
        attch3.Body = Blob.valueOf(serviceDTO_V2);
        lstattach.add(attch3);
        //EDGE - 117740 End
    // EDGE-117738
    Attachment attach1 = new Attachment();
        attach1.Name = 'TransitionJSONData.json';
        attach1.ParentId = prodConfigList[22].Id;
        attach1.Body = Blob.valueOf(serviceDTO_V2);
        lstattach.add(attach1);
    //EDGE-170932 Start
      Attachment attchAM1 = new Attachment();
      attchAM1.Name = 'TransitionJSONData.json';
      attchAM1.ParentId = newAMConfig.Id;
      attchAM1.Body = Blob.valueOf(serviceDTO_V2);
      lstattach.add(attchAM1);
    //EDGE-170932 End    
        insert lstattach;
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
         cscfga__Attribute_Definition__c ad27 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'FeatureLevelShadow'); 
         attDefList.add(ad27);
          cscfga__Attribute_Definition__c ad28 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'TechnicalSupportShadow'
            ); 
         attDefList.add(ad28);
           cscfga__Attribute_Definition__c ad29 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'TenancyID'
            ); 
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
     cscfga__Attribute_Definition__c ad53 = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'RecurringPrice'
            ); 
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
            cscfga__Product_Definition__c = pd3.Id,//EDGE-148534
            Name = 'Contract Term',
            Snapshot_Attribute_Value_Field__c = 'Term__c',
            Snapshot_Attribute_Fields__c = 'Term__c'
        );
        attDefList.add(ad54);
    cscfga__Attribute_Definition__c ad55 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd3.Id,//EDGE-148534
            Name = 'DisconnectionDate',
            Snapshot_Attribute_Value_Field__c = 'PAYG_GT_5__c',
            Snapshot_Attribute_Fields__c = 'PAYG_GT_5__c'
        );
        attDefList.add(ad55);
    cscfga__Attribute_Definition__c ad56 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd3.Id,//EDGE-148534
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
    testPriceItem.ProdSpecId__c='TestOffer';
    testPriceItem.Feature_Level__c='Advanced';
    testPriceItem.Technical_Support__c='24X7';
    testPriceItem.rangeFrom__c='1';
    testPriceItem.rangeTo__c='500';
        //EDGE-121387, EDGE-133760
          testPriceItem.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          testPriceItem.Billing_Description__c ='Test';
          testPriceItem.taxTreatment__c = 'GST Applicable';
        testPriceItem.Unit_Of_Measure__c='per device';
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem};
  //EDGE-166406 Start
  cspmb__Price_Item__c priceItem1 = new cspmb__Price_Item__c();
  priceItem1.Name = 'PaymentTypeLookup';
  priceItem1.cspmb__Recurring_Charge__c = 45;
  priceItem1.Unit_Of_Measure__c='per Mobility Plan';
  PIList.add(priceItem1);
  //EDGE-166406 End
    insert PIList; 
    //EDGE-132608 Start
  cspmb__Price_Item__c testPriceItemBusCal = new cspmb__Price_Item__c();
    testPriceItemBusCal.Name = 'Business Calling';
    testPriceItemBusCal.ChargeType__c = 'RC';
    testPriceItemBusCal.cspmb__Recurring_Charge__c = 75;
    testPriceItemBusCal.cspmb__One_Off_Charge__c = 750;
    testPriceItemBusCal.ProdSpecId__c='DMCAT_ProductSpecification_000871';
    testPriceItemBusCal.rangeFrom__c='501';
    testPriceItemBusCal.rangeTo__c='99999';
          testPriceItemBusCal.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          testPriceItemBusCal.Billing_Description__c ='Standard calling plan - shared line';
          testPriceItemBusCal.taxTreatment__c = 'GST Applicable';
        testPriceItemBusCal.Mode__c = 'Shared Line';
    testPriceItemBusCal.Plan__c = 'Standard';
    List<cspmb__Price_Item__c> PIListBusCal = new List<cspmb__Price_Item__c> {testPriceItemBusCal};
    insert PIListBusCal;
  //EDGE-132608 End      
          //EDGE - 105921 & EDGE-148067- Start
    List<cspmb__Usage_Type__c> UsageList = new List<cspmb__Usage_Type__c>();
    cspmb__Usage_Type__c testUsage = new cspmb__Usage_Type__c();
    testUsage.cspmb__type__c='Group';
    testUsage.cspmb__unit_of_measure__c='Minute';
    testUsage.Name='Data Pack Usage';
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
    List<cspmb__Allowance__c> AllowanceList = new List<cspmb__Allowance__c> {testAllowance,testAllowance1};
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
          testPriceItemCD.ProdSpecId__c='TestOffer';
          testPriceItemCD.Feature_Level__c='Advanced';
          testPriceItemCD.Technical_Support__c='24X7';
          testPriceItemCD.rangeFrom__c='1';
          testPriceItemCD.rangeTo__c='500';
          //EDGE-121387, EDGE-133760
          testPriceItemCD.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          testPriceItemCD.Billing_Description__c ='Test';
          testPriceItemCD.taxTreatment__c = 'GST Applicable';
          testPriceItemCD.Unit_Of_Measure__c='per month per service';
          List<cspmb__Price_Item__c> PIListCD = new List<cspmb__Price_Item__c> {testPriceItemCD};
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
    testPriceItemCD.Charge_Id__c=' DMCAT_RecurringCharge_000814';
        testPriceItemTC.Unit_Of_Measure__c='per Auto Attendant';
        testPriceItemTC.Billing_Description__c = 'Virtual Receptionist';
    List<cspmb__Price_Item__c> PIListTC = new List<cspmb__Price_Item__c> {testPriceItemTC};
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
        testPriceItemIOT.Unit_Of_Measure__c='';
        testPriceItemIOT.Billing_Description__c = 'Telstra IOT Data Plan 100KB Charge';
    List<cspmb__Price_Item__c> PIListIOT = new List<cspmb__Price_Item__c> {testPriceItemIOT};
    insert PIListIOT;
        //EDGE-127817 Start
        cspmb__Price_Item__c testPriceItemngUC = new cspmb__Price_Item__c();
        testPriceItemngUC.Name = 'IADs-OneAccess One100 (8 Port)';
        testPriceItemngUC.cspmb__Contract_Term__c = '';
        testPriceItemngUC.Contract_Type__c = 'Hardware Repayment';
        //EDGE-121387, EDGE-133760
          testPriceItemCD.Charge_Id__c=' DMCAT_RecurringCharge_000814';
        List<cspmb__Price_Item__c> PIListngUC = new List<cspmb__Price_Item__c> {testPriceItemngUC};
        insert PIListngUC;  
        //EDGE-127817 End
        //EDGE-121387, EDGE-133760
        cspmb__Add_On_Price_Item__c testPriceItemAddon = new cspmb__Add_On_Price_Item__c(Name='Basic',ProdSpecId__c='1213',Billing_Description__c='abc',cspmb__Recurring_Charge__c=10);
     insert testPriceItemAddon;
     //EDGE-121387, EDGE-133760
        cspmb__Price_Item_Add_On_Price_Item_Association__c testPriceItemAddonAssoc = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=10,cspmb__Add_On_Price_Item__c=testPriceItemAddon.Id);
     insert testPriceItemAddonAssoc;  


    //EDGE-166406 Start
    List<cspmb__Add_On_Price_Item__c> addOnList = new List<cspmb__Add_On_Price_Item__c>();
    cspmb__Add_On_Price_Item__c priceAddon0 = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_001196',name='international roaming month pass',taxTreatment__c='TAX Exempt',Billing_Description__c='international roaming month pass',cspmb__Recurring_Charge__c=60);
    addOnList.add(priceAddon0);
  //EDGE-176737 Start
  cspmb__Add_On_Price_Item__c priceAddon1 = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_001196',name='international roaming month pass_neg',taxTreatment__c='GST Applicable',Billing_Description__c='international roaming month pass_neg',cspmb__Recurring_Charge__c=60);
    addOnList.add(priceAddon1);
  //EDGE-176737 End
    insert addOnList;
    //EDGE-166406 End   
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[8].Id,
            Name = 'PlanCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[0].Id
        );
        attList.add(att0);
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
          //EDGE-165831
        cscfga__Attribute__c attPC1 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'ContractType',
                cscfga__Value__c = PIListTC[0].id,
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[17].Id
            );
        attList.add(attPC1);
        cscfga__Attribute__c att24 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[14].Id,
                Name = 'Quantity',
                cscfga__Value__c = '1',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[18].Id
            );
        attList.add(att24); 
          //EDGE-165831
          cscfga__Attribute__c attpc2 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'Quantity',
                cscfga__Value__c = '1',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[18].Id
            );
        attList.add(attpc2); 
        cscfga__Attribute__c att25 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[14].Id,
                Name = 'TotalRecurringPrice',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[19].Id
            );
        attList.add(att25); 
          //EDGE-165831
          cscfga__Attribute__c attpc3 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'TotalRecurringPrice',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[19].Id
            );
        attList.add(attpc3);
        cscfga__Attribute__c att26 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[14].Id,
                Name = 'UnitPrice',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[20].Id
            );
        attList.add(att26);  
          //EDGE-165831
          cscfga__Attribute__c attpc4 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'UnitPrice',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[20].Id
            );
        attList.add(attpc4);
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
                cscfga__Value__c = configObjectId,
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[4].Id
            );
        attList.add(att42); //EDGE-117631 End
        // EDGE-165831.
        cscfga__Attribute__c attpc6 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'Quantity',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[0].Id
            );
        attList.add(attpc6);
          cscfga__Attribute__c attpc19 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'Rate',
                cscfga__Value__c = '10.10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[0].Id
            );
        attList.add(attpc19); 
        cscfga__Attribute__c attpc13 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'Type',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[1].Id
            );
        attList.add(attpc13);     
        cscfga__Attribute__c attpc7 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'TC',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[2].Id
            );
        attList.add(attpc7);
        cscfga__Attribute__c attpc8 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'OC',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[3].Id
            );
        attList.add(attpc8);
        cscfga__Attribute__c attpc9 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'OperationalHours',

                cscfga__Value__c = configObjectId,

                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[4].Id
            );
        attList.add(attpc9); 
        // End 
        // EDGE - 117738
        cscfga__Attribute__c att43 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'callingPlans',cscfga__Value__c = PIList[0].id,cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[43].Id
        );
        attList.add(att43);
        cscfga__Attribute__c att44 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'concurrencyLimit', cscfga__Value__c = '1',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[42].Id
        );
        attList.add(att44);
        cscfga__Attribute__c att45 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'HostedUCQuantity', cscfga__Value__c = '1',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[41].Id
        );
        attList.add(att45);
        cscfga__Attribute__c att46 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'HuntGroupQuantity', cscfga__Value__c = '1',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[40].Id
        );
        attList.add(att46);
        cscfga__Attribute__c att47 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'Number', cscfga__Value__c = ' ',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[39].Id
        );
        attList.add(att47);
        cscfga__Attribute__c att48 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'NumberofPhoneNumbers', cscfga__Value__c = '1',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[38].Id
        );
        attList.add(att48);
        cscfga__Attribute__c att49 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'RCAutoAttendant', cscfga__Value__c = '9.00',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[37].Id
        );
        attList.add(att49);
        cscfga__Attribute__c att50 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'RCHostedUC', cscfga__Value__c = '14.00',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[36].Id
        );
        attList.add(att50);
        cscfga__Attribute__c att51 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'RCHuntGroup', cscfga__Value__c = '14.00',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[35].Id
        );
        attList.add(att51);
        cscfga__Attribute__c att52 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'RCUser', cscfga__Value__c = '14.00',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[34].Id
        );
        attList.add(att52);
        cscfga__Attribute__c att53 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'Recurring Charge', cscfga__Value__c = '14.00',cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[33].Id
        );
        attList.add(att53);
        cscfga__Attribute__c att54 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'RecurringChargePerNumber', cscfga__Value__c = '14.00',cscfga__is_active__c =true,
            cscfga__Attribute_Definition__c = attDefList[32].Id
        );
        attList.add(att54);
        cscfga__Attribute__c att55 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'UCUserQuantity', cscfga__Value__c = '1',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = attDefList[12].Id
        );
        attList.add(att55);
        cscfga__Attribute__c att56 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[22].Id,Name = 'AutoAttendantQuantity', cscfga__Value__c = '1',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = attDefList[42].Id
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
                cscfga__Value__c = '40.40',
                cscfga__is_active__c = true,
                cscfga__Display_Value__c = 'Rental',
                cscfga__Attribute_Definition__c = attDefList[16].Id
            );
        attList.add(att58);   
        //EDGE - 117738 End
        //
        //EDGE-165831
        cscfga__Attribute__c attpc10 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'ContractTypeString',
                cscfga__Value__c = 'Hardware Repayment',
                cscfga__is_active__c = true,
                cscfga__Display_Value__c = 'Hardware Repayment'
                //cscfga__Attribute_Definition__c = attDefList[16].Id
            );
        attList.add(attpc10); 
        cscfga__Attribute__c attpc11 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'ContractTypeString',
                cscfga__Value__c = '40.40',
                cscfga__is_active__c = true,
                cscfga__Display_Value__c = 'Rental',
                cscfga__Attribute_Definition__c = attDefList[16].Id
            );
        attList.add(attpc11); 
          cscfga__Attribute__c attpc20 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[14].Id,
                Name = 'Rate',
                cscfga__Value__c = '10.10',
                cscfga__is_active__c = true,
                cscfga__Display_Value__c = '10.10',
                cscfga__Attribute_Definition__c = attDefList[16].Id
            );
        attList.add(attpc20); 
          //end
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
          //retrofit
          cscfga__Attribute__c attpc12 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[44].Id,
                Name = 'RC',
                cscfga__Value__c = '555',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[56].Id
            );
        attList.add(attpc12);
          //end
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
                cscfga__Value__c ='!=PayOut',
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
            cscfga__Product_Configuration__c = prodConfigList[36].Id,Name = 'callingPlans',cscfga__Value__c = PIListBusCal[0].id,cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[60].Id
        );
        attList.add(att86);
  // EDGE-132608 End
  //EDGE-142319 Start
        cscfga__Attribute__c att87 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[37].Id,Name = 'callingPlans',cscfga__Value__c = PIListBusCal[0].id,cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attDefList[60].Id
        );
        attList.add(att87);
  //EDGE-142319 End  
    //EDGE-144732 - START
    cscfga__Attribute__c att88 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[38].Id,Name = 'callingPlans',cscfga__Value__c = PIListBusCal[0].id,cscfga__is_active__c = true,
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
     //EDGE-164623 start 
     cscfga__Attribute__c att92 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[45].Id,
                Name = 'RedeemFundCopy',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[61].Id
            );
            attList.add(att92);
            //EDGE-164623 End
    //EDGE-148722 End
  //EDGE-166406 Start
  system.debug('prodConfigListattrb::' + prodConfigList[46].name + '::' + prodConfigList[46].cscfga__Product_Basket__r.cscfga__total_contract_value__c);
  
    cscfga__Attribute__c att94 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[46].Id,
        Name = 'PlanTypeString',
        cscfga__Value__c = 'Enterprise Wireless',
        cscfga__is_active__c = true


        );  
    attList.add(att94);
    cscfga__Attribute__c att95 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[46].Id,
            Name = 'Select Plan',
            cscfga__Value__c = PIList[1].id,
            cscfga__is_active__c = true


        );
    attList.add(att95);
    system.debug('prodConfigListattrbchild::' + prodConfigList[51].name + '::' + prodConfigList[51].cscfga__Parent_Configuration__r.name);
    cscfga__Attribute__c att96 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[51].Id,//EDGE-176737
            Name = 'IR_MonthPass',
            cscfga__Value__c = addOnList[0].id,
            cscfga__is_active__c = true


        );
        attList.add(att96);
  //EDGE-166406 End
  //EDGE-176737 Start
  
  cscfga__Attribute__c att97 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[52].Id,
            Name = 'Select Plan',
            cscfga__Value__c = PIList[1].id,
            cscfga__is_active__c = true
        );
    attList.add(att97);
    system.debug('prodConfigListattrbchild53::' + prodConfigList[53].name + '::' + prodConfigList[52].name);
    cscfga__Attribute__c att98 = new cscfga__Attribute__c(
      cscfga__Product_Configuration__c = prodConfigList[53].Id,//EDGE-176737
            Name = 'IR_MonthPass',
            cscfga__Value__c = addOnList[1].id,
            cscfga__is_active__c = true
        );
        attList.add(att98);
  cscfga__Attribute__c att99 = new cscfga__Attribute__c(
        cscfga__Product_Configuration__c = prodConfigList[52].Id,
        Name = 'PlanTypeString',
        cscfga__Value__c = 'Enterprise Wireless',
        cscfga__is_active__c = true
        );  
    attList.add(att99);
  //EDGE-176737 End
        insert attList;
          List<Charge_Line_Item__c> lstOfCLI=new  List<Charge_Line_Item__c>();
          Charge_Line_Item__c cliPlan=new Charge_Line_Item__c();
          cliPlan.Name= chargeLineItemName;
          cliPlan.basketId__c=basket.Id;
          cliPlan.BusinessID__c='';
          cliPlan.Product_Configuration__c=prodConfigList[14].id;
          cliPlan.status__c='Active';
          cliPlan.targetChargeProduct__c='Plan';
          lstOfCLI.add(cliPlan);
          Charge_Line_Item__c cliAddOn=new Charge_Line_Item__c();
          cliAddOn.Name= chargeLineItemName;
          cliAddOn.basketId__c=basket.Id;
          cliAddOn.BusinessID__c='';
          cliAddOn.Product_Configuration__c=prodConfigList[14].id;
          cliAddOn.status__c='Active';
          cliAddOn.targetChargeProduct__c='AddOn';
          lstOfCLI.add(cliAddOn);
          Charge_Line_Item__c cliPlan1=new Charge_Line_Item__c();
          cliPlan1.Name=chargeLineItemName;
          cliPlan1.basketId__c=basket.Id;
          cliPlan1.BusinessID__c='';
          cliPlan1.Product_Configuration__c=prodConfigList[15].id;
          cliPlan1.status__c='Active';
          cliPlan1.targetChargeProduct__c='Plan';
          lstOfCLI.add(cliPlan1);
          Charge_Line_Item__c cliAddOn1=new Charge_Line_Item__c();
          cliAddOn1.Name=chargeLineItemName;
          cliAddOn1.basketId__c=basket.Id;
          cliAddOn1.BusinessID__c='';
          cliAddOn1.Product_Configuration__c=prodConfigList[15].id;
          cliAddOn1.status__c='Active';
          cliAddOn1.targetChargeProduct__c='AddOn';
          lstOfCLI.add(cliAddOn1);
          Charge_Line_Item__c cliPlan2=new Charge_Line_Item__c();
          cliPlan2.Name=chargeLineItemName;
          cliPlan2.basketId__c=basket.Id;
          cliPlan2.BusinessID__c='';
          cliPlan2.Product_Configuration__c=prodConfigList[14].id;
          cliPlan2.status__c='Active';
          cliPlan2.targetChargeProduct__c='Plan';
          lstOfCLI.add(cliPlan2);
          Charge_Line_Item__c cliAddOn2=new Charge_Line_Item__c();
          cliAddOn2.Name=chargeLineItemName;
          cliAddOn2.basketId__c=basket.Id;
          cliAddOn2.BusinessID__c='';
          cliAddOn2.Product_Configuration__c=prodConfigList[14].id;
          cliAddOn2.status__c='Active';
          cliAddOn2.targetChargeProduct__c='AddOn';
          lstOfCLI.add(cliAddOn2);
          Charge_Line_Item__c cliPlan4=new Charge_Line_Item__c();
          cliPlan4.Name=chargeLineItemName;
          cliPlan4.basketId__c=basket.Id;
          cliPlan4.BusinessID__c='';
          cliPlan4.Product_Configuration__c=prodConfigList[16].id;
          cliPlan4.status__c='Active';
          cliPlan4.targetChargeProduct__c='Plan';
          lstOfCLI.add(cliPlan4);
          Charge_Line_Item__c cliAddOn4=new Charge_Line_Item__c();
          cliAddOn4.Name=chargeLineItemName;
          cliAddOn4.basketId__c=basket.Id;
          cliAddOn4.BusinessID__c='';
          cliAddOn4.Product_Configuration__c=prodConfigList[16].id;
          cliAddOn4.status__c='Active';
          cliAddOn4.targetChargeProduct__c='AddOn';
          lstOfCLI.add(cliAddOn4);
          Charge_Line_Item__c cliPlan5=new Charge_Line_Item__c();
          cliPlan5.Name=chargeLineItemName;
          cliPlan5.basketId__c=basket.Id;
          cliPlan5.BusinessID__c='';
          cliPlan5.Product_Configuration__c=prodConfigList[18].id;
          cliPlan5.status__c='Active';
          cliPlan5.targetChargeProduct__c='Plan';
          lstOfCLI.add(cliPlan5);
          //EDGE-121387, EDGE-133760 start
          Charge_Line_Item__c cliAddOn5=new Charge_Line_Item__c();
          cliAddOn5.Name=chargeLineItemName;
          cliAddOn5.basketId__c=basket.Id;
          cliAddOn5.BusinessID__c='';
          cliAddOn5.Product_Configuration__c=prodConfigList[18].id;
          cliAddOn5.status__c='Active';
          cliAddOn5.targetChargeProduct__c='AddOn';
          lstOfCLI.add(cliAddOn5);
          Charge_Line_Item__c cliAddOn6=new Charge_Line_Item__c();
          cliAddOn6.Name=chargeLineItemName;
          cliAddOn6.basketId__c=basket.Id;
          cliAddOn6.BusinessID__c='';
          cliAddOn6.Product_Configuration__c=prodConfigList[8].id;
          cliAddOn6.status__c='Active';
          cliAddOn6.targetChargeProduct__c='AddOn';
          lstOfCLI.add(cliAddOn6);
          Charge_Line_Item__c cliAddOn7=new Charge_Line_Item__c();
          cliAddOn7.Name=chargeLineItemName;
          cliAddOn7.basketId__c=basket.Id;
          cliAddOn7.BusinessID__c='DMCAT_RecurringCharge_000814';
          cliAddOn7.Product_Configuration__c=prodConfigList[22].id;
          cliAddOn7.status__c='Active';
          cliAddOn7.targetChargeProduct__c='Feature';
          lstOfCLI.add(cliAddOn7);
           Charge_Line_Item__c cliAddOn8=new Charge_Line_Item__c();
          cliAddOn8.Name=chargeLineItemName;
          cliAddOn8.basketId__c=basket.Id;
          cliAddOn8.BusinessID__c='DMCAT_RecurringCharge_000816';
          cliAddOn8.Product_Configuration__c=prodConfigList[22].id;
          cliAddOn8.status__c='Active';
          cliAddOn8.targetChargeProduct__c='Feature';
          lstOfCLI.add(cliAddOn8);
          Charge_Line_Item__c cliAddOn9=new Charge_Line_Item__c();
          cliAddOn9.Name=chargeLineItemName;
          cliAddOn9.basketId__c=basket.Id;
          cliAddOn9.BusinessID__c='DMCAT_RecurringCharge_000816';
          cliAddOn9.Product_Configuration__c=prodConfigList[22].id;
          cliAddOn9.status__c='Active';
          cliAddOn9.targetChargeProduct__c='Device';
          lstOfCLI.add(cliAddOn9);
          //EDGE-121387, EDGE-133760 End
          Insert lstOfCLI;
          List<Discount_Line_Item__c> lstOfDLI=new List<Discount_Line_Item__c>();
          Discount_Line_Item__c dliPlan = new Discount_Line_Item__c();
          dliPlan.chargeInstance__c =lstOfCLI[0].Id;
          dliPlan.BusinessID__c='DMCAT_Discount_000945' ;
          dliPlan.discountValue__c='4';
          dliPlan.duration__c='4';
          lstOfDLI.add(dliPlan);
          Discount_Line_Item__c dliAddOn= new Discount_Line_Item__c();
          dliAddOn.chargeInstance__c =lstOfCLI[1].Id;
          dliAddOn.BusinessID__c='DMCAT_Discount_000945' ;
          dliAddOn.discountValue__c='4';
          dliAddOn.duration__c='4';
          lstOfDLI.add(dliAddOn);
          Discount_Line_Item__c dliPlan1 = new Discount_Line_Item__c();
          dliPlan1.chargeInstance__c =lstOfCLI[2].Id;
          dliPlan1.BusinessID__c='DMCAT_Discount_000945' ;
          dliPlan1.discountValue__c='4';
          dliPlan1.duration__c='4';
          lstOfDLI.add(dliPlan1);
          Discount_Line_Item__c dliAddOn1= new Discount_Line_Item__c();
          dliAddOn1.chargeInstance__c =lstOfCLI[3].Id;
          dliAddOn1.BusinessID__c='DMCAT_Discount_000945' ;
          dliAddOn1.discountValue__c='4';
          dliAddOn1.duration__c='4';
          lstOfDLI.add(dliAddOn1);
          Discount_Line_Item__c dliPlan3 = new Discount_Line_Item__c();
          dliPlan3.chargeInstance__c =lstOfCLI[4].Id;
          dliPlan3.BusinessID__c='DMCAT_Discount_000945' ;
          dliPlan3.discountValue__c='4';
          dliPlan3.duration__c='4';
          lstOfDLI.add(dliPlan3);
          Discount_Line_Item__c dliAddOn3= new Discount_Line_Item__c();
          dliAddOn3.chargeInstance__c =lstOfCLI[5].Id;
          dliAddOn3.BusinessID__c='DMCAT_Discount_000945' ;
          dliAddOn3.discountValue__c='4';
          dliAddOn3.duration__c='4';
          lstOfDLI.add(dliAddOn3);
          Discount_Line_Item__c dliPlan4 = new Discount_Line_Item__c();
          dliPlan4.chargeInstance__c =lstOfCLI[6].Id;
          dliPlan4.BusinessID__c='DMCAT_Discount_000945' ;
          dliPlan4.discountValue__c='4';
          dliPlan4.duration__c='4';
          lstOfDLI.add(dliPlan4);
          Discount_Line_Item__c dliAddOn4= new Discount_Line_Item__c();
          dliAddOn4.chargeInstance__c =lstOfCLI[7].Id;
          dliAddOn4.BusinessID__c='DMCAT_Discount_000945' ;
          dliAddOn4.discountValue__c='4';
          dliAddOn4.duration__c='4';
          lstOfDLI.add(dliAddOn4);
          Discount_Line_Item__c dliPlan5 = new Discount_Line_Item__c();
          dliPlan5.chargeInstance__c =lstOfCLI[8].Id;
          dliPlan5.BusinessID__c='DMCAT_Discount_000945' ;
          dliPlan5.discountValue__c='4';
          dliPlan5.duration__c='4';
          lstOfDLI.add(dliPlan5);
          //EDGE-121387, EDGE-133760 start
          Discount_Line_Item__c dliAddOn5= new Discount_Line_Item__c();
          dliAddOn5.chargeInstance__c =lstOfCLI[9].Id;
          dliAddOn5.BusinessID__c='DMCAT_Discount_000945' ;
          dliAddOn5.discountValue__c='4';
          dliAddOn5.duration__c='4';
          lstOfDLI.add(dliAddOn5);
           Discount_Line_Item__c dliPlan6 = new Discount_Line_Item__c();
          dliPlan6.chargeInstance__c =lstOfCLI[10].Id;
          dliPlan6.BusinessID__c='DMCAT_Discount_000945' ;
          dliPlan6.discountValue__c='4';
          dliPlan6.duration__c='4';
          lstOfDLI.add(dliPlan6);
          Discount_Line_Item__c dliAddOn6= new Discount_Line_Item__c();
          dliAddOn6.chargeInstance__c =lstOfCLI[10].Id;
          dliAddOn6.BusinessID__c='DMCAT_Discount_000899' ;
          dliAddOn6.discountValue__c='4';
          dliAddOn6.duration__c='4';
          lstOfDLI.add(dliAddOn6);
          Discount_Line_Item__c dliAddOn7= new Discount_Line_Item__c();
          dliAddOn7.chargeInstance__c =lstOfCLI[11].Id;
          dliAddOn7.BusinessID__c='DMCAT_Discount_000945' ;
          dliAddOn7.discountValue__c='4';
          dliAddOn7.duration__c='4';
           lstOfDLI.add(dliAddOn7);
          Discount_Line_Item__c dliAddOn8= new Discount_Line_Item__c();
          dliAddOn8.chargeInstance__c =lstOfCLI[12].Id;
          dliAddOn8.BusinessID__c='DMCAT_Discount_000899' ;
          dliAddOn8.discountValue__c='4';
          dliAddOn8.duration__c='4';
           lstOfDLI.add(dliAddOn8);
           Discount_Line_Item__c dliAddOn9= new Discount_Line_Item__c();
          dliAddOn9.chargeInstance__c =lstOfCLI[13].Id;
          dliAddOn9.BusinessID__c='DMCAT_Discount_000899' ;
          dliAddOn9.discountValue__c='4';
          dliAddOn9.duration__c='4';
           lstOfDLI.add(dliAddOn9);
           //EDGE-121387, EDGE-133760 End
          Insert lstOfDLI;
          // EDGE-132608 Test Data          
          List<cspmb__Price_Item__c> PIList1 = new List<cspmb__Price_Item__c>();
          Date enddate =  Date.Today().addDays(1);
          Date startdate =  Date.Today().addDays(-1);
          cspmb__Price_Item__c pi1 = new cspmb__Price_Item__c();
          pi1.Mode__c = 'Individual Line';
          pi1.plan__c = 'Standard';
          pi1.cspmb__Recurring_Charge__c = 75;
          pi1.Technical_Support__c='24X7';
          pi1.rangeFrom__c='1';
          pi1.rangeTo__c='10';
          pi1.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          pi1.cspmb__Effective_End_Date__c = enddate;
          pi1.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi1);
          cspmb__Price_Item__c pi2 = new cspmb__Price_Item__c();
          pi2.Mode__c = 'Individual Line';
          pi2.plan__c = 'Standard';
          pi2.cspmb__Recurring_Charge__c = 75;
          pi2.Technical_Support__c='24X7';
          pi2.rangeFrom__c='11';
          pi2.rangeTo__c='20';
          pi2.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          pi2.cspmb__Effective_End_Date__c = enddate;
          pi2.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi2);
          cspmb__Price_Item__c pi3 = new cspmb__Price_Item__c();
          pi3.Mode__c = 'Individual Line';
          pi3.plan__c = 'Standard';
          pi3.cspmb__Recurring_Charge__c = 75;
          pi3.Technical_Support__c='24X7';
          pi3.rangeFrom__c='21';
          pi3.rangeTo__c='50';
          pi3.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          pi3.cspmb__Effective_End_Date__c = enddate;
          pi3.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi3);
          cspmb__Price_Item__c pi4 = new cspmb__Price_Item__c();
          pi4.Mode__c = 'Individual Line';
          pi4.plan__c = 'Standard';
          pi4.cspmb__Recurring_Charge__c = 75;
          pi4.Technical_Support__c='24X7';
          pi4.rangeFrom__c='51';
          pi4.rangeTo__c='200';
          pi4.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          pi4.cspmb__Effective_End_Date__c = enddate;
          pi4.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi4);
          cspmb__Price_Item__c pi5 = new cspmb__Price_Item__c();
          pi5.Mode__c = 'Individual Line';
          pi5.plan__c = 'Standard';
          pi5.cspmb__Recurring_Charge__c = 75;
          pi5.Technical_Support__c='24X7';
          pi5.rangeFrom__c='201';
          pi5.rangeTo__c='500';
          pi5.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          pi5.cspmb__Effective_End_Date__c = enddate;
          pi5.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi5);
          cspmb__Price_Item__c pi6 = new cspmb__Price_Item__c();
          pi6.Mode__c = 'Individual Line';
          pi6.plan__c = 'Standard';
          pi6.cspmb__Recurring_Charge__c = 75;
          pi6.Technical_Support__c='24X7';
          pi6.rangeFrom__c='501';
          pi6.rangeTo__c='3000';
          pi6.Charge_Id__c=' DMCAT_RecurringCharge_000814';
          pi6.cspmb__Effective_End_Date__c = enddate;
          pi6.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi6);
          cspmb__Price_Item__c pi7 = new cspmb__Price_Item__c();
          pi7.cspmb__Recurring_Charge__c = 75;
          pi7.rangeFrom__c='1';
          pi7.rangeTo__c='10';
          pi7.Charge_Id__c=' DMCAT_RecurringCharge_000813';
          pi7.cspmb__Effective_End_Date__c = enddate;
          pi7.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi7);
          cspmb__Price_Item__c pi8 = new cspmb__Price_Item__c();
          pi8.cspmb__Recurring_Charge__c = 75;
          pi8.rangeFrom__c='11';
          pi8.rangeTo__c='20';
          pi8.Charge_Id__c=' DMCAT_RecurringCharge_000813';
          pi8.cspmb__Effective_End_Date__c = enddate;
          pi8.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi8);
          cspmb__Price_Item__c pi9 = new cspmb__Price_Item__c();
          pi9.cspmb__Recurring_Charge__c = 75;
          pi9.rangeFrom__c='21';
          pi9.rangeTo__c='50';
          pi9.Charge_Id__c=' DMCAT_RecurringCharge_000813';
          pi9.cspmb__Effective_End_Date__c = enddate;
          pi9.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi9);
          cspmb__Price_Item__c pi10 = new cspmb__Price_Item__c();
          pi10.cspmb__Recurring_Charge__c = 75;
          pi10.rangeFrom__c='51';
          pi10.rangeTo__c='200';
          pi10.Charge_Id__c=' DMCAT_RecurringCharge_000813';
          pi10.cspmb__Effective_End_Date__c = enddate;
          pi10.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi10);
          cspmb__Price_Item__c pi11 = new cspmb__Price_Item__c();
          pi11.cspmb__Recurring_Charge__c = 75;
          pi11.rangeFrom__c='201';
          pi11.rangeTo__c='500';
          pi11.Charge_Id__c=' DMCAT_RecurringCharge_000813';
          pi11.cspmb__Effective_End_Date__c = enddate;
          pi11.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi11);
          cspmb__Price_Item__c pi12 = new cspmb__Price_Item__c();
          pi12.cspmb__Recurring_Charge__c = 75;
          pi12.rangeFrom__c='501';
          pi12.rangeTo__c='3000';
          pi12.Charge_Id__c=' DMCAT_RecurringCharge_000813';
          pi12.cspmb__Effective_End_Date__c = enddate;
          pi12.cspmb__Effective_Start_Date__c= startdate; 
          PIList1.add(pi12);
          insert PIList1;
          //EDGE-132608 Test Data End
                //EDGE-173365 --- Start
                List<Legacy_Service__c> lstLegSer = new List<Legacy_Service__c>();
                Legacy_Service__c legSrvc = new Legacy_Service__c();
                legSrvc.Product_Basket__c = basket.id;
                legSrvc.Product_Type__c = 'Enterprise Mobility';
                legSrvc.Select__c = TRUE;
                legSrvc.Plan_Name__c = 'LegacyAMPlan';
              lstLegSer.add(legSrvc);
                Legacy_Service__c legSrvc1 = new Legacy_Service__c();
                legSrvc1.Product_Basket__c = basket.id;
                legSrvc1.Product_Type__c = 'Enterprise Mobility';
                legSrvc1.Select__c = TRUE;
                legSrvc1.Plan_Name__c = 'LegacyAMPlan';
              lstLegSer.add(legSrvc1);
                insert lstLegSer;
            
          Service_Add_On__c ser = new Service_Add_On__c();
           list<Service_Add_On__c> serList = new list<Service_Add_On__c>();
        ser.Device_Description__c = 'IPhone 6';
            ser.Monthly_Amount__c = 100.00;
            ser.Residual_Remaining_Term__c =3;
        ser.Legacy_Service__c = lstLegSer[0].Id;
        serList.add(ser);
        Service_Add_On__c ser1 = new Service_Add_On__c();
        ser1.Device_Description__c = 'IPhone 6';
            ser1.Monthly_Amount__c = 10.00;
            ser1.Residual_Remaining_Term__c =2;
        ser1.Legacy_Service__c =  lstLegSer[1].Id;
          serList.add(ser1);
          insert serList;
          //EDGE-173365 --- End      
    }
    private void setupNegative() {
    List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
    CustomConfigurationOptions__c commConfig1 = new CustomConfigurationOptions__c();
    commConfig1.Name = 'ContractAccepted';
    commConfig1.Enrichment_Basket_Stage__c = 'Contract Accepted';
    commConfig1.External_Id__c = '7654';
    commConfig1.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig1);
    CustomConfigurationOptions__c commConfig2 = new CustomConfigurationOptions__c();
    commConfig2.Name = 'CommercialConfiguration';
    commConfig2.Enrichment_Basket_Stage__c = 'Commercial Configuration';
    commConfig2.External_Id__c = 'CCO4';
    commConfig2.Opportunity_Stage__c = 'Develop';
    commList.add(commConfig2);
    CustomConfigurationOptions__c commConfig3 = new CustomConfigurationOptions__c();
    commConfig3.Name = 'Quote';
    commConfig3.Enrichment_Basket_Stage__c = 'Quote';
    commConfig3.External_Id__c = 'CC08';
    commConfig3.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig3);
    insert commList;      
        EnvironmentVariable__c transitionClone =  new EnvironmentVariable__c();
        transitionClone .name='TransitionClone';
        transitionClone .value__c='3';
        insert transitionClone ;
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
    }   
    // EDGE-132608 Start

    //EDGE-132608 End
    //EDGE-162365 Defect Fix Below function is for positive scenario
     @isTest static void getNewServicesSummary_Test() {
         ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getSummaryForNewServices(basketId);
         Test.stopTest();
        system.debug('rowsnewsummary@@::' + rows);
        system.debug('GSTIncl_Total_Onceoff_Charges@0' + rows[0].get('GSTIncl_Total_Onceoff_Charges'));
        system.debug('GSTIncl_Total_Onceoff_Charges@1' + rows[1].get('GSTIncl_Total_Onceoff_Charges'));
         System.assert(rows.size()>-1);
        System.assertEquals(rows[0].get('GSTIncl_Total_Onceoff_Charges')!=null,true);//EDGE-162365 Defect Fix 
     }
     @isTest static void getMobilityTypeProducts_Test() {
         ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Devices', 'Type'=>'Recurring Charges'});
         System.debug('rowsdevices:'+rows);
         rows.addAll(handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Mobile Services', 'Type'=>'Recurring Charges'}));
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
     }
    /*Commented because cpu Time Limit exceded  moved getCancelTypeProducts calling method to  getMobilityCancelTypeProducts_Test  
      * @isTest static void getCancelTypeProducts_Test() {
         ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCancelTypeProducts(basketId);
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
     }*/
    @isTest static void getMobilityCancelTypeProducts_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();        
         List<Map<String,Object>> rows = handler.getMobilityCancelTypeProducts(basketId);
          List<Map<String,Object>> rows01 = handler.getCancelTypeProducts(basketId);
         Test.stopTest();
         System.assert(rows.isEmpty() != false );
     }
    //Below function is covers postive scneario for EDGE-148722
    //EDGE-155059 & EDGE-162542 Positive
    @isTest static void getSummaryForChangesToExisting_Test() {
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();//EDGE-148534
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(basketId);
         Test.stopTest();//EDGE-148534
         system.debug('getSummaryForChangesToExisting_Test rows--->'+rows);
         List<String> ETCRow = new List<String>();
         List<String> oneFundRow = new List<String>();//EDGE-164623
        //EDGE-150587 - Added positive assert statement as per Main class changes
         for(Map<String,Object> newRow: rows){
            ETCRow.add(String.valueOf(newRow.get('GSTExcl_TotalETC')));
            system.debug('ETCRow@@:' + ETCRow); 
            if(String.valueOf(newRow.get('Existing_Service'))==System.Label.Telstra_Enterprise_Plus_Credit){oneFundRow.add(String.valueOf(newRow.get('GSTIncl_TotalETC')));}
        }
        
        System.assert(ETCRow.contains('NA- Not available'));
        //System.assert(ETCRow.contains('$555.00'));//EDGE-148722 Start
        //System.assert(ETCRow.contains('1110.00'));
        //EDGE-150587 end
        //EDGE-164623--Start

        if(oneFundRow.size() >= 1) {    //EDGE-197766: If condition is added as part of to fix assert.
            System.assert(oneFundRow[0].contains('-110')); //EDGE-197766: Fixed assert
        }

        //EDGE-164623--Start
        System.assert(rows.isEmpty() == false);
        system.assert(rows[0].get('Order_Type') !='PaidOut'); //EDGE-147912 | Excluding PaidOut details
        //EDGE-155245 | Excluding Transition
        system.assert(rows[0].get('Existing_Service') !='Change Commercial Configuration'); 
        //EDGE-155059 & EDGE-162542 Start
        Boolean isOneFund = false;
        for(integer i=0;i<rows.size();i++){
            system.debug('Existing_Service@@:' + rows[i].get('Existing_Service'));
            if(rows[i].get('Existing_Service')==System.Label.Telstra_Enterprise_Plus_Fund){
                isOneFund = true;
                break;
            }
        }

        system.assert(isOneFund == true);

        //EDGE-155059 & EDGE-162542 End
     }
   //EDGE-148534 Start
   //EDGE-150587 - Negative assert covered in below function & EDGE-164335
   @isTest static void getSummaryForChangesToExistingEM_Test() {
    ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
      Test.startTest();
     testclass.setup();
      cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
      String basketId = '';
      if(prodBasket !=null)
          basketId = prodBasket.id;
      ProductBasketDataHandler handler = new ProductBasketDataHandler();
      List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(basketId);
      Test.stopTest();
      System.assert(rows.isEmpty() == false); //EDGE-164335
      System.assert(rows[1].get('GSTExcl_TotalETC') != null); //EDGE-164335

      system.debug('valueofGST'+rows[1].get('GSTExcl_TotalETC'));

      System.assert(String.valueof(rows[1].get('GSTExcl_TotalETC')) == '555.00');
  }
   @isTest static void getSummaryForChangesToExistingEM_TestNegative() {
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();//
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(null);
         Test.stopTest();
         system.debug('getSummaryForChangesToExistingEM_TestNegative rows@@::' + rows);
         System.assert(rows.isEmpty() == true);// //EDGE-155245 | Negative assert scenario
     }
   //EDGE-148534 End
   /*
   @isTest static void getSummaryForChangesToExisting1_Test() {
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         List<cscfga__Product_Basket__c> prodBasketlist = [select id from cscfga__Product_Basket__c];
         String basketId = '';
         if(prodBasketlist !=null)
             basketId = prodBasketList[1].id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getSummaryForChangesToExisting(prodBasketList[0].Id);
         List<Map<String,Object>> rows1 = handler.getSummaryForChangesToExisting(prodBasketList[1].Id);
         List<Map<String,Object>> rows2 = handler.getSummaryForChangesToExisting(prodBasketList[2].Id);
         System.assert(rows.isEmpty() == false);
     }*/
    //EDGE-88163 & EDGE-148728 - Start
    //EDGE-155059 & EDGE-162542 Positive
    @isTest static void getParentProductsTestSuccess() {
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getParentProducts(basketId);
         //EDGE-144228 Start
         system.debug('row@@::' + rows);
         system.debug('row.get@@::' + rows[0].get('isCommittedData'));
         Test.stopTest();
         system.assert(rows[0].get('isCommittedData') != null);
         system.assert(rows[0].get('Type') == true);//INC000093040240  //EDGE-165488
         //EDGE-144228 End
         System.assert(rows.isEmpty() == false);
         System.assert(rows[0].get('isNGEMPlanCancel') == true);//EDGE-155059 & EDGE-162542

          //EDGE-171429 - Start | Negative Scenario is covered as part of getParentProductsAMNeg() method
          System.assert(rows[0].get('isNGEMNew') == true);
          System.assert(rows[0].get('isNGEMPlanNew') == true);
          System.assert(rows[0].get('isNGEMDeviceNew') == true);
          System.assert(rows[0].get('isNGEMMac') == true);
          System.assert(rows[0].get('isNGEMPlanMac') == true);
         //EDGE-171429 - End
          System.assert(rows[0].get('isNGEMRedeemable') == false);//INC - INC000094326608

     }
      //EDGE-147419 - Start
    @isTest static void getParentProducts_TCTest() {
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c= 1234 limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.Id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getParentProducts(basketId);
         Test.stopTest();
         system.debug('row@@::' + rows);
        // EDGE-165831 - Existing Assert to check check method output as per new spec codes.
         System.assert(rows.isEmpty() == false);
         system.assert(rows[0].get('Order_Type')==true);
     }
     //EDGE-147419 - END
     //EDGE-155059 & EDGE-162542 Negative Scenario
    @isTest static void getParentProductsTestFailure() {
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setupNegative();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getParentProducts(basketId);
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
     }
    //EDGE-88163 & EDGE-148728 - End
     //EDGE-81549 - Test Method for getCMPDevices()
    @isTest static void getCMPDevicesTestSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
        Test.startTest();
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPDevices(basketId,new Map<String,String>{'Order_Type'=>'Device', 'Query_Type'=>'CMPDeviceDetails','Type'=>'New'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
         system.assert(rows[0].get('Product_Module_Name')=='V2T Samsung Galaxy S9+ 256GB Black first');//EDGE-154662 Fix Assert
    }
    @isTest static void getCMPDevicesModifyTestFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();

         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
        Test.startTest();
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPDevices(basketId,new Map<String,String>{'Order_Type'=>'Device', 'Query_Type'=>'CMPDeviceDetails','Type'=>'Modify'});
         Test.stopTest();
         System.assert(!rows.isEmpty() == false);
    }
    //EDGE-81549 - Test Method for getCMPServices()
    //EDGE-162024 - Test Data
    private void setupGetCMPServiceData() {
    List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
    CustomConfigurationOptions__c commConfig1 = new CustomConfigurationOptions__c();
    commConfig1.Name = 'ContractAccepted';
    commConfig1.Enrichment_Basket_Stage__c = 'Contract Accepted';
    commConfig1.External_Id__c = '7654';
    commConfig1.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig1);
    CustomConfigurationOptions__c commConfig2 = new CustomConfigurationOptions__c();
    commConfig2.Name = 'CommercialConfiguration';
    commConfig2.Enrichment_Basket_Stage__c = 'Commercial Configuration';
    commConfig2.External_Id__c = 'CCO4';
    commConfig2.Opportunity_Stage__c = 'Develop';
    commList.add(commConfig2);
    CustomConfigurationOptions__c commConfig3 = new CustomConfigurationOptions__c();
    commConfig3.Name = 'Quote';
    commConfig3.Enrichment_Basket_Stage__c = 'Quote';
    commConfig3.External_Id__c = 'CC08';
    commConfig3.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig3);
    insert commList;      
        Account acc = AccountTestFactory.buildAccount('TestAccListPrice');
        acc.CIDN__c = '1234543210';
        acc.Customer_Status__c='Active';
        insert acc;
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000501234';
        billAcc.Account__c = acc.id;
        insert billAcc;
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Committed_Data';
        ev.value__c='True';
        insert ev;
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        List<cscfga__Product_Basket__c> lstBasket = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        lstBasket.add(basket);
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.cscfga__Basket_Status__c = 'Valid';
        basket1.cscfga__total_contract_value__c = 1100;
        lstBasket.add(basket1);
        insert lstBasket;
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        insert moMob;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c ='DMCAT_Offer_000646';
        insert pd;
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_000420';
        insert pd1;
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c(name='test',Type__c = 'New',cscfga__Product_Basket__c = lstBasket[0].id,Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',
                                                                                          cscfga__total_recurring_charge__c=100,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null,cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfig;
        cscfga__Product_Configuration__c newConfigMod = new cscfga__Product_Configuration__c(name='test1',Type__c = 'Modify',cscfga__Product_Basket__c = lstBasket[0].id,Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,
                                                                                             cscfga__Product_Definition__c = pd.id,csordtelcoa__Replaced_Product_Configuration__c = newConfig.id,cscfga__Parent_Configuration__c = null,cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfigMod;
        cscfga__Product_Configuration__c newConfigCancel = new cscfga__Product_Configuration__c(Name='Committed Data',Type__c = 'Cancel',cscfga__Product_Basket__c = lstBasket[0].id,
                                                                                                Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,
                                                                                                cscfga__Product_Definition__c = pd.id,csordtelcoa__Replaced_Product_Configuration__c = newConfig.id,cscfga__Parent_Configuration__c = null,
                                                                                                cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfigCancel;
        cscfga__Product_Configuration__c newConfigCancel1 = new cscfga__Product_Configuration__c(Name='Committed Data',Type__c = 'Cancel',cscfga__Product_Basket__c = lstBasket[0].id,
                                                                                                 Marketable_Offer__c = moMob.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,
                                                                                                 cscfga__Product_Definition__c = pd1.id,csordtelcoa__Replaced_Product_Configuration__c = newConfig.id,cscfga__Parent_Configuration__c = null,
                                                                                                 cscfga__recurring_charge_line_discount_value__c = 50.00);
        insert newConfigCancel1;
        List<Charge_Line_Item__c> lstOfCLI=new  List<Charge_Line_Item__c>();
        Charge_Line_Item__c cliPlan=new Charge_Line_Item__c();
        cliPlan.Name=chargeLineItemName;
        cliPlan.basketId__c=lstBasket[0].Id;
        cliPlan.BusinessID__c='';
        cliPlan.Product_Configuration__c=newConfig.id;
        cliPlan.status__c='Active';
        cliPlan.targetChargeProduct__c='Plan';
        lstOfCLI.add(cliPlan);
        Charge_Line_Item__c cliAddOn=new Charge_Line_Item__c();
        cliAddOn.Name=chargeLineItemName;
        cliAddOn.basketId__c=lstBasket[0].Id;
        cliAddOn.BusinessID__c='';
        cliAddOn.Product_Configuration__c=newConfig.id;
        cliAddOn.status__c='Active';
        cliAddOn.targetChargeProduct__c='AddOn';
        lstOfCLI.add(cliAddOn);
        insert lstOfCLI;
        List<Discount_Line_Item__c> lstOfDLI=new List<Discount_Line_Item__c>();
        Discount_Line_Item__c dliPlan = new Discount_Line_Item__c();
        dliPlan.chargeInstance__c =lstOfCLI[0].Id;
        dliPlan.BusinessID__c='DMCAT_Discount_000945' ;
        dliPlan.discountValue__c='4';
        dliPlan.duration__c='4';
        lstOfDLI.add(dliPlan);
        Discount_Line_Item__c dliAddOn= new Discount_Line_Item__c();
        dliAddOn.chargeInstance__c =lstOfCLI[1].Id;
        dliAddOn.BusinessID__c='DMCAT_Discount_000945' ;
        dliAddOn.discountValue__c='4';
        dliAddOn.duration__c='4';
        lstOfDLI.add(dliAddOn);
        insert lstOfDLI;
        cspmb__Price_Item__c piItem = new cspmb__Price_Item__c(Plan__c='Global BYO',taxTreatment__c='GST Applicable',Billing_Description__c='Bring your own - global plan', Unit_Of_Measure__c  
                                                               ='each', Name='Mobility', Offer_Id__c='DMCAT_Offer_000646',cspmb__Recurring_Charge__c=131.81);
        insert piItem;
        List<cspmb__Add_On_Price_Item__c> pilst = new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c priceAddon = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_000263',Charge_Id__c='DMCAT_RecurringCharge_000497',name='3G Standard Retail',Unit_Of_Measure__c='each',Billing_Description__c='3G Standard Retail',cspmb__Recurring_Charge__c=50);
        pilst.add(priceAddon);
        cspmb__Add_On_Price_Item__c priceAddon1 = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_000420',Charge_Id__c='DMCAT_RecurringCharge_000669',name='3G Standard Retail',Unit_Of_Measure__c='each',Billing_Description__c='Premium',cspmb__Recurring_Charge__c=50);
        pilst.add(priceAddon1);
        cspmb__Add_On_Price_Item__c priceAddon2 = new cspmb__Add_On_Price_Item__c(ProdSpecId__c='DMCAT_ProductSpecification_000420',Charge_Id__c='DMCAT_RecurringCharge_000669',name='International call pack - premium',Unit_Of_Measure__c='each',Billing_Description__c='Premium',cspmb__Recurring_Charge__c=50);
        pilst.add(priceAddon2);
        insert pilst;
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piAddOnAssociation=new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c paddon = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=50.00,cspmb__Add_On_Price_Item__c=pilst[0].Id);
        piAddOnAssociation.add(paddon);
        cspmb__Price_Item_Add_On_Price_Item_Association__c paddon1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=50.00,cspmb__Add_On_Price_Item__c=pilst[1].Id);
        piAddOnAssociation.add(paddon1);
        cspmb__Price_Item_Add_On_Price_Item_Association__c paddon2 = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Recurring_Charge__c=50.00,cspmb__Add_On_Price_Item__c=pilst[2].Id);
        piAddOnAssociation.add(paddon2);
        insert piAddOnAssociation;
        cspmb__Usage_Type__c usage1=new cspmb__Usage_Type__c(Name='Mobile Plan Usage',cspmb__unit_of_measure__c='Megabyte',cspmb__type__c='Single');
        insert usage1;
        List<cspmb__Allowance__c> lstAllowance=new List<cspmb__Allowance__c>();
        cspmb__Allowance__c pallowance = new cspmb__Allowance__c(Name='FairPlay Data Allowance Global BYO',Value__c='250',cspmb__usage_type__c=usage1.Id);
        lstAllowance.add(pallowance);
        cspmb__Allowance__c planCancel = new cspmb__Allowance__c(Unit_Of_Measure__c='GB',Name='FairPlay Data Allowance Global BYO',Value__c='250',type__c='Committed Data',cspmb__usage_type__c=usage1.Id);
        lstAllowance.add(planCancel);
        cspmb__Allowance__c planCancel1 = new cspmb__Allowance__c(Unit_Of_Measure__c='GB',Name='FairPlay Data Allowance Global BYO',Value__c='250',type__c='Committed Bonus Data',cspmb__usage_type__c=usage1.Id);
        lstAllowance.add(planCancel1);
        insert lstAllowance;
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',
            Snapshot_Attribute_Fields__c = 'Plan'
        ); 
        insert ad2;
        List<cscfga__Attribute__c> attlist=new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'PlanCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att0);
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'Select Plan',
            cscfga__Value__c = piItem.Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'MessageBank',
            cscfga__Value__c = piAddOnAssociation[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'InternationalDirectDial',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att3);
        cscfga__Attribute__c att4 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att4);
        cscfga__Attribute__c att5 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'TotalPlanBonus',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att5);
        cscfga__Attribute__c att6 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'PlanAllowance',
            cscfga__Value__c = lstAllowance[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att6);
        cscfga__Attribute__c att7 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'PlanCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att7);
        cscfga__Attribute__c att8 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'Select Plan',
            cscfga__Value__c = piItem.Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att8);
        cscfga__Attribute__c att9 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'MessageBank',
            cscfga__Value__c = piAddOnAssociation[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att9);
        cscfga__Attribute__c att10 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'InternationalDirectDial',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att10);
        cscfga__Attribute__c att11 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att11);
        cscfga__Attribute__c att12 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'TotalPlanBonus',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att12);
        cscfga__Attribute__c att13 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigMod.Id,
            Name = 'PlanAllowance',
            cscfga__Value__c = lstAllowance[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att13);
        cscfga__Attribute__c att14 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'Select Plan',
            cscfga__Value__c = piItem.Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att14);
        cscfga__Attribute__c att15 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'MessageBank',
            cscfga__Value__c = piAddOnAssociation[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att15);
        cscfga__Attribute__c att16 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'InternationalDirectDial',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att16);
        cscfga__Attribute__c att17 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att17);
        cscfga__Attribute__c att18 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'TotalPlanBonus',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att18);
        cscfga__Attribute__c att19 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'PlanAllowance',
            cscfga__Value__c = lstAllowance[1].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att19);
        cscfga__Attribute__c att20 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel1.Id,
            Name = 'IDDAllowance',
            cscfga__Value__c = lstAllowance[2].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att20);
         cscfga__Attribute__c att21 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'InternationalDirectDial',
            cscfga__Value__c = piAddOnAssociation[2].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att21);
        cscfga__Attribute__c att22 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'IDD Charge',
            cscfga__Value__c = '50',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att22);
        cscfga__Attribute__c att23 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'SelectIDD',
            cscfga__Value__c = 'Premium',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att23);
        cscfga__Attribute__c att24 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'IDD Charge Discounted',
            cscfga__Value__c = '',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att24);
        cscfga__Attribute__c att25 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'MessageBank RC',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att25);
        cscfga__Attribute__c att26 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'MessageBankString',
            cscfga__Value__c = '3G Standard Retail',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att26);
        cscfga__Attribute__c att27 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfig.Id,
            Name = 'IDD ChargeLookup',
            cscfga__Value__c =pilst[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att27);
        cscfga__Attribute__c att28 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'Select Plan',
            cscfga__Value__c = piItem.Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att28);
        cscfga__Attribute__c att29 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'MessageBank',
            cscfga__Value__c = piAddOnAssociation[0].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att29);
        cscfga__Attribute__c att30 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'InternationalDirectDial',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att30);
        cscfga__Attribute__c att31 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att31);
        cscfga__Attribute__c att32 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'TotalPlanBonus',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att32);
        cscfga__Attribute__c att33 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'PlanAllowance',
            cscfga__Value__c = lstAllowance[1].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att33);
        cscfga__Attribute__c att34 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = newConfigCancel.Id,
            Name = 'IDDAllowance',
            cscfga__Value__c = lstAllowance[2].Id,
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = ad2.Id
        );
        attList.add(att34);
        insert attList; 
    }
    @isTest static void getCMPServicesTestSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        //testclass.setup();
        testclass.setupGetCMPServiceData();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'New'});
         system.debug('getCMPServicesTestSuccessdebug'+rows);
        Test.stopTest();
       /*for(Map<String,Object> returnMap:rows){
            for(String str:returnMap.keySet()){
                Object text=returnMap.get(str);
                 System.assert(text!=null);
            }
        }*/
        System.assertEquals(1,rows[0].get('Quantity'));//EDGE-140420 AND EDGE-143435
         System.assert(rows.isEmpty() == false);
        System.assertEquals('3G Standard Retail',rows[2].get('Product_Module_Name'));//EDGE-162025
    }

   //EDGE-99894 - Test Method for getDOPServices()
    @isTest static void getDOPServicesTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id,cscfga__total_contract_value__c from cscfga__Product_Basket__c limit 1];
         system.debug('prodBasket---->'+prodBasket);
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getDOPServices(basketId,new Map<String,String>{'Query_Type'=>'DOPServiceDetails','Type'=>'New'});
         System.debug('-----rows'+rows.isEmpty());
         System.debug('-----rows'+rows);
         Test.stopTest();
        // System.assert(rows.isEmpty() == false);
         System.assertNotEquals(null,prodBasket);
    }
   //EDGE-99894 - Test Method for getDOPServices()|| (Added by Aman Soni)
    @isTest static void getDOPServicesTest1(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getDOPServices(null,null);
         System.debug('-----rows'+rows.isEmpty());
         System.debug('-----rows'+rows);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }

    //EDGE-144732 - END
    @isTest static void getCalculateRemainingTermngUCSuccess(){
         ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup(); // moved to here to check as a part of DIGI-20532
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
         String BillingAccountJson = '{"code":200,"status":200,"message":"Success","billingAccount":{"billingAccountNumber":700000506340,"status":"Active","startDate":"2019-12-18T00:00:00Z","billCycleDay":1,"paymentTerms":30,"rouCode":"test22","currencyCode":"AUD","language":"English","companyName":"Eureka_18/12/2019_ZVX","billingAddress":{"address":"40 BOND ST, abc dd","locality":"KINGS MEADOWS","postcode":"7249","state":"TAS","country":"Australia"}}}';
         //String BillingAccountJson = '[billingAccount=BillingAccount:[billCycleDay=1, billingAccountNumber=700000506340, billingAccountOwner=null, billingAddress=BillingAddress:[address=40 BOND ST, abc dd, country=Australia, locality=KINGS MEADOWS, postcode=7249, state=TAS], currencyCode=AUD, language=English, paymentTerms=30, rouCode=test22, startDate=2019-12-18T00:00:00Z, status=Active], code=200, correlationId=null, errors=null, message=Success, status=200]';
         BillingAccountDetailsDTO BillingAccDTO = BillingAccountDetailsDTO.parse(BillingAccountJson);
         //testclass.setup(); this line is moved to above
         Test.startTest();
         system.debug('BillingAccountDetailsDTO@@::' + BillingAccDTO);
         Date iniActDat = Date.valueOf('2018-12-30 00:00:00');
         Date disDate = Date.valueOf('2019-12-30 00:00:00');
         Integer conTerm = 24;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         //List<Map<String,Object>> rows = handler.getngUCDevicesRC(basketId,new Map<String,String>{'Query_Type'=>'ngUCDevicesRCDetails','Type'=>'New'});
         Integer rowsTerms = ProductBasketDataHandler.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
         //rowsTerms = handler.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
         Test.stopTest();
         System.assert(rowsTerms!=null);
    } 
    //EDGE-127817 End
    //Test method for - EDGE-104681 Modify CMP
    @isTest static void getCMPServicesTestModify(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        //testclass.setup();
        testclass.setupGetCMPServiceData();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Modify'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }
    //Test method for - EDGE-80783 Professional Services
    @isTest static void getMDMProfServicesTestSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getMDMProfServices(basketId,new Map<String,String>{'Query_Type'=>'MDMProfServiceDetails','Offer_Name'=>'Professional Services-MDM Config'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
        List<Map<String,Object>> failedRows = handler.getMDMProfServices(null,null);
        System.assert(failedRows.isEmpty() == true);
    }
    @isTest static void negative(){
      ProductBasketDataHandler handler = new ProductBasketDataHandler();
         // List<Map<String,Object>> rowsTCServices = handler.getTCServices(null,null);////EDGE-210438-- Code Commented
          //List<Map<String,Object>> rowsngUCDevicesOC = handler.getngUCDevicesOC(null,null);//EDGE-210438--Code Commented
         // List<Map<String,Object>> getngUCDevicesRCRental = handler.getngUCDevicesRCRental(null,null);////EDGE-210438--Code Commented
          //List<Map<String,Object>> rowsSLADetails = handler.ngUCSLADetails(null,null);////EDGE-210438--Code Commented
          List<Map<String,Object>> rowsCMPDevices=handler.getCMPDevices(null,null);
          List<Map<String,Object>> rowsParentProducts=handler.getParentProducts(null);
          List<Map<String,Object>> rowsSummaryForNewServices=handler.getSummaryForNewServices(null);
          List<Map<String,Object>> rowsSummaryForExistingServices=handler.getSummaryForChangesToExisting(null);//EDGE-148722 Negative////EDGE-155059 & EDGE-162542 Negative
         //EDGE-123788  //EDGE-123789 start
         List<Map<String,Object>> cmpServices=handler.getCMPServices(null,null);
        System.assert(cmpServices.isEmpty() == True);
        List<Map<String,Object>> rowsSummaryForNewServicesRC=handler.getSummaryForNewServicesRC(null);//EDGE-166406 Negative
        System.assert(rowsSummaryForNewServicesRC.isEmpty() == True);//EDGE-166406 Negative
        List<Map<String,Object>> rowsPromotionsApplied = handler.getPromotionsApplied(null,null);
        System.assert(rowsPromotionsApplied.isEmpty() == True);
         //EDGE-123788  //EDGE-123788 end
          //EDGE-127817 Start
          //List<Map<String,Object>> rowsSummaryForngUCCancel=handler.getngUCCancel(null,null);//EDGE-210438--Code Commented
          Integer rowsTerms = ProductBasketDataHandler.calculateRemainingTermngUC(null,null,null,null);
          System.assert(rowsTerms==null);
         // System.assert(!rowsSummaryForngUCCancel.isEmpty() == false);//EDGE-210438--Code Commented
          //EDGE-127817 End
          //System.assert(!rowsTCServices.isEmpty() == false);//EDGE-210438--Code Commented
          //System.assert(!rowsngUCDevicesOC.isEmpty() == false);//EDGE-210438--Code Commented
          //System.assert(!getngUCDevicesRCRental.isEmpty() == false);////EDGE-210438--Code Commented
         // System.assert(!rowsSLADetails.isEmpty() == false);//EDGE-210438--Code Commented
          System.assert(!rowsCMPDevices.isEmpty() == false);
          System.assert(!rowsParentProducts.isEmpty() == false);
          System.assert(!rowsSummaryForNewServices.isEmpty() == false);
          System.assert(!rowsSummaryForExistingServices.isEmpty() == false);//EDGE-148722
   }
   //EDGE - 105921 - START - CMP-Committed Offer Quote/Orderform
   //EDGE-144228 - Below function is for negative scenario for changes made as part of EDGE-144228. 
   //It should return record if there is no Fairplay plan in basket.
    @isTest static void getCMPCommittedDataSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPCommittedData(basketId,new Map<String,String>{'Query_Type'=>'CMPCommittedData','Type'=>'New'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
     System.assert(rows[0].get('Product_Module_Name') == 'Committed'); //EDGE-146809 | Filtering Committed Data PCs
        System.debug('rows[0] '+rows[0]+' Rows: '+rows);
        System.assert(rows[1].get('Bonus_Data') == '40'); //EDGE-148067 | Positive scenario
    }
    //EDGE-148067 Negative scenario
    @isTest static void getCMPCommittedDataFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPCommittedData(null,null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
    //EDGE-144228 Start - Below function is for positive scenario. 
    //The function being invoked should return zero records if basket has Fairplay plan
    @isTest static void getCMPFairplayData(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> isFairplayRecord = handler.getCMPCommittedData(basketId,new Map<String,String>{'Query_Type'=>'CMPCommittedData','Type'=>'New'});
         Test.stopTest();
         System.assert(isFairplayRecord.isEmpty() == true);
    }
    //EDGE-144228 End
    //EDGE-144779 Start
    //Below is test method for positive scenario. If the basket has pc with attribute OfferTypeString as either 'Committed Data'
    // or 'Fairplay Data' in it , the function should return zero rows. 
    @isTest static void getCMPCommittedExcludeSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        //testclass.setup();
        testclass.setupGetCMPServiceData();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> isCommittedRecord = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Modify'});
        Test.stopTest(); 
        System.assert(isCommittedRecord.isEmpty() == true);
    }
    //Below is test method for negative scenario. If the basket does not has pc with attribute OfferTypeString as either 'Committed Data'
    // or 'Fairplay Data' in it , the function should return some rows .
    @isTest static void getCMPCommittedExcludeFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        //testclass.setup();
        testclass.setupGetCMPServiceData();
        Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> isCommittedRecord = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Modify'});
         Test.stopTest();
         System.assert(isCommittedRecord.isEmpty() == false);
         system.debug('row.get@@::' + isCommittedRecord[0].get('GSTIncl_TotalETC'));
         system.assert(isCommittedRecord[0].get('GSTIncl_TotalETC') == 'N/A');
    }
    //EDGE-144779 End
    //EDGE-145184-Start
    @isTest static void getCMPFairplaySuccess(){
         ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 1100 limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> isFairPlayRecord = handler.getParentProducts(basketId);
         system.debug('isFairPlayRecord'+isFairPlayRecord);
        Test.stopTest(); 
        // EDGE-165831 - existing Assert to check check method output.
         System.assert(isFairPlayRecord.isEmpty() == false);
        System.assert(isFairPlayRecord[0].get('isCommittedData') == true);
    }
    //EDGE-EDGE-145184-End
    @isTest static void getCMPCancelProductsFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPCancelProducts(null,null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
    //EDGE - 105921 - End
           //Test method for EDGE-101077 - Quote and Order form updates for Mobility Managed Service 
   /* @isTest static void getMobiltyManagedServceDetailsTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getMobiltyManagedServceDetails(basketId,new Map<String,String>{'Query_Type'=>'Test','Offer_Name'=>'TestOffer'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    } */

    @isTest static void getTenancyDetailsTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTenancyDetails(basketId,new Map<String,String>{'Query_Type'=>'TenancyDetails','Product_Module_Name'=>'Test'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }
    @isTest static void getTelstraCollaborationMinCmmt(){//EDGE-123562
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         list<cscfga__Product_Configuration__c> prConfig = [select id, Marketable_Offer__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :prodBasket.Id and Marketable_Offer__c <> null];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();         
        List<Map<String,Object>>  rows;
        Marketable_Offer__c mOfferMSS = new Marketable_Offer__c();
        mOfferMSS.Id = prConfig[0].Marketable_Offer__c;
        mOfferMSS.Offer_ID__c = 'DMCAT_Offer_000854';
        update mOfferMSS;
        Test.startTest();// Changes by done by Napier to handle governor limit
        rows = handler.getParentProducts(basketId);       
        System.assert(rows.isEmpty() == false);
        mOfferMSS = new Marketable_Offer__c();
        mOfferMSS.Id = prConfig[0].Marketable_Offer__c;
        mOfferMSS.Offer_ID__c = 'DMCAT_Offer_000750';
        update mOfferMSS;   
        Test.stopTest();
        // Changes by done by Napier to handle governor limit.Commented below code.
  /*rows = handler.getParentProducts(basketId);       
        System.assert(rows.isEmpty() == false);     
        mOfferMSS = new Marketable_Offer__c();
        mOfferMSS.Id = prConfig[0].Marketable_Offer__c;
        mOfferMSS.Offer_ID__c = 'DMCAT_Offer_000936';
        update mOfferMSS;   
        rows = handler.getParentProducts(basketId);       
        System.assert(rows.isEmpty() == false);  */       
    }
  //EDGE-98336 - START
    @isTest static void getTIDDetailsSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTIDDetails(basketId,new Map<String,String>{'Query_Type'=>'TIDDetails','Type'=>'New'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }
    @isTest static void getgetTIDDetailsFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTIDDetails(null,null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
    //EDGE-98336 - END
      //EDGE-123788   : Display Delegated Discounts in Quote Document Test
    @isTest static void getPromotionsAppliedNewTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getPromotionsApplied(basketId,new Map<String,String>{'Query_Type'=>'PromotionsAppliedDetails','Type'=>'New'});
        Test.stopTest();
        for(Map<String,Object> returnMap:rows){
            for(String str:returnMap.keySet()){
                Object text=returnMap.get(str);
                 System.assert(text!=null);
            }
        }       
         System.assert(rows.isEmpty() == false);
    }
        //EDGE-121387, EDGE-133760 StartA
        @isTest static void getPromotionsAppliedModifyTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getPromotionsApplied(basketId,new Map<String,String>{'Query_Type'=>'PromotionsAppliedDetails','Type'=>'Modify'});
        //EDGE-121387, EDGE-133760 End
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
     //Test method for - EDGE-104681 Modify CMP
    @isTest static void getCMPServicesTestCancel(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        // testclass.setup();
        testclass.setupGetCMPServiceData();
        Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Cancel'});
        Test.stopTest(); 
         system.debug('getCMPServicesTestCanceldebug'+rows);
        System.debug('------ ROWS --> ' + rows);
        System.assertEquals(1,rows[0].get('Quantity'));//Edge-140420
         System.assert(rows.isEmpty() == false);//Edge-140420
        //EDGE-143435 START
        System.assertEquals('N/A',rows[0].get('GSTIncl_TotalETC'));
        System.assertEquals('N/A',rows[0].get('GSTExcl_TotalETC'));
        //EDGE-143435 END
    }
    //EDGE-127780 - START
    @isTest static void getTIDCancelSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTIDCancel(basketId,new Map<String,String>{'Query_Type'=>'TIDCancel','Type'=>'Cancel'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }
    @isTest static void getTIDCancelFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTIDCancel(null,null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
  //EDGE-127780
  //EDGE-123788 & EDGE-123789 Start
  @isTest static void getNewServicesSummaryRC_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(basketId);
       System.debug('getSummaryForNewServicesRC'+rows);
       Test.stopTest();
       for(Map<String,Object> returnMap:rows){
            for(String str:returnMap.keySet()){
                Object text=returnMap.get(str);
                 System.assert(text!=null);
            }
        }
      System.debug('rows@#--->'+rows);
        System.assert(rows.size()>-1);
    }
    //EDGE-123788 & EDGE-123789 end
  //EDGE-127778 - START
    @isTest static void getTIDDetailsMACSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
        String pmName = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTIDDetails(basketId,new Map<String,String>{'Query_Type'=>'TIDDetails','Type'=>'Modify'});
        Test.stopTest();
        for(Map<String,Object> newRow: rows){
            pmName = String.valueOf(newRow.get('Product_Module_Name'));
        }
        System.assert(pmName == 'Internet Direct');
    }
    @isTest static void getgetTIDDetailsMACFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getTIDDetails(null,null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
  //EDGE-127778 - End
    /*
    * Description: Data Setup Method for getting list price from Product Configuration using discount value (Strategic solution). 
    * EDGE-140501,EDGE-142033
  * Team: Napier
  * Developer: Tejes Mahajan
  */
  private void setupDataStrategicSolution() {
    List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
    CustomConfigurationOptions__c commConfig1 = new CustomConfigurationOptions__c();
    commConfig1.Name = 'ContractAccepted';
    commConfig1.Enrichment_Basket_Stage__c = 'Contract Accepted';
    commConfig1.External_Id__c = '7654';
    commConfig1.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig1);
    CustomConfigurationOptions__c commConfig2 = new CustomConfigurationOptions__c();
    commConfig2.Name = 'CommercialConfiguration';
    commConfig2.Enrichment_Basket_Stage__c = 'Commercial Configuration';
    commConfig2.External_Id__c = 'CCO4';
    commConfig2.Opportunity_Stage__c = 'Develop';
    commList.add(commConfig2);
    CustomConfigurationOptions__c commConfig3 = new CustomConfigurationOptions__c();
    commConfig3.Name = 'Quote';
    commConfig3.Enrichment_Basket_Stage__c = 'Quote';
    commConfig3.External_Id__c = 'CC08';
    commConfig3.Opportunity_Stage__c = 'Propose';
    commList.add(commConfig3);
    insert commList;          
        Account acc = AccountTestFactory.buildAccount('TestAccListPrice');
        acc.CIDN__c = '1234543210';
        acc.Customer_Status__c='Active';
        insert acc;
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000501234';
        billAcc.Account__c = acc.id;
        insert billAcc;
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Committed_Data';
        ev.value__c='True';
        insert ev;
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
    Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        //moMob.Name = 'Corporate Mobile Plus';
        moMob.Name = 'DMCAT_Offer_000646';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
    insert moMob;
    cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');

        pd.product_Specification__c='DMCAT_ProductSpecification_000657';

        insert pd;
    cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name='test';
        newConfig.Type__c = 'New';
        newConfig.cscfga__Product_Basket__c = basket.id;
        newConfig.Marketable_Offer__c = moMob.id;
        newConfig.cscfga__Product_Family__c='Enterprise Mobility';
    newConfig.cscfga__total_recurring_charge__c=100;
    newConfig.cscfga__Product_Definition__c = pd.Id;
    newConfig.cscfga__Parent_Configuration__c = null;
    newConfig.cscfga__recurring_charge_line_discount_value__c = 50.00;
        insert newConfig;        
    }
    /*
    * Description: Test Method for checking list price using discount value field on PC (Strategic solution). 
    * EDGE-140501,EDGE-142033
  * Team: Napier
  * Developer: Tejes Mahajan
  */
  @isTest static void getListPriceUsingDiscountTest(){
    ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
    testclass.setupDataStrategicSolution();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
    String basketId = '';
    if(prodBasket !=null)
        basketId = prodBasket.id;
    ProductBasketDataHandler handler = new ProductBasketDataHandler();
    List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(basketId);
    Test.stopTest();
    System.debug('rows---->'+rows);
    System.assert(rows.size()>-1);
    //System.assertEquals(rows.size()>0, true);
    //EDGE-147408 - Assert to check positive scenario.
    System.assertEquals(rows[0].get('Total_Recurring_Charges') !=null, true);
    // EDGE-158690 assert to check GSTIncl_Total_Recurring_Charges value.
    System.assertEquals(rows[0].get('GSTIncl_Total_Recurring_Charges') !=null,true);


    //System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') == 260.00);//EDGE-181157 Defect Fix Positive


}
    //EDGE-147408 & EDGE-158690 negative test.
    @isTest static void getListPriceUsingDiscountNegative_Test(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setupDataStrategicSolution();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
            basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
    //EDGE-172118 - Start
    // Negative Scenario is already covered as part of getParentProductsTestFailure method
    @isTest static void getParentProductsTestNGEM() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        Test.startTest();
        testclass.setup();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getParentProducts(basketId);
        system.debug('row@@::' + rows);


         system.debug('row.get@@::' + rows[0].get('isNGEMPlan'));
         Test.stopTest();
         system.assert(rows[0].get('Type') == true); // To dynamically display Min Commitment section
         System.assert(rows.isEmpty() == false);
     }
      //EDGE-172118 - End
    //EDGE-166406 Start Positive
    //EDGE-176737 Positive
    @isTest static void getGSTIncPriceforPC(){
    ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
    testclass.setup();
    
    cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c=1111];
    system.debug('getGSTIncPriceforPC::prodBasket::' + prodBasket);
        String basketId = '';
    if(prodBasket !=null)
      basketId = prodBasket.id;
       // List<cscfga__Product_Configuration__c> pc = [Select id,name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId];
       //system.debug('getGSTIncPriceforPC::pc::' + pc);
        Test.startTest();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
    List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(basketId);
    Test.stopTest();
    System.debug('rows---->'+rows);

   // System.assert(rows[0].get('MonthlyRCPromotionsInclGST') == 104.00); //EDGE-176688
    //System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') == 104.00);//EDGE-181157 Defect Fix Negative
    }
    //EDGE-166406 End
//EDGE-171429 - Start | Below method is to cover negative scenario
    @isTest static void getParentProductsAMNeg(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        Test.startTest();
        testclass.setup();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c=191919.19];
        system.debug('getGSTIncPriceforPC::prodBasket::' + prodBasket);
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getParentProducts(basketId);
        system.debug('row@@::' + rows);
        System.assert(rows[0].get('isNGEMNew') == null);
        System.assert(rows[0].get('isNGEMPlanNew') == null);
        System.assert(rows[0].get('isNGEMDeviceNew') == null);
        System.assert(rows[0].get('isNGEMMac') == null);
        System.assert(rows[0].get('isNGEMPlanMac') == null);
        System.assert(rows[0].get('Type') == false);//EDGE-165488 | Positive scenario
    }
    //EDGE-171429 - End
    //EDGE-165834 - Start
    @isTest static void getSummaryforTotalCharges_Test() {
        Account acc = AccountTestFactory.buildAccount('TestAccListPrice');
        acc.CIDN__c = '1234543210';
        acc.Customer_Status__c='Active';
        insert acc;
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(cscfga__Opportunity__c= opp.id,csordtelcoa__Synchronised_with_Opportunity__c =true,
        csbb__Synchronised_With_Opportunity__c =true,cscfga__Basket_Status__c = 'Valid');
        insert basket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c ='DMCAT_Offer_000646';
        insert pd;
        List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();//EDGE-200765
        cscfga__Product_Configuration__c newConfig00 = new cscfga__Product_Configuration__c(name='test',Type__c = 'New',cscfga__Product_Basket__c = basket.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,cscfga__total_one_off_charge__c=200,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null);
        //EDGE-200765 Start
    configLst.add(newConfig00);
        cscfga__Product_Configuration__c newConfig01 = new cscfga__Product_Configuration__c(name='test',Type__c = 'Active',cscfga__Product_Basket__c = basket.id,cscfga__Product_Family__c='Enterprise Mobility',cscfga__total_recurring_charge__c=100,cscfga__total_one_off_charge__c=200,cscfga__Product_Definition__c = pd.id,cscfga__Parent_Configuration__c = null);
        configLst.add(newConfig01);
        insert configLst;
    //EDGE-200765 End
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(cscfga__Product_Definition__c = pd.Id,Name = 'EarlyTerminationCharge',Snapshot_Attribute_Value_Field__c = 'Product_Module_Name__c',Snapshot_Attribute_Fields__c = 'Plan'); 
        insert ad2;
        List<cscfga__Attribute__c> attLst = new List<cscfga__Attribute__c>();//EDGE-200765
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(cscfga__Product_Configuration__c = configLst[0].Id,Name = 'EarlyTerminationCharge',
            cscfga__Value__c = '50',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = ad2.Id);
        //EDGE-200765 Start
    attLst.add(att0);
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(cscfga__Product_Configuration__c = configLst[0].Id,Name = 'RedeemFund',
            cscfga__Value__c = '10',cscfga__is_active__c = true,cscfga__Attribute_Definition__c = ad2.Id);
        attLst.add(att1);
        insert attLst;
    //EDGE-200765 End      
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getSummaryForNewCharges(basketId);
        system.debug('row@@::' + rows);
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
    //EDGE-186680 - assert to verify GSTIncl_Total_Recurring_Charges present in rows.
        System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') != 0.00);
        System.assert(rows[0].get('GSTExcl_Total_Onceoff_Charges')==240.00);//EDGE-200765 Positive Scenario
    }//EDGE-165834 - End
  //EDGE-165834 - Below is for negative test case
  //EDGE-200765 Negative Scenario
    @isTest static void getSummaryforTotalCharges_TestNegative(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getSummaryForNewCharges(null);
         System.debug('-----rows'+rows); 
        Test.stopTest();
        System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') == 0.00); //EDGE-176688
    }
    //EDGE-165834 End

    //EDGE-176737 Start Negative
    @isTest static void getGSTIncPriceforPC_Negative(){
    ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
    testclass.setup();
    Test.startTest();
    cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c=2233];
    system.debug('getGSTIncPriceforPC::prodBasket::Neg' + prodBasket);
        String basketId = '';
    if(prodBasket !=null)
      basketId = prodBasket.id;
        List<cscfga__Product_Configuration__c> pc = [Select id,name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId];
    system.debug('getGSTIncPriceforPC::pc::Neg' + pc);
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
    List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(basketId);
    Test.stopTest();
    System.debug('rows_neg-->'+rows);
    System.assert(rows[0].get('MonthlyRCPromotionsInclGST') == 110.00); //EDGE-176688
  System.assert(rows[0].get('GSTIncl_Total_Recurring_Charges') == 110.00); //EDGE-176688

    }
    //EDGE-176737 Negative End







    @isTest static void getBSMobilityTransitionTest(){//EDGE-173365
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getBSMobilityTransition(basketId);
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }
    @isTest static void getMobilityTransitionHardwareAndDevice_test(){//EDGE-175105
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
         List<Map<String,Object>> rows = handler.getMobilityTransitionHardwareAndDevice(basketId,new Map<String,String>{'Query_Type'=>'MobilityTransitionHardwareAndDevice'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }  
    //EDGE-171311 Start
    @isTest static void getNewServicesSummaryRCInfl_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        list<cscfga__Product_Configuration__c> pcLst = [select id,cscfga__total_one_off_charge__c,cscfga__total_recurring_charge__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId];
        for(cscfga__Product_Configuration__c pc:pcLst){
            pc.cscfga__total_one_off_charge__c = -10;
            pc.cscfga__total_recurring_charge__c = -10;
        }
        update pcLst;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(basketId);
        List<Map<String,Object>> rows1 = handler.getSummaryForNewCharges(basketId);
        System.debug('getSummaryForNewServicesRC'+rows);
        Test.stopTest();
        System.debug('rows@#--->'+rows);
        System.debug('rows1@#--->'+rows1);
        System.assert(rows.isEmpty() == false);
    }
    //EDGE-171311 End
        //DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
    @isTest static void getParentProductsIoTTestSuccess() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 900 limit 1];
        system.debug('prodBasket ' + prodBasket);
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getParentProducts(basketId);
        system.debug('row@@::' + rows);
        system.debug('row.get@@::' + rows[0].get('is_IOT'));
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        //System.assert(rows[0].get('is_IOT') == true);
    }
    //DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan 
   //This below code is commented because of CPU time limit Exception Optimization move the getSummaryForNewServiceRC to below method.
    /*@isTest static void getNewServicesSummaryRCIOT_Test() {
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 900 limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getSummaryForNewServicesRC(basketId);
        System.debug('getSummaryForNewServicesRC'+rows);
        Test.stopTest();
        for(Map<String,Object> returnMap:rows){
            for(String str:returnMap.keySet()){
                Object text=returnMap.get(str);
                System.assert(text!=null);
            }
        }
        System.debug('rows@#--->'+rows);
        System.assert(rows.size()>-1);
    }*/
    
    @isTest
    public static void offerWiseRedeemedAmountListTest(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        testclass.setup();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 900 limit 1];
        cscfga__Product_Configuration__c configuration=[SELECT id,cscfga__Product_Basket__c,Offername__c from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =:prodBasket.Id  limit 1];
        cscfga__Attribute_Definition__c attributedefinis=[SELECT id from cscfga__Attribute_Definition__c limit 1];
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configuration.Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        insert att0;
        
        Test.startTest();
        
        new ProductBasketDataHandler().offerWiseRedeemedAmountList(prodBasket.Id, configuration.OfferName__c);
        List<Map<String,Object>> rows = new ProductBasketDataHandler().getSummaryForNewServicesRC(prodBasket.Id);
        for(Map<String,Object> returnMap:rows){
            for(String str:returnMap.keySet()){
                Object text=returnMap.get(str);
                System.assert(text!=null);
            }
        }
        Test.stopTest();
    }
   
    
   @isTest
    public static void getCMPDevices_CancelScenarioTest(){
        /* ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
testclass.setup();*/
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        //EDGE-127817 Start
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        //billAcc.name = 'BA-0004772';
        billAcc.Account__c = acc.id;
        insert billAcc;
        
         Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Product_Basket__c pbIoTBasket = ProductTestFactory.buildEmptyBasket();
        pbIoTBasket.cscfga__Opportunity__c = opp.id;
        pbIoTBasket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        pbIoTBasket.csbb__Synchronised_With_Opportunity__c =true;
        pbIoTBasket.cscfga__Basket_Status__c = 'Valid';
        pbIoTBasket.cscfga__total_contract_value__c = 900;
        insert pbIoTBasket;
        
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_001342';
        insert pd1;
        cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd1.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges__c',
            Snapshot_Attribute_Fields__c = 'Device'

        );
        insert ad;
        
        
        cscfga__Product_Basket__c prodBasket =pbIoTBasket;
        
        cscfga__Product_Configuration__c replacedConfig01 = new cscfga__Product_Configuration__c();
        replacedConfig01.name='Replaced Product Configuration record';
        replacedConfig01.cscfga__Product_Definition__c=pd1.id;
        replacedConfig01.cscfga__Product_Basket__c=prodBasket.id;
        replacedConfig01.cscfga__Description__c = 'test Description';
        replacedConfig01.cscfga__Contract_Term__c = 36;
        replacedConfig01.Commercial_Config__c='Yes';
        replacedConfig01.Quantity_Product_Configuration__c=1;
        replacedConfig01.cscfga__total_one_off_charge__c=100;
        replacedConfig01.cscfga__total_recurring_charge__c=100;
        insert replacedConfig01;
        
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name='Replaced Product Configuration record';
        replacedConfig.cscfga__Product_Definition__c=pd1.id;
        replacedConfig.cscfga__Product_Basket__c=prodBasket.id;
        replacedConfig.cscfga__Description__c = 'test Description';
        replacedConfig.cscfga__Contract_Term__c = 36;
        replacedConfig.Commercial_Config__c='Yes';
        replacedConfig.Quantity_Product_Configuration__c=1;
        replacedConfig.cscfga__total_one_off_charge__c=100;
        replacedConfig.cscfga__total_recurring_charge__c=100;
        replacedConfig.Type__c='Cancel';
        replacedConfig.csordtelcoa__Replaced_Product_Configuration__c=replacedConfig01.Id;
        insert replacedConfig;
        
        cscfga__Attribute_Definition__c attributedefinis=ad;
        
        
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = replacedConfig.Id,
            Name = 'RedeemFund',
            cscfga__Value__c = 'True',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        insert att0;
       /*  cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = replacedConfig.Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        insert att1;*/
         ProductBasketDataHandler.sortPriceItem ins=new ProductBasketDataHandler.sortPriceItem();
        ins.Range_From=10;
        ins.Range_To=10;
        ins.Feature_Level='test';
        ins.Techinical_Support='test01';
        ins.Rate=10.01;
        ins.Unit_Of_Measure='test';
        ins.compareTo(ins);
        Test.startTest();
        new ProductBasketDataHandler().getCMPCommittedData(prodBasket.id, new Map<String,String>{'Type'=>'Modify'});
        new ProductBasketDataHandler().getCMPCommittedData(prodBasket.id, new Map<String,String>{'Type'=>'Cancel'});
        Test.stopTest();
    }

    
    
   @isTest
    public static void getSummaryForNewServices_Test(){
       ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        testclass.setup();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 900 limit 1];
          cscfga__Attribute_Definition__c attributedefinis=[SELECT id from cscfga__Attribute_Definition__c limit 1];
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_001211';
        insert pd1;
        Marketable_Offer__c momdm = new Marketable_Offer__c();
        momdm.OfferDefinationName__c ='MDM Tenancy' ;
        momdm.Name = 'Test MOdfs';
        //momdm.Offer_ID__c = 'D12sd333s';
          momdm.Offer_ID__c = 'DMCAT_Offer_000681';
        insert momdm;
        List<cscfga__Product_Configuration__c> listofpcs=new List<cscfga__Product_Configuration__c>();
          cscfga__Product_Configuration__c replacedConfig01 = new cscfga__Product_Configuration__c();
        replacedConfig01.name=' Product Configuration record';
        replacedConfig01.cscfga__Product_Definition__c=pd1.id;
        replacedConfig01.cscfga__Product_Basket__c=prodBasket.id;
        replacedConfig01.Marketable_Offer__c=momdm.id;
        replacedConfig01.cscfga__Description__c = 'test Description';
        replacedConfig01.cscfga__Contract_Term__c = 36;
        replacedConfig01.Commercial_Config__c='Yes';
        replacedConfig01.Quantity_Product_Configuration__c=1;
        replacedConfig01.cscfga__total_one_off_charge__c=100;
        replacedConfig01.cscfga__total_recurring_charge__c=100;
        insert replacedConfig01; //insert parent;
        
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name='Replaced Product Configuration record';
        replacedConfig.cscfga__Product_Definition__c=pd1.id;
        replacedConfig.cscfga__Product_Basket__c=prodBasket.id;
        replacedConfig.cscfga__Description__c = 'test Description';
        replacedConfig.cscfga__Contract_Term__c = 36;
        replacedConfig.Commercial_Config__c='Yes';
        replacedConfig.Type__c='New';
        replacedConfig.Quantity_Product_Configuration__c=1;
        replacedConfig.cscfga__total_one_off_charge__c=100;
        replacedConfig.cscfga__total_recurring_charge__c=100;
        replacedConfig.cscfga__Parent_Configuration__c=replacedConfig01.Id;
        insert replacedConfig;
        List<cscfga__Attribute__c> listAtts=new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = replacedConfig.Id,
            Name = 'PaymentTypeString',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        listAtts.add(att0);
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = replacedConfig.Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        listAtts.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = replacedConfig.Id,
            Name = 'PaymentTypeShadow',
            cscfga__Value__c = 'Purchase',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        listAtts.add(att2);
        
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = replacedConfig.Id,
            Name = 'RedeemFund',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = attributedefinis.Id
        );
        listAtts.add(att3);
        insert listAtts;
        
        /*
                cscfga__Product_Basket__c= :basketId 
                       and cscfga__Product_Definition__r.product_Specification__c IN :productSpecCodes 
                       and (Type__c='New' OR Type__c='CHOWN') 
                        AND (cscfga__Parent_Configuration__c= null OR cscfga__Product_Definition__r.product_Specification__c =: ngemDeviceCare)]
*/
        Test.startTest();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        List<Map<String,Object>> rows = handler.getSummaryForNewServices(prodBasket.Id);
        List<Map<String,Object>> rows01 = handler.getSummaryForNewCharges(prodBasket.Id);
        Test.stopTest();
    } 
    

}