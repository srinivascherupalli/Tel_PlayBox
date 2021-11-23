/*****************************************************************************
@Name			: OppProposalDueDateTrigger_Handler
@Author			: Mahaboob Subani
@CreateDate		: 23/07/2018
@Description	: This Class is Helper for OppProposalDueDateTrigger Trigger
@Last Modified  : 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified  : 
*******************************************************************************/
public with sharing class OppProposalDueDateTrigger_Handler {
    
    public  void OpportunityProposalCheck(list<Opportunity> newList ){
        try{
            Id myRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Custom).getRecordTypeId();
            if( !(FeatureManagement.checkPermission('Integration_Datahub') || 
                  FeatureManagement.checkPermission('System_Administrator') || FeatureManagement.checkPermission('SharePoint_Integration_Permission'))){
                      for(Opportunity opp : newList){      
                          if((opp.RecordTypeId == myRecordType) && (opp.Proposal_Required_Date__c== null)&& (opp.StageName != System.label.Opp_Stage_ClosedLost)){
                              opp.addError(System.label.Opp_Proposal_Due_Date_Error);
                          }
                      }
                  }
        }catch(Exception Ex){
            system.debug('Exception:--->OppProposalDueDateTrigger_Handler Class,OpportunityProposalCheck Method'+ Ex.getMessage());
        }
    }    
}