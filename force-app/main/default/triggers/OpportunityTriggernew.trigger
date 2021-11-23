trigger OpportunityTriggernew on opportunity (before insert, before update, before delete, 
                                       after insert, after update, after delete, 
                                       after undelete) {
     OpportunityTriggernewhandler handler = new OpportunityTriggernewhandler();
       if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new); 
       }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new);  
    }
    
  
}