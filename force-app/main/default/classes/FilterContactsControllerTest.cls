/*******************************************************************
@Class Name:FilterContactsControllerTest
@Description:Sprint 20.03 , P2OB-4620 ,Sprint 20.07 :P2OB-6382
@Author:SFO Team (Sravanthi)
@Comments:This class is test class for FilterContactsController.
@Last Modified        : 07/01/2020 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772  updating API version to 50.
                        21.05 FDR fix . contacts retreival from ACR while asserting. same as main class.
*********************************************************************/
@isTest
public with sharing class FilterContactsControllerTest {
    @testSetup
    static void setup()
    {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; //EDGE-85331 :: =:'Sales - Enterprise'];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        List<user> userList = new List<user>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com');
        User admin = new User(alias = 'standt',email='adminuser@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pfAdmin.id,
                              timezonesidkey='Australia/Sydney',userroleid=r.id,
                              username='TestingAdmin@TestingAdmin.com');
        userList.add(sales);
        userList.add(admin);
        insert userList;
        System.runAs(admin){
            //Sprint 20.07 :P2OB-6382
            list<Account> acclist =new list<Account>();
            for(integer a=0;a<2;a++){
                Account customerAccount=TestUtil.createAccount('Testacc'+a);
                customerAccount.OwnerId=sales.id;
                acclist.add(customerAccount);
       }
            insert acclist;
            
            list<Contact> conlist =new list<Contact>();
            for(integer i=0;i<10;i++){
                Contact con1 = TestUtil.createContact(acclist[0].id,'First'+i,'Last'+i);
                con1.OwnerId=sales.id;
                conlist.add(con1);
       }
            conlist[0].Telstra_Connect_Status__c=System.Label.Telstra_Connect_Status_Registered_Active;
            conlist[1].Telstra_Connect_Status__c=System.Label.Telstra_Connect_Status_Registered_Not_Active;
            insert conlist;
         //Sprint 20.07 :P2OB-6382, creating acr to view secondary contacts in account related list    
             list<AccountContactRelation> ACRlist =new list<AccountContactRelation>();
             for(Contact currentContact : conlist){
               AccountContactRelation ACR=new AccountContactRelation(Accountid=acclist[1].id,Contactid=currentContact.id, roles = System.Label.Contact_Limited_Authority_Value);
                ACRlist.add(ACR);
            }
            insert ACRlist;
            
            //EDGE-51592
            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            Contact con = new Contact(LastName ='testCon',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert con; 
            Profile prmProfile = [select id from profile where name ='PRM Community User - Australia'];
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{prmProfile} ,new List<Contact>{con} ,false);
            insert partnerUser;
            
            Account[] enterpriseAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : enterpriseAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert enterpriseAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),enterpriseAccount.get(0).Id);
          
            insert customerContacts;
            for(contact cont:customerContacts){
                cont.Authority__c = 'Full Authority';
                cont.Contact_Status__c = 'Active';
                cont.MobilePhone = '+61123456789';
            }
            update customerContacts;
            
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=enterpriseAccount.get(0).Id, 
                                                                Partner__c=acc[0].Id,Partner_Signatories__c= con.Id,Status__c='Active',Customer_Signatories__c= customerContacts.get(0).Id); 
            insert POR;
            
         
        }
    }
    /*
    @Method Name: secondaryACRContact
    @Description:Sprint 20.07 :P2OB-6382,I should see all of the related contacts on my account and not just the PRIMARY account contact.
    @Author:SFO Team (Sravanthi)
    */ 
    @isTest
    static void secondaryACRContact(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Account Acc1 =[SELECT id FROM Account Where Name='testAcc1'];
        acc1.OwnerId=sales.id;
        update acc1;
        Test.startTest();
        System.runAs(sales){
            Account customerAccount1 =[SELECT id FROM Account Where Name='testAcc1'];
            List<AccountContactRelation> ACRlist =[SELECT id FROM AccountContactRelation WHERE Accountid =:customerAccount1.id];
            
            FilterContactsController.dataAndColumns response1 = new FilterContactsController.dataAndColumns();
            response1=FilterContactsController.getDataAndColumns(customerAccount1.id,'Active',False,TRUE,null);
            system.assertEquals(ACRlist.size(),response1.lstTableData.size());
        }
        Test.stopTest();
    }
    /*
    @Method Name: filterContactsControllerActiveConUnitTest
    @Description:Sprint 20.03 , P2OB-4620,Test for view all and actice contacts.
    @Author:SFO Team (Sravanthi)
    @updated : 21.05 FDR fix . contacts retreival from ACR while asserting. same as main class.
    */
    @isTest
    static void filterContactsControllerActiveConUnitTest(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Account acc =[SELECT id FROM Account LIMIT 1];
        acc.OwnerId=sales.id;
        update acc;
        Set<Id> contactIdList = new Set<Id>();
        Test.startTest();
        System.runAs(sales){
            Account customerAccount =[SELECT id FROM Account LIMIT 1];
            for(AccountContactRelation acrRec : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: customerAccount.id]){
                contactIdList.add(acrRec.ContactId);
            }
            List<Contact> conlist =[SELECT id FROM Contact WHERE id in :contactIdList AND Contact_Status__c = :System.Label.Contact_Active_Status];
            FilterContactsController.dataAndColumns response = new FilterContactsController.dataAndColumns();
            response=FilterContactsController.getDataAndColumns(customerAccount.id,'Active',False,TRUE,null);
            system.assertEquals(conlist.size(),response.lstTableData.size());
        }
        Test.stopTest();
    }  
    
    /*
    @Method Name: filterContactsControllerInactiveConUnitTest
    @Description:Sprint 20.03 , P2OB-4620,Test for view all and Inactice contacts.
    @Author:SFO Team (Sravanthi)
    @updated : 21.05 FDR fix . contacts retreival from ACR while asserting. same as main class.
    */
    @isTest
    static void filterContactsControllerInactiveConUnitTest(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Account acc =[SELECT id FROM Account LIMIT 1];
        acc.OwnerId=sales.id;
        update acc;
        Set<Id> contactIdList = new Set<Id>();
        Test.startTest();
        System.runAs(sales){
            Account customerAccount =[SELECT id FROM Account LIMIT 1];
            for(AccountContactRelation acrRec : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: customerAccount.id]){
                contactIdList.add(acrRec.ContactId);
            }
            List<Contact> conlist =[SELECT id FROM Contact WHERE id in :contactIdList AND Contact_Status__c != :System.Label.Contact_Active_Status];
            FilterContactsController.dataAndColumns response = new FilterContactsController.dataAndColumns();
            response=FilterContactsController.getDataAndColumns(customerAccount.id,'Inactive',False,TRUE,null);
            system.assertEquals(conlist.size(),response.lstTableData.size());
        }
        Test.stopTest();
    }
    /*
    @Method Name: filterContactsControllerAllConUnitTest
    @Description:Sprint 20.03 , P2OB-4620,P2OB-4620,Test All contacts initial load only 5.
    @Author:SFO Team (Sravanthi)
    @updated : 21.05 FDR fix . contacts retreival from ACR while asserting. same as main class.
    */
    @isTest
    static void filterContactsControllerAllConUnitTest(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Account acc =[SELECT id FROM Account WHERE Name = 'Testacc0' LIMIT 1];
        acc.OwnerId=sales.id;
        update acc;
        Set<Id> contactIdList = new Set<Id>();
        Test.startTest();
        System.runAs(sales){
            Account customerAccount =[SELECT id FROM Account LIMIT 1];
            for(AccountContactRelation acrRec : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: customerAccount.id]){
                contactIdList.add(acrRec.ContactId);
            }
            List<Contact> conlist =[SELECT id FROM Contact WHERE id in :contactIdList LIMIT 5];
            FilterContactsController.dataAndColumns response = new FilterContactsController.dataAndColumns();
            response=FilterContactsController.getDataAndColumns(customerAccount.id,'All',True,TRUE,null);
            system.assertEquals(conlist.size(),response.lstTableData.size());
        }
        Test.stopTest();
    }
    /*
    @Method Name: filterContactsControllerUpdateUnitTest
    @Description:Sprint 20.03 , P2OB-4620,Tests for contact update .
    @Author:SFO Team (Sravanthi)
    */ 
    @isTest
    static void filterContactsControllerUpdateUnitTest(){
        Test.startTest();
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        try{
            System.runAs(sales){
                List<Contact> conlist =[SELECT id FROM Contact ];
                FilterContactsController.updateContacts(conlist);
            }
        }
        Catch(Exception e){
            system.assertEquals(true, e.getMessage()!=null);
        }
        Test.stopTest();
    }
    /*
    @Method Name: filterContactsControllerUpdateFailUnitTest
    @Description:Sprint 20.03 , P2OB-4620,Tests for contact update .
    @Author:SFO Team (Sravanthi)
    */
    @isTest
    static void filterContactsControllerUpdateFailUnitTest(){
        Test.startTest();
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        try{
            System.runAs(sales){
                List<Contact> conlist =[SELECT id FROM Contact];
                for(integer i=0;i<conlist.size();i++){
                ConList[i].FirstName='';
                }
                FilterContactsController.updateContacts(conlist);
            }
        }
        Catch(Exception e){
            system.assertEquals(true, e.getMessage()!=null);
        }
        Test.stopTest();
    }
    
    @isTest
    static void filterContactsControllerGetListViwe(){
       Test.startTest();
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        System.runAs(sales){
            ListView accListview = FilterContactsController.getListViews('Account',System.Label.AccountListViewRelatedContacts);
            system.assertEquals([SELECT Id, Name FROM ListView WHERE SobjectType = 'Account'  and DeveloperName = :System.Label.AccountListViewRelatedContacts LIMIT 1], accListview);
        }
       Test.stopTest();
    }
    @isTest
    static void filterContactsControllerCheckcreateConaccess(){
        User partnerUser = [Select id,IsActive from user where email ='test@noemail45345555.com0' and IsActive =true Limit 1 ];
         System.runAs(partnerUser){
            Account customerAccount=[select id from Account limit 1];
            FilterContactsController.dataAndColumns response = new FilterContactsController.dataAndColumns();
            response=FilterContactsController.getDataAndColumns(customerAccount.id,'All',True,TRUE,null);
             system.assertEquals(false,response.createConaccess);
         }
    }
    
    
    /*
    @Method Name: filterContactsControllerTelstraConUnitTest
    @Description:SFO 21.04 :P2OB-12577
    @Author:SFO Team (Sravanthi)
    */
    @isTest
    static void filterContactsControllerTelstraConUnitTest(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Account acc =[SELECT id FROM Account WHERE Name = 'Testacc0' LIMIT 1];
        acc.OwnerId=sales.id;
        update acc;
        Test.startTest();
        System.runAs(sales){
            Account customerAccount =[SELECT id FROM Account LIMIT 1];
            List<Contact> conlist =[SELECT id FROM Contact ];
            FilterContactsController.dataAndColumns response = new FilterContactsController.dataAndColumns();
            response=FilterContactsController.getDataAndColumns(customerAccount.id,'RegisteredActive',True,TRUE,null);
            system.assertEquals(1,response.lstTableData.size());
        }
        Test.stopTest();
    }
    /*
    @Method Name: filterContactsControllerTelstraConNotActiveUnitTest
    @Description:SFO 21.04 :P2OB-12577
    @Author:SFO Team (Sravanthi)
    */
    @isTest
    static void filterContactsControllerTelstraConNotActiveUnitTest(){
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        Account acc =[SELECT id FROM Account WHERE Name = 'Testacc0' LIMIT 1];
        acc.OwnerId=sales.id;
        update acc;
        Test.startTest();
        System.runAs(sales){
            Account customerAccount =[SELECT id FROM Account LIMIT 1];
            List<Contact> conlist =[SELECT id FROM Contact ];
            FilterContactsController.dataAndColumns response = new FilterContactsController.dataAndColumns();
            response=FilterContactsController.getDataAndColumns(customerAccount.id,'RegisteredNotActive',True,TRUE,null);
            system.assertEquals(1,response.lstTableData.size());
        }
        Test.stopTest();
    }
}