/****************************************************************************************************
Name          : GetDeliveryDetailsLookupValuesTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of GetDeliveryDetailsLookupValues
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods getDataTest, getDataTest1
1.2         Rohit T         27-07-2019      Added getDataTest2 to Increase the Code Coverage
1.3         Venkata Ramanan 19-08-2019 .    Added getDataTest3 to cater new options getcontact & getaddress
1.4         Purushottam 	02-09-2020      Added getDataTest4 to test logic of getcontact for Partners
****************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class GetDeliveryDetailsLookupValuesTest {
    
    /******************************************************************************************************
    * Method Name : getDataTest
    * Description : Used to simulate and test the logic of getData method in GetDeliveryDetailsLookupValues
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getDataTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        inputMap.put('basketId', basket.Id);
        cspmb__Price_Item__c userPI = new cspmb__Price_Item__c(Name = 'User', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'User', Package_Name__c = 'Connected Workplace', Type__c = 'Fixed Seat', Zone__c = '1', cspmb__Effective_End_Date__c = System.today().addDays(1), cspmb__Effective_Start_Date__c = System.today().addDays(-1));
        INSERT userPI;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            GetDeliveryDetailsLookupValues getDlvryDet = new GetDeliveryDetailsLookupValues();
            returnMap = getDlvryDet.getData(inputMap);
        Test.stopTest();
        System.assertEquals(2, returnMap.size());
        System.assert(returnMap.containsKey('contact'));
        System.assert(returnMap.containsKey('addresses'));
        System.assertEquals(new List<Contact>(), returnMap.get('contact'));
        System.assertEquals(new List<cscrm__Address__c>(), returnMap.get('addresses'));
    }
    
    /******************************************************************************************************
    * Method Name : getDataTest1
    * Description : Used to simulate and test the logic of getData method in GetDeliveryDetailsLookupValues
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getDataTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        inputMap.put('basketId', basket.Id);
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Contact con = new Contact(LastName = 'Test Con', AccountId = acc.Id);
        INSERT con;
        AccountContactRelation acr = new AccountContactRelation(ContactId = con.Id, AccountId = basket.csbb__Account__c);
        INSERT acr;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            GetDeliveryDetailsLookupValues getDlvryDet = new GetDeliveryDetailsLookupValues();
            returnMap = getDlvryDet.getData(inputMap);
        Test.stopTest();
        System.assertEquals(2, returnMap.size());
        System.assert(returnMap.containsKey('contact'));
        System.assert(returnMap.containsKey('addresses'));
        System.assertNotEquals(NULL, returnMap.get('contact'));
        System.assertNotEquals(NULL, returnMap.get('addresses'));
    }
    
    //To Increase the Code Coverage (CR 1.2)
        /******************************************************************************************************
    * Method Name : getDataTest2
    * Description : Used to simulate and test the logic of getData method in GetDeliveryDetailsLookupValues
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getDataTest2() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        inputMap.put('basketId', basket.Id);
        inputMap.put('searchString', 'Test');
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Contact con = new Contact(LastName = 'Test Con', AccountId = acc.Id);
        INSERT con;
        AccountContactRelation acr = new AccountContactRelation(ContactId = con.Id, AccountId = basket.csbb__Account__c);
        INSERT acr;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            GetDeliveryDetailsLookupValues getDlvryDet = new GetDeliveryDetailsLookupValues();
            returnMap = getDlvryDet.getData(inputMap);
        Test.stopTest();
        System.assertNotEquals(NULL, returnMap);
    }
     //To Increase the Code Coverage - Venkata Ramanan G
        /******************************************************************************************************
    * Method Name : getDataTest3
    * Description : Used to simulate and test the logic of getData method options getcontact & getaddress in GetDeliveryDetailsLookupValues
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getDataTest3() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        inputMap.put('basketId', basket.Id);
        inputMap.put('option', 'getcontact');
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Contact con = new Contact(LastName = 'Test Con', AccountId = acc.Id);
        INSERT con;
        inputMap.put('id', con.id);
        AccountContactRelation acr = new AccountContactRelation(ContactId = con.Id, AccountId = basket.csbb__Account__c);
        INSERT acr;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            GetDeliveryDetailsLookupValues getDlvryDet = new GetDeliveryDetailsLookupValues();
            returnMap = getDlvryDet.getData(inputMap);
            
        Test.stopTest();
        System.assertNotEquals(NULL, returnMap);
    }
    
     /******************************************************************************************************************
    * Method Name : getDataTest4
    * Description : Used to simulate and test the logic of getData method in GetDeliveryDetailsLookupValues for Partners
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************************************/
    static testmethod void getDataTest4() {
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
        Map<String, Object> inputMap = new Map<String, Object> ();
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
        
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = basket.csordtelcoa__Account__c;
        UPDATE basket;
        inputMap.put('basketId', basket.Id);
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Contact con = new Contact(LastName = 'Test Con', AccountId = acc.Id);
        INSERT con;
        AccountContactRelation acr = new AccountContactRelation(ContactId = con.Id, AccountId = basket.csbb__Account__c);
        INSERT acr;
        }
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User partnerUser = [Select id,IsActive from user where email ='test@noemail45345555.com0' and IsActive =true Limit 1 ];
        System.runAs(partnerUser){   
        GetDeliveryDetailsLookupValues getDlvryDet = new GetDeliveryDetailsLookupValues();
            returnMap = getDlvryDet.getData(inputMap);
        }
        Test.stopTest();
        System.assertEquals(2, returnMap.size());
        System.assert(returnMap.containsKey('contact'));
        System.assert(returnMap.containsKey('addresses'));
        System.assertNotEquals(NULL, returnMap.get('contact'));
        System.assertNotEquals(NULL, returnMap.get('addresses'));
    }
}