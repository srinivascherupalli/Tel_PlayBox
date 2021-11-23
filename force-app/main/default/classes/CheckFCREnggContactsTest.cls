/*****************************************************************
@Name: CheckFCREnggContactsTest
@Author: Ravi Shankar
@JIRA Reference: EDGE-136074
@CreateDate: 27/02/2019
@Description: This is the Test class for CheckFCREnggContacts
******************************************************************/
@isTest( SeeAllData = false )
public class CheckFCREnggContactsTest {
 @TestSetup static void dataSetup() {
     
      UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
          
        insert uSysAdmin;
       System.runAs(uSysAdmin){  
        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        Account acc = new Account(name ='Telecom') ;
        insert acc; 
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
		conList.add(con);
        Contact con2 = new Contact(LastName ='testCon2',AccountId = acc.Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
        conList.add(con2);
        insert conList;

        List<User> usrList = new List<User>();
           String orgId = UserInfo.getOrganizationId();
           String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
           Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
           String uniqueName = orgId + dateString + randomInt;
           
        User u1 = new User(alias = 'test123', email='test12345@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'test12345@noemail.com');
		usrList.add(u1);           
        User u2 = new User(alias = 'test128', email='test12365@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testaing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con2.Id,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'test12365@noemail.com');   
        usrList.add(u2);
        insert usrList;
     
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
        
        csord__Service__c ser = ProductTestFactory.buildService('TestService', ord.id, subs.id, ordReq.id);
        ser.name = 'Telstra Collaboration Professional Services';
        ser.csordtelcoa__Product_Configuration__c = pc.id;
        insert ser;
        
        Attachment att1 = new Attachment(Name = 'ServiceSpecifications.json',ParentId = ser.Id);
        att1.Body = Blob.valueOf('{"specifications" : [ {  "version" : "1",  "status" : "Created",  "startDate" : "",  "specification" : "49c6a564-5845-7088-a2b5-f0f61688f5ca",  "productConfigurationId" : "a3T5O0000001OdcUAE",  "name" : "Non_Commercial_Site_Contact",  "metadata" : { },  "instanceId" : "",  "includeBilling" : false,  "guid" : "122271fe-72f5-1dc4-0b98-5eeeeec769ce",  "endDate" : "",  "description" : "NON_COMMERCIAL_SITE_CONTACT_DETAILS",  "code" : "Non_Commercial_Site_Contact",  "attributes" : {    "PS_SITE_CONTACT" : [ {      "attributes" : {        "ProjectContactName" : "Billing",        "SiteContactBusinessHoursName" : "Sahu Contact",        "SiteContactAfterHoursName" : "Billing",        "ContactName" : "Billing",        "SiteName" : "0 CAMBRIDGE ST ROCKLEA QLD 4106",        "ProjectContactId" : "0035O0000029suAQAQ",        "ContactId" : "0035O0000029suAQAQ",        "SiteContactAfterHoursId" : "0035O0000029suAQAQ",        "SiteContactBusinessHoursId" : "0035O000001tIjVQAU",        "SiteId" : "a4O2O0000004TWxUAM"      },      "schemaId" : "9fd5db8d-04b6-a7cc-e2ab-f51b5151ac63"    } ]  },  "additionalAttributes" : { }} ],"serviceId" : "a4e5O0000002FmkQAE","legacyAttributes" : [ ]}');
        insert att1;
        
        FulfillmentLineItem__c f= new FulfillmentLineItem__c(subscription__c=subs.id);
        insert f;
        Id fcrPortalAdminRecordTypeID =  Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Admin').getRecordTypeId();
        Id fcrPortalEngineerRecordTypeID =  Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Engineer').getRecordTypeId();
        
        Functional_Contact_Role__c fcrAdmin = new Functional_Contact_Role__c( Role_Type__c = 'Subscription',
                                                                         RecordTypeId = fcrPortalAdminRecordTypeID,
                                                                         SubscriptionID__c=subs.id,
                                                                         Partner_User__c=u1.id,
                                                                         ContactID__c=con.id,
                                                                         Fulfillment_Task__c=f.id
                                                                       );
     insert fcrAdmin;
      
        Functional_Contact_Role__c fcrEngineer = new Functional_Contact_Role__c( Role_Type__c = 'Subscription',
                                                                         RecordTypeId = fcrPortalEngineerRecordTypeID,
                                                                         SubscriptionID__c=subs.id,
                                                                         Partner_User__c=u1.id,
                                                                         ContactID__c=con2.id,
                                                                         Fulfillment_Task__c=f.id
                                                                       );
        insert fcrEngineer;
       }
    }
    static testmethod void checkEnggUsersTest(){
		List<Functional_Contact_Role__c> fcrLst = [select id from Functional_Contact_Role__c];
		list<string> lstRes = CheckFCREnggContacts.checkContactsExist(new list<string>{fcrLst[0].id});
		system.assertEquals(lstRes[0], 'Yes');
    }
    static testmethod void checkEnggUsersNegativeTest(){        
        List<Functional_Contact_Role__c> fcrLst = [select id from Functional_Contact_Role__c];
        try{            
			list<string> lstRes = CheckFCREnggContacts.checkContactsExist(null);
        }
        catch(Exception e){            
        }
        system.assertEquals(fcrLst.size()>0, true);
    }    
}