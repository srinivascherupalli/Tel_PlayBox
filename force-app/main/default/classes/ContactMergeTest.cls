@istest
public class ContactMergeTest {
    
    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com:443/org006/qa/v3/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/qa/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', '2yW2V7byaft2XJZ6');
        
        Merge_Settings__c record = Merge_Settings__c.getInstance('ContactMerge');
        if(record == null) {
            record = new Merge_Settings__c(name = 'ContactMerge' ,Object_Type__c = 'CONTACT', Process_Window_End__c ='24:00:00', Process_Window_Start__c ='00:00:00',Type__c ='Contact');
        }
        
        //record.Value__c = value;
        upsert record;
        
        
    }
    
    static testmethod void testdata()
    {
         EnvironmentVariable.put('tcm_access_token', '1234');
         EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/4840371999');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com:443/org006/qa/v3/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/qa/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', '2yW2V7byaft2XJZ6');
        
       
		 Merge_Settings__c record = Merge_Settings__c.getInstance('ContactMerge');
        if(record == null) {
            record = new Merge_Settings__c(name = 'ContactMerge' ,Object_Type__c = 'CONTACT', Process_Window_End__c ='24:00:00', Process_Window_Start__c ='00:00:00',Type__c ='Contact');
        }
        
        //record.Value__c = value;
        upsert record;
    }
    
  
    static testmethod void testcontactmerge(){
        
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Something');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
        Account b = TestUtil.createAccount('test');
        b.Account_UUID__c = '12345';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='1234546';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;
        
        
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shankkky', 'Raja');
        source.Birthdate=Date.newInstance(2001, 2, 17);
                                source.Salutation='Mrs.';
                                source.Merge_Lock__c=false;
                                
        source.UUID__c='906361';
        
        Contact invalid=TestUtil.createContact(a.id,'Shanees', 'Rayas');
        invalid.Birthdate=Date.newInstance(2002, 3, 17);
        invalid.UUID__c='0030l000002f90m';
         invalid.Merge_Lock__c=false;
        invalid.Salutation='Mr.';
        
        Contact target=TestUtil.createContact(a.id,'Nishaash', 'abcwwe');
        target.UUID__c='2345678';
        target.Birthdate=Date.newInstance(2003, 4, 18);
         target.Merge_Lock__c=false;
        target.Salutation='Mr.';
                                
        Contact target2=TestUtil.createContact(a.id,'Ramush', 'cdaee');
        target2.Birthdate=Date.newInstance(2004, 5, 12);
        target2.Merge_Lock__c=false;
        target2.UUID__c='123';
         
        target2.Salutation='Mr.';
                                
        Contact validsrc=TestUtil.createContact(a.id,'sreyc', 'Raysea');
        validsrc.Birthdate=Date.newInstance(2000, 4, 25);
        validsrc.UUID__c='9563';
        validsrc.Merge_Lock__c=false;
        validsrc.Salutation='Mr.';
                                       
                                
        Contact target3=TestUtil.createContact(a.id,'siraj', 'ffdcs');
		target3.Birthdate=Date.newInstance(2000, 6, 22);
		target3.Merge_Lock__c=false;
		target3.UUID__c='789456';
		target3.Salutation='Mr.';
                                
       
        conList.add(source);
        conList.add(target);
        conList.add(invalid);
        conList.add(target2);
        conList.add(validsrc);
        conList.add(target3);
        insert conList;
        
        cscrm__Site__c srcsite=TestUtil.createSite(validsrc.Id, target2.Id, a.id);
        insert srcsite;
        
        //validsrc.sites__r=srcsite;
        
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
   		Merge_Request__c rqst2=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='0030l000002f90m',Source_Id__c='123',status__c='PENDING');
        Merge_Request__c rqst3=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='129B6D37-B5EC-43f9-8709-4F5FC4CBE394',Source_Id__c='7894567',status__c='PENDING');
        merList.add(validrqst);
       // merList.add(rqst);
        merList.add(rqst2);
        merList.add(rqst3);
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(1, [select count() from contact where UUID__c='789456']);
        Test.stopTest();
        
    }
        static testmethod void testexecutemergevalidcases(){
        
             
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Something');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
            
         Account b = TestUtil.createAccount('test');
        b.Account_UUID__c = '12345';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='1234546';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;    
        
        
        
        List<Contact> conList=new  List<Contact>();
       
                                
        Contact target2=TestUtil.createContact(a.id,'Target', 'abc');
        target2.Birthdate=Date.newInstance(2000, 2, 17);
        target2.Merge_Lock__c=false;
        target2.UUID__c='123';
         
        target2.Salutation='Mr.';
             
                                
        Contact validsrc=TestUtil.createContact(b.id,'sreyc', 'Rayaa');
        validsrc.Birthdate=Date.newInstance(2000, 2, 17);
        validsrc.UUID__c='9563';
        validsrc.Merge_Lock__c=false;
        validsrc.Salutation='Mr.';
                               
                                
                                
        //Contact target3=TestUtil.createContact(a.id,'Targetc', 'abcc');
        target2.Birthdate=Date.newInstance(2000, 2, 17);
        target2.Merge_Lock__c=false;
        target2.UUID__c='789456';
         
        target2.Salutation='Mr.';
                                
       
        //conList.add(source);
        //conList.add(target);
        //conList.add(invalid);
        conList.add(target2);
        conList.add(validsrc);
       // conList.add(target3);
        insert conList;
        
        /*cscrm__Site__c srcsite=TestUtil.createSite(validsrc.Id, target2.Id, a.id);
        insert srcsite;*/
        
        //validsrc.sites__r=srcsite;
        
        
     	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
   		
        merList.add(validrqst);
       // merList.add(rqst);
        
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(1, [select count() from contact where UUID__c='789456']);
        Test.stopTest();
        
  
        
    }

     static testmethod void testexecutemergevalidsitecases(){
        
             
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Something');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
            
        Account b = TestUtil.createAccount('test');
        b.Account_UUID__c = '12345';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='1234546';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;    
        
        
        
        List<Contact> conList=new  List<Contact>();
       
                                
        Contact target2=TestUtil.createContact(b.id,'Target', 'abc');
        target2.Birthdate=Date.newInstance(2000, 2, 17);
        target2.Merge_Lock__c=false;
        target2.UUID__c='123';
         
        target2.Salutation='Mr.';
                                
        Contact validsrc=TestUtil.createContact(a.id,'sreyc', 'Rayaa');
        validsrc.Birthdate=Date.newInstance(2000, 2, 17);
        validsrc.UUID__c='9563';
        validsrc.Merge_Lock__c=false;
        validsrc.Salutation='Mr.';
         
                                
                                
                                
        //Contact target3=TestUtil.createContact(a.id,'Targetc', 'abcc');
        target2.Birthdate=Date.newInstance(2000, 2, 17);
        target2.Merge_Lock__c=false;
        target2.UUID__c='789456';
         
         
        //target2.Sites__r
        //target2.Salutation='Mr.';
                                
       
        //conList.add(source);
        //conList.add(target);
        //conList.add(invalid);
       
        
       
        //validsrc.sites__r=srcsite;
        
        conList.add(target2);
        conList.add(validsrc);
       
        insert conList;
        cscrm__Site__c site= TestUtil.createSite(validsrc.id, null, a.id);
        //site.cscrm__Installation_Address__c='a4O5D0000008OUrUAM';
        insert site;
        system.debug('testsite1++'+site);
        cscrm__Site__c site2= TestUtil.createSite(target2.id, null, b.id);
        //site2.cscrm__Installation_Address__c='a4O5D0000008OUrUAM';
        insert site2;
        system.debug('testsite2++'+site2);
        validsrc.sites__r.add(site);
        target2.sites__r.add(site2) ;
        conList.clear();
        conList.add(validsrc);
        conList.add(target2);
        update conlist;
            
        Contact con = [SELECT id ,Merge_Status__c,UUID__c,ReferenceMessage__c,(Select id, EndDate,ContactId, IsDirect,AccountId,Contact_Type__c,Contact_Usage__c,InActive__c,Relationship_End_Date__c from AccountContactRelations),  (Select Id,Secondary_Contact__c,cscrm__Account__c,cscrm__Installation_Address__c From Sites__r) FROM Contact WHERE Id =:validsrc.Id limit 1];  
         
        system.debug('con'+con);
        //system.debug('conlist'+conList);
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
   		
        merList.add(validrqst);
       // merList.add(rqst);
        
        insert  validrqst;
        ContactObject cobj=new ContactObject();
       	ContactMerge conm=new ContactMerge(validrqst);
        conm.contacts=cobj;
        ContactMerge.unlockRecords(merList);
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(1, [select count() from contact where UUID__c='789456']);
        Test.stopTest();
        
  
        
    }
    static testmethod void testexecutemergevalidsitecases2(){
        
             
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Something');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
            
        Account b = TestUtil.createAccount('test');
        b.Account_UUID__c = '12345';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='1234546';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;    
        
        
        
        List<Contact> conList=new  List<Contact>();
       
                                
        Contact target2=TestUtil.createContact(b.id,'Target', 'abc');
        target2.Birthdate=Date.newInstance(2000, 2, 17);
        target2.Merge_Lock__c=false;
        target2.UUID__c='123';
         
        target2.Salutation='Mr.';
                                
        Contact validsrc=TestUtil.createContact(a.id,'sreyc', 'Rayaa');
        validsrc.Birthdate=Date.newInstance(2000, 2, 17);
        validsrc.UUID__c='9563';
        validsrc.Merge_Lock__c=false;
        validsrc.Salutation='Mr.';
         
                                
                                
                                
        //Contact target3=TestUtil.createContact(a.id,'Targetc', 'abcc');
        target2.Birthdate=Date.newInstance(2000, 2, 17);
        target2.Merge_Lock__c=false;
        target2.UUID__c='789456';
         
         
        //target2.Sites__r
        //target2.Salutation='Mr.';
                                
       
        //conList.add(source);
        //conList.add(target);
        //conList.add(invalid);
       
        
       
        //validsrc.sites__r=srcsite;
        
        conList.add(target2);
        conList.add(validsrc);
       
        insert conList;
        cscrm__Site__c site= TestUtil.createSite(null, validsrc.id, a.id);
        //site.cscrm__Installation_Address__c='a4O5D0000008OUrUAM';
        insert site;
        system.debug('testsite1++'+site);
        cscrm__Site__c site2= TestUtil.createSite(null, target2.id, b.id);
        //site2.cscrm__Installation_Address__c='a4O5D0000008OUrUAM';
        insert site2;
        system.debug('testsite2++'+site2);
        validsrc.sites__r.add(site);
        target2.sites__r.add(site2) ;
        conList.clear();
        conList.add(validsrc);
        conList.add(target2);
        update conlist;
            
        Contact con = [SELECT id ,Merge_Status__c,UUID__c,ReferenceMessage__c,(Select id, EndDate,ContactId, IsDirect,AccountId,Contact_Type__c,Contact_Usage__c,InActive__c,Relationship_End_Date__c from AccountContactRelations),  (Select Id,Secondary_Contact__c,cscrm__Account__c,cscrm__Installation_Address__c From Sites__r) FROM Contact WHERE Id =:validsrc.Id limit 1];  
         
        system.debug('con'+con);
        //system.debug('conlist'+conList);
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
   		
        merList.add(validrqst);
       // merList.add(rqst);
        
        insert  validrqst;
        ContactObject cobj=new ContactObject();
       	ContactMerge conm=new ContactMerge(validrqst);
        conm.contacts=cobj;
        ContactMerge.unlockRecords(merList);
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(1, [select count() from contact where UUID__c='789456']);
        Test.stopTest();
        
  
        
    }
   
  static testmethod void testcontactmergeinvalidmerge(){
        
        Test.startTest();
    	EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/4840371999');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Somethingn');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456778';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='123458';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
        Account b = TestUtil.createAccount('testn');
        b.Account_UUID__c = '123456';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='12345467';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;
        
        
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shambo', 'Rayss');
        source.Birthdate=Date.newInstance(2000, 2, 17);
                                source.Salutation='Mr.';
                                source.Merge_Lock__c=false;
                                
        source.UUID__c='9063612';
    	conList.add(source);
        insert conList;
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	//Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
                                
       
        Merge_Request__c rqst2=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='0030l000002f90m',Source_Id__c='9063612',status__c='PENDING');
        //Merge_Request__c rqst3=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='129B6D37-B5EC-43f9-8709-4F5FC4CBE394',Source_Id__c='7894567',status__c='PENDING');
       // merList.add(validrqst);
       // merList.add(rqst);
        merList.add(rqst2);
        //merList.add(rqst3);
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(0, [select count() from contact where UUID__c='0030l000002f90m']);
        Test.stopTest();
        
    }
    
    
    
    static testmethod void testcontactmergeinvalidmergefuncerror(){
        
        Test.startTest();
    	EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/4840371988');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Somethingnq');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456778';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='123450';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
        Account b = TestUtil.createAccount('testn');
        b.Account_UUID__c = '123456';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='12345460';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;
        
        
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shambo', 'Rayssq');
        source.Birthdate=Date.newInstance(2000, 2, 17);
                                source.Salutation='Mr.';
                                source.Merge_Lock__c=false;
                                
        source.UUID__c='90636127';
    	conList.add(source);
        insert conList;
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	//Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
                                
       
        Merge_Request__c rqst2=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='0030l000002f90m1',Source_Id__c='90636127',status__c='PENDING');
        //Merge_Request__c rqst3=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='129B6D37-B5EC-43f9-8709-4F5FC4CBE394',Source_Id__c='7894567',status__c='PENDING');
       // merList.add(validrqst);
       // merList.add(rqst);
        merList.add(rqst2);
        //merList.add(rqst3);
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(0, [select count() from contact where UUID__c='0030l000002f90m']);
        Test.stopTest();
        
    }
    
    
    
    
    
    
    
    
    
   
    
     static testmethod void testcontactmerge401Error(){
        
        Test.startTest();
		EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/test401ContactMerge');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Somethingnq');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456778';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='123450';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
        Account b = TestUtil.createAccount('testn');
        b.Account_UUID__c = '123456';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='12345460';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;
        
        
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shambo', 'Rayssq');
        source.Birthdate=Date.newInstance(2000, 2, 17);
                                source.Salutation='Mr.';
                                source.Merge_Lock__c=false;
                                
        source.UUID__c='90636127';
    	conList.add(source);
        insert conList;
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	//Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
                                
       
        Merge_Request__c rqst2=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='0030l000002f90m1',Source_Id__c='90636127',status__c='PENDING');
        //Merge_Request__c rqst3=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='129B6D37-B5EC-43f9-8709-4F5FC4CBE394',Source_Id__c='7894567',status__c='PENDING');
       // merList.add(validrqst);
       // merList.add(rqst);
        merList.add(rqst2);
        //merList.add(rqst3);
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(0, [select count() from contact where UUID__c='0030l000002f90m']);
        Test.stopTest();
        
    }
    static testmethod void testcontactmergeRaiseExceptioninCallout(){
        
        Test.startTest();
		EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/testExceptionContactMerge');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Somethingnq');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456778';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='123450';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
        Account b = TestUtil.createAccount('testn');
        b.Account_UUID__c = '123456';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='12345460';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;
        
        
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shambo', 'Rayssq');
        source.Birthdate=Date.newInstance(2000, 2, 17);
                                source.Salutation='Mr.';
                                source.Merge_Lock__c=false;
                                
        source.UUID__c='90636127';
    	conList.add(source);
        insert conList;
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	//Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
                                
       
        Merge_Request__c rqst2=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='0030l000002f90m1',Source_Id__c='90636127',status__c='PENDING');
        //Merge_Request__c rqst3=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='129B6D37-B5EC-43f9-8709-4F5FC4CBE394',Source_Id__c='7894567',status__c='PENDING');
       // merList.add(validrqst);
       // merList.add(rqst);
        merList.add(rqst2);
        //merList.add(rqst3);
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(0, [select count() from contact where UUID__c='0030l000002f90m']);
        Test.stopTest();
        
    }
    static testmethod void testcontactmergeinvalidcases(){
        
        Test.startTest();
    
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
      

        
        Account a = TestUtil.createAccount('Something');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354323';
        a.Email__c='sahs.ray@gmail.com'; 
        
        
        insert a;
        
        Account b = TestUtil.createAccount('test');
        b.Account_UUID__c = '12345';
        b.Customer_ID__c = '000';
        b.Pref_Comm_Method__c='Fax';
        b.Fax='12345';
        b.CIDN__c='1234546';
        b.Customer_Status__c='SUSPECT';
        
        b.Type='Sole Trader';
        b.ABN__c='aaaa';
        b.ACN__c='ccc';
        b.Website='www.vsygwoci.com';
        b.FraudFlag__c=false;
        b.VIP_Customer__c=false; 
        b.Phone='0412354323';
        b.Email__c='sahsww.ray@gmail.com'; 
        
        
        
        
        
        insert b;
        
        
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shambo', 'Ray');
        source.Birthdate=Date.newInstance(2000, 2, 17);
                                source.Salutation='Mr.';
                                source.Merge_Lock__c=false;
                                
        source.UUID__c='906361';
    	conList.add(source);
        insert conList;
        
      	List< Merge_Request__c> merList = new List< Merge_Request__c>();
     	//Merge_Request__c validrqst=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='789456',Source_Id__c='9563',status__c='PENDING');
                                
       
        Merge_Request__c rqst2=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='0030l000002f90m',Source_Id__c='906361',status__c='PENDING');
        //Merge_Request__c rqst3=new Merge_Request__c(Type__c='CONTACT',Target_Id__c='129B6D37-B5EC-43f9-8709-4F5FC4CBE394',Source_Id__c='7894567',status__c='PENDING');
       // merList.add(validrqst);
       // merList.add(rqst);
        merList.add(rqst2);
        //merList.add(rqst3);
        insert  merList;
        for(Merge_Request__c mer : merList){
            System.debug('Id : ' + mer.Id);
        }
        
        MergeRecordBatch batch  =  new MergeRecordBatch();
        Database.executeBatch(batch);
      	system.assertEquals(0, [select count() from contact where UUID__c='0030l000002f90m']);
        Test.stopTest();
        
    }
    
    
    static testmethod void testcontactmerge2(){
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        Map<id,List<Contact>> accToContactMap = new Map<id,List<Contact>>();
        integer count =0;
        //integer count =0;
        map<Integer, String> accountlist = new Map<Integer, String>{1 => 'a', 2 => 'b' , 3=>'c', 4=>'d'};
        List<Account> acctLst = new List<Account>();
        for(Integer i=0;i<4;i++){
            Account a = TestUtil.createAccount('TestAcct' +accountlist.get(i));
            a.CIDN__c = '123456'+i;
            a.Account_UUID__c = '12345'+i;
            a.Pref_Comm_Method__c='Fax';
            a.Fax='12349';
            
            a.Customer_Status__c='SUSPECT';

			a.Type='Sole Trader';
            a.ABN__c='aaaa';
            a.ACN__c='ccc';
            a.Website='www.vsygwoci.com';
            a.FraudFlag__c=false;
            a.VIP_Customer__c=false; 
            a.Phone='041235432'+i;
            a.Email__c='sahs.ray@gmail.com'; 
            
            acctLst.add(a);
        }                     
        insert acctLst; 
        
        List<Contact> conl=new List<Contact>();
        for(Account acc : acctLst){
            count++;
            Contact c = TestUtil.createContact(acc.id,'AestFname1', 'Aestlname1227882');
            c.Birthdate=Date.newInstance(2000, 2, 17);
            c.UUID__c = '23456'+count;
            //c.Merge_Lock__c=false;
            c.FirstName='sham';
            c.lastname='ray';
            c.Salutation='Mr.';
			conl.add(c);
            
            
        }
        insert conl;
         
        //cscrm__Site__c srcsite=TestUtil.createSite(conl[0].Id, conl[1].Id, acctLst[0].id);
        //insert srcsite;
        
        
        
       List<Merge_Request__c> mergeList = new List<Merge_Request__c>();
        
        Merge_Request__c mr =  new Merge_Request__c();
        mr.Status__c = 'PENDING';
        mr.Type__c = 'CONTACT';
        mr.Target_Id__c = '234562';
        mr.Source_Id__c = '234561';
        mergeList.add(mr);
        
        
        Merge_Request__c mr1 =  new Merge_Request__c();
        mr1.Status__c = 'PENDING';
        mr1.Type__c = 'CONTACT';
        mr1.Target_Id__c = '23456789';
        mr1.Source_Id__c = '234563';
        mergeList.add(mr1);
        
        Merge_Request__c mr3 =  new Merge_Request__c();
        mr3.Status__c = 'PENDING';
        mr3.Type__c = 'CONTACT';
        mr3.Target_Id__c = '4663336636366';
        mr3.Source_Id__c = '234563';
        mergeList.add(mr3);
        
        Merge_Request__c mr4 =  new Merge_Request__c();
        mr4.Status__c = 'PENDING';
        mr4.Type__c = 'CONTACT';
        mr4.Target_Id__c = '1111111';
        mr4.Source_Id__c = '123454';
        mergeList.add(mr4);
        
        insert mergeList;
        ContactObject co=new ContactObject();
        co.Data=new ContactObject.Data();
        co.Data.contacts=new List<ContactObject.Contact>();
        ContactObject.Contact c=new ContactObject.Contact();
        ContactObject.ContactRelationship cr=new ContactObject.ContactRelationship();
        cr.contactType='Full Authority'; 
        cr.contactUsage='Business'; 
        cr.endDate='2016-12-12';
        c.preferredMethod='Fax';
        c.title='test';
        c.firstName='test55';
        c.lastName='test11';
        c.middleName='test22';
        c.status='';
        c.Title='abc';
       	c.id='4663336636366';
        c.birthDate='1994-12-12';
        co.Data.contacts.add(c);
        contactobject.HomeContact hc=new contactobject.HomeContact();
        
        hc.emailAddress='abc.ray@xyz.com';
        hc.faxNumber='7019788922';
        hc.mobileNumber='7019788922';
        hc.phoneNumber='7019788922';
        c.homeContact=hc;   
        c.customerAccounts=new  List<ContactObject.CustomerAccount>();
        ContactObject.CustomerAccount cacc=new ContactObject.CustomerAccount();
        
        
        cacc.contactRelationship=cr;
        cacc.lastName = 'Lastname';
        
        cacc.mmsOptIn = 'true';
        cacc.smsOptIn = 'true';
        cacc.emailOptIn = 'false';
        cacc.faceToFaceOptIn = 'false';
        cacc.phoneOptIn = 'true';
        cacc.directMailOptIn = 'false';
       // cacc.marketClass = '';
       // cacc.businessUnit = '';
        cacc.dataSovereignty = '';
        c.customerAccounts.add(cacc);
        
        
        
        
        //Map<String, CustomerObject.Customer> acountInsert = new Map<String, CustomerObject.Customer>();
        
        Map<String, Contactobject> contactInsert = new Map<String, Contactobject>();
                                
        Map<String,list<Merge_Request__c>> targetmissing =  new Map<String,list<Merge_Request__c>>();
        targetmissing.put('4663336636366', new List<Merge_Request__c>{mr3});
        contactInsert.put('0010l000001r90o', co);
        ContactMerge conm = new ContactMerge();
        conm.insertContact(contactInsert,targetmissing);
        List <Merge_Request__c> lockRecord=new List <Merge_Request__c>();
        lockRecord.add(mr1);
        conm.lockRecords(lockRecord);
        system.assertEquals(1, [select count() from contact where UUID__c='4663336636366']);
        Test.stopTest();
        
    }
    
    static testmethod void testcontactmerge3(){
        Test.startTest();
        MergeRecordBatch batch  =  new MergeRecordBatch(MergeRecordFactory.type.CONTACT);
        Database.executeBatch(batch);
        system.assertNotEquals(null, MergeRecordFactory.type.CONTACT);
        Test.stopTest();
    }
    
    static testmethod void testcontactmerge4(){
        Test.startTest();
        MergeRecordBatch batch  =  new MergeRecordBatch(MergeRecordFactory.type.CONTACT, 'Pending');
        Database.executeBatch(batch);
        system.assertEquals(0,[select count() from Merge_Request__c]);
        Test.stopTest();
    }
    /* static testmethod void testmergeforaccount(){
        Test.startTest();
        MergeRecordBatch batch  =  new MergeRecordBatch(MergeRecordFactory.type.ACCOUNT, 'Pending');
        Database.executeBatch(batch);
        Test.stopTest();
    }*/
    
    static testmethod void  testcontactmerge5(){
        Test.startTest();
        MergeRecordBatch batch  =  new MergeRecordBatch(MergeRecordFactory.type.CONTACT, 'In Progress	');
        Database.executeBatch(batch);
        system.assertEquals(0,[select count() from Merge_Request__c]);
        Test.stopTest();
    }
  
}