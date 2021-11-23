/*
* @Author : Robin/Ritika
* @Date : 5 June 2019
* @Desc : IntegrationQueueHandler for sending callout to Tramas-TM1 (for Mobile Transition)
* @Jira Cloud : EDGE-85155
*/
public class TM1EligibilityCheckHandlerV2  extends IntegrationQueueHandler{
    public TM1EligibilityCheckHandlerV2() {
        super(TM1EligibilityCheckHandlerV2.class.getName());
    }

    // It is overriden method for Queueable class 
    public override void executeWork(List<String> params) {
        System.debug('Execute work:'+params.size());       
        if( params.size() > 0){
        //future method for making callout to TM1-interface and adding the response details in Salesforce-records        
            TM1EligibilityCheckServiceV2.sendEligibilityCheckRequest(params.get(0));
        }                
    }
}