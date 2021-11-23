/***********************************************************************************************************
Name          : SCSQCheckControllerTest
Created By    : Venkata Ramanan G
Created Date  : July 22 2019
Description   : This is a test class for SCSQCheckController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Venkata         22-07-2019      Created
**********************************************************************************************************/
@isTest
private class SCSQCheckControllerTest  {

    @testSetup
    public static void testdatasetup(){
            Account acc = new Account(name ='Test Acc');
        	acc.Account_Status__c ='Active' ;
        acc.Customer_Status__c = 'ACTIVE';
            insert acc;
            Opportunity opp = new Opportunity(name='Test Opp',AccountId=acc.id,Product_Domain__c='FIXED TELEPHONY',StageName='Propose',CloseDate=system.today()+10,Description='testopp');
            insert opp;
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(name='Test basket1',cscfga__Opportunity__c=opp.id);
            insert basket;
            List<cscrm__Address__c> addresslst = new List<cscrm__Address__c>();
            cscrm__Address__c address1 = new cscrm__Address__c(name='Test Address1',Address_ID__c='4124111', Address_Status__c='CONFIRMED');
            addresslst.add(address1);
            cscrm__Address__c address2 = new cscrm__Address__c(name='Test Address2',Address_ID__c='4124112', Address_Status__c='CONFIRMED');
            addresslst.add(address2);
            insert addresslst;
            List<cscrm__Site__c> sitelst = new List<cscrm__Site__c>();
            cscrm__Site__c site1 = new cscrm__Site__c(cscrm__Account__c=acc.id, cscrm__Installation_Address__c=addresslst[0].id);
            sitelst.add(site1);
            cscrm__Site__c site2 = new cscrm__Site__c(cscrm__Account__c=acc.id,cscrm__Installation_Address__c=addresslst[1].id);
              sitelst.add(site2);
            insert sitelst;
            List<Service_Qualification__c> sqlst = new List<Service_Qualification__c>();
                Service_Qualification__c sq1 = new  Service_Qualification__c(name='test1',Site__c=sitelst[0].id,Status__c='Available',Service_Type__c='Internet',CreatedDate=system.today()-15);
                //Service_Qualification__c sq2 = new  Service_Qualification__c(name='test2',Site__c=sitelst[1].id,Status__c='Available',Service_Type__c='Internet',CreatedDate=system.today()-1);
            sqlst.add(sq1);
            //sqlst.add(sq2);
            
            insert sqlst;
        SQ_Check_Enablement__c sqenablement = new SQ_Check_Enablement__c(name='Test',Is_SQ_Check_Enabled__c=True);
        insert sqenablement;
    }
    
    public static Integration_Handler__mdt getChangedCustomMetadataRecord(String Name) {
        Integration_Handler__mdt theRecord = [SELECT Id, DeveloperName from Integration_Handler__mdt where DeveloperName = :Name LIMIT 1];
        theRecord.Enable_Mock_Integration__c=true;
        theRecord.Mock_End_Point__c='https://slot1.org009.t-dev.telstra.net/v2/servicequalification/service-addresses';
        theRecord.Enable_MASSL__c=true;
        theRecord.Is_Sync_Call__c=false; 
        return theRecord;
    }


    @isTest
    private static void fetchSiteInfoTest(){
        PageReference currPage = Page.SCSQCheckPage;                                                        
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c limit 1];
        System.currentPageReference().getParameters().put('basketId', basket.id);
        System.currentPageReference().getParameters().put('adborId','4124111' );
        System.currentPageReference().getParameters().put('configGUID', '212412');
        
        
        // Create the page controller
        SCSQCheckController controller = new SCSQCheckController();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        controller.initiateSQCheck();
        Test.setCurrentPage(currPage);
         system.assertEquals(1,controller.adborIdsToSQ.size());
        

    } 
    @isTest
    private static void fetchSiteInfoTestwithSQEnablement(){
    Test.startTest();
     
        PageReference currPage = Page.SCSQCheckPage;                                                        
        SQ_Check_Enablement__c enablement = [select id from SQ_Check_Enablement__c LIMIT 1];
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c limit 1];
        Integration_Handler__mdt data1 = getChangedCustomMetadataRecord('SiteSQAddressHandler');
        System.currentPageReference().getParameters().put('basketId', basket.id);
        System.currentPageReference().getParameters().put('adborId','4124112');
        System.currentPageReference().getParameters().put('configGUID', '212413');
        
        
        SCSQCheckController controller = new SCSQCheckController();
        
        Test.setCurrentPage(currPage);
        
        Test.setMock(HttpCalloutMock.class, new MockSCSQCheckCalloutResponseGenerator());
        controller.initiateSQCheck();
        system.assertEquals('Yes',controller.sqCheckEnabled);
        Test.stopTest();

    }
}