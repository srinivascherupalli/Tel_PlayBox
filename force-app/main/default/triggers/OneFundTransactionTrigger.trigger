trigger OneFundTransactionTrigger on OneFund_Transactions__c (after insert, after update) {  
    
    OneFundTransactionTriggerHandler handler = new OneFundTransactionTriggerHandler();
        
    if(Trigger.isAfter){  
        if(Trigger.isInsert){
            handler.handleAfterInsertEvents(trigger.newmap.keyset());
        }
    }   
}