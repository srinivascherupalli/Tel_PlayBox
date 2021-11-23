/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Class to cover : ReplicatorGetSiteServiceV2
 * Revision :
 * 
 * *****************************************************************************/
@isTest
public class ReplicatorGetSiteServiceV2Test {

    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Method to cover success scenario
 * Revision :
 * 
 * *****************************************************************************/
    static testMethod void getCustomerSites_withoutErrorTest() {
        Test.startTest();
       
        String TestCIDN = '1234';
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMockV2());
            ReplicatorGetSiteDataObject_V2 getSiteDTO = ReplicatorGetSiteServiceV2.getCustomerSites(TestCIDN);
            System.debug('GetSiteDTOTest: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
        Test.stopTest();
    }
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Method to cover error 404 Scenario
 * Revision :
 * 
 * *****************************************************************************/
    @isTest
    static void getCustomerSites_with404ErrorTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new ReplicatorResponseMockV2());
        ReplicatorGetSiteDataObject_V2 getSiteDTO = ReplicatorGetSiteServiceV2.getCustomerSites('404');
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
        Test.stopTest();
        
    }
    
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Method to cover error 500 Scenario
 * Revision :
 * 
 * *****************************************************************************/
    @isTest
    static  void getCustomerSites_with500ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMockV2());
            ReplicatorGetSiteDataObject_V2 getSiteDTO = ReplicatorGetSiteServiceV2.getCustomerSites('500');
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
        Test.stopTest();
    }
    
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Method to cover error 503 Scenario
 * Revision :
 * 
 * *****************************************************************************/
    @isTest
    static  void getCustomerSites_with503ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMockV2());
            ReplicatorGetSiteDataObject_V2 getSiteDTO = ReplicatorGetSiteServiceV2.getCustomerSites('503');
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
           
        Test.stopTest();
    }
    
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Method to cover exception Scenario
 * Revision :
 * 
 * *****************************************************************************/
     @isTest
    static  void getCustomerSites_withException() {
        Test.startTest();
            ReplicatorGetSiteDataObject_V2 getSiteDTO = ReplicatorGetSiteServiceV2.getCustomerSites('Exception');
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO == null);
        Test.stopTest();
    } 
 
}