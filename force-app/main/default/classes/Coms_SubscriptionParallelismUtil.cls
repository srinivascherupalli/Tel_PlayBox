public class Coms_SubscriptionParallelismUtil{
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
        String temp=orchestrationProcessName.substringBeforeLast('_');
        unquiueKey=unquiueKey.replaceAll(temp, 'Sub');                   
        System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
        OrchestrationStepDetails__c s1  =OrchestrationStepDetails__c.getvalues(unquiueKey);
        //system.debug(s1.OrchClassname__c);         
        Orchestration_StepInterface instance=(Orchestration_StepInterface)Type.forName(s1.OrchClassname__c).newInstance();
        instance.processUpdate(strPayload);
        system.debug('Invoked method: '+s1.OrchClassname__c);
        /*switch on unquiueKey {
            when 'Subscription Fulfilment Process_Provision-4'{
                //GeneratePriceScheduleRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
               // Orchestration_GeneratePriceSch_Handler handler = new Orchestration_GeneratePriceSch_Handler();
               // handler.processUpdate(strPayload);
            }when 'Subscription Fulfilment Process_Provision-5'{
                //PostSubscriptionAPIRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
              //  Orchestration_OrdertoBillUpdate_Handler handler = new Orchestration_OrdertoBillUpdate_Handler();
              //  handler.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Provision-7' {
                //UpdateAccountStatusRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_AccountStatsUpd_V2_Handler handler = new Orchestration_AccountStatsUpd_V2_Handler();
                handler.processUpdate(strPayload);
            }when 'Subscription Fulfilment Process_Provision-9'{
                //EvaluateOrderStatusRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_EvaluateOrderStats_Handler eval = new Orchestration_EvaluateOrderStats_Handler();
                eval.processUpdate(strPayload);
            }when 'Subscription Fulfilment Process_Provision-13'{
                //UpdateSubscriptionData
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_UpdSubsData_Handler eval = new Orchestration_UpdSubsData_Handler();
                eval.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Activation-2'{
                //GeneratePriceScheduleRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_GeneratePriceSch_Handler handler = new Orchestration_GeneratePriceSch_Handler();
                handler.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Activation-4'{
                //PostSubscriptionAPIRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_OrdertoBillUpdate_Handler handler = new Orchestration_OrdertoBillUpdate_Handler();
                handler.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Activation-12'{
                //PostSubscriptionAPIRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_OrdertoBillUpdate_Handler handler = new Orchestration_OrdertoBillUpdate_Handler();
                handler.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Activation-14'{
                //AccountStatusUpdate
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_AccountStatsUpd_V2_Handler handler = new Orchestration_AccountStatsUpd_V2_Handler();
                handler.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Activation-19'{
                //EvaluateOrderStatusRF
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_EvaluateOrderStats_Handler eval = new Orchestration_EvaluateOrderStats_Handler();
                eval.processUpdate(strPayload);
            }
            when 'Subscription Fulfilment Process_Activation-20'{
                //UpdateSubscriptionData
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
                Orchestration_UpdSubsData_Handler eval = new Orchestration_UpdSubsData_Handler();
                eval.processUpdate(strPayload);
            }
        }*/
    }

}