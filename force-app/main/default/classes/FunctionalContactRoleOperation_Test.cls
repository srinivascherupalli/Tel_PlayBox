/*********************************************************************************************************************************
 *Class Name      :   FunctionalContactRoleOperation_Test
 *Story             :   EDGE-78293  Create PB to attach Dummy PC for Legacy Transition Services
 *Developer         :   Rohit Tripathi
@LastModified:	Modified by Sri, team SFO on 16/01/2020 
				P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation  


Test Class : FunctionalContactRoleOperationTest
********************************/


@isTest
public class FunctionalContactRoleOperation_Test {
    @testsetup static void CustomButtonComparisonDataSetup()
    {
        Profile pf = [select Id,Name from profile where name ='Sales Manager - Enterprise'];
        //CREATE USER
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = pf.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com');

        insert usr;
        System.runAs(usr){

            Account acc = AccountTestFactory.buildAccount('TestAccount');
			//Modified by Sri, team SFO on 16/01/2020
			//P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
            acc.Imported__c = true;
            insert acc;

            List<Contact> lstContact = new List<Contact>();
            Contact con = AccountTestFactory.buildContact(acc,'Primary Contact');
            lstContact.add(con);
            con = AccountTestFactory.buildContact(acc,'Technical Contact');
            lstContact.add(con);
            con = AccountTestFactory.buildContact(acc,'After Hours Contact');
            lstContact.add(con);
            con = AccountTestFactory.buildContact(acc,'Project Contact');
            lstContact.add(con);
            con = AccountTestFactory.buildContact(acc,'Delivery Contact');
            lstContact.add(con);
            con = AccountTestFactory.buildContact(acc,'Order primary contact');
            lstContact.add(con);

            insert lstContact;

            cscrm__Address__c address = AccountTestFactory.buildAddress('12345');
            insert address;

            cscrm__Site__c site = AccountTestFactory.buildSite(address.Id, acc.Id);
            insert site;


            cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('IP Site','IP Site');
            System.assertNotEquals(null,prodDef);
            insert prodDef;

            cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
            insert prodConfig;

            csord__Order_Request__c orderRequest = ProductTestFactory.buildOrderRequest();
            insert orderRequest;

            csord__Order__c order = ProductTestFactory.buildOrder('TestOrder', acc.Id, 'Active', orderRequest.Id);
            insert order;

            List<csord__Subscription__c> lstSubscription = new List<csord__Subscription__c>();

            csord__Subscription__c subscription = ProductTestFactory.buildSubscription('Test Subscription 1', acc.Id, order.Id, orderRequest.Id);
            lstSubscription.add(subscription);
            subscription = ProductTestFactory.buildSubscription('Test Subscription 2', acc.Id, order.Id, orderRequest.Id);
            lstSubscription.add(subscription);

            insert lstSubscription;

            List<csord__Service__c> lstServices = new List<csord__Service__c>();

            csord__Service__c service = ProductTestFactory.buildService('Test Service 1', order.Id, lstSubscription[0].id, orderRequest.Id);
            service.csordtelcoa__Product_Configuration__c = prodConfig.Id;
            service.SiteId__c = site.Id;
            service.Primary_Contact__c = lstContact[0].Id;
            service.Technical_Contact__c = lstContact[1].Id;
            service.After_Hours_Site_Contact__c = lstContact[2].Id;
            service.Project_Contact__c = lstContact[3].Id;
            service.Site_Delivery_Contact__c = lstContact[4].Id;
            service.Order_Primary_Contact__c=lstContact[5].Id;
            lstServices.add(service);

            service = ProductTestFactory.buildService('Test Service 2', order.Id, lstSubscription[0].id, orderRequest.Id);
            service.csordtelcoa__Product_Configuration__c = prodConfig.Id;
            service.SiteId__c = site.Id;
            service.Primary_Contact__c = lstContact[0].Id;
            service.Technical_Contact__c = lstContact[2].Id;
            service.After_Hours_Site_Contact__c = lstContact[3].Id;
            service.Project_Contact__c = lstContact[4].Id;
            service.Site_Delivery_Contact__c = lstContact[1].Id;
            service.Order_Primary_Contact__c=lstContact[5].Id;
            lstServices.add(service);

            service = ProductTestFactory.buildService('Test Service 3', order.Id, lstSubscription[1].id, orderRequest.Id);
            service.csordtelcoa__Product_Configuration__c = prodConfig.Id;
            service.SiteId__c = site.Id;
            service.Primary_Contact__c = lstContact[2].Id;
            service.Technical_Contact__c = lstContact[3].Id;
            service.After_Hours_Site_Contact__c = lstContact[4].Id;
            service.Project_Contact__c = lstContact[0].Id;
            service.Site_Delivery_Contact__c = lstContact[1].Id;
            service.Order_Primary_Contact__c=lstContact[5].Id;
            lstServices.add(service);

            service = ProductTestFactory.buildService('Test Service 4', order.Id, lstSubscription[1].id, orderRequest.Id);
            service.csordtelcoa__Product_Configuration__c = prodConfig.Id;
            service.SiteId__c = site.Id;
            service.Primary_Contact__c = lstContact[3].Id;
            service.Technical_Contact__c = lstContact[4].Id;
            service.After_Hours_Site_Contact__c = lstContact[0].Id;
            service.Project_Contact__c = lstContact[1].Id;
            service.Site_Delivery_Contact__c = lstContact[2].Id;
            service.Order_Primary_Contact__c=lstContact[5].Id;
            lstServices.add(service);

            insert lstServices;

            Functional_Contact_Role__c fcr = new Functional_Contact_Role__c();
            fcr.SiteID__c = site.Id;
            fcr.Role_Type__c = 'Site';
            fcr.Role__c = 'Project Contact';
            fcr.ContactID__c= lstContact[0].Id;
            insert fcr;


        }
    }
    static testmethod void testUpsertFunctionalContactRoleForSalesManagerEnterprise()
    {
        User usr = [select Id,UserName from User where UserName = 'standarduser@telestra.com'];
        System.runAs(usr)
        {
            Test.startTest();
            List<csord__Service__c> lstServices =[select Id from csord__Service__c];
            List<Id> lstServiceIds = new List<Id>();
            if(!lstServices.isEmpty())
            {
                for(csord__Service__c service : lstServices)
                {
                    lstServiceIds.add(service.Id);
                }
            }
            FunctionalContactRoleOperation.upsertFunctionalContactRole(lstServiceIds);
            Integer iRecordProcessed = [select count() from Functional_Contact_Role__c where Role_Type__c = 'Site'];
            System.assertEquals(5, iRecordProcessed);
            Test.stopTest();
        }
    }
    static testmethod void testUpsertFunctionalContactRoleForSalesEnterprise()
    {
        Profile pf = [select Id,Name from profile where name ='Sales - Enterprise'];
        User usr = [select Id,UserName from User where UserName = 'standarduser@telestra.com'];
        usr.ProfileId = pf.Id;
        update usr;
        System.runAs(usr)
        {
            Test.startTest();
            List<csord__Service__c> lstServices =[select Id from csord__Service__c];
            List<Id> lstServiceIds = new List<Id>();
            if(!lstServices.isEmpty())
            {
                for(csord__Service__c service : lstServices)
                {
                    lstServiceIds.add(service.Id);
                }
            }
            FunctionalContactRoleOperation.upsertFunctionalContactRole(lstServiceIds);
            Integer iRecordProcessed = [select count() from Functional_Contact_Role__c where Role_Type__c = 'Site'];
            System.assertEquals(5, iRecordProcessed);
            Test.stopTest();
        }
    }
}