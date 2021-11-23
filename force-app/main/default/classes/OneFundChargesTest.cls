/*-------------------------------------------------------- 
EDGE-123565
Class: OneFundChargesTest
Description: Test class for OneFundCharges
Author:Tejes

**Modified By: Payal/Shishir : Fix the test Class Failure
--------------------------------------------------------*/

@isTest
public class OneFundChargesTest {
    public static Id oneFundChargesCaseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OneFund_Charges').getRecordTypeId();
    public static Id oneFundChargesCreditRecordId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByDeveloperName().get('OneFund_Charges').getRecordTypeId();

    @testSetup
    static void testData(){
      /*  Profile p = [select Id,name from Profile where Name ='Sales Enterprise B2B'];
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u1 = new User(alias = 'sales', email='OneFundChargesTest_salesuser@noemail.com',
                           emailencodingkey='UTF-8', lastname='Test salesuser', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'salesuser@noemail.com',phone='+121231231234');        
        insert u1;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'OneFund_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id);
        
        User u = [select Id from User where email='OneFundChargesTest_salesuser@noemail.com' ];
        System.runAs(u1){*/
            Account accountRecord = APTPS_TestClassData.accountRecord('Test OneFund Charges Account','1234543210');
            Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
            List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
            Billing_Account__c oneFundChargesBillingAccount1 =new Billing_Account__c(Account__c=accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='700000375019');
            lstBillingAccount.add(oneFundChargesBillingAccount1);
            Billing_Account__c oneFundChargesBillingAccount2 =new Billing_Account__c(Account__c=accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='700000375020');
            lstBillingAccount.add(oneFundChargesBillingAccount2);
            
            insert lstBillingAccount;
            
            List<Case> lstOneFundCharges = new List<Case>();
            case oneFundChargesCase1 =new case(Account=accountRecord,Billing_Account__c=oneFundChargesBillingAccount1.id,Subject='OneFundTest',status='In Progress',RecordTypeId=oneFundChargesCaseRecordId,Charge_Type__c='Downgrade',Charge_Amount__c=2500.00);
            lstOneFundCharges.add(oneFundChargesCase1);
            case oneFundChargesCase2 =new case(Account=accountRecord,Billing_Account__c=oneFundChargesBillingAccount2.id,Subject='OneFundTest',status='In Progress',RecordTypeId=oneFundChargesCaseRecordId,Charge_Type__c='OF Termination',Charge_Amount__c=2500.00);
            lstOneFundCharges.add(oneFundChargesCase2);
            
            insert lstOneFundCharges;
            Test.startTest();
            
            List<Credits_and_Adjustments__c> lstOneFundChargesCredit = new List<Credits_and_Adjustments__c>();
            Credits_and_Adjustments__c oneFundChargesCredit1= new Credits_and_Adjustments__c(Case_Number__c=oneFundChargesCase1.id,Billing_Account_Number_BAN__c=oneFundChargesBillingAccount1.id,RecordTypeId=oneFundChargesCreditRecordId,Charge_Status__c='In Progress',Charge_Type__c='Downgrade',Charge_Amount__c=2000.00);
            lstOneFundChargesCredit.add(oneFundChargesCredit1);
            Credits_and_Adjustments__c oneFundChargesCredit2= new Credits_and_Adjustments__c(Case_Number__c=oneFundChargesCase2.id,Billing_Account_Number_BAN__c=oneFundChargesBillingAccount2.id,RecordTypeId=oneFundChargesCreditRecordId,Charge_Status__c='In Progress',Charge_Type__c='OF Termination',Charge_Amount__c=2000.00);
            lstOneFundChargesCredit.add(oneFundChargesCredit2);
            insert lstOneFundChargesCredit;
            
            Non_Marketable_Product__c recordOfProduct= new Non_Marketable_Product__c(Name=oneFundChargesCredit1.Charge_Type__c,billingSpecId__c='DMCAT_NonRecurringCharge_000882',currency__c='AUD',externalId__c='DMCAT_StandaloneProduct_000879_DMCAT_NonRecurringCharge_000882_1173',
                                                                                         specId__c='DMCAT_StandaloneProduct_000879',productDescription__c='Onefunds Downgrade Charge',taxTreatment__c='GST Applicable');
            insert recordOfProduct;
            
            Test.stopTest();
        //}
    }
    
    
    @isTest
    static void testPostOneFundCharges(){
        //User u = [select Id from User where email='OneFundChargesTest_salesuser@noemail.com' /*username ='salesuser@noemail.com'*/];
        //System.runAs(u){
            
            List<Credits_and_Adjustments__c> lstOneFundChargesCredit = [SELECT id,Case_Number__c,Billing_Account_Number_BAN__c,RecordTypeId,Charge_Status__c,Charge_Type__c,Charge_Amount__c FROM Credits_and_Adjustments__c];
            
            List<Case> lstCases = [SELECT id,AccountId,Billing_Account__c,Subject,status,RecordTypeId,Charge_Type__c,Charge_Amount__c FROM Case];
            
            String correlationId1 = EDISSingleManager.getUID();
            String correlationId2 = EDISSingleManager.getUID();
            
            //Mocking responses for OneFundChargesCallout
            //Test.setMock(HttpCalloutMock.class, new MockOneFundChargesCallout('errorResponse'));
            HttpResponse res1 = new HttpResponse();
            HttpResponse res2 = new HttpResponse();       
            String successResponse='{"code":201,"status":201,"message": "Created"}';
            String errorResponse='{"code":422,"status":422,"message":"Validation Failed"}';
            res1.setBody(successResponse);
            res1.setStatusCode(201);
    
            for(Credits_and_Adjustments__c objFundCred: lstOneFundChargesCredit){
                objFundCred.Charge_Status__c='Charge Customer';
            }
            Test.startTest();
            update lstOneFundChargesCredit;
            
            /*oneFundChargesCredit1.Charge_Status__c='Charge Customer';
            update oneFundChargesCredit1;*/
            OneFundCharges.checkResponseStatus(res1,lstOneFundChargesCredit[0].id,lstCases[0].id,correlationId1);
               
            res2.setBody(errorResponse);
            res2.setStatusCode(422);
            /*oneFundChargesCredit2.Charge_Status__c='Charge Customer';
            update oneFundChargesCredit2;*/
            OneFundCharges.checkResponseStatus(res2,lstOneFundChargesCredit[1].id,lstCases[1].id,correlationId2);
            Test.stopTest();
            
            List<Credits_and_Adjustments__c> creditList = [select id,name,Case_Number__c,charge_type__c,Charge_Status__c,Charge_Amount__c,Corelation_ID__c,Billing_Account_Number_BAN__c from Credits_and_Adjustments__c where Id IN :lstOneFundChargesCredit order by name];
            System.assertnotequals(creditList[0].Charge_Status__c,'Charge Customer');
            System.assertnotequals(creditList[1].Charge_Status__c,'Charge Customer');
            System.assertequals(creditList[0].Charge_Status__c,'Posted');
            System.assertequals(creditList[1].Charge_Status__c,'Submission Failed');
        }
    //}
    
}