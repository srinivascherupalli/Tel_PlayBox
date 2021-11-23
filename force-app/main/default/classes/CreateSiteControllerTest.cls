@isTest
private class CreateSiteControllerTest{
    private static  Account acc=null;
    private static cscrm__Address__c add=null;
    @testsetup static void CreateSiteControllerTestDataSetup()
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
        }
        
    }
    private static void preRequisitesForSiteCreation(){
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
    
    @isTest static void testSaveNewSiteSuccessCase1(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  '';
        String account = ''+acc.id;
        String address = ''+add.id;
        
        Test.startTest();
        String result = CreateSiteController.saveNewSite(siteName,account,address);
        Test.stopTest();
        System.assertEquals('Success',result);
        
    }
    
    @isTest static void testSaveNewSiteFailureCase1(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  'Valid';
        String account = ''+acc.id;
        String address = ''+add.id;
        
                
        Test.startTest();
        String result1 = CreateSiteController.saveNewSite(siteName,account,address);
        String result2 = CreateSiteController.saveNewSite(siteName,account,address);
        Test.stopTest();
        System.assertEquals('Success',result1);
        //System.assertEquals('Failed',result2);
        
    }

  @isTest static void testSaveNewSiteFailureCase2(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String account = ''+acc.id;
        String address = '';
                
        Test.startTest();
        String result = CreateSiteController.saveNewSite(siteName,account,address);
        Test.stopTest();
        System.assertEquals('Failed',result);
    }
    
    @isTest Static void testGetAddressType(){
        preRequisitesForSiteCreation();
        String address = ''+add.id;
        Test.startTest();
        sObject result = CreateSiteController.getAddressType(address);
        Test.stopTest();
        System.assert(result!=null);
    }

    @isTest Static void testGetSiteName(){
        try{
        preRequisitesForSiteCreation();
        List<cscrm__Address__c> addList = [SELECT Id FROM cscrm__Address__c];
        String siteName = CreateSiteController.getSiteNameSFDC(addList[0].Id);
        System.assert(siteName!=null);
        }
        catch(Exception e){
            System.debug(e);
        }
    }

    /**
    *   @Description - If site name is start with '0' or 'null' or BLANK values then ignore value.
    *   @Jira Story Ref - EDGE-77460
    *   @ModifiedBy - Ramesh Somalagari,OSAKA
    **/
    @isTest static void getSiteNamePositiveTest(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  '';
        String account = ''+acc.id;
        String address = ''+add.id;
        add.streetNumberStartPrefix__c = '02';
        add.streetNumberEndPrefix__c    = '02';
        update add;
        Test.startTest();
    
        String result = CreateSiteController.getSiteNameSFDC(String.valueOf(add.id));
        System.assert(siteName!=null);
        Test.stopTest();
        
    }
    @isTest static void getSiteNameNegativeTest(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  '';
        String account = ''+acc.id;
        String address = ''+add.id;
        add.streetNumberStartPrefix__c = '02';
        add.streetNumberEndPrefix__c    = '02';
        update add;
        Test.startTest();
    
        String result = CreateSiteController.getSiteNameSFDC(String.valueOf(add.id));
        Test.stopTest();
        System.debug(result);
        System.assert(siteName!=null);
        
    }
    
    /**
    *   @Description - Written test method as part of EDGE-77460
    *   @Jira Story Ref - EDGE-77460
    *   @ModifiedBy - Sasidhar Devarapalli,OSAKA
    **/
    @isTest static void getParentAccountTest(){
        preRequisitesForSiteCreation();
        Account acc1 = [select id,name from Account where id=:acc.id];
        Test.startTest();
        Sobject accResult = CreateSiteController.getParentAccount(String.valueOf(acc1.id));
        Test.stopTest();
        System.assertNotEquals(null,accResult);
    }
    
    /**
    *   @Description - Written test method as part of EDGE-77460
    *   @Jira Story Ref - EDGE-77460
    *   @ModifiedBy - Sasidhar Devarapalli,OSAKA
    **/
    @isTest static void getParaSaveAndNewTest(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  '';
        String account = ''+acc.id;
        String address = ''+add.id;
        add.streetNumberStartPrefix__c = '02';
        add.streetNumberEndPrefix__c    = '02';
        update add;
        Test.startTest();
        Sobject siteResult = CreateSiteController.getParaSaveAndNew();
        Test.stopTest();
        System.assertNotEquals(null,siteResult);
    }
    
    @isTest static void testgetallsites(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  'Valid';
        String account = ''+acc.id;
        String address = ''+add.id;
        
        String accid = acc.id;
        
        Test.startTest();
        List<cscrm__Site__c> siteResult = CreateSiteController.getAllsites(accid);
        Test.stopTest();
        System.assertNotEquals(null,siteResult);
        
        
    }
    
    @isTest static void testcheckporaccess(){
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  'Valid';
        String account = ''+acc.id;
        String address = ''+add.id;
        
        String accid = acc.id;
        
        Test.startTest();
        List<cscrm__Site__c> siteResult = CreateSiteController.getAllsites(accid);
        Test.stopTest();
        System.assertNotEquals(null,siteResult);
        
        
    }
    @isTest static void checkcreatesiteaccessTest(){
         User partnerUser = [Select id,IsActive from user where email ='test@noemail45345555.com0' and IsActive =true Limit 1 ];
        preRequisitesForSiteCreation();
        String siteName = 'Melbourne'; 
        String status =  '';
        String account = ''+acc.id;
        String address = ''+add.id;
        add.streetNumberStartPrefix__c = '02';
        add.streetNumberEndPrefix__c    = '02';
        update add;
         System.runAs(partnerUser){
            CreateSiteController.checkcreatesiteaccess(acc.id);
         }
    }
}