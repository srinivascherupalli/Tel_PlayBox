/*************************************************************************************************
Name : InflightProcessHelperTest
MainClass:InflightProcessHelper
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.          Gokul               02-Feb-2021     EDGE-192945
===============================================================================================================================
***************************************************************************************************/    
@isTest
private class InflightProcessHelperTest {
    
   @TestSetup
   public static void testSetup(){
    //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;
        //CREATE CONTACT 
        Contact con1 = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
         );
        insert con1;    
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        
        insert pbe;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.CloseDate = date.today().adddays(-1);
        opp.Attachment_Count__c = 1;
        insert opp;
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Project_ID__c = 'basket1';
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp.id;
        basket2.Project_ID__c = 'basket2';
        basket2.csbb__Synchronised_With_Opportunity__c = true;
        basket2.csordtelcoa__Synchronised_with_Opportunity__c = true;
        cscfga__Product_Basket__c basket3 = ProductTestFactory.buildEmptyBasket();
        basket3.csbb__Account__c = acc.id;
        basket3.cscfga__Opportunity__c = opp.id;
        basket3.Project_Complexity__c='Simplex';
        basket3.Project_ID__c = 'basket3';
        insert new List<cscfga__Product_Basket__c>{basket1,basket2,basket3};
        csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
        insert new List<csord__Solution__c>{sol1,sol2};
        cscfga__Product_Configuration__c pc1_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket1.id,sol1.id,'');
        cscfga__Product_Configuration__c pc1_new= PricingTestDataFactory.generateProductConfiguration('','New',basket1.id,sol1.id,'');
        cscfga__Product_Configuration__c pc2_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket2.id,sol2.id,'');
        cscfga__Product_Configuration__c pc2_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket2.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','New',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_modify= PricingTestDataFactory.generateProductConfiguration('','Modify',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_new= PricingTestDataFactory.generateProductConfiguration('','New',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket3.id,sol2.id,'');

        insert new List<cscfga__Product_Configuration__c>{pc1_sol,pc1_new,pc2_sol,pc2_cancel,pc3_sol,pc3_modify,pc3_new,pc3_cancel};
         //Biiling accs
        Billing_Account__c billAcc1=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=con1.Id, status__c='Created',Account__c=acc.id);
        Billing_Account__c billAcc2=new Billing_Account__c(Billing_Account_Number__c='123456789013',Billing_Account_Owner__c=con1.Id,status__c='Final',Account__c=acc.id);
        insert new List<Billing_Account__c>{billAcc1,billAcc2};
        //attributes
        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc1.id , pc1_sol.id);
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc2_sol.id);
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc3_sol.id);
        insert new List<cscfga__Attribute__c>{attr0,attr1,attr2};
        
   }
    
    static testmethod void scenario1test(){
        
        cscfga__Product_Basket__c prod=[select id,cscfga__Opportunity__c,cscfga__Opportunity__r.closedate from cscfga__Product_Basket__c where Project_ID__c = 'basket1'  limit 1];
        test.startTest();
        InflightProcessHelper inf = new InflightProcessHelper();
        inf.performInflightDiscard(prod);
        System.assertEquals(date.today().adddays(-1),prod.cscfga__Opportunity__r.closedate);
        test.stoptest();
    }

    static testmethod void scenario2test(){    
        cscfga__Product_Basket__c prod=[select id,name,cscfga__Opportunity__c,cscfga__Opportunity__r.closedate,Project_ID__c from cscfga__Product_Basket__c where Project_ID__c = 'basket1'  limit 1];
        System.assertEquals('basket1', prod.Project_ID__c);
        Test.startTest();
            List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
            String currentUserId                                    =   UserInfo.getUserId();
            String feedMessage                                      =   Label.ChatterFeed_BasketSubmitFailure;
            List<String> params = new List<String>{'{'+currentUserId+'}','{record:' + prod.Id + '}'};
            String parameterizedLabel   =   String.format(feedMessage, params);
            Boolean isMsgWithParams1    =   parameterizedLabel.contains(prod.Id);
            Boolean isMsgWithParams2    =   parameterizedLabel.contains(currentUserId);            
            feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,prod.Id,parameterizedLabel));
            InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
            System.assertEquals(true, isMsgWithParams1);
            System.assertEquals(true, isMsgWithParams2);
        Test.stoptest();
    }
}