@IsTest
public class OrderLodgementTest{
    @TestSetup public static void dataSetup(){
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Id recodtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Opportunity migrationOpp = new Opportunity();
        migrationOpp.RecordtypeId = recodtypeId;
        migrationOpp.AccountId = acc.Id;
        migrationOpp.Name = 'Migration Opportunity';
        migrationOpp.Product_Domain__c = 'OTHER';
        migrationOpp.StageName = 'Develop';
        migrationOpp.Product_Type__c = 'Modular';
        migrationOpp.CloseDate = System.Date.today();
        migrationOpp.Description__c = 'test';
        migrationOpp.Type = 'Migration';
        migrationOpp.Billing_Solution__c = 'Standard';
        insert migrationOpp;
        
        csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Mobility', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        insert sol;
        
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Next Generation Enterprise Mobility';
        offer.Name = 'Adaptive Mobility';
        offer.Offer_ID__c = 'DMCAT_Offer_001233';
        insert offer;
        
        cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
        migrationOppBasket.csbb__Account__c = acc.Id;
        migrationOppBasket.AutoConfigStage__c='Not Initiated';
        migrationOppBasket.Name = 'Migration Opportunity Basket';
        migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
        migrationOppBasket.cscfga__Basket_Status__c  = 'Valid';  
        insert migrationOppBasket;
        
        cscfga__Product_Configuration__c productConfig = TestDataFactory.generateProductConfiguration();
        productConfig.cssdm__solution_association__c = sol.Id;
        productConfig.Marketable_Offer__c=offer.id;
        productConfig.cscfga__Product_Basket__c=migrationOppBasket.id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        update productConfig;
        
    } 
    @IsTest public static void orderLodgmentServiceRequestSuccessTest(){
        Test.startTest();
        string basketId=[SELECT id,Name from cscfga__Product_Basket__c LIMIT 1]?.id;
        Test.setMock(HttpCalloutMock.class, new OrderLodgementMock('success_acknowledgement'));
        Boolean isSucess= OrderLodgement.orderLodgmentServiceRequest(basketId);
        system.assert(isSucess);
        Test.stopTest();   
    } 
    @IsTest public static void orderLodgmentServiceRequestFailureTest(){
        Test.startTest();
        string basketId=[SELECT id,Name from cscfga__Product_Basket__c LIMIT 1]?.id;
        Test.setMock(HttpCalloutMock.class, new OrderLodgementMock('failure_acknowledgement'));
        Boolean isSucess= OrderLodgement.orderLodgmentServiceRequest(basketId);
        system.assert(!isSucess);
        Test.stopTest();   
    } 
    @IsTest public static void orderLodgmentServiceRequestExceptionTest(){
        Test.startTest();
        delete[SELECT id from EnvironmentVariable__c];
        string basketId=[SELECT id,Name from cscfga__Product_Basket__c LIMIT 1]?.id;
        Boolean isSucess= OrderLodgement.orderLodgmentServiceRequest(basketId);
        system.assert(!isSucess);
        Test.stopTest();   
    } 
}