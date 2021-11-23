/////22/5/2020 EDGE-142085 added by shubhi/Aman

//// 16/6/2020 Qa1 test failure

@isTest
public class AccountTestFactory {
    public static cscrm__Address__c buildAddress(String addressId) {
        cscrm__Address__c address = new cscrm__Address__c();
        address.Address_ID__c = addressId;
        address.cscrm__Street__c  = '150 TEST ROAD TEST';
        return address;
    }
    public static cscrm__Address__c buildAddressFull(String addressId) {
        cscrm__Address__c address = new cscrm__Address__c();
        address.Address_ID__c = addressId;
        address.Address_Line_1__c = '123';
        address.Address_Line_2__c = '456';
        address.Address_Line_3__c = '789';
        address.Address_Status__c = '012';
        address.Locality__c = 'abc';
        address.cscrm__Plan_Number__c = 'def';
        address.cscrm__State_Province__c = 'hij';
        address.cscrm__Street_Name__c = 'klm';  
        address.streetNumberEndSuffix__c = 'nop';
        address.streetNumberStartSuffix__c = 'qrs';
        address.TCM_Street_Type_code__c = 'tuv';
        address.streetTypeSuffix__c = 'w';
        address.cscrm__Zip_Postal_Code__c = '151001';
        //address.Name = 'Aakil Bhardwaj 151001 Bathinda Punjab Patiala Amritsar Mansa';
        address.cscrm__Street__c  = '150 TEST ROAD TEST';
        return address;
    }
    public static cscrm__Site__c  buildSite(Id addressRef, Id accountRef) {
        cscrm__Site__c  site = new cscrm__Site__c();
        site.cscrm__Floor__c = 'L-T';
        site.cscrm__Installation_Address__c = addressRef;
        site.cscrm__Account__c = accountRef;
        return site;
    }
    public static Account buildAccount(String name) {
        Account acc = new Account();
        acc.name = name;
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        return acc;
    }
    public static Contact buildContact(Account acc, String name) {
        Contact cnt = new Contact();
        cnt.AccountId = acc.id;
        cnt.LastName = name;
        cnt.Title = name;
        //cnt.Phone = '+61322132343';
        cnt.Email = 'test@test.com';
        cnt.Pref_Comm_Method__c = 'Phone';
        cnt.Phone='0456789076';
        cnt.Contact_Status__c = 'Active';
        cnt.Salutation = 'Mr.';
        cnt.FirstName = name;
        cnt.Birthdate = Date.newInstance(1980, 1, 1);

        cnt.Authority__c ='Full Authority'; //EDGE-142085 // updated for qa1 test failures

        return cnt;
    }
    public static Contact buildContact(Account acc, String name, String email) {
        Contact cnt = buildContact(acc, name);
        cnt.email = email;
        return cnt;
    }
}