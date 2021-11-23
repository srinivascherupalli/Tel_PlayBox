/****************************************************************************
@Modified By: Shambo Ray
@CreateDate: 24/04/2018.
@Description: BillingStatusUpdate For Microservice 
********************************************************************************/
trigger BillingStatusUpdate on Billing_Account__c (after insert,after update) {
    BillingHandler blh=new BillingHandler(); 
    if(trigger.isafter && trigger.isupdate){
        Boolean fireEvent ;
        for(Billing_Account__c bill:trigger.new){
            fireEvent = fireEvent(trigger.newMap.get(bill.id),trigger.oldMap.get(bill.id));
            if( bill.IsUpdated__c == true  && ('Created'.equals(bill.Status__c) || 'Provisioned'.equals(bill.Status__c) || fireEvent)){
                System.debug('bill.Status__c: '+bill.Status__c);
                blh.onAfterUpdate(trigger.new);
            }
        }
        if(BillingHandler.runOnce()){
            for(Billing_Account__c bill:trigger.new){
                if('Allocated'.equals(bill.Status__c))
                    BillingOrderManager.createBillingAccount(string.valueof(bill.id));
            }
        }
    }
    else if(trigger.isafter && trigger.isinsert){
        blh.onAfterInsert(trigger.new); 
    }
    //EDGE-155621 - Fire event when status = Final, Pending Finalisation or PreDebt__c/Written_Off__c is updated.
    public boolean fireEvent(Billing_Account__c newBillAcc,Billing_Account__c oldBillAcc){
        Boolean fireEvent=false;
        if(newBillAcc.Status__c != oldBillAcc.Status__c && (newBillAcc.Status__c == 'Final'||newBillAcc.Status__c == 'Pending Finalisation')){
            fireEvent=true;
            System.debug('true in status');
        }
        if((newBillAcc.PreDebt__c != oldBillAcc.PreDebt__c)	 || (newBillAcc.Written_Off__c != oldBillAcc.Written_Off__c) || (newBillAcc.Retention__c != oldBillAcc.Retention__c)){
            fireEvent=true;
            System.debug('true in value change');
        }
        
        return fireEvent;
    }
}