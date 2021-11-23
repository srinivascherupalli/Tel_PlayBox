/*************************************************************************************************
Name : PpvComponentControllerTest
Description : Used for Pre-Port Verification
Author: Kalashree Borgaonkar
Story: EDGE-90327
***************************************************************************************************/
@isTest
public class PpvComponentControllerTest {
	//Create data
   
    @testSetup 
    public static void setupdata(){
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Contact c = TestUtil.createContact(acc.id,'Testing', 'Test');
        insert c;
        OpportunityContactRole ocr = TestUtil.createOCR(c,opp);
        insert ocr;
        cscfga__Product_Basket__c basket = TestUtil.createBasket(opp,acc);
        basket.Primary_Basket__c=true;
        insert basket;
        Customer_Authority_Form__c caf = TestUtil.createCustAuthorityForm(opp,acc);
        insert caf;
        AccountContactRelation acr = [SELECT id FROM AccountContactRelation WHERE Accountid=:acc.Id];
        acr.Roles = 'Legal Lessee';
        update acr;
		Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        sqRecord.Added_to_CA_form__c=true;
        insert sqRecord;
    }
    
    /*----------------------------------------------------------------
Method : getDetailsTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getDetailsTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c];
        Test.startTest();
        PpvComponentController.BasketDetailsWrapper wrap= PpvComponentController.getDetails(basket.id);
        Test.stopTest();
        System.assertEquals(wrap!=null,true,'Deatils Wrapper created');
    }
    
    /*----------------------------------------------------------------
Method : getContactSearchWithTextTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getContactSearchWithTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<AccountContactRelation> acrList= PpvComponentController.getContactsForSearch(opp.AccountID,opp.Id,'Test');
        Test.stopTest();
        System.assertEquals(acrList!=null,true, 'Contacts found with searct key');
    }
    
    /*----------------------------------------------------------------
Method : getContactSearchWithoutTextTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getContactSearchWithoutTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<AccountContactRelation> acrList= PpvComponentController.getContactsForSearch(opp.AccountID,opp.Id,'');
        Test.stopTest();
        System.assertEquals(acrList!=null,true, 'Contacts found without search key');
    }
    
    /*----------------------------------------------------------------
Method : getPortInMsisdnsWithTextTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getPortInMsisdnsWithTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<Service_Qualification__c> sqList= PpvComponentController.getPortInMsisdns(opp.AccountID,opp.Id,'614');
        Test.stopTest();
        System.assertEquals(sqList!=null,true, 'SQ found with search key');
    }
    /*----------------------------------------------------------------
Method : getPortInMsisdnsWithOutTextTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getPortInMsisdnsWithOutTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<Service_Qualification__c> sqList= PpvComponentController.getPortInMsisdns(opp.AccountID,opp.Id,'');
        Test.stopTest();
        System.assertEquals(sqList!=null,true, 'SQ found without search key');
    }
    /*-----------------------------------------------------------------
Method : ppvCalloutSuccessTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void ppvCalloutSuccessTest(){
        Account acc = [SELECT id FROM Account WHERE name ='Test Account'];
        Customer_Authority_Form__c caf = [SELECT id FROM Customer_Authority_Form__c WHERE Account__c=:acc.id];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockPPVCalloutResponse('success_Search'));
        PpvComponentController.ResponeWrapper response = PpvComponentController.ppvCallout(acc.id,'61411111111',caf.id,'Testing Test');
        Test.stopTest(); 
        System.assertEquals(response!=null,true, 'Received response from PPV Tool');
    }
    /*----------------------------------------------------------------
Method : ppvCalloutFailTest422
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void ppvCalloutFailTest422(){
        Account acc = [SELECT id FROM Account WHERE name ='Test Account'];
        Customer_Authority_Form__c caf = [SELECT id FROM Customer_Authority_Form__c WHERE Account__c=:acc.id];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockPPVCalloutResponse('success_Error'));
        PpvComponentController.ResponeWrapper response = PpvComponentController.ppvCallout(acc.id,'61411111111',caf.id,'Testing Test');
        Test.stopTest(); 
        System.assertEquals(response!=null,true, '422 Error');
    }
    /*----------------------------------------------------------------
Method : ppvCalloutFailTest503
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
     @isTest
    public static void ppvCalloutFailTest503(){
        Customer_Authority_Form__c caf = [SELECT id,Account__c FROM Customer_Authority_Form__c WHERE Account__r.name=:'Test Account'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockPPVCalloutResponse('success_Error_503'));
        PpvComponentController.ResponeWrapper response = PpvComponentController.ppvCallout(caf.Account__c,'61411111111',caf.id,'Testing Test');
        Test.stopTest(); 
        System.assertEquals(response!=null,true, '503 Error');
    }
      @isTest
    public static void saveResponseFailTest(){
        Customer_Authority_Form__c caf = [SELECT id FROM Customer_Authority_Form__c WHERE Account__r.name=:'Test Account'];
        Test.startTest();
        Boolean isSaved = PpvComponentController.saveResponse('202',caf.id,'61411111111','Testing Test','145sdhju176-wh2327-9474f-f56g5');
        Test.stopTest(); 
        System.assertEquals(isSaved==false,true, 'Save Error');
    }
    /*----------------------------------------------------------------
Method : saveResponseSuccessTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
      @isTest
    public static void saveResponseSuccessTest(){
        Customer_Authority_Form__c caf = [SELECT id FROM Customer_Authority_Form__c WHERE Account__r.name=:'Test Account'];
        Contact c = [SELECT id FROM Contact WHERE name = 'Testing Test'];
        Test.startTest();
        Boolean isSaved = PpvComponentController.saveResponse('MPPV-ACCEPTED',caf.id,'61411111111',c.id,'145sdhju176-wh2327-9474f-f56g5');
        Test.stopTest(); 
        System.assertEquals(isSaved==true,true, 'Response Saved');
    }
    
    
    /*----------------------------------------------------------------
Method : saveReservationPoolTest
Author: Aishwarya Yeware
Story: EDGE-100327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveReservationPoolTest(){
         Account acc = [SELECT id FROM Account WHERE name ='Test Account'];
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        List<Service_Qualification__c> sqList=[SELECT id ,Service_Number__c FROM Service_Qualification__c WHERE Account__c=:acc.id AND Added_to_CA_form__c=true];
       
        Test.startTest();
		PpvComponentController.addToReservationPool(acc.id,opp.id,'61411111111','success');
		PpvComponentController.addToReservationPool(acc.id,opp.id,'61411111111','failed');
        PpvComponentController.addToReservationPool(acc.id,opp.id,'','');
        Test.stopTest(); 
        System.assertEquals(sqList!=Null,true, 'Response not Saved');
    }
}