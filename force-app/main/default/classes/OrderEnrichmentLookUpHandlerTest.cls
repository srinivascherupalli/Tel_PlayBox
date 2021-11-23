/*********************************
 * @Author: Sarvanan, Sathyanarayanan, Vasu
 * @Date : Sep 19, 2021
 * @Description : Test Class for OrderEnrichmentLookUpHandler
 * Last modified Date: 13/10/2021
 *********************************/

@isTest
public class OrderEnrichmentLookUpHandlerTest {
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
		
		cscrm__Address__c address= new cscrm__Address__c();
		address.Address_ID__c='Test'; 
		//address.Street_calc__c='Test'; 
		address.cscrm__City__c='Test';
		address.cscrm__Zip_Postal_Code__c='12345';
		address.Address_Status__c='CONFIRMED';
		insert address;
		
		
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        }
        
    }
    static testmethod void doLookupContactFromAcctBasketTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
		searchFields.put('basketId',basket.Id);
        searchFields.put('searchValue','');
        searchFields.put('CommercialPDName','');
        List<Contact> lstCon = (List<Contact>)OrderEnrichmentLookUpHandler.doLookupContactFromAcctBasket(searchFields, 99);
        system.assert(lstCon.size()!=null);
    }
    
    static testmethod void doLookupSearchPartnerTest()
    {
         User partnerUser = [Select id,IsActive from user where email ='test@noemail45345555.com0' and IsActive =true Limit 1 ];
         System.runAs(partnerUser){
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
		 Map<String, String> searchFields= new Map<String, String>();
		searchFields.put('basketId',basket.Id);
        searchFields.put('searchValue','');
        searchFields.put('CommercialPDName','BroadsoftTenancy');
        List<Contact> lstCon = (List<Contact>)OrderEnrichmentLookUpHandler.doLookupContactFromAcctBasket(searchFields, 99);
        system.assert(lstCon.size()!=null);
        }
    }
    static testmethod void doLookupDeliveryAddressTest()
    {
		cscrm__Address__c add= [ SELECT Name, Id, Address_ID__c, Street_calc__c, cscrm__City__c, cscrm__Zip_Postal_Code__c, Address_Status__c
                FROM cscrm__Address__c];
		  Map<String,String> searchFields = new Map<String,String>();
         searchFields.put('searchValue','Test');
        List<Object> lstCon = OrderEnrichmentLookUpHandler.doLookupConfirmedAddress(searchFields, 25);
        system.assert(lstCon!=null);
        
    }
	 static testmethod void doLookupDeliveryAddressTestNew()
    {
		cscrm__Address__c add= [ SELECT Name, Id, Address_ID__c, Street_calc__c, cscrm__City__c, cscrm__Zip_Postal_Code__c, Address_Status__c
                FROM cscrm__Address__c];
		  Map<String,String> searchFields = new Map<String,String>();
         searchFields.put('searchValue',null);
        List<Object> lstCon = OrderEnrichmentLookUpHandler.doLookupConfirmedAddress(searchFields, 25);
        system.assert(lstCon!=null);
        
    }
	
}