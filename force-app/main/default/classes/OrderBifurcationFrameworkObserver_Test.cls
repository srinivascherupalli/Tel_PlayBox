/**********************************************************************************************
@description: Test class to test the custom order observer methods implemented in apex classes
 invoked when platform event is published .
***********************************************************************************************/
 

@isTest
private class OrderBifurcationFrameworkObserver_Test {

     @isTest static void testObserverWithValidOrder() {
        testFactoryForOrderGeneration.orderUtilConfiguration(10, true, true, 'Closed Won', true);
        List<Account> accountList = new List<Account>(); 
        accountList = testFactoryForOrderGeneration.accountCreation(1, 'Test Account OG');
        insert accountList;

        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList = testFactoryForOrderGeneration.opportunityCreation(1, 'Test Opp OG', accountList[0].Id, 'Modular', 'Propose' );
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>(); 
        basketList = testFactoryForOrderGeneration.basketCreation(1, 'Enriched', accountList[0].Id, oppList[0].Id );
        insert basketList;
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>(); 
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(5, 'PC', basketList[0].Id );
        insert pcList;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', accountList[0].id, 'Created', ordReqList[0].id);
        ord.csord__Order_Request__c = ordReqList[0].Id;
        ord.csordtelcoa__Opportunity__c = oppList[0].Id;
        orderList.add(ord);
        insert orderList;
        
        List<csord__subscription__c> subList = new List<csord__subscription__c>(); 
        for( cscfga__Product_Configuration__c pc: pcList){
            List<csord__subscription__c> tempSubList = new List<csord__subscription__c>();  
            tempSubList = testFactoryForOrderGeneration.subscriptionCreation(1, 'Subscription', orderList[0].Id, pc.Id );
            subList.addAll(tempSubList);
        }
        insert subList;
        
        List<csord__service__c> servList = new List<csord__service__c>(); 
        for( csord__subscription__c subs: subList){
            List<csord__service__c> tempServList = new List<csord__service__c>();   
            tempServList = testFactoryForOrderGeneration.serviceCreation(1, 'Service', subs.csord__Order__c, subs.csordtelcoa__Product_Configuration__c, subs.Id  );
            servList.addAll(tempServList);
        }
        insert servList;
        
        
        Test.startTest();
        List<Id> temporderIds = new List<Id>();
        
        List<order_decomposition_request__e> orderObserverEvents= new list<order_decomposition_request__e>();
        for(csord__order__c rec: orderList){
            orderObserverEvents.add(new order_decomposition_request__e(order_Id__c=rec.Id, observer_Invocation__c=true));
            temporderIds.add(rec.Id);
        }
        //Publish the event
        OrderGenrationHelper.publishOrderDecompositionEvents(orderObserverEvents, temporderIds);
        //OrderObserverInvoker.observerChainingMethod(temporderIds);
        Test.stopTest();
        csord__Order__c order = [SELECT Id, Name from csord__Order__c WHERE Name = 'TestOrder'];
        System.assertEquals('TestOrder',order.Name);
    }
    
    @isTest static void incorrectOrderIds() {
        testFactoryForOrderGeneration.orderUtilConfiguration(10, true, true, 'Closed Won', false);
        List<Account> accountList = new List<Account>(); 
        accountList = testFactoryForOrderGeneration.accountCreation(1, 'Test Account OG');
        insert accountList;

        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList = testFactoryForOrderGeneration.opportunityCreation(1, 'Test Opp OG', accountList[0].Id, 'Modular', 'Propose' );
        insert oppList;
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>(); 
        basketList = testFactoryForOrderGeneration.basketCreation(1, 'Enriched', accountList[0].Id, oppList[0].Id );
        insert basketList;
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>(); 
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(5, 'PC', basketList[0].Id );
        insert pcList;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', accountList[0].id, 'Created', ordReqList[0].id);
        ord.csord__Order_Request__c = ordReqList[0].Id;
        //ord.csordtelcoa__Opportunity__c = oppList[0].Id;
        orderList.add(ord);
        insert orderList;
        
        List<csord__subscription__c> subList = new List<csord__subscription__c>(); 
        for( cscfga__Product_Configuration__c pc: pcList){
            List<csord__subscription__c> tempSubList = new List<csord__subscription__c>();  
            tempSubList = testFactoryForOrderGeneration.subscriptionCreation(1, 'Subscription', null, pc.Id );
            subList.addAll(tempSubList);
        }
        insert subList;
        
        Test.startTest();
        List<Id> temporderIds = new List<Id>();
        temporderIds = null;
        csordcb.ObserverApi.Observable o;
        List<Id> subscriptionIds = new List<Id>();
        for(csord__subscription__c subs: [Select Id from csord__subscription__c WHERE csord__order__c = null]){
            subscriptionIds.add(subs.Id);
        }
        OrderObserverInvoker.observerChainingMethod(subscriptionIds, o, temporderIds);
        Test.stopTest();
        List<Exception_Log__c> exceptionList = [SELECT Id, Name from Exception_Log__c];
        System.assertEquals(false,exceptionList.isEmpty());
    }
    
    @isTest
   static void runObserverEsecuteMethod() {
       testFactoryForOrderGeneration.orderUtilConfiguration(10, true, true, 'Closed Won', true);
        List<Account> accountList = new List<Account>(); 
        accountList = testFactoryForOrderGeneration.accountCreation(1, 'Test Account OG');
        insert accountList;

        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList = testFactoryForOrderGeneration.opportunityCreation(1, 'Test Opp OG', accountList[0].Id, 'Modular', 'Propose' );
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>(); 
        basketList = testFactoryForOrderGeneration.basketCreation(1, 'Enriched', accountList[0].Id, oppList[0].Id );
        insert basketList;
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>(); 
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(5, 'PC', basketList[0].Id );
        insert pcList;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', accountList[0].id, 'Created', ordReqList[0].id);
        ord.csord__Order_Request__c = ordReqList[0].Id;
        ord.csordtelcoa__Opportunity__c = oppList[0].Id;
        orderList.add(ord);
        insert orderList;
        
        List<csord__subscription__c> subList = new List<csord__subscription__c>(); 
        for( cscfga__Product_Configuration__c pc: pcList){
            List<csord__subscription__c> tempSubList = new List<csord__subscription__c>();  
            tempSubList = testFactoryForOrderGeneration.subscriptionCreation(1, 'Subscription', orderList[0].Id, pc.Id );
            subList.addAll(tempSubList);
        }
        insert subList;
        
        List<csord__service__c> servList = new List<csord__service__c>(); 
        for( csord__subscription__c subs: subList){
            List<csord__service__c> tempServList = new List<csord__service__c>();   
            tempServList = testFactoryForOrderGeneration.serviceCreation(1, 'Service', subs.csord__Order__c, subs.csordtelcoa__Product_Configuration__c, subs.Id  );
            servList.addAll(tempServList);
        }
        insert servList;
        Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>([SELECT Id FROM csord__Subscription__c]);
        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([SELECT Id FROM csord__Order__c]);
        Map<Id, csord__Service__c> servMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c]);
        List<Id> subscriptionIds = new List<Id>(subMap.keySet());
        List<Id> orderIds = new List<Id>(orderMap.keySet());
        List<Id> serviceIds = new List<Id>(servMap.keySet());
        Test.startTest();
        AllObserversAfterOrderGeneration observer = new AllObserversAfterOrderGeneration();
        csordtelcoa.OrderGenerationObservable o = new csordtelcoa.OrderGenerationObservable(
            'AllObserversAfterOrderGeneration',
            null,
            orderIds,
            subscriptionIds,
            serviceIds,
            null,
            null,
            null,
            null,
            null
        );
        observer.execute(o, null);
        Test.stopTest();
        List<csord__Order__c> orders = [SELECT Id, csord__Status2__c FROM csord__Order__c];
        System.debug('Staus of Order1 : ' +orders[0].csord__Status2__c);
        //System.assert(orders[0].csord__Status2__c.Contains('Order Decomposition Failed'));
    }
    
    @isTest static void testobserverExecutionForFutureMethod() {
        testFactoryForOrderGeneration.orderUtilConfiguration(10, true, true, 'Closed Won', true);
        List<Account> accountList = new List<Account>(); 
        accountList = testFactoryForOrderGeneration.accountCreation(1, 'Test Account OG');
        insert accountList;

        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList = testFactoryForOrderGeneration.opportunityCreation(1, 'Test Opp OG', accountList[0].Id, 'Modular', 'Propose' );
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>(); 
        basketList = testFactoryForOrderGeneration.basketCreation(1, 'Enriched', accountList[0].Id, oppList[0].Id );
        insert basketList;
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>(); 
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(5, 'PC', basketList[0].Id );
        insert pcList;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', accountList[0].id, 'Created', ordReqList[0].id);
        ord.csord__Order_Request__c = ordReqList[0].Id;
        ord.csordtelcoa__Opportunity__c = oppList[0].Id;
        orderList.add(ord);
        insert orderList;
        
        List<csord__subscription__c> subList = new List<csord__subscription__c>(); 
        for( cscfga__Product_Configuration__c pc: pcList){
            List<csord__subscription__c> tempSubList = new List<csord__subscription__c>();  
            tempSubList = testFactoryForOrderGeneration.subscriptionCreation(1, 'Subscription', orderList[0].Id, pc.Id );
            subList.addAll(tempSubList);
        }
        insert subList;
        
        List<csord__service__c> servList = new List<csord__service__c>(); 
        for( csord__subscription__c subs: subList){
            List<csord__service__c> tempServList = new List<csord__service__c>();   
            tempServList = testFactoryForOrderGeneration.serviceCreation(1, 'Service', subs.csord__Order__c, subs.csordtelcoa__Product_Configuration__c, subs.Id  );
            servList.addAll(tempServList);
        }
        insert servList;
        
        Test.startTest();
        List<Id> temporderIds = new List<Id>();
        for(csord__order__c rec: orderList){
            temporderIds.add(rec.Id);
        }
        //Publish the event
        AllObserversAfterOrderGeneration.observerExecutionForFutureMethod(temporderIds);
        //OrderObserverInvoker.observerChainingMethod(temporderIds);
        Test.stopTest();
        csord__Order__c order = [SELECT Id, Name from csord__Order__c WHERE Name = 'TestOrder'];
        System.assertEquals('TestOrder',order.Name);
    }
    
    @isTest static void testPlatformTriggerforOrderEntry() {
        testFactoryForOrderGeneration.orderUtilConfiguration(10, true, true, 'Closed Won', false);
        List<Account> accountList = new List<Account>(); 
        accountList = testFactoryForOrderGeneration.accountCreation(1, 'Test Account OG');
        insert accountList;

        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList = testFactoryForOrderGeneration.opportunityCreation(1, 'Test Opp OG', accountList[0].Id, 'Modular', 'Propose' );
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>(); 
        basketList = testFactoryForOrderGeneration.basketCreation(1, 'Enriched', accountList[0].Id, oppList[0].Id );
        insert basketList;
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>(); 
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(5, 'PC', basketList[0].Id );
        insert pcList;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', accountList[0].id, 'Created', ordReqList[0].id);
        ord.csord__Order_Request__c = ordReqList[0].Id;
        ord.csordtelcoa__Opportunity__c = oppList[0].Id;
        orderList.add(ord);
        insert orderList;
        
        List<csord__subscription__c> subList = new List<csord__subscription__c>(); 
        for( cscfga__Product_Configuration__c pc: pcList){
            List<csord__subscription__c> tempSubList = new List<csord__subscription__c>();  
            tempSubList = testFactoryForOrderGeneration.subscriptionCreation(1, 'Subscription', orderList[0].Id, pc.Id );
            subList.addAll(tempSubList);
        }
        insert subList;
        
        List<csord__service__c> servList = new List<csord__service__c>(); 
        for( csord__subscription__c subs: subList){
            List<csord__service__c> tempServList = new List<csord__service__c>();   
            tempServList = testFactoryForOrderGeneration.serviceCreation(1, 'Service', subs.csord__Order__c, subs.csordtelcoa__Product_Configuration__c, subs.Id  );
            servList.addAll(tempServList);
        }
        insert servList;
        
        Test.startTest();
        List<Id> temporderIds = new List<Id>();
        List<order_decomposition_request__e> orderDecomposeEvents= new list<order_decomposition_request__e>();

        for(csord__order__c rec: orderList){
            orderDecomposeEvents.add(new order_decomposition_request__e(Order_Id__c=rec.Id, observer_Invocation__c=true));
            temporderIds.add(rec.Id);
        }
                
        //Publish the event
        OrderGenrationHelper.publishOrderDecompositionEvents(orderDecomposeEvents, temporderIds);
        Test.stopTest();
        //csord__Order__c order = [SELECT Id, Name from csord__Order__c WHERE Name = 'TestOrder'];
        System.assertEquals(false,orderDecomposeEvents.isEmpty());
    }
    
    
}