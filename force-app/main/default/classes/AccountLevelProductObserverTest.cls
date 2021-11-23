@isTest
private class AccountLevelProductObserverTest {
  @isTest static void testDesyncModularBasketWhenProductAdded() {
      csbb__Product_Configuration_Request__c pcRequest = TestDataFactory.generateProdutConfigurationRequest();
      csbb.ObserverApi.Observable o;//EDGE-218369
      csbb.ProductConfigurationObservable observable = (csbb.ProductConfigurationObservable) o;//EDGE-218369
      AccountLevelProductObserver controller = new AccountLevelProductObserver();
      
      Test.startTest();
      controller.execute(observable, null);//EDGE-218369
      controller.desyncModularBasketWhenProductAdded(pcRequest.csbb__Product_Configuration__c);
      Test.stopTest();

    System.assertNotEquals(pcRequest.csbb__Product_Configuration__c, null);
  }
  
  //commenting below code as its no longer in use || EDGE-218369 start
  /*@isTest static void testCreateSitesAndAddress() {
    csbb__Product_Configuration_Request__c pcRequest = TestDataFactory.generateProdutConfigurationRequest();
    EnvironmentVariable__c ev = new EnvironmentVariable__c(Name = 'TransitionClone', Value__c = '3');
    insert ev;
    AccountLevelProductObserver controller = new AccountLevelProductObserver();
    
    Test.startTest();
    controller.createSitesAndAddress(pcRequest.csbb__Product_Configuration__c, pcRequest);
    Test.stopTest();

    System.assertNotEquals(pcRequest.csbb__Product_Configuration__c, null);
  }

  @isTest static void testAccountCheckSubPresentOnAcc() {
    csbb__Product_Configuration_Request__c pcRequest = TestDataFactory.generateProdutConfigurationRequest();

    cscfga__Product_Configuration__c pc = [
      SELECT Id, cscfga__Product_Definition__r.name
      FROM cscfga__Product_Configuration__c pc 
      WHERE Id = :pcRequest.csbb__Product_Configuration__c
    ];
	cscfga__Configuration_Offer__c testOffer = new cscfga__Configuration_Offer__c();
	testOffer.Name ='testOffer';
	insert testOffer;
	pc.Offer_Reference__c = testOffer.Id;
	update pc;
    EnvironmentVariable__c ev = new EnvironmentVariable__c(Name = 'IPNetworkUCEPCClone', Value__c = '5');
    insert ev;
    AccountLevelProductObserver controller = new AccountLevelProductObserver();
    
    Test.startTest();
    controller.accountCheckSubPresentOnAcc(pc, pcRequest);
    Test.stopTest();

    System.assertNotEquals(pcRequest.csbb__Product_Configuration__c, null);
  }*/
  //commenting below code as its no longer in use || EDGE-218369 end
}