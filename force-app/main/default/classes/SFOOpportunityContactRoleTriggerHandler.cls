/****************************************************************************
@Name			: SFOOpportunityContactRoleTriggerHandler
@TestCoverage   : SFOOpportunityContactRoleTriggerHandlerTest
@Author			: SFO(SanFrancisco)/Chhaveel
@Sprint 		: 21.09[P2OB-13775]
@CreateDate		: 25/06/2021
@Description	: This Class is for OpportunityContactRoleTriggerHandler Trigger
@Test Class     : ContactAccountRelationCheckTest
Note 			: Implemented Trigger FrameWork
********************************************************************************/

public without sharing class SFOOpportunityContactRoleTriggerHandler extends ATF_AbstractDomainHandler {

/****************************************************************************
@Method Name	: handleBeforeUpdate
@Author			: SFO(SanFrancisco)/Chhaveel
@Sprint 		: 21.09[P2OB-13775]
@CreateDate		: 25/06/2021
@Description	: This Method is triggered before insert 
********************************************************************************/       
    public override void handlebeforeInsert(){
        try{ 
            List<OpportunityContactRole> eventlist = trigger.new;
            for(OpportunityContactRole ocr: eventlist){
                List<opportunity> opp = [Select id, accountId from Opportunity where id =:ocr.OpportunityId Limit 1];
                // Checking if Contact and Account are related
                Boolean isError = ContactAccountRelationCheck.isRelated(opp[0].AccountId, ocr.ContactId);
                if(isError == false){
                    //throwing error if no relation found
                    ocr.ContactId.addError(System.label.Opportunity_Contact_Error);
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOOpportunityContactRoleTriggerHandler Class:::: handleBeforeInsert Method'+ Ex.getMessage());            
        }
    }   
    
/****************************************************************************
@Method Name	: handleBeforeUpdate
@Author			: SFO(SanFrancisco)/Chhaveel
@Sprint 		: 21.09[P2OB-13775]
@CreateDate		: 25/06/2021
@Description	: This Method is triggered before update 
********************************************************************************/       
    public override void handlebeforeUpdate(Map<id,SObject> oldTagetsObjectMap){
        try{ 
            List<OpportunityContactRole> eventlist1 = trigger.new;
            for(OpportunityContactRole ocr: eventlist1){
                List<opportunity> opp = [Select id, accountId from Opportunity where id =:ocr.OpportunityId Limit 1];
                // Checking if Contact and Account are related
                Boolean isError = ContactAccountRelationCheck.isRelated(opp[0].AccountId, ocr.ContactId);
                if(isError == false){
                    //throwing error if no relation found
                    ocr.ContactId.addError(System.label.Opportunity_Contact_Error);
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOOpportunityContactRoleTriggerHandler Class:::: handleBeforeUpdate Method'+ Ex.getMessage());            
        }
    }  
}