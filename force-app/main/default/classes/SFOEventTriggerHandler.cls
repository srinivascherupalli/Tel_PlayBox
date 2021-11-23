/****************************************************************************
@Name: SFOEventTriggerHandler
@Author: SFO/Vamshi
@CreateDate: 09/04/2020
@Sprint : 20.05[P2OB-5475]
@Description: This Class is for EventTrigger Trigger - P2OB-5475, to get the test coverage 
using the class SFOEventTriggerHandlerTest
Note : Implemented Trigger FrameWork
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*****************************************************************************/
public without sharing class SFOEventTriggerHandler extends ATF_AbstractDomainHandler {
    /****************************************************************************
    @Method Name: handleBeforeInsert
    @Author: SFO/Vamshi
    @Sprint : 20.05[P2OB-5475]
    @CreateDate: 09/04/2020
    @Description: This Method is triggered before insert to update Standard Name field on Event with 
    custom activity field called "Contact__c"
    ******************************************************************************/      
    public override void handlebeforeInsert(){
        try{ 
            List<Event> eventlist = trigger.new;
            for(Event eventRecord: eventlist){
                 if(eventRecord.whatId != null && String.valueOf(eventRecord.whatId).startsWith('001') && eventRecord.contact__c != null){
                     eventRecord.whoid = eventRecord.contact__c;
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOeventTriggerHandler Class:::: handleBeforeInsert Method'+ Ex.getMessage());            
        }
    }    
}