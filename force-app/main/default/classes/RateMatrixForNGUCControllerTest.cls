/*
* @Author : Shubhi
* @Date : 12 March 2020
* @Desc : RateMatrixForNGUCController for display rate and discount data   
* @Jira : Edge-133882
* @testclass : RateMatrixForNGUCControllerTest
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description 
1         Shubhi                  30/3/2020       EDGE-140157
2.        Aditya                  28/4/2020       Edge-120919
3.        Gokul                   05/11/2020      EDGE-185639
4.        Jagadeswary             17/03/2021      EDGE-207998 
5.        Pawan Singh             09/08/2021      DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
===============================================================================================================================
*/
@IsTest
public class RateMatrixForNGUCControllerTest {

    @TestSetup static void testdata(){       
         Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        upsert testBasket;

        
        //POrice item
        //Edge-120919 NGUC consumption based Model-New
        cspmb__Price_Item__c price_item_V = PricingTestDataFactory.generateNGUCPriceItem_Voice(System.Label.BusinessCalling,'DMCAT_RecurringCharge_000814');
        cspmb__Price_Item__c price_item_V2 = PricingTestDataFactory.generateNGUCPriceItem_Voice('Feature Usage Charges','DMCAT_RecurringCharge_000813');
        insert price_item_V2;
        price_item_V.cspmb__master_price_item__c = price_item_V2.id;
        price_item_V.External_Id__c = 'dmcat_11211';
        price_item_V.Offer_Id__c = 'DMCAT_Offer_000618';
        price_item_V.Mode__c = 'Shared line';
        price_item_V.Plan__c = 'Standard';
        price_item_V.cspmb__Effective_End_Date__c = Date.today().addDays(5);
        price_item_V.cspmb__Effective_Start_Date__c = Date.today().addDays(-5);
        price_item_V.cspmb__Is_Active__c = true;
        insert price_item_V; 
        
        // Create test Discount Level
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level2 = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', null,'rental','');
        discount_level2.Is_Delegated__c=false;
        dlList.add(discount_level2);    
        insert dlList;
        
        // Create test Solution
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');   DIGI-5648
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');  
        solutionList.add(solutionV);        
        insert solutionList;    
                
        // Create json solution attachment
        List<Attachment> attList =new List<Attachment>();
        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCVoiceSolutionString(price_item_V.id));
        attList.add(attV);
        insert attList;
        
        
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
        //edge-120919 start
        List<cspmb__Rate_Card_Line__c> rateCardLineList=new List<cspmb__Rate_Card_Line__c>();
        cspmb__Rate_Card_Line__c rcl=PricingTestDataFactory.generateRateCardLine(1,10,rc.id,'StandardShared line');
        rateCardLineList.add(rcl);
        cspmb__Rate_Card_Line__c rcl1=PricingTestDataFactory.generateRateCardLine(11,20,rc.id,'StandardShared line');
        rateCardLineList.add(rcl1);
        cspmb__Rate_Card_Line__c rcl2=PricingTestDataFactory.generateRateCardLine(1,10,rc2.id,'StandardShared line');
        rateCardLineList.add(rcl2);
        cspmb__Rate_Card_Line__c rcl3=PricingTestDataFactory.generateRateCardLine(1,10,rc3.id,'StandardShared line');
        rateCardLineList.add(rcl3);
        cspmb__Rate_Card_Line__c rcl4=PricingTestDataFactory.generateRateCardLine(1,10,rc4.id,'StandardShared line');
        rateCardLineList.add(rcl4);
        cspmb__Rate_Card_Line__c rcl5=PricingTestDataFactory.generateRateCardLine(1,10,rc5.id,'StandardShared line');
        rateCardLineList.add(rcl5);
        insert rateCardLineList; 
        
        List<cspmb__Price_Item_Rate_Card_Association__c> cppraList = new List<cspmb__Price_Item_Rate_Card_Association__c>();
        cspmb__Price_Item_Rate_Card_Association__c cppra = new cspmb__Price_Item_Rate_Card_Association__c();
        cppra.cspmb__Price_Item__c = price_item_V.id;
        cppra.cspmb__Rate_Card__c = rc.id;
        cppraList.add(cppra);
        cspmb__Price_Item_Rate_Card_Association__c cppra1 = new cspmb__Price_Item_Rate_Card_Association__c();
        cppra.cspmb__Price_Item__c = price_item_V2.id;
        cppra.cspmb__Rate_Card__c = rc1.id;
        cppraList.add(cppra1);
        cspmb__Price_Item_Rate_Card_Association__c cppra2 = new cspmb__Price_Item_Rate_Card_Association__c();
        cppra.cspmb__Price_Item__c = price_item_V2.id;
        cppra.cspmb__Rate_Card__c = rc2.id;
        cppraList.add(cppra2);
        cspmb__Price_Item_Rate_Card_Association__c cppra3 = new cspmb__Price_Item_Rate_Card_Association__c();
        cppra.cspmb__Price_Item__c = price_item_V2.id;
        cppra.cspmb__Rate_Card__c = rc3.id;
        cppraList.add(cppra3);
        cspmb__Price_Item_Rate_Card_Association__c cppra4 = new cspmb__Price_Item_Rate_Card_Association__c();
        cppra.cspmb__Price_Item__c = price_item_V2.id;
        cppra.cspmb__Rate_Card__c = rc4.id;
        cppraList.add(cppra4);
        cspmb__Price_Item_Rate_Card_Association__c cppra5 = new cspmb__Price_Item_Rate_Card_Association__c();
        cppra.cspmb__Price_Item__c = price_item_V2.id;
        cppra.cspmb__Rate_Card__c = rc5.id;
        cppraList.add(cppra5);
        insert cppraList;
        
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];//Added by Aman Soni as a part of EDGE-143527
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        //edge-1209191 end
    }
         //Edge-133882 added by Shubhi start  
    @IsTest
      public static void getRateCard_DiscountsTest()
      { 
          Test.startTest();
          //EDGE-185639
          List<csord__Solution__c> solutionList = [ SELECT Id FROM csord__Solution__c ];
          string jsonsios = '';
          User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; //Added by Aman Soni as a part of EDGE-143527      
          System.runAs(sales){
              //EDGE-185639
              RateDiscountCardDTO rateCardDto=RateMatrixForNGUCController.getRateCard_Discounts('Standard','DMCAT_Offer_000618',solutionList[0].Id,'New','','Shared line',jsonsios);
              Map<String,List<ChargeRateCardDTO>> ratecardMap=rateCardDto.RateCardMap;
              //EDGE-185639
              RateDiscountCardDTO rateCardDto1=RateMatrixForNGUCController.getRateCard_Discounts('Standard','DMCAT_Offer_000618',solutionList[0].Id,'New','','Shared line',jsonsios) ;
              Map<String,List<ChargeRateCardDTO>> ratecardMap1=rateCardDto.RateCardMap;
              List<DiscountDTO> disDTO=rateCardDto.discountDTOList;
              System.assertEquals('Early Adopter Discount',disDTO[0].discountName);
         }
          Test.stopTest();
      }
    @IsTest
      public static void getRateCard_DiscountsTestNegative()
      {
          Test.startTest();
          //EDGE-185639
          string jsonsios = '';
          List<csord__Solution__c> solutionList = [ SELECT Id FROM csord__Solution__c ];
          User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; //Added by Aman Soni as a part of EDGE-143527      
          System.runAs(sales){
              //EDGE-185639
              RateDiscountCardDTO rateCardDto=RateMatrixForNGUCController.getRateCard_Discounts('','',solutionList[0].Id,'','','',jsonsios);
              Map<String,List<ChargeRateCardDTO>> ratecardMap=rateCardDto.RateCardMap;
              system.assertEquals(ratecardMap,null);
          }
          Test.stopTest();
          

      }
      @IsTest
      public static void getRateCard_DataTest()
      {
          Test.startTest();
          Map <String,List<ChargeRateCardDTO>> crdcMap = RateMatrixForNGUCController.getRateCardData('Standard','DMCAT_Offer_000618',new List<DiscountDTO>(),'Shared line', new Map<String,RateCardSIOWrapper.wrapSIO>());
          Test.stopTest();
          system.assertNotEquals(crdcMap.size(),0);
      }
    //Edge-133882 added by Shubhi end
   //EDGE-140157 start 
    @isTest
    public static void getRateCard_DiscountsModifyTest()
      {
          
          // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
          csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
          User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; //Added by Aman Soni as a part of EDGE-143527      
          Account acc=[Select id from Account limit 1];
          System.runAs(sales){
          GetPriceScheduleControllerNGUCVoice priceSchedule=new GetPriceScheduleControllerNGUCVoice();
          String solutionName= System.Label.BusinessCalling;   //Edge-120919 NGUC consumption based Model-New
              cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
              list<cspmb__Rate_Card_Line__c> rcList = new list<cspmb__Rate_Card_Line__c>();
              for(cspmb__Rate_Card_Line__c rcl :[select id,cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,cspmb__Rate_Card__r.Name,
                                fromUnit__c,toUnit__c,cspmb__rate_value__c,cspmb__Rate_Card__r.External_Rate_Row_ID__c,
                                cspmb__Rate_Card__c from cspmb__Rate_Card_Line__c ]){
              	rcList.add(rcl);    
              }
              
              Test.startTest();
              Map<String,RateCardSIOWrapper.wrapSIO> mPlanRateSIO = new Map<String,RateCardSIOWrapper.wrapSIO>();
              RateCardSIOWrapper.wrapSIO sios = new RateCardSIOWrapper.wrapSIO();
              sios.name = 'test';
              sios.expectedSIO = 1;
              sios.actualSIO =2;
              mPlanRateSIO.put('test',sios);
              	RateCardHelper.getRateCardJsonData(rcList[0],mPlanRateSIO,false);
                Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
                priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
                Charge_Line_Item__c cli=[Select id,guid__c from Charge_Line_Item__c limit 1];
                string guid=cli.guid__c;
                String response=PricingTestDataFactory.msresponse;
              system.debug('cli---'+cli);
                PricingMSResponseObject__c pricingMS=PricingTestDataFactory.generatePricingMSResponse(cli,'', response);
              system.debug('pricingMS----'+pricingMS);  
              insert pricingMS;
              string jsonsios = '';
                RateDiscountCardDTO rateCardDto=RateMatrixForNGUCController.getRateCard_Discounts('Standard','DMCAT_Offer_000618',sol.id,'Modify',guid,'Shared line',jsonsios);
                Map<String,List<ChargeRateCardDTO>> ratecardMap=rateCardDto.RateCardMap;
                RateDiscountCardDTO rateCardDto1=RateMatrixForNGUCController.getRateCard_Discounts('','DMCAT_Offer_000618',sol.id,'Modify',guid,'Shared line',jsonsios);
                Map<String,List<ChargeRateCardDTO>> ratecardMap1=rateCardDto.RateCardMap;
                List<DiscountDTO> disDTO=rateCardDto.discountDTOList;
                System.assertEquals('Early Adopter Discount',disDTO[0].discountName);
            }
          Test.stopTest();
      }
    //EDGE-140157 end
}