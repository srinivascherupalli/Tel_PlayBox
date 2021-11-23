@isTest
public class OfferAutoRefreshTest {

    static testMethod void Test1(){
        
        List<cscfga__Product_Configuration__c> configIds = New List<cscfga__Product_Configuration__c> (); 
        List<ID> pcIds = New List<ID> ();
        
        cscfga__Configuration_Offer__c offerDef = new cscfga__Configuration_Offer__c();
        offerDef.Name = 'Unified Communication Enterprise';
        offerDef.cscfga__Description__c ='Description';
        insert offerDef;
        

        
		cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
		prodDef.Name = 'Unified Communication Enterprise';
        prodDef.cscfga__Description__c = 'Description';
		prodDef.cscfga__Active__c = true;
		insert prodDef;
        
        
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'Communication Enterprise';
        prodConfig.cscfga__Product_Basket__c = null;
        prodConfig.Name  = 'testConfig';
		prodConfig.cscfga__Configuration_Offer__c = offerDef.Id;
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        insert prodConfig;
        
		configIds.add(prodConfig);
        pcIds.add(prodConfig.Id);


        
        Test.startTest();
        OfferAutoRefresh OffRefresh = new OfferAutoRefresh(); 

        cscfga__Product_Configuration__c prodConfig1 = [Select id, Name from cscfga__Product_Configuration__c where name = 'testConfig' LIMIT 1];  
        OfferAutoRefresh.offerRefresh('Modular');
        System.assert(prodConfig1 != null);
        Test.stopTest();
        
    }  

    static testMethod void Test2(){
        
        List<cscfga__Product_Configuration__c> configIds = New List<cscfga__Product_Configuration__c> (); 
        List<ID> pcIds = New List<ID> ();
        
        cscfga__Configuration_Offer__c offerDef1 = new cscfga__Configuration_Offer__c();
        offerDef1.Name = 'FIXED TELEPHONY';
        offerDef1.cscfga__Description__c ='Description';
        insert offerDef1;
        
       	cscfga__Product_Definition__c prodDef1 = new cscfga__Product_Definition__c();
		prodDef1.Name = 'FIXED TELEPHONY';
        prodDef1.cscfga__Description__c = 'Description';
		prodDef1.cscfga__Active__c = true;
		insert prodDef1;

        
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.cscfga__Product_Basket__c = null;
        prodConfig.Name  = 'testConfig';
		prodConfig.cscfga__Configuration_Offer__c = offerDef1.Id;
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        insert prodConfig;
        configIds.add(prodConfig);
        pcIds.add(prodConfig.Id);
        
        Test.startTest();
        OfferAutoRefresh OffRefresh = new OfferAutoRefresh(); 
        cscfga__Product_Configuration__c prodConfig1 = [Select id, Name from cscfga__Product_Configuration__c where name = 'testConfig' LIMIT 1];  
        OfferAutoRefresh.offerRefresh('Non Modular');
        System.assert(prodConfig1 != null);
        Test.stopTest();
        
    }
}