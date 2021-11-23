@isTest
public class CustomNotificationFromApexTests {
    @testSetup
    static void setupData() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Name';
        opp.StageName = 'Develop';
        opp.CloseDate = Date.today();
        opp.Proposal_Requested_User__c = UserInfo.getUserId();   
        opp.SharePoint_Sync__c = 'Complete';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
    }
    
    @isTest
    static void testSendNotifications() {
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName='Proposal_Generation_Complete'];
        Opportunity opp = [SELECT Id,Proposal_Requested_User__c,SharePoint_Sync__c 
                           FROM Opportunity];
        Test.startTest();
            String str = CustomNotificationFromApex.sendNotifications(notificationType, opp, 'Success', 'Test Successful');
        Test.stopTest();
        
        System.assertEquals(str,'', 'Response should be null');
    }    
    @isTest
    static void testsendNotificationsToBasketUser() {
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName='Proposal_Generation_Complete'];
        cscfga__Product_Basket__c prdBasket = [SELECT Id,Name,CreatedById 
                           FROM cscfga__Product_Basket__c];
        Test.startTest();
            CustomNotificationFromApex.sendNotificationsToBasketUser(notificationType, prdBasket, 'Success', 'Test Successful');
        Test.stopTest();
       
    }
    @isTest
    static void testsendNotificationsToBasketUserEx() {
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName='Proposal_Generation_Complete'];
        cscfga__Product_Basket__c prdBasket = new cscfga__Product_Basket__c();
        Test.startTest();
            CustomNotificationFromApex.sendNotificationsToBasketUser(notificationType, prdBasket , 'Success', 'Test Successful');
        Test.stopTest();
       
    }
}