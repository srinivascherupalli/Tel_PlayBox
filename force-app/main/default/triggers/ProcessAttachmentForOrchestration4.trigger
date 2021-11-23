/********************************************************************************
* Class Name  : ProcessAttachmentForOrchestration 
* Description : Platform Event Trigger
* Created By  : Sarv
* Change Log  : 10 JUl 2021 - Created
********************************************************************************/
trigger ProcessAttachmentForOrchestration4 on ProcessAttachmentForOrchestration__e (after insert) {
    String THREAD_NUM = '4';
    Integer counter = 0; 
    List<String> listOfKey = new List<String>();
    List<String> listOfHandler = new List<String>();
    System.debug(' ProcessAttachmentForOrchestration4 ==> '  );
    
    for (ProcessAttachmentForOrchestration__e event : Trigger.New) { 
        String sequnceNumber = event.Sequence__c;
        String threadSelector = sequnceNumber.substring((sequnceNumber.length()-1), (sequnceNumber.length()));
        if(threadSelector == THREAD_NUM){
            counter++;
            if(counter>1){
                break;
            }
            listOfKey.add(event.ServiceIds__c);
            listOfHandler.add(event.PlatformCacheHandler__c);
        }
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
    }
    if(!listOfKey.isEmpty()){
        OrchestrationCacheBackupHelper.processAttachment(listOfKey[0], listOfHandler[0]);
    }
}