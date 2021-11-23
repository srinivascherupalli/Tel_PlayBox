/*
 * AUTHOR : Shivaprasad
 * TEAM: Napier
 * EDGE-205066
 * DESCRIPTION :  Test Class for ScheduleFundTransactions
*/

@istest
public class ScheduleFundTransactionsTest {
    
        static testmethod void testOneFundTransactions(){
        Test.startTest();
        Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();    
    	id committedRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();//'Committed'
    	Id oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
        
        Date dte = system.today();
        Date prevMonthDate = Date.newInstance(dte.year(), dte.month()-1, dte.day());
        Date prevYearDate = Date.newInstance(dte.year(), dte.month()-12, dte.day());
		Date prevTwoYearDate = Date.newInstance(dte.year(), dte.month()-24, dte.day());
        Date prevTwoYearMinusOneMonthDate = Date.newInstance(dte.year(), dte.month()-25, dte.day());
        Date nextYearDate = Date.newInstance(dte.year(), dte.month()+12, dte.day());
            
        List<OneFund__c> fundList = new List<OneFund__c>();
        List<OneFund_Transactions__c> fundTransList = new List<OneFund_Transactions__c>();
        
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);

        OneFund__c fundRecord1 = new OneFund__c(RecordTypeId = flexibleRecordId,End_Date__c = dte.addMonths(24),OneFund_Status__c = 'Active',CIDN__c = accountRecord.id,Contract_Duration__c = '24',Customer_Commitment__c = '1000');        
        fundList.add(fundRecord1);
        
        OneFund__c fundRecord3 = new OneFund__c(RecordTypeId = flexibleRecordId,CIDN__c = accountRecord.id,Contract_Duration__c = '24',Customer_Commitment__c = '1000');        
        fundList.add(fundRecord3); 
        
        OneFund__c fundRecord4 = new OneFund__c(RecordTypeId = flexibleRecordId,CIDN__c = accountRecord.id,Start_Date__c = prevTwoYearDate,Contract_Duration__c = '24',Customer_Commitment__c = '1000');        
        fundList.add(fundRecord4);
        
        OneFund__c fundRecord5 = new OneFund__c(RecordTypeId = flexibleRecordId,CIDN__c = accountRecord.id,Start_Date__c = prevYearDate,Contract_Duration__c = '24',Customer_Commitment__c = '1000');        
        fundList.add(fundRecord5);
            
        OneFund__c fundRecord6 = new OneFund__c(RecordTypeId = flexibleRecordId,CIDN__c = accountRecord.id,Start_Date__c = prevTwoYearMinusOneMonthDate,Contract_Duration__c = '24',Customer_Commitment__c = '1000');        
        fundList.add(fundRecord6);
                system.debug('fundList::'+fundList);
        insert fundList;

          
        OneFund_Transactions__c fundTransactionRecord2 = new OneFund_Transactions__c(OneFund__c = fundRecord1.Id,
                                                                             RecordTypeId = oneFundAccrualRecordId,                                                                                                                                                                                                                                     
                                                                             Transaction_Amount__c=10000.00,Expiry_Date__c = dte);
        fundTransList.add(fundTransactionRecord2);
        
        		
        OneFund_Transactions__c fundTransactionRecord3 = new OneFund_Transactions__c(OneFund__c = fundRecord6.Id,
                                                                             RecordTypeId = oneFundAccrualRecordId,                                                                                                                                                          
                                                                             Transaction_Amount__c=10000.00,Expiry_Date__c = prevMonthDate);
        fundTransList.add(fundTransactionRecord3);
 
            
		OneFund_Transactions__c fundTransactionRecord6 = new OneFund_Transactions__c(OneFund__c = fundRecord4.Id,Expiry_Date__c = system.today(),RecordTypeId = oneFundAccrualRecordId,Transaction_Amount__c=1000.00,Transaction_Status__c='Active'); 
        fundTransList.add(fundTransactionRecord6); 
        
            /*OneFund_Transactions__c fundTransactionRecord7 = new OneFund_Transactions__c(OneFund__c = fundRecord5.Id,Start_Date__c = prevYearDate,Expiry_Date__c = system.today(),RecordTypeId = oneFundAccrualRecordId,Transaction_Status__c='Active',Transaction_Amount__c=2500.00); 
        fundTransList.add(fundTransactionRecord7);*/
        OneFund_Transactions__c fundTransactionRecord8 = new OneFund_Transactions__c(OneFund__c = fundRecord5.Id,Start_Date__c = system.today(),RecordTypeId = oneFundAccrualRecordId,Transaction_Status__c='Pending',Expiry_Date__c= nextYearDate,Transaction_Amount__c=2500.00); 
        fundTransList.add(fundTransactionRecord8);
        system.debug('fundTransList::'+fundTransList);
        insert fundTransList;
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        ScheduleFundTransactions sch = new ScheduleFundTransactions();
        String jobName = 'fundTransactionJob'+Datetime.now();
		system.schedule(jobName, CRON_EXP, sch); 
        
        Test.stopTest();
                
        List<OneFund_Transactions__c> fundTransListUpdated = [SELECT Id,name,OneFund__C,Start_Date__c,Expiry_Date__c,Transaction_Status__c
                                                  FROM OneFund_Transactions__c WHERE id in :fundTransList order by name];
		//to move to expired
        system.debug('fundTransListUpdated::'+fundTransListUpdated);
        system.assertEquals('Expired', fundTransListUpdated[0].Transaction_Status__c, 'name='+fundTransListUpdated[0].name+' expirydate='+fundTransListUpdated[0].Expiry_Date__c+' status ='+fundTransListUpdated[0].Transaction_Status__c);
        
            // To make active from pending ones
        List<OneFund_Transactions__c> fundTransListUpdated1 = [SELECT Id,name,OneFund__C,Start_Date__c,Expiry_Date__c,Transaction_Status__c,Transaction_Amount__c
                                                  FROM OneFund_Transactions__c WHERE OneFund__c =:fundRecord5.id order by name];
            
        system.debug('fundTransListUpdated1::'+fundTransListUpdated1);
        system.assertEquals('Active', fundTransListUpdated1[0].Transaction_Status__c, 'name='+fundTransListUpdated1[0].name+' startdate='+fundTransListUpdated1[0].Start_Date__c+' status ='+fundTransListUpdated1[0].Transaction_Status__c);        
            
            //final transaction to keep it active
            List<OneFund_Transactions__c> fundTransListUpdated2 = [SELECT Id,name,OneFund__C,Start_Date__c,Expiry_Date__c,Transaction_Status__c,Transaction_Amount__c
                                                  FROM OneFund_Transactions__c WHERE OneFund__c =:fundRecord4.id order by name];
            system.debug('fundTransListUpdated2::'+fundTransListUpdated2);
        system.assertEquals('Active', fundTransListUpdated2[0].Transaction_Status__c, 'name='+fundTransListUpdated2[0].name+' expirydate='+fundTransListUpdated2[0].Expiry_Date__c+' status ='+fundTransListUpdated2[0].Transaction_Status__c);        
            
            //grace period test final transaction
            List<OneFund_Transactions__c> fundTransListUpdated3 = [SELECT Id,name,OneFund__C,Start_Date__c,Expiry_Date__c,Transaction_Status__c,Transaction_Amount__c
                                                  FROM OneFund_Transactions__c WHERE OneFund__c =:fundRecord6.id order by name];
            system.debug('fundTransListUpdated3::'+fundTransListUpdated3);
        system.assertEquals('Expired', fundTransListUpdated3[0].Transaction_Status__c, 'name='+fundTransListUpdated3[0].name+' expirydate='+fundTransListUpdated3[0].Expiry_Date__c+' status ='+fundTransListUpdated3[0].Transaction_Status__c);        
            
        
    }

}