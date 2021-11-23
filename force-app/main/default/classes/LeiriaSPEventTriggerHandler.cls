/****************************************************************************
@Name: LeiriaSPEventTriggerHandler
@Author: Leirie/Ravi Dodiya
@CreateDate: 20/07/2021
@Sprint : 21.10[DIGI-458]
@Description: This Class is for SharePointEvent Trigger - DIGI-458, to get the test coverage 
			  using the class LeiriaSPEventTriggerHandlerTest
Note : Implemented Trigger FrameWork
@Last Modified        : 
*****************************************************************************/
public class LeiriaSPEventTriggerHandler  extends ATF_AbstractDomainHandler {

    /****************************************************************************
    @Method Name: handleAfterInsert
    @Author: Leirie/Ravi Dodiya
    @Sprint : 20.10[DIGI-458]
    @CreateDate: 20/07/2021
    @Description: This Method is triggered after insert to publish sharepoint platform 
				event - Sharepoint HVPE
    ******************************************************************************/      
    public override void handleAfterInsert(){        
        try{            
            List<SharePointPlatformEventHV__e> SPEventtoPublish = new List<SharePointPlatformEventHV__e>();
            for(SharePointEvent__c spe : (List<SharePointEvent__c>) Trigger.new) {
				SharePointPlatformEventHV__e SPevent = new SharePointPlatformEventHV__e();
					SPevent.Event_Code__c = spe.Event_Code__c ;
					SPevent.Event_ID__c = spe.Id ;
					SPevent.Event_Payload__c = spe.Event_Payload__c ;
				
				SPEventtoPublish.add(SPevent);
            }
			List<Database.SaveResult> saveResultsHV = null;
			// Publish the Sharepoint HVPE
            if(SPEventtoPublish.size()>0){
				saveResultsHV = EventBus.publish(SPEventtoPublish);
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: LeiriaSPEventTriggerHandler Class:::: handleAfterInsert Method'+ Ex.getMessage());            
        }
    }
}