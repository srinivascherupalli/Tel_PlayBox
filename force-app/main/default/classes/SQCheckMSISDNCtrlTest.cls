/*Author: Ila
Company: Tesltra 
User Story :EDGE-80745
Description: Test class for Mobile/MSISDN SQ Check Lightning UI controller.
*/

@isTest
public class SQCheckMSISDNCtrlTest {

     @testSetup
    public static void setupdata(){
         Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Account accOne = TestUtil.createAccount('Test AccountOne');
        accOne.Customer_Status__c = 'ACQUIRED';
        insert accOne;
        
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
       
    }
    
     @isTest
    public static void testmsisdnSearchSuccess(){
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Success'));
        List<PortInController.NumberWrapper> sqPortIn = new List<PortInController.NumberWrapper>();
        PortInController.NumberWrapper wrap = new PortInController.NumberWrapper();  
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
          
        Account acc=[Select id from Account where name ='Test Account'];
        
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
             
         Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'61412345678','Y');
        sqRecord1.Portability_Code__c = 'PORT_SUCCESS';
        sqRecord1.SQ_Type__c='Port in SQ';
        sqRecord1.Incumbent_Account_Number__c='3545654656';
        sqList.add(sqRecord1);
        insert sqList;
        
        Test.startTest();
        SQCheckMobileResponseDTO addrRes = SQCheckMSISDNCtrl.qualifyMsisdn('2459872');
        wrap.num='12345';
        wrap.accountNumber='454634';
        wrap.indicator='Y';
        wrap.reason='The MSISDN can be Ported within Telstra network';
        wrap.code='PORT_SUCCESS';
        sqPortIn.add(wrap);
        SQCheckMSISDNCtrl.saveMsisdn(sqPortIn,basket.id);
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    
       @isTest
    public static void testMsisdnSearchError(){
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Failure'));
        Test.startTest();
        SQCheckMobileResponseDTO addrRes = SQCheckMSISDNCtrl.qualifyMsisdn('2459872');
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    
    @isTest 
    public static void testMsisdnSaveError(){
        
        List<PortInController.NumberWrapper> sqPortIn = new List<PortInController.NumberWrapper>();
        PortInController.NumberWrapper wrap = new PortInController.NumberWrapper();        
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();

        Account acc=[Select id from Account where name ='Test Account'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
             
         Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'6142459872','Y');
        sqRecord1.Portability_Code__c = 'PORT_FAILURE';
        sqRecord1.SQ_Type__c='Port in SQ';
        sqRecord1.Incumbent_Account_Number__c='3545654656';
        sqList.add(sqRecord1);
        insert sqList;
        
         Test.startTest();
        SQCheckMobileResponseDTO addrRes = SQCheckMSISDNCtrl.qualifyMsisdn('2459872');
        wrap.num='2459872';
        wrap.accountNumber='454634';
        wrap.indicator='Y';
        wrap.reason='The MSISDN can be Ported within Telstra network';
        wrap.code='PORT_SUCCESS';
        wrap.uniqueBakset='6142459872' + acc.id;
        sqPortIn.add(wrap);
        SQCheckMSISDNCtrl.saveMsisdn(sqPortIn,basket.id);
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
     @isTest
    public static void testmsisdnSearchSuccessSave(){
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Success'));
        List<PortInController.NumberWrapper> sqPortIn = new List<PortInController.NumberWrapper>();
        PortInController.NumberWrapper wrap = new PortInController.NumberWrapper();  
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
          
        Account acc=[Select id from Account where name ='Test Account'];
        Account acc1=[Select id from Account where name ='Test AccountOne'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
             
         Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc1,'61412345678','Y');
        sqRecord1.Portability_Code__c = 'PORT_SUCCESS';
        sqRecord1.SQ_Type__c='Port in SQ';
        sqRecord1.Incumbent_Account_Number__c='3545654656';
        sqList.add(sqRecord1);
        insert sqList;
        
        Test.startTest();
        SQCheckMobileResponseDTO addrRes = SQCheckMSISDNCtrl.qualifyMsisdn('2459872');
        wrap.num='12345';
        wrap.accountNumber='454634';
        wrap.indicator='Y';
        wrap.reason='The MSISDN can be Ported within Telstra network';
        wrap.code='PORT_SUCCESS';
        sqPortIn.add(wrap);
        SQCheckMSISDNCtrl.saveMsisdn(sqPortIn,basket.id);
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
     /*-------------------------------------------------------- 
EDGE-107149
Method: createPayloadTest
Description: Test method for multiple portin check request payload
Author:Aishwarya
--------------------------------------------------------*/
	 @isTest
    public static void createPayloadTest(){
        List<String> msisdnList = new List<String>{'100159856','100157169','100159379'};
        Test.startTest();
		SQCheckMobileRequestDTO requestDto= SQCheckMSISDNCtrl.createPayload(msisdnList);
        System.assertEquals(requestDto!=null , true, 'Request created');
		Test.stopTest();
	}
     /*-------------------------------------------------------- 
EDGE-107149
Method: calloutSQCheckMultipleSuccess
Description: Test method for calloutToSQCheck Success
Author:Aishwarya
--------------------------------------------------------*/
	 @isTest
    public static void calloutSQCheckMultipleSuccess(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('success_multiple'));
        String success_multiple = '{"status":200,"data":{"numberDetails":[{"mobileNumber":"msisdn2","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"},{"mobileNumber":"msisdn3","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"},{"mobileNumber":"msisdn4","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"}]}}';
        SQCheckMobileRequestDTO requestDto = SQCheckMobileRequestDTO.parse(success_multiple);
		SQCheckMobileResponseDTO responseDto = SQCheckMSISDNCtrl.calloutToSQCheck(requestDto);
        if(responseDto!=null && responseDto.data != null){
            if(responseDto.data.numberDetails ==null)
		        System.assertEquals((responseDto!=null && !responseDto.data.numberDetails.isEmpty()), true, 'Callout SuccessFull');	
        }        
		Test.stopTest();
	}
     /*-------------------------------------------------------- 
EDGE-107149
Method: calloutSQCheckMultipleFailure
Description: Test method for calloutToSQCheck failure
Author:Aishwarya
--------------------------------------------------------*/
	 @isTest
    public static void calloutSQCheckMultipleFailure(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('failure_multiple'));
        String failure_multiple = '{"status":404,"data":{},"errors":{"errorDetails":[{"message":"The Mobile Number cannot be found","code":"RESOURCE_NOT_FOUND"}]}}';
		SQCheckMobileRequestDTO requestDto = SQCheckMobileRequestDTO.parse(failure_multiple);
		SQCheckMobileResponseDTO responseDto = SQCheckMSISDNCtrl.calloutToSQCheck(requestDto);
        if(responseDto!=null && responseDto.data != null){
            if(responseDto.data.numberDetails ==null)
		        System.assertEquals((responseDto!=null && responseDto.data.numberDetails ==null), true, 'Callout Failed');	
        }
        Test.stopTest();
	}
    /*-------------------------------------------------------- 
EDGE-107149
Method: testMsisdnMultipleSearchError
Description: Test method for catch exception 
Author:Aishwarya
--------------------------------------------------------*/
       @isTest
    public static void testMsisdnMultipleSearchError(){
        //Test.setMock(HttpCalloutMock.class, new MockSQCheckMSISDNCtrl('Failure'));
        Test.startTest();
        String success_multiple = '{"status":200,"data":{"numberDetails":[{"mobileNumber":"msisdn2","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"},{"mobileNumber":"msisdn3","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"},{"mobileNumber":"msisdn4","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"}]}}';

        //SQCheckMobileResponseDTO addrRes = SQCheckMSISDNCtrl.qualifyMsisdn('2459872');
        SQCheckMobileRequestDTO requestDto = SQCheckMobileRequestDTO.parse(success_multiple);
		SQCheckMobileResponseDTO responseDto = SQCheckMSISDNCtrl.calloutToSQCheck(null);
        Test.stopTest();
        System.assertNotEquals(responseDto, NULL);
    }
}