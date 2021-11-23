/**
*  Description of the purpose of the method.
*  @name PRM_MACDPORCtrlTest
*  @description               : Test Class for PRM_MACDPORCtrl
*  ** Change Log **
* Sl. No.   Developer Name      Date            Story           Description
* 1.        Pooja               18/05/2021      EDGE-202803     UI Domain View - Multi POR in TPC view # 1
**/
@isTest
public class PRM_MACDPORCtrlTest {
    public static final String MODIFICATION_IN_PROGRESS_STRING = 'Modification in progress';
    @testSetup public static void setup() {
        
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia')])
            profilesMap.put(profile.Name, profile);
        
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName in ('Sales_Ops','CEO')])
            rolesMap.put(role.DeveloperName, role);
        
        User[] uSysAdmin = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        insert uSysAdmin;
        
        System.runAs(uSysAdmin[0]){  
            
            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            
            Contact con = new Contact(LastName ='testCon', FirstName='testCon', AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert con; 
            
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,new List<Contact>{con} ,false);
            insert partnerUser;
            
            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
            
            insert customerContacts;
            
            for(Contact  customCon : customerContacts){
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
            update customerContacts;
            
            Partner_of_Record__c testPORRecord = PORDomainTriggerHandlerTest.createPOR(customerAccount.get(0).Id,customerContacts.get(0).Id,acc[0].Id,con.Id,'Active');
            testPORRecord.Agreement_Duration__c ='12';
            Database.insert(testPORRecord);
            
            List<Partner_of_Record_Domain__c> domainList = new List<Partner_of_Record_Domain__c>();
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = testPORRecord.Id,Status__c='Customer Review',Domain_Name__c='Mobile'));
            Database.insert(domainList);
            
            //Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
            //                                                   Partner__c=acc[0].Id,Partner_Signatories__c= con.Id,Status__c='Active'); 
            //insert POR;

            //Start: EDGE-202803
            String mobile                                   =   'Mobile';
            String adaptiveMobility                         =   'Adaptive Mobility';
            String dataAndIP                                =   'Data & IP';
            String sdWAN                                    =   'SD-WAN';
            String networkAppAndServices                    =   'Network Applications and Services';
            String telstraCollaboration                     =   'Telstra Collaboration';
            List<cscfga__Product_Category__c> prodCatList   =   new List<cscfga__Product_Category__c>();
            cscfga__Product_Category__c prodCatgryAMCare    =   new cscfga__Product_Category__c();
            prodCatgryAMCare.Name                           =   'Adaptive Mobility Care';
            prodCatgryAMCare.Product_Family_Level_1__c      =   mobile;
            prodCatgryAMCare.Product_Family_Level_2__c      =   adaptiveMobility;
            prodCatList.add(prodCatgryAMCare);
            cscfga__Product_Category__c prodCatgryAMDevice  =   new cscfga__Product_Category__c();
            prodCatgryAMDevice.Name                         =   'Adaptive Mobility Device';
            prodCatgryAMDevice.Product_Family_Level_1__c    =   mobile;
            prodCatgryAMDevice.Product_Family_Level_2__c    =   adaptiveMobility;
            prodCatList.add(prodCatgryAMDevice);
            cscfga__Product_Category__c prodCatgrySDWAN     =   new cscfga__Product_Category__c();
            prodCatgrySDWAN.Name                            =   'SD-WAN Adapt S1';
            prodCatgrySDWAN.Product_Family_Level_1__c       =   dataAndIP;
            prodCatgrySDWAN.Product_Family_Level_2__c       =   sdWAN;
            prodCatList.add(prodCatgrySDWAN);
            cscfga__Product_Category__c prodCatgrySecEdge   =   new cscfga__Product_Category__c();
            prodCatgrySecEdge.Name                          =   'SecureEdge';
            prodCatgrySecEdge.Product_Family_Level_1__c     =   dataAndIP;
            prodCatgrySecEdge.Product_Family_Level_2__c     =   sdWAN;
            prodCatList.add(prodCatgrySecEdge);
            cscfga__Product_Category__c prodCatgryTC        =   new cscfga__Product_Category__c();
            prodCatgryTC.Name                               =   telstraCollaboration;
            prodCatgryTC.Product_Family_Level_1__c          =   networkAppAndServices;
            prodCatgryTC.Product_Family_Level_2__c          =   telstraCollaboration;
            prodCatList.add(prodCatgryTC);
            cscfga__Product_Category__c prodCatgryTCProfs   =   new cscfga__Product_Category__c();
            prodCatgryTCProfs.Name                          =   'Telstra Collaboration Professional Service';
            prodCatgryTCProfs.Product_Family_Level_1__c     =   networkAppAndServices;
            prodCatgryTCProfs.Product_Family_Level_2__c     =   networkAppAndServices;
            prodCatList.add(prodCatgryTCProfs);
            insert prodCatList;
            List<Marketable_Offer__c> marketOfferList       =   new List<Marketable_Offer__c>();
            Marketable_Offer__c moAMCare                    =   new Marketable_Offer__c();
            moAMCare.OfferDefinationName__c                 =   'NextGenAdaptiveCareService';
            moAMCare.Name                                   =   'Adaptive Mobility Care';
            moAMCare.Offer_ID__c                            =   'DMCAT_Offer_001251';
            moAMCare.Product_Category__c                    =   prodCatgryAMCare.Id;
            marketOfferList.add(moAMCare);
            Marketable_Offer__c moAMDevAcc                  =   new Marketable_Offer__c();
            moAMDevAcc.OfferDefinationName__c               =   'Next Generation Enterprise Mobility';
            moAMDevAcc.Name                                 =   'Standalone Devices and Accessories';
            moAMDevAcc.Offer_ID__c                          =   'DMCAT_Offer_001231';
            moAMDevAcc.Product_Category__c                  =   prodCatgryAMDevice.Id;
            marketOfferList.add(moAMDevAcc);
            Marketable_Offer__c moSDWAN                     =   new Marketable_Offer__c();
            moSDWAN.OfferDefinationName__c                  =   'SD-WAN Adapt S1';
            moSDWAN.Name                                    =   'SD-WAN Adapt S1';
            moSDWAN.Offer_ID__c                             =   'DMCAT_Offer_001343';
            moSDWAN.Product_Category__c                     =   prodCatgrySDWAN.Id;
            marketOfferList.add(moSDWAN);
            Marketable_Offer__c moSecureEdge                =   new Marketable_Offer__c();
            moSecureEdge.OfferDefinationName__c             =   'SecureEdge';
            moSecureEdge.Name                               =   'SecureEdge';
            moSecureEdge.Offer_ID__c                        =   'DMCAT_Offer_001367';
            moSecureEdge.Product_Category__c                =   prodCatgrySecEdge.Id;
            marketOfferList.add(moSecureEdge);
            Marketable_Offer__c moTC                        =   new Marketable_Offer__c();
            moTC.OfferDefinationName__c                     =   'Telstra Collaboration Solution';
            moTC.Name                                       =   'Telstra Collaboration';
            moTC.Offer_ID__c                                =   'DMCAT_Offer_000618';
            moTC.Product_Category__c                        =   prodCatgryTC.Id;
            marketOfferList.add(moTC);
            Marketable_Offer__c moTCProfServ                =   new Marketable_Offer__c();
            moTCProfServ.OfferDefinationName__c             =   'Telstra Collaboration Professional Services Solution';
            moTCProfServ.Name                               =   'Telstra Collaboration Professional Services';
            moTCProfServ.Offer_ID__c                        =   'DMCAT_Offer_000936';
            moTCProfServ.Product_Category__c                =   prodCatgryTCProfs.Id;
            marketOfferList.add(moTCProfServ);
            insert marketOfferList;
            //End: EDGE-202803       
        }
        
    }
    @IsTest
    static void createPORTest(){
        Account partnerAccount=[select id from Account where recordtype.name='Partner' limit 1 ];
        Contact partnerContact=[select id from Contact where LastName ='testCon' limit 1];
        Account accountRecord=[select id from Account where recordtype.name='Enterprise' limit 1];
        Contact contact=[select id from Contact where accountid=:accountRecord.id limit 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PDF',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true);
        insert cv;
        
        ContentVersion document=[select Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","duration":"12"}';
        Test.startTest();
        PRM_MACDPORCtrl.createPOR(porDetails);
        Test.stopTest();
        System.assertEquals([SELECT  count() FROM Partner_of_Record__c ]>0, true,'Record Created');
    }
    @IsTest
    static void getPORTest(){
        Account partnerAccount=[select id from Account where recordtype.name='Partner' limit 1 ];
        Contact partnerContact=[select id from Contact where LastName ='testCon' limit 1];
        Account accountRecord=[select id from Account where recordtype.name='Enterprise' limit 1];
        Contact contact=[select id from Contact where accountid=:accountRecord.id limit 1];
        Partner_Of_Record__c porRecord=[Select Id from Partner_Of_Record__c LIMIT 1]; 
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PDF',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true);
        insert cv;
        
        ContentVersion document=[select Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","duration":"12"}';
        Test.startTest();
        Partner_of_Record__c testData = PRM_MACDPORCtrl.getPORRecord(porRecord.Id);
        Test.stopTest();
        System.assertEquals(testData.Id, porRecord.Id,'Check if the record is passed to the UI');
    }
    
    @IsTest
    static void updatePORTest(){
        Account partnerAccount=[select id from Account where recordtype.name='Partner' limit 1 ];
        Contact partnerContact=[select id from Contact where LastName ='testCon' limit 1];
        Account accountRecord=[select id from Account where recordtype.name='Enterprise' limit 1];
        Contact contact=[select id from Contact where accountid=:accountRecord.id limit 1];
        Partner_Of_Record__c porRecord=[Select Id,Sub_Status__c from Partner_Of_Record__c LIMIT 1]; 
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PDF',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true);
        insert cv;
        
        ContentVersion document=[select Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","porRecordId":"'+porRecord.Id+'","duration":"NoChange"}';
        Test.startTest();
        String testData = PRM_MACDPORCtrl.updatePOR(porDetails);
        Test.stopTest();
        porRecord=[Select Id,Status__c from Partner_Of_Record__c LIMIT 1]; 
        System.assertEquals(MODIFICATION_IN_PROGRESS_STRING, porRecord.Status__c,'Check if the record is updated to the Modification In Progress');
    }
     @IsTest
    static void ValidatePORTest(){
        Account partnerAccount=[select id from Account where recordtype.name='Partner' limit 1 ];
        Contact partnerContact=[select id from Contact where LastName ='testCon' limit 1];
        Account accountRecord=[select id from Account where recordtype.name='Enterprise' limit 1];
        Contact contact=[select id from Contact where accountid=:accountRecord.id limit 1];
        Partner_Of_Record__c porRecord=[Select Id,Sub_Status__c from Partner_Of_Record__c LIMIT 1]; 
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PDF',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true);
        insert cv;
        
        ContentVersion document=[select Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","porRecordId":"'+porRecord.Id+'","duration":"NoChange"}';
        Test.startTest();
        String testData = PRM_MACDPORCtrl.PORDomainValidation(accountRecord.id,partnerAccount.id,'Mobile',null);
        Test.stopTest();
       // porRecord=[Select Id,Status__c from Partner_Of_Record__c LIMIT 1]; 
        System.assertEquals(testData,'Customer Review');
    }

    //Start: EDGE-202803
    @isTest
    static void fetchProductDomainDataTest(){
        Map<String, List<String>> mapProductDomain  =   PRM_MACDPORCtrl.fetchProductDomainData();
        System.assertEquals(3, mapProductDomain.size());
        System.assertEquals(true, mapProductDomain.containsKey('Mobile'));
        System.assertEquals(true, mapProductDomain.containsKey('Data & IP'));
        System.assertEquals(true, mapProductDomain.containsKey('Network Applications and Services')); 
    }
    //End: EDGE-202803
    
    @IsTest
    static void updatePORCancellationTest(){
        Partner_Of_Record__c porRecord=[Select Id,Sub_Status__c, (Select Id,Name,Domain_Name__c,Status__c,Sub_Status__c from Partner_of_Record_Domain__r) from Partner_Of_Record__c LIMIT 1];
        porRecord.status__c='Modification in progress';
        update porRecord;
        Test.startTest();
        PRM_MACDPORCtrl.updatePORCancellation(new List<id>{porRecord.id});
        Partner_of_Record_Domain__c porDomain =[select id from Partner_of_Record_Domain__c where Partner_Of_Record__c=:porRecord.id limit 1];
        porDomain.status__c='Active';
        update porDomain;
        try{
        PRM_MACDPORCtrl.updatePORCancellation(new List<id>{porRecord.id});
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }
        Test.stopTest();
        }
    @IsTest
    static void updatePORDCanncelTest(){
        Account partnerAccount=[select id from Account where recordtype.name='Partner' limit 1 ];
        Contact partnerContact=[select id from Contact where LastName ='testCon' limit 1];
        Account accountRecord=[select id from Account where recordtype.name='Enterprise' limit 1];
        Contact contact=[select id from Contact where accountid=:accountRecord.id limit 1];
        Partner_Of_Record__c porRecord=[Select Id,Sub_Status__c from Partner_Of_Record__c LIMIT 1];
        Partner_of_Record_Domain__c porDomain =[select id from Partner_of_Record_Domain__c where Partner_Of_Record__c=:porRecord.id limit 1];
        porDomain.Status__c='Cancelled';
        update porDomain;
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.PDF',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true);
        insert cv;
        
        ContentVersion document=[select Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","porRecordId":"'+porRecord.Id+'","duration":"NoChange"}';
        Test.startTest();
        String testData = PRM_MACDPORCtrl.updatePOR(porDetails);
        Test.stopTest();
        Partner_Of_Record__c porRecord1=[Select Id,Sub_Status__c from Partner_Of_Record__c LIMIT 1];
        Partner_of_Record_Domain__c porDomain1 =[select id,Sub_Status__c from Partner_of_Record_Domain__c where Partner_Of_Record__c=:porRecord.id limit 1];
        system.debug('---Sub_Status__c'+porDomain1.Sub_Status__c );
        System.assertEquals(porDomain1.Sub_Status__c, 'Point of no return');
    }
    
    //Start: DIGI-1891
    @IsTest
    static void updatePORDCanncelDomainTest(){
        Account partnerAccount=[select id from Account where recordtype.name='Partner' limit 1 ];
        Contact partnerContact=[select id from Contact where LastName ='testCon' limit 1];
        Account accountRecord=[select id from Account where recordtype.name='Enterprise' limit 1];
        Contact contact=[select id from Contact where accountid=:accountRecord.id limit 1];
        Partner_Of_Record__c porRecord=[Select Id,Sub_Status__c from Partner_Of_Record__c LIMIT 1];
        Partner_of_Record_Domain__c porDomain =[select id from Partner_of_Record_Domain__c where Partner_Of_Record__c=:porRecord.id limit 1];
        porDomain.Status__c='Customer Review';
        update porDomain;
        
        List<Partner_of_Record_Domain__c> domainList = new List<Partner_of_Record_Domain__c>();
        domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = porRecord.Id,Status__c='Customer Review',Domain_Name__c='Network Application and Services'));
        Database.insert(domainList);
        
        ContentVersion cv = new ContentVersion(
                        Title = 'Test',
                        PathOnClient = 'Test.PDF',
                        VersionData = blob.valueof('Test Content Data'),
                        IsMajorVersion = true);                                                            
        insert cv;
        
        ContentVersion document=[select Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        String porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","porRecordId":"'+porRecord.Id+'","duration":"NoChange","cancelDomain":"Mobile"}';
        Test.startTest();
        String testData = PRM_MACDPORCtrl.updatePOR(porDetails);
        Test.stopTest();
        Partner_Of_Record__c porRecord1=[Select Id,Sub_Status__c,Is_Domain_Cancelled__c from Partner_Of_Record__c LIMIT 1];
        Partner_of_Record_Domain__c porDomain1 =[select id,Sub_Status__c,Domain_Name__c from Partner_of_Record_Domain__c where Partner_Of_Record__c=:porRecord.id limit 1];
        System.assertEquals(porRecord1.Is_Domain_Cancelled__c, true);

        porDetails = '{"partnerAccountId":"'+partnerAccount.id+'","partnerContactId":"'+partnerContact.id+'","accountRecordId":"'+accountRecord.id+'","contactId":"'+contact.id+'","documentId":"'+document.ContentDocumentId+'","domain":"Mobile;Network Application and Services","porRecordId":"'+porRecord.Id+'","duration":"24","cancelDomain":"Mobile"}';
        
        String testData2 = PRM_MACDPORCtrl.updatePOR(porDetails);
        Partner_Of_Record__c porRecord2=[Select Id,Sub_Status__c,Is_Domain_Cancelled__c from Partner_Of_Record__c LIMIT 1];
        Partner_of_Record_Domain__c porDomain2 =[select id,Sub_Status__c,Domain_Name__c from Partner_of_Record_Domain__c where Partner_Of_Record__c=:porRecord.id limit 1];
        System.assertEquals(porRecord2.Is_Domain_Cancelled__c , false);
    }
    //End: DIGI-1891
}