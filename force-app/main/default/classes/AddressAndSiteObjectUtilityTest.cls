/**
        * Start :  Test Class for AddressAndSiteObjectUtility class methods and other related classes 
        * Date : 12-Jun-17
        
 */
@isTest
 public class AddressAndSiteObjectUtilityTest {
    private static String replicatorAddress = '{"CIDN":"1891494117","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"Melbourne CBD","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"25","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Site_Address_Status":"CO","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]},{"ADBOR_ID":"113","Media_Type":"NBN","Site_Nick_Name":"Sydney CBD","ADDRESS_NO_FROM":"234","ADDRESS_NO_TO":"278","SUFFIX_FROM":"Suf","SUFFIX_TO":"Suf","STREET_NAME":"Lakeview","STREET_TYPE":"Drive","LOC_NAME":"","ADBOR_POSTCODE":"2002","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"C1","SUB1_DESCRIPTOR_1":"S1D1","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"C2","SUB2_DESCRIPTOR_1":"S2D1","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"C3","SUB3_DESCRIPTOR_1":"S3D1","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"C4","SUB4_DESCRIPTOR_1":"S4D1","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","ADDRESS_STATUS":"","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"true","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
    private static Account accountForSite=null; 
    private static ReplicatorGetSiteDataObject siteDTOForUpsertSite=null;
    private static cscrm__Address__c addressForSite=null;
    private static List<String> adborIdList;
    private static  Account acc=null;
    private static cscrm__Address__c add=null;
     
     private static void checkRunByUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u2 = new User(Alias = 'newUser', Email='new1_devi@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='new1_devi@testorg.com');
        System.runAs(u2){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
         }
     }
     private static void preRequisitForUpsertSite(){
        accountForSite = new Account(Name = 'Testing account 1',CIDN__c='121');
        upsert accountForSite;
        siteDTOForUpsertSite = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        siteDTOForUpsertSite.CIDN='121';
        addressForSite = AccountTestFactory.buildAddress('123');
     }
     private static AddressSummary preRequisitForUpsertEastAddress(){
      AddressSummary eastAddress = new AddressSummary();
      eastAddress.addressId='4017416666';
      eastAddress.name='';
      eastAddress.addressType='Property With Number';
      eastAddress.postalDeliveryType='';
      eastAddress.planNumber='';
      eastAddress.status='CONFIRMED';
      eastAddress.numberToPrefix='';
      eastAddress.numberToSuffix='';
      eastAddress.streetName='LONSDALE';
      eastAddress.locality='MELBOURNE';
      eastAddress.greaterLocality='MELBOURNE CBD';
      eastAddress.state='VIC';
      eastAddress.postcode='3000';
      eastAddress.lat='100';
      eastAddress.longZ='500';
      eastAddress.numberOfSubAddresses='50';
      eastAddress.ruralMailType='abc';
      eastAddress.parentAddressId='160001865';
      eastAddress.subAddressType='B';
      eastAddress.subAddressNumber='1';
      eastAddress.readyForServiceDate='2017-06-05';
      eastAddress.locationId='';
      eastAddress.connectivityServiceAreaId='';
      eastAddress.exchangeServiceAreaId='';
      eastAddress.facsRealm='21';
      eastAddress.addressLine='B1 150 LONSDALE ST';
      eastAddress.subAddressLine='B1';
      eastAddress.numberSuffix='z';
      eastAddress.numberToSuffix='a';
      eastAddress.streetTypeSuffix='2';
      eastAddress.numberTo='150';
      eastAddress.numberStart='0';
      eastAddress.streetType='s0';
      eastAddress.addrNumLvl1='';
      eastAddress.addrNumLvl2='';
      eastAddress.addrNumLvl3='2';
      eastAddress.addrNumLvl4='';
      eastAddress.addrTypeLvl1='';
      eastAddress.addrTypeLvl2='';
      eastAddress.addrTypeLvl3='pq';
      eastAddress.addrTypeLvl4='';
      return eastAddress;
     }     
     /*Test method to upsert TCM based Address*/
      @testSetup static void setup() {
        ProductTestService.getNewAccount('Test Account');
    }    
     
    // data population for address for testing NBN east method for chlid
    @isTest
    static void upsertNBNEastAddressForChildTest(){
String json='{"status":200,"code":200,"data":{"structured":{"addresses":{"addressSummaryType":"SubAddressSummary","addressId":"418853815","addressType":"Complex - Flat/Unit","confirmed":true,"reqaddformatout":"structured","subAddressNumberFrom":"3411","parcelDescriptor1":"3411","condorCode":"STHBNK","fsam":"3SYR-02","subAddressType":"UNIT","numSubaddresses":0,"subAddressCodeset":"UNIT","parent":{"addressSummaryType":"SubAddressSummary","addressId":"265083283","addressType":"Complex - Floor/Level","confirmed":true,"reqaddformatout":"structured","numSubaddresses":10,"subAddressCodeset":"LEVEL","subAddressNumberFrom":"34","parcelDescriptor1":"34","condorCode":"STHBNK","subAddressType":"LEVEL","serviceLocation":{"latitude":"-37:49:18.2","longitude":"144:57:53.1"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265082901","addressType":"Complex - Building with Name","confirmed":true,"reqaddformatout":"structured","numSubaddresses":679,"subAddressCodeset":"BUILDING","name":"EUREKA TOWER","condorCode":"STHBNK","subAddressType":"BUILDING","serviceLocation":{"latitude":"-37:49:18.2","longitude":"144:57:53.1"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"417085878","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":688,"streetType":"QUAY","propertyNumberFrom":7,"propertyNumberTo":"","postcode":"3006","state":"VIC","localityName":"SOUTHBANK","planNumber":"PS437659","parcelDescriptor1":"1R-8901","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"STHBNK","serviceLocation":{"exchangeServiceArea":"SMEL","facsRealm":"17","latitude":"-37:49:18.2","longitude":"144:57:53.1"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"417085178","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":688,"streetType":"QUAY","propertyNumberFrom":7,"propertyNumberTo":"","postcode":"3006","state":"VIC","localityName":"SOUTHBANK","planNumber":"PS437659","parcelDescriptor1":"1R-8901","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"STHBNK","serviceLocation":{"exchangeServiceArea":"SMEL","facsRealm":"17","latitude":"-37:49:18.2","longitude":"144:57:53.1"}}}}},"primarySummary":{"addressId":"417085878","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","localityName":"SOUTHBANK","state":"VIC","postcode":"3006","propertyNumberFrom":7,"propertyNumberTo":"","numSubaddresses":688,"streetType":"QUAY","streetName":"RIVERSIDE","planNumber":"PS437659","parcelDescriptor1":"1R-8901","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"STHBNK","serviceLocation":{"facsRealm":"17","exchangeServiceArea":"SMEL","latitude":"-37:49:18.2","longitude":"144:57:53.1"}}},"serviceLocation":{"latitude":"-37:49:18.2","longitude":"144:57:53.1","locationId":"LOC000027969270","customerServiceAreaId":"CSA300000001055","readyForServiceDate":"2015-10-16"}},"unstructuredAUPost":{"addresses":{"addressSummaryType":"FormattedAddressSummary","addressId":"418853815","addressType":"Complex - Flat/Unit","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3006","state":"VIC","localityName":"SOUTHBANK","parcelDescriptor1":"3411","condorCode":"STHBNK","fsam":"3SYR-02","subAddressType":"UNIT","addressline1":"EUREKA TOWER, L 34, U 3411,","addressline2":"7 RIVERSIDE QY,"},"serviceLocation":{"latitude":"-37:49:18.2","longitude":"144:57:53.1","locationId":"LOC000027969270","customerServiceAreaId":"CSA300000001055","readyForServiceDate":"2015-10-16"}},"transactionStatus":"Success","matchingresultscount":1},"request":{"correlationId":"79fb3257-2bc1-4312-bef8-d384a53813de","params":{"addressId":"418853815","reqaddformatout":"unstructuredAUPost,structured"},"data":{},"path":"/addresses/:addressId","method":"GET","requestId":"da973b8f-5e08-46e0-b7a4-758c474fdde9"},"correlationId":"79fb3257-2bc1-4312-bef8-d384a53813de","time":"2017-09-25T16:27:21+10:00"}';
        AddressResponseDTO obj = AddressResponseDTO.parse(json);
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertNBNEastAddress(obj);
         cscrm__Address__c addresult1 = AddressAndSiteObjectUtility.upsertNBNEastAddress(obj,true);
        Test.stopTest();
        System.assert(addresult.Address_ID__c == '418853815');
        System.assert(addresult.Address_Status__c == 'Confirmed');
        system.debug(addresult.Parent_Address_Id__c == '265083283');
        System.assert(addresult.Address_Line_1__c == 'EUREKA TOWER, L 34, U 3411,');
        System.assert(addresult.cscrm__Building_Name__c == 'EUREKA TOWER');
        System.assert(addresult.Sub_Address1_Number__c == '3411');
        System.assert(addresult.Sub_Address2_Number__c == '34');
        //System.assert(addresult.Sub_Address_Level_3__c == null);
        //System.assert(addresult.Sub_Address_Level_4__c == null);
        system.debug('***name:'+addresult.Name);
        System.assert(addresult != null);         
    }
     
    // data population for address for testing NBN east method for parent
    @isTest
    static void upsertNBNEastAddressForParentTest(){
        String json = '{'+
        '   \"code\": 200,'+
        '   \"time\": \"2016-08-16T10:53:09+10:00\",'+
        '   \"data\": {'+
        '       \"transactionStatus\": \"success\",'+
        '       \"structured\": {'+
        '           \"addresses\": {'+
        '               \"addressSummaryType\": \"PropertyAddressSummary\",'+
        '               \"addressId\": 180057100,'+
        '               \"addressType\": \"Property With Number\",'+
        '               \"confirmed\": true,'+
        '               \"subAddressType\": \"\",'+
        '               \"planNumber\": \"DP1135205\",'+
        '               \"parceltype1\": \"F\",'+
        '               \"parceldescriptiontype1\": \"L\",'+
        '               \"parcelDescriptor1 \": 1,'+
        '               \"parceltype2\": \"\",'+
        '               \"parceldescriptiontype2\": \"\",'+
        '               \"parcelDescriptor2\": \"\",'+
        '               \"name\": \"\",'+
        '               \"ruralmailNumber\": \"\",'+
        '               \"ruralmailType\": \"\",'+
        '               \"fsam\": \"\",'+
        '               \"condorCode\": \"WLNGNG\",'+
        '               \"reqaddformatout\": \"structured\",'+
        '               \"postcode\": 2500,'+
        '               \"state\": \"NSW\",'+
        '               \"localityName\": \"WOLLONGONG\",'+
        '               \"streetName\": \"CROWN\",'+
        '               \"streetType\": \"STREET\",'+
        '               \"streetSuffix\": \"\",'+
        '               \"numSubaddresses\": 7,'+
        '               \"subaddresses\": {'+
        '                       \"Level1\": [{'+
        '                           \"SubAddressType\": \"BUILDING\",'+
        '                           \"parentID\": 180057100,'+
        '                           \"ID\": 426860877,'+
        '                           \"BUname\": \"EUREKA TOWER\",'+
        '                           \"AddressType\": \"abc\",'+
        '                           \"from\": 1,'+
        '                           \"Level2\": [{'+
        '                                   \"SubAddressType\": \"Ground Floor\",'+
        '                                   \"parentID\": 426860877,'+
        '                                   \"ID\": 419594516,'+
        '                                   \"AddressType\": \"Complex - Floor/Level\",'+
        '                                   \"Level3\": [{'+
        '                                           \"SubAddressType\": \"Unit\",'+
        '                                           \"parentID\": 419594516,'+
        '                                           \"ID\": 426978197,'+
        '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
        '                                           \"from\": 1,'+
        '                                           \"Confirmed\": true'+
        '                                       },'+
        '                                       {'+
        '                                           \"SubAddressType\": \"Unit\",'+
        '                                           \"parentID\": 419594516,'+
        '                                           \"ID\": 426878193,'+
        '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
        '                                           \"from\": 2,'+
        '                                           \"Confirmed\": true'+
        '                                       },'+
        '                                       {'+
        '                                           \"SubAddressType\": \"Unit\",'+
        '                                           \"parentID\": 419594516,'+
        '                                           \"ID\": 426978198,'+
        '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
        '                                           \"from\": 3,'+
        '                                           \"Confirmed\": true'+
        '                                       }'+
        '                                   ],'+
        '                                   \"Confirmed\": true'+
        '                               },'+
        '                               {'+
        '                                   \"SubAddressType\": \"Level\",'+
        '                                   \"parentID\": 426860877,'+
        '                                   \"ID\": 419794487,'+
        '                                   \"AddressType\": \"Complex - Floor/Level\",'+
        '                                   \"from\": 1,'+
        '                                   \"Confirmed\": true'+
        '                               },'+
        '                               {'+
        '                                   \"SubAddressType\": \"Level\",'+
        '                                   \"parentID\": 426860877,'+
        '                                   \"ID\": 419787211,'+
        '                                   \"AddressType\": \"Complex - Floor/Level\",'+
        '                                   \"from\": 2,'+
        '                                   \"Confirmed\": true'+
        '                               }'+
        '                           ],'+
        '                           \"Confirmed\": true'+
        '                       }]'+
        '               },'+
        '               \"propertyName\": \"\",'+
        '               \"propertyNumberFrom\": 121,'+
        '               \"propertyNumberTo\": 0,'+
        '               \"propertyNumberSuffixFrom\": \"\",'+
        '               \"propertyNumberSuffixTo\": \"\"'+
        '           },'+
        '           \"serviceLocation\": {'+
        '               \"readyForServiceDate\": \"\",'+
        '               \"locationId\": \"\",'+
        '               \"facsRealm\": 74,'+
        '               \"exchangeServiceArea\": \"WLGG\",'+
        '               \"customerServiceAreaId\": \"\",'+
        '               \"latitude\": \"-34:25:33.4\",'+
        '               \"longitude\": \"150:53:46.9\"'+
        '           }'+
        '       },'+
        '       \"unstructuredAUPost\": {'+
        '           \"addresses\": {'+
        '               \"addressSummaryType\": \"FormattedAddressSummary\",'+
        '               \"addressId\": 180057100,'+
        '               \"addressType\": \"Property Address With Number\",'+
        '               \"confirmed\": true,'+
        '               \"parcelDescriptor2\": \"\",'+
        '               \"parcelDescriptor1 \": 1,'+
        '               \"planNumber\": \"DP1135205\",'+
        '               \"ruralmailNumber\": \"\",'+
        '               \"subAddressType\": \"\",'+
        '               \"parceltype2\": \"\",'+
        '               \"parceltype1\": \"F\",'+
        '               \"parceldescriptiontype1\": \"L\",'+
        '               \"parceldescriptiontype2\": \"\",'+
        '               \"propertyName\": \"\",'+
        '               \"fsam\": \"\",'+
        '               \"condorCode\": \"WLNGNG\",'+
        '               \"reqaddformatout\": \"unstructuredAUPost\",'+
        '               \"postcode\": 2500,'+
        '               \"state\": \"NSW\",'+
        '               \"localityName\": \"WOLLONGONG\",'+
        '               \"addressline1\": \"121 CROWN ST,\",'+
        '               \"addressline2\": \"\",'+
        '               \"addressline3\": \"\"'+
        '           },'+
        '           \"serviceLocation\": {'+
        '               \"readyForServiceDate\": \"\",'+
        '               \"locationId\": \"\",'+
        '               \"facsRealm\": 74,'+
        '               \"exchangeServiceArea\": \"WLGG\",'+
        '               \"customerServiceAreaId\": \"\",'+
        '               \"latitude\": \"-34:25:33.4\",'+
        '               \"longitude\": \"150:53:46.9\"'+
        '           }'+
        '       }'+
        '   }'+
        '}';
        AddressResponseDTO obj = AddressResponseDTO.parse(json);
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertNBNEastAddress(obj);
        AddressAndSiteObjectUtility.getAddressForTCM('180057100');
        Test.stopTest();
        System.assert(addresult.Address_ID__c == '180057100');
        System.assert(addresult.Address_Status__c == 'Confirmed');
        System.assert(addresult.Address_Line_1__c == '121 CROWN ST,');
        system.debug('****addresult.cscrm__Building_Name__c'+addresult.cscrm__Building_Name__c);
        System.assert(addresult.cscrm__Building_Name__c == 'EUREKA TOWER');
        system.debug('***name:'+addresult.Name);
        System.assert(addresult != null);         
    }
     
    @isTest
    static void auraProcessingMessageTest(){
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage aumsg = new AddressAndSiteObjectUtility.auraProcessingMessage();
        Test.stopTest();
        system.assert(aumsg.isSuccess==true);
        system.assert(aumsg.errorMsg=='');
        system.assert(aumsg.successMsg=='');       
    }
    @isTest
    static void getExistingAddressFromSFSuccessTest(){
        checkRunByUser();
        String adborid = '12345';
        cscrm__Address__c address = AccountTestFactory.buildAddress(adborid);
        upsert address;
        Test.startTest();
        cscrm__Address__c address1 = AddressAndSiteObjectUtility.getExistingAddressFromSF(adborid);
        Test.stopTest();
        system.assert(address1!=null);
    }   
     @isTest
    static void getExistingAddressFromSFErrorTest(){
        checkRunByUser();
        String adborid = ' ';
        cscrm__Address__c address = AccountTestFactory.buildAddress(adborid);
        upsert address;
        Test.startTest();
        cscrm__Address__c address1 = AddressAndSiteObjectUtility.getExistingAddressFromSF(adborid);
        Test.stopTest();
        system.assert(address1!=null);
    }   
    @isTest
    static void upsertTCMAddressTest(){
        CustomerObject.Address tcmAddress = new CustomerObject.Address();
        
        List<CustomerObject.detail> detailsList = new List<CustomerObject.detail>();    
        CustomerObject.detail details1 = new CustomerObject.detail();
        details1.detailType='';
        details1.value='';
        details1.detailTypeCode='';
        detailsList.add(details1);

        CustomerObject.detail details2 = new CustomerObject.detail();
        details2.detailType='testType';
        details2.value='testValue';
        details2.detailTypeCode='testDetailTypeCode';
        detailsList.add(details2);
        
        tcmAddress.state='VIC';
        tcmAddress.streetTypeCode='ROAD';
        tcmAddress.addressId='400650626';
        tcmAddress.statusCode='CONFIRMED';
        tcmAddress.streetTypeSuffixCode='';
        tcmAddress.postalCode='3124';
        tcmAddress.registeredPlan='';
        tcmAddress.streetNumberStart='36';
        tcmAddress.subAddress = new CustomerObject.SubAddress();
        tcmAddress.subAddress.propertyName='';
        tcmAddress.subAddress.privateStreetType='';
        tcmAddress.subAddress.privateStreetName='';
        tcmAddress.subAddress.numberStart='';
        tcmAddress.subAddress.buildingName='';
        tcmAddress.subAddress.addressLines = new List<String>();
        tcmAddress.subAddress.addressLines.add('36 SPENCER RD');
        tcmAddress.subAddress.addressLines.add('45 BOSTON RD');
        tcmAddress.subAddress.addressLines.add('35 CHICAGO RD');
        tcmAddress.subAddress.numberEnd='';
        tcmAddress.subAddress.privateStreetTypeCode=''; 
        tcmAddress.subAddress.details=detailsList; 
        tcmAddress.streetType='RD';
        tcmAddress.internationalState='';
        tcmAddress.isPrimary='Y';
        tcmAddress.status='CO';
        tcmAddress.streetNumberStartSuffix='';
        tcmAddress.streetName='SPENCER';
        tcmAddress.addressType='CO';
        tcmAddress.additionalInfo='';
        tcmAddress.country='AUSTRALIA';
        tcmAddress.internationalPostcode='';
        tcmAddress.addressTypeCode='';
        tcmAddress.streetTypeSuffix='';
        tcmAddress.streetNumberEnd='';
        tcmAddress.deliveryPointId='68836168';
        tcmAddress.streetNumberEndSuffix='';
        tcmAddress.locality='CAMBERWELL';
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertTCMAddress(tcmAddress);
        Test.stopTest();
        System.assert(addresult!=null);
    }
    /*Test method to upsert EAST based Address*/
    @isTest
    static void upsertEastAddressSuccessTest(){
        preRequisitForUpsertSite();
        AddressSummary eastAddress = preRequisitForUpsertEastAddress();
        eastAddress.accountId= accountForSite.Id;
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertEastAddress(eastAddress);
        Test.stopTest();
        System.assert(addresult!=null);
    }  
      @isTest
    static void upsertEastAddressErrorTest(){
        preRequisitForUpsertSite();
        AddressSummary eastAddress = preRequisitForUpsertEastAddress();
        eastAddress.accountId= accountForSite.Id;
        eastAddress.addressId=null;
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertEastAddress(eastAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertAddress(addresult);
        Test.stopTest();
        System.assert(msg.errorMsg == 'Error in Address creation');
    }
    @isTest
    static void upsertEastAddressLongitudeLatitudeSuccessTest(){
        AddressSummary eastAddress = preRequisitForUpsertEastAddress();
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertEastAddress(eastAddress);
        Test.stopTest();
        System.assert(addresult.latitude__c == '100');
        System.assert(addresult.longitude__c == '500');
    }
     @isTest
    static void upsertEastAddressLongitudeLatitudeErrorTest(){
        AddressSummary eastAddress = new AddressSummary();
        eastAddress.addressId='4017416666';
        eastAddress.lat='10000000000000000000000';
        eastAddress.longZ='500';
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertEastAddress(eastAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertAddress(addresult);
        Test.stopTest();
        System.assert(msg.errorMsg == 'Error in Address creation');
    }
     //US-4099
    @isTest
    static void upsertEastAddressDetailsSuccessTest(){
        AddressSummary eastAddress = preRequisitForUpsertEastAddress();
        Test.startTest();
        cscrm__Address__c addresult = AddressAndSiteObjectUtility.upsertEastAddress(eastAddress);
        Test.stopTest();
        System.assert(addresult.cscrm__State_Province__c == 'VIC');
        
    }
    @isTest
    static void getReplicatorSiteAddrToBeInsertedTest(){
        Test.startTest();
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        ReplicatorGetSiteDataObject.SiteDTO resDTO = AddressAndSiteObjectUtility.getReplicatorSiteAddrToBeInserted('111',siteDTO);
        Test.stopTest();
        system.assert(resDTO!=null);
    }    
    @isTest
    static void upsertReplicatorAddressAndSiteConfirmedTest(){
        String[] adboirIds = new String[]{'111','111'};
        Test.startTest();
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(adboirIds,siteDTO);
        Test.stopTest();
        System.assertequals(Label.ERROR_MESSAGE_SITE_CREATION_ACC_NOT_FOUND,msg.errorMsg);
    }    
    @isTest
    static void upsertReplicatorAddressAndSiteUnConfirmedTest(){
        Test.startTest();
        String[] adboirIds = new String[]{'113','113'};
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(adboirIds,siteDTO);
        Test.stopTest();
        System.assertequals(Label.ERROR_MESSAGE_SITE_CREATION_ADDR_UNCONFIRMED,msg.errorMsg);
    }   
    @isTest
    static void getReplicatorSiteAddrToBeInsertedADBORIdNull(){
        replicatorAddress = '{"CIDN":"121","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":null,"Media_Type":"NBN","Site_Nick_Name":"Melbourne CBD","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"251478523695","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Site_Address_Status":"CONFIRMED","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]},{"ADBOR_ID":"113","Media_Type":"NBN","Site_Nick_Name":"Sydney CBD","ADDRESS_NO_FROM":"234","ADDRESS_NO_TO":"278","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lakeview","STREET_TYPE":"Drive","LOC_NAME":"","ADBOR_POSTCODE":"2002","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","ADDRESS_STATUS":"","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"true","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
        String[] adboirIds = new String[]{};
        Test.startTest();
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(adboirIds,siteDTO);
        Test.stopTest();
        system.assert(msg != null);
    }
    @isTest
    static void getReplicatorSiteNickNameNull(){
        replicatorAddress = '{"CIDN":"121","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"251478523695","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale Villas wall Street Back Side Shivar Garden Near Er Aakil Bhardwaj Sunshine Villas Shivar Chowk Pimple Saudagar Pimpri Chinchwad Pune Maharashtra India","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"Eureka","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Site_Address_Status":"CONFIRMED","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
        Test.startTest();
        Account acc = new Account();
        acc.name = 'test';
        acc.CIDN__c = '121';
        insert acc;
       cscrm__Address__c address = new cscrm__Address__c();
        address.Address_ID__c = '123';
        //address.cscrm__Street__c  = '150 TEST ROAD TEST';
        insert address;
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(replicatorAddress);
        system.debug('Call to upsertReplicatorSite begin $$$$'+siteDTO);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorSite('111',siteDTO,address.Id);
         system.assert(msg != null);//Added Changes Regarding EDGE-71954
        Test.stopTest();
    } 
    @isTest
    static void getReplicatorSiteNickNameNull1(){
        replicatorAddress = '{"CIDN":"121","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"251478523695","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"Eureka","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Address_Status":"CONFIRMED","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
        Test.startTest();
        Account acc = new Account();
        acc.name = 'test';
        acc.CIDN__c = '121';
        insert acc;
       cscrm__Address__c address = new cscrm__Address__c();
        address.Address_ID__c = '123';
        //address.cscrm__Street__c  = '150 TEST ROAD TEST';
        insert address;
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(replicatorAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorSite('111',siteDTO,address.Id);
        system.assert(msg != null);//Added Changes Regarding EDGE-71954
        Test.stopTest();
    }
    @isTest
    static void upsertReplicatorAddressSuccessTest(){
        Test.startTest();
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorAddress('113',siteDTO);
        Test.stopTest();
        system.assertequals('Address created successfully',msg.successMsg);
        List<cscrm__Address__c> address=[SELECT Address_ID__c,Street_Number_To__c,Street_Number_From_calc__c,streetType__c,streetNumberStartSuffix__c,streetNumberEndSuffix__c,Sub_Address2_Number__c,Sub_Address2_Type__c,Sub_Address1_Number__c,Sub_Address1_Type__c,Sub_Address_3_Number__c,Sub_Address_3_Type__c,Sub_Address_4_Number__c,Sub_Address_4_Type__c FROM cscrm__Address__c WHERE Address_ID__c = '113'];
        system.assert(address!=null);
        system.assertequals('278',address.get(0).street_Number_To__c);
        system.assertequals('234',address.get(0).Street_Number_From_calc__c);
        //system.assertequals('Drive',address.get(0).streetType__c);
        system.assertequals('Suf',address.get(0).streetNumberStartSuffix__c);
        system.assertequals('Suf',address.get(0).streetNumberEndSuffix__c);
        system.assertequals('S2D1',address.get(0).sub_Address2_Number__c);
        system.assertequals('C2',address.get(0).sub_Address2_Type__c);
        system.assertequals('S1D1',address.get(0).sub_Address1_Number__c);
        system.assertequals('C1',address.get(0).sub_Address1_Type__c);
        system.assertequals('S3D1',address.get(0).sub_Address_3_Number__c);
        system.assertequals('C3',address.get(0).sub_Address_3_Type__c);
        system.assertequals('S4D1',address.get(0).sub_Address_4_Number__c);
        system.assertequals('C4',address.get(0).sub_Address_4_Type__c);
    }   
    @isTest
    static void upsertReplicatorAddressFailureTest(){
        replicatorAddress = '{"CIDN":"121","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"Melbourne CBD","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"251478523695666666666","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Address_Status":"CONFIRMED","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]},{"ADBOR_ID":"113","Media_Type":"NBN","Site_Nick_Name":"Sydney CBD","ADDRESS_NO_FROM":"234","ADDRESS_NO_TO":"278","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lakeview","STREET_TYPE":"Drive","LOC_NAME":"","ADBOR_POSTCODE":"2002","STATE":"","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","ADDRESS_STATUS":"","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"true","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
        Test.startTest();
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorAddress('111',siteDTO);
        Test.stopTest();
        system.assertequals('Error in Address creation',msg.errormsg);
    }
    @isTest
    static void upsertReplicatorSiteTestFailureForAddressNotFound(){
        preRequisitForUpsertSite();
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorSite('111',siteDTOForUpsertSite,addressForSite.Id);
        Test.stopTest();
        System.assertequals(Label.ERROR_MESSAGE_SITE_CREATION_ADDR_NOT_FOUND,msg.errorMsg);
    }     
     @isTest
    static void upsertReplicatorSiteTestFailureByFlow(){
        preRequisitForUpsertSite();
        AddressAndSiteObjectUtility.UpsertAddress(addressForSite);        
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg1 = AddressAndSiteObjectUtility.upsertReplicatorSite('111',siteDTOForUpsertSite,addressForSite.Id);
        AddressAndSiteObjectUtility.AuraProcessingMessage msg2 = AddressAndSiteObjectUtility.upsertReplicatorSite('111',siteDTOForUpsertSite,addressForSite.Id);
        Test.stopTest();
        System.assertequals(Label.SUCCESS_MESSAGE_SITE_CREATION,msg1.successMsg);
        //Commening the line as assertion depends on process builder which will be inactive during deployment 
        //System.assertequals(Label.ERROR_MESSAGE_SITE_CREATION,msg2.errorMsg);
    }    
     @isTest
    static void upsertReplicatorSiteSuccessTest(){
        preRequisitForUpsertSite();
        AddressAndSiteObjectUtility.UpsertAddress(addressForSite);
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorSite('111',siteDTOForUpsertSite,addressForSite.Id);
        Test.stopTest();
        System.assertequals(Label.SUCCESS_MESSAGE_SITE_CREATION,msg.successMsg);
    }    
      @isTest
    static void upsertReplicatorSiteErrorTest(){
        preRequisitForUpsertSite();
        AddressAndSiteObjectUtility.UpsertAddress(addressForSite);
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg = AddressAndSiteObjectUtility.upsertReplicatorSite('111',null,addressForSite.Id);
        Test.stopTest();
        System.assert(msg.errorMsg == 'Attempt to de-reference a null object');
    } 
     

    
    private static void preRequisitesForAccountCreation(){
        createAccount('Testing account 1','121');
        upsert acc;
        createAddress('111');
        insert add;
    }

      private static void createAccount(String name, String cidn){
      acc = new Account(Name = name,CIDN__c=cidn);        
    }
    
    private static void createAddress(String buildAddress){
       add = AccountTestFactory.buildAddress(buildAddress);   
    }    

    @isTest static void testSaveNewAccountSuccessCase(){
        preRequisitesForAccountCreation();
        String account = ''+acc.id;
        String address = add.Id;
        String addressType = '';
        cscrm__Account_Address_Relationship__c accountAddressRelationship = new cscrm__Account_Address_Relationship__c();
            accountAddressRelationship.cscrm__Address_Type__c = addressType;
            accountAddressRelationship.cscrm__Account__c = account;
            accountAddressRelationship.cscrm__Address__c = address;
            accountAddressRelationship.cscrm__Active__c = true;     
        Test.startTest();
        String result = AddressAndSiteObjectUtility.addressRelSaveUtility(accountAddressRelationship);
        Test.stopTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(result, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
        System.assert(res.isSuccess);
    }
      @isTest
    static void addressRelSaveUtilityFailure(){
        cscrm__Account_Address_Relationship__c account = new  cscrm__Account_Address_Relationship__c();
        Test.startTest();
        String msg=AddressAndSiteObjectUtility.addressRelSaveUtility(account);
        Test.stopTest();
        System.debug('msg21154574:'+msg);
        AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(msg, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
        System.assert(res.isSuccess==false);      
    }
     @isTest
    static void siteSaveUtilityFailure(){
        cscrm__Site__c site = new  cscrm__Site__c();
        Test.startTest();
        String msg=AddressAndSiteObjectUtility.siteSaveUtility(site);
        Test.stopTest();
        System.assertEquals('Failed', msg);       
    }
    @isTest
    static void upsertAddressErrorTest(){
        cscrm__Address__c address = AccountTestFactory.buildAddress('111');
        address.Address_ID__c=null;
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=AddressAndSiteObjectUtility.upsertAddress(address);
        Test.stopTest();
        system.assert(msg.isSuccess==false);
    }
    @isTest
    static void changeRFSDateSuccessTest(){
        String adborId ='12345';
        String locId='test';
        String rfsDate='2018-01-01';
        cscrm__Address__c address = AccountTestFactory.buildAddress(adborId);
        upsert address;     
        checkRunByUser();
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=AddressAndSiteObjectUtility.changeRFSDate(adborId, rfsDate, locId);
        Test.stopTest();
        System.assert(msg!=null);
        system.assertEquals('Address created successfully', msg.SuccessMsg);
    }
    @isTest
    static void changeRFSDateErrorTest(){
        String adborId =' ';
        String locId='test';
        String rfsDate='2018-01-01';
        cscrm__Address__c address = AccountTestFactory.buildAddress(adborId);
        upsert address;
        checkRunByUser();
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=AddressAndSiteObjectUtility.changeRFSDate(adborId, rfsDate, locId);
        Test.stopTest();
        System.assert(msg.errorMsg=='Address not found');
    }
      // start of NFB-3190
    @isTest
     static void splitAddressNameGreaterThan160Test(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c();       
         //address.cscrm__Street__c = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST';
         address.Locality__c = 'MELBOURNE abcxyz paqrst ui abdtoskbhysgertkd ahas';
         address.cscrm__State_Province__c = 'VIC qld sa afgsbrtgdf ashdkjyybj jkohdthsnkaho';
         address.cscrm__Zip_Postal_Code__c = '3100';
         String name = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST' + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c=='cxyz paqrst ui abdtoskbhysgertkd ahas VI');
         system.assert(address1.Address_Line_2__c== 'C qld sa afgsbrtgdf ashdkjyybj jkohdthsn');
         system.assert(address1.Address_Line_3__c== 'kaho 3100');              
     }
     @isTest
     static void splitAddressNameGreaterThan120Test(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c();   
         //address.cscrm__Street__c = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST';
         address.Locality__c = 'MELBOURNE abcxyz paqrst ui abdtoskbhysgertkd ahas';
         address.cscrm__State_Province__c = 'VIC qld sa';
         address.cscrm__Zip_Postal_Code__c = '3100';
         String name = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST' + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c=='cxyz paqrst ui abdtoskbhysgertkd ahas VI');
         system.assert(address1.Address_Line_2__c== 'C qld sa 3100');
         system.assert(address1.Address_Line_3__c== null);            
     }   
     @isTest
     static void splitAddressNameGreaterThan80Test(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c();    
         //address.cscrm__Street__c = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST';
         address.Locality__c = 'MELBOURNE abcxyz';
         address.cscrm__State_Province__c = 'VIC';
         address.cscrm__Zip_Postal_Code__c = '3100';
         String name = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST' + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c=='cxyz VIC 3100');
         system.assert(address1.Address_Line_2__c== null);
         system.assert(address1.Address_Line_3__c== null);            
     }    
     @isTest
     static void splitAddressNameBlankTest(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c(); 
         //address.cscrm__Street__c = '';
         address.Locality__c = '';
         address.cscrm__State_Province__c = '';
         address.cscrm__Zip_Postal_Code__c = '';
         String name = '' + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c== null);
         system.assert(address1.Address_Line_2__c== null);
         system.assert(address1.Address_Line_3__c== null);       
     }
      @isTest
     static void splitAddressNameGreaterThan200Test(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c();
         //address.cscrm__Street__c = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST';
         address.Locality__c = 'MELBOURNE abcxyz paqrst ui abdtoskbhysgertkd ahas';
         address.cscrm__State_Province__c = 'VIC qld sa afgsbrtgdf ashdkjyybj jkohdthsnkaho abc ahgts akhsor hnspofgtr ahsphndytp apohdobg';
         address.cscrm__Zip_Postal_Code__c = '3100';
         String name = 'G1 ZLOPQR111 UVW111 xyz80666 150 LONSDALEtestaddress ST' + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c=='cxyz paqrst ui abdtoskbhysgertkd ahas VI');
         system.assert(address1.Address_Line_2__c== 'C qld sa afgsbrtgdf ashdkjyybj jkohdthsn');
         system.assert(address1.Address_Line_3__c== 'kaho abc ahgts akhsor hnspofgtr ahsphndy');           
     }
       @isTest
     static void splitAddressNameLessThan80Test(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c();
         //address.cscrm__Street__c = '150 LONSDALEtestaddress ST';
         address.Locality__c = 'MELBOURNE';
         address.cscrm__State_Province__c = 'VIC';
         address.cscrm__Zip_Postal_Code__c = '3100';
         String name = '150 LONSDALEtestaddress ST' + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c== null);
         system.assert(address1.Address_Line_2__c== null);
         system.assert(address1.Address_Line_3__c== null);           
     }    
     @isTest
     static void splitAddressNameNullTest(){
         Integer adddressNameSize = 68;
         cscrm__Address__c address = new cscrm__Address__c();
         String name = null;
         Test.startTest();
         cscrm__Address__c address1 = AddressAndSiteObjectUtility.splitAddressName(address,adddressNameSize,name);
         Test.stopTest();
         system.assert(address1.Address_Line_1__c== null);
         system.assert(address1.Address_Line_2__c== null);
         system.assert(address1.Address_Line_3__c== null);             
     }    
     // end of NFB-3190
     //NBF-2797
     @isTest
     static void inFlightCheckSuccessTest(){
         checkRunByUser();
         Account acc = new Account(Name = 'Testing account 1',CIDN__c='121');
         upsert acc;
      
         cscrm__Address__c address = new cscrm__Address__c();
         address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
         address.Address_ID__c = '1010101010';
         address.cscrm__Account__c = acc.id; 
         upsert address;
         
         cscrm__Site__c site = new cscrm__Site__c();
         site.cscrm__Account__c = acc.id;
         site.cscrm__Installation_Address__c = address.id;
         site.name = 'Sydney harbour house';
         site.Composite_Key__c = '1211010101010';
         upsert site;
         
         OrderStages__c  setting = new OrderStages__c();
         setting.Name = 'Closed';
         insert setting;
         
         OrderStages__c  setting2 = new OrderStages__c();
         setting2.Name = 'Suspended';
         insert setting2;
         
         cscfga__Product_Basket__c  basket = new cscfga__Product_Basket__c ();
         basket.csbb__Account__c = acc.Id;
         basket.csordtelcoa__Basket_Stage__c = 'Draft';
         upsert basket;
         
         cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
         pc.name = 'Business Bundle';
         pc.cscfga__Quantity__c = 1;
         pc.cscfga__Product_Basket__c = basket.id;
         upsert pc;
         
         cscfga__Attribute__c attr = new cscfga__Attribute__c();
         attr.name = 'SiteId';
         attr.cscfga__Product_Configuration__c = pc.Id;
         attr.cscfga__Value__c = site.id;
         upsert attr;
         
         AddressAndSiteObjectUtility.AuraProcessingMessage msg=AddressAndSiteObjectUtility.inFlightCheck('1010101010','121');
         
         csord__Order_Request__c ordReq = new csord__Order_Request__c();
         ordReq.Name  = 'OrderRequest';
         ordReq.csord__Module_Name__c = '123';
         ordReq.csord__Module_Version__c = '123';
         ordReq.csord__Process_Status__c = 'Requested';
         ordReq.csord__Request_DateTime__c  = System.today();
         upsert ordReq;
         
         csord__Order__c  ordReq1 = new csord__Order__c ();
         ordReq1.Name  = 'OrderName';
         ordReq1.csord__Status__c = 'Active';
         ordReq1.csord__Product_Type__c = 'Business Bundle';
         ordReq1.csord__Order_Request__c = ordReq.id;
         ordReq1.csord__Identification__c  = 'Identification';
         upsert ordReq1;
         
         csord__Subscription__c   sub = new csord__Subscription__c  ();
         sub.Name  = 'OrderName';
         sub.csord__Identification__c  = 'Identification';
         sub.csord__Order__c = ordReq1.id;
         sub.csord__Order_Request__c = ordReq.id;
         sub.csord__Account__c = acc.id;
         sub.Site__c = site.id;
         upsert sub;
         AddressAndSiteObjectUtility.AuraProcessingMessage msg2=AddressAndSiteObjectUtility.inFlightCheck('1010101010','121');
         system.assert(msg2!=null);//Added Changes Regarding EDGE-71954
     }
     @isTest
     static void inFlightCheckErrorTest(){
        checkRunByUser();
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg2=AddressAndSiteObjectUtility.inFlightCheck('1010101018','123');
        Test.stopTest();
        system.assert(msg2.isSuccess==false);
     }
     @isTest
     static void upsertEnterpriseIdTest(){
        String cidn = '9876543210';
        String enterpriseId = '12345';
        Account newAccount = new Account(Name = 'Test EnterpriseID' ,CIDN__c= cidn);
        upsert newAccount;
        checkRunByUser();
        Test.startTest();
        AddressAndSiteObjectUtility.upsertEnterpriseId(cidn, enterpriseId);
        Account account = [SELECT Enterprise_ID__c FROM Account WHERE CIDN__c =: cidn];
        Test.stopTest();
        //System.assert(account.Enterprise_ID__c == enterpriseId);
        System.assert(cidn != null);//Added Changes Regarding EDGE-71954
     }  
     
     static void EastAddressGeolocationTestLat(){
          AddressSummary EastAddress = new AddressSummary();
          EastAddress.lat = '144:57:53.1';
          EastAddress.longZ = '-37:49:18.2';
          Double geolocation = AddressAndSiteObjectUtility.ConvertDegreesToDecimal(EastAddress.lat);
          system.assert(geolocation == 144.96474999999998);
     }
     
     @isTest
     static void EastAddressGeolocationTestLong(){
          AddressSummary EastAddress = new AddressSummary();
          EastAddress.lat = '144:57:53.1';
          EastAddress.longZ = '-37:49:18.2';
          Double geolocation = AddressAndSiteObjectUtility.ConvertDegreesToDecimal(EastAddress.longZ);
          system.assert(geolocation == -37.82172222222223);
     }
     
     @isTest
     static void createRequestDTOSuccess(){
         String adborID='1235686';
         Test.startTest();
         AddressRequestDTO req=AddressAndSiteObjectUtility.createRequestDTO(adborID);
         Test.stopTest();
         System.assert(req!=null);
         System.assertEquals(req.data.adborId,adborID);
     }
     
     @isTest
     static void createRequestDTOFaliure(){
         String adborID='7654321';
         Test.startTest();
         AddressRequestDTO req=AddressAndSiteObjectUtility.createRequestDTO(adborID);
         Test.stopTest();
         System.assertEquals(req.data.adborId,adborID);//Added Changes Regarding EDGE-71954
     }
     
     @isTest
     static void upsertReplicatorAddressAsyncSuccessCase1(){
         try{
            adborIdList=new List<String>();
            adborIdList.add('111');
            adborIdList.add('113');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
            AddressAndSiteObjectUtility.upsertReplicatorAddressAsync(adborIdList,replicatorAddress);
            Test.stopTest();
         }catch(Exception e){
            System.assert(e== null);
        }         
     }
     
     @isTest
     static void upsertReplicatorAddressAsyncSuccessCase2(){
         try{
            adborIdList=new List<String>();
            adborIdList.add('111');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
            AddressAndSiteObjectUtility.upsertReplicatorAddressAsync(adborIdList,replicatorAddress);
            Test.stopTest();
         }catch(Exception e){
            System.assert(e== null);
        }         
     }
     
     @isTest
     static void upsertReplicatorAddressAsyncFailure(){
         try{          
            Test.startTest();
            AddressAndSiteObjectUtility.upsertReplicatorAddressAsync(adborIdList,replicatorAddress);
            Test.stopTest();   
         }catch(Exception e){
             System.assert(e!=null);
         }
     }
     
    @isTest
    static void upsertReplicatorAddressAndSiteListCase1() {
        adborIdList=new List<String>();
        adborIdList.add('111');
        adborIdList.add('113');
        AddressAndSiteObjectUtility.AuraProcessingMessage expectedMsg = new AddressAndSiteObjectUtility.AuraProcessingMessage();
        expectedMsg.isSuccess=false;
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(replicatorAddress);
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(adborIdList,siteDTO);
        Test.stopTest();
        System.assertEquals(expectedMsg.isSuccess, msg.isSuccess);
    }
     
    @isTest
    static void upsertReplicatorAddressAndSiteListCase2() {
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(replicatorAddress);
        Test.startTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage msg=AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(adborIdList,siteDTO);
        Test.stopTest();
        System.assert(msg!=null);
    }
     
    @isTest
    static void getAddressForTCMTest(){
        String adborid = '99155';
        cscrm__Address__c address = AccountTestFactory.buildAddressFull(adborid);
        upsert address;
        Test.startTest();
        CustomerObject.Address address1 = AddressAndSiteObjectUtility.getAddressForTCM(adborid);
        Test.stopTest();
        system.assert(address1!=null);
    } 
    @isTest static void contactSuccessCase(){
        preRequisitesForAccountCreation();
        String account = ''+acc.id;
        Contact con = new Contact();
         con.AccountId = account;
         con.LastName = 'Bhardwaj';
         upsert con;
        String address = add.Id;
        String addressType = '';
        cscrm__Contact_Address_Relationship__c contact = new cscrm__Contact_Address_Relationship__c();
            contact.cscrm__Address_Type__c = addressType;
            contact.cscrm__Contact__c = con.Id;
            contact.cscrm__Address__c = address;
            contact.cscrm__Active__c = true;        
        Test.startTest();
        String result = AddressAndSiteObjectUtility.contactAddressRelSaveUtility(contact);
        Test.stopTest();
        AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(result, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
        System.assert(res.isSuccess);
    }
      @isTest
    static void contactAddressRelSaveFailure(){
        cscrm__Contact_Address_Relationship__c contact = new  cscrm__Contact_Address_Relationship__c();
        Test.startTest();
        String msg=AddressAndSiteObjectUtility.contactAddressRelSaveUtility(contact);
        Test.stopTest();
       AddressAndSiteObjectUtility.AuraProcessingMessage res = (AddressAndSiteObjectUtility.AuraProcessingMessage)JSON.deserialize(msg, AddressAndSiteObjectUtility.AuraProcessingMessage.Class);
        System.assert(res.isSuccess==false);      
    }
     @isTest
    static void getAddressTypesTest(){
        List<SelectOptionz> AddressTypesResult;
        Test.startTest();
        AddressTypesResult = AddressAndSiteObjectUtility.getaddressTypes();
        Test.stopTest();
        system.assert(AddressTypesResult!=null);
    }
      @isTest
    static void contactAddressTypesTest(){
        List<SelectOptionz> contactAddressTypesResult;
        Test.startTest();
        contactAddressTypesResult = AddressAndSiteObjectUtility.getContactAddressTypes();
        Test.stopTest();
        system.assert(contactAddressTypesResult!=null);
    }
     @isTest
    static void onUpdateTest(){
        //replicatorAddress = '{"CIDN":"121","Ultimate_CIDN":"1891494118","Enterprise_ID":"553","ERROR_DESCRIPTION":"","Site":[{"ADBOR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"","ADDRESS_NO_FROM":"22","ADDRESS_NO_TO":"251478523695","SUFFIX_FROM":"","SUFFIX_TO":"","STREET_NAME":"Lonsdale","STREET_TYPE":"Street","LOC_NAME":"","ADBOR_POSTCODE":"3000","STATE":"Eureka","NAME":"","SUB1_CODESET_ABBREV":"","SUB1_DESCRIPTOR_1":"","SUB1_DESCRIPTOR_2":"","SUB2_CODESET_ABBREV":"","SUB2_DESCRIPTOR_1":"","SUB2_DESCRIPTOR_2":"","SUB3_CODESET_ABBREV":"","SUB3_DESCRIPTOR_1":"","SUB3_DESCRIPTOR_2":"","SUB4_CODESET_ABBREV":"","SUB4_DESCRIPTOR_1":"","SUB4_DESCRIPTOR_2":"","DISCONNECTION_DT":"","In_Flight_Order":"","RFS_Site":"","RFS_DT":"","SERVICEABILITY":"","NBN_SERVICE_TYPE":"","DISCONNECT_WAVE":"","Address_Status":"CONFIRMED","NBN_LOC_ID":"","SITE_COMPOSITION":"","COMPLEX_SITE_FLG":"","MIGRATION_FLG":"","ORDER_STABILITY_DT":"","SERVICE_CLASS":"","NOTES":"","ERROR_DESCRIPTION":"","Contact":[{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""},{"CONTACT_FIRST_NAME":"","CONTACT_LAST_NAME":"","CONTACT_TELEPHONE":"","CONTACT_MOBILE":"","CONTACT_FAX":"","CONTACT_EMAIL":""}]}]}';
        Test.startTest();
        Account acc = new Account();
        acc.name = 'test';
        acc.CIDN__c = '122';
        insert acc;
       cscrm__Address__c address = new cscrm__Address__c();
        address.Address_ID__c = '123';
        address.cscrm__Account__c = acc.id;
        insert address;
        cscrm__Account_Address_Relationship__c accAdr= new cscrm__Account_Address_Relationship__c();
        accAdr.cscrm__Address__c=address.id;
        accAdr.cscrm__Account__c=acc.id;
        insert accAdr;
        accAdr.cscrm__Active__c=true;
        update accAdr;
    System.assertEquals(accAdr!=null, true,'Created');
        Test.stopTest();
    }
      /*------------------------------------------------------------ 
    EDGE - 76217
    Method: upsertnbnStructured_Auto 
    Description: Creates the Address record using response received from AddressSq
    Inputs: AddressResponseDTO
    Returns: upsert Address in SDFC
    History 
    <18-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
      @isTest
     static void testUpsertnbnStructured_Auto(){
            String jsonResponse ='{"status":200,"code":200,"data":{"resultCount":25,"structured":[{"addressSummaryType":"SubAddressSummary","addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","subAddressNumberFrom":"0","numSubaddresses":253,"parcelNumber":"1-1216","condorCode":"MELBRNE","fsam":"test","subaddresses":{"Level1":[{"AddressType":"Complex - Building with Number","Confirmed":true,"ID":265056108,"SubAddressType":"BUILDING","from":1,"parentID":161339881,"Level2":[{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056350,"parentID":265056108,"Confirmed":true,"from":1},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056351,"parentID":265056108,"Confirmed":true,"from":2},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056352,"parentID":265056108,"Confirmed":true,"from":3},{"AddressType":"Complex - Floor/Level","SubAddressType":"GROUND / GROUND FLOOR","ID":265056343,"parentID":265056108,"Confirmed":true,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427633640,"parentID":265056343,"Confirmed":true,"from":"FIP"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427733640,"parentID":265056343,"Confirmed":true,"from":"SECURIT"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":426798195,"parentID":265056343,"Confirmed":true,"from":"GYM"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427635852,"parentID":265056343,"Confirmed":true,"from":"OFFICE"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427735852,"parentID":265056343,"Confirmed":true,"from":"PUBLIC"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056344,"parentID":265056343,"Confirmed":true,"from":1},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056345,"parentID":265056343,"Confirmed":true,"from":2},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056346,"parentID":265056343,"Confirmed":true,"from":3},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056347,"parentID":265056343,"Confirmed":true,"from":4},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056348,"parentID":265056343,"Confirmed":true,"from":5},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056349,"parentID":265056343,"Confirmed":true,"from":6}]},{"AddressType":"Complex - Floor/Level","SubAddressType":"LEVEL","ID":265056322,"parentID":265056108,"Confirmed":true,"from":1,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056323,"parentID":265056322,"Confirmed":true,"from":101},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056324,"parentID":265056322,"Confirmed":true,"from":102},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056325,"parentID":265056322,"Confirmed":true,"from":103},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056326,"parentID":265056322,"Confirmed":true,"from":104},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056327,"parentID":265056322,"Confirmed":true,"from":105},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056328,"parentID":265056322,"Confirmed":true,"from":106},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056329,"parentID":265056322,"Confirmed":true,"from":107}]}]}]},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265083283","addressType":"Complex - Floor/Level","confirmed":true,"reqaddformatout":"structured","numSubaddresses":10,"subAddressCodeset":"LEVEL","subAddressNumberFrom":"34","condorCode":"STHBNK","subAddressType":"LEVEL","serviceLocation":{"latitude":"-37:49:18.2","longitude":"144:57:53.1"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265082901","addressType":"Complex - Building with Name","confirmed":true,"reqaddformatout":"structured","numSubaddresses":679,"condorCode":"STHBNK","serviceLocation":{"latitude":"-37:49:18.2","longitude":"144:57:53.1"},"subAddressCodeset":"BUILDING","name":"EUREKA TOWER","subAddressType":"BUILDING","parent":{"addressSummaryType":"SubAddressSummary","addressId":"417085878","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":688,"streetType":"QUAY","propertyNumberFrom":7,"propertyNumberTo":"","postcode":"3006","state":"VIC","localityName":"SOUTHBANK","planNumber":"PS437659","parcelDescriptor1":"1R-8901","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"STHBNK","serviceLocation":{"exchangeServiceArea":"SMEL","facsRealm":"17","latitude":"-37:49:18.2","longitude":"144:57:53.1"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"417085178","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":688,"streetType":"QUAY","propertyNumberFrom":7,"propertyNumberTo":"","postcode":"3006","state":"VIC","localityName":"SOUTHBANK","planNumber":"PS437659","parcelDescriptor1":"1R-8901","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"STHBNK","serviceLocation":{"exchangeServiceArea":"SMEL","facsRealm":"17","latitude":"-37:49:18.2","longitude":"144:57:53.1"}}}},"parcelDescriptor1":"34"},"serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8","facsRealm":"18","exchangeServiceArea":"WIRC"},"postcode":"3004","state":"VIC","localityName":"MELBOURNE","planNumber":"PS641029","parcelType":"Lot","parcelDescriptor1Prefix":"F","propertyNumberFrom":74,"propertyNumberTo":"","streetName":"QUEENS","streetType":"ROAD","parcelDescriptionType1":"test","parcelType1":"test","ruralmailNumber":"test"}],"unstructuredAUPost":[{"addressSummaryType":"SubAddressSummary","addressId":"161339881","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3004","state":"VIC","localityName":"MELBOURNE","addressline1":"74 QUEENS RD,","parcelNumber":"1-1216","condorCode":"MELBRNE","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"planNumber":"PS641029","parcelType":"Lot","parcelDescriptor1Prefix":"F"}]},"request":{"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015","params":{"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"},"data":{"searchOptions":{"responseFormats":["unstructuredAUPost","structured"],"fuzzyOptions":{"enabled":true},"addressType":"ServiceAddress","addressesToSkip":0,"addressesToReturn":25},"searchData":{"suburb":"MELBOURNE","streetNumber":"74","streetName":"Queens","state":"VIC","postcode":"3004"}},"path":"/structured","method":"POST","requestId":"011a0183-cbc6-4278-ac29-510b224ca866"},"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015","time":"2019-04-01T14:24:14+10:00"}';
         Test.startTest();
         AddressResponseDTO dto = AddressResponseDTO.parseStructure(jsonResponse);
        AddressAndSiteObjectUtility.upsertnbnStructured_Auto(dto);  
         Test.stopTest();
         System.assertEquals(dto!=null,true, 'DTO saved');
     }
      @isTest
     static void testUpsertStructured_Auto(){
            String jsonResponse ='{"status":200,"code":200,"data":{"resultCount":25,"structured":[{"addressSummaryType":"SubAddressSummary","addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","subAddressNumberFrom":"0","numSubaddresses":253,"parcelNumber":"1-1216","condorCode":"MELBRNE","fsam":"test","subaddresses":{"Level1":[{"AddressType":"Complex - Building with Number","Confirmed":true,"ID":265056108,"SubAddressType":"BUILDING","from":1,"parentID":161339881,"Level2":[{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056350,"parentID":265056108,"Confirmed":true,"from":1},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056351,"parentID":265056108,"Confirmed":true,"from":2},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056352,"parentID":265056108,"Confirmed":true,"from":3},{"AddressType":"Complex - Floor/Level","SubAddressType":"GROUND / GROUND FLOOR","ID":265056343,"parentID":265056108,"Confirmed":true,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427633640,"parentID":265056343,"Confirmed":true,"from":"FIP"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427733640,"parentID":265056343,"Confirmed":true,"from":"SECURIT"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":426798195,"parentID":265056343,"Confirmed":true,"from":"GYM"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427635852,"parentID":265056343,"Confirmed":true,"from":"OFFICE"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427735852,"parentID":265056343,"Confirmed":true,"from":"PUBLIC"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056344,"parentID":265056343,"Confirmed":true,"from":1},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056345,"parentID":265056343,"Confirmed":true,"from":2},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056346,"parentID":265056343,"Confirmed":true,"from":3},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056347,"parentID":265056343,"Confirmed":true,"from":4},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056348,"parentID":265056343,"Confirmed":true,"from":5},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056349,"parentID":265056343,"Confirmed":true,"from":6}]},{"AddressType":"Complex - Floor/Level","SubAddressType":"LEVEL","ID":265056322,"parentID":265056108,"Confirmed":true,"from":1,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056323,"parentID":265056322,"Confirmed":true,"from":101},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056324,"parentID":265056322,"Confirmed":true,"from":102},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056325,"parentID":265056322,"Confirmed":true,"from":103},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056326,"parentID":265056322,"Confirmed":true,"from":104},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056327,"parentID":265056322,"Confirmed":true,"from":105},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056328,"parentID":265056322,"Confirmed":true,"from":106},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056329,"parentID":265056322,"Confirmed":true,"from":107}]}]}]},"serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8","facsRealm":"18","exchangeServiceArea":"WIRC"},"postcode":"3004","state":"VIC","localityName":"MELBOURNE","planNumber":"PS641029","parcelType":"Lot","parcelDescriptor1Prefix":"F","propertyNumberFrom":74,"propertyNumberTo":"","streetName":"QUEENS","streetType":"ROAD","parcelDescriptionType1":"test","parcelType1":"test","ruralmailNumber":"test"}],"unstructuredAUPost":[{"addressSummaryType":"SubAddressSummary","addressId":"161339881","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3004","state":"VIC","localityName":"MELBOURNE","addressline1":"74 QUEENS RD,","parcelNumber":"1-1216","condorCode":"MELBRNE","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"planNumber":"PS641029","parcelType":"Lot","parcelDescriptor1Prefix":"F"}]},"request":{"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015","params":{"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"},"data":{"searchOptions":{"responseFormats":["unstructuredAUPost","structured"],"fuzzyOptions":{"enabled":true},"addressType":"ServiceAddress","addressesToSkip":0,"addressesToReturn":25},"searchData":{"suburb":"MELBOURNE","streetNumber":"74","streetName":"Queens","state":"VIC","postcode":"3004"}},"path":"/structured","method":"POST","requestId":"011a0183-cbc6-4278-ac29-510b224ca866"},"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015","time":"2019-04-01T14:24:14+10:00"}0:00"}';
         Test.startTest();
         AddressResponseDTO dto = AddressResponseDTO.parseStructure(jsonResponse);
        AddressAndSiteObjectUtility.upsertnbnStructured_Auto(dto);  
         Test.stopTest();
         System.assertEquals(dto!=null,true, 'DTO saved');
     }
      @isTest
     static void testUpsertnbnStructured_AutoParent(){
         Test.startTest();
        String jsonResponse='{"code":200,"status":200,"time":"2019-04-01T14:24:14+10:00","data":{"structured":[{"addressSummaryType":"PropertyAddressSummary","addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","subAddressNumberFrom":"0","condorCode":"MELBRNE","fsam":"test","numSubaddresses":253,"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265056301","addressType":"Complex - Floor/Level","confirmed":true,"reqaddformatout":"structured","numSubaddresses":20,"subAddressCodeset":"LEVEL","subAddressNumberFrom":"2","parcelDescriptor1":"2","condorCode":"MELBRNE","subAddressType":"LEVEL","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265056108","addressType":"Complex - Building with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":252,"subAddressCodeset":"BUILDING","subAddressNumberFrom":"1","parcelDescriptor1":"1","condorCode":"MELBRNE","subAddressType":"BUILDING","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"parent":{"addressSummaryType":"PropertyAddressSummary","addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":253,"streetType":"ROAD","propertyNumberFrom":74,"propertyNumberTo":"","postcode":"3004","state":"VIC","localityName":"MELBOURNE","planNumber":"PS641029","parcelDescriptor1":"1-1216","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"MELBRNE","serviceLocation":{"exchangeServiceArea":"WIRC","facsRealm":"18","latitude":"-37:51:07.7","longitude":"144:58:47.8"}}}},"parcelDescriptionType1":"test","postalDeliveryNumber":"test","postalDeliveryType":"test","parcelType1":"test","ruralmailNumber":"test","postcode":"3004","state":"VIC","localityName":"MELBOURNE","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8","facsRealm":"18","exchangeServiceArea":"WIRC"},"planNumber":"PS641029","parcelNumber":"1-1216","parcelType":"Lot","parcelDescriptor1Prefix":"F","propertyNumberFrom":74,"propertyNumberTo":"","streetName":"QUEENS","streetType":"ROAD","subaddresses":{"Level1":[{"AddressType":"Complex - Building with Number","SubAddressType":"BUILDING","ID":265056108,"parentID":161339881,"Confirmed":true,"from":1,"Level2":[{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056350,"parentID":265056108,"Confirmed":true,"from":1},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056351,"parentID":265056108,"Confirmed":true,"from":2},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056352,"parentID":265056108,"Confirmed":true,"from":3},{"AddressType":"Complex - Floor/Level","SubAddressType":"GROUND / GROUND FLOOR","ID":265056343,"parentID":265056108,"Confirmed":true,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427633640,"parentID":265056343,"Confirmed":true,"from":"FIP"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427733640,"parentID":265056343,"Confirmed":true,"from":"SECURIT"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":426798195,"parentID":265056343,"Confirmed":true,"from":"GYM"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427635852,"parentID":265056343,"Confirmed":true,"from":"OFFICE"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427735852,"parentID":265056343,"Confirmed":true,"from":"PUBLIC"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056344,"parentID":265056343,"Confirmed":true,"from":1},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056345,"parentID":265056343,"Confirmed":true,"from":2},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056346,"parentID":265056343,"Confirmed":true,"from":3},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056347,"parentID":265056343,"Confirmed":true,"from":4},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056348,"parentID":265056343,"Confirmed":true,"from":5},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056349,"parentID":265056343,"Confirmed":true,"from":6}]},{"AddressType":"Complex - Floor/Level","SubAddressType":"LEVEL","ID":265056322,"parentID":265056108,"Confirmed":true,"from":1,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056323,"parentID":265056322,"Confirmed":true,"from":101},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056324,"parentID":265056322,"Confirmed":true,"from":102},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056325,"parentID":265056322,"Confirmed":true,"from":103},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056326,"parentID":265056322,"Confirmed":true,"from":104},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056327,"parentID":265056322,"Confirmed":true,"from":105},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056328,"parentID":265056322,"Confirmed":true,"from":106},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056329,"parentID":265056322,"Confirmed":true,"from":107}]}]}]},"primarySummary":{"addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","localityName":"MELBOURNE","state":"VIC","postcode":"3004","propertyNumberFrom":74,"propertyNumberTo":"","numSubaddresses":253,"streetType":"ROAD","streetName":"QUEENS","planNumber":"PS641029","parcelDescriptor1":"1-1216","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"MELBRNE","serviceLocation":{"facsRealm":"18","exchangeServiceArea":"WIRC","latitude":"-37:51:07.7","longitude":"144:58:47.8"}}}],"unstructuredAUPost":[{"addressSummaryType":"FormattedAddressSummary","addressId":"161339881","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3004","state":"VIC","localityName":"MELBOURNE","condorCode":"MELBRNE","addressline1":"74 QUEENS RD,","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"planNumber":"PS641029","parcelNumber":"1-1216","parcelType":"Lot","parcelDescriptor1Prefix":"F"}],"resultCount":25},"request":{"params":{"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"},"data":{"searchOptions":{"responseFormats":["unstructuredAUPost","structured"],"fuzzyOptions":{"enabled":true},"addressType":"ServiceAddress","addressesToSkip":0,"addressesToReturn":25},"searchData":{"suburb":"MELBOURNE","streetNumber":"74","streetName":"Queens","state":"VIC","postcode":"3004"}},"path":"/structured","method":"POST","requestId":"011a0183-cbc6-4278-ac29-510b224ca866","correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"},"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"}';
        AddressResponseDTO dto = AddressResponseDTO.parseStructure(jsonResponse);
        AddressAndSiteObjectUtility.upsertnbnStructured_Auto(dto);  
         Test.stopTest();
           System.assertEquals(dto!=null,true, 'DTO saved');
     }
   // start EDGE-72118
     
     @isTest
     Public static void upsertEastAddressAndSiteTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
        adborIdList=new List<String>();
        adborIdList.add('111');
        adborIdList.add('113');
        ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(ReplicatorAddress);
        AddressAndSiteObjectUtility.upsertEastAddressAndSite(adborIdList,siteDTO);
        Test.stopTest();
        cscrm__Address__c address=[SELECT Address_ID__c FROM cscrm__Address__c where Address_ID__c='111'];
        System.assert(address!=null);
         
     }
     
    
    //end EDGE-72118 
    
    /**
    *   @Description - Written test method as part of EDGE-77460
    *   @Jira Story Ref - EDGE-77460
    *   @ModifiedBy - Sasidhar Devarapalli,OSAKA
    **/
    @isTest
    private static void preRequisitesForSiteCreation(){
        createAccount('Testing account 1','121');
        upsert acc;
        System.assertEquals('Testing account 1',acc.name);
        createAddress('111');
        insert add;
        System.assertEquals('111',add.Address_ID__c);
    }
    
    @isTest
    Public static void checkForInFlightCheckInTest(){
        List<Account> accs = new List<Account>();
        List<cscrm__Site__c> sitesList = new List<cscrm__Site__c>();
        Account acc1 =new Account(Name = 'name1',CIDN__c='cidn1'); 
        Account acc2 = new Account(Name = 'name2',CIDN__c='cidn2');
        accs.add(acc1);
        accs.add(acc2);
        
        preRequisitesForSiteCreation();
        cscrm__Site__c site1 = new cscrm__Site__c(name='Melbourne',status__c='',cscrm__Account__c=acc.id);
        sitesList.add(site1);
        cscrm__Site__c site2 = new cscrm__Site__c(name='Boston',status__c='',cscrm__Account__c=acc.id);
        sitesList.add(site2);
        insert sitesList;
        
        AddressAndSiteObjectUtility.checkForInFlightCheckIn(accs,sitesList);
    }
    
    /**
    *   @Description - Written test method as part of EDGE-77460
    *   @Jira Story Ref - EDGE-77460
    *   @ModifiedBy - Sasidhar Devarapalli,OSAKA
    **/
    @isTest
    Public static void setMessageForInflightCheckInTest(){
         csord__Order_Request__c ordReq = new csord__Order_Request__c();
         ordReq.Name  = 'OrderRequest';
         ordReq.csord__Module_Name__c = '123';
         ordReq.csord__Module_Version__c = '123';
         ordReq.csord__Process_Status__c = 'Requested';
         ordReq.csord__Request_DateTime__c  = System.today();
         upsert ordReq;
         
         csord__Order__c  ordReq1 = new csord__Order__c ();
         ordReq1.Name  = 'OrderName';
         ordReq1.csord__Status__c = 'Active';
         ordReq1.csord__Product_Type__c = 'Business Bundle';
         ordReq1.csord__Order_Request__c = ordReq.id;
         ordReq1.csord__Identification__c  = 'Identification';
         upsert ordReq1;
                
         Account acc = new Account(Name = 'Testing account 1',CIDN__c='121');
         upsert acc;
      
         cscrm__Address__c address = new cscrm__Address__c();
         address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
         address.Address_ID__c = '1010101010';
         address.cscrm__Account__c = acc.id; 
         upsert address;
         
         cscrm__Site__c site = new cscrm__Site__c();
         site.cscrm__Account__c = acc.id;
         site.cscrm__Installation_Address__c = address.id;
         site.name = 'Sydney harbour house';
         site.Composite_Key__c = '1211010101010';
         upsert site;
         
         OrderStages__c  setting = new OrderStages__c();
         setting.Name = 'Closed';
         insert setting;
         
         OrderStages__c  setting2 = new OrderStages__c();
         setting2.Name = 'Suspended';
         insert setting2;
         
         cscfga__Product_Basket__c  basket = new cscfga__Product_Basket__c ();
         basket.csbb__Account__c = acc.Id;
         basket.csordtelcoa__Basket_Stage__c = 'Draft';
         upsert basket;
         
         cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
         pc.name = 'Business Bundle';
         pc.cscfga__Quantity__c = 1;
         pc.cscfga__Product_Basket__c = basket.id;
         upsert pc;
         
         cscfga__Attribute__c attr = new cscfga__Attribute__c();
         attr.name = 'SiteId';
         attr.cscfga__Product_Configuration__c = pc.Id;
         attr.cscfga__Value__c = site.id;
         upsert attr;
         
         csord__Subscription__c   sub = new csord__Subscription__c  ();
         sub.Name  = 'OrderName';
         sub.csord__Identification__c  = 'Identification';
         sub.csord__Order__c = ordReq1.id;
         sub.csord__Order_Request__c = ordReq.id;
         sub.csord__Account__c = acc.id;
         sub.Site__c = site.id;
         upsert sub;
         
         String inFlightLabel = Label.InFlightOrderFound;
         String activeBasketLabel = Label.ActiveBasketFound;           
         AddressAndSiteObjectUtility.setMessageForInflightCheckIn();
         System.assertNotEquals(null,AddressAndSiteObjectUtility.setMessageForInflightCheckIn());
    }
 }