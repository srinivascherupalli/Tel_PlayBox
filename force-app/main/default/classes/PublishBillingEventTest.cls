@isTest
public class PublishBillingEventTest {
  
    @testsetup static void setup(){
         List<sobject> lsAcc=Test.loadData(Account.sObjectType, 'TCM_ACC_TST');
        List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Acr_Con');
        List<sobject> lsAdd=Test.loadData(cscrm__Address__c.sObjectType, 'TCM_AddressRelation');
    /* EDGE-194261 Starts */
        account acct=new account(name='TestAccount',CIDN__c='12345',ABN__c='1234');
        insert acct;
        contact cont=new contact(lastname='TestContact1',accountId=acct.id);
        insert cont;
        Billing_Account__c billAcc=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=cont.Id);
        insert billAcc;
        cscrm__Address__c add=new cscrm__Address__c(Name='TestAddress',cscrm__Country__c='India');
        insert add;
    /* EDGE-194261 Ends */
        
    }
    @isTest static void testMethodBillingAccountUpdate(){
        Billing_Account__c bAccount = new Billing_Account__c();
        bAccount.Account__c = [select id from Account Limit 1].id;
        bAccount.Billing_Account_Number__c = '100000000011';
        bAccount.Billing_Account_Owner__c = [Select Id from contact Limit 1].Id;
        bAccount.Billing_Address__c=[select id from cscrm__Address__c Limit 1].Id;
        insert bAccount; 
        bAccount.Billing_Account_Number__c='100000000022';
        update bAccount ;
        cscrm__Address__c add= [select id from cscrm__Address__c Limit 1];
        add.cscrm__Country__c='INDIA';
        update add;
        System.assertNotEquals(Null, bAccount);
       
    }
  
  /* EDGE-194261 Upgrading the customer MS platform event to HV platform event - Starts */
   @isTest static void testHVEventLogMethod(){
        BillingPublishEventsImpl.EventLog eventL= new BillingPublishEventsImpl.EventLog();
        BillingAccountMSEventHV__e billAcc = new BillingAccountMSEventHV__e(); 
       test.startTest();
       billingHandler.run = true;
             test.stopTest();
             Database.Error dbError = null;
             eventL.billingHVEvent=billAcc;
             eventL.errorMessage=dbError;
             System.assertNotEquals(Null, billAcc);
         }
    
      
    @isTest static void testHVMethodLog(){   
        BillingAccountMSEventHV__e event = new BillingAccountMSEventHV__e();
        List<BillingAccountMSEventHV__e> CustEvent = new List<BillingAccountMSEventHV__e>();
    
        
        CustEvent.add(event);
        List<Database.SaveResult> saveResults = null;
        saveResults = EventBus.publish(CustEvent);
        System.assertNotEquals(Null, event);
         System.assertNotEquals(Null, CustEvent);
      BillingPublishEventsImpl p = new BillingPublishEventsImpl();
        p.logApplicationLogHV(saveResults);   
    }
    
    @isTest
    public static void test_saveRecs(){              
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con1 = [Select Id,Name from contact where lastname='TestContact1'];
        List < AccountContactRelation  > lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con1.Id];
        for(AccountContactRelation acr: lstOfContact){
            acr.roles = 'Full Authority';
        }
        update lstOfContact;
        
        AccountContactRelation acr=[SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con1.id];
        acr.roles = 'Full Authority'; 
        update acr;
        cscrm__Address__c add=[select id,name,cscrm__Country__c from cscrm__Address__c where cscrm__Country__c='India'];
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        test.startTest();
        String sTest = BillingAccountCreate.fetchban(billAcc.Id);
        system.debug('acc.id ------------------------->'+acc.id);
        //String str= BillingAccountCreate.fetchAccountContactRelObj(acc.id,con.id);
        Id id=BillingAccountCreate.saveRecs( billAcc.Billing_Account_Number__c,'14','10',String.valueOf(acc.id),acr,add,lstOfContact,true,true,true);
        Id ids=BillingAccountCreate.saveEditedRecords(billAcc.Billing_Account_Number__c,String.valueOf(acr.ContactId),
                                                      String.ValueOf(add.id),lstOfContact,true, 'Final',true,'10');
        test.stopTest();
        system.assertNotEquals(null,id);
    }
    /* EDGE-194261 Upgrading the customer MS platform event to HV platform event - Ends */

}