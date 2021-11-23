trigger RoleAlignmentTrigger on Role_Alignment__c (before insert,before Update) {

   RoleAlignmentHelper rolealgnmethlpr = new RoleAlignmentHelper();
   
    if((trigger.isBefore && Trigger.isInsert)){
        rolealgnmethlpr.RoleAligmentLV6NameUniquenessCheck(trigger.new);
        
    }
    
    else if(Trigger.isBefore && Trigger.isUpdate){
         rolealgnmethlpr.RoleAligmentLV6NameUniquenessCheckOnUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
       
    }
}