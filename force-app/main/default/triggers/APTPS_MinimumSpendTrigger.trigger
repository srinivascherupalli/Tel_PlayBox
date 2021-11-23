/*****************************************************************
@Name: APTPS_MinimumSpendTrigger
@Author: Shishir Bose
@CreateDate: 01/03/2017 
@Description: This is the trigger on Minimum Spend
******************************************************************/ 
trigger APTPS_MinimumSpendTrigger on APTPS_Minimum_Spend_Entry__c (after update) {
    
    Map<Id, Decimal> currentMinSpendOnLineItems = new Map<Id, Decimal>();
    List<Apttus__AgreementLineItem__c> lineItemsToBeUpdate = new List<Apttus__AgreementLineItem__c>();
    
    for(APTPS_Minimum_Spend_Entry__c minSpend : trigger.new)
    {
        if(minSpend.APTPS_Current_Minimum_Spend__c != Trigger.oldMap.get(minSpend.Id).APTPS_Current_Minimum_Spend__c)
        {
            if(!currentMinSpendOnLineItems.containsKey(minSpend.APTPS_Agreement_Line_Item__c))
            {
                currentMinSpendOnLineItems.put(minSpend.APTPS_Agreement_Line_Item__c, minSpend.APTPS_Current_Minimum_Spend__c);
            }
        }
    }
    
    for(Apttus__AgreementLineItem__c lineItem : [Select Id, APTPS_Current_Period_Minimum_Spend__c from Apttus__AgreementLineItem__c where Id in : currentMinSpendOnLineItems.keySet()])
    {
        lineItem.APTPS_Current_Period_Minimum_Spend__c = currentMinSpendOnLineItems.get(lineItem.Id);
        lineItemsToBeUpdate.add(lineItem);
    }
    
    if(lineItemsToBeUpdate.size() > 0)
    {
        update lineItemsToBeUpdate;
    }
}