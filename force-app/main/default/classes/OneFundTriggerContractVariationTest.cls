/*
 * AUTHOR : Anil
 * TEAM: Napier
 * DESCRIPTION : Test Class for OneFundTriggerContractVariation
 * EDGE-112655, EDGE-115681 
*/

@istest
public class OneFundTriggerContractVariationTest {
    public static id committedFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
    public static Id redemptionRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();
    public static Id accrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
    
    @testSetup
    static void testData(){
        Profile p = [select Id,name from Profile where Name ='Sales Enterprise B2B'];
         
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		String uniqueName = orgId + dateString + randomInt;
        User u1 = new User(alias = 'sales', email='OneFundTriggerContractVariationTest_salesuser@noemail.com',
                           emailencodingkey='UTF-8', lastname='Test salesuser', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'salesuser@noemail.com',phone='+121231231234');        
        insert u1;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'OneFund_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id);
    }
    
    static testmethod void testCalculateOneFundCharge(){
        User u = [select Id from User where email='OneFundTriggerContractVariationTest_salesuser@noemail.com' /*username ='salesuser@noemail.com'*/];
        System.runAs(u){
            Date dt = system.today();
            Date fiveMonthsBefore= Date.newInstance(dt.year(), dt.month()-5, dt.day());            
            List<OneFund__c> fundList = new List<OneFund__c>();
            Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
            Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);
            //Update code by Vidhata as per user Story#EDGE-122646(Monthly Commitment field type changes to picklist. )
            OneFund__c fundRecord1 = new OneFund__c(Start_Date__c = dt, Contract_Duration__c = '36',Customer_Commitment__c = '1000', RecordTypeId = committedFundRecId,CIDN__c = accountRecord.id,Contract_Variation__c='Upgrade');
            fundList.add(fundRecord1);
            
            OneFund__c fundRecord2 = new OneFund__c(Start_Date__c = dt, Contract_Duration__c = '36',Customer_Commitment__c = '2000', RecordTypeId = committedFundRecId,CIDN__c = accountRecord.id,Contract_Variation__c='Downgrade');
            fundList.add(fundRecord2);        
            
            OneFund__c fundRecord3 = new OneFund__c(Start_Date__c = dt, Contract_Duration__c = '36', RecordTypeId = committedFundRecId,CIDN__c = accountRecord.id,Contract_Variation__c='Upgrade');
            fundList.add(fundRecord3);
            
            OneFund__c fundRecord4 = new OneFund__c(Start_Date__c = dt, Contract_Duration__c = '36',Customer_Commitment__c = '2000', RecordTypeId = committedFundRecId,CIDN__c = accountRecord.id,Contract_Variation__c='Downgrade');
            fundList.add(fundRecord4);
            
            OneFund__c fundRecord5 = new OneFund__c(Start_Date__c = dt, Contract_Duration__c = '36',Customer_Commitment__c = '2000', RecordTypeId = committedFundRecId,CIDN__c = accountRecord.id,Contract_Variation__c='Downgrade');
            fundList.add(fundRecord5);
            
            OneFund__c fundRecord6 = new OneFund__c(Start_Date__c = dt, Contract_Duration__c = '36',Customer_Commitment__c = '2000', RecordTypeId = committedFundRecId,CIDN__c = accountRecord.id,Contract_Variation__c='Downgrade');
            fundList.add(fundRecord6);
            
            insert fundList;
            
            List<OneFund_Transactions__c> fundTransList = new List<OneFund_Transactions__c>();
            
            OneFund_Transactions__c fundTransactionRecord3 = new OneFund_Transactions__c(OneFund__c = fundRecord3.id,
                                                                                         RecordTypeId = redemptionRecordId,                                                                            
                                                                                         Transaction_Amount__c=3000.00);
            fundTransList.add(fundTransactionRecord3);
            
            
            OneFund_Transactions__c fundTransactionRecord5 = new OneFund_Transactions__c(OneFund__c = fundRecord5.id,
                                                                                         RecordTypeId = redemptionRecordId,
                                                                                         Transaction_Status__c='Active',
                                                                                         Transaction_Amount__c=1200.00);
            fundTransList.add(fundTransactionRecord5);
            
         /*   OneFund_Transactions__c allocationTransaction5 = [select id,Redeemed_Amount__c from OneFund_Transactions__c where OneFund__c =: fundRecord5.id and Transaction_Status__c = 'Active' and Transaction_Type__c = 'Allocation' and Sub_Type__c = 'Committed OneFund'];
            allocationTransaction5.Redeemed_Amount__c=1200.00;
            update allocationTransaction5;*/
            
            
            OneFund_Transactions__c arrearsTransaction5 = new OneFund_Transactions__c(OneFund__c = fundRecord5.id,
                                                                                      RecordTypeId = accrualRecordId,Transaction_Status__c='Active',
                                                                                      Sub_Type__c='Arrears',Transaction_Amount__c=100.00);
            fundTransList.add(arrearsTransaction5);
            
            
            OneFund_Transactions__c fundTransactionRecord6 = new OneFund_Transactions__c(OneFund__c = fundRecord6.id,
                                                                                         RecordTypeId = redemptionRecordId,
                                                                                         Transaction_Status__c='Active',
                                                                                         Transaction_Amount__c=7200.00);
            fundTransList.add(fundTransactionRecord6);
            
           /* OneFund_Transactions__c allocationTransaction6 = [select id,Redeemed_Amount__c from OneFund_Transactions__c where OneFund__c =: fundRecord6.id and Transaction_Status__c = 'Active' and Transaction_Type__c = 'Allocation' and Sub_Type__c = 'Committed OneFund'];
            allocationTransaction6.Redeemed_Amount__c=7200.00;
            update allocationTransaction6;*/
            
            
            OneFund_Transactions__c arrearsTransaction6 = new OneFund_Transactions__c(OneFund__c = fundRecord6.id,
                                                                                      RecordTypeId = accrualRecordId,Transaction_Status__c='Active',
                                                                                      Sub_Type__c='Arrears',Transaction_Amount__c=1000.00);
            fundTransList.add(arrearsTransaction6);
            
            
            insert fundTransList;
            
            //updating start date of OneFund for contract variation scenarios
            fundRecord2.Start_Date__c = fiveMonthsBefore;
            fundRecord4.Start_Date__c = fiveMonthsBefore;
            fundRecord5.Start_Date__c = fiveMonthsBefore;            
            fundRecord6.Start_Date__c = fiveMonthsBefore; 
            update fundList;
            
            Test.startTest();
            //to Check for upgrade scenario
            fundRecord1.Contract_Duration__c = '36';
            fundRecord1.Customer_Commitment__c = '2000';        
            
            //to Check for downgrade scenario
            fundRecord2.Contract_Duration__c = '24';
            fundRecord2.Customer_Commitment__c = '1000';        
            
            //to Check for downgrade scenario           
            fundRecord4.Contract_Duration__c = '24';
            fundRecord4.Customer_Commitment__c = '1500'; 
            
            //to Check for downgrade scenario           
            fundRecord5.Contract_Duration__c = '24';
            fundRecord5.Customer_Commitment__c = '1500';
            
            //to Check for downgrade scenario           
            fundRecord6.Contract_Duration__c = '24';
            fundRecord6.Customer_Commitment__c = '1500';
            
            update fundList;
            
            Test.stopTest();
            
         /*   List<OneFund_Transactions__c> fundTransListUpdated = [SELECT Id,name,OneFund__c,Transaction_Amount__c,Transaction_Status__c
                                                                  FROM OneFund_Transactions__c 
                                                                  WHERE OneFund__c =:fundRecord1.id order by name DESC];        
            system.assertEquals(7200.00, fundTransListUpdated[0].Transaction_Amount__c);
            system.assertEquals(3600.00, fundTransListUpdated[1].Transaction_Amount__c);
            system.assertNotEquals('Active',fundTransListUpdated[1].Transaction_Status__c);
            
            List<OneFund_Transactions__c> fundTransListUpdated1 = [SELECT Id,name,OneFund__c,Transaction_Amount__c,Sub_Type__c
                                                                   FROM OneFund_Transactions__c 
                                                                   WHERE OneFund__c =:fundRecord2.id order by name];        
            system.assertEquals(7200.00, fundTransListUpdated1[0].Transaction_Amount__c);
            system.assertEquals(1615.00, fundTransListUpdated1[1].Transaction_Amount__c);
            system.assertEquals('Committed OneFund', fundTransListUpdated1[1].Sub_Type__c);
            system.assertEquals(1000.00, fundTransListUpdated1[2].Transaction_Amount__c);
            system.assertNotEquals(null, fundTransListUpdated1[2].Sub_Type__c);
            
            List<OneFund_Transactions__c> fundTransListUpdated2 = [SELECT Id,name,OneFund__c,Transaction_Amount__c,Transaction_Status__c
                                                                   FROM OneFund_Transactions__c 
                                                                   WHERE OneFund__c =:fundRecord5.id order by name];
            system.assertNotEquals('Active', fundTransListUpdated2[0].Transaction_Status__c);
            system.assertEquals(2422.50, fundTransListUpdated2[3].Transaction_Amount__c);
            system.assertEquals(100.00, fundTransListUpdated2[4].Transaction_Amount__c);
            system.assertEquals(200.00, fundTransListUpdated2[5].Transaction_Amount__c);
            
            List<OneFund_Transactions__c> fundTransListUpdated3 = [SELECT Id,name,OneFund__c,Transaction_Amount__c,Transaction_Status__c
                                                                   FROM OneFund_Transactions__c 
                                                                   WHERE OneFund__c =:fundRecord6.id order by name];
            system.assertNotEquals('Active', fundTransListUpdated3[0].Transaction_Status__c);            
            system.assertEquals(2422.50, fundTransListUpdated3[3].Transaction_Amount__c);
            system.assertEquals(1000.00, fundTransListUpdated3[4].Transaction_Amount__c);
            system.assertEquals(2422.50, fundTransListUpdated3[5].Transaction_Amount__c);
            system.assertEquals(1000.00, fundTransListUpdated3[6].Transaction_Amount__c);
            
            List<Case> caseRecList = [SELECT Id,Onefund_ID__c,Charge_Amount__c,Charge_Type__c FROM Case WHERE Onefund_ID__c =:fundRecord6.id];
            system.assertEquals(2777.50, caseRecList[0].Charge_Amount__c);
            system.assertEquals('Downgrade', caseRecList[0].Charge_Type__c);
            
            List<Credits_and_Adjustments__c> creditList = [SELECT ID,Charge_Amount__c,Charge_Type__c FROM Credits_and_Adjustments__c
                                                           WHERE Billing_Account_Number_BAN__c =:fundRecord6.Billing_Account__c order by name];
            system.assertEquals(2777.50, creditList[0].Charge_Amount__c);
            system.assertEquals('Downgrade', creditList[0].Charge_Type__c);*/
            
        }
    }
}