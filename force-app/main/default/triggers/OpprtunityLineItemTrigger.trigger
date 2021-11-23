trigger OpprtunityLineItemTrigger on OpportunityLineItem (before insert, before update) {
    if(EnvironmentalSettings.isTriggerDisabled('OpprtunityLineItemTrigger')) {
        return;
    }
    System.debug('----------> OpportunityLineItem');
    for(OpportunityLineItem oli : Trigger.new) {
        if(oli.Description != NULL)
        {
            oli.Description  = oli.Description .replace('------------', '');
            oli.Description  = oli.Description .replace('--------', '');
            oli.Description  = oli.Description .replace('----', '');
            oli.Description = !String.isEmpty(oli.Description) ? oli.Description.split(' x ',2).get(0) : '';
        }
    }
    /*
Team SFO, sprint 20.08, P2OB-6818(Sravanthi)  
 BeforeInsert & BeforeUpdate Calls
*/
    OpportunityLineItemTriggerHandler handler=new OpportunityLineItemTriggerHandler();
    if(trigger.isBefore && trigger.isInsert){
        handler.OnBeforeInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        handler.onBeforeUpdate(Trigger.OldMap,Trigger.new);      
    }
}