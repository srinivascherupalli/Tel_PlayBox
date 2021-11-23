/* 
*Class Name     : ChargeZoneControllerTest
* Author        : Aman Soni || EDGE-98299
* Date          : 3 Dec 2019
* Description   : This is a test class to simulate and test the logic of ChargeZoneController
******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.       Omkar Jante      08/Oct/2021     DIGI-15723 : Updated logic product charge zone api
 * 2.       Ajith Kumar      28/Oct/2021     DIGI-33904 : Created methods to cover Rental value Update scenario's
*/

@isTest(SeeAllData=FALSE)
public class ChargeZoneControllerTest{
    
@testsetup static void setup(){
    Account acc = TestUtil.createAccount('TestAcct');
    insert acc;

    Contact ct1 = TestUtil.createContact(acc.id,'James', 'Bond');
    insert ct1;
    
    Contact ct2 = TestUtil.createContact(acc.id,'Jason', 'Roy');
    insert ct2;        
    
    List<cscrm__Site__c> sitesList = new List<cscrm__Site__c>();
    cscrm__Address__c objAddress = TestUtil.createAddress();
    objAddress.cscrm__External_ID__c = objAddress.cscrm__External_ID__c;
    objAddress.NBN_Location_Id__c = 'LOC00014519312';
    insert objAddress;
    
    for(Integer i=0; i<4; i++){
        cscrm__Site__c newSite = TestUtil.createSite(ct1.id, ct2.id, acc.id);
        newSite.ProductZoneAPIResponse__c='Test';
        newSite.LastVerificationDate__c=DateTime.now();
        newSite.cscrm__Installation_Address__c = objAddress.Id;
        sitesList.add(newSite);
    }       	
    insert sitesList;
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
}
@isTest static void callChargeZoneServiceTest(){
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('esaCode','1');
    inputMap.put('czpId','1');
    inputMap.put('contractStartDate','2019-11-08'); 
    
    String es = String.valueOf(inputMap.get('esaCode'));
    String czp = String.valueOf(inputMap.get('czpId'));
    String csd = String.valueOf(inputMap.get('contractStartDate'));
                
    Map<String, Object> returnMap = new Map<String, Object>();

    ChargeZoneController czcode = new ChargeZoneController();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
    returnMap = czcode.getData(inputMap);
    ChargeProductZoneHandler.callChargeProductZoneService(es,csd,czp);
    Test.stopTest();
    //laxmi EDGE-137160 Changed the assert with proper values
    System.assertEquals('URBAN', returnMap.get('Zone SLA').toString());

}

@isTest static void getDataNullTest(){   
    
    ChargeZoneController czcode = new ChargeZoneController();
    Map<String, Object> returnMap = new Map<String, Object>();
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('esaCode',null);
    inputMap.put('czpId',null);
    inputMap.put('contractStartDate',null);         
    Test.startTest();
    returnMap = czcode.getData(inputMap);
    Test.stopTest();
    System.assertEquals(null, returnMap);
}

@isTest static void fetchProductChargeZoneInfoTest(){
    Test.startTest();
    cscrm__Site__c site=[select Id from cscrm__Site__c Limit 1];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
    GetChargeZoneAPIDTO response=ChargeProductZoneHandler.fetchProductChargeZoneInfo(site.id,true,false);
    System.assertEquals(response!=null,true);
    Test.stopTest();      
}
@isTest static void fetchProductChargeNegativeTest(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c ];
    set<Id> siteRecordId=new set<Id>();
    for(cscrm__Site__c site:siteList){
        siteRecordId.add(site.Id);
    }
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
    ChargeProductZoneHandler.storeProductChargeZoneInfo(siteRecordId);
    GetChargeZoneAPIDTO response=ChargeProductZoneHandler.fetchProductChargeZoneInfo(siteList[0].id,true,false);
    System.assertEquals(response!=null,true);
    Test.stopTest();      
}
@isTest static void refreshProductChargeZoneInfoTest(){
    Test.startTest();        
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
    GetChargeZoneAPIDTO response=ChargeProductZoneHandler.refreshProductChargeZoneInfo(siteList[0].id,true);
    System.assertEquals(response!=null,true);
    Test.stopTest();      
} 
@isTest static void callChargeZoneServiceExceptionTest(){                     
    Test.startTest();
    try{
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('errorZone'));
    GetChargeZoneAPIDTO dtoTest1 = ChargeProductZoneHandler.callChargeProductZoneService(null,null,null);
    
    }
    catch(Exception ex){
        System.assertEquals(ex.getMessage(),'Attempt to de-reference a null object');
    }        
    Test.stopTest();        
}
@isTest static void testgetData(){
    Test.startTest();
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String,Object> returnMap = new Map<String,Object>();
    inputMap.put('esaCode',null);
    inputMap.put('czpId','1');
    inputMap.put('contractStartDate','2019-11-08');
    ChargeZoneController chargeZone = new ChargeZoneController();
    returnMap= chargeZone.getData(inputMap);
    Test.stopTest();
    System.assertEquals(returnMap==null,true);
}
@isTest static void testgetDataException(){
    Test.startTest();
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String,Object> returnMap = new Map<String,Object>();
    inputMap.put('esaCode','TestException');
    inputMap.put('czpId','1');
    inputMap.put('contractStartDate','2019-11-08');
    ChargeZoneController chargeZone = new ChargeZoneController();
    returnMap= chargeZone.getData(inputMap);
    Test.stopTest();
    System.assertEquals(returnMap!=null,false);
}
 //DIGI-33904 Test method for Telstra Fibre product rental mapping 
@isTest static void testchargeZoneGroupA(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('zoneProduct'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'Telstra Fibre');
    System.assertEquals(response.zone.rental=='zone 1',true);
    Test.stopTest();      
}
//DIGI-33904 Test method for NBN product rental mapping 
@isTest static void testchargeZoneGroupB(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('zoneProduct'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'NBN TC2');
    System.assertEquals(response.zone.rental=='National',true);
    Test.stopTest();      
}
//DIGI-33904 Test method for Group C prodcut rental mapping 
@isTest static void testchargeZoneGroupC(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('zoneProduct'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'TID Adapt');
    System.assertEquals(response.zone.rental=='National',true);
    Test.stopTest();      
}
//DIGI-33904 Test method for SLA prodcut rental mapping 
@isTest static void testchargeZoneGroupD(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('zoneSLA'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'SLA');
    System.assertEquals(response.zone.rental=='Rural',true);
    Test.stopTest();      
}
//DIGI-33904 Test method for checking Empty Product
@isTest static void testEmptyProduct(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('productEmpty'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'TID Adapt');
    System.assertEquals(response.zone.rental==null,true);
    Test.stopTest();
}
//DIGI-33904 Test method for checking Invalid Rental
@isTest static void testInvalidRental(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('rentalInvalid'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'TID Adapt');
    System.assertEquals(response.zone.rental==null,true);
    Test.stopTest(); 
}
//DIGI-33904 Test method for checking DC Rate Card
@isTest static void testDCRateCard(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('zoneDC'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'DC Rate Card');
    System.assertEquals(response.zone.rental!=null,true);
    Test.stopTest();
    }
//DIGI-33904 Test method for checking Product Not Available
@isTest static void testProductNotAvailable(){
    Test.startTest();
    List<cscrm__Site__c> siteList=[select Id from cscrm__Site__c];
    Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('NotAvailable'));
    GetChargeZoneAPIDTO response=ChargeZoneController.chargeZoneProductMapping(siteList[0].Id,true,'BIP Adapt');
    System.assertEquals(response.zone.rental==null,true);
    Test.stopTest();
    }
}