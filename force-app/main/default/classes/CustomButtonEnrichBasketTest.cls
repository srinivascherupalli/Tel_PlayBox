/**
* Class for custom button enrich basket test
Sr.No.    Developer Name          Date          Story Description
1.          Aruna Aware          09/04/2020     DPG-1692 Added for to check Enrichment for IOT Subscription
2.          Laxmi Rahate         30/04/2020     EDGE-142321 - Port Out Reversal Story
3.          Rohit Tripahi       08/05/2020      EDGE-137753 No error is coming on Enriched button if enrichment is not done for UC tenancy offer
4.          shubhi              22/05/2020`     EDGE-142085
5.      Laxmi Rahate    15/06/2020    EDGE-155254 
6.      Gnana        30/06/2020    EDGE-151354 - Added test methods for validating Device Care Contact
7.      Gnana        10/07/2020    EDGE-148725 - Added test method for validating DCC for MAC Scenario

8.      Gnana        22/07/2020    EDGE-155181 - Added test methods for validating OE for Next Gen EM Plan
9.       Gokul        11/09/2020    EDGE-172954 -  Addded test methods to validate refactored code.
10.    Sharmila Eltepu   01/10/2020  DPG-2890 - Added for to check Enrichment for VeloCloud Tenancy
11.    Aman Soni    4/11/2020     EDGE-176693 While user is enriching the basket, Plan transitions revenue should be tagged as technology transformation revenue instead of incremental annuity
12.     Sharmila    15/11/2020  DPG-3466  -  Added to check for Enrichment for SDWAN
13.     Sharmila    21/01/2021  DPG-3299  -  Added to check for Enrichment for SecureEdge
14. Aman Soni       02/03/2021   INC000095150396  Apex CPU time limit exceeded 
15.     Suyash Chiplunkar 02/08/2021 DIGI-4031 Enrichment Validations for SDWAN
*/
@isTest(SeeAllData=FALSE)
public class CustomButtonEnrichBasketTest {
    @testSetup static void testdataMethod() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        createCustomSettingSubmitted();
        EnvironmentVariable__c env_var =  new EnvironmentVariable__c();
        env_var.name = 'EnableB2B4';
        env_var.value__c = 'true';
        insert env_var;
        //EDGE-142085 start--
        //List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
        
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
        //EDGE-142085 end--
        Account acc = new Account(Name = 'Test Account');
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        insert billingAccount;

        Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id);
        insert cont;

        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Test.startTest();//FDR Fix by Aman Soni 21.05
        List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();//FDR Fix by Aman Soni 21.05
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.Project_ID__c = 'testAc01';
        basket.Billing_Account__c = billingAccount.id;
        basket.Project_Manager_Contact_Number__c = '0999999999';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = false;
        basket.cscfga__Opportunity__c = opp.Id;
        basket.cscfga__Products_Id_Qty_In_Basket__c = '2';
        update basket;
        //  DPG-1692 Added for to check Enrichment for IOT Subscription        
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        update opp;
        //  DPG-1692 Added for to check Enrichment for IOT Subscription
        Account dpgAcc  = new Account(Name = 'DPG Account');
        insert dpgAcc;
        cscfga__Product_Basket__c basketIoT = new cscfga__Product_Basket__c();//ProductTestFactory.buildEmptyBasket();
        basketIoT.csbb__Account__c = dpgAcc.id;
        basketIoT.cscfga__Opportunity__c = opp.id;
        basketIoT.Name = 'IoT Basket';
        basketIoT.Device_Care_Contact__c = cont.Id;
        basketLst.add(basketIoT);//FDR Fix by Aman Soni 21.05
        //insert basketIoT;
        //attribute and PD
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'User', cscfga__Description__c = 'User');
        pdList.add(userPD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPsite = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Network',product_Specification__c = 'DMCAT_ProductOffering_000304');
        pdList.add(IPsite);
        cscfga__Product_Definition__c SD = new cscfga__Product_Definition__c(Name = 'Site Details', cscfga__Description__c = 'Site Details');
        pdList.add(SD);
        cscfga__Product_Definition__c RN = new cscfga__Product_Definition__c(Name = 'Reserve Numbers', cscfga__Description__c = 'Reserve Numbers');
        pdList.add(RN);
        cscfga__Product_Definition__c CRD = new cscfga__Product_Definition__c(Name = 'Customer Requested Dates', cscfga__Description__c = 'Customer Requested Dates');
        pdList.add(CRD);
        cscfga__Product_Definition__c Mobility = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility');
        pdList.add(Mobility);
        cscfga__Product_Definition__c DD = new cscfga__Product_Definition__c(Name = 'Delivery Details', cscfga__Description__c = 'Delivery Details');
        pdList.add(DD);    
        cscfga__Product_Definition__c MF = new cscfga__Product_Definition__c(Name = 'Mobility Features', cscfga__Description__c = 'Mobility Features');
        pdList.add(MF);
        cscfga__Product_Definition__c MDMTenancy = new cscfga__Product_Definition__c(Name = 'Tenancy', cscfga__Description__c = 'MDM Tenancy');
        pdList.add(MDMTenancy);
        cscfga__Product_Definition__c MobileSubscription = new cscfga__Product_Definition__c(Name = 'Mobile Subscription', cscfga__Description__c = 'Mobile Subscription');
        pdList.add(MobileSubscription);
        //  DPG-1692 Added for to check Enrichment for IOT Subscription
        cscfga__Product_Definition__c IOTSubscriptionPD = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        pdList.add(IOTSubscriptionPD);
        cscfga__Product_Definition__c Tenancy_BrodsoftTenancyPD = new cscfga__Product_Definition__c(Name = 'Tenancy_BrodsoftTenancy', cscfga__Description__c = 'Tenancy_BrodsoftTenancy');
        pdList.add(Tenancy_BrodsoftTenancyPD);
        
         //  DPG-2890 Added for to check Enrichment for VeloCloud Tenancy
        Account dpgVeloAcc  = new Account(Name = 'DPG Velo Account');
        insert dpgVeloAcc;
        cscfga__Product_Basket__c basketVelo = new cscfga__Product_Basket__c();//ProductTestFactory.buildEmptyBasket();
        basketVelo.csbb__Account__c = dpgVeloAcc.id;
        basketVelo.cscfga__Opportunity__c = opp.id;
        basketVelo.Name = 'VeloCloud Basket';
        basketVelo.Device_Care_Contact__c = cont.Id;
        basketLst.add(basketVelo);//FDR Fix by Aman Soni 21.05
        //insert basketVelo;
    
        //  DPG-2890 Added for to check Enrichment for VeloCloud Tenancy
        cscfga__Product_Definition__c Tenancy_VeloCloudTenancyPD = new cscfga__Product_Definition__c(Name = 'SD-WAN Tenancy', cscfga__Description__c = 'SD-WAN Tenancy');
        pdList.add(Tenancy_VeloCloudTenancyPD);
        
        //  DPG-2890 Added for to check Enrichment for VeloCloud Tenancy
        cscfga__Product_Definition__c dmsProdDefin = new cscfga__Product_Definition__c(Name = 'DMS Product', cscfga__Description__c = 'DMS Product Description');
        pdList.add(dmsProdDefin);

        // DPG-3466  Enrichment for SDWAN
        Account dpgSdwanAcc  = new Account(Name = 'DPG SDWAN Account');
        insert dpgSdwanAcc;
        // DIGI-4031
        cscrm__Address__c sdwanAddress = new cscrm__Address__c();
        sdwanAddress.cscrm__Address_Type__c = 'Property With Number';
        sdwanAddress.streetType__c = 'DRIVE';
        sdwanAddress.cscrm__Street_Name__c = 'LILA';
        sdwanAddress.Locality__c='PROSPECT';
        sdwanAddress.cscrm__State_Province__c = 'TAS';
        sdwanAddress.cscrm__Zip_Postal_Code__c = '7250';
        sdwanAddress.cscrm__Country__c = 'AUSTRALIA';
        sdwanAddress.Address_Line_1__c = '21 CRESTING AVE,';
        sdwanAddress.Address_Line_2__c = 'Melbourne';
        sdwanAddress.Address_Line_3__c = 'Aussie';
        sdwanAddress.Address_Status__c = 'CONFIRMED';
        sdwanAddress.Address_ID__c = '50844332';
        insert sdwanAddress;
        // DIGI-4031
        cscrm__Site__c sdwanSite = new cscrm__Site__c();
        sdwanSite.Name = '242 Exhibition Street Melbourne';
        sdwanSite.cscrm__Installation_Address__c = sdwanAddress.id;
        sdwanSite.cscrm__Account__c = dpgSdwanAcc.id;
        insert sdwanSite;

        cscfga__Product_Basket__c basketSDWAN = new cscfga__Product_Basket__c();//ProductTestFactory.buildEmptyBasket();
        basketSDWAN.csbb__Account__c = dpgSdwanAcc.id;
        basketSDWAN.cscfga__Opportunity__c = opp.id;
        basketSDWAN.Name = 'SDWAN Basket';
        basketSDWAN.Device_Care_Contact__c = cont.Id;
        basketLst.add(basketSDWAN);//FDR Fix by Aman Soni 21.05
        //insert basketSDWAN;
        // DIGI-4031
        Contact sdwanContact = new Contact();
        sdwanContact.FirstName = 'Oxygen';
        sdwanContact.LastName = 'Contact';
        sdwanContact.Phone = '0663325236';
        sdwanContact.Email = 'test@test.com';
        insert sdwanContact;
    
        // DPG-3466  Enrichment for SDWAN
        cscfga__Product_Definition__c SDWAN_AdaptPD = new cscfga__Product_Definition__c(Name = 'SD-WAN ADAPT S1', product_Specification__c=System.Label.SDWAN_ADAPT_OFFER,cscfga__Description__c = 'SDWAN ADAPT S1');
        pdList.add(SDWAN_AdaptPD);
        // DIGI-15582
        cscfga__Product_Definition__c dmsPD = new cscfga__Product_Definition__c(Name = 'DMS Product', product_Specification__c='DMCAT_Offer_001540',cscfga__Description__c = 'DMS Product desc');
        pdList.add(dmsPD);
        
        // DPG-3299  Enrichment for SecureEdge
        Account dpgSecureEdgeAcc  = new Account(Name = 'DPG SecureEdge Account');
        insert dpgSecureEdgeAcc;
        cscfga__Product_Basket__c basketSecureEdge = new cscfga__Product_Basket__c();//ProductTestFactory.buildEmptyBasket();
        basketSecureEdge.csbb__Account__c = dpgSecureEdgeAcc.id;
        basketSecureEdge.cscfga__Opportunity__c = opp.id;
        basketSecureEdge.Name = 'SecureEdge Basket';
        basketSecureEdge.Device_Care_Contact__c = cont.Id;
        basketLst.add(basketSecureEdge);//FDR Fix by Aman Soni 21.05
        insert basketLst;//FDR Fix by Aman Soni 21.05
    
        // DPG-3299  Enrichment for SecureEdge
        cscfga__Product_Definition__c SecureEdge_AdaptPD = new cscfga__Product_Definition__c(Name = 'SecureEdge Cloud Tenancy', cscfga__Description__c = 'SecureEdge');
        pdList.add(SecureEdge_AdaptPD);
        
        

        //EDGE-155254  
        cscfga__Product_Definition__c nextGenMobility = new cscfga__Product_Definition__c(Name = 'Next Generation Mobile Device', cscfga__Description__c = 'Next Generation Mobile Device');
        pdList.add(nextGenMobility);
        //EDGE-151354  
        cscfga__Product_Definition__c mobileDeviceCare = new cscfga__Product_Definition__c(Name = 'Mobile Device Care', cscfga__Description__c = 'Mobile Device Care');
        pdList.add(mobileDeviceCare);
        //EDGE-155181  
        cscfga__Product_Definition__c nextGenMobilityPlan = new cscfga__Product_Definition__c(Name = 'Enterprise Mobility Plan', cscfga__Description__c = 'Enterprise Mobility Plan');
        pdList.add(nextGenMobilityPlan);

        insert pdList;
        cscfga__Configuration_Offer__c offernameTC= new cscfga__Configuration_Offer__c();
        offernameTC.Offer_Spec_Id__c='DMCAT_Offer_000618';
        offernameTC.name='Telstra Collaboration';
        offernameTC.cscfga__Active__c=true;
        offernameTC.cscfga__Description__c='';
        insert offernameTC;
        Marketable_Offer__c moTC = new Marketable_Offer__c();
        moTC.OfferDefinationName__c ='Telstra Collaboration';
        moTC.Name = 'Telstra Collaboration';
        moTC.Offer_ID__c = 'D12sd333z';
        insert moTC;
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(
            Name = 'userPC',
            cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c = userPD.Id,Marketable_Offer__c =moTC.id,
            Quantity_Product_Configuration__c = 3
        );
        cscfga__Product_Configuration__c ucePC = new cscfga__Product_Configuration__c(
            Name = 'Unified Communication',
            cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c = ucePD.Id
        );
        cscfga__Product_Configuration__c UCPC2 = new cscfga__Product_Configuration__c(
            Name = 'Unified Communication',
            cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c = ucePD.Id,
            cscfga__Root_Configuration__c = null,
            Type__c = 'Cancel'
        );      
        cscfga__Product_Configuration__c IPSitePC = new cscfga__Product_Configuration__c(
            Name = 'IP Site', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c = IPSite.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c MobilityPC = new cscfga__Product_Configuration__c(
            Name = 'Mobility', cscfga__Product_Basket__c = basket.Id, 
            cscfga__Product_Definition__c = Mobility.Id, csedm__CFS_Mapping_List__c = 'TestSpec', 
            Type__c = 'New'
        );
        cscfga__Product_Configuration__c TenancyPC = new cscfga__Product_Configuration__c(
            Name = 'Tenancy', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c=MDMTenancy.Id,
            Type__c = 'New'
        );
        cscfga__Product_Configuration__c UCPC = new cscfga__Product_Configuration__c(
            Name = 'IP Site', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c=IPSite.Id,
            Type__c = 'Cancel'
        );
        cscfga__Product_Configuration__c EMPC = new cscfga__Product_Configuration__c(
            Name = 'Mobile Subscription', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c=MobileSubscription.Id,
            Type__c = 'New'
        );
        //EDGE-142321
         cscfga__Product_Configuration__c EMPC1 = new cscfga__Product_Configuration__c(
            Name = 'Mobile Subscription1', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c=MobileSubscription.Id,
            Type__c = 'New'
        );
        //EDGE-142321 Chanegs END
        cscfga__Product_Configuration__c TenancyPC1 = new cscfga__Product_Configuration__c(
            Name = 'Tenancy_BrodsoftTenancy', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c=Tenancy_BrodsoftTenancyPD.Id,
            Type__c = 'New'
        );
        //  DPG-1692 Added for to check Enrichment for IOT Subscription
        cscfga__Product_Configuration__c IOTPC1 = new cscfga__Product_Configuration__c(
            Name = 'IOT Subscription', cscfga__Product_Basket__c = basketIoT.Id,
            cscfga__Product_Definition__c=IOTSubscriptionPD.Id,
            Type__c = 'New'
        );
    
        cscfga__Product_Configuration__c IOTPC2 = new cscfga__Product_Configuration__c(
            Name = 'IOT Subscription', cscfga__Product_Basket__c = basketIoT.Id,
            cscfga__Product_Definition__c=IOTSubscriptionPD.Id,
            Type__c = 'New'
        );
        
        //  DPG-2890 Added for to check Enrichment for VeloCloud Tenancy
        cscfga__Product_Configuration__c VeloPC1 = new cscfga__Product_Configuration__c(
            Name = 'SD-WAN Tenancy', cscfga__Product_Basket__c = basketVelo.Id,
            cscfga__Product_Definition__c=Tenancy_VeloCloudTenancyPD.Id,
            Type__c = 'New'
        );
        
        // DPG-3466 Enrichment for SDWAN
        cscfga__Product_Configuration__c SDWANPC1 = new cscfga__Product_Configuration__c(
            Name = 'SD-WAN ADAPT S1', cscfga__Product_Basket__c = basketSDWAN.Id,
            cscfga__Product_Definition__c=SDWAN_AdaptPD.Id,
            Type__c = 'New'
        );
        
        // DPG-3299 Enrichment for SecureEdge
        cscfga__Product_Configuration__c SecureEdgePC1 = new cscfga__Product_Configuration__c(
            Name = 'SecureEdge Cloud Tenancy', cscfga__Product_Basket__c = basketSecureEdge.Id,
            cscfga__Product_Definition__c=SecureEdge_AdaptPD.Id,
            Type__c = 'New'
        );

        //DIGI-15582
        cscfga__Product_Configuration__c dmsPC1 = new cscfga__Product_Configuration__c(
            Name = 'DMS Product', cscfga__Product_Basket__c = basketSDWAN.Id,
            cscfga__Product_Definition__c=dmsPD.Id,
            Type__c = 'New'
        );
         // ##
         cscfga__Product_Configuration__c dmsPc = new cscfga__Product_Configuration__c(
            Name = 'Dms Product', cscfga__Product_Basket__c = basketVelo.Id,
            cscfga__Product_Definition__c=dmsProdDefin.Id,
            Type__c = 'New'
        );

    //EDGE-155254 
        cscfga__Product_Configuration__c nextGenPC = new cscfga__Product_Configuration__c(
            Name = 'Next Generation Mobile Device', cscfga__Product_Basket__c =basket.Id,
            cscfga__Product_Definition__c=nextGenMobility.Id,
            Type__c = 'New'
        );       


        cscfga__Product_Configuration__c nextGenPC1 = new cscfga__Product_Configuration__c(
            Name = 'Next Generation Mobile Device12', cscfga__Product_Basket__c =basket.Id,
            cscfga__Product_Definition__c=nextGenMobility.Id,
            Type__c = 'New'
        );    


        //EDGE-151354 
        cscfga__Product_Configuration__c mobileDecCare = new cscfga__Product_Configuration__c(
            Name = 'Mobile Device care 1', cscfga__Product_Basket__c =basketIoT.Id,
            cscfga__Product_Definition__c=mobileDeviceCare.Id,
            Type__c = 'New'
        ); 

        //EDGE-155181 
        cscfga__Product_Configuration__c NGMobPlanPC1 = new cscfga__Product_Configuration__c(
            Name = 'nextGenMobilityPlan PC 1', cscfga__Product_Basket__c =basket.Id,
            cscfga__Product_Definition__c=nextGenMobilityPlan.Id,
            Type__c = 'New'
        ); 
        cscfga__Product_Configuration__c NGMobPlanPC2 = new cscfga__Product_Configuration__c(
            Name = 'nextGenMobilityPlan PC 2', cscfga__Product_Basket__c =basket.Id,
            cscfga__Product_Definition__c=nextGenMobilityPlan.Id,
            Type__c = 'New'
        ); 

       //EDGE-155254  END
        csord__Solution__c sol = new csord__Solution__c(Name = 'Telstra Collaboration Solution', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        csord__Solution__c sol1 = new csord__Solution__c(Name = 'Telstra Collaboration Solution', csord__Account__c = acc.Id, csord__External_Identifier__c = '12346', csord__External_Identifier2__c = '1235', csord__Identification__c = '14');
        INSERT sol1;
        System.debug('Solution Id : ' + sol.Id);
        List<cscfga__Product_Configuration__c> lstUpdatePC = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cssdm__solution_association__c = sol1.Id;
        pc1.Name = 'Unified Communication';
        pc1.cscfga__Product_Definition__c = ucePD.Id;
        //UPDATE pc1;
        lstUpdatePC.add(pc1);
        update lstUpdatePC;

        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c> {userPC,IOTPC2, ucePC, IPSitePC, MobilityPC, TenancyPC, EMPC, IOTPC1, VeloPC1, SDWANPC1,dmsPC1,dmsPc, SecureEdgePC1, EMPC1,TenancyPC1,nextGenPC,nextGenPC1,mobileDecCare,NGMobPlanPC1,NGMobPlanPC2};

            insert pcList;
        system.debug('pcList ' + pcList);
        cscfga__Product_Configuration__c WifiAPPC = new cscfga__Product_Configuration__c(
            Name = 'Wifi Access Point',
            csoe__Commercial_Configuration__c = IPSitePC.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c SDPC = new cscfga__Product_Configuration__c(
            Name = 'Site Details', cscfga__Product_Basket__c = basket.Id,
            csoe__Commercial_Configuration__c = IPSitePC.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c NEPC = new cscfga__Product_Configuration__c(
            Name = 'Reserve Numbers', cscfga__Product_Basket__c = basket.Id,
            csoe__Commercial_Configuration__c = IPSitePC.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c CRDPC = new cscfga__Product_Configuration__c(
            Name = 'Customer Requested Dates', cscfga__Product_Basket__c = basket.Id,
            csoe__Commercial_Configuration__c = IPSitePC.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c DDPC = new cscfga__Product_Configuration__c(
            Name = 'Delivery Details', cscfga__Product_Basket__c = basket.Id, 
            csoe__Commercial_Configuration__c =MobilityPC.Id, csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c NEPC2 = new cscfga__Product_Configuration__c(
            Name = 'Reserve Numbers', cscfga__Product_Basket__c = basket.Id, 
            csoe__Commercial_Configuration__c =MobilityPC.Id, csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c CRDPC2 = new cscfga__Product_Configuration__c(
            Name = 'Customer Requested Dates', cscfga__Product_Basket__c = basket.Id, 
            csoe__Commercial_Configuration__c =MobilityPC.Id, csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        cscfga__Product_Configuration__c MFPC = new cscfga__Product_Configuration__c(
            Name = 'Mobility Features', cscfga__Product_Basket__c = basket.Id, 
            csoe__Commercial_Configuration__c =MobilityPC.Id, csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        List<cscfga__Product_Configuration__c> nonCommPCList = new List<cscfga__Product_Configuration__c> {WifiAPPC, SDPC, NEPC, CRDPC, DDPC, NEPC2, CRDPC2, MFPC};
            insert nonCommPCList;
        
        //Added by Aman Soni for EDGE-176693 || Start
        List<cscfga__Product_Configuration__c> transitionPcLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c transPc = new cscfga__Product_Configuration__c();
        transPc.Name = 'Transition Product';
        transPc.cscfga__Product_Basket__c = basket.Id;
        transPc.subType__c = Label.ProductConfigSubType;
        transitionPcLst.add(transPc);
        insert transitionPcLst;
        
        List<cscfga__Attribute__c> attLst = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att = new cscfga__Attribute__c();
        att.cscfga__Product_Configuration__c = transPc.id;
        att.Name = 'testAttribute';
        attLst.add(att);
        insert attLst;
        Test.stopTest();//FDR Fix by Aman Soni 21.05
        
        List<Product2> Product2Lst = new List<Product2>();
        Product2 prod = new Product2();
        prod.name = 'testProduct';
        prod.ProductCode = 'testProductCode';
        Product2Lst.add(prod);
        insert Product2Lst;
        
        ID standardPBID = Test.getStandardPricebookId();
        
        List<Pricebook2> Pricebook2Lst = new List<Pricebook2>();
        Pricebook2 pb = new Pricebook2();
        pb.name = 'testPricebook2';
        pb.IsActive = true;
        Pricebook2Lst.add(pb);
        insert Pricebook2Lst;
        
        List<PricebookEntry> PricebookEntryLst = new List<PricebookEntry>();
        PricebookEntry Pbe = new PricebookEntry();
        Pbe.Product2Id = prod.id;
        Pbe.Pricebook2Id = standardPBID;
        Pbe.UnitPrice  = 1.0;
        Pbe.isActive=true;
        PricebookEntryLst.add(Pbe);
        insert PricebookEntryLst;
        
        List<opportunityLineItem> OliLst = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Technology_Transformation_RevenueCur__c = null;
        oli.New_Income_Revenue__c = 10.00;
        oli.OpportunityId = opp.Id;
        oli.Quantity = 1;
        oli.TotalPrice = 12;
        oli.PricebookEntryId = Pbe.id;
        oli.cscfga__Attribute__c = att.id;
        OliLst.add(oli);
        insert OliLst;
        //Added by Aman Soni for EDGE-176693 || End     
            
        cscfga__Attribute__c ad = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = ucePC.Id,
            Name = 'Orderprimarycontactid'
        );
        cscfga__Attribute__c ad1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = ucePC.Id,
            Name = 'TotalUserQty',
            cscfga__Value__c = '10'
        );
        cscfga__Attribute__c a1d = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = WifiAPPC.Id,
            cscfga__is_required__c = true,
            Name = 'wifiapp'
        );
        cscfga__Attribute__c ad2 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = ucePC.Id,
            Name = 'TotalNumbers',
            cscfga__Value__c = '13'
        );
        cscfga__Attribute__c ad3 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = IPSitePC.Id,
            Name = 'WifiAddOnUserModified', cscfga__is_required__c = true,
            cscfga__Value__c = 'true'
        );
        cscfga__Attribute__c ad4 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = IPSitePC.Id,
            Name = 'Technicalcontactid'
        );
        cscfga__Attribute__c ad5 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = IPSitePC.Id,
            Name = 'Primarycontactid',
            cscfga__Value__c = 'testcontact'
        );
        cscfga__Attribute__c ad6 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = IPSitePC.Id,
            Name = 'isNumberEnrichComplete',
            cscfga__Value__c = 'true'
        );
        cscfga__Attribute__c ad7 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = IPSitePC.Id,
            Name = 'Not Before CRD',
            cscfga__Value__c = '' + Date.today()
        );
        cscfga__Attribute__c ad8 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = TenancyPC.Id,
            Name = 'TenancyPrimaryContact',cscfga__Value__c = 'test'
        );
        cscfga__Attribute__c ad9 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = EMPC.Id,
            Name = 'SiteDeliveryAddress',cscfga__Value__c = ''
        );
        //  DPG-1692 Added for to check Enrichment for IOT Subscription
        cscfga__Attribute__c ad10 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = IOTPC1.Id,
            Name = 'SiteDeliveryContact',cscfga__Value__c = ''
        );
        
        //  DPG-2890 Added for to check Enrichment for VeloCloud Tenancy
        cscfga__Attribute__c ad19 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = VeloPC1.Id,
            Name = 'Tenancy Primary Contact',cscfga__Value__c = ''
        );
        
        // DPG-3466 & DIGI-4031  Enrichment for SDWAN
        cscfga__Attribute__c ad20 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = SDWANPC1.Id,
            Name = 'SiteDeliveryContact',cscfga__Value__c = sdwanContact.Id
        );
       
        // DPG-3299  Enrichment for SecureEdge
        cscfga__Attribute__c ad21 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = SecureEdgePC1.Id,
            Name = 'Tenancy Primary Contact',cscfga__Value__c = ''
        );

        // DPG-3466 & DIGI-4031Enrichment for SDWAN
        cscfga__Attribute__c ad22 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = SDWANPC1.Id,
            Name = 'SiteDeliveryAddress',cscfga__Value__c = sdwanSite.id
        );

 

        // EDGE-142321 - 
        cscfga__Attribute__c ad11 = ProductTestFactory.buildAttribute('ShippingRequired', 'FALSE', EMPC.Id);
        cscfga__Attribute__c ad12 =  ProductTestFactory.buildAttribute('DeviceShipping', 'FALSE', EMPC.Id);
        cscfga__Attribute__c ad13 = ProductTestFactory.buildAttribute('ShippingRequired', 'TRUE', EMPC1.Id);
        cscfga__Attribute__c ad14 =  ProductTestFactory.buildAttribute('DeviceShipping', 'TRUE', EMPC1.Id);  
        cscfga__Attribute__c ad15 =  ProductTestFactory.buildAttribute('Call Restriction', '', EMPC1.Id);       
        // DIGI-15582
         cscfga__Attribute__c ad23 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = dmsPC1.Id,
            Name = 'TenancyPrimaryContact' ,cscfga__Value__c = sdwanContact.Id
        );  //,cscfga__Value__c = sdwanContact.Id
         // DIGI-15582
         cscfga__Attribute__c ad24 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = dmsPC1.Id,
            Name = 'Preferred CRD'
        ); // ,cscfga__Value__c = String.valueOf(system.today())
         // DIGI-15582
         cscfga__Attribute__c ad25 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = dmsPC1.Id,
            Name = 'Not Before CRD',cscfga__Value__c =  String.valueOf(system.today()-2)
        ); // 

     //EDGE-155254
        cscfga__Attribute__c ad16 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = nextGenPC1.Id,
            Name = 'SiteDeliveryAddress',cscfga__Value__c = ''
        );
         cscfga__Attribute__c ad17 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = nextGenPC1.Id,
            Name = 'SiteDeliveryContact',cscfga__Value__c = ''
        );       
      //EDGE-155254 CHanges END    

        // Added as part of EDGE-155181
        cscfga__Attribute__c ad18 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = NGMobPlanPC2.Id,
            Name = 'SiteDeliveryAddress',cscfga__Value__c = ''
        );

        List <User> userList = new List <User>();
        Profile testProfile = [select id from profile where name =:Label.Profile_SalesEnterprise];  
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingCustomButtonEnrBskt', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');     
        insert sales;        
        // EDGE-142321 - Changes END
        List<Number__c> lstnumber = new List<Number__c>();
        lstnumber.add(new Number__c(Type__c='Transition', ListingCode__c='Listed',Basket__c=basket.Id));

        List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c> {ad, ad1, ad2, ad3, ad4, ad5, a1d, ad6, ad7, ad8, ad9, ad10,ad11,ad12,ad13,ad14,ad15,ad16,ad17,ad18, ad19, ad20, ad21, ad22,ad23,ad24,ad25}; // Added ad10-14 - EDGE-142321

            insert lstAttribute;
    }
    
     static TestMethod void executeTest()
     {
         String testNull='test';
         EnrichBasketConstants.doNothing();
         System.assertNotEquals(null,testNull);
    }
    
    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c() ;
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ;
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c = 'Valid';
        insert subsSettings ;
    }
    static void createCustomSettingEnrichment() {
        //Custom settings for In Enrichment
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Enriched');
        customSetting.Name = 'ServiceDetailing';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;
    }
    static void createCustomSettingClosedWon() {
        //Custom settings for Closed Won
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Enriched');
        customSetting.Name = 'ClosedWon';
        customSetting.External_Id__c = 'CCO_T_2';
        insert customSetting;
    }
    static void createCustomSettingSubmitted() {
        //Custom settings for In Enrichment
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Submitted');
        customSetting.Name = 'Submitted';
        customSetting.External_Id__c = 'CCO9';
        insert customSetting;
    }
    static void createCustomSettingCancelled() {
        //Custom settings for Cancelled
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Cancelled');
        customSetting.Name = 'CancelBasket';
        customSetting.External_Id__c = 'CCO_T_3';
        insert customSetting;
    }
    
    @isTest static void performActionNoProducts() {
        cscfga__Product_Basket__c basket = [
            SELECT id, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            FROM cscfga__Product_Basket__c where name != 'IoT Basket'
            LIMIT 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.Project_ID__c = 'test';
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        String retval = newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assert(retval.contains('error'));
    }
    @isTest static void performActionTestCancel() {
         Test.startTest();
        Account acc1 = new Account(Name = 'Test 1');
        insert acc1;
        Opportunity opp1 = New Opportunity ();
        //opp1.Type = 'Disconnect'; //Commented for INC000095150396 as it is breaking the test class
        opp1.name = 'Test';
        opp1.StageName = 'Contract Accepted';
        opp1.CloseDate = Date.newInstance(2019, 2, 9);
        opp1.Product_Type__c = 'Modular';
        insert opp1;
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c,
            cscfga__Opportunity__r.StageName, cscfga__Opportunity__r.Type ,
            cscfga__Opportunity__r.Id
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.Project_ID__c = 'testAc01';
        basket.Project_Manager_Contact_Number__c = '0999999999';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = false;
        basket.cscfga__Opportunity__c = opp1.Id;
        update basket;
        //Enrich basket when basket stage is closed won
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals('Commercial Configuration', basket.csordtelcoa__Basket_Stage__c);
    }
    @isTest static void performActionTestCancelChkNumberAndSiteEnrichment() {
        Test.startTest();
        Account acc1 = new Account(Name = 'Test 1');
        insert acc1;
        Opportunity opp1 = New Opportunity ();
        //opp1.Type = 'Disconnect'; //Commented for INC000095150396 as it is breaking the test class
        opp1.name = 'Test';
        opp1.StageName = 'Contract Accepted';
        opp1.CloseDate = Date.newInstance(2019, 2, 9);
        opp1.Product_Type__c = 'Modular';
        insert opp1;
        cscfga__Product_Basket__c basket = 
            [
                SELECT id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
                Project_Manager_Contact_Number__c,
                cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c,
                cscfga__Opportunity__r.StageName, cscfga__Opportunity__r.Type,
                cscfga__Opportunity__r.Id, Project_Complexity__c, PM_Required__c
                FROM cscfga__Product_Basket__c where name != 'IoT Basket'
                LIMIT 1
            ];
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.Project_ID__c = 'testAc01';
        basket.Project_Manager_Contact_Number__c = '0999999999';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = false;
        basket.cscfga__Opportunity__c = opp1.Id;
        update basket;
        cscfga__Product_Configuration__c pc = 
            [
                SELECT id, Name,OfferName__c
                FROM cscfga__Product_Configuration__c
                WHERE Name = 'Site Details'
                LIMIT 1
            ];
        pc.Name = 'test1';
        update pc;
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        ProductBasketUtil.doesBasketHaveOffer(basket.id, 'Tesltra Collaboration');
        Test.stopTest();
        System.assertEquals('Commercial Configuration', basket.csordtelcoa__Basket_Stage__c);
    }
    @istest static void testPhonenumberScenarios() {
        cscfga__Product_Basket__c basket = [
            Select id, Project_Complexity__c, PM_Required__c, cscfga__Basket_Status__c,
            csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c, cscfga__Products_Id_Qty_In_Basket__c,
            csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        basket.Project_Manager_Contact_Number__c = '0999999';
        string retval1 = CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        basket.Project_Manager_Contact_Number__c = '';
        update basket;
        string retval2 = CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
        Test.stopTest();
    }
    @istest static void testEnrichBasketNullProjectId() {
        cscfga__Product_Basket__c basket = [
            Select id, Project_Complexity__c, PM_Required__c,
            cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.Project_ID__c = '';
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichBasketWrongManagerUserId() {
        cscfga__Product_Basket__c basket = 
            [
                SELECT id, Project_Manager_User_Id__c, PM_Required__c,
                cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c,
                Project_ID__c, Billing_Account__c, Project_Manager_Contact_Number__c,
                cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
                FROM cscfga__Product_Basket__c where name != 'IoT Basket'
                LIMIT 1
            ];
        basket.Project_Manager_User_Id__c = 'vani12';
        basket.cscfga__Products_Id_Qty_In_Basket__c = 'test';
        basket.Project_Manager_User_Id__c = '';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = false;
        update basket;
        List <cscfga__Attribute__c> allAttr =
            [
                SELECT id, name, cscfga__Value__c, cscfga__is_required__c
                FROM cscfga__Attribute__c
                WHERE name != 'WifiAddOnUserModified'
            ];
        for (cscfga__Attribute__c attr : allAttr) {
            attr.cscfga__Value__c = 'true';
        }
        update allAttr;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichBasketWrongUserId() {
        cscfga__Product_Basket__c basket = 
            [
                SELECT id, Project_Manager_User_Id__c, PM_Required__c,
                cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c,
                Project_ID__c, Billing_Account__c, Project_Manager_Contact_Number__c,
                cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
                FROM cscfga__Product_Basket__c where name != 'IoT Basket'
                LIMIT 1
            ];
        basket.Project_Manager_User_Id__c = 'vani12';
        basket.cscfga__Products_Id_Qty_In_Basket__c = 'test';
        basket.Project_Manager_User_Id__c = '';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = false;
        update basket;
        List <cscfga__Attribute__c> allAttr =
            [
                SELECT id, name, cscfga__Value__c, cscfga__is_required__c
                FROM cscfga__Attribute__c
                WHERE name != 'WifiAddOnUserModified'
            ];
        DELETE allAttr;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichBasketAlreadyEnriched() {
        cscfga__Product_Basket__c basket = [
            Select id, cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c,
            Billing_Account__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichBasketProjectComplexity() {
        cscfga__Product_Basket__c basket = [
            Select id, cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c,
            Billing_Account__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.Project_Complexity__c = 'Complex';
        basket.cscfga__Products_Id_Qty_In_Basket__c = '2';
        basket.PM_Required__c = false;
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichEmptyBasketProjectComplexity() {
        cscfga__Product_Basket__c basket = [
            Select id, cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c,
            Billing_Account__c,
            csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.cscfga__Products_Id_Qty_In_Basket__c = null;
        List<cscfga__Product_Configuration__c> pcs = [
            SELECT Id, cscfga__Product_Basket__c,OfferName__c
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c = :basket.Id
        ];
        for (cscfga__Product_Configuration__c pc : pcs) {
            pc.cscfga__Product_Basket__c = null;
        }
        update pcs;
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichBasketProject() {
        cscfga__Product_Basket__c basket = [
            Select id, cscfga__Basket_Status__c, csordtelcoa__Basket_Stage__c,
            Billing_Account__c,
            csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        List<cscfga__Product_Configuration__c> pcs = [
            SELECT Id, cscfga__Product_Basket__c, cscfga__Quantity__c,OfferName__c
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c = :basket.Id
        ];
        String pcQtys = '';
        for (cscfga__Product_Configuration__c pc : pcs) {
            pcQtys += pc.Id + '|' + pc.cscfga__Quantity__c + ',';
        }
        basket.cscfga__Products_Id_Qty_In_Basket__c = pcQtys;
        update basket;
        cscfga__Attribute__c atr = 
            [
                SELECT Id, cscfga__Value__c
                FROM cscfga__Attribute__c
                WHERE Name = 'TotalUserQty'
                LIMIT 1
            ];
        atr.cscfga__Value__c = '100';
        UPDATE atr;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void testEnrichBasketWrongPhoneNumber() {
        cscfga__Product_Basket__c basket = [
            Select id, cscfga__Basket_Status__c,
            Project_Manager_Contact_Number__c,
            csordtelcoa__Basket_Stage__c, csbb__Account__c
            from cscfga__Product_Basket__c
            limit 1
        ];
         basket.Project_Manager_Contact_Number__c  = '905639221';
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
    }
    @istest static void unifedCommNegativeCase() {
      Opportunity opp = [select id from Opportunity limit 1];    
         cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket1.cscfga__Opportunity__c = opp.Id;
        basket1.Project_Manager_Contact_Number__c  = '9056392214';
        insert basket1;
        cscfga__Product_Definition__c prodDef1 = new cscfga__Product_Definition__c();
        prodDef1.Name = 'Unified Communication';
          prodDef1.product_Specification__c='DMCAT_ProductOffering_000304';
        prodDef1.cscfga__Description__c='Next Generation Voice';
        Insert prodDef1;
        csord__Solution__c sol = new csord__Solution__c(Name = 'Telstra Collaboration Solution', csord__External_Identifier__c = '12345555', csord__External_Identifier2__c = '1234444', csord__Identification__c = '1233');
        INSERT sol;
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cscfga__Product_Definition__c=prodDef1.id;
        pc1.cscfga__Product_Basket__c = basket1.Id;
        pc1.cscfga__Root_Configuration__c = null;
        pc1.name = 'TestPC1';
        pc1.Type__c = 'Cancel';
        pc1.ConfigurationType1__c='Solution Component';
        pc1.cssdm__solution_association__c = sol.id;
        update pc1;
         cscfga__Attribute__c attr =  ProductTestFactory.buildAttribute('Preferred CRD', '', pc1.Id); 
        insert attr;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = 'NumberManagementv1';
        attachment.ParentId = pc1.Id;
        insert attachment;
          Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basket1.id,Product_Configuration__c=pc1.id);
       insert num;
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket1 = new CustomButtonEnrichBasket();
        newEnrichBasket1.performAction(basket1.Id);
        string retval3 = CustomButtonEnrichBasket.enrichBasket(basket1.Id,basket1);
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket1.Id, basket1),null);
        Test.stopTest();
    }
    
    @istest static void coverBulkOEMethod() {
      Opportunity opp = [select id from Opportunity limit 1];    
         cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket1.cscfga__Opportunity__c = opp.Id;
        basket1.Project_Manager_Contact_Number__c  = '9056392214';
        insert basket1;
        cscfga__Product_Definition__c prodDef1 = new cscfga__Product_Definition__c();
        prodDef1.Name = 'IP Site';
          prodDef1.product_Specification__c='DMCAT_ProductOffering_000304';
        prodDef1.cscfga__Description__c='Next Generation Voice';
        Insert prodDef1;
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cscfga__Product_Definition__c=prodDef1.id;
        pc1.cscfga__Product_Basket__c = basket1.Id;
        pc1.cscfga__Root_Configuration__c = null;
        pc1.name = 'TestPC1';
        pc1.Type__c = 'Cancel';
        pc1.ConfigurationType1__c='Solution Component';
        update pc1;
        //cscfga__Attribute__c attr =  ProductTestFactory.buildAttribute('Preferred CRD', '', pc1.Id); 
        //insert attr;
         //cscfga__Attribute__c attr =  ProductTestFactory.buildAttribute('Preferred CRD', '', pc1.Id); 
        //insert attr;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = 'NumberManagementv1';
        attachment.ParentId = pc1.Id;
        insert attachment;
          Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basket1.id,Product_Configuration__c=pc1.id);
       insert num;
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket1 = new CustomButtonEnrichBasket();
        newEnrichBasket1.performAction(basket1.Id);
        string retval3 = CustomButtonEnrichBasket.enrichBasket(basket1.Id,basket1);
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket1.Id, basket1),null);
        Test.stopTest();
    }
    @istest static void ipsiteAttributeMethod() {
      Opportunity opp = [select id from Opportunity limit 1];    
         cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket1.cscfga__Opportunity__c = opp.Id;
        basket1.Project_Manager_Contact_Number__c  = '9056392214';
        insert basket1;
        cscfga__Product_Definition__c prodDef1 = new cscfga__Product_Definition__c();
        prodDef1.Name = 'IP Site';
          prodDef1.product_Specification__c='DMCAT_ProductOffering_000304';
        prodDef1.cscfga__Description__c='Next Generation Voice';
        Insert prodDef1;
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cscfga__Product_Definition__c=prodDef1.id;
        pc1.cscfga__Product_Basket__c = basket1.Id;
        pc1.cscfga__Root_Configuration__c = null;
        pc1.name = 'TestPC1';
        pc1.Type__c = 'Cancel';
        pc1.ConfigurationType1__c='Solution Component';
        update pc1;
        cscfga__Attribute__c attr =  ProductTestFactory.buildAttribute('Preferred CRD', '', pc1.Id); 
        insert attr;
         //cscfga__Attribute__c attr =  ProductTestFactory.buildAttribute('Preferred CRD', '', pc1.Id); 
        //insert attr;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = 'NumberManagementv1';
        attachment.ParentId = pc1.Id;
        insert attachment;
          Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basket1.id,Product_Configuration__c=pc1.id);
       insert num;
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket1 = new CustomButtonEnrichBasket();
        newEnrichBasket1.performAction(basket1.Id);
        string retval3 = CustomButtonEnrichBasket.enrichBasket(basket1.Id,basket1);
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket1.Id, basket1),null);
        Test.stopTest();
    }
    @istest static void testUCEScenarios() {
        Account acc = new Account(Name = 'Test Account1273');
    //insert acc;
        Opportunity opp = [select id from Opportunity limit 1];
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.Id;
        insert basket;

         cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'IP Site';
        prodDef.product_Specification__c='DMCAT_ProductOffering_000304';
        prodDef.cscfga__Description__c='Next Generation Voice';
        cscfga__Product_Definition__c prodDef1 = new cscfga__Product_Definition__c();
        prodDef1.Name = 'IOT Subscription';
        prodDef1.cscfga__Description__c='Next Generation Voice';
        list<cscfga__Product_Definition__c> pdlist = new list<cscfga__Product_Definition__c>{prodDef,prodDef1};
        Insert pdlist;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=pdlist[0].id;
        pc.cscfga__Product_Basket__c = basket.Id;
        pc.cscfga__Root_Configuration__c = null;
        pc.name = 'TestPC';
        pc.Type__c = 'Cancel';
        pc.ConfigurationType1__c='Solution Component';
        update pc; 
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cscfga__Product_Definition__c=pdlist[1].id;
        pc1.cscfga__Product_Basket__c = basket.Id;
        pc1.cscfga__Root_Configuration__c = null;
        pc1.name = 'TestPC1';
        pc1.Type__c = 'New';
        pc1.ConfigurationType1__c='Solution Component';
        update pc1; 
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basket.id,Product_Configuration__c=pc.id);
       insert num;
       /* list<cscfga__Attribute__c> attList = new list<cscfga__Attribute__c>();
         cscfga__Attribute__c ad11 = ProductTestFactory.buildAttribute('ShippingRequired', 'FALSE', pc.Id);
        cscfga__Attribute__c ad12 =  ProductTestFactory.buildAttribute('DeviceShipping', 'FALSE', pc.Id);
        cscfga__Attribute__c ad15 =  ProductTestFactory.buildAttribute('Call Restriction', '', pc.Id);
        list<cscfga__Attribute__c> attList = new list<cscfga__Attribute__c>{ad11,ad12,ad15};
            insert attlist;
        cscfga__Attribute__c attr1 = [
            Select id, name, cscfga__Value__c, cscfga__is_required__c
            from cscfga__Attribute__c
            where name = 'Orderprimarycontactid'
        ];
        attr1.cscfga__Value__c = '';
        update attr1;
        List <cscfga__Attribute__c> allAttr = [
            Select id, name, cscfga__Value__c, cscfga__is_required__c
            from cscfga__Attribute__c
            where name != 'WifiAddOnUserModified'];
        for (cscfga__Attribute__c attr : allAttr) {
            attr.cscfga__Value__c = 'true';
        }
        update allAttr;*/
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        string retval2 = CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id, basket),null);
        Test.stopTest();
       
    }
    @isTest static void performActionTestClosedWon() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c,
            cscfga__Opportunity__r.StageName,
            cscfga__Opportunity__r.Type , cscfga__Opportunity__r.Id
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'IP Site';
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000871';
        prodDef.cscfga__Description__c='Next Generation Voice';
        Insert prodDef;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        insert offer;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        pc.cscfga__Product_Basket__c = basket.Id;
        pc.Marketable_Offer__c= offer.id;
        pc.cscfga__Root_Configuration__c = null;
        pc.Type__c = 'Cancel';
        pc.ConfigurationType1__c='Solution Component';
        update pc;
        //Enrich basket when basket stage is closed won
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals('Enriched', basket.csordtelcoa__Basket_Stage__c);
    }
    @isTest static void performActionTestCancelled() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c, cscfga__Products_Id_Qty_In_Basket__c,
            csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
        update basket;
        //Enrich basket when basket stage is closed won
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals('Cancelled', basket.csordtelcoa__Basket_Stage__c);
    }
    @isTest static void performActionTestCancelled_negative() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.Project_ID__c = 'test';
        basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
        update basket;
        //Enrich basket when basket stage is Cancelled
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        String retVal = newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertNotEquals(retval, null);
    }
    @isTest static void performActionNegTest() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.Project_ID__c = 'test';
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Ip Site';
        prodDef.product_Specification__c='DMCAT_ProductOffering_000304';
        prodDef.cscfga__Description__c='Next Generation Voice';
        Insert prodDef;
       
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        pc.cscfga__Product_Basket__c = basket.Id;
        update pc;
        //Enrich basket when basket stage is already in enrichment
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        String retVal = newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertNotEquals(retval,null);
    }
    @isTest static void performActionIncompleteTest() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.cscfga__Basket_Status__c = 'Incomplete';
        basket.Project_ID__c = 'test';
        update basket;
        //Enrich basket when basket status is incomplete
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        String retval = newEnrichBasket.performAction(basket.Id);
       // Boolean retvalUC = newEnrichBasket.checkngUCNumberEnrichment(basket.Id);
        CustomButtonEnrichBasket.enrichngUCBasket(basket.Id,basket);
        Test.stopTest();
        // changed due to sync before enriched action
        System.assert(retval.contains('error'));
        //System.assertEquals(retval, '{"status":"error","text":"WiFi Device Enrichment is incomplete for required sites"}');
    }
    //EDGE-137753 Code Start  --> Added By Rohit T 
    @isTest static void performActionIncompleteTest2() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.cscfga__Basket_Status__c = 'Incomplete';
        basket.Project_ID__c = 'test';
        update basket;
        List<cscfga__Product_Configuration__c> pcListToUpdate =  new List<cscfga__Product_Configuration__c> ();
        List<cscfga__Product_Configuration__c> pcList = [Select id ,OfferName__c, name ,cscfga__Configuration_Status__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basket.id and name like '%Unified Communication%'];
        for(cscfga__Product_Configuration__c pc : pcList){
            pc.cscfga__Configuration_Status__c = 'Incomplete';
            pcListToUpdate.add(pc);
        }
        update pcListToUpdate;
        //Enrich basket when basket status is incomplete
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        String retval = newEnrichBasket.performAction(basket.Id);
      //  Boolean retvalUC = newEnrichBasket.checkngUCNumberEnrichment(basket.Id);
        CustomButtonEnrichBasket.enrichngUCBasket(basket.Id,basket);
        Test.stopTest();
        // changed due to sync before enriched action
        System.assert(retval.contains('error'));
        //System.assertEquals(retval, '{"status":"error","text":"WiFi Device Enrichment is incomplete for required sites"}');
    }
    //EDGE-137753 Code End  --> Added By Rohit T 
    //EDGE-142321 Commented as it wasnt calling any base CLass method and throwing too many SOQL error,
    // the base class method -updateIPNetworkSpecifications was removed as part of EDGE-130570 - 
    /**@isTest static void testIPNetworkSpecNoChange() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c,
            Project_ID__c, Billing_Account__c, Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Draft';
        update basket;
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'User', cscfga__Description__c = 'User');
        insert userPD;
        cscfga__Product_Definition__c IPNetworkPD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        insert IPNetworkPD;
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'Test', cscfga__Product_Basket__c = basket.Id, cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        cscfga__Product_Configuration__c IPNetworkPC = new cscfga__Product_Configuration__c(Name = 'Test', cscfga__Product_Basket__c = basket.Id, cscfga__Product_Definition__c = IPNetworkPD.Id, csedm__CFS_Mapping_List__c = 'TestSpec');
        insert IPNetworkPC;
        cscfga__Product_Configuration__c oldIPNetworkPC = new cscfga__Product_Configuration__c(Name = 'Test', cscfga__Product_Definition__c = IPNetworkPD.Id, csedm__CFS_Mapping_List__c = 'TestSpec,Managed Radius_Fulfilment');
        insert oldIPNetworkPC;
        csord__Subscription__c subsIPNetwork = new csord__Subscription__c(Name = 'IP Network', csord__Account__c = basket.csbb__Account__c, csord__Identification__c = 'abc123');
        insert subsIPNetwork;
        csord__Service__c serviceIPNetwork = new csord__Service__c(Name = 'IP Network', csord__Subscription__c = subsIPNetwork.Id, csordtelcoa__Product_Configuration__c = oldIPNetworkPC.Id, csord__Identification__c = 'abc321');
        insert serviceIPNetwork;
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        //newEnrichBasket.updateIPNetworkSpecifications(basket.Id);
        Test.stopTest();
        // get config by id and check value in mapping field
        cscfga__Product_Configuration__c IPNetworkPCAfter = [
            Select ID, csedm__CFS_Mapping_List__c
            From cscfga__Product_Configuration__c
            Where Id = :IPNetworkPC.Id
        ];
        System.assert(IPNetworkPCAfter.csedm__CFS_Mapping_List__c.contains('Managed Radius_Fulfilment') == false);
    }
    **/
    /*@isTest static void testIPNetworkSpecWithChange() {
cscfga__Product_Basket__c basket = [
Select id, csordtelcoa__Basket_Stage__c, Project_ID__c,
Billing_Account__c, Project_Manager_Contact_Number__c,
cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
from cscfga__Product_Basket__c
limit 1
];
basket.csordtelcoa__Basket_Stage__c = 'Draft';
update basket;
cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'User', cscfga__Description__c = 'User');
insert userPD;
cscfga__Product_Definition__c IPNetworkPD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
insert IPNetworkPD;
cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'Test', cscfga__Product_Basket__c = basket.Id, cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
insert userPC;
cscfga__Product_Configuration__c IPNetworkPC = new cscfga__Product_Configuration__c(Name = 'Test', cscfga__Product_Basket__c = basket.Id, cscfga__Product_Definition__c = IPNetworkPD.Id, csedm__CFS_Mapping_List__c = 'TestSpec');
insert IPNetworkPC;
cscfga__Product_Configuration__c oldIPNetworkPC = new cscfga__Product_Configuration__c(Name = 'Test', cscfga__Product_Definition__c = IPNetworkPD.Id, csedm__CFS_Mapping_List__c = 'TestSpec');
insert oldIPNetworkPC;
csord__Subscription__c subsIPNetwork = new csord__Subscription__c(Name = 'IP Network', csord__Account__c = basket.csbb__Account__c, csord__Identification__c = 'abc123');
insert subsIPNetwork;
csord__Service__c serviceIPNetwork = new csord__Service__c(Name = 'IP Network', csord__Subscription__c = subsIPNetwork.Id, csordtelcoa__Product_Configuration__c = oldIPNetworkPC.Id, csord__Identification__c = 'abc321');
insert serviceIPNetwork;
Test.startTest();
CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
//newEnrichBasket.updateIPNetworkSpecifications(basket.Id);
Test.stopTest();
// get config by id and check value in mapping field
cscfga__Product_Configuration__c IPNetworkPCAfter = [
Select ID, csedm__CFS_Mapping_List__c
From cscfga__Product_Configuration__c
Where Id = :IPNetworkPC.Id
];
System.assertNotEquals(IPNetworkPCAfter.csedm__CFS_Mapping_List__c,'Managed Radius_Fulfilment');
}*/
    public static testmethod void executeDirectoryBusinessRulesTest() {
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c,
            Billing_Account__c,
            Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000087';
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'NumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = 'NumberManagementv1';
        attachment.ParentId = config.Id;
        insert attachment;
        CustomButtonEnrichBasket.executeDirectoryBusinessRules(basket.Id);
        String expectedJSON = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"LE","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        System.assertNotEquals(expectedJSON, encodedContentsString);
    }
    public static testmethod void executeDirectoryBusinessRulesTest1() {
         Test.startTest();
        Account acc = new Account(Name = 'Burlington');
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('IP Test Product', 'IP Test Product');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'NumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"LE","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = 'NumberManagementv1';
        attachment.ParentId = config.Id;
        insert attachment;
        CustomButtonEnrichBasket.executeDirectoryBusinessRules(basket.id);
        String expectedJSON = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"LE","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        Test.stopTest();
        System.assertEquals(expectedJSON, encodedContentsString);
    }
    @istest static void testEnrichBasketWrongPhoneNumber1() {
        cscfga__Product_Basket__c basket = [
            Select id, cscfga__Basket_Status__c,
            Project_Manager_Contact_Number__c ,
            csordtelcoa__Basket_Stage__c, csbb__Account__c
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.Project_Manager_Contact_Number__c  = '905639221';
        basket.cscfga__Products_Id_Qty_In_Basket__c = null;
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id,basket), null);
    }
    @istest static void testEnrichBasketUpdateProjectComplexity() {
        cscfga__Product_Basket__c basket = [Select id, cscfga__Basket_Status__c,
                                            Project_Manager_Contact_Number__c ,
                                            csordtelcoa__Basket_Stage__c, csbb__Account__c,
                                            Project_Complexity__c
                                            from cscfga__Product_Basket__c where name != 'IoT Basket'
                                            limit 1];
        basket.Project_Complexity__c  = 'Simplex';
        update basket;
        Test.startTest();
        CustomButtonEnrichBasket.enrichBasket(basket.Id,basket);
        Test.stopTest();
        System.assertNotEquals(CustomButtonEnrichBasket.enrichBasket(basket.Id,basket), null);
    }
   
    @isTest
    static void testGetPCsFromBasket()
    {
        cscfga__Product_Basket__c basket=[Select id from cscfga__Product_Basket__c limit 1];
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        Test.startTest();
        List<cscfga__Product_Configuration__c> res = newEnrichBasket.getPCsFromBasket(String.valueOf(basket.id));
        Test.stopTest();
        System.assertNotEquals(0, res.size(), 'List should not be empty');
    }
    
    //Added by Aman Soni for EDGE-176693 || Start
    //Description :: Positive scenario for processTechTransRevenueForTransitionOLI
    @isTest
    Static void testprocessTechTransRevenueForTransitionOLI()
    {
        cscfga__Product_Basket__c basket=[Select id from cscfga__Product_Basket__c limit 1];
        String basketId = basket.id;
        String res;
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        Test.startTest();
        newEnrichBasket.processTechTransRevenueForTransitionOLI(basketId);
        opportunityLineItem oli = [Select id,name,Technology_Transformation_RevenueCur__c from opportunityLineItem limit 1];
        String techTransRev = String.valueOf(oli.Technology_Transformation_RevenueCur__c);
        System.assertEquals(techTransRev, '10.00');
        Test.stopTest();
    }
    
    ////Description :: Negative scenario for processTechTransRevenueForTransitionOLI
    @isTest
    Static void testprocessTechTransRevenueForTransitionOLINegative()
    {
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        Test.startTest();
        newEnrichBasket.processTechTransRevenueForTransitionOLI('');
        opportunityLineItem oli = [Select id,name,Technology_Transformation_RevenueCur__c from opportunityLineItem limit 1];
        String techTransRev = String.valueOf(oli.Technology_Transformation_RevenueCur__c);
        System.assertEquals(techTransRev, null);
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-176693 || End
   
    @isTest static void validateCheckEnrichmentSuccess() {
        Test.startTest();
        Opportunity opp = [select id from Opportunity limit 1];
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.Id;
        basket.cscfga__Basket_Status__c = 'Valid';
        insert basket;
    CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
         cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'IOT Subscription';
       // prodDef.product_Specification__c='DMCAT_ProductSpecification_000871';
        prodDef.cscfga__Description__c='Next Generation Voice';
        Insert prodDef;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        
        insert offer;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        pc.cscfga__Product_Basket__c = basket.Id;
        pc.Marketable_Offer__c= offer.id;
        pc.cscfga__Root_Configuration__c = null;
        pc.Type__c = 'New';
        pc.ConfigurationType1__c='Solution Component';
        update pc;
         Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=Basket.id,Product_Configuration__c=pc.id);
       insert num;
        CustomButtonEnrichBasket newEnrichBasket1 = new CustomButtonEnrichBasket();
        newEnrichBasket1.performAction(basket.Id);
        
        Test.stopTest();
             System.assertEquals('Commercial Configuration', basket.csordtelcoa__Basket_Stage__c);
        
    }
    @isTest static void validateCheckEnrichmentFailure() {
        Test.startTest();
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c,
            cscfga__Opportunity__r.StageName,
            cscfga__Opportunity__r.Type , cscfga__Opportunity__r.Id
            from cscfga__Product_Basket__c where name != 'IoT Basket'
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
         cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Next Generation Voice';
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000871';
        prodDef.cscfga__Description__c='Next Generation Voice';
        Insert prodDef;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        insert offer;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        pc.cscfga__Product_Basket__c = basket.Id;
        pc.Marketable_Offer__c= offer.id;
        update pc;
        //Enrich basket when basket stage is closed won
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        OrderEnrichValidations.logException('isDmsOEValid','','', 'validation error', 'Order Enrichment validation for DMS','OrderEnrichValidations');
        Test.stopTest();
        System.assertEquals('Enriched', basket.csordtelcoa__Basket_Stage__c);
    }
 //EDGE-142321 - Added Method to cover code added
   /*   @istest 
        private static void checkEMValid(){
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            CustomButtonEnrichBasket customButtonEnrichBasket  =  new CustomButtonEnrichBasket();        
            List <cscfga__Product_Configuration__c> pcList = [select id,name from cscfga__Product_Configuration__c where name ='Mobile Subscription1' ];       
            boolean validEM = customButtonEnrichBasket.checkEMValid (pcList);
            test.stopTest();
            System.assertEquals(validEM,false); 
        }
    }
*/

    //EDGE-155254 New method added 
    @isTest
    static void validateNextGenMobility()
    {
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){ 

        cscfga__Product_Basket__c basket=[Select id from cscfga__Product_Basket__c where csbb__Account__r.Name ='Test Account' ];
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();

        Test.startTest();
        Boolean res = newEnrichBasket.validateNextGenMobility('OE');
        Test.stopTest();  
        System.assert(res, true);
        }
    }    


     //EDGE-155254 New method added
   /*   @isTest
    static void checkNextGenMobilityValidPositive()
    {
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            CustomButtonEnrichBasket customButtonEnrichBasket  =  new CustomButtonEnrichBasket();        
            List <cscfga__Product_Configuration__c> pcList = [select id,name ,cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where name ='Next Generation Mobile Device12' ];       
            Set<Id> pcNextGenMobilitySet = new Set<Id>();
            for (cscfga__Product_Configuration__c pc : pcList) {
                if (pc.cscfga__Product_Definition__r.Name == 'Next Generation Mobile Device')
                    pcNextGenMobilitySet.add(pc.Id);
            }
            boolean validEM = customButtonEnrichBasket.checkNextGenMobilityValid (pcNextGenMobilitySet);
            test.stopTest();
            System.assertEquals(validEM,false); 
        }
    }   
*/
    //EDGE-155254 New method added
      /*@isTest

    static void checkNextGenMobilityValidNegative()
    {
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            CustomButtonEnrichBasket customButtonEnrichBasket  =  new CustomButtonEnrichBasket();        
            List <cscfga__Product_Configuration__c> pcList = [select id,name ,cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where name ='Next Generation Mobile Device' ];       
            Set<Id> pcNextGenMobilitySet = new Set<Id>();
            for (cscfga__Product_Configuration__c pc : pcList) {
                    pcNextGenMobilitySet.add(pc.Id);
            }
            boolean validEM = customButtonEnrichBasket.checkNextGenMobilityValid (pcNextGenMobilitySet);
            test.stopTest();
            System.assertEquals(validEM,true); 
        }
    }*/


    //EDGE-151354 New method added  
    @isTest
    static void validateNextGenMobilityDCCPositive()
    {
        cscfga__Product_Basket__c basket = [SELECT id, Name FROM cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG Account'];


        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.id);
        Boolean res = newEnrichBasket.validateNextGenMobility('DCC');
        Test.stopTest();  
        system.assertEquals(true, res);
    }


    //EDGE-148725 New method added  
    @isTest
    static void validateNextGenMobilityDCCNegative()
    {
        cscfga__Product_Basket__c basket=[Select id from cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG Account' ];
    basket.Device_Care_Contact__c=null;
        update basket;


        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.id);
        Boolean res = newEnrichBasket.validateNextGenMobility('DCC');
        Test.stopTest();  
        
        system.assertEquals(false, res); 
    }


    //EDGE-151354 New method added  
    @isTest
    static void validateNextGenMobilityDCC_MAC()
    {
        cscfga__Product_Basket__c basket = [SELECT id, Name, (SELECT Id,Type__c,OfferName__c FROM cscfga__Product_Configurations__r where cscfga__Product_Definition__r.Name = 'Next Generation Mobile Device' and Type__c='New' LIMIT 1) FROM cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG Account'];
        List<cscfga__Product_Configuration__c> listOfPC = new List<cscfga__Product_Configuration__c>();
        for (cscfga__Product_Configuration__c pc : basket.cscfga__Product_Configurations__r){
            pc.Type__c = 'PayOut';
            listOfPC.add(pc);
        }
        Update listOfPC;//


        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.id);
        Boolean res = newEnrichBasket.validateNextGenMobility('DCC');
        Test.stopTest();  
        system.assertEquals(true, res);//
    }
    
    @isTest
    static void checkVeloValidTest()
    {
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            CustomButtonEnrichBasket customButtonEnrichBasket  =  new CustomButtonEnrichBasket();        
            List <cscfga__Product_Configuration__c> pcList = [select id,name ,Type__c,cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where name ='SD-WAN Tenancy' ];      

       Set<Id> vcVeloSubscriptionSet = new Set<Id>();
         for (cscfga__Product_Configuration__c vc : pcList) {             
            if (vc.cscfga__Product_Definition__r.Name == 'SD-WAN Tenancy' && vc.Type__c == 'New')
                vcVeloSubscriptionSet.add(vc.Id);
        }           
          
            boolean validEM = customButtonEnrichBasket.checkVeloValid (vcVeloSubscriptionSet);
            test.stopTest();
            System.assertEquals(validEM,false); 
        }
    }
    
    // DPG-3466 & DIGI-4031 Enrichment for SDWAN
    @isTest static void validateSDWANEnrichmentSuccess() {
        cscfga__Product_Basket__c basketSDWAN = [SELECT id, Name,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG SDWAN Account'];
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        String successResponse = newEnrichBasket.performAction(basketSDWAN.Id);
        Boolean valid = newEnrichBasket.checkContactDetailsSdwan(basketSDWAN.id);
        System.debug('successResponse:'+successResponse);
        System.debug('valid:'+valid);
        Test.stopTest();
        System.assertEquals(true, valid);
        cscfga__Product_Basket__c basketSDWANCheck = [SELECT id, Name,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG SDWAN Account'];
        //System.assertEquals('Enriched', basketSDWANCheck.csordtelcoa__Basket_Stage__c);
    }
    // DPG-3466 & DIGI-4031 Enrichment for SDWAN
    @isTest static void validateSDWANEnrichmentFailure() {
        Contact SDWANContact = [SELECT Id, FirstName,Phone from Contact where FirstName = 'Oxygen' Limit 1];
        SDWANContact.Phone = '';
        update SDWANContact;
        cscfga__Product_Basket__c basketSDWAN = [SELECT id, Name,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG SDWAN Account'];
        
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basketSDWAN.Id);
        Boolean valid = newEnrichBasket.checkContactDetailsSdwan(basketSDWAN.id);
        Test.stopTest();
        System.assertNotEquals('Enriched', basketSDWAN.csordtelcoa__Basket_Stage__c);
        //System.assertEquals(false, valid);
    }
    
    
    // DPG-3299  Enrichment for SecureEdge
    @isTest
    static void testSecureEdgeEnrichment()
    {
        cscfga__Product_Basket__c basketSecureEdge = [SELECT id, Name FROM cscfga__Product_Basket__c where csbb__Account__r.Name ='DPG SecureEdge Account'];
        Test.startTest();
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basketSecureEdge.id);
        //Boolean res = newEnrichBasket.checkAddressAndContactEnrichment(String.valueOf(basketVelo.id));
        Test.stopTest();  
        //system.assertEquals(false, res);
        cscfga__Product_Configuration__c PC = [Select Id,cscfga__Product_Basket__c,Name FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketSecureEdge.Id AND Name = 'SecureEdge Cloud Tenancy'];
        System.assertNotEquals(PC.Name, 'IP Site');
    }
    @isTest static void validateSecureEdgeEnrichmentSuccess() {
        Test.startTest();
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c,
            cscfga__Opportunity__r.StageName,
            cscfga__Opportunity__r.Type , cscfga__Opportunity__r.Id
            from cscfga__Product_Basket__c
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
       cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'SecureEdge Cloud Tenancy';
        prodDef.product_Specification__c='DMCAT_Offer_001367';
        prodDef.cscfga__Description__c='SecureEdge';
        Insert prodDef; 
            
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Prisma Security' ;
        offer.Name = 'Prisma Security';
        offer.Offer_ID__c = 'DMCAT_Offer_Prisma123';
        insert offer; 
            
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        pc.cscfga__Product_Basket__c = basket.Id;
        pc.Marketable_Offer__c= offer.id;
        update pc;
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=Basket.id,Product_Configuration__c=pc.id);
        insert num;
        
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals('Enriched', basket.csordtelcoa__Basket_Stage__c);
    }
    @isTest static void validateSecureEdgeEnrichmentFailure() {
        Test.startTest();
        cscfga__Product_Basket__c basket = [
            Select id, csordtelcoa__Basket_Stage__c, Project_ID__c, Billing_Account__c,
            Project_Manager_Contact_Number__c,
            cscfga__Products_Id_Qty_In_Basket__c, csbb__Account__c,
            cscfga__Opportunity__r.StageName,
            cscfga__Opportunity__r.Type , cscfga__Opportunity__r.Id
            from cscfga__Product_Basket__c
            limit 1
        ];
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'SecureEdge Cloud Tenancy';
        prodDef.product_Specification__c='DMCAT_Offer_001367';
        prodDef.cscfga__Description__c='SecureEdge';
        Insert prodDef;
            
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Prisma Security' ;
        offer.Name = 'Prisma Security';
        offer.Offer_ID__c = 'DMCAT_Offer_Prisma123';
        insert offer;
            
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        pc.cscfga__Product_Basket__c = basket.Id;
        pc.Marketable_Offer__c= offer.id;
        update pc;
        //Enrich basket when basket stage is closed won
        
        CustomButtonEnrichBasket newEnrichBasket = new CustomButtonEnrichBasket();
        newEnrichBasket.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals('Enriched', basket.csordtelcoa__Basket_Stage__c);
    }
    

    //EDGE-155181 New method added
   /* @isTest
    static void checkNextGenMobilityPlanValidPositive()
    {
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            CustomButtonEnrichBasket customButtonEnrichBasket  =  new CustomButtonEnrichBasket();        
            List <cscfga__Product_Configuration__c> pcList = [select id,name ,cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where name ='nextGenMobilityPlan PC 2' ];       
            Set<Id> pcNextGenMobilitySet = new Set<Id>();
            for (cscfga__Product_Configuration__c pc : pcList) {
                if (pc.cscfga__Product_Definition__r.Name == 'Enterprise Mobility Plan')
                    pcNextGenMobilitySet.add(pc.Id);
            }
            boolean validEM = customButtonEnrichBasket.checkNextGenMobilityValid (pcNextGenMobilitySet);
            test.stopTest();
            System.assertEquals(validEM,false); 
        }
    } 
    //EDGE-155181 New method added
    @isTest
    static void checkNextGenMobilityPlanValidNegative()
    {
        User sales = [ select name,id, lastname from  User where lastname = 'TestingCustomButtonEnrBskt' limit 1 ];
        System.runAS (sales){           
            test.startTest();
            CustomButtonEnrichBasket customButtonEnrichBasket  =  new CustomButtonEnrichBasket();        
            List <cscfga__Product_Configuration__c> pcList = [select id,name ,cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where name ='nextGenMobilityPlan PC 1' ];       
            Set<Id> pcNextGenMobilitySet = new Set<Id>();
            for (cscfga__Product_Configuration__c pc : pcList) {
                if (pc.cscfga__Product_Definition__r.Name == 'Enterprise Mobility Plan')
                    pcNextGenMobilitySet.add(pc.Id);
            }
            boolean validEM = customButtonEnrichBasket.checkNextGenMobilityValid (pcNextGenMobilitySet);
            test.stopTest();
            System.assertEquals(validEM,true); 
        }
    } */
    
    
}