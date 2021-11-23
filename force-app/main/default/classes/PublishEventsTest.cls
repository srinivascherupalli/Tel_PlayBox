@isTest
public class PublishEventsTest {

    @testsetup static void setup(){
        List<sobject> lsAcc=Test.loadData(Account.sObjectType, 'TCM_ACC_TST');
        List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Acr_Con');
        List<sobject> lsAdd=Test.loadData(cscrm__Address__c.sObjectType, 'TCM_AddressRelation');  
        
        ASIC__c asic = new ASIC__c();
        asic.Industry__c = 'ABC';
        asic.SIC_Code__c = '3400';
        insert asic;
        
        csord__Order_Request__c orderRequest = new csord__Order_Request__c();
        orderRequest.Name = 'test request';
        orderRequest.csord__Module_Name__c = 'module test';
        orderRequest.csord__Module_Version__c = 'v1';
        orderRequest.csord__Process_Status__c = 'Requested';
        orderRequest.csord__Request_DateTime__c = System.now();
        insert orderRequest;
        
        csord__Order__c order = new csord__Order__c();
        order.Name = 'test order';
        order.csord__Account__c = [select id from Account Limit 1].id;
        order.Status__c = 'Requested';
        order.csord__Identification__c = 'test identification';
        order.csord__Order_Request__c = orderRequest.Id;
        insert order;
              
    }
    //Account Address Relationship
    @isTest static void testMethodAccountAddressInsert(){
        cscrm__Account_Address_Relationship__c accAdr= new cscrm__Account_Address_Relationship__c();
        accAdr.cscrm__Address__c=[select id from cscrm__Address__c where cscrm__Country__c='AUSTRALIA' Limit 1].id;
        accAdr.cscrm__Account__c=[select id from Account Limit 1].id;
        
        insert accAdr;
        System.assertNotEquals(Null, accAdr);
        system.debug('cscrm__Account_Address_Relationship__c'+accAdr.id);
    }
    
    //Contact Address Relationship
     @isTest static void testMethodContactAddressInsert(){
        cscrm__Contact_Address_Relationship__c car = new cscrm__Contact_Address_Relationship__c();
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1');
        insert address;
        Contact pc = AccountTestFactory.buildContact(acc, 'testPC', 'testabc122@test.com');
        insert pc;
        car.cscrm__Contact__c = pc.Id;
        car.cscrm__Address__c = address.Id; 
        car.cscrm__Active__c = true;
        car.cscrm__Address_Type__c = 'Home Address';
        car.Primary__c = true;
        insert car;
        car.cscrm__Address_Type__c = 'Office Address';
        update car;
        System.assertNotEquals(Null, car);
    }
    //Account Industry relationship
     @isTest static void testMethodAccountIndustryInsert(){
       Account_Industry_Relationship__c air = new Account_Industry_Relationship__c();
       air.AccountID__c = [select id from Account Limit 1].id;
       air.IndustryID__c = [select id from ASIC__c Limit 1].id;
       insert air;     
        
       System.assertNotEquals(Null, air);
    }
    //Billing Account
     @isTest static void testMethodBillingAccountInsert(){
       
         Billing_Account__c bAccount = new Billing_Account__c();
        bAccount.Account__c = [select id from Account Limit 1].id;
        bAccount.Billing_Account_Number__c = '100000000011';
        bAccount.Billing_Account_Owner__c = [Select Id from contact Limit 1].Id;
        insert bAccount;    
        System.assertNotEquals(Null, bAccount);
       
    }
    //Functional Contact Role
    @isTest static void testMethodInsert(){
        
        Functional_Contact_Role__c fcr = new Functional_Contact_Role__c();
        fcr.ContactID__c = [Select Id from contact Limit 1].Id;
        fcr.OrderID__c = [Select Id,Name,csord__Account__c,Status__c,csord__Identification__c,csord__Order_Request__c from csord__Order__c LIMIT 1].Id;
        insert fcr;
        System.assertNotEquals(Null, fcr);
    }
   
    //Contact
    @isTest static void testMethodcontact(){
        Account acctest = [SELECT Id FROM Account limit 1];
        Contact con1 = new Contact(LastName='Con',AccountId=acctest.Id,Is_Lead_Originated__c=False,Sales_Contact__c=False);
        Insert con1;
        System.assertNotEquals(Null, con1);
    }  


    /*EDGE-194261 Starts Here */
    //Publish Event
    @isTest static void testMethodLog2(){        
        // Updated for P2OB-11660 lastModified Date is needed to generate platform event 
         list<Account> acctest = [SELECT Id,LastModifiedDate FROM Account limit 1];
        CustomerMicroServiceEventHV__e event = new CustomerMicroServiceEventHV__e();
        List<CustomerMicroServiceEventHV__e> CustEvent = new List<CustomerMicroServiceEventHV__e>();
        CustEvent.add(event);
        List<Database.SaveResult> saveResults = null;
        saveResults = EventBus.publish(CustEvent);
        System.assertNotEquals(Null, event);
        System.assertNotEquals(Null, CustEvent);
        PublishEventsImpl p = new PublishEventsImpl();
        //p.customerMSList=CustEvent;
        p.createEventObject(acctest,'Account','Create');
        p.logApplicationLogHV(saveResults);
    
    }
    /*EDGE-194261 Ends Here*/
    
    
}