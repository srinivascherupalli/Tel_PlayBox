@isTest
public class SQButtonContentHandlerTest {
    @testSetup static void setup() {

        Account acc = AccountTestFactory.buildAccount('Test Acc') ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c = '1234567891';
        acc.ABN__c = '1235';
        insert acc;

        List <Contact> listCon = new List <Contact>();

        for (Integer i = 0 ; i < 10 ; i++) {
            String contactName = 'contact' + i;
            Contact contact = AccountTestFactory.buildContact(acc, contactName);
            listCon.add(contact);
        }
        insert listCon;

        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        Integer addID = 161152457;
        for (Integer i = 0 ; i < 10 ; i++) {
            cscrm__Address__c address = AccountTestFactory.buildAddressFull(String.valueOf(addID));
            addID++;
            lstAddress.add(address);
        }
        insert lstAddress;

        List <Billing_Account__c> listBillAC = new List <Billing_Account__c> ();

        Billing_Account__c billingAccount = new Billing_Account__c();
        billingAccount.Billing_Account_Number__c = '1234567322';
        billingAccount.Billing_Address__c = lstAddress[0].id;
        billingAccount.Billing_Account_Owner__c = listCon[0].Id;
        billingAccount.Account__c = acc.Id;
        listBillAC.add(billingAccount);

        List<cscrm__Site__c> lstSite = new List<cscrm__Site__c>();
        for (cscrm__Address__c address : lstAddress) {
            cscrm__Site__c  site = new cscrm__Site__c();
            site.cscrm__Floor__c = 'L-T' + address.Address_ID__c;
            site.cscrm__Installation_Address__c = address.id;
            site.cscrm__Account__c = acc.id;
            site.Primary_Contact__c = listCon[0].id;
            site.Secondary_Contact__c = listCon[1].id;
            lstSite.add(site);
        }
        insert lstSite;

        List <Service_Qualification__c> listservSq = new List <Service_Qualification__c> ();
        for (cscrm__Site__c site : lstSite) {
            Service_Qualification__c serviceSQ = new Service_Qualification__c();
            serviceSQ.Site__c = site.Id;
            listservSq.add(serviceSQ);
        }
        insert listservSq;
    }

    @isTest
    public static void callSQService_Success() {
        String addressList = '161152457';
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        String accId = acc.Id;
        Test.setMock(HttpCalloutMock.class, new MockSQcheckCalloutResponse('success_Search'));
        Test.setCurrentPageReference(new PageReference('Page.SQButtonContent'));
        System.currentPageReference().getParameters().put('adborId', addressList);
        System.currentPageReference().getParameters().put('accountId', accId);
        SQButtonContentHandler sqClass = new SQButtonContentHandler();
        sqClass.callSQService();
        System.assertNotEquals(acc, null);
        Test.stopTest();
    }
}