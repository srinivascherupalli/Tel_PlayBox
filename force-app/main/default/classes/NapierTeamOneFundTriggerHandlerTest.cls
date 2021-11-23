/*
* AUTHOR : Anil,Tejes, Prashant
* TEAM: Napier
* DESCRIPTION : Test Class for NapierTeamOneFundTriggerHandler, OneFundTriggerHelper, ValidationForCIDNAndBillingAccount
*/
@istest
public class NapierTeamOneFundTriggerHandlerTest {
   // public static id committedFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    public static id flexibleFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
    @testSetup
    static void testData(){
        Profile p = [select Id,name from Profile where Name ='Sales Enterprise B2B'];
        
            String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User u1 = new User(alias = 'sales', email='NapierTeamOneFundTriggerHandlerTest_salesuser@noemail.com',
                           emailencodingkey='UTF-8', lastname='Test salesuser', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'salesuser@noemail.com',Phone='+121231231234');        
        insert u1;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'OneFund_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id);
    }
    
    static testmethod void testOneFundInsertion(){
        User u = [select Id from User where email='NapierTeamOneFundTriggerHandlerTest_salesuser@noemail.com' /*username ='salesuser@noemail.com'*/];
        System.runAs(u){
            Test.startTest();
            List<OneFund_Transactions__c> fundTransList = new List<OneFund_Transactions__c>();
            List<OneFund__c> fundList = new List<OneFund__c>();
            Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
            Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
            //Update code by Vidhata as per user Story#EDGE-122646(Monthly Commitment field type changes to picklist. )
            OneFund__c fundRecord1 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '1000',/* RecordTypeId = committedFundRecId,*/CIDN__c = accountRecord.id);
            fundList.add(fundRecord1);
            OneFund__c fundRecord2 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '1500',/* RecordTypeId = committedFundRecId,*/CIDN__c = accountRecord.id);
           // fundList.add(fundRecord2);
            OneFund__c fundRecord3 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '3000',/* RecordTypeId = committedFundRecId,*/CIDN__c = accountRecord.id);
           // fundList.add(fundRecord3);
            OneFund__c fundRecord4 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '500',/* RecordTypeId = committedFundRecId,*/CIDN__c = accountRecord.id);
          //  fundList.add(fundRecord4);
            OneFund__c fundRecord5 = new OneFund__c(Contract_Duration__c = '24', /* RecordTypeId = committedFundRecId,*/CIDN__c = accountRecord.id);
          //  fundList.add(fundRecord5); 
            insert fundList;
            Test.stopTest();
            
            List<OneFund_Transactions__c> fundTransListUpdated = [SELECT Id,name,OneFund__c,Transaction_Amount__c
                                                                  FROM OneFund_Transactions__c 
                                                                  WHERE OneFund__c = :fundList
                                                                 ];
           // system.assertEquals(2040.00, fundTransListUpdated[0].Transaction_Amount__c,fundTransListUpdated[0]);
           // system.assertEquals(3060.00, fundTransListUpdated[1].Transaction_Amount__c,fundTransListUpdated[1]);
           // system.assertEquals(6120.00, fundTransListUpdated[2].Transaction_Amount__c,fundTransListUpdated[2]);        
          //  system.assertEquals(1020.00, fundTransListUpdated[3].Transaction_Amount__c,fundTransListUpdated[3]);
            //negative testing for fundRecord5 in fundTransactionList will not have its child since there is no Customer_Commitment__c.
           // system.assertEquals(fundTransListUpdated.size()==4,true);
        }
    }
    //EDGE-124394- This Method is written by Prashant to test the Validation on Flexible record
    Static testmethod void testValidationForCIDNFlexible()
    { User u = [select Id from User where email='NapierTeamOneFundTriggerHandlerTest_salesuser@noemail.com' /*username ='salesuser@noemail.com'*/];
     System.runAs(u){
         try{
             
             Test.startTest();
             List<OneFund__c> oneFundList = new List<OneFund__c>();
             Account createAccountRecord = APTPS_TestClassData.accountRecord('Acc Test1','TTest');
             OneFund__c  FundRecord01 = new OneFund__c(CIDN__c = createAccountRecord.id ,RecordTypeId = flexibleFundRecId, OneFund_Status__c ='Active');
             insert FundRecord01;
             OneFund__c  FundRecord02 = new OneFund__c(CIDN__c = createAccountRecord.id ,RecordTypeId = flexibleFundRecId, OneFund_Status__c ='Active');
            // insert FundRecord02;
             Test.stopTest();
             list<OneFund__c> oneFundBillingAccountList = [SELECT id FROM OneFund__c WHERE CIDN__c =:createAccountRecord.CIDN__c]; 
            // system.assertEquals(oneFundBillingAccountList.size(), 1);  
         }
         catch(Exception ex){
             system.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Telstra Enterprise Plus Fund Flexi already exists: []', ex.getMessage());
         }
     }  
    }
    
    //EDGE-124394 & 127732 -This Method is written by Prashant to test the Validation on Committed record- Committed Scenario
    Static testmethod void testValidationForCIDNAndBillingAccountCommittedScenario()
    {
        User u = [select Id from User where email='NapierTeamOneFundTriggerHandlerTest_salesuser@noemail.com' /*username ='salesuser@noemail.com'*/];
        System.runAs(u){ 
            try{
                Test.startTest();
                Account createAccountRecord = APTPS_TestClassData.accountRecord('Test767','cidnTest');
                Billing_Account__c billingAccountRecord = new Billing_Account__c(Account__c=createAccountRecord.id, Billing_Account_Name__c='TestOneFund1',Billing_Account_Number__c='700000123767');
                OneFund__c FundRecord01 = new OneFund__c(Billing_Account__c = billingAccountRecord.id ,Contract_Duration__c = '48',Customer_Commitment__c = '2500',/* RecordTypeId = committedFundRecId,*/CIDN__c = createAccountRecord.id , Committed_OneFund_tied_to__c = 'CIDN');
                insert FundRecord01;
                OneFund__c FundRecord02 = new OneFund__c(Billing_Account__c = billingAccountRecord.id ,Contract_Duration__c = '36',Customer_Commitment__c = '2000',/* RecordTypeId = committedFundRecId,*/CIDN__c = createAccountRecord.id , Committed_OneFund_tied_to__c = 'CIDN');
                 //insert FundRecord02;
                Test.stopTest();        
                list<OneFund__c> oneFundBillingandCIDNList = [SELECT id FROM OneFund__c WHERE CIDN__c =:createAccountRecord.CIDN__c AND Billing_Account__c =:billingAccountRecord.Billing_Account_Name__c];
                
            //    system.assertEquals(oneFundBillingandCIDNList.size(),1);    
            }
            catch(Exception ex){
                system.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Telstra Enterprise Plus Fund Advance already exists: []', ex.getMessage());
            }
        }
    }
    //EDGE-124394 & 127732 -This Method is written by Prashant to test the Validation on Committed record- Hybrid Scenario
    Static testmethod void testValidationForCIDNAndBillingAccountHybridScenario()
    {
        User u = [select Id from User where email='NapierTeamOneFundTriggerHandlerTest_salesuser@noemail.com' /*username ='salesuser@noemail.com'*/];
        System.runAs(u){ 
            try{
                Test.startTest();
                Account createAccountRecord = APTPS_TestClassData.accountRecord('Test688','CidnTest2');
              Billing_Account__c billingAccountRecord = new Billing_Account__c(Account__c=createAccountRecord.id, Billing_Account_Name__c='TestOneFund02',Billing_Account_Number__c='700000123688');
             
                OneFund__c FundRecord01 = new OneFund__c(Billing_Account__c = billingAccountRecord.id ,Contract_Duration__c = '36',Customer_Commitment__c = '2000', /*RecordTypeId = committedFundRecId,*/CIDN__c = createAccountRecord.id , Committed_OneFund_tied_to__c = 'Billing Account');
                insert FundRecord01;
                OneFund__c FundRecord02 = new OneFund__c(Billing_Account__c = billingAccountRecord.id ,Contract_Duration__c = '24',Customer_Commitment__c = '1000', /*RecordTypeId = committedFundRecId,*/CIDN__c = createAccountRecord.id, Committed_OneFund_tied_to__c = 'Billing Account');
               // insert FundRecord02;
                Test.stopTest();        
                list<OneFund__c> oneFundBillingandCIDNList = [SELECT id FROM OneFund__c WHERE CIDN__c =:createAccountRecord.CIDN__c AND Billing_Account__c =:BillingAccountRecord.Billing_Account_Name__c];
                
              //  system.assertEquals(oneFundBillingandCIDNList.size(),1);    
            }
            catch(Exception ex){
                system.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Telstra Enterprise Plus Fund Advance already exists: []', ex.getMessage());
            }
        }
    }
}