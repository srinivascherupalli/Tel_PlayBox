public class Coms_ServiceParallelismUtil{
    // strPayload -- json with the values of Key - vlaue pair
    // CacheMetaDataResponses [Field -> Payload ,  OrchestrationProcessName,StepNumber]
    // we will write a schedule job to update the above object and insert into cache - later 
    // orchestrationProcessName - 'Order , Service , Subscription' static text
    // it can be called from anywhere from 'Order , Service , Subscription' class
    //CSPOFA__Orchestration_Step__c
    public static void process( string strPayload , 
                                string orchestrationProcessName,
                                integer intStepNumber){
        string unquiueKey;
        System.debug('Coms_ParallelismUtil :: process :: found strPayload ---> ' + strPayload + ' orchestrationProcessName--->' +orchestrationProcessName + ' intStepNumber---> '+ intStepNumber);
        //Coms_ParallelismUtil.process(objCSPOFAOrchestrationStep, strPayload, orchestrationProcessName, strClassName)                   
        // pass the above parameetrs as it it to the other class  [ apex class name ]  Metadata
        // unquiue  - CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name '-' CSPOFA__Step_Order__c
        // orchestrationProcessName - intStepNumber
        //Coms_ParallelismUtil.process(strPayload, orchestrationProcessName, strStep); Change to all the platform trigger.
        unquiueKey = orchestrationProcessName+'-'+intStepNumber;
        System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
        switch on unquiueKey {
            when 'Service Fulfilment Process_New-3'{
               // Orchestration_EvaluateSubStatus_Handler eval = new Orchestration_EvaluateSubStatus_Handler();
              //  eval.evaluateSubscription(strPayload);
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }/*when 'Service Fulfilment Process_New-2'{
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
            when 'Service Fulfilment Process_New-5' {
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }when 'Service Fulfilment Process_New-4'{
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }*/
        }
    }
}