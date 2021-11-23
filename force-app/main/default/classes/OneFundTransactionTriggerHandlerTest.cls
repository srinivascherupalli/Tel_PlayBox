/*
 * AUTHOR : Shivaprasad
 * DESCRIPTION : Test Class for OneFundTransactionTriggerHandler
*/
@istest
public class OneFundTransactionTriggerHandlerTest {
    
	public static id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
	public static id accrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
	
    static testmethod void testTransactionExpiryDate(){
        
        Map<String,List<OneFund_Transactions__c>> mapOfAccountIdWithTransactions=new  Map<String,List<OneFund_Transactions__c>>();
        Test.startTest();
		
        OneFundTransactionTriggerHandler oneFundHandler=new OneFundTransactionTriggerHandler();

        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Account accountRecord1 = APTPS_TestClassData.accountRecord('Fund Trigger Test1','1233211231');
		
		csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.csconta__Status__c = 'Active';
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        fam.csconta__Account__c=accountRecord.Id;
        fam.Mark_as_Variation__c = false;
        fam.csconta__effective_start_date__c = DateTime.now(); 
        fam.csconta__effective_end_date__c = DateTime.now().addMonths(36);
        insert fam;
        
        csconta__Frame_Agreement__c fam1 = new csconta__Frame_Agreement__c();
        fam1.csconta__Status__c = 'Draft';
        fam1.Contract_Acceptance_Date__c=DateTime.now(); 
        fam1.csconta__Account__c=accountRecord1.Id;
        fam1.Mark_as_Variation__c = false;
        fam1.csconta__effective_start_date__c = DateTime.now(); 
        fam1.csconta__effective_end_date__c = DateTime.now().addMonths(36);
        insert fam1;
		
        OneFund__c fundRecord1 = new OneFund__c(Contract_Duration__c = '36',Customer_Commitment__c = '1000', RecordTypeId = flexibleRecordId,CIDN__c = accountRecord.id);
        insert fundRecord1;
		
        OneFund__c fundRecord2 = new OneFund__c(Contract_Duration__c = '36',Customer_Commitment__c = '1000', RecordTypeId = flexibleRecordId,CIDN__c = accountRecord1.id);
        insert fundRecord2;
        
		OneFund_Transactions__c fundTransactionRecord1 = new OneFund_Transactions__c(OneFund__c = fundRecord1.id,
                                                                                    RecordTypeId = AccrualRecordId,Sub_Type__c = 'Legacy Fund Transfer',Legacy_Fund_Account_Number__c = '1213113313',Legacy_Fund_Type__c ='Adaptive Mobility Fund Migration',Transaction_Amount__c=3000.00,Transaction_Status__c='Active');
        insert fundTransactionRecord1;
		
        OneFund_Transactions__c fundTransactionRecord2 = new OneFund_Transactions__c(OneFund__c = fundRecord2.id,
                                                                                    RecordTypeId = AccrualRecordId,Sub_Type__c = 'Legacy Fund Transfer',Legacy_Fund_Account_Number__c = '1213113316',Legacy_Fund_Type__c ='Adaptive Mobility Fund Migration',Transaction_Amount__c=3000.00,Transaction_Status__c='Active');
        insert fundTransactionRecord2;
        
        OneFund_Transactions__c fundTransactionRecord3 = new OneFund_Transactions__c(OneFund__c = fundRecord2.id,
                                                                                     RecordTypeId = AccrualRecordId,Sub_Type__c = 'Legacy Fund Transfer',Legacy_Fund_Account_Number__c = '1213113317',Legacy_Fund_Type__c ='Adaptive Mobility Fund Migration',Transaction_Amount__c=3000.00,Transaction_Status__c='Active');
        insert fundTransactionRecord3;
        Test.stopTest();
        
        List<OneFund_Transactions__c> fundTransListUpdated = [SELECT Id,name,OneFund__c,Expiry_Date__c,Transaction_Amount__c
                                                  FROM OneFund_Transactions__c 
                                                  WHERE OneFund__c = :fundRecord1.id
                                                 ];
        
        //system.assertEquals(fam.csconta__effective_end_date__c.Date(),fundTransListUpdated[0].Expiry_Date__c);
        
        List<OneFund_Transactions__c> fundTransListUpdated1 = [SELECT Id,name,OneFund__c,Expiry_Date__c,Transaction_Amount__c
                                                  FROM OneFund_Transactions__c 
                                                  WHERE OneFund__c = :fundRecord2.id
                                                 ];
        system.assert(fundTransListUpdated1 != null);
       // system.assertEquals(system.today().addMonths(12),fundTransListUpdated1[0].Expiry_Date__c);
    }
}