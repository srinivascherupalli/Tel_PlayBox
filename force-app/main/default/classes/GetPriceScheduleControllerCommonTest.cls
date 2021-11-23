/*
* @Author : Shubhi
* @Date : 12 March 2020
* @Desc : GetPriceScheduleController (new Component)
* @Jira : Edge-143527
* @testclass : GetPriceScheduleControllerCommonTest
// Added by Aman Soni as a part of EDGE-143527
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.      Shubhi              23/04/2020      Edge-120919
2.        Gnana            30-apr-2020      EDGE-140967-Enabling Redemption as Discount for Device Payout on EM
3.     Pawan Singh         09/08/2021       DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
===============================================================================================================================
*/
@isTest
global class GetPriceScheduleControllerCommonTest{
    //Method for test data Setup
    // Modified by Aman Soni as a part of EDGE-143527 || Start
    @TestSetup static void CreateData(){
        
       Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        insert testOppty;
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        insert testBasket;
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];//Added by Aman Soni as a part of EDGE-143527
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c pINGUCDevice =PricingTestDataFactory.generateNGUCPriceItem_discount('Next Generation device','Purchase','DMCAT_RecurringCharge_000814');
        price_item_List.add(pINGUCDevice);
        cspmb__Price_Item__c price_item_1 = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5177');
        price_item_List.add(price_item_1);
        cspmb__Price_Item__c FairPlayPI =PricingTestDataFactory.generateMobilePriceItemFairPlay('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_7206');
        price_item_List.add(FairPlayPI);
        cspmb__Price_Item__c price_item2 =PricingTestDataFactory.generateNGUCPriceItem_discount('Unified Communication Device','Rental','DMCAT_RecurringCharge_000858');
        price_item_List.add(price_item2);
        cspmb__Price_Item__c price_item_V = PricingTestDataFactory.generateNGUCPriceItem_Voice('Next Generation Voice','DMCAT_RecurringCharge_000814');
        price_item_List.add(price_item_V);
        insert price_item_List;
          
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;
        
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level_1 = PricingTestDataFactory.generateDiscountLevelPlan('DummyForTestClass', 'Dummy', testAccount,'Purchase','');
        dlList.add(discount_level_1);
        cspmb__Discount_Level__c discount_level2 = PricingTestDataFactory.generateDiscountLevelPlan('IDD callpack','DMCAT_Discount_000957',testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level2);
        
        cspmb__Discount_Level__c dliMMC = PricingTestDataFactory.generateDiscountLevelPlan('MMC Discount', 'DMCAT_Discount_000961', testAccount,'Data SIM $5','3 GB');
        dlList.add(dliMMC);
        
        cspmb__Discount_Level__c dliAC = PricingTestDataFactory.generateDiscountLevelPlan('Activation Credits Months Discount', 'DMCAT_Discount_000951', testAccount,'Data SIM $5','3 GB');
        dlList.add(dliAC);
        
        cspmb__Discount_Level__c dliMRO = PricingTestDataFactory.generateDiscountLevelPlan('Postpaid MRO Plan Discount','', testAccount,'Data SIM $5','3 GB');
        dlList.add(dliMRO);
        
        cspmb__Discount_Level__c discount_levelv = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', testAccount,'Purchase','');
        dlList.add(discount_levelv);
        cspmb__Discount_Level__c discount_level3 = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', null,'rental','');
        discount_level2.Is_Delegated__c=false;
        dlList.add(discount_level3);
        insert dlList;
        
        List<cspmb__Discount_Association__c> DAList=new List<cspmb__Discount_Association__c>();
        cspmb__Discount_Association__c DisAssoc = PricingTestDataFactory.generateDiscountAssociation2(pINGUCDevice,null,discount_level_1);
        cspmb__Discount_Association__c DisAssoc1 = PricingTestDataFactory.generateDiscountAssociation2(pINGUCDevice,null,discount_levelv);
        cspmb__Discount_Association__c DisAssoc2 = PricingTestDataFactory.generateDiscountAssociation2(null,addon,discount_level2);
        cspmb__Discount_Association__c DisAssoc3 = PricingTestDataFactory.generateDiscountAssociation2(FairPlayPI,null,dliMMC);
        cspmb__Discount_Association__c DisAssoc4 = PricingTestDataFactory.generateDiscountAssociation2(FairPlayPI,null,dliAC);
        cspmb__Discount_Association__c DisAssoc5 = PricingTestDataFactory.generateDiscountAssociation2(FairPlayPI,null,dliMRO);
        DAList.add(DisAssoc);
        DAList.add(DisAssoc1);
        DAList.add(DisAssoc2);
        DAList.add(DisAssoc3);
        DAList.add(DisAssoc4);
        DAList.add(DisAssoc5);
        insert DAList;
        
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');  DIGI-5648
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');  
        solutionList.add(solutionV); 
        csord__Solution__c solution1 = PricingTestDataFactory.generateSolution('Enterprise Mobility (2)');  
        solutionList.add(solution1);
        // csord__Solution__c solution2 = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution2');  DIGI-5648
        csord__Solution__c solution2 = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution2');  
        solutionList.add(solution2);
        // csord__Solution__c solutionV2 = PricingTestDataFactory.generateSolution('Telstra Collaboration SolutionV2'); DIGI-5648 
        csord__Solution__c solutionV2 = PricingTestDataFactory.generateSolution('Adaptive Collaboration SolutionV2');  
        solutionList.add(solutionV2);
        csord__Solution__c solution3 = PricingTestDataFactory.generateSolution('Enterprise Mobility');  
        solutionList.add(solution3);        
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solution1.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.ID,addon.id));
        attList.add(att2);
        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCSolutionString(pINGUCDevice.id));
        attList.add(attV);
        Attachment att3 = PricingTestDataFactory.generateSolutionAttachment(solution2.id,SolutionAttachmentTestDataFactory.generateNGUCSolutionString(price_item2.id));
        attList.add(att3);
        Attachment attV2=PricingTestDataFactory.generateSolutionAttachment(solutionV2.id,SolutionAttachmentTestDataFactory.generateNGUCVoiceSolutionString(price_item_V.id));
        attList.add(attV2);
        Attachment att4=PricingTestDataFactory.generateSolutionAttachment(solution3.id,SolutionAttachmentTestDataFactory.generateSolutionString(FairPlayPI.ID,addon.id));
        attList.add(att4);
        insert attList;
    
      
        //added for edge-121376
        ///RateCard
         List<cspmb__Rate_Card__c> rateCardList=new List<cspmb__Rate_Card__c>();
        cspmb__Rate_Card__c rc=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000814');
        rateCardList.add(rc);
        cspmb__Rate_Card__c rc1=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000810');
        rateCardList.add(rc1);
        cspmb__Rate_Card__c rc2=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000811');
        rateCardList.add(rc2);
        cspmb__Rate_Card__c rc3=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000813');
        rateCardList.add(rc3);
        cspmb__Rate_Card__c rc4=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000816');
        rateCardList.add(rc4);
        cspmb__Rate_Card__c rc5=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000808');
        rateCardList.add(rc5);
        insert rateCardList;
        //rateCardLine
        List<cspmb__Rate_Card_Line__c> rateCardLineList=new List<cspmb__Rate_Card_Line__c>();
        cspmb__Rate_Card_Line__c rcl=PricingTestDataFactory.generateRateCardLine(1,10,rc.id,'Standard');
        rateCardLineList.add(rcl);
        cspmb__Rate_Card_Line__c rcl1=PricingTestDataFactory.generateRateCardLine(11,20,rc.id,'Standard');
        rateCardLineList.add(rcl1);
        cspmb__Rate_Card_Line__c rcl2=PricingTestDataFactory.generateRateCardLine(1,10,rc2.id,'Standard');
        rateCardLineList.add(rcl2);
        cspmb__Rate_Card_Line__c rcl3=PricingTestDataFactory.generateRateCardLine(1,10,rc3.id,'Standard');
        rateCardLineList.add(rcl3);
        cspmb__Rate_Card_Line__c rcl4=PricingTestDataFactory.generateRateCardLine(1,10,rc4.id,'Standard');
        rateCardLineList.add(rcl4);
        cspmb__Rate_Card_Line__c rcl5=PricingTestDataFactory.generateRateCardLine(1,10,rc5.id,'Standard');
        rateCardLineList.add(rcl5);
        insert rateCardLineList;   
       // edge-121376 end
    }// Modified by Aman Soni as a part of EDGE-143527 || End
    
    // Added by Aman Soni as a part of EDGE-143527 || Start
     @isTest
    public static void TestonLoadEM(){
        Test.startTest();

          User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
          csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (2)' limit 1];
          account acc=[Select id from account limit 1];
          String solutionName='Mobile Subscription';
          cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){  
          Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);    
          String JsonString=JSON.serialize(guidToAttMapofMap);
          GetPriceScheduleControllerCommon.onLoadMethod(JsonString,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'true');// Pass extra parameter by gnana as part of  EDGE-140967        
          System.assertEquals('Initial',GetPriceScheduleControllerCommon.DiscountApplicableStatus);
        }
       Test.stopTest();        

    }
    // Added by Aman Soni as a part of EDGE-143527 || End
    
    // Added by Aman Soni as a part of EDGE-143527 || Start
     @isTest
    public static void TestonLoadEMApplicable(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
          csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility' limit 1];
          account acc=[Select id from account limit 1];
          String solutionName='Mobile Subscription';
          cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){  
          Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);    
          String JsonString=JSON.serialize(guidToAttMapofMap);
          GetPriceScheduleControllerCommon.onLoadMethod(JsonString,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'false'); // Pass extra parameter by gnana as part of  EDGE-140967       
          System.assertEquals('Discount Applicable',GetPriceScheduleControllerCommon.DiscountApplicableStatus);
        }
       Test.stopTest();        

    }
    // Added by Aman Soni as a part of EDGE-143527 || End
    
      @isTest
    public static void TestonLoadNGUCDevice(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
          // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
          csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
          account acc=[Select id from account limit 1];
          String solutionName='Unified Communication Device';
          cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){  
          Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);    
      String JsonString=JSON.serialize(guidToAttMapofMap);
          GetPriceScheduleControllerCommon.onLoadMethod(JsonString,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'false');  // Pass extra parameter by gnana as part of  EDGE-140967      
          System.assertEquals('Discount Applicable',GetPriceScheduleControllerCommon.DiscountApplicableStatus);
        }
       Test.stopTest();        

    }
     
    @isTest
    public static void TestonLoadNGUCVoice(){
         Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        //  csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration SolutionV2' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration SolutionV2' limit 1];
        account acc=[Select id from account limit 1];
        String solutionName='Business Calling'; //Edge-120919
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
          Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);    
      string JsonString=JSON.serialize(guidToAttMapofMap);
          GetPriceScheduleControllerCommon.onLoadMethod(JsonString,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'false');    // Pass extra parameter by gnana as part of  EDGE-140967    
          System.assertEquals('No discount applicable',GetPriceScheduleControllerCommon.DiscountApplicableStatus);  
        }
        Test.stopTest();   
     }
    
    @isTest
    public static void TestonLoadNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        //account acc=[Select id from account limit 1];
        String solutionName='Unified Communication Device';
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
           Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;//GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
      GetPriceScheduleControllerCommon.onLoadMethod('',testBasket.id,'',sol.id,'true', solutionName,testBasket.Basket_Number__c,'true'); // Pass extra parameter by gnana as part of  EDGE-140967
          System.assertEquals('Initial',GetPriceScheduleControllerCommon.DiscountApplicableStatus);
        }
        Test.stopTest();        
    }

}