/*********************************************************************************************************************************
 *Class Name      :   ShowPromotionAndDiscountContollerTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.           Shubhi            26 Nov 2019       Edge-120132
2.          Aman Soni          22 Apr 2020       EDGE-143527
 *********************************************************************************************************************************
*/
//Modified by Aman Soni as a part of EDGE-143527 || Start
@isTest
private class ShowPromotionAndDiscountContollerTest  {
    @TestSetup static void CreateData()
    {
        // Create Test Account
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        
        // Create Test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        
        // Create Test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];//Added by Aman Soni as a part of EDGE-143527
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c price_item =PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5176');
        price_item_List.add(price_item);
        
        cspmb__Price_Item__c price_item_1 =PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5177');
        price_item_List.add(price_item_1);
        
        cspmb__Price_Item__c FairPlayPI =PricingTestDataFactory.generateMobilePriceItemFairPlay('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_7206');
        price_item_List.add(FairPlayPI);
        insert price_item_List;
        
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;       
        
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c dliMW1 = PricingTestDataFactory.generateDiscountLevelPlan('Mobile Workspace Discount 1', 'DMCAT_Discount_000944', testAccount,price_item.id,'3 GB');
        dlList.add(dliMW1);
        
        cspmb__Discount_Level__c dliNBYO = PricingTestDataFactory.generateDiscountLevelPlan('National BYO Discount', 'DMCAT_Discount_000956', testAccount,price_item.id,'3 GB');
        dlList.add(dliNBYO);
        
        cspmb__Discount_Level__c dliMMC = PricingTestDataFactory.generateDiscountLevelPlan('MMC Discount', 'DMCAT_Discount_000961', testAccount,price_item.id,'');
        dlList.add(dliMMC);
        
        cspmb__Discount_Level__c dliAC = PricingTestDataFactory.generateDiscountLevelPlan('Activation Credits Months Discount', 'DMCAT_Discount_000951', testAccount,price_item.id,'');
        dlList.add(dliAC);
        
        cspmb__Discount_Level__c dliMRO = PricingTestDataFactory.generateDiscountLevelPlan('Postpaid MRO Plan Discount','', testAccount,price_item.id,'');
        dlList.add(dliMRO);
        
        cspmb__Discount_Level__c dliIDD = PricingTestDataFactory.generateDiscountLevelPlan('IDD Call Pack Discount','DMCAT_Discount_000957', testAccount,addon.id,'');
        dlList.add(dliIDD);
        insert dlList;
        
        List<cspmb__Discount_Association__c> DAList=new List<cspmb__Discount_Association__c>();
        cspmb__Discount_Association__c DisAssoc = PricingTestDataFactory.generateDiscountAssociation2(price_item,null,dliMW1);
        cspmb__Discount_Association__c DisAssoc1 = PricingTestDataFactory.generateDiscountAssociation2(price_item_1,null,dliNBYO);
        cspmb__Discount_Association__c DisAssoc2 = PricingTestDataFactory.generateDiscountAssociation2(null, addon, dliIDD);
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
        csord__Solution__c solution = PricingTestDataFactory.generateSolution('Enterprise Mobility (1)');  
        solutionList.add(solution); 
        
        csord__Solution__c solution1 = PricingTestDataFactory.generateSolution('Enterprise Mobility (2)');  
        solutionList.add(solution1);
        
        csord__Solution__c solution2 = PricingTestDataFactory.generateSolution('Enterprise Mobility (3)');  
        solutionList.add(solution2);
        insert solutionList;
        
        Attachment att=new attachment();
        att.name='solutionDetails.JSON';
        att.body=Blob.valueOf(SolutionAttachmentTestDataFactory.generateSolutionString(price_item.id,addon.id));
        att.parentId=solution.id;  
        insert att;

        Attachment att2=new attachment();
        att2.name='solutionDetails.JSON';
        att2.body=Blob.valueOf(SolutionAttachmentTestDataFactory.generateSolutionString(FairPlayPI.id,addon.id));
        att2.parentId=solution1.id;  
        insert att2;
    
        Attachment att3=new attachment();
        att3.name='solutionDetails.JSON';
        att3.body=Blob.valueOf(SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.id,addon.id));
        att3.parentId=solution2.id;  
        insert att3;
            
    }
    
    @isTest
    public static void TestDiscountDTO(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
        account acc=[Select id from account limit 1];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
        string solutionName='Mobile Subscription';
        cspmb__Add_On_Price_Item__c addon=[select id from cspmb__Add_On_Price_Item__c limit 1];
        
        System.runAs(sales){
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            if(guidToAttMapofMap!=null && guidToAttMapofMap.containskey(configGuid)){
                Object JsonString=JSON.serialize(guidToAttMapofMap.get(configGuid));
                List<DiscountDTO> disTolist=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'PromotionAndDis',JsonString);
                List<DiscountDTO> disTolist2=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'AddOn',JsonString);
                System.assert(true,disTolist[0].discountName=='Activation Credits Months Discount'|| disTolist[0].discountName=='Postpaid MRO Plan Discount'||disTolist[0].discountName=='MMC Discount');
                System.assert(true,disTolist[0].promotionID=='DMCAT_Discount_000951'|| disTolist[0].promotionID=='DMCAT_Discount_000961'||disTolist[0].promotionID=='');
            }
        }
        Test.stopTest();
    }
    @isTest
    public static void TestDiscountDTO_scenario2(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (2)' limit 1];
        account acc=[Select id from account limit 1];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
        string solutionName='Mobile Subscription';
        System.runAs(sales){
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            if(guidToAttMapofMap!=null && guidToAttMapofMap.containskey(configGuid)){
                Object JsonString=JSON.serialize(guidToAttMapofMap.get(configGuid));
                List<DiscountDTO> disTolist=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'PromotionAndDis',JsonString);
                List<DiscountDTO> disTolist2=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'AddOn',JsonString);
                system.debug('disTolist2.size()------>'+disTolist2.size());
                System.assert(true,disTolist[0].discountName=='Activation Credits Months Discount'|| disTolist[0].discountName=='Postpaid MRO Plan Discount'||disTolist[0].discountName=='MMC Discount');
                System.assert(true,disTolist[0].promotionID=='DMCAT_Discount_000951'|| disTolist[0].promotionID=='DMCAT_Discount_000961'||disTolist[0].promotionID=='');
            }
        }
        Test.stopTest();
    }
    @isTest
    public static void TestDiscountDTO_negativeScenario(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (3)' limit 1];
        account acc=[Select id from account limit 1];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8';
        string solutionName='Mobile Subscription';
        System.runAs(sales){
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            if(guidToAttMapofMap!=null && guidToAttMapofMap.containskey(configGuid)){
                Object JsonString=JSON.serialize(guidToAttMapofMap.get(configGuid));
                List<DiscountDTO> disTolist=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'',JsonString);
                List<DiscountDTO> disTolist1=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'PromotionAndDis',JsonString);
                List<DiscountDTO> disTolist2=ShowPromotionAndDiscountContoller.getDiscountdata(acc.id,sol.id,configGuid,'AddOn',JsonString);
                System.assert(true,disTolist1[0].discountName=='Activation Credits Months Discount'|| disTolist1[0].discountName=='Postpaid MRO Plan Discount'||disTolist1[0].discountName=='MMC Discount');
                System.assert(true,disTolist1[0].promotionID=='DMCAT_Discount_000951'|| disTolist1[0].promotionID=='DMCAT_Discount_000961'||disTolist1[0].promotionID=='');
                System.assert(true,disTolist2[0].discountName=='IDD Call Pack Discount');
                System.assert(true,disTolist2[0].promotionID=='DMCAT_Discount_000957');
                System.assert(true,disTolist[0].discountName=='');
                System.assert(true,disTolist[0].promotionID=='');
                Test.stopTest();
            }
        }
    }
}
//Modified by Aman Soni as a part of EDGE-143527 || End