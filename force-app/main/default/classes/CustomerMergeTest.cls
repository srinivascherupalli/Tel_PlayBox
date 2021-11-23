@isTest
public class CustomerMergeTest {
      @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', 'http://mocksandbox.getsandbox.com/MockService');
          
        Merge_Settings__c record = Merge_Settings__c.getInstance('AccountMerge');
        if(record == null) {
            record = new Merge_Settings__c(name = 'AccountMerge' ,Object_Type__c = 'ACCOUNT', Process_Window_End__c ='24:00:00', Process_Window_Start__c ='00:00:00',Type__c ='Account');
        }
        
        //record.Value__c = value;
        upsert record;
          
    }
	
    static testmethod void testPositiveMergedata(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        List<Account> acctLst = new List<Account>();
        for(Integer i=0;i<4;i++){
            Account a = TestUtil.createAccount('TestAcct' +accountlist.get(i));
            a.TCM_Merge_Status__c = 'Pending';
            a.CIDN__c = '12345'+i;
            a.Customer_ID__c = '712345678'+i;
            a.Pref_Comm_Method__c= 'Email';
            a.Email__c='abc@test.com';
            a.Customer_Status__c= 'Active';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='041235432'+i;
            a.Fax='12349';
            
            
            acctLst.add(a);
        }       
        insert acctLst;

        Map<id,List<Contact>> accToContactMap = new Map<id,List<Contact>>();
        integer count =0;
		Contact c = TestUtil.createContact(acctLst[0].id,'sham', 'ray');
        c.UUID__c = '23456'+count;
        c.Birthdate=Date.newInstance(2000, 2, 17);
        c.Merge_Lock__c=false;
        c.Salutation='Mr.';

        insert c;
		
        Contact c1 = TestUtil.createContact(acctLst[1].id,'nikita', 'tiwari');
        c1.UUID__c = '23456'+count;
        c1.Birthdate=Date.newInstance(1988, 2, 17);
        c1.Merge_Lock__c=false;
        c1.Salutation='Mr.';

        insert c1;
		
		Contact c2 = TestUtil.createContact(acctLst[2].id,'swapna', 'deshapnde');
        c2.UUID__c = '23456'+count;
        c2.Birthdate=Date.newInstance(1986, 2, 17);
        c2.Merge_Lock__c=false;
        c2.Salutation='Mr.';

        insert c2;
        List<Merge_Request__c> mergeList = new List<Merge_Request__c>();

        Merge_Request__c mr =  new Merge_Request__c();
        mr.Status__c = 'PENDING';
        mr.Type__c = 'ACCOUNT';
        mr.Target_Id__c = '123450';
        mr.Source_Id__c = ' 123451';
        mergeList.add(mr);
        
        
        Merge_Request__c mr1 =  new Merge_Request__c();
        mr1.Status__c = 'PENDING';
        mr1.Type__c = 'ACCOUNT';
        mr1.Target_Id__c = '123453';
        mr1.Source_Id__c = '123455';
        mergeList.add(mr1);
        
       Merge_Request__c mr3 =  new Merge_Request__c();
        mr3.Status__c = 'PENDING';
        mr3.Type__c = 'ACCOUNT';
        mr3.Target_Id__c = '7100000837';
        mr3.Source_Id__c = '123453';
        mergeList.add(mr3);
        
        Merge_Request__c mr4 =  new Merge_Request__c();
        mr4.Status__c = 'PENDING';
        mr4.Type__c = 'ACCOUNT';
        mr4.Target_Id__c = '8877274928';
        mr4.Source_Id__c = '123454';
        mergeList.add(mr4);
        
        insert mergeList;
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
    }
    
    static testmethod void testTechicalErrorMessage(){
        Test.startTest();
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/4840371988');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        
            Account a = TestUtil.createAccount('TestAcct' +accountlist.get(1));
            a.TCM_Merge_Status__c = 'Pending';
            a.CIDN__c = '123450';
            a.Customer_ID__c = '7123456780';
            a.Pref_Comm_Method__c= 'Email';
            a.Email__c='abc@test.com';
            a.Customer_Status__c= 'Active';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='0412354320';
            a.Fax='12349';
			insert a;

        integer count =0;
		Contact c = TestUtil.createContact(a.id,'sham', 'ray');
        c.UUID__c = '23456'+count;
        c.Birthdate=Date.newInstance(2000, 2, 17);
        c.Merge_Lock__c=false;
        c.Salutation='Mr.';

        insert c;
		
       
        List<Merge_Request__c> mergeList = new List<Merge_Request__c>();
		Merge_Request__c mr3 =  new Merge_Request__c();
        mr3.Status__c = 'PENDING';
        mr3.Type__c = 'ACCOUNT';
        mr3.Target_Id__c = '7100000837';
        mr3.Source_Id__c = '123450';
        mergeList.add(mr3);
       
        insert mergeList;
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
    }
    
    static testmethod void testFucntionalErrorMessage(){
        Test.startTest();
		EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/4840371999');
		Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        
            Account a = TestUtil.createAccount('TestAcct' +accountlist.get(1));
            a.TCM_Merge_Status__c = 'Pending';
            a.CIDN__c = '123450';
            a.Customer_ID__c = '7123456780';
            a.Pref_Comm_Method__c= 'Email';
            a.Email__c='abc@test.com';
            a.Customer_Status__c= 'Active';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='0412354320';
            a.Fax='12349';
			insert a;

        integer count =0;
		Contact c = TestUtil.createContact(a.id,'sham', 'ray');
        c.UUID__c = '23456'+count;
        c.Birthdate=Date.newInstance(2000, 2, 17);
        c.Merge_Lock__c=false;
        c.Salutation='Mr.';

        insert c;
		
       
        List<Merge_Request__c> mergeList = new List<Merge_Request__c>();
		Merge_Request__c mr3 =  new Merge_Request__c();
        mr3.Status__c = 'PENDING';
        mr3.Type__c = 'ACCOUNT';
        mr3.Target_Id__c = '7100000837';
        mr3.Source_Id__c = '123450';
        mergeList.add(mr3);
       
        insert mergeList;
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
    }
    
  	static testmethod void testNegativeMergeData(){
        Test.startTest();
		EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/4840371888');
		Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        
            Account a = TestUtil.createAccount('TestAcct' +accountlist.get(1));
            a.TCM_Merge_Status__c = 'Pending';
            a.CIDN__c = '123450';
            a.Customer_ID__c = '7123456780';
            a.Pref_Comm_Method__c= 'Email';
            a.Email__c='abc@test.com';
            a.Customer_Status__c= 'Active';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='0412354320';
            a.Fax='12349';
			insert a;

        integer count =0;
		Contact c = TestUtil.createContact(a.id,'sham', 'ray');
        c.UUID__c = '23456'+count;
        c.Birthdate=Date.newInstance(2000, 2, 17);
        c.Merge_Lock__c=false;
        c.Salutation='Mr.';

        insert c;
		
       
        List<Merge_Request__c> mergeList = new List<Merge_Request__c>();
		Merge_Request__c mr3 =  new Merge_Request__c();
        mr3.Status__c = 'PENDING';
        mr3.Type__c = 'ACCOUNT';
        mr3.Target_Id__c = '7100000837';
        mr3.Source_Id__c = '123450';
        mergeList.add(mr3);
       
        insert mergeList;
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
    }
    
    static testmethod void testLockRecords(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
         map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        List<Account> acctLst = new List<Account>();
        for(Integer i=0;i<2;i++){
            Account a = TestUtil.createAccount('TestAcct'+accountlist.get(i));
            a.CIDN__c = '12345'+i;
            a.Customer_ID__c = '712345678'+i;
            a.Pref_Comm_Method__c= 'Email';
            a.Email__c='abc@test.com';
            a.Customer_Status__c= 'Active';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='041235432'+i;
            a.Fax='12349';
            a.Merge_Lock__c = false;
            acctLst.add(a);
        }       
        insert acctLst;

        Map<id,List<Contact>> accToContactMap = new Map<id,List<Contact>>();
        integer count =0;
		Contact c = TestUtil.createContact(acctLst[0].id,'sham', 'ray');
        c.UUID__c = '23456'+count;
        c.Birthdate=Date.newInstance(2000, 2, 17);
        c.Merge_Lock__c=false;
        c.Salutation='Mr.';

        insert c;
		
        List<Merge_Request__c> mergeList = new List<Merge_Request__c>();

        Merge_Request__c mr =  new Merge_Request__c();
        mr.Status__c = 'PENDING';
        mr.Type__c = 'ACCOUNT';
        mr.Target_Id__c = '123450';
        mr.Source_Id__c = ' 123451';
        mergeList.add(mr);
       
        
        insert mergeList;
        
        CustomerMerge custm = new CustomerMerge();
        custm.lockRecords(new List<Merge_Request__c>{mr});
        system.assert(custm !=null);
        Test.stopTest();
    }
    
    static testmethod void testMergeBatchAccount(){
        Test.startTest();
        MergeRecordBatch batch  =  new MergeRecordBatch(MergeRecordFactory.type.ACCOUNT);
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
        
    }
    
    static testmethod void testPendingRecord(){
        Test.startTest();
        MergeRecordBatch batch  =  new MergeRecordBatch(MergeRecordFactory.type.ACCOUNT, 'Pending');
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
        
    }
    // added below test class for Account Merge Issue P2OB-13763
    static testmethod void testPositiveMergedata1(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        List<Account> acctLst = new List<Account>();
        Account ultimateParentAccount = TestUtil.createAccount('ultimateParentAccount');
        ultimateParentAccount.Customer_Status__c= 'Active';
        ultimateParentAccount.CIDN__c= '987654321';
        acctLst.add(ultimateParentAccount);
        for(Integer i=0;i<4;i++){
            Account a = TestUtil.createAccount('TestAcct' +accountlist.get(i));
            a.TCM_Merge_Status__c = 'Pending';
            a.CIDN__c = '12345'+i;
            a.Ultimate_Parent_CIDN__c = ultimateParentAccount.CIDN__c;
            a.Customer_ID__c = '712345678'+i;
            a.Pref_Comm_Method__c= 'Email';
            a.Email__c='abc@test.com';
            a.Customer_Status__c= 'Active';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='041235432'+i;
            a.Fax='12349';
            
            
            acctLst.add(a);
        }       
        insert acctLst;

        Map<id,List<Contact>> accToContactMap = new Map<id,List<Contact>>();
        integer count =0;
		Contact c = TestUtil.createContact(acctLst[0].id,'sham', 'ray');
        c.UUID__c = '23456'+count;
        c.Birthdate=Date.newInstance(2000, 2, 17);
        c.Merge_Lock__c=false;
        c.Salutation='Mr.';

        insert c;
		
        Contact c1 = TestUtil.createContact(acctLst[1].id,'nikita', 'tiwari');
        c1.UUID__c = '23456'+count;
        c1.Birthdate=Date.newInstance(1988, 2, 17);
        c1.Merge_Lock__c=false;
        c1.Salutation='Mr.';
		
        insert c1;
		// Source(123451) Indirect , Target(123450) Direct
		c1.AccountId = acctLst[0].id;
		update c1;
		
		Contact c2 = TestUtil.createContact(acctLst[2].id,'swapna', 'deshapnde');
        c2.UUID__c = '23456'+count;
        c2.Birthdate=Date.newInstance(1986, 2, 17);
        c2.Merge_Lock__c=false;
        c2.Salutation='Mr.';

        insert c2;
		
		Contact c3 = TestUtil.createContact(acctLst[3].id,'swapna2', 'deshapnde2');
        c3.UUID__c = '23456'+count;
        c3.Birthdate=Date.newInstance(1986, 2, 17);
        c3.Merge_Lock__c=false;
        c3.Salutation='Mr.';

        insert c3;
		
		// Source(123453) Direct , Target(123452) Indirect 
		c3.AccountId = acctLst[2].id;
		update c3;
		c3.AccountId = acctLst[3].id;
		update c3;
		
		
        List<Merge_Request__c> mergeList = new List<Merge_Request__c>();

        Merge_Request__c mr =  new Merge_Request__c();
        mr.Status__c = 'PENDING';
        mr.Type__c = 'ACCOUNT';
        mr.Target_Id__c = '123450';
        mr.Source_Id__c = ' 123451';
        mergeList.add(mr);
        
        
        Merge_Request__c mr1 =  new Merge_Request__c();
        mr1.Status__c = 'PENDING';
        mr1.Type__c = 'ACCOUNT';
        mr1.Target_Id__c = '123452';
        mr1.Source_Id__c = '123453';
        mergeList.add(mr1);
        
        
        insert mergeList;
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        ID batchprocessid = Database.executeBatch(batch);
        System.assert(batchprocessid !=null);
        Test.stopTest();
    }
    //End  Account Merge Issue P2OB-13763
}