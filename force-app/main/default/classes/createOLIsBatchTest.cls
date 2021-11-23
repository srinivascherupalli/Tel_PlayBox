/*****
Code Coverage for Classes : createOLIsBatch
CreatedBy : Kamlesh Kumar
CreatedDate : 5/2/2021
******/
@isTest
public class createOLIsBatchTest {
    @testSetup static void testDataSetup() {
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
        testpartnerOpp.Description__c   =   'CHOWN Incoming';
        oppyList.add(testpartnerOpp);
        Opportunity testOpp             =   ProductTestFactory.getOpportunityBasic(testAccount);  //EDGE-144345  changed to use ProductTestFactory
        testpartnerOpp.Name             =   'testOpp';
        testOpp.Product_Type__c         =   'Modular';
        oppyList.add(testOpp);
        Opportunity testOpp1            =   ProductTestFactory.getOpportunityBasic(testAccount);  //EDGE-144345  changed to use ProductTestFactory
        testpartnerOpp.Name             =   'testOpp1';
        //testOpp1.Product_Type__c        =   'Non Modular';

        testOpp1.Description__c = 'CHOWN Incoming';

        oppyList.add(testOpp1);
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
        basket1.csbb__Synchronised_With_Opportunity__c  =   true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c = true;
        basketList.add(basket1);
        cscfga__Product_Basket__c basket2               =   ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c                        =   testAccount.Id;
        basket2.Name                                    =   'Basket 2';
        basket2.cscfga__Opportunity__c                  =   testOpp1.Id;//testOpp.Id;
        basket2.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basket2.csbb__Synchronised_With_Opportunity__c  =   true;
        basket2.csordtelcoa__Synchronised_with_Opportunity__c = true;        
        basketList.add(basket2);
        cscfga__Product_Basket__c basket3               =   ProductTestFactory.buildEmptyBasket();
        basket3.csbb__Account__c                        =   testAccount.Id;
        basket3.Name                                    =   'Basket 3';
        basket3.cscfga__Opportunity__c                  =   testOpp1.Id;
        basket3.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basket3.csbb__Synchronised_With_Opportunity__c  =   true;
        basket3.csordtelcoa__Synchronised_with_Opportunity__c = true;        
        basketList.add(basket3);
        insert basketList;

        Migration_Change_Request__c mcr = new Migration_Change_Request__c();
        mcr.macd_basket_ids__c = basketList[0].id+','+basketList[1].id;
        insert mcr;

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
        List<cscfga__Product_Basket__c> basketList  =  [SELECT Id,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where cscfga__Opportunity__r.name = 'testOpp1'];

        Set<String> setProductBasketId = new Set<String>();
        
        for(cscfga__Product_Basket__c oBasket : basketList) {
            oBasket.csbb__Synchronised_With_Opportunity__c  =   true;
            oBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
            setProductBasketId.add(oBasket.Id);
        }
        
        Test.startTest();
            database.executeBatch(new createOLIsBatch(setProductBasketId));
        Test.stopTest();
        Integer lstSize = basketList.size();

        System.assertNotEquals(2,lstSize);

    }   //End of unitTest1()
}