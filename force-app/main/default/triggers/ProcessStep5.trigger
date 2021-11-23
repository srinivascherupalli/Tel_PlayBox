/**
 * @description       : 
 * @author            : Rohit Pal
 * @group             : 
 * @last modified on  : 10-22-2021
**/
trigger ProcessStep5 on Coms_Step_PE__e (after insert) {
    String THREAD_NUM = '5';
    Integer counter = 0; 
    string strPayload;
    string orchestrationProcessName;
    integer intStepNumber;
    for (Coms_Step_PE__e event : Trigger.New) { 
        System.debug(' event ==> ' + event );  
        if(event.Sequence__c == THREAD_NUM){
            counter++;
            if(counter>1){
                break;
            }
            strPayload = event.Payload__c;
            orchestrationProcessName = event.Orchestration_Process_Name__c;
            intStepNumber = integer.valueof(event.Step_Number__c);
        }
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
    }
    if(string.isNotBlank(strPayload) && string.isNotBlank(orchestrationProcessName) && intStepNumber != null){
        Coms_OrderParallelismUtil.process(strPayload, orchestrationProcessName, intStepNumber);                   
    }
}