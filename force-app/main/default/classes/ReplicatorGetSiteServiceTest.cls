@isTest
public class ReplicatorGetSiteServiceTest {
    
    @testSetup static void setup() {
        ProductTestService.getNewAccount('Test Account');
    }
    
    static testMethod void getCustomerSites_withoutErrorTest() {
        Test.startTest();
        List<Account> acctList = new List<Account>([SELECT Id FROM Account WHERE name = 'Test Account']);
        System.assertEquals(acctList.size(), 1, 'Unexpected number of Accounts retrived');
        Account acct = acctList.get(0);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites(acct.Id);
            System.debug('GetSiteDTO: ' + getSiteDTO);
            
            System.assert(getSiteDTO != null);
            System.assertEquals(getSiteDTO.CIDN, '212', 'Error, incorrect CIDN');
            
            System.assert(getSiteDTO.Site != null, 'Error, response do not contain any sites');
            List<ReplicatorGetSiteDataObject.SiteDTO> siteList = new List<ReplicatorGetSiteDataObject.SiteDTO>(getSiteDTO.Site);
            System.assertEquals(siteList.size(), 2, 'Error, unexpected number of sites in the response');
            ReplicatorGetSiteDataObject.SiteDTO site = siteList.get(0);
            
            System.assertEquals(site.ADBoR_ID, '111', 'Error, incorrect ADBoR_ID for site');
            System.assertEquals(site.ADBoR_Postcode, '3000', 'Error, incorrect ADBoR_Postcode for site');
            
            System.assert(site.Contact != null, 'Error, response missing contacts');
            List<ReplicatorGetSiteDataObject.SiteContactDTO> contactList = new List<ReplicatorGetSiteDataObject.SiteContactDTO>(site.Contact);
            System.assertEquals(contactList.size(), 2, 'Error, unexpected number of contacts in the response');
            
            ReplicatorGetSiteDataObject.SiteContactDTO contact = contactList.get(0);
            System.assertEquals(contact.Site_Contact_First_Name, 'Ben', 'Error, incorrect First Name for contact');
            System.assertEquals(contact.Site_Contact_Last_Name, 'Smith', 'Error, incorrect Last Name for contact');
            
        Test.stopTest();
    }
   
    static testMethod void getCustomerSites_with404ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites('errorId'+ IntegrationRecordHandlerUtil.ERROR_404_CODE);
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
            System.assertEquals(getSiteDTO.Error_Code, String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }
    
    static testMethod void getCustomerSites_with500ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites('errorId'+ IntegrationRecordHandlerUtil.ERROR_500_CODE);
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
            System.assertEquals(getSiteDTO.Error_Code, String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }

    static testMethod void getCustomerSites_with503ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites('errorId'+ IntegrationRecordHandlerUtil.ERROR_503_CODE);
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
            System.assertEquals(getSiteDTO.Error_Code, String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }
    
    static testMethod void getCustomerSites_withErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites('errorId');
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO != null);
            System.assertEquals(getSiteDTO.Error_Description,Label.Replicator_Technical_Error_Message);
        Test.stopTest();
    }
    
    static testMethod void getCustomerSitesCalloutTest() {
        Test.startTest();
        List<Account> acctList = new List<Account>([SELECT Id FROM Account WHERE name = 'Test Account']);
        System.assertEquals(acctList.size(), 1, 'Unexpected number of Accounts retrived');
        Account acct = acctList.get(0);
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites(acct.Id);
            System.debug('GetSiteDTO: ' + getSiteDTO);
            System.assert(getSiteDTO.CIDN!=null);
        Test.stopTest();    
    }  
}