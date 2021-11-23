@isTest
public with sharing class ObserverImplSubscriptionHelperTest {
    @testsetup static void ObserverImplSubscriptionHelperTestDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
       	insert acc;
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        update prodBasket;
        
		
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'IP Site';
        config.cscfga__Product_Basket__c = prodBasket.Id;
        insert config;
        
        //subscription and service
        csord__Subscription__c sub = [select id,csordtelcoa__Product_Configuration__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :Testorder2.id];
        sub.csordtelcoa__Product_Configuration__c = config.Id;
		update sub;
        
        ContractJunction__c cj = new ContractJunction__c();
        cj.Related_Basket__c = prodBasket.Id;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        cj.Related_Opportunity__c = opp.id;
        insert cj;
    }
    @isTest
    private static void testAssociateContractJunctionRecord() {
        Test.startTest();
        List<csord__Subscription__c> sublst = [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c];
        List<String> SubscriptionIds = new List<String>();
        for(csord__Subscription__c sub : sublst)
        {
         	SubscriptionIds.add(sub.Id);   
        }
  		ObserverImplSubscriptionHelper.associateContractJunctionRecord(SubscriptionIds);
        List<csord__Subscription__c> subscriptionList = [select id,ContractJunction__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c from csord__Subscription__c where id in : SubscriptionIds];
        List<ContractJunction__c> contJunctionList = [select Id, Related_Basket__c from ContractJunction__c where Related_Basket__c = :subscriptionList[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c];
        System.assertEquals(contJunctionList[0].Id, subscriptionList[0].ContractJunction__c);
        Test.stopTest();
    }

}