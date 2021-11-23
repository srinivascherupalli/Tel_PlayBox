/****************************************************************************
   @Name: ContentVersionTrigger.
   @Author: Chandrakant Wani.
   @CreateDate: 16/12/2021.
   @Description: P2OB-12607 This is a Trigger on ContentVersion object for linking file 
   upload by integration user with record
  
 ********************************************************************************/

trigger ContentVersionTrigger on ContentVersion (after insert) {

    if(Trigger.isAfter && Trigger.isInsert) {
        ContentVersionTriggerHelper.attachFileToRecord(Trigger.new);
    }
}