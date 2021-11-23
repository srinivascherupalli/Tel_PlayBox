/*
* Edge-113351
*@Desc: Test class for NBNEastCallout
*/ 

@isTest 
public class NBNEastCalloutNewTest {
    private static String adborId;
    private static String replicatorAddress = '{"CIDN":"1891494117","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"Melbourne CBD","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"25","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Site_Address_Status":"CO","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]},{"ADBOR_ID":"113","Media_Type":"NBN","Site_Nick_Name":"Sydney CBD","ADDRESS_NO_FROM":"234","ADDRESS_NO_TO":"278","SUFFIX_FROM":"Suf","SUFFIX_TO":"Suf","STREET_NAME":"Lakeview","STREET_TYPE":"Drive","LOC_NAME":"","ADBOR_POSTCODE":"2002","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"C1","SUB1_DESCRIPTOR_1":"S1D1","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"C2","SUB2_DESCRIPTOR_1":"S2D1","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"C3","SUB3_DESCRIPTOR_1":"S3D1","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"C4","SUB4_DESCRIPTOR_1":"S4D1","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","ADDRESS_STATUS":"","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"true","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
  
    private static AddressRequestDTO createRequestDTO(String adborID){
        AddressRequestDTO req;
        try{
            req=new AddressRequestDTO();
            req.data =new AddressRequestDTO.Data();
            req.data.adborId=adborID;
        }catch(Exception e){
                        
        }
        System.debug('RequestDTO:'+req.data);
        return req; 
    }
	 @TestSetup static void dataSetup(){
	 
		//CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='212';
        insert acc;
        System.assertNotEquals(null,acc);
        //Create address
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        cscrm__Address__c addrs2 = new cscrm__Address__c();
        addrs2.Address_ID__c = '111';
        addrs2.Name = 'Test Address';
        addrs2.cscrm__Account__c = acc.id;
        lstAddress.add(addrs2);
        insert lstAddress;
        
        //Create site
        cscrm__Site__c siteobj1 = new cscrm__Site__c();
        siteobj1.Name = 'Test Site1';
        siteobj1.cscrm__Account__c = acc.id;
        siteobj1.cscrm__Installation_Address__c = lstAddress[0].Id;
        siteobj1.Status__c = 'Active';
        siteobj1.Legacy__c = true;
        siteobj1.site_nick_name__c='test123';
		//siteobj1.Display_Name__c='test 12345';
        insert siteobj1;
        
	 }
    @isTest
     Public static void eastCalloutAndUpsertAddressAndSiteSuccessTest(){         
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
        Service_Qualification__c sq=new Service_Qualification__c();
        sq.Address_ID__c='111';
        Service_Qualification_Provider_Resource__c sqp=new Service_Qualification_Provider_Resource__c();
        List<Service_Qualification_Provider_Resource__c> sqplist=new List<Service_Qualification_Provider_Resource__c>();
        sqplist.add(sqp);
        adborId='111';
         string cidn='212';
        AddressRequestDTO req=createRequestDTO(adborId);
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        Test.startTest();
        ID JobId= System.enqueueJob(new NBNEastCalloutNew(req,adborID,cidn,siteDTO,sq,sqplist));
        Test.stopTest();
        List<cscrm__Address__c> address=[SELECT Address_ID__c FROM cscrm__Address__c where Address_ID__c='111'];
        System.assert(address!=null);
     }
     
     @isTest  
     Public static void eastCalloutAndUpsertAddressAndSiteFailureTest(){
        
        //Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
        adborId='112';
         String Cidn='113';
         Service_Qualification__c sq=new Service_Qualification__c();
         sq.Address_ID__c='112';
         List<Service_Qualification_Provider_Resource__c> providerresourceList=new List<Service_Qualification_Provider_Resource__c>();
        AddressRequestDTO req=createRequestDTO(adborId);
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        Test.startTest();
        ID JobId= System.enqueueJob(new NBNEastCalloutNew(req,adborID,cidn,siteDTO,sq,providerresourceList));
         NBNEastCalloutNew.UpsertSQRecords(sq,providerresourceList,cidn+adborID);
        Test.stopTest();         
        List<cscrm__Address__c> address=[SELECT Address_ID__c FROM cscrm__Address__c where Address_ID__c='112'];
        System.assert(address.isEmpty()==true); 
         
     }

}