/****************************************************************************
@Modified By: Shambo Ray
@CreateDate: 24/04/2018.
@Description: BillingHandler For Microservice 
********************************************************************************/
public class BillingHandler {
	public  static boolean run = true;
	public static boolean runOnce(){
		if(run){
			run=false;
			return true;
		}
		else {
			return run;
		}
	}
    
    public void onAfterInsert(List<Billing_Account__c> newList){
        List<Billing_Account__c> bAccList = new List<Billing_Account__c>();
        for(Billing_Account__c bAcc : newList){
            if(bAcc.Account__c != NULL){
                bAccList.add(bAcc);
            }
            if(!bAccList.isEmpty()){
                publishCreateEvents(bAccList,EventConstants.UPDATE_OPERATION); 
          }
       }
    }
    
    public void onAfterUpdate(List<Billing_Account__c> newList){
        publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
        publishCreateBillingEvents(newList,EventConstants.UPDATE_OPERATION);
    }    
    
    private void publishCreateEvents(List<Billing_Account__c> newList,String event){
       //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newList,EventConstants.BUSINESS_ENTITY_ACCOUNT,event);
        publishIntface.createEvent(); 
    }
    private void publishCreateBillingEvents(List<Billing_Account__c> newList,String event){
       //Dynamic Binding
        BillingPublishEvents publishIntface=BillingPublishEventsImpl.getInstance();
        publishIntface.createBillingEventObject(newList,EventConstants.BILLING_ACCOUNT,event);
        publishIntface.createBillingEvent(); 
  } 
}