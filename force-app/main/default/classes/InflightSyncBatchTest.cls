/*************************************************************************************************************************************************
* Name         :   InflightSyncBatchTest  
* Description  :   Test coverage for class InflightSyncBatch

Sr.No.     Developer Name      Date            Story           Description
1.      Gokul/Pooja         01/02/2021      EDGE-192806     In-Flight: Basket to Opportunity line item sync framework enhancements
2.      Kamlesh             22/03/2021      EDGE-205509     Commenting InflightProductUtilityForModular.failedBasketIds as this is commented in main class
**************************************************************************************************************************************************/
@isTest
private class InflightSyncBatchTest {
   
    @testSetup
    static void testdata(){
        Account testAccount = AccountTestFactory.buildAccount ('testAccount');
        insert testAccount;
        
        ID standardPBID     = Test.getStandardPricebookId();
        
        Pricebook2 pb       =   new Pricebook2();
        pb.name             =   'testPricebook2';
        pb.IsActive         =   true;
        insert pb;
        
        List<Opportunity> lstOppy   =   new List<Opportunity>();
        Opportunity testOpp         =   ProductTestFactory.getOpportunityBasic (testAccount);
        testOpp.Account             =   testAccount;
        testOpp.Product_Type__c     =   'Modular';
        testOpp.Pricebook2Id        =   standardPBID;
        lstOppy.add(testOpp);
        Opportunity testOpp1        =   ProductTestFactory.getOpportunityBasic (testAccount);
        testOpp1.Account            =   testAccount;
        testOpp1.Product_Type__c    =   'Modular';
        testOpp1.Pricebook2Id       =   standardPBID;
        lstOppy.add(testOpp1);
        Opportunity testOpp2        =   ProductTestFactory.getOpportunityBasic (testAccount);
        testOpp2.Account            =   testAccount;
        testOpp2.Product_Type__c    =   'Modular';
        testOpp2.Pricebook2Id       =   standardPBID;
        lstOppy.add(testOpp2);
        insert lstOppy;

        list<cscfga__Product_Basket__c> basketList                  =   new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c testBasket1                       =   ProductTestFactory.buildEmptyBasket();
        testBasket1.csbb__Account__c                                =   testAccount.Id;
        testBasket1.Name                                            =   'testBasket1';
        testBasket1.cscfga__Opportunity__c                          =   testOpp.Id;
        testBasket1.csbb__Synchronised_With_Opportunity__c          =   true;
        testBasket1.csordtelcoa__Synchronised_with_Opportunity__c   =   true;
        basketList.add(testBasket1);
        cscfga__Product_Basket__c testInflightBasket1               =   ProductTestFactory.buildEmptyBasket();
        testInflightBasket1.csbb__Account__c                        =   testAccount.Id;
        testInflightBasket1.Name                                    =   'testInflightBasket1';
        testInflightBasket1.cscfga__Opportunity__c                  =   testOpp.Id;
        testInflightBasket1.Amend_Type__c                           =   'Commercial';
        testInflightBasket1.sync_job_Id__c                          =   '[{"name":"syncJobId","isCompleted":true,"id":"7072N00000L8FF2QAQ","error":true}]';
        basketList.add(testInflightBasket1);
        cscfga__Product_Basket__c testBasket2                       =   ProductTestFactory.buildEmptyBasket();
        testBasket2.csbb__Account__c                                =   testAccount.Id;
        testBasket2.Name                                            =   'testBasket2';
        testBasket2.cscfga__Opportunity__c                          =   testOpp1.Id;
        testBasket2.csbb__Synchronised_With_Opportunity__c          =   true;
        testBasket2.csordtelcoa__Synchronised_with_Opportunity__c   =   true;
        basketList.add(testBasket2);
        cscfga__Product_Basket__c testInflightBasket2               =   ProductTestFactory.buildEmptyBasket();
        testInflightBasket2.csbb__Account__c                        =   testAccount.Id;
        testInflightBasket2.Name                                    =   'testInflightBasket2';
        testInflightBasket2.cscfga__Opportunity__c                  =   testOpp1.Id;
        testInflightBasket2.Amend_Type__c                           =   'Commercial';
        testInflightBasket2.sync_job_Id__c                          =   '[{"name":"syncJobId","isCompleted":true,"id":"7072N00000L8FF2QAQ","error":true}]';
        basketList.add(testInflightBasket2);
        cscfga__Product_Basket__c testBasket3                       =   ProductTestFactory.buildEmptyBasket();
        testBasket3.csbb__Account__c                                =   testAccount.Id;
        testBasket3.Name                                            =   'testBasket3';
        testBasket3.cscfga__Opportunity__c                          =   testOpp2.Id;
        testBasket3.csbb__Synchronised_With_Opportunity__c          =   true;
        testBasket3.csordtelcoa__Synchronised_with_Opportunity__c   =   true;
        basketList.add(testBasket3);
        cscfga__Product_Basket__c testInflightBasket3               =   ProductTestFactory.buildEmptyBasket();
        testInflightBasket3.csbb__Account__c                        =   testAccount.Id;
        testInflightBasket3.Name                                    =   'testInflightBasket3';
        testInflightBasket3.cscfga__Opportunity__c                  =   testOpp2.Id;
        testInflightBasket3.Amend_Type__c                           =   'Commercial';
        testInflightBasket3.sync_job_Id__c                          =   '[{"name":"syncJobId","isCompleted":true,"id":"7072N00000L8FF2QAQ","error":true}]';
        basketList.add(testInflightBasket3);
        insert basketList;
        testInflightBasket1.csordtelcoa__Previous_Product_Basket__c =   testBasket1.Id;
        testInflightBasket2.csordtelcoa__Previous_Product_Basket__c =   testBasket2.Id;
        testInflightBasket3.csordtelcoa__Previous_Product_Basket__c =   testBasket3.Id;
        update basketList;

        List<cscfga__Product_Definition__c> pdInsertList    =   new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pdNetwork             =   new cscfga__Product_Definition__c ();
        pdNetwork.Name                                      =   'IP Network';
        pdNetwork.cscfga__Description__c                    =   'IP Network Description';
        pdInsertList.add(pdNetwork);
        cscfga__Product_Definition__c pdData                =   new cscfga__Product_Definition__c ();
        pdData.Name                                         =   'IP Data';
        pdData.cscfga__Description__c                       =   'IP Data Description';
        pdInsertList.add(pdData);
        insert pdInsertList;
        
        List <cscfga__Product_Configuration__c> listTestConfig1     =   new List <cscfga__Product_Configuration__c>();
        List <cscfga__Product_Configuration__c> listTestConfig2     =   new List <cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc1                        =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc1.Name                                                    =   'IP Network11';
        pc1.cscfga__Product_Basket__c                               =   testBasket1.Id;
        pc1.cscfga__Product_Family__c                               =   'Modular';
        pc1.Quantity_Product_Configuration__c                       =   1;
        pc1.cscfga__Contract_Term__c                                =   12;
        pc1.cscfga__Product_Definition__c                           =   pdNetwork.id ;
        pc1.Quantity_Product_Configuration__c                       =   6;
        pc1.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc1.cscfga__total_recurring_charge__c                       =   100;
        pc1.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc1);

        cscfga__Product_Configuration__c pc2                        =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc2.Name                                                    =   'IP Network12';
        pc2.cscfga__Product_Basket__c                               =   testBasket1.Id;
        pc2.cscfga__Product_Family__c                               =   'Modular';
        pc2.Quantity_Product_Configuration__c                       =   1;
        pc2.cscfga__Contract_Term__c                                =   12;
        pc2.cscfga__Product_Definition__c                           =   pdNetwork.id ;
        pc2.Quantity_Product_Configuration__c                       =   6;
        pc2.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc2.cscfga__total_recurring_charge__c                       =   100;
        pc2.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc2);

        cscfga__Product_Configuration__c pc3                        =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc3.Name                                                    =   'IP Data13';
        pc3.cscfga__Product_Basket__c                               =   testBasket1.Id;
        pc3.cscfga__Product_Family__c                               =   'Modular';
        pc3.Quantity_Product_Configuration__c                       =   1;
        pc3.cscfga__Contract_Term__c                                =   12;
        pc3.cscfga__Product_Definition__c                           =   pdData.id ;
        pc3.Quantity_Product_Configuration__c                       =   6;
        pc3.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc3.cscfga__total_recurring_charge__c                       =   100;
        pc3.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc3);

        cscfga__Product_Configuration__c pc4                        =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc4.Name                                                    =   'IP Data14';
        pc4.cscfga__Product_Basket__c                               =   testBasket1.Id;
        pc4.cscfga__Product_Family__c                               =   'Modular';
        pc4.Quantity_Product_Configuration__c                       =   1;
        pc4.cscfga__Contract_Term__c                                =   12;
        pc4.cscfga__Product_Definition__c                           =   pdData.id ;
        pc4.Quantity_Product_Configuration__c                       =   6;
        pc4.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc4.cscfga__total_recurring_charge__c                       =   100;
        pc4.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc4);

        cscfga__Product_Configuration__c pc6                        =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc6.Name                                                    =   'IP Network21';
        pc6.cscfga__Product_Basket__c                               =   testBasket2.Id;
        pc6.cscfga__Product_Family__c                               =   'Modular';
        pc6.Quantity_Product_Configuration__c                       =   1;
        pc6.cscfga__Contract_Term__c                                =   12;
        pc6.cscfga__Product_Definition__c                           =   pdNetwork.id ;
        pc6.Quantity_Product_Configuration__c                       =   6;
        pc6.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc6.cscfga__total_recurring_charge__c                       =   100;
        pc6.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc6);

        cscfga__Product_Configuration__c pc7                        =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc7.Name                                                    =   'IP Network71';
        pc7.cscfga__Product_Basket__c                               =   testBasket3.Id;
        pc7.cscfga__Product_Family__c                               =   'Modular';
        pc7.Quantity_Product_Configuration__c                       =   1;
        pc7.cscfga__Contract_Term__c                                =   12;
        pc7.cscfga__Product_Definition__c                           =   pdNetwork.id ;
        pc7.Quantity_Product_Configuration__c                       =   6;
        pc7.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc7.cscfga__total_recurring_charge__c                       =   100;
        pc7.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc7);

        cscfga__Product_Configuration__c pc8                        =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc8.Name                                                    =   'IP Network81';
        pc8.cscfga__Product_Basket__c                               =   testBasket3.Id;
        pc8.cscfga__Product_Family__c                               =   'Modular';
        pc8.Quantity_Product_Configuration__c                       =   1;
        pc8.cscfga__Contract_Term__c                                =   12;
        pc8.cscfga__Product_Definition__c                           =   pdNetwork.id ;
        pc8.Quantity_Product_Configuration__c                       =   6;
        pc8.cscfga__discounts__c                                    =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc8.cscfga__total_recurring_charge__c                       =   100;
        pc8.cscfga__total_one_off_charge__c                         =   10;
        listTestConfig1.add(pc8);

        insert listTestConfig1;

        cscfga__Product_Configuration__c pc1Amend                   =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc1Amend.Name                                               =   'IP Network11';
        pc1Amend.cscfga__Product_Basket__c                          =   testInflightBasket1.Id;
        pc1Amend.cscfga__Product_Family__c                          =   'Modular';
        pc1Amend.Quantity_Product_Configuration__c                  =   1;
        pc1Amend.cscfga__Contract_Term__c                           =   12;
        pc1Amend.cscfga__Product_Definition__c                      =   pdNetwork.id ;
        pc1Amend.Quantity_Product_Configuration__c                  =   6;
        pc1Amend.cscfga__discounts__c                               =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc1Amend.cscfga__total_recurring_charge__c                  =   100;
        pc1Amend.cscfga__total_one_off_charge__c                    =   10;
        pc1Amend.csordtelcoa__Replaced_Product_Configuration__c     =   pc1.Id;
        pc1Amend.Type__c                                            =   'Inflight Amend';        
        listTestConfig2.add(pc1Amend);

        cscfga__Product_Configuration__c pc2Amend                   =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc2Amend.Name                                               =   'IP Network12';
        pc2Amend.cscfga__Product_Basket__c                          =   testInflightBasket1.Id;
        pc2Amend.cscfga__Product_Family__c                          =   'Modular';
        pc2Amend.Quantity_Product_Configuration__c                  =   1;
        pc2Amend.cscfga__Contract_Term__c                           =   12;
        pc2Amend.cscfga__Product_Definition__c                      =   pdNetwork.id ;
        pc2Amend.Quantity_Product_Configuration__c                  =   6;
        pc2Amend.cscfga__discounts__c                               =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc2Amend.cscfga__total_recurring_charge__c                  =   100;
        pc2Amend.cscfga__total_one_off_charge__c                    =   10;
        pc2Amend.csordtelcoa__Replaced_Product_Configuration__c     =   pc2.Id;
        pc2Amend.Type__c                                            =   'Inflight Amend';        
        listTestConfig2.add(pc2Amend);

        cscfga__Product_Configuration__c pc3Cancel                  =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc3Cancel.Name                                              =   'IP Data13';
        pc3Cancel.cscfga__Product_Basket__c                         =   testInflightBasket1.Id;
        pc3Cancel.cscfga__Product_Family__c                         =   'Modular';
        pc3Cancel.Quantity_Product_Configuration__c                 =   1;
        pc3Cancel.cscfga__Contract_Term__c                          =   12;
        pc3Cancel.cscfga__Product_Definition__c                     =   pdData.id ;
        pc3Cancel.Quantity_Product_Configuration__c                 =   6;
        pc3Cancel.cscfga__discounts__c                              =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc3Cancel.cscfga__total_recurring_charge__c                 =   100;
        pc3Cancel.cscfga__total_one_off_charge__c                   =   10;
        pc3Cancel.csordtelcoa__Replaced_Product_Configuration__c    =   pc3.Id;
        pc3Cancel.Type__c                                           =   'Inflight Cancel'; 
        listTestConfig2.add(pc3Cancel);

        cscfga__Product_Configuration__c pc5New                     =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc5New.Name                                                 =   'IP Data15';
        pc5New.cscfga__Product_Basket__c                            =   testInflightBasket1.Id;
        pc5New.cscfga__Product_Family__c                            =   'Modular';
        pc5New.Quantity_Product_Configuration__c                    =   1;
        pc5New.cscfga__Contract_Term__c                             =   12;
        pc5New.cscfga__Product_Definition__c                        =   pdData.id ;
        pc5New.Quantity_Product_Configuration__c                    =   6;
        pc5New.cscfga__discounts__c                                 =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc5New.cscfga__total_recurring_charge__c                    =   100;
        pc5New.cscfga__total_one_off_charge__c                      =   10;
        listTestConfig2.add(pc5New);

        cscfga__Product_Configuration__c pc6Cancel                  =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc6Cancel.Name                                              =   'IP Network21';
        pc6Cancel.cscfga__Product_Basket__c                         =   testInflightBasket2.Id;
        pc6Cancel.cscfga__Product_Family__c                         =   'Modular';
        pc6Cancel.Quantity_Product_Configuration__c                 =   1;
        pc6Cancel.cscfga__Contract_Term__c                          =   12;
        pc6Cancel.cscfga__Product_Definition__c                     =   pdData.id ;
        pc6Cancel.Quantity_Product_Configuration__c                 =   6;
        pc6Cancel.cscfga__discounts__c                              =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc6Cancel.cscfga__total_recurring_charge__c                 =   100;
        pc6Cancel.cscfga__total_one_off_charge__c                   =   10;
        pc6Cancel.csordtelcoa__Replaced_Product_Configuration__c    =   pc6.Id;
        pc6Cancel.Type__c                                           =   'Inflight Cancel'; 
        listTestConfig2.add(pc6Cancel);

        cscfga__Product_Configuration__c pc7Amend                   =   ProductTestFactory.buildProductConfig(pdNetwork.Id);
        pc7Amend.Name                                               =   'IP Network72';
        pc7Amend.cscfga__Product_Basket__c                          =   testInflightBasket3.Id;
        pc7Amend.cscfga__Product_Family__c                          =   'Modular';
        pc7Amend.Quantity_Product_Configuration__c                  =   1;
        pc7Amend.cscfga__Contract_Term__c                           =   12;
        pc7Amend.cscfga__Product_Definition__c                      =   pdNetwork.id ;
        pc7Amend.Quantity_Product_Configuration__c                  =   6;
        pc7Amend.cscfga__discounts__c                               =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc7Amend.cscfga__total_recurring_charge__c                  =   100;
        pc7Amend.cscfga__total_one_off_charge__c                    =   10;
        pc7Amend.csordtelcoa__Replaced_Product_Configuration__c     =   pc7.Id;
        pc7Amend.Type__c                                            =   'Inflight Amend';        
        listTestConfig2.add(pc7Amend);

        cscfga__Product_Configuration__c pc8Cancel                  =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc8Cancel.Name                                              =   'IP Data82';
        pc8Cancel.cscfga__Product_Basket__c                         =   testInflightBasket3.Id;
        pc8Cancel.cscfga__Product_Family__c                         =   'Modular';
        pc8Cancel.Quantity_Product_Configuration__c                 =   1;
        pc8Cancel.cscfga__Contract_Term__c                          =   12;
        pc8Cancel.cscfga__Product_Definition__c                     =   pdData.id ;
        pc8Cancel.Quantity_Product_Configuration__c                 =   6;
        pc8Cancel.cscfga__discounts__c                              =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc8Cancel.cscfga__total_recurring_charge__c                 =   100;
        pc8Cancel.cscfga__total_one_off_charge__c                   =   10;
        pc8Cancel.csordtelcoa__Replaced_Product_Configuration__c    =   pc8.Id;
        pc8Cancel.Type__c                                           =   'Inflight Cancel'; 
        listTestConfig2.add(pc8Cancel);

        cscfga__Product_Configuration__c pc9New                     =   ProductTestFactory.buildProductConfig(pdData.Id);
        pc9New.Name                                                 =   'IP Data92';
        pc9New.cscfga__Product_Basket__c                            =   testInflightBasket3.Id;
        pc9New.cscfga__Product_Family__c                            =   'Modular';
        pc9New.Quantity_Product_Configuration__c                    =   1;
        pc9New.cscfga__Contract_Term__c                             =   12;
        pc9New.cscfga__Product_Definition__c                        =   pdData.id ;
        pc9New.Quantity_Product_Configuration__c                    =   6;
        pc9New.cscfga__discounts__c                                 =   '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        pc9New.cscfga__total_recurring_charge__c                    =   100;
        pc9New.cscfga__total_one_off_charge__c                      =   10;
        listTestConfig2.add(pc9New);
        insert listTestConfig2;
        
        List <cscfga__Attribute__c> listTestAttribute   =   new List <cscfga__Attribute__c>(); 
        cscfga__Attribute__c test_ETC_PC1               =   new cscfga__Attribute__c();
        test_ETC_PC1.Name                               =   'EarlyTerminationCharge';
        test_ETC_PC1.cscfga__Product_Configuration__c   =   pc1.Id;
        test_ETC_PC1.cscfga__is_active__c               =   true;
        test_ETC_PC1.cscfga__Line_Item_Description__c   =   'EarlyTerminationCharge Test';        
        test_ETC_PC1.cscfga__Recurring__c               =   false;
        test_ETC_PC1.cscfga__Price__c                   =   100;
        test_ETC_PC1.cscfga__Value__c                   =   '100';
        test_ETC_PC1.cscfga__List_Price__c              =   100;
        listTestAttribute.add(test_ETC_PC1);

        cscfga__Attribute__c test_OC_PC1                =   new cscfga__Attribute__c();
        test_OC_PC1.Name                                =   'OC';
        test_OC_PC1.cscfga__Product_Configuration__c    =   pc1.Id;
        test_OC_PC1.cscfga__is_active__c                =   true;
        test_OC_PC1.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC1.cscfga__Recurring__c                =   false;
        test_OC_PC1.cscfga__Price__c                    =   100;
        test_OC_PC1.cscfga__Value__c                    =   '100';
        test_OC_PC1.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC1);

        cscfga__Attribute__c test_OC_PC2                =   new cscfga__Attribute__c();
        test_OC_PC2.Name                                =   'OC';
        test_OC_PC2.cscfga__Product_Configuration__c    =   pc2.Id;
        test_OC_PC2.cscfga__is_active__c                =   true;
        test_OC_PC2.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC2.cscfga__Recurring__c                =   false;
        test_OC_PC2.cscfga__Price__c                    =   100;
        test_OC_PC2.cscfga__Value__c                    =   '100';
        test_OC_PC2.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC2);
        
        cscfga__Attribute__c test_OC_PC3                =   new cscfga__Attribute__c();
        test_OC_PC3.Name                                =   'OC';
        test_OC_PC3.cscfga__Product_Configuration__c    =   pc3.Id;
        test_OC_PC3.cscfga__is_active__c                =   true;
        test_OC_PC3.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC3.cscfga__Recurring__c                =   false;
        test_OC_PC3.cscfga__Price__c                    =   100;
        test_OC_PC3.cscfga__Value__c                    =   '100';
        test_OC_PC3.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC3);

        cscfga__Attribute__c test_RC_PC3                =   new cscfga__Attribute__c();
        test_RC_PC3.Name                                =   'RC';
        test_RC_PC3.cscfga__Product_Configuration__c    =   pc3.Id;
        test_RC_PC3.cscfga__is_active__c                =   true;
        test_RC_PC3.cscfga__Line_Item_Description__c    =   'RC Test';        
        test_RC_PC3.cscfga__Recurring__c                =   true;
        test_RC_PC3.cscfga__Price__c                    =   100;
        test_RC_PC3.cscfga__Value__c                    =   '100';
        test_RC_PC3.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_RC_PC3);

        cscfga__Attribute__c test_OC_PC4                =   new cscfga__Attribute__c();
        test_OC_PC4.Name                                =   'OC';
        test_OC_PC4.cscfga__Product_Configuration__c    =   pc4.Id;
        test_OC_PC4.cscfga__is_active__c                =   true;
        test_OC_PC4.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC4.cscfga__Recurring__c                =   false;
        test_OC_PC4.cscfga__Price__c                    =   100;
        test_OC_PC4.cscfga__Value__c                    =   '100';
        test_OC_PC4.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC4);

        cscfga__Attribute__c test_OC_PC6                =   new cscfga__Attribute__c();
        test_OC_PC6.Name                                =   'OC';
        test_OC_PC6.cscfga__Product_Configuration__c    =   pc6.Id;
        test_OC_PC6.cscfga__is_active__c                =   true;
        test_OC_PC6.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC6.cscfga__Recurring__c                =   false;
        test_OC_PC6.cscfga__Price__c                    =   100;
        test_OC_PC6.cscfga__Value__c                    =   '100';
        test_OC_PC6.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC6);

        cscfga__Attribute__c test_OC_PC7                =   new cscfga__Attribute__c();
        test_OC_PC7.Name                                =   'OC';
        test_OC_PC7.cscfga__Product_Configuration__c    =   pc7.Id;
        test_OC_PC7.cscfga__is_active__c                =   true;
        test_OC_PC7.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC7.cscfga__Recurring__c                =   false;
        test_OC_PC7.cscfga__Price__c                    =   100;
        test_OC_PC7.cscfga__Value__c                    =   '100';
        test_OC_PC7.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC7);

        cscfga__Attribute__c test_ETC_PC7               =   new cscfga__Attribute__c();
        test_ETC_PC7.Name                               =   'ETC';
        test_ETC_PC7.cscfga__Product_Configuration__c   =   pc7.Id;
        test_ETC_PC7.cscfga__is_active__c               =   true;
        test_ETC_PC7.cscfga__Line_Item_Description__c   =   'ETC Test';        
        test_ETC_PC7.cscfga__Recurring__c               =   false;
        test_ETC_PC7.cscfga__Price__c                   =   100;
        test_ETC_PC7.cscfga__Value__c                   =   '100';
        test_ETC_PC7.cscfga__List_Price__c              =   100;
        listTestAttribute.add(test_ETC_PC7);

        cscfga__Attribute__c test_RFd_PC7               =   new cscfga__Attribute__c();
        test_RFd_PC7.Name                               =   'RedeemFund';
        test_RFd_PC7.cscfga__Product_Configuration__c   =   pc7Amend.Id;
        test_RFd_PC7.cscfga__is_active__c               =   true;
        test_RFd_PC7.cscfga__Line_Item_Description__c   =   'RedeemFund Test';        
        test_RFd_PC7.cscfga__Recurring__c               =   true;
        test_RFd_PC7.cscfga__Price__c                   =   100;
        test_RFd_PC7.cscfga__Value__c                   =   '100';
        test_RFd_PC7.cscfga__List_Price__c              =   100;
        listTestAttribute.add(test_RFd_PC7);

        cscfga__Attribute__c test_OC_PC8                =   new cscfga__Attribute__c();
        test_OC_PC8.Name                                =   'OC';
        test_OC_PC8.cscfga__Product_Configuration__c    =   pc8.Id;
        test_OC_PC8.cscfga__is_active__c                =   true;
        test_OC_PC8.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC8.cscfga__Recurring__c                =   false;
        test_OC_PC8.cscfga__Price__c                    =   100;
        test_OC_PC8.cscfga__Value__c                    =   '100';
        test_OC_PC8.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC8);

        cscfga__Attribute__c test_ETC_PC1Amnd               =   new cscfga__Attribute__c();
        test_ETC_PC1Amnd.Name                               =   'EarlyTerminationCharge';
        test_ETC_PC1Amnd.cscfga__Product_Configuration__c   =   pc1Amend.Id;
        test_ETC_PC1Amnd.cscfga__is_active__c               =   true;
        test_ETC_PC1Amnd.cscfga__Line_Item_Description__c   =   'EarlyTerminationCharge Test';        
        test_ETC_PC1Amnd.cscfga__Recurring__c               =   false;
        test_ETC_PC1Amnd.cscfga__Price__c                   =   100;
        test_ETC_PC1Amnd.cscfga__Value__c                   =   '100';
        test_ETC_PC1Amnd.cscfga__List_Price__c              =   100;
        listTestAttribute.add(test_ETC_PC1Amnd);

        cscfga__Attribute__c test_OC_PC1Amnd                =   new cscfga__Attribute__c();
        test_OC_PC1Amnd.Name                                =   'OC';
        test_OC_PC1Amnd.cscfga__Product_Configuration__c    =   pc1Amend.Id;
        test_OC_PC1Amnd.cscfga__is_active__c                =   true;
        test_OC_PC1Amnd.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC1Amnd.cscfga__Recurring__c                =   false;
        test_OC_PC1Amnd.cscfga__Price__c                    =   100;
        test_OC_PC1Amnd.cscfga__Value__c                    =   '100';
        test_OC_PC1Amnd.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC1Amnd);

        cscfga__Attribute__c test_RC_PC1Amnd                =   new cscfga__Attribute__c();
        test_RC_PC1Amnd.Name                                =   'RC';
        test_RC_PC1Amnd.cscfga__Product_Configuration__c    =   pc1Amend.Id;
        test_RC_PC1Amnd.cscfga__is_active__c                =   true;
        test_RC_PC1Amnd.cscfga__Line_Item_Description__c    =   'RC Test';        
        test_RC_PC1Amnd.cscfga__Recurring__c                =   true;
        test_RC_PC1Amnd.cscfga__Price__c                    =   100;
        test_RC_PC1Amnd.cscfga__Value__c                    =   '100';
        test_RC_PC1Amnd.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_RC_PC1Amnd);
        
        cscfga__Attribute__c test_OC_PC2Amnd                =   new cscfga__Attribute__c();
        test_OC_PC2Amnd.Name                                =   'OC';
        test_OC_PC2Amnd.cscfga__Product_Configuration__c    =   pc2Amend.Id;
        test_OC_PC2Amnd.cscfga__is_active__c                =   true;
        test_OC_PC2Amnd.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC2Amnd.cscfga__Recurring__c                =   false;
        test_OC_PC2Amnd.cscfga__Price__c                    =   100;
        test_OC_PC2Amnd.cscfga__Value__c                    =   '100';
        test_OC_PC2Amnd.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC2Amnd);

        cscfga__Attribute__c test_RC_PC2Amnd                =   new cscfga__Attribute__c();
        test_RC_PC2Amnd.Name                                =   'RC';
        test_RC_PC2Amnd.cscfga__Product_Configuration__c    =   pc2Amend.Id;
        test_RC_PC2Amnd.cscfga__is_active__c                =   true;
        test_RC_PC2Amnd.cscfga__Line_Item_Description__c    =   'RC Test';        
        test_RC_PC2Amnd.cscfga__Recurring__c                =   true;
        test_RC_PC2Amnd.cscfga__Price__c                    =   100;
        test_RC_PC2Amnd.cscfga__Value__c                    =   '100';
        test_RC_PC2Amnd.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_RC_PC2Amnd);

        cscfga__Attribute__c test_OC_PC3Cncl                =   new cscfga__Attribute__c();
        test_OC_PC3Cncl.Name                                =   'OC';
        test_OC_PC3Cncl.cscfga__Product_Configuration__c    =   pc3Cancel.Id;
        test_OC_PC3Cncl.cscfga__is_active__c                =   true;
        test_OC_PC3Cncl.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC3Cncl.cscfga__Recurring__c                =   false;
        test_OC_PC3Cncl.cscfga__Price__c                    =   100;
        test_OC_PC3Cncl.cscfga__Value__c                    =   '100';
        test_OC_PC3Cncl.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC3Cncl);

        cscfga__Attribute__c test_RC_PC3Cncl                =   new cscfga__Attribute__c();
        test_RC_PC3Cncl.Name                                =   'RC';
        test_RC_PC3Cncl.cscfga__Product_Configuration__c    =   pc3Cancel.Id;
        test_RC_PC3Cncl.cscfga__is_active__c                =   true;
        test_RC_PC3Cncl.cscfga__Line_Item_Description__c    =   'RC Test';        
        test_RC_PC3Cncl.cscfga__Recurring__c                =   true;
        test_RC_PC3Cncl.cscfga__Price__c                    =   100;
        test_RC_PC3Cncl.cscfga__Value__c                    =   '100';
        test_RC_PC3Cncl.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_RC_PC3Cncl);

        cscfga__Attribute__c test_OC_PC5New                =   new cscfga__Attribute__c();
        test_OC_PC5New.Name                                =   'OC';
        test_OC_PC5New.cscfga__Product_Configuration__c    =   pc5New.Id;
        test_OC_PC5New.cscfga__is_active__c                =   true;
        test_OC_PC5New.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC5New.cscfga__Recurring__c                =   false;
        test_OC_PC5New.cscfga__Price__c                    =   100;
        test_OC_PC5New.cscfga__Value__c                    =   '100';
        test_OC_PC5New.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC5New);

        cscfga__Attribute__c test_OC_PC6Cncl                =   new cscfga__Attribute__c();
        test_OC_PC6Cncl.Name                                =   'OC';
        test_OC_PC6Cncl.cscfga__Product_Configuration__c    =   pc6Cancel.Id;
        test_OC_PC6Cncl.cscfga__is_active__c                =   true;
        test_OC_PC6Cncl.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC6Cncl.cscfga__Recurring__c                =   false;
        test_OC_PC6Cncl.cscfga__Price__c                    =   100;
        test_OC_PC6Cncl.cscfga__Value__c                    =   '100';
        test_OC_PC6Cncl.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC6Cncl);


        cscfga__Attribute__c test_OC_PC7Amnd                =   new cscfga__Attribute__c();
        test_OC_PC7Amnd.Name                                =   'OC';
        test_OC_PC7Amnd.cscfga__Product_Configuration__c    =   pc7Amend.Id;
        test_OC_PC7Amnd.cscfga__is_active__c                =   true;
        test_OC_PC7Amnd.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC7Amnd.cscfga__Recurring__c                =   false;
        test_OC_PC7Amnd.cscfga__Price__c                    =   100;
        test_OC_PC7Amnd.cscfga__Value__c                    =   '100';
        test_OC_PC7Amnd.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC7Amnd);

        cscfga__Attribute__c test_RC_PC7Amnd                =   new cscfga__Attribute__c();
        test_RC_PC7Amnd.Name                                =   'RC';
        test_RC_PC7Amnd.cscfga__Product_Configuration__c    =   pc7Amend.Id;
        test_RC_PC7Amnd.cscfga__is_active__c                =   true;
        test_RC_PC7Amnd.cscfga__Line_Item_Description__c    =   'RC Test';        
        test_RC_PC7Amnd.cscfga__Recurring__c                =   true;
        test_RC_PC7Amnd.cscfga__Price__c                    =   100;
        test_RC_PC7Amnd.cscfga__Value__c                    =   '100';
        test_RC_PC7Amnd.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_RC_PC7Amnd);

        cscfga__Attribute__c test_ETC_PC7Amnd               =   new cscfga__Attribute__c();
        test_ETC_PC7Amnd.Name                               =   'ETC';
        test_ETC_PC7Amnd.cscfga__Product_Configuration__c   =   pc7Amend.Id;
        test_ETC_PC7Amnd.cscfga__is_active__c               =   true;
        test_ETC_PC7Amnd.cscfga__Line_Item_Description__c   =   'ETC Test';        
        test_ETC_PC7Amnd.cscfga__Recurring__c               =   true;
        test_ETC_PC7Amnd.cscfga__Price__c                   =   100;
        test_ETC_PC7Amnd.cscfga__Value__c                   =   '100';
        test_ETC_PC7Amnd.cscfga__List_Price__c              =   100;
        listTestAttribute.add(test_ETC_PC7Amnd);

        cscfga__Attribute__c test_RFd_PC7Amnd               =   new cscfga__Attribute__c();
        test_RFd_PC7Amnd.Name                               =   'RedeemFund';
        test_RFd_PC7Amnd.cscfga__Product_Configuration__c   =   pc7Amend.Id;
        test_RFd_PC7Amnd.cscfga__is_active__c               =   true;
        test_RFd_PC7Amnd.cscfga__Line_Item_Description__c   =   'RedeemFund Test';        
        test_RFd_PC7Amnd.cscfga__Recurring__c               =   true;
        test_RFd_PC7Amnd.cscfga__Price__c                   =   100;
        test_RFd_PC7Amnd.cscfga__Value__c                   =   '100';
        test_RFd_PC7Amnd.cscfga__List_Price__c              =   100;
        listTestAttribute.add(test_RFd_PC7Amnd);

        cscfga__Attribute__c test_OC_PC8Cncl                =   new cscfga__Attribute__c();
        test_OC_PC8Cncl.Name                                =   'OC';
        test_OC_PC8Cncl.cscfga__Product_Configuration__c    =   pc8Cancel.Id;
        test_OC_PC8Cncl.cscfga__is_active__c                =   true;
        test_OC_PC8Cncl.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC8Cncl.cscfga__Recurring__c                =   true;
        test_OC_PC8Cncl.cscfga__Price__c                    =   100;
        test_OC_PC8Cncl.cscfga__Value__c                    =   '100';
        test_OC_PC8Cncl.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC8Cncl);

        cscfga__Attribute__c test_OC_PC9New                =   new cscfga__Attribute__c();
        test_OC_PC9New.Name                                =   'OC';
        test_OC_PC9New.cscfga__Product_Configuration__c    =   pc5New.Id;
        test_OC_PC9New.cscfga__is_active__c                =   true;
        test_OC_PC9New.cscfga__Line_Item_Description__c    =   'OC Test';        
        test_OC_PC9New.cscfga__Recurring__c                =   false;
        test_OC_PC9New.cscfga__Price__c                    =   100;
        test_OC_PC9New.cscfga__Value__c                    =   '100';
        test_OC_PC9New.cscfga__List_Price__c               =   100;
        listTestAttribute.add(test_OC_PC9New);

        insert listTestAttribute; 

        List<cscfga__Attribute_Field__c> attrFieldList      =   new  List<cscfga__Attribute_Field__c>();
        cscfga__Attribute_Field__c attrField1               =   new cscfga__Attribute_Field__c();
        attrField1.name                                     =   'LineItem';
        attrField1.cscfga__Attribute__c                     =   test_ETC_PC1.id;
        attrField1.cscfga__Value__c                         =   'False';
        attrFieldList.add(attrField1);
        cscfga__Attribute_Field__c attrField2               =   new cscfga__Attribute_Field__c();
        attrField2.name                                     =   'LineItem';
        attrField2.cscfga__Attribute__c                     =   test_OC_PC1.id;
        attrField2.cscfga__Value__c                         =   'True'; 
        attrFieldList.add(attrField2);
        cscfga__Attribute_Field__c attrField3               =   new cscfga__Attribute_Field__c();
        attrField3.name                                     =   'LineItem';
        attrField3.cscfga__Attribute__c                     =   test_OC_PC2.id;
        attrField3.cscfga__Value__c                         =   'True';
        attrFieldList.add(attrField3);
        cscfga__Attribute_Field__c attrField4               =   new cscfga__Attribute_Field__c();
        attrField4.name                                     =   'LineItem';
        attrField4.cscfga__Attribute__c                     =   test_OC_PC3.id;
        attrField4.cscfga__Value__c                         =   'True';
        attrFieldList.add(attrField4);
        cscfga__Attribute_Field__c attrField5               =   new cscfga__Attribute_Field__c();
        attrField5.name                                     =   'LineItem';
        attrField5.cscfga__Attribute__c                     =   test_RC_PC3.id;
        attrField5.cscfga__Value__c                         =   'True';
        attrFieldList.add(attrField5);
        cscfga__Attribute_Field__c attrField6               =   new cscfga__Attribute_Field__c();
        attrField6.name                                     =   'LineItem';
        attrField6.cscfga__Attribute__c                     =   test_OC_PC4.id;
        attrField6.cscfga__Value__c                         =   'True';
        attrFieldList.add(attrField6);
        cscfga__Attribute_Field__c attrField7               =   new cscfga__Attribute_Field__c();
        attrField7.name                                     =   'LineItem';
        attrField7.cscfga__Attribute__c                     =   test_ETC_PC1Amnd.id;
        attrField7.cscfga__Value__c                         =   'False';
        attrFieldList.add(attrField7);
        cscfga__Attribute_Field__c attrField8               =   new cscfga__Attribute_Field__c();
        attrField8.name                                     =   'LineItem';
        attrField8.cscfga__Attribute__c                     =   test_OC_PC1Amnd.id;
        attrField8.cscfga__Value__c                         =   'True';
        attrFieldList.add(attrField8);
        cscfga__Attribute_Field__c attrField9               =   new cscfga__Attribute_Field__c();
        attrField9.name                                     =   'LineItem';
        attrField9.cscfga__Attribute__c                     =   test_RC_PC1Amnd.id;
        attrField9.cscfga__Value__c                         =   'True';
        attrFieldList.add(attrField9);
        cscfga__Attribute_Field__c attrField10              =   new cscfga__Attribute_Field__c();
        attrField10.name                                    =   'LineItem';
        attrField10.cscfga__Attribute__c                    =   test_OC_PC2Amnd.id;
        attrField10.cscfga__Value__c                        =   'False';
        attrFieldList.add(attrField10);
        cscfga__Attribute_Field__c attrField11              =   new cscfga__Attribute_Field__c();
        attrField11.name                                    =   'LineItem';
        attrField11.cscfga__Attribute__c                    =   test_RC_PC2Amnd.id;
        attrField11.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField11);
        cscfga__Attribute_Field__c attrField12              =   new cscfga__Attribute_Field__c();
        attrField12.name                                    =   'LineItem';
        attrField12.cscfga__Attribute__c                    =   test_OC_PC3Cncl.id;
        attrField12.cscfga__Value__c                        =   'False';
        attrFieldList.add(attrField12);
        cscfga__Attribute_Field__c attrField13              =   new cscfga__Attribute_Field__c();
        attrField13.name                                    =   'LineItem';
        attrField13.cscfga__Attribute__c                    =   test_RC_PC3Cncl.id;
        attrField13.cscfga__Value__c                        =   'False';
        attrFieldList.add(attrField13);
        cscfga__Attribute_Field__c attrField14              =   new cscfga__Attribute_Field__c();
        attrField14.name                                    =   'LineItem';
        attrField14.cscfga__Attribute__c                    =   test_OC_PC5New.id;
        attrField14.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField14);
        cscfga__Attribute_Field__c attrField15              =   new cscfga__Attribute_Field__c();
        attrField15.name                                    =   'LineItem';
        attrField15.cscfga__Attribute__c                    =   test_OC_PC6.id;
        attrField15.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField15);
        cscfga__Attribute_Field__c attrField16              =   new cscfga__Attribute_Field__c();
        attrField16.name                                    =   'LineItem';
        attrField16.cscfga__Attribute__c                    =   test_OC_PC6Cncl.id;
        attrField16.cscfga__Value__c                        =   'False';
        attrFieldList.add(attrField16);
        cscfga__Attribute_Field__c attrField18              =   new cscfga__Attribute_Field__c();
        attrField18.name                                    =   'LineItem';
        attrField18.cscfga__Attribute__c                    =   test_OC_PC7.id;
        attrField18.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField18);
        cscfga__Attribute_Field__c attrField19              =   new cscfga__Attribute_Field__c();
        attrField19.name                                    =   'LineItem';
        attrField19.cscfga__Attribute__c                    =   test_OC_PC8.id;
        attrField19.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField19);
        cscfga__Attribute_Field__c attrField20              =   new cscfga__Attribute_Field__c();
        attrField20.name                                    =   'LineItem';
        attrField20.cscfga__Attribute__c                    =   test_OC_PC7Amnd.id;
        attrField20.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField20);
        cscfga__Attribute_Field__c attrField21              =   new cscfga__Attribute_Field__c();
        attrField21.name                                    =   'LineItem';
        attrField21.cscfga__Attribute__c                    =   test_RC_PC7Amnd.id;
        attrField21.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField21);
        cscfga__Attribute_Field__c attrField22              =   new cscfga__Attribute_Field__c();
        attrField22.name                                    =   'LineItem';
        attrField22.cscfga__Attribute__c                    =   test_OC_PC8Cncl.id;
        attrField22.cscfga__Value__c                        =   'False';
        attrFieldList.add(attrField22);
        cscfga__Attribute_Field__c attrField23              =   new cscfga__Attribute_Field__c();
        attrField23.name                                    =   'LineItem';
        attrField23.cscfga__Attribute__c                    =   test_OC_PC9New.id;
        attrField23.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField23);
        cscfga__Attribute_Field__c attrField24              =   new cscfga__Attribute_Field__c();
        attrField24.name                                    =   'LineItem';
        attrField24.cscfga__Attribute__c                    =   test_ETC_PC7.id;
        attrField24.cscfga__Value__c                        =   'True';
        attrFieldList.add(attrField24);
        cscfga__Attribute_Field__c attrField25              =   new cscfga__Attribute_Field__c();
        attrField25.name                                    =   'LineItem';
        attrField25.cscfga__Attribute__c                    =   test_ETC_PC7Amnd.id;
        attrField25.cscfga__Value__c                        =   'False';
        attrFieldList.add(attrField25);
        insert attrFieldList;
        
        Product2 prodct2    =   new Product2();
        prodct2.Family      =   'Modular'; 
        prodct2.IsActive    =   true;
        prodct2.Name        =   'Test';
        prodct2.ProductCode =   'test';
        insert prodct2;
        
        PricebookEntry Pbe  =   new PricebookEntry();
        Pbe.Product2Id      =   prodct2.id;
        Pbe.Pricebook2Id    =   standardPBID;
        Pbe.UnitPrice       =   1.0;
        Pbe.isActive        =   true;
        insert pbe;
        
        list<opportunitylineitem> oliList   =   new list<opportunitylineitem>();
        opportunitylineitem oli1            =   new Opportunitylineitem();
        oli1.OpportunityId                  =   testOpp.id;
        oli1.Product2Id                     =   prodct2.id;
        oli1.Product_Configuration__c       =   pc1.id;
        oli1.cscfga__Attribute__c           =   test_OC_PC1.id;
        oli1.PricebookEntryId               =   pbe.id;
        oli1.Quantity                       =   1;
        oli1.TotalPrice                     =   12;
        oliList.add(oli1);
        opportunitylineitem oli2            =   new Opportunitylineitem();
        oli2.OpportunityId                  =   testOpp.id;
        oli2.Product2Id                     =   prodct2.id;
        oli2.Product_Configuration__c       =   pc2.id;
        oli2.cscfga__Attribute__c           =   test_OC_PC2.id;
        oli2.PricebookEntryId               =   pbe.id;
        oli2.Quantity                       =   1;
        oli2.TotalPrice                     =   12;
        oliList.add(oli2);
        opportunitylineitem oli3            =   new Opportunitylineitem();
        oli3.OpportunityId                  =   testOpp.id;
        oli3.Product2Id                     =   prodct2.id;
        oli3.Product_Configuration__c       =   pc3.id;
        oli3.cscfga__Attribute__c           =   test_OC_PC3.id;
        oli3.PricebookEntryId               =   pbe.id;
        oli3.Quantity                       =   1;
        oli3.TotalPrice                     =   12;
        oliList.add(oli3);
        opportunitylineitem oli4            =   new Opportunitylineitem();
        oli4.OpportunityId                  =   testOpp.id;
        oli4.Product2Id                     =   prodct2.id;
        oli4.Product_Configuration__c       =   pc3.id;
        oli4.cscfga__Attribute__c           =   test_RC_PC3.id;
        oli4.PricebookEntryId               =   pbe.id;
        oli4.Quantity                       =   1;
        oli4.TotalPrice                     =   12;
        oliList.add(oli4);
        opportunitylineitem oli5            =   new Opportunitylineitem();
        oli5.OpportunityId                  =   testOpp.id;
        oli5.Product2Id                     =   prodct2.id;
        oli5.Product_Configuration__c       =   pc4.id;
        oli5.cscfga__Attribute__c           =   test_OC_PC4.id;
        oli5.PricebookEntryId               =   pbe.id;
        oli5.Quantity                       =   1;
        oli5.TotalPrice                     =   12;
        oliList.add(oli5);
        opportunitylineitem oli6            =   new Opportunitylineitem();
        oli6.OpportunityId                  =   testOpp1.id;
        oli6.Product2Id                     =   prodct2.id;
        oli6.Product_Configuration__c       =   pc6.id;
        oli6.cscfga__Attribute__c           =   test_OC_PC6.id;
        oli6.PricebookEntryId               =   pbe.id;
        oli6.Quantity                       =   1;
        oli6.TotalPrice                     =   12;
        oliList.add(oli6);
        opportunitylineitem oli7            =   new Opportunitylineitem();
        oli7.OpportunityId                  =   testOpp2.id;
        oli7.Product2Id                     =   prodct2.id;
        oli7.Product_Configuration__c       =   pc7Amend.id;
        oli7.cscfga__Attribute__c           =   test_OC_PC7Amnd.id;
        oli7.PricebookEntryId               =   pbe.id;
        oli7.Quantity                       =   1;
        oli7.TotalPrice                     =   12;
        oliList.add(oli7);
        opportunitylineitem oli8            =   new Opportunitylineitem();
        oli8.OpportunityId                  =   testOpp2.id;
        oli8.Product2Id                     =   prodct2.id;
        oli8.Product_Configuration__c       =   pc7Amend.id;
        oli8.cscfga__Attribute__c           =   test_RC_PC7Amnd.id;
        oli8.PricebookEntryId               =   pbe.id;
        oli8.Quantity                       =   1;
        oli8.TotalPrice                     =   12;
        oliList.add(oli8);
        opportunitylineitem oli9            =   new Opportunitylineitem();
        oli9.OpportunityId                  =   testOpp2.id;
        oli9.Product2Id                     =   prodct2.id;
        oli9.Product_Configuration__c       =   pc8Cancel.id;
        oli9.cscfga__Attribute__c           =   test_OC_PC8Cncl.id;
        oli9.PricebookEntryId               =   pbe.id;
        oli9.Quantity                       =   1;
        oli9.TotalPrice                     =   12;
        oliList.add(oli9);
        opportunitylineitem oli10           =   new Opportunitylineitem();
        oli10.OpportunityId                 =   testOpp2.id;
        oli10.Product2Id                    =   prodct2.id;
        oli10.Product_Configuration__c      =   pc9New.id;
        oli10.cscfga__Attribute__c          =   test_OC_PC9New.id;
        oli10.PricebookEntryId              =   pbe.id;
        oli10.Quantity                      =   1;
        oli10.TotalPrice                    =   12;
        oliList.add(oli10);
        opportunitylineitem oli11           =   new Opportunitylineitem();
        oli11.OpportunityId                 =   testOpp2.id;
        oli11.Product2Id                    =   prodct2.id;
        oli11.Product_Configuration__c      =   pc7Amend.id;
        oli11.cscfga__Attribute__c          =   test_ETC_PC7Amnd.id;
        oli11.PricebookEntryId              =   pbe.id;
        oli11.Quantity                      =   1;
        oli11.TotalPrice                    =   12;
        oliList.add(oli11);
        insert oliList;           
    }

    @isTest
    static void unitTest1() {
        List<cscfga__Product_Basket__c> basketTest = [SELECT Id,name,cscfga__Opportunity__c,Primary_Basket__c,csbb__Synchronised_with_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c where Amend_Type__c = 'Commercial'];
        Test.startTest();

        Set<String> prdbskids = new Set<String>();
        for(cscfga__Product_Basket__c oPB : basketTest) {
            system.debug('oPB**** ' + oPB);
            System.assertNotEquals(true, oPB.Primary_Basket__c, 'Basket is not Primary Basket');
            System.assertNotEquals(true, oPB.csbb__Synchronised_with_Opportunity__c, 'Basket is not Synchronised with Opportunity');
            System.assertNotEquals(true, oPB.csordtelcoa__Synchronised_with_Opportunity__c,'Basket is not Synchronised with Opportunity');
            prdbskids.add(oPB.Id);
        }
        InflightSyncBatch inf = new InflightSyncBatch(prdbskids);
        System.assertEquals(3, prdbskids.size());
        //Submitting the basket for the 1st time
        database.executeBatch(inf);
        //Re-Submitting the basket for the 2nd time
        List<cscfga__Product_Basket__c> lstBasketPostSubmit = [SELECT Id,name,cscfga__Opportunity__c,Primary_Basket__c,csbb__Synchronised_with_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c where Id IN:prdbskids];
        for(cscfga__Product_Basket__c oPB : lstBasketPostSubmit) {
            oPB.csordtelcoa__Basket_Stage__c = 'Enriched';
        }
        update lstBasketPostSubmit;
        database.executeBatch(inf);
        Test.stopTest();
    } 

    @isTest
    static void unitTest2() {
        InflightProductUtilityForModular.ProdConfigOLIWrapper oPCOLIWrapper = new InflightProductUtilityForModular.ProdConfigOLIWrapper();
        List<cscfga__Product_Basket__c> basketTest = [SELECT Id,name,cscfga__Opportunity__c,Primary_Basket__c,csbb__Synchronised_with_Opportunity__c,
        csordtelcoa__Synchronised_with_Opportunity__c,(select Id from cscfga__Product_Configurations__r) 
        FROM cscfga__Product_Basket__c where Amend_Type__c = 'Commercial'];
        Test.startTest();

        Set<String> prdbskids = new Set<String>();
        for(cscfga__Product_Basket__c oPB : basketTest) {
            system.debug('oPB**** ' + oPB);
            System.assertNotEquals(true, oPB.Primary_Basket__c, 'Basket is not Primary Basket');
            System.assertNotEquals(true, oPB.csbb__Synchronised_with_Opportunity__c, 'Basket is not Synchronised with Opportunity');
            System.assertNotEquals(true, oPB.csordtelcoa__Synchronised_with_Opportunity__c,'Basket is not Synchronised with Opportunity');
            if(oPB.cscfga__Product_Configurations__r.size()==1)
            prdbskids.add(oPB.Id);
        }
        InflightSyncBatch inf = new InflightSyncBatch(prdbskids);
        System.assertEquals(1, prdbskids.size());
        StaticUtilForRecursion.checkInflightSync    =   true;  
        List<cscfga__Product_Basket__c> lstBasketPostSubmit = [SELECT Id,name,cscfga__Opportunity__c,Primary_Basket__c,csbb__Synchronised_with_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c where Id IN:prdbskids];
        for(cscfga__Product_Basket__c oPB : lstBasketPostSubmit) {
            oPB.csordtelcoa__Basket_Stage__c = 'Enriched';
        }
        update lstBasketPostSubmit;
        database.executeBatch(inf);
    } 
    
    @isTest
    static void negativeCase1() {       
        Test.startTest();
        list<opportunityLineItem> OliList = new list<opportunityLineItem>();
        cscfga__Attribute__c attr = [select id,cscfga__Product_Configuration__c from cscfga__Attribute__c limit 1];
        opportunity testOpp = [select id from opportunity limit 1];
        product2 prodct2 = [select id from product2 limit 1];
        pricebookentry pbe = [select id from pricebookentry limit 1];
        Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper> newPCIdOLIWrapperMap = new Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper>();
        opportunitylineitem oli4            =   new Opportunitylineitem();
        oli4.OpportunityId                  =   testOpp.id;
        oli4.Product2Id                     =   prodct2.id;
        oli4.Product_Configuration__c       =   attr.cscfga__Product_Configuration__c;
        oli4.cscfga__Attribute__c           =   attr.id;
        oli4.PricebookEntryId               =   pbe.id;
        oli4.Order_Type__c                  =   'New';
        oli4.Quantity                       =   1;
        oli4.TotalPrice                     =   12;
        OliList.add(oli4);
        InflightProductUtilityForModular.ProdConfigOLIWrapper oPcWrapper =   new InflightProductUtilityForModular.ProdConfigOLIWrapper('Inflight Amend','Won','Added','',attr.cscfga__Product_Configuration__c,attr.cscfga__Product_Configuration__c,attr.id,OliList[0]);
        newPCIdOLIWrapperMap.put(attr.cscfga__Product_Configuration__c+'_'+attr.id,oPcWrapper);
        insert OliList;
        InflightProductUtilityForModular.processOLIs(OliList,newPCIdOLIWrapperMap,null);
        List<OpportunityLineItem> oliAfterSync = [SELECT Id,Status__c,Product_Status__c,Order_Type__c FROM OpportunityLineItem WHERE Id=:oli4.Id];
        System.assertEquals(oliAfterSync[0].Status__c, 'Added');
        System.assertEquals(oliAfterSync[0].Product_Status__c, 'Won');
        Map<Id,cscfga__Product_Basket__c> updatebasketMap  =   new Map<Id,cscfga__Product_Basket__c>();
        Set<Id> oppIdSet    =   new Set<Id>();
        for(cscfga__Product_Basket__c oPB : [SELECT Id,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__c,cscfga__total_contract_value__c,Primary_Basket__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c,cscfga__Opportunity__r.Product_Type__c FROM cscfga__Product_Basket__c]) {
            updatebasketMap.put(oPB.Id,oPB);
            oppIdSet.add(oPB.cscfga__Opportunity__c);
        }
        BasketOpportunityUpdateHelper.updateOpportunityDetails(updatebasketMap,oppIdSet);
        Test.stopTest();       
    }

    @isTest
    static void negativeCase2() {
        List<cscfga__Product_Basket__c> basketTest = [SELECT Id,name,cscfga__Opportunity__c,Primary_Basket__c,csbb__Synchronised_with_Opportunity__c,
        csordtelcoa__Synchronised_with_Opportunity__c,(select Id from cscfga__Product_Configurations__r) 
        FROM cscfga__Product_Basket__c where Amend_Type__c = 'Commercial'];
        Test.startTest();

        Set<String> prdbskids = new Set<String>();
        for(cscfga__Product_Basket__c oPB : basketTest) {
            system.debug('oPB**** ' + oPB);
            System.assertNotEquals(true, oPB.Primary_Basket__c, 'Basket is not Primary Basket');
            System.assertNotEquals(true, oPB.csbb__Synchronised_with_Opportunity__c, 'Basket is not Synchronised with Opportunity');
            System.assertNotEquals(true, oPB.csordtelcoa__Synchronised_with_Opportunity__c,'Basket is not Synchronised with Opportunity');
            if(oPB.cscfga__Product_Configurations__r.size()==1)
            prdbskids.add(oPB.Id);
        }
        InflightSyncBatch inf = new InflightSyncBatch(prdbskids);
        System.assertEquals(1, prdbskids.size());
        //EDGE:205509 Commented
        //InflightProductUtilityForModular.failedBasketIds = prdbskids;
        database.executeBatch(inf);
    } 
    
}