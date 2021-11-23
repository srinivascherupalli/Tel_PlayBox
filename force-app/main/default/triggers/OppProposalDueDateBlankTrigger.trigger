/*********************************************************************************************************
@Name: OppProposalDueDateBlankTrigger 
@Author: Mahaboob Subani
@CreateDate: 23/07/2018
@Description: To stop updation of Opportunity of Custom Recordtype with Null Proposal due Date
***********************************************************************************************************/
trigger OppProposalDueDateBlankTrigger on Opportunity (before update) {
    
    if(Trigger.isBefore && (Trigger.isUpdate)){  
        OppProposalDueDateTrigger_Handler OppProposalTriggerHandler=new OppProposalDueDateTrigger_Handler();
        OppProposalTriggerHandler.OpportunityProposalCheck(trigger.new);
    }
    
    
   
      
    }