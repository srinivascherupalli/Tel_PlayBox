/*****************************************************************
@Name: FetchFCRContactControllerTest
@Author: Ravi Shankar
@JIRA Reference: EDGE-136074
@CreateDate: 26/02/2019
@Description: This is the Test class for FetchFCRContactController
******************************************************************/
@isTest( SeeAllData = false )
public class FetchFCRContactControllerTest {
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
       
          Id partnerrectypeid =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();		

           Account acc = new Account(name ='Telecom',recordtypeid=partnerrectypeid) ;
        insert acc; 
		
		acc.ispartner=true;
        update acc;
		
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
        insert con; 

        User u1 = new User(alias = 'test123', email='test12345@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'test12345@noemail.com');
        
        insert u1;
            Opportunity opp  = new Opportunity();
            opp.Name = 'TestOpp1';
			opp.AccountID = acc.id;
			opp.StageName = 'Committed';
			opp.CloseDate = System.today();
    		opp.ownerid=u1.id;
           opp.partneraccountid=acc.id;
			insert opp;
        
      
		   Id caseFulfillmentRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();		
		   Case fulcase = new Case(RecordTypeId = caseFulfillmentRecordTypeId);
           fulcase.Subject = 'Test';
           fulcase.OpportunityId__c = opp.id;
           fulcase.AccountId = acc.id; 
          insert fulcase;
     
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
		
        
        FulfillmentLineItem__c f= new FulfillmentLineItem__c(subscription__c=subs.id,Name='Test123',case__c=fulcase.id,Ownerid=u1.id);
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
      
     
       }
     
     
      
    }
    static testmethod void getEnggUsersPositiveTest(){
		List<Functional_Contact_Role__c> fcrLst = [select id from Functional_Contact_Role__c];
		list<user> lst = FetchFCRContactController.fetchContact(fcrLst[0].id);
		system.assertEquals(lst.size()>0, true);
    }
    static testmethod void getEnggUsersNegativeTest(){        
        List<Functional_Contact_Role__c> fcrLst = [select id from Functional_Contact_Role__c];
        try{            
			list<user> lst = FetchFCRContactController.fetchContact(null);
        }
        catch(Exception e){            
        }
        system.assertEquals(fcrLst.size()>0, true);
    }    
    static testmethod void createEnggUsersPositiveTest(){
		List<Functional_Contact_Role__c> fcrLst = [select id,ContactID__c,Partner_User__c from Functional_Contact_Role__c];
        list<string> lst = FetchFCRContactController.createPortalEngg(/*new list<string>{*/fcrLst[0].id+'#'+fcrLst[0].Partner_User__c/*}*/);
		system.debug('lst'+lst);
        system.assertEquals(lst[0], 'Users are added successfully');
    } 
    static testmethod void createEnggUsersNegativeTest(){
		List<Functional_Contact_Role__c> fcrLst = [select id,ContactID__c,Partner_User__c from Functional_Contact_Role__c];
        list<string> lst = FetchFCRContactController.createPortalEngg(/*new list<string>{*/fcrLst[0].id+'#'/*}*/);
		system.assertEquals(lst[0], 'Please select atleast one user');
    }

  static testmethod void ReassignTaskTCPSTest(){
      	User puser = [Select id from User where email = 'test12345@noemail.com'];
		FulfillmentLineItem__c fli=[select id,ownerid from FulfillmentLineItem__c where Name='Test123'];
		Functional_Contact_Role__c fcradmin=[select id from Functional_Contact_Role__c where Fulfillment_Task__c=:fli.id];
		
        list<string> result= FetchFCRContactController.ReassignTask(fli.id+'#'+puser.id,fcradmin.id,'Telstra Collaboration Operations User');
        FulfillmentLineItem__c fli1=[select id,ownerid from FulfillmentLineItem__c where id=:fli.id];
		system.assertEquals(fli1.ownerid,puser.id);
        
		list<Functional_Contact_Role__c> fcrlist=[select id,Fulfillment_Task__c from Functional_Contact_Role__c where Fulfillment_Task__c=:fli.id and Recordtype.Name='Portal Engineer'];
		system.assert(fcrlist.size()>0);
    }
static testmethod void ReassignTaskMDMPSTest(){
		User puser = [Select id from User where email = 'test12345@noemail.com'];
		FulfillmentLineItem__c fli=[select id,ownerid from FulfillmentLineItem__c where Name='Test123'];
		Functional_Contact_Role__c fcradmin=[select id from Functional_Contact_Role__c where Fulfillment_Task__c=:fli.id];
		
        list<string> result= FetchFCRContactController.ReassignTask(fli.id+'#'+puser.id,fcradmin.id,'MDM Operations User');
        FulfillmentLineItem__c fli1=[select id,ownerid from FulfillmentLineItem__c where id=:fli.id];
		system.assertEquals(fli1.ownerid,puser.id);
        
		list<Functional_Contact_Role__c> fcrlist=[select id,Fulfillment_Task__c from Functional_Contact_Role__c where Fulfillment_Task__c=:fli.id and Recordtype.Name='Portal Engineer'];
		system.assert(fcrlist.size()==0);
    }
 	
    static testmethod void getEngineeringUsersTest(){
		User puser = [Select id from User where email = 'test12345@noemail.com'];
		FulfillmentLineItem__c fli=[select id,ownerid from FulfillmentLineItem__c where Name='Test123'];
		Functional_Contact_Role__c fcradmin=[select id from Functional_Contact_Role__c where Fulfillment_Task__c=:fli.id];
		list<string> result= FetchFCRContactController.ReassignTask(fli.id+'#'+puser.id,fcradmin.id,'MDM Operations User');
		List<User> userlist=FetchFCRContactController.getEngineeringUsers(fli.id);  
		system.assert(userlist.size()>0);
    }
}