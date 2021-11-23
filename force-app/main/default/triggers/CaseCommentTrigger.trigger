trigger CaseCommentTrigger on CaseComment (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
       CaseCommentTriggerHandler.updateChildComments(Trigger.new);
    }
}