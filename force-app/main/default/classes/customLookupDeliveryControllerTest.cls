@isTest
public class customLookupDeliveryControllerTest {
    
        @testsetup 
    static void testdata() {
        //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account');
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        System.assertNotEquals(null,acc);
       
        Account acc1  = new Account(Name = 'Test Sam');
        insert acc1;

        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
        
        insert opp;
        System.assertNotEquals(null,opp);
        
        Contact con = new Contact(LastName = 'Sam');
        con.AccountId=acc.id;
        insert con;
        
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = con.Id;
        ACR.AccountId = acc1.Id;
        ACR.Roles = 'Legal Lessee';
        insert ACR;
        
        //Create addresses
        List<cscrm__Address__c> lstAddress=new List<cscrm__Address__c>();
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '152365895123';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = acc.id;
        addrs.Address_Status__c='CONFIRMED';
        lstAddress.add(addrs);
        
        cscrm__Address__c addrs1 = new cscrm__Address__c();
        addrs1.Address_ID__c = '256345896231';
        addrs1.Name = 'Test Address 1';
        addrs1.cscrm__Account__c = acc.id;
        addrs1.Address_Status__c='CONFIRMED';
        lstAddress.add(addrs1);
        
        cscrm__Address__c addrs2 = new cscrm__Address__c();
        addrs2.Address_ID__c = '189562345874';
        addrs2.Name = 'Test Address 2';
        addrs2.cscrm__Account__c = acc.id;
        addrs2.Address_Status__c='CONFIRMED';
        lstAddress.add(addrs2);
        
        insert lstAddress;
 
    }
    
    @isTest
    static void fetchLookUpValues(){
        Account acc = [Select Id From Account where Name = 'Test Sam'];
        String keyWord = 'Test';
        Test.startTest();
        List <AccountContactRelation> returnedConId = customLookUpDeliveryController.fetchDeliveryContactLookUpValues(keyWord,acc.ID);
        List<cscrm__Address__c> addressList=customLookUpDeliveryController.fetchAddressLookUpValues(keyWord,acc.ID);
        List<cscrm__Address__c> addressList1=customLookUpDeliveryController.fetchAddressLookUpValues('',acc.ID);
        Test.stopTest();   
       System.assert(acc != null);
    }
     @isTest
    static void fetchLookUpValueselse(){
        Account acc = [Select Id From Account where Name = 'Test Sam'];
        Test.startTest();
        List<cscrm__Address__c> addressList1=customLookUpDeliveryController.fetchAddressLookUpValues('',acc.ID);
        Test.stopTest();   
       System.assert(addressList1!= null);
    }

}