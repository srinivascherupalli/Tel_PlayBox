/*****
Code Coverage for Classes : ProductBasketTriggerHandler, ProductUtility, ProductBasketTrigger, BasketOpportunityUpdateHelper
Added test data to cover cleanupServAddOnRecords method for EDGE-194029 by Aman Soni
******/

@isTest
public class ProductBasketTriggerHandlerTest1 {
    @testSetup static void testDataSetup() {
        
        //Added by Aman Soni for EDGE-194029 || Start
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                      lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                      profileid = pf.id,
                      timezonesidkey='Australia/Sydney',
                      username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        //Added by Aman Soni for EDGE-194029 || End
    
        //Creating Account test data
        RecordType accRecType           =   [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Partner' LIMIT 1];  // Laxmi - EDGE-133414 added below record type code ode to satisfy partner type condition
        List<Account> accList           =   new List<Account>();
        Account testPartnerAccount      =   AccountTestFactory.buildAccount('testPartnerAccount');
        testPartnerAccount.RecordTypeID =   accRecType.Id;
        accList.add(testPartnerAccount);
        Account testAccount             =   AccountTestFactory.buildAccount('testAccount');
        accList.add(testAccount);
        insert accList;
        
        //Creating Contact test data
        List<Contact> contactList       =   new List<Contact>();
        Contact partnerContact          =   AccountTestFactory.buildContact(testPartnerAccount, 'Partner Contact', 'partnercontact@test.com');
        contactList.add(partnerContact);
        Contact testContact             =   AccountTestFactory.buildContact(testAccount, 'Test Contact', 'testcontact@test.com');
        contactList.add(testContact);
        insert contactList;
        
        //Creating Opportunity test data
        List<Opportunity> oppyList      =   new List<Opportunity>();
        Opportunity testpartnerOpp      =   ProductTestFactory.getOpportunityBasic(testPartnerAccount);  //EDGE-144345  changed to use ProductTestFactory
        testpartnerOpp.Name             =   'testpartnerOpp';
        testpartnerOpp.Product_Type__c  =   'Modular';
        oppyList.add(testpartnerOpp);
        Opportunity testOpp             =   ProductTestFactory.getOpportunityBasic(testAccount);  //EDGE-144345  changed to use ProductTestFactory
        testpartnerOpp.Name             =   'testOpp';
        testOpp.Product_Type__c         =   'Modular';
        oppyList.add(testOpp);
        Opportunity testOpp1            =   ProductTestFactory.getOpportunityBasic(testAccount);  //EDGE-144345  changed to use ProductTestFactory
        testpartnerOpp.Name             =   'testOpp1';
        testOpp1.Product_Type__c        =   'Non Modular';
        oppyList.add(testOpp1);
        
        //Added by Aman Soni for EDGE-194029 || Start
        Opportunity testOpp2            =   ProductTestFactory.getOpportunityBasic(testAccount); 
        testOpp2.Name                   =   'TestOppty2';
        testOpp2.Product_Type__c        =   'Modular';
        oppyList.add(testOpp2); 
        //Added by Aman Soni for EDGE-194029 || End
        
        insert oppyList;

        //Creating Product Definition test data
        cscfga__Product_Definition__c prodDef_IPNetwork =   new cscfga__Product_Definition__c ();
        prodDef_IPNetwork.Name                          =   'IP Network';
        prodDef_IPNetwork.cscfga__Description__c        =   'IP Network Description';
        insert prodDef_IPNetwork;

        //Creating Product Basket test data
        List<cscfga__Product_Basket__c> basketList      =   new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1               =   ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c                        =   testPartnerAccount.Id;
        basket1.Name                                    =   'Basket 1';
        basket1.cscfga__Opportunity__c                  =   testpartnerOpp.Id;
        basket1.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basketList.add(basket1);
        cscfga__Product_Basket__c basket2               =   ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c                        =   testAccount.Id;
        basket2.Name                                    =   'Basket 2';
        basket2.cscfga__Opportunity__c                  =   testOpp.Id;
        basket2.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basketList.add(basket2);
        cscfga__Product_Basket__c basket3               =   ProductTestFactory.buildEmptyBasket();
        basket3.csbb__Account__c                        =   testAccount.Id;
        basket3.Name                                    =   'Basket 3';
        basket3.cscfga__Opportunity__c                  =   testOpp1.Id;
        basket3.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basketList.add(basket3);
        
        //Added by Aman Soni for EDGE-194029 || Start
        cscfga__Product_Basket__c basket4               =   ProductTestFactory.buildEmptyBasket();
        basket4.csbb__Account__c                        =   testAccount.Id;
        basket4.Name                                    =   'Test Basket';
        basket4.cscfga__Opportunity__c                  =   testOpp2.Id;
        basket4.csordtelcoa__Basket_Stage__c            =   'Cancelled';
        basketList.add(basket4);
        insert basketList;
        
        List<Legacy_Service__c> legcyServLst= new List<Legacy_Service__c>();
        Legacy_Service__c legcyServ = new Legacy_Service__c();
        legcyServ.Eligibility_Status__c = 'Eligible';
        legcyServ.Select__c = true;
        legcyServ.Product_Basket__c = basket4.id;
        legcyServLst.add(legcyServ);
        insert legcyServLst;
        
        List<Service_Add_On__c> servAddOnLst= new List<Service_Add_On__c>();
        Service_Add_On__c servAddOn = new Service_Add_On__c();
        servAddOn.Device_Id__c = '1234568';
        servAddOn.Name = 'Test Service Add On';
        servAddOn.Status__c = 'Sync Completed';
        servAddOn.Instance_Id__c = '43227654';
        servAddOn.Contract_Type__c = 'MRO';
        servAddOn.Transaction_Type__c = 'Transition';
        servAddOn.Account__c = testAccount.id;
        servAddOn.Product_Basket__c = basket4.id;
        servAddOn.Solution_Id__c = 'aefnefi678901jdw';
        servAddOnLst.add(servAddOn);
        
        Service_Add_On__c servAddOn1 = new Service_Add_On__c();
        servAddOn1.Device_Id__c = '1234568';
        servAddOn1.Name = 'Test Service Add On';
        servAddOn1.Status__c = 'Sync Completed';
        servAddOn1.Instance_Id__c = '43227652';
        servAddOn1.Contract_Type__c = 'MRO';
        servAddOn1.Transaction_Type__c = 'MIgration';
        servAddOn1.Account__c = testAccount.id;
        servAddOn1.Product_Basket__c = basket4.id;
        servAddOn1.Solution_Id__c = 'aefnefi678901jdw';
        servAddOnLst.add(servAddOn1);
        insert servAddOnLst;
        //Added by Aman Soni for EDGE-194029 || End
        
        //Creating Product Configuration test data
        List <cscfga__Product_Configuration__c> pcList  =   new List <cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config1        =   ProductTestFactory.buildProductConfig(prodDef_IPNetwork.Id);  //EDGE-144345  changed to use ProductTestFactory
        config1.Name                                    =   'IP Network Partner 1';
        config1.cscfga__Product_Basket__c               =   basket1.Id;
        config1.cscfga__Product_Family__c               =   'Modular';
        config1.Quantity_Product_Configuration__c       =   1;
        config1.cscfga__Contract_Term__c                =   12;
        config1.cscfga__Product_Definition__c           =   prodDef_IPNetwork.id ;
        config1.Quantity_Product_Configuration__c       =   6;
        pcList.add(config1);
        cscfga__Product_Configuration__c config1IPSubt  =   ProductTestFactory.buildProductConfig(prodDef_IPNetwork.Id); // Added as part of EDGE-133414
        config1IPSubt.Name                              =   'IP Network Subcription Partner 1';
        config1IPSubt.cscfga__Product_Basket__c         =   basket1.Id;
        config1IPSubt.cscfga__Product_Family__c         =   'Modular';
        config1IPSubt.Quantity_Product_Configuration__c =   1;
        config1IPSubt.cscfga__Contract_Term__c          =   12;
        pcList.add(config1IPSubt);
        cscfga__Product_Configuration__c config2        =   ProductTestFactory.buildProductConfig(prodDef_IPNetwork.Id);  //EDGE-144345  changed to use ProductTestFactory
        config2.Name                                    =   'IP Network 1';
        config2.cscfga__Product_Basket__c               =   basket2.Id;
        config2.cscfga__Product_Family__c               =   'Modular';
        config2.Quantity_Product_Configuration__c       =   1;
        config2.cscfga__Contract_Term__c                =   12;
        config2.cscfga__Product_Definition__c           =   prodDef_IPNetwork.id ;
        config2.Quantity_Product_Configuration__c       =   6;
        pcList.add(config2);
        cscfga__Product_Configuration__c config2IPSubt  =   ProductTestFactory.buildProductConfig(prodDef_IPNetwork.Id); // Added as part of EDGE-133414
        config2IPSubt.Name                              =   'IP Network Subcription 1';
        config2IPSubt.cscfga__Product_Basket__c         =   basket2.Id;
        config2IPSubt.cscfga__Product_Family__c         =   'Modular';
        config2IPSubt.Quantity_Product_Configuration__c =   1;
        config2IPSubt.cscfga__Contract_Term__c          =   12;
        pcList.add(config2IPSubt);
        cscfga__Product_Configuration__c config1Cancel  =   ProductTestFactory.buildProductConfig(prodDef_IPNetwork.Id); // Added as part of EDGE-133414
        config1Cancel.Name                              =   'IP Network Subcription 1';
        config1Cancel.cscfga__Product_Basket__c         =   basket2.Id;
        config1Cancel.cscfga__Product_Family__c         =   'Modular';
        config1Cancel.Quantity_Product_Configuration__c =   1;
        config1Cancel.cscfga__Contract_Term__c          =   12;
        config1Cancel.Type__c                           =   'Cancel';
        pcList.add(config1Cancel);
        cscfga__Product_Configuration__c config3IPSubt  =   ProductTestFactory.buildProductConfig(prodDef_IPNetwork.Id); // Added as part of EDGE-133414
        config3IPSubt.Name                              =   'IP Network Subcription 1';
        config3IPSubt.cscfga__Product_Basket__c         =   basket3.Id;
        config3IPSubt.cscfga__Product_Family__c         =   'Non Modular';
        config3IPSubt.Quantity_Product_Configuration__c =   1;
        config3IPSubt.cscfga__Contract_Term__c          =   36;
        pcList.add(config3IPSubt);
        insert pcList;

        //Creating Attribute Data
        List <cscfga__Attribute__c> attributeList       =   new List <cscfga__Attribute__c>();  // Added as part of EDGE-133414
        cscfga__Attribute__c attETC1                    =   ProductTestFactory.buildPriceAttribute('EarlyTerminationCharge','100',config1.Id,true,100);
        attETC1.cscfga__is_active__c                    =   true;
        attETC1.cscfga__Line_Item_Description__c        =   'IP Network Partner 1';        
        attETC1.cscfga__Recurring__c                    =   true;
        attributeList.add(attETC1);
        cscfga__Attribute__c attETC2                    =   ProductTestFactory.buildPriceAttribute('EarlyTerminationCharge','100',config2.Id,true,100);
        attETC2.cscfga__is_active__c                    =   true;
        attETC2.cscfga__Line_Item_Description__c        =   'IP Network 1';        
        attETC2.cscfga__Recurring__c                    =   true;
        attributeList.add(attETC2); 
        cscfga__Attribute__c attETC3                    =   ProductTestFactory.buildPriceAttribute('ETC','100',config1Cancel.Id,true,100);
        attETC3.cscfga__is_active__c                    =   true;
        attETC3.cscfga__Line_Item_Description__c        =   'IP Network 1';        
        attETC3.cscfga__Recurring__c                    =   true;
        attributeList.add(attETC3); 
        cscfga__Attribute__c attETCIPSubt1              =   ProductTestFactory.buildPriceAttribute('ETC','100',config1IPSubt.Id,true,100); 
        attETCIPSubt1.cscfga__is_active__c              =   true;
        attETCIPSubt1.cscfga__Line_Item_Description__c  =   'IP Network Subcription  1';        
        attributeList.add(attETCIPSubt1);
        cscfga__Attribute__c attETCIPSubt2              =   ProductTestFactory.buildPriceAttribute('ETC','100',config2IPSubt.Id,true,100); 
        attETCIPSubt2.cscfga__is_active__c              =   true;
        attETCIPSubt2.cscfga__Line_Item_Description__c  =   'IP Network Subcription  1';        
        attributeList.add(attETCIPSubt2);
        cscfga__Attribute__c attSplCharge               =   ProductTestFactory.buildPriceAttribute('Special Charge','255',config3IPSubt.Id,true,255);
        attSplCharge.cscfga__is_active__c               =   true;
        attSplCharge.cscfga__Line_Item_Description__c   =   'Special Charge'; 
        attributeList.add(attSplCharge);
        cscfga__Attribute__c attRF1                     =   ProductTestFactory.buildAttribute('RedeemFund','100',config1.Id);
        attributeList.add(attRF1);
        cscfga__Attribute__c attRF2                     =   ProductTestFactory.buildAttribute('RedeemFund','100',config2.Id);
        attributeList.add(attRF2);
        cscfga__Attribute__c attProdCode1               =   ProductTestFactory.buildAttribute('ProductCode','TEST100',config1.Id);
        attributeList.add(attProdCode1);
        cscfga__Attribute__c attProdCode2               =   ProductTestFactory.buildAttribute('ProductCode','TEST200',config2.Id);
        attributeList.add(attProdCode2);
        cscfga__Attribute__c attProdMaxim1              =   ProductTestFactory.buildAttribute('ProductMaximName','TESTMAXIM100',config1.Id);
        attributeList.add(attProdMaxim1);
        cscfga__Attribute__c attProdMaxim2              =   ProductTestFactory.buildAttribute('ProductMaximName','TESTMAXIM200',config2.Id);
        attributeList.add(attProdMaxim2); 
        cscfga__Attribute__c attRF3                     =   ProductTestFactory.buildAttribute('RedeemFund','200',config2.Id);
        attributeList.add(attRF3);
        cscfga__Attribute__c attRF4                     =   ProductTestFactory.buildAttribute('RedeemFund','200',config1.Id);
        attributeList.add(attRF4);        
        insert attributeList; 

        cscfga__Attribute_Field__c attField1    =   new cscfga__Attribute_Field__c();
        attField1.Name                          =   'IncrementalRevenue';
        attField1.cscfga__Attribute__c          =   attETC2.Id;
        attField1.cscfga__Value__c              =   '300';
        insert attField1;

        List<cspmb__Price_Item__c> commProdList         =   new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c commProd1                  =   new cspmb__Price_Item__c();
        commProd1.Name                                  =   'Test Commercial 1';
        commProd1.Maxim_Product_Name__c                 =   'TESTMAXIM100';
        commProd1.Product_Code__c                       =   'TEST100';
        commProd1.Product_Family__c                     =   'TESTFamily1';
        commProd1.Product_Group__c                      =   'TestGroup1';
        commProd1.Ultimate_Product__c                   =   'TestProduct1';
        commProdList.add(commProd1);
        cspmb__Price_Item__c commProd2                  =   new cspmb__Price_Item__c();
        commProd2.Name                                  =   'Test Commercial 1';
        commProd2.Maxim_Product_Name__c                 =   'TESTMAXIM200';
        commProd2.Product_Code__c                       =   'TEST200';
        commProd2.Product_Family__c                     =   'TESTFamily2';
        commProd2.Product_Group__c                      =   'TestGroup2';
        commProd2.Ultimate_Product__c                   =   'TestProduct2';
        commProdList.add(commProd2);
        insert commProdList;      

        List<CustomConfigurationOptions__c> commList    =   new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c commConfig1       =   new CustomConfigurationOptions__c();
        commConfig1.Name                                =   'ContractAccepted';
        commConfig1.Enrichment_Basket_Stage__c          =   'Contract Accepted';
        commConfig1.External_Id__c                      =   '7654';
        commConfig1.Opportunity_Stage__c                =   'Propose';
        commList.add(commConfig1);
        CustomConfigurationOptions__c commConfig2       =   new CustomConfigurationOptions__c();
        commConfig2.Name                                =   'CommercialConfiguration';
        commConfig2.Enrichment_Basket_Stage__c          =   'Commercial Configuration';
        commConfig2.External_Id__c                      =   'CCO4';
        commConfig2.Opportunity_Stage__c                =   'Develop';
        commList.add(commConfig2);
        CustomConfigurationOptions__c commConfig3       =   new CustomConfigurationOptions__c();
        commConfig3.Name                                =   'Quote';
        commConfig3.Enrichment_Basket_Stage__c          =   'Quote';
        commConfig3.External_Id__c                      =   'CC08';
        commConfig3.Opportunity_Stage__c                =   'Propose';
        commList.add(commConfig3);
        insert commList;
    }   //End of testDataSetup()

   @istest 
    private static void unitTest1(){
        List<cscfga__Product_Basket__c> basketList  =   [SELECT Id,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c];
        Set<String> setProductBasketId              =   new Set<String>();
        
        for(cscfga__Product_Basket__c oBasket : basketList) {
            oBasket.csbb__Synchronised_With_Opportunity__c  =   true;
            setProductBasketId.add(oBasket.Id);
        }
        
        Test.startTest();
            if(!basketList.isEmpty()) {
                update basketList;
            }
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            List<cscfga__Product_Basket__c> updatebasketList  =   [SELECT Id,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c];
            set<string> basketId = new Set<String>();
            for(cscfga__Product_Basket__c basket : updatebasketList) {
                System.assertEquals(true, basket.csordtelcoa__Synchronised_with_Opportunity__c, 'Basket is not synchronised with opportunity sucessfully');
                System.assertEquals(true, basket.csbb__Synchronised_With_Opportunity__c,'Basket is not synchronised with opportunity sucessfully');
                basket.csbb__Synchronised_With_Opportunity__c = false;
                basketId.add(basket.Id);
            }
            ProductUtility.createOLIs(basketId);
            List<OpportunityLineItem> oliList   =   new List<OpportunityLineItem>([SELECT Id,Name,OpportunityId,Opportunity.Name,Opportunity.Basket_Redemption_amount__c FROM OpportunityLineItem]);
            
            System.assertEquals(7, oliList.size(), 'OLIs didnt generate for Attribute with Is Line Item = true');
            System.assertNotEquals(11, oliList.size(), 'OLIs are also created for Attribute with Is Line Item != true');
            System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Test.stopTest();
        
        update updatebasketList;
        System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        List<OpportunityLineItem> oliListAfterDel   =   new List<OpportunityLineItem>([SELECT Id,OpportunityId,Opportunity.Name,Opportunity.Product_Type__c FROM OpportunityLineItem]);
        System.assertEquals(0, oliListAfterDel.size(), 'OLIs deletion error');        
    }   //End of unitTest1()

    @isTest private static void unitTest2() {
        Account acc                             =   [SELECT Id FROM Account WHERE Name = 'testAccount' LIMIT 1];
        cscfga__Product_Basket__c prodBasket    =   [SELECT Id,cscfga__Opportunity__c,csbb__Account__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.Id LIMIT 1];
        cscfga__Product_Definition__c oProdDef  =   [SELECT Id FROM cscfga__Product_Definition__c WHERE Name='IP Network' LIMIT 1];
        //Opportunity oppy    =   [SELECT Id, Name, AccountId, (SELECT Id,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Baskets__r WHERE ) FROM Opportunity WHERE AccountId=:acc.Id LIMIT 1];        
        
        Test.startTest();
            prodBasket.csbb__Synchronised_With_Opportunity__c   =   true;
            update prodBasket;
            
            cscfga__Product_Basket__c basket1   =   new cscfga__Product_Basket__c(
                Name = 'Test Basket',
                csbb__Account__c = prodBasket.csbb__Account__c, 
                cscfga__Opportunity__c = prodBasket.cscfga__Opportunity__c,
                csordtelcoa__Basket_Stage__c = 'Commercial Configuration');
            insert basket1;

            cscfga__Product_Configuration__c config1        =   ProductTestFactory.buildProductConfig(oProdDef.Id);
            config1.Name                                    =   'IP Network Partner 1';
            config1.cscfga__Product_Basket__c               =   basket1.Id;
            config1.cscfga__Product_Family__c               =   'Modular';
            config1.Quantity_Product_Configuration__c       =   1;
            config1.cscfga__Contract_Term__c                =   12;
            config1.Quantity_Product_Configuration__c       =   6;
            insert config1;
            
            List <cscfga__Attribute__c> attributeList       =   new List <cscfga__Attribute__c>();
            cscfga__Attribute__c attSplCharge               =   ProductTestFactory.buildPriceAttribute('Special Charge','300',config1.Id,true,300);
            attSplCharge.cscfga__is_active__c               =   true;
            attSplCharge.cscfga__Line_Item_Description__c   =   'Special Charge'; 
            attributeList.add(attSplCharge);
            cscfga__Attribute__c attAddress                 =   ProductTestFactory.buildAttribute('Address','X Street',config1.Id);
            attributeList.add(attAddress);
            insert attributeList;

            basket1.csbb__Synchronised_With_Opportunity__c  =   true;
            update basket1;
        Test.stopTest(); 

        List<cscfga__Product_Basket__c> prodbasketList = [SELECT Id,Name,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c =: prodBasket.cscfga__Opportunity__c];
        for(cscfga__Product_Basket__c basket : prodbasketList) {
            if(basket.Name=='Test Basket') {
                System.assertEquals(true, basket.csordtelcoa__Synchronised_with_Opportunity__c, 'Basket is not synchronised with opportunity sucessfully');
                System.assertEquals(true, basket.csbb__Synchronised_With_Opportunity__c,'Basket is not synchronised with opportunity sucessfully');
            } else {
                System.assertNotEquals(true, basket.csordtelcoa__Synchronised_with_Opportunity__c, 'Basket is not unsynchronised with opportunity');
                System.assertNotEquals(true, basket.csbb__Synchronised_With_Opportunity__c,'Basket is not unsynchronised with opportunity');
            }
        }
    }   //End of unitTest2()

    @istest 
    private static void unitTest3(){
        Account acc                             =   [SELECT Id FROM Account WHERE Name = 'testAccount' LIMIT 1];
        cscfga__Product_Basket__c prodBasket    =   [SELECT Id,cscfga__Opportunity__c,csbb__Account__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.Id AND cscfga__Opportunity__r.Product_Type__c='Modular' LIMIT 1];
        cscfga__Product_Definition__c oProdDef  =   [SELECT Id FROM cscfga__Product_Definition__c WHERE Name='IP Network' LIMIT 1];
        Id opportunityId                        =   prodBasket.cscfga__Opportunity__c;
        //Opportunity oppy    =   [SELECT Id, Name, AccountId, (SELECT Id,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Baskets__r WHERE ) FROM Opportunity WHERE AccountId=:acc.Id LIMIT 1];        
        
        Test.startTest();
            prodBasket.csbb__Synchronised_With_Opportunity__c   =   true;
            update prodBasket;
            ProductUtility.createOLIs(new Set<String>{prodBasket.Id});
        Test.stopTest();

        Map<Id,cscfga__Product_Basket__c> updatebasketMap  =   new Map<Id,cscfga__Product_Basket__c>([SELECT Id,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__c,cscfga__total_contract_value__c,Primary_Basket__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c,cscfga__Opportunity__r.Product_Type__c FROM cscfga__Product_Basket__c WHERE Id=:prodBasket.Id]);
        for(cscfga__Product_Basket__c basket : updatebasketMap.values()) {
            System.assertEquals(true, basket.csordtelcoa__Synchronised_with_Opportunity__c, 'Basket is not synchronised with opportunity sucessfully');
            System.assertEquals(true, basket.csbb__Synchronised_With_Opportunity__c,'Basket is not synchronised with opportunity sucessfully');
        }

        List<OpportunityLineItem> oliList   =   new List<OpportunityLineItem>([SELECT Id,Name,Domain__c,OpportunityId,Opportunity.Name,Opportunity.Basket_Redemption_amount__c FROM OpportunityLineItem]);
        
        System.assertEquals(3, oliList.size(), 'OLIs didnt generate for Attribute with Is Line Item = true');
        System.assertNotEquals(11, oliList.size(), 'OLIs are also created for Attribute with Is Line Item != true');
        
        Integer i = 1;
        for(OpportunityLineItem oli : oliList) {
            if(i==1) { i++; continue; }
            oli.Domain__c = oli.Name + ' i';
            i++;
        }

        update oliList;

        BasketOpportunityUpdateHelper.updateOpportunityDetails(updatebasketMap,new Set<Id>{opportunityId});

        List<Opportunity> oppList = [SELECT Id,Domain__c FROM Opportunity WHERE Id=:opportunityId];
        System.assertEquals('Multi',oppList[0].Domain__c);
        System.assertNotEquals('Single',oppList[0].Domain__c);

    }   //End of unitTest3()
     
    //Desc: Positive Scenario for cleanupServAddOnRecords || Added for EDGE-194029
    @IsTest
    private static void cleanupServAddOnRecordsPosTest(){
        User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
        System.runAS(sales){
        Test.startTest();
        List<cscfga__Product_Basket__c> basketLst = [select id,name,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where csordtelcoa__Basket_Stage__c = 'Cancelled' limit 1];
        List<Service_Add_On__c> addOnLst = [select id,name,Status__c,Product_Basket__c,Transaction_Type__c  from Service_Add_On__c where Product_Basket__c IN: basketLst];        
        ProductBasketTriggerHandler.cleanupServAddOnRecords(basketLst);
        
        List<Service_Add_On__c> addOnLstUpdated = [select id,name,Status__c,Product_Basket__c,Transaction_Type__c from Service_Add_On__c where Product_Basket__c =: basketLst[0].id];
        
        for(Service_Add_On__c servAddOn: addOnLstUpdated){
            if(servAddOn.Transaction_Type__c == 'Transition'){
                System.assertEquals('Pending', servAddOn.Status__c);
            }
            else if(servAddOn.Transaction_Type__c == 'Migration'){
                System.assertEquals('Ready for Sync', servAddOn.Status__c);
            }    
        }
        Test.stopTest();
        }
    } 
    
    //Desc: Negative scenario for cleanupServAddOnRecords || Added for EDGE-194029
   @IsTest
    private static void cleanupServAddOnRecordsNegTest(){
        User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1];
        System.runAS(sales){
        Test.startTest();
        List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
        
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c limit 1];
        Legacy_Service__c legcyServ = [select id,name,Account__c,Eligibility_Status__c,Product_Basket__c,Select__c,Transition_Id__c,Contract_Term__c from Legacy_Service__c limit 1];
        ProductBasketTriggerHandler.cleanupServAddOnRecords(basketLst);
        System.assertEquals('Sync Completed', addOn.Status__c);
        System.assertEquals('Eligible', legcyServ.Eligibility_Status__c);
        Test.stopTest();
        }
    }

}