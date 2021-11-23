trigger APTPS_AgreementTemplateTrigger on Apttus__APTS_Template__c (after insert, before update,before insert) {
    
    Map<Id, Apttus__APTS_Template__c> templateClauseMap = trigger.newMap;
    APTPS_TemplateTriggerHandler clausehandler = new APTPS_TemplateTriggerHandler();
    if(trigger.isBefore && trigger.isUpdate){
        clausehandler.updateAndCopyAutoNumber(templateClauseMap);
        clausehandler.updateClausewithApttusTemplate(templateClauseMap);        
    }        
    else if(trigger.isAfter && trigger.isInsert){
       clausehandler.insertAndCopyAutoNumber(templateClauseMap);
       clausehandler.insertClausewithApttusTemplate(templateClauseMap);       
    }
        
    
}