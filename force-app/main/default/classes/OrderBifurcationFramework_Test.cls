/**********************************************************************************************
@description: Test class to test the custom order generation methods implemented in apex classes
 invoked when opportunity stage changes to "Closed Won" or "Cancelled".
***********************************************************************************************/
 

@isTest
private class OrderBifurcationFramework_Test {

    
     @isTest static void testClosedWonOppWithPlatformEvent() {
    
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
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(15, 'PC', basketList[0].Id );
        insert pcList;
        
        Test.startTest();
        for(Opportunity opp: oppList){
            opp.StageName = 'Closed Won';

        }
        update oppList;
        Test.stopTest();
        Opportunity opp = [SELECT Id, StageName, csordtelcoa__Process_Order_Generation_In_Batch__c FROM Opportunity LIMIT 1];
        System.assertEquals('Closed Won',opp.StageName);
    }
    
    @isTest static void testClosedWonOppWithoutPlatformEvent() {
    
        testFactoryForOrderGeneration.orderUtilConfiguration(10, true, false, 'Closed Won', true);
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
        
        Test.startTest();
        for(Opportunity opp: oppList){
            opp.StageName = 'Closed Won';

        }
        update oppList;
        Test.stopTest();
        Opportunity opp = [SELECT Id, StageName, csordtelcoa__Process_Order_Generation_In_Batch__c FROM Opportunity LIMIT 1];
        System.assertEquals('Closed Won',opp.StageName);
    }
    
    @isTest static void testClosedWonOppWithoutPlatformEventProcess() {
    
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
        
        Test.startTest();
        for(Opportunity opp: oppList){
            opp.StageName = 'Closed Won';

        }
        update oppList;
        Test.stopTest();
        Opportunity opp = [SELECT Id, StageName, csordtelcoa__Process_Order_Generation_In_Batch__c FROM Opportunity LIMIT 1];
        System.assertEquals('Closed Won',opp.StageName);
    }
    
    
    
    @isTest static void testCodeFailureWhenoNsOptionsNotdefined() {
    
        testFactoryForOrderGeneration.orderUtilConfiguration(10, true, true, '');
        
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
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(15, 'PC', basketList[0].Id );
        insert pcList;
        
        Test.startTest();
        //Delete [Select Id from csordtelcoa__Orders_Subscriptions_Options__c];
        for(Opportunity opp: oppList){
            opp.StageName = 'Closed Won';

        }
        update oppList;
        Test.stopTest();
        List<Exception_Log__c> exceptionLog = [SELECT Id from Exception_Log__c ];
        System.assertEquals(false ,exceptionLog.isEmpty());
    }
    
    @isTest static void testCodeFailureWhenCustomSettingNotdefined() {
    
        testFactoryForOrderGeneration.orderUtilConfiguration(null, true, true, 'Closed Won');
        
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
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(15, 'PC', basketList[0].Id );
        insert pcList;
        
        Test.startTest();
        //Delete [Select Id from csordtelcoa__Orders_Subscriptions_Options__c];
        List<Id> tempopportunityIds = new List<Id>();
        for(Opportunity opp: oppList){
            tempopportunityIds.add(opp.Id);
        }
        order_Utilites__c orderUtilSetting = null;
        orderGenerationAPIInvoker.orderGeneration(tempopportunityIds, orderUtilSetting);
        Test.stopTest();
        List<Exception_Log__c> exceptionLog = [SELECT Id from Exception_Log__c ];
        System.assertEquals(false ,exceptionLog.isEmpty());
    }
    
    @isTest static void testCodeFailureWhenOrderutilSettingFieldIsMissing() {
    
        testFactoryForOrderGeneration.orderUtilConfiguration(null, true, true, 'Closed Won');
        
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
        pcList = testFactoryForOrderGeneration.productConfigurationCreation(15, 'PC', basketList[0].Id );
        insert pcList;
        
        Test.startTest();
        //Delete [Select Id from csordtelcoa__Orders_Subscriptions_Options__c];
        List<Id> tempopportunityIds = new List<Id>();
        for(Opportunity opp: oppList){
            tempopportunityIds.add(opp.Id);
        }
        orderGenerationAPIInvoker.orderGenerationAPIInvokerDecision( null, tempopportunityIds , true);
        Test.stopTest();
        List<Exception_Log__c> exceptionLog = [SELECT Id from Exception_Log__c ];
        System.assertEquals(false ,exceptionLog.isEmpty());
    }
    
    @isTest static void testIncorrectPlatformPayload(){
    
    test.startTest();
    List<Id> tempopportunityIds = new List<Id>();
    List<Account> accountList = new List<Account>(); 
    accountList = testFactoryForOrderGeneration.accountCreation(1, 'Test Account OG');
    insert accountList;

    List<Opportunity> oppList = new List<Opportunity>(); 
    oppList = testFactoryForOrderGeneration.opportunityCreation(1, 'Test Opp OG', accountList[0].Id, 'Modular', 'Propose' );
    insert oppList;
    Id oppId = oppList[0].Id;
    tempopportunityIds.add(oppId );
    List<order_decomposition_request__e> orderDecomposeEvents= new list<order_decomposition_request__e>();
    orderDecomposeEvents.add(new order_decomposition_request__e(Opportunity_Id__c='abcdefghijklmnopqrstuvw'));
    //Publish the event
    OrderGenrationHelper.publishOrderDecompositionEvents(orderDecomposeEvents, tempopportunityIds);
    test.stopTest();
    List<Exception_Log__c> exceptionLog = [SELECT Id from Exception_Log__c WHERE referenceInfo__c =:oppId ];
    System.assertEquals(false ,exceptionLog.isEmpty());
    } 
}