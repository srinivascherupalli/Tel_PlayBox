/**
 * @description       : 
 * @author            : Rohit Pal
 * @group             : 
 * @last modified on  : 10-22-2021
**/
trigger SubscriptionProcessStep on Coms_Subscription_PE__e (after insert) {
    String THREAD_NUM = '0';
    Integer counter = 0; 
    string strPayload;
    string orchestrationProcessName;
    integer intStepNumber; 
    for (Coms_Subscription_PE__e event : Trigger.New) { 
        System.debug(' event ==> ' + event );  
        String sequnceNumber = event.Sequence__c;
        String threadSelector = sequnceNumber.substring((sequnceNumber.length()-1), (sequnceNumber.length()));
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
        Coms_SubscriptionParallelismUtil.process(strPayload, orchestrationProcessName, intStepNumber);                   
    }
}