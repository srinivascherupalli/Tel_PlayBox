/*************************************************************************************************************
 * @name            Coms_ParallelismUtil
 * @author          BLR\rohit.pal <rohit.pal@crmit.com>
 * @created         07 / 09 / 2021
 * @description     Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2021-09-07      BLR\rohit.pal           Changes desription
 *
**************************************************************************************************************/
public with sharing class Coms_OrderParallelismUtil {

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
        unquiueKey=unquiueKey.replaceAll(temp, 'Order');                   
        System.debug('Coms_OrderParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
        OrchestrationStepDetails__c s1  =OrchestrationStepDetails__c.getvalues(unquiueKey);
        system.debug(s1.OrchClassname__c);         
        Orchestration_StepInterface instance=(Orchestration_StepInterface)Type.forName(s1.OrchClassname__c).newInstance();
        instance.processUpdate(strPayload);
        system.debug('Invoked method: '+s1.OrchClassname__c);
                                    
       /* switch on unquiueKey {
            when 'Order Fulfilment Process_New-2'{
                Orchestration_RecreateDelSpecsV1_Handler handler = new Orchestration_RecreateDelSpecsV1_Handler();
                handler.processUpdate(strPayload);
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }when 'Order Fulfilment Process_New-3'{
                Orchestration_CreateLegacyServ_Handler handler = new Orchestration_CreateLegacyServ_Handler();
                handler.processUpdate(strPayload);
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
            /*when 'Order Fulfilment Process_New-4' {
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }*//*when 'Order Fulfilment Process_New-5'{
              // Orchestration_OrderDeltaChange_Handler handler = new Orchestration_OrderDeltaChange_Handler();
              //  handler.processUpdate(strPayload);
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }when 'Order Fulfilment Process_New-6'{
                Orchestration_LinkNumAndServV1_Handler handler = new Orchestration_LinkNumAndServV1_Handler();
                handler.processUpdate(strPayload);
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
            when 'Order Fulfilment Process_New-7'{
                Orchestration_GenTransDataV1_Handler handler = new Orchestration_GenTransDataV1_Handler();
                handler.processUpdate(strPayload);
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
            /*when 'Order Fulfilment Process_New-13'{
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
            when 'Order Fulfilment Process_New-10'{
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
            when 'Order Fulfilment Process_New-11'{
                System.debug('Coms_ParallelismUtil :: process :: found unquiueKey ---> ' + unquiueKey);
            }
        }*/
    }
  
     public static void updateStepStatus(Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails){
        //CSPOFA__Orchestration_Step__c step = [Select id,CSPOFA__Message__c,CSPOFA__Status__c from CSPOFA__Orchestration_Step__c where id=:stepid];
        List<Database.SaveResult> updateResult = Database.update(mapStepDetails.values(), false);
      // step.CSPOFA__Message__c= msg;
       // step.CSPOFA__Status__c=stepStatus; 
        //update step;
        for(Database.SaveResult result: updateResult){
            if (result.isSuccess()) {
                System.debug('Successfully updated step status ==> ' + result );
            } else {
                for(Database.Error err : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage()); 
                }
            }
        }
    }
}