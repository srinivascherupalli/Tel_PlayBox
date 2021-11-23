trigger APTPS_FundTrigger on Fund__c (after update,before update) {
    
    //Id InitialRecordTypeId = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get('Initial_Credit').getRecordTypeId();
   Id InitialRecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Initial Credit').getRecordTypeId();
    
    List<Fund_Transaction__c> fundTransactions = new List<Fund_Transaction__c>();
    List<Fund_Transaction__c> fundTransactionsToBeDeleted = new List<Fund_Transaction__c>();
    Fund_Transaction__c fndTransaction;
   
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
            for(Fund__c fund : trigger.new)
            {
                fndTransaction = new Fund_Transaction__c();
                System.debug('Shishir fndTransaction: ' + fndTransaction);
                
                
                
                if(fund.APTPS_Accrual_Method__c == 'Annual'
                && fund.APTPS_Annual_Fund_Payment_Yr_1__c != Trigger.oldMap.get(fund.id).APTPS_Annual_Fund_Payment_Yr_1__c)
                {
                    for(Fund_Transaction__c fndTran : [select Id, Fund__c , RecordTypeId from Fund_Transaction__c where 
                         RecordTypeId =: InitialRecordTypeId and Fund__c =: fund.Id])
                     {
                         fundTransactionsToBeDeleted.add(fndTran);
                     }
                 
                    fndTransaction.Fund__c = fund.Id;
                    fndTransaction.APTPS_Fund_Approval_Status__c = 'Pending Approval';
					
					if('Active'.equals(fund.APTPS_Fund_Status__c)){
                        fndTransaction.APTPS_Fund_Approval_Status__c='Approved';
                    }
					
                    fndTransaction.APTPS_Action_Type__c = 'Initial Credit';
                    fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_1__c;
                    fndTransaction.RecordTypeId = InitialRecordTypeId;
                    //fndTransaction.APTPS_Agreement_Owner__c = fund.Agreement__r.Owner;
                    
                    fundTransactions.add(fndTransaction);
                }
                else if(fund.APTPS_Accrual_Method__c == 'Upfront' 
                && (fund.APTPS_Annual_Fund_Payment_Yr_1__c != Trigger.oldMap.get(fund.id).APTPS_Annual_Fund_Payment_Yr_1__c 
                || fund.Annual_Fund_Payment_Yr_2__c != Trigger.oldMap.get(fund.id).Annual_Fund_Payment_Yr_2__c 
                || fund.APTPS_Annual_Fund_Payment_Yr_3__c != Trigger.oldMap.get(fund.id).APTPS_Annual_Fund_Payment_Yr_3__c 
                || fund.APTPS_Annual_Fund_Payment_Yr_4__c != Trigger.oldMap.get(fund.id).APTPS_Annual_Fund_Payment_Yr_4__c 
                || fund.APTPS_Annual_Fund_Payment_Yr_5__c != Trigger.oldMap.get(fund.id).APTPS_Annual_Fund_Payment_Yr_5__c ))
                {
                    
                    for(Fund_Transaction__c fndTran : [select Id, Fund__c , RecordTypeId from Fund_Transaction__c where 
                         RecordTypeId =: InitialRecordTypeId and Fund__c =: fund.Id])
                     {
                         fundTransactionsToBeDeleted.add(fndTran);
                     }
                 
                    fndTransaction.Fund__c = fund.Id;
                    fndTransaction.APTPS_Fund_Approval_Status__c = 'Pending Approval';
					
					if('Active'.equals(fund.APTPS_Fund_Status__c)){
                        fndTransaction.APTPS_Fund_Approval_Status__c='Approved';
                    }
					
                    fndTransaction.APTPS_Action_Type__c = 'Initial Credit';
                    fndTransaction.RecordTypeId = InitialRecordTypeId;
                    //fndTransaction.APTPS_Agreement_Owner__c = fund.Agreement__r.Owner;
                    
                    fndTransaction.APTPS_Transaction_Amount__c = 0;
                    
                    if(fund.APTPS_Annual_Fund_Payment_Yr_1__c >= 0)
                    {
                        fndTransaction.APTPS_Transaction_Amount__c = fndTransaction.APTPS_Transaction_Amount__c + fund.APTPS_Annual_Fund_Payment_Yr_1__c;
                    }
                    
                    if(fund.Annual_Fund_Payment_Yr_2__c >= 0)
                    {
                        fndTransaction.APTPS_Transaction_Amount__c = fndTransaction.APTPS_Transaction_Amount__c + fund.Annual_Fund_Payment_Yr_2__c;
                    }
                    
                    if(fund.APTPS_Annual_Fund_Payment_Yr_3__c >= 0)
                    {
                        fndTransaction.APTPS_Transaction_Amount__c = fndTransaction.APTPS_Transaction_Amount__c + fund.APTPS_Annual_Fund_Payment_Yr_3__c;
                    }
                    
                    if(fund.APTPS_Annual_Fund_Payment_Yr_4__c >= 0)
                    {
                        fndTransaction.APTPS_Transaction_Amount__c = fndTransaction.APTPS_Transaction_Amount__c + fund.APTPS_Annual_Fund_Payment_Yr_4__c;
                    }
                    
                    if(fund.APTPS_Annual_Fund_Payment_Yr_5__c >= 0)
                    {
                        fndTransaction.APTPS_Transaction_Amount__c = fndTransaction.APTPS_Transaction_Amount__c + fund.APTPS_Annual_Fund_Payment_Yr_5__c;
                    }
                    if(fndTransaction.APTPS_Transaction_Amount__c != 0)
                    {
                    	fundTransactions.add(fndTransaction);
                    }
                    
                }
            }
        }
    }
    
    System.debug('Shishir fundTransactions: ' + fundTransactions);
    if(fundTransactions.size() > 0)
    {
        insert fundTransactions;
    }
    
    if(fundTransactionsToBeDeleted.size() > 0)
    {
        delete fundTransactionsToBeDeleted;
    }
}