/*********************************
 * @Author: Sarvanan, Sathyanarayanan, Vasu
 * @Date : Sep 19, 2021
 * @Description : Test Class for OrderEnrichmentLookUp
 * Last modified Date: 13/10/2021
 *********************************/

@isTest
public class OrderEnrichmentLookUpTest {
    @testsetup static void OrderEnrichmentLookUpTestDataSetup()
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User admin = new User(alias = 'standt',email='adminuser@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pfAdmin.id,
                              timezonesidkey='Australia/Sydney',userroleid=r.id,
                              username=uniqueName+'TestingAdmin@TestingAdmin.com');
        insert admin;
        System.runAs(admin){
            Account[] partnerAcc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAcc; 
            partnerAcc[0].ispartner=true;
            update partnerAcc[0];
            
            Contact partnerCon = new Contact(LastName ='testCon',AccountId = partnerAcc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert partnerCon; 
            Profile prmProfile = [select id from profile where name ='PRM Community User - Australia'];
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{prmProfile} ,new List<Contact>{partnerCon} ,false);
            insert partnerUser;
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact con = AccountTestFactory.buildContact(acc,'TestContact');
        insert con;
        // Updating Contact Role to Fix Test Class Failure
        AccountContactRelation acr = [Select id , Roles from AccountContactRelation where ContactId =: con.id limit 1];
        acr.Roles = 'Full Authority';
        update acr;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        }
        
    }
    static testmethod void doLookupSearchTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        List<Contact> lstCon = (List<Contact>)OrderEnrichmentLookUp.doLookupContactDetails(basket.Id, null, null);
        system.assert(lstCon.size()!=null);
    }
    
    static testmethod void doLookupSearchPartnerTest()
    {
         User partnerUser = [Select id,IsActive from user where email ='test@noemail45345555.com0' and IsActive =true Limit 1 ];
         System.runAs(partnerUser){
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        List<Contact> lstCon = (List<Contact>)OrderEnrichmentLookUp.doLookupContactDetails(basket.Id, null, null);
        system.assert(lstCon.size()!=null);
        }
    }
    static testmethod void doLookupNeagativeTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        List<Contact> lstCon = OrderEnrichmentLookUp.doLookupContactDetails(null, null, null);
        system.assert(lstCon==null);
        
    }
	static testmethod void doLookupDeliveryAddressTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        List<cscrm__Address__c> lstCon = (List<cscrm__Address__c>)OrderEnrichmentLookUp.doLookupDeliveryAddress(basket.Id, null);
        system.assert(lstCon.size()!=null);
    }
}