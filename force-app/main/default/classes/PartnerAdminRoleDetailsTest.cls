/*****************************************************************
@Name: PartnerAdminRoleDetailsTest
@Author: Purushottam Sahu
@CreateDate: 26/02/2020 
@Description: This is the Test class for PartnerAdminRoleDetails
******************************************************************/ 
/***History of Updates 
Purushottama Sahu: 29/04/2020  EDGE-137134  Added getPartnerFCRTenancies Method to View Telstra Collaboration Services selected in Enrichment 
***/
@isTest( SeeAllData = false )
public class PartnerAdminRoleDetailsTest {
 @TestSetup static void dataSetup() {
     
     UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
     insert r;
     String orgId = UserInfo.getOrganizationId();
     String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
     Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
     String uniqueName = orgId + dateString + randomInt;
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username=uniqueName+'Cont987657awqas@noemail.com', userroleid=r.id);
          
        insert uSysAdmin;
       System.runAs(uSysAdmin){  
        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        Account acc = new Account(name ='Telecom') ;
        insert acc; 
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Adaptive Collaboration Operations User;Engineering User;MDM Operations User');
        insert con; 

        User u1 = new User(alias = 'test123', email='test12345@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'test12345@noemail.com');
        
        insert u1;
     
        Marketable_Offer__c moMob = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services-MDM Config',Name = 'Professional Services-MDM Config',Offer_ID__c = System.Label.TC_PS_Offer,Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}');
        insert moMob;
        
        cscfga__Product_Definition__c pd= ProductTestFactory.buildProductDefinition('Professional Services','Professional Services');
        insert pd;
        
        cscfga__Product_Configuration__c pc = ProductTestFactory.buildProductConfig(pd.id);
        pc.name= 'Professional Services-MDM Config';
        pc.Marketable_Offer__c=moMob.id;
        insert pc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
        insert subs;
        //EDGE-137134 >> Start
        csord__Subscription__c tenancySubs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
        insert tenancySubs;
         
         subs.Parent_Subscription__r=tenancySubs;
         update subs;
        //EDGE-137134 >> End
        csord__Service__c ser = ProductTestFactory.buildService('TestService', ord.id, subs.id, ordReq.id);
        ser.name = 'Telstra Collaboration Professional Services';
        ser.csordtelcoa__Product_Configuration__c = pc.id;
        insert ser;
        
        Attachment att1 = new Attachment(Name = 'ServiceSpecifications.json',ParentId = ser.Id);
        att1.Body = Blob.valueOf('{"specifications" : [ {  "version" : "1",  "status" : "Created",  "startDate" : "",  "specification" : "49c6a564-5845-7088-a2b5-f0f61688f5ca",  "productConfigurationId" : "a3T5O0000001OdcUAE",  "name" : "Non_Commercial_Site_Contact",  "metadata" : { },  "instanceId" : "",  "includeBilling" : false,  "guid" : "122271fe-72f5-1dc4-0b98-5eeeeec769ce",  "endDate" : "",  "description" : "NON_COMMERCIAL_SITE_CONTACT_DETAILS",  "code" : "Non_Commercial_Site_Contact",  "attributes" : {    "PS_SITE_CONTACT" : [ {      "attributes" : {        "ProjectContactName" : "Billing",        "SiteContactBusinessHoursName" : "Sahu Contact",        "SiteContactAfterHoursName" : "Billing",        "ContactName" : "Billing",        "SiteName" : "0 CAMBRIDGE ST ROCKLEA QLD 4106",        "ProjectContactId" : "0035O0000029suAQAQ",        "ContactId" : "0035O0000029suAQAQ",        "SiteContactAfterHoursId" : "0035O0000029suAQAQ",        "SiteContactBusinessHoursId" : "0035O000001tIjVQAU",        "SiteId" : "a4O2O0000004TWxUAM"      },      "schemaId" : "9fd5db8d-04b6-a7cc-e2ab-f51b5151ac63"    } ]  },  "additionalAttributes" : { }} ],"serviceId" : "a4e5O0000002FmkQAE","legacyAttributes" : [ ]}');
        insert att1;
        
        FulfillmentLineItem__c f= new FulfillmentLineItem__c(subscription__c=subs.id,FCR_Subscriptions__c=subs.id,ownerid=u1.id,Name='Professional Services-MDM Config');        
        insert f;
        Id fcrPortalAdminRecordTypeID =  Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Admin').getRecordTypeId();
        Id fcrPortalEngineerRecordTypeID =  Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Engineer').getRecordTypeId();
        
        List<Functional_Contact_Role__c> fcrList= new List<Functional_Contact_Role__c>();
           Functional_Contact_Role__c fcrAdmin = new Functional_Contact_Role__c( Role_Type__c = 'Subscription',
                                                                         RecordTypeId = fcrPortalAdminRecordTypeID,
                                                                         SubscriptionID__c=subs.id,
                                                                         Partner_User__c=u1.id,
                                                                         Role__c='Adaptive Collaboration',
                                                                         ContactID__c=con.id,
                                                                         Fulfillment_Task__c=f.id
                                                                       );
           fcrList.add(fcrAdmin);
      
        Functional_Contact_Role__c fcrEngineer = new Functional_Contact_Role__c( Role_Type__c = 'Subscription',
                                                                         RecordTypeId = fcrPortalEngineerRecordTypeID,
                                                                         SubscriptionID__c=subs.id,
                                                                         Partner_User__c=u1.id,
                                                                         ContactID__c=con.id,
                                                                         Fulfillment_Task__c=f.id
                                                                       );
           fcrList.add(fcrEngineer);
   
     Functional_Contact_Role__c fcrMDM = new Functional_Contact_Role__c( Role_Type__c = 'Subscription',
                                                                         RecordTypeId = fcrPortalAdminRecordTypeID,
                                                                         SubscriptionID__c=subs.id,
                                                                         Partner_User__c=u1.id,
                                                                         Role__c='MDM Operations User',
                                                                         ContactID__c=con.id,
                                                                         Fulfillment_Task__c=f.id
                                                                       );
           fcrList.add(fcrMDM);
           insert fcrList;
       }
 }
    //test Method for getPartnerRoles Positive scenario
    static testmethod void getPartnerRolesPositiveTest()
    {
        User uSysAdmin = [Select id from User where email = 'test12345@noemail.com'];
        System.runAs(uSysAdmin){  
        Test.startTest();
        //test Method for getPartnerRoles - Telstra Collaboration Operations User
        System.assertNotEquals(PartnerAdminRoleDetails.getPartnerRoles('Telstra Collaboration Operations User'),null);
        //test Method for getPartnerRoles - Engineering User
        System.assertNotEquals(PartnerAdminRoleDetails.getPartnerRoles('Engineering User'),null);
          //test Method for getPartnerRoles - MDM Operations User
        System.assertNotEquals(PartnerAdminRoleDetails.getPartnerRoles('MDM Operations User'),null);
        Test.stopTest();
        }
    }
    //test Method for getPartnerEngineers 
    static testmethod void getPartnerEngineersPositiveTest()
    {
        User uSysAdmin = [Select id from User where email = 'test12345@noemail.com'];
        Functional_Contact_Role__c partnerAdmin = [SELECT id,SubscriptionID__c,Fulfillment_Task__c FROM Functional_Contact_Role__c WHERE recordtype.name='Portal Admin' limit 1];
        System.runAs(uSysAdmin){
        Test.startTest();
        //test Method for getPartnerEngineers - Portal Admin Record
        System.assertNotEquals(PartnerAdminRoleDetails.getPartnerEngineers(partnerAdmin.id),null);
         Test.stopTest();
        }
    }
    
    //test Method for getPartnerRoles Negative scenario
     static testmethod void getPartnerRolesNegativeTest()
    {
        Test.startTest();
        System.assertEquals(PartnerAdminRoleDetails.getPartnerRoles('Test'),null);
        Test.stopTest();
    }
    //EDGE-137134 >> Test Coverage Added for getPartnerFCRTenanciesTest and getPartnerAdminsTest
    //test Method for getPartnerAdmin Positive scenario
     static testmethod void getPartnerAdminsTest()
    {
        Test.startTest();
         Functional_Contact_Role__c partnerAdmin = [SELECT id,SubscriptionID__c,Fulfillment_Task__c FROM Functional_Contact_Role__c WHERE recordtype.name='Portal Admin' limit 1];
        System.assertNotEquals(PartnerAdminRoleDetails.getPartnerAdmins(partnerAdmin.id),null);
        Test.stopTest();
    }
    
    //test Method for getPartnerFCRTenancies Positive scenario
     static testmethod void getPartnerFCRTenanciesTest()
    {
        Test.startTest();
        FulfillmentLineItem__c FLI= [select id from FulfillmentLineItem__c];
        System.assertnotEquals(PartnerAdminRoleDetails.getPartnerFCRTenancies(FLI.id),null);
        Test.stopTest();
    }
    //EDGE-137134 >> End
    
    //EDGE-140596 test Method for getPartnerEngineerRolesPSMDM 
    static testmethod void getPartnerEngineersMDMPositiveTest()
    {
        User uSysAdmin = [Select id from User where email = 'test12345@noemail.com'];
        System.runAs(uSysAdmin){
        Test.startTest();
        //test Method for getPartnerEngineers - Portal Admin Record
     System.assert(PartnerAdminRoleDetails.getPartnerEngineerRolesPSMDM().size()>0);
         Test.stopTest();
        }
    }
        //EDGE-140596 test Method for getPartnerEngineerRolesPSMDM 
     static testmethod void getPartnerEngineersMDMNegativeTest()
    {
        User uSysAdmin = [Select id from User where email = 'ContactTr8wrw98@noemail.com'];
        System.runAs(uSysAdmin){
        Test.startTest();
        //test Method for getPartnerEngineers - Portal Admin Record
        System.assert(PartnerAdminRoleDetails.getPartnerEngineerRolesPSMDM().size()==0);
         Test.stopTest();
        }
    }
}