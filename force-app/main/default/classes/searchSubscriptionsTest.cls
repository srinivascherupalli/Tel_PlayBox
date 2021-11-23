@isTest
public class searchSubscriptionsTest {
    @testSetup static void setup() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
        id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        insert uSysAdmin;
        
        System.runAs(uSysAdmin){  
            
            list<account> acclist= new list<account>();
            id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
            id PartnerrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Contact contact = new Contact(
                LastName = 'Last', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tele2.com', Contact_Status__c = 'Active');
            EnvironmentalSettings.isTriggerDisabled('ContactTrigger');
            Insert contact;
            
            account partneracc = new Account();
            partneracc.RecordTypeId = PartnerrecordTypeId ;
            partneracc.Name='Partner acc';
            partneracc.Account_Status__c = 'Active';
            partneracc.Customer_Trading_Name__c = 'Test';
            partneracc.ABN__c='aaaa';
            partneracc.Mobile_Code__c = '12345';
            partneracc.ACN__c='ccc';
            partneracc.State_Coverage__c = 'VIC';
            partneracc.Partner_Type__c='Partner';
            partneracc.Website = 'www.vsygqwoci.com';
            partneracc.Phone='0412354323';
            partneracc.Overall_Accreditation__c='Platinum';
            partneracc.Mobility_Accreditation__c='Platinum';
            partneracc.Cloud_Accreditation__c='Platinum';
            partneracc.Data_Security_Accreditation__c='Platinum';
            partneracc.Collaboration_Accreditation__c='Platinum';
            partneracc.PartnerPrincipalContact__c = Contact.id;
            insert partneracc;
            
            Account enterPriseacc = AccountTestFactory.buildAccount('Test Enterprise');
            enterPriseacc.Customer_Status__c = 'ACTIVE';    
            enterPriseacc.CIDN__c = '1234';
            enterPriseacc.recordTypeId=recordTypeId;
            insert enterPriseacc;   
            
            cscfga__Product_Configuration__c prod = new cscfga__Product_Configuration__c();
            prod.ConfigurationType1__c = 'SolutionComponent';
            prod.Name = 'test Product';
            insert prod;
            
            csord__Subscription__c sub = new csord__Subscription__c();
            sub.Name = 'test Subscriptions';
            sub.PartnerAccount__c = partneracc.Id;
            sub.csord__Account__c = enterPriseacc.Id;
            sub.csord__Status__c = 'Active';
            sub.csord__Identification__c = 'test';
            sub.csordtelcoa__Product_Configuration__c = prod.Id;
            insert sub;   
        }
    }
    @isTest
    public static void searchSubtest(){
        Account enterPriseacc= [select id from Account where name ='Test Enterprise'];
        Account partneracc=[select id from Account where name='Partner acc'];
        list<csord__Subscription__c> subs = searchSubscriptions.getSubscriptions(enterPriseacc.id,partneracc.id,'1234','12345',null,null,'SolutionComponent');    
        system.assert(subs.size()>0);
    }  
    
     @isTest
    public static void updatePartnertest(){
          Account partneracc=[select id from Account where name='Partner acc'];
          Map<Id, csord__Subscription__c> subMap=new Map<ID, csord__Subscription__c>([select id from csord__Subscription__c]);
          String errResult = searchSubscriptions.updatePartner( null,null);
          String result = searchSubscriptions.updatePartner( new List<Id>(subMap.keySet()),partneracc.id);
          system.assertEquals(result,'Success');
    }
}