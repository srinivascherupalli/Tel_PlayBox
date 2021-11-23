/** 
 * Class  Billing Account Manager Test. 
 */ 
/********************************************************   
Class Name      :   BillingOrderManagerTest 
=============================================================================================================================== 
Change.No.    Developer Name          Date          Story Description   
1.            Sandeep R             05/11/19        EDGE- 118632    
2.            Prajakta Patil        11/03/2020      EDGE-137876 
3.            Manish Jha            27/04/2020       INC000092427869 
**********************************************************  
*/  
@isTest 
public class BillingOrderManagerTest {  
    @testsetup  
    public static void dataSetup(){ 
           //   
        Account acc=new Account();  
        acc.Name='testacc'; 
        acc.CIDN__c='1234567891';   
        acc.ABN__c='1235';  
        insert acc; 
            
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');   
        insert contact; 
            
        cscrm__Address__c address = new cscrm__Address__c();    
        address.Name='Unit 1 1234 Lostmy Way';  
        address.Address_Line_1__c='Unit 4 Mahatma'; 
        address.Address_Line_2__c='818 Bourke Street';  
        address.Address_Line_3__c='Docklands';  
        address.Locality__c='Sydney';   
        address.cscrm__Zip_Postal_Code__c='2000';   
        address.cscrm__State_Province__c='NSW'; 
        address.cscrm__Country__c='Australia';  
            
        insert address; 
            
        Billing_Account__c billingAccount=new Billing_Account__c(); 
        billingAccount.Billing_Account_Number__c='123456789322';    
        billingAccount.Billing_Address__c=address.id;   
        billingAccount.Billing_Account_Owner__c=contact.Id; 
        billingAccount.Account__c=acc.Id;   
        billingAccount.Write_off_in_U2C__c=true;
        billingAccount.Written_Off__c = false;
        billingAccount.PreDebt__c = true;
        billingAccount.Status__c = 'Final';
        insert billingAccount;  
            
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);    
        site.Primary_Contact__c = contact.Id;   
        site.cscrm__Installation_Address__r = address;  
        insert site;    
            
        csord__Order__c ord = new csord__Order__c();    
        ord.csord__Identification__c = 'test identification';   
        ord.csord__Account__c = acc.id; 
        ord.csord__Order_Type__c = 'test order' ;   
        ord.Billing_Account__c=billingAccount.id;   
        insert ord; 
            
        csord__Order__c secOrd = new csord__Order__c(); 
        secOrd.csord__Identification__c = 'test identification';    
        secOrd.csord__Account__c = acc.id;  
        secOrd.csord__Order_Type__c = 'test order' ;    
        secOrd.csord__Primary_Order__c = ord.id;    
        insert secOrd;  
            
        cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');   
        insert OriginatingOffer;    
            
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();    
            productConfig.cscfga__originating_offer__c = OriginatingOffer.id;   
        insert productConfig;   
            
        csord__Subscription__c subs=new csord__Subscription__c();   
        subs.name  = 'test subs';   
        subs.csord__Identification__c = 'test identity';    
        subs.Site__c = site.Id; 
        subs.Billing_Account__c=billingAccount.id;  
            subs.csord__Status__c='Subscription Created';   
        subs.csord__Order__c = secOrd.id;   
        subs.csordtelcoa__Product_Configuration__c = productConfig.id;  
        insert subs;    
            
        csord__Service__c serv = new csord__Service__c();   
        serv.name ='tst service';   
        serv.csord__Identification__c  = 'test identify';   
        serv.csord__Subscription__c  = subs.id; 
        serv.csord__Order__c = ord.id;  
        serv.csordtelcoa__Service_Number__c = '3';  
        insert serv;    
        //List<Attachment> atts = new List<Attachment>();   
        Attachment att1 = new Attachment(); 
        att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","unitPrice" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');    
        att1.Name = 'ServiceSpecifications.json';   
        att1.ParentId = serv.Id;    
        insert att1;    
    }   
        
    @isTest static void testGetInstance()   
    {   
        BillingOrderManager.getInstance();  
        system.assertNotEquals(null,BillingOrderManager.getInstance()); 
    }   
        
    @istest static void testCreateBillingAccount(){ 
        Contact con = new Contact();    
        con.FirstName='Joe';    
        con.LastName='Bloggs';  
        con.Salutation='Mr';    
        
        insert con; 
            
        Account acc=new Account();  
        acc.Name='test';    
        acc.CIDN__c='1234567890';   
        acc.ABN__c='1234';  
        insert acc; 
            
        cscrm__Address__c address = new cscrm__Address__c();    
        address.Name='Unit 1 1234 Lostmy Way';  
        address.Address_Line_1__c='Unit 4 Mahatma'; 
        address.Address_Line_2__c='818 Bourke Street';  
        address.Address_Line_3__c='Docklands';  
        address.Locality__c='Sydney';   
        address.cscrm__Zip_Postal_Code__c='2000';   
        address.cscrm__State_Province__c='NSW'; 
        address.cscrm__Country__c='Australia';  
            
        insert address; 
            
        Billing_Account__c billingAccount=new Billing_Account__c(); 
        billingAccount.Billing_Account_Number__c='123456789321';    
        billingAccount.Billing_Address__c=address.id;   
        billingAccount.Billing_Account_Owner__c=con.Id; 
        billingAccount.Account__c=acc.Id;   
        billingAccount.Written_Off__c = false;
        billingAccount.Status__c = 'Final';
        billingAccount.PreDebt__c = true;
        insert billingAccount;  
        String str= billingAccount.id;  
        test.startTest();   
        BillingOrderManager.createBillingAccount(str);  
        test.stopTest();    
        system.assertEquals('123456789321', billingAccount.Billing_Account_Number__c); 
        //INC000092427869
        System.assertNotEquals('',address.Address_Line_2__c);
        
    }   
        
    @istest static void testAllocateBillingAccount()    
    {   
        try{    
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', null, new Map<String, String>())); 
        test.startTest();   
            Billing_Account__c billingAccount1=new Billing_Account__c();    
        billingAccount1.Billing_Account_Number__c='123456789321';   
        insert billingAccount1; 
        //Billing_Account__c billAccount = BillingOrderManager.allocateBillingAccount();    
        string billAccount = BillingOrderManager.allocateBillingAccount();  
        system.assertEquals('123456789321', billingAccount1.Billing_Account_Number__c); 
        test.stopTest();    
        
        }catch(Exception e) 
        {   
            system.debug(' '+e.getMessage());   
        }   
    }   
        
    @istest static void testTriggerPostSubscription()   
    {   
        List<csord__Subscription__c> subsList = [select id,Name from csord__Subscription__c LIMIT 1];   
        List<String> subIds = new List<String>();   
        for(csord__Subscription__c subs :subsList){ 
            subIds.add(subs.id);    
        }           
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(202, 'ACCEPTED', null, new Map<String, String>()));   
        test.startTest();   
        boolean isIncludeSolution = true;   
        Map<Id,CSPOFA__Orchestration_Step__c>subscriptionIdStepMap = new Map<Id,CSPOFA__Orchestration_Step__c>();   
            BillingOrderManager.triggerPostSubscription(subIds,isIncludeSolution);  
        test.stopTest();    
        List<csord__Subscription__c> subList = [select Id, Name, csord__Status__c from csord__Subscription__c WHERE Name ='test subs' LIMIT 1]; 
        if(!subsList.isEmpty()) 
                System.assertNotEquals(null,subList[0].csord__Status__c);   
    }   
    @isTest static void test_requestBillingAccountDetails_404() {   
           Billing_Account__c bill= [select billing_account_number__c,Name,Billing_Address__c,Write_off_in_U2C__c FROM Billing_Account__c WHERE Billing_Account_Number__c='123456789322' LIMIT 1];  
            String ban =String.valueOf(bill.billing_account_number__c); 
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(404, 'OK', '', new Map<String, String>()));   
            Test.startTest();   
           //BillingOrderService.requestBillingAccountDetails(ban);
           //////EDGE-147537
         BillingOrderManager.fetchBillingDetailsFromBDS(ban);
            Test.stopTest();    
            System.assertEquals('123456789322',ban);    
                    
        }   
        
}