/**
* Author: Shreyansh Sharma
* Team: Jaipur
* Sprint: 19.16
* Date: 11/20/2019
* Description: Controller class for cusdl_orb_approval lightning component - P2OB-4171
* Updates: P2OB-10467, button visibility on case stages 'ORB Solution Review' and 'Proposed'
* Modified by and date: Shreyansh Sharma  11/02/2020
**/
public with sharing class cusdl_orbApprovalController {
     Private static String reqFields = System.label.cusdl_Required_field_message;
     Private static string successMsg = System.label.cusdl_Bid_record_success;
     Private static string errorMessage = System.label.cusdl_Bid_record_success;
     Private static string successMsgNewButton = 'modifySolButton';
    
    @AuraEnabled
    public static String getCaseValues(String caseId, String contextVar){
        Case cs = [Select id,OpportunityId__c,cusdl_Bid_Status__c,Stage__c,cusdl_Techscore__c,OpportunityId__r.OwnerId,cusdl_Opty_been_Identified_Qualifieds__c,cusdl_The_Compelling_Events__c,cusdl_Win_Strategy_And_Why_Telstra__c,cusdl_Customer_s_current_environment__c,
                   cusdl_Technical_or_service_issues__c,cusdl_Key_Deliverables_and_Milestones__c,cusdl_Billing_Requirements__c,cusdl_Third_Party_Engagement__c,cusdl_Carriage_and_standard_product__c,cusdl_Third_parties__c,cusdl_Once_off_costs__c,
                   cusdl_Telstra_services__c,cusdl_Pricing_Type__c,cusdl_Benchmarking_Requirements__c,cusdl_Details__c,cusdl_non_standard_contract_pricing_oct__c,cusdl_Proposal_Due_Date__c FROM Case where id =:caseId];
        
        
        //P2OB-4219//
        //set Error message accordingly
        //P2OB:8329, remove Bid Governance reference and check for Case status and stage to toggle button visibility
        if(cs!=NULL){
            if(contextVar == 'onLoad'){
                if((cs.cusdl_Bid_Status__c == 'Rejected' || cs.cusdl_Bid_Status__c == 'BRM Review') && (cs.Stage__c == 'Requirement Analysis' || cs.Stage__c == 'New' || cs.Stage__c == 'Assignment Pending')){
                    errorMessage = successMsg;
                }
                //P2OB-10467 Set visibility for modify solution button
                else if(cs.Stage__c == 'ORB Solution Review' || cs.Stage__c == 'Proposed'){
                    errorMessage = 'modifySolButton';
                }
                
                else {  errorMessage = 'Bid';}
            }
            else  if(contextVar == 'onClick'){
                if(cs.OpportunityId__c ==NULL || cs.OpportunityId__r.OwnerId ==NULL ||cs.cusdl_Opty_been_Identified_Qualifieds__c ==NULL || cs.cusdl_The_Compelling_Events__c ==NULL || cs.cusdl_Win_Strategy_And_Why_Telstra__c==NULL || cs.cusdl_Customer_s_current_environment__c==NULL ||
                   cs.cusdl_Technical_or_service_issues__c==NULL || cs.cusdl_Key_Deliverables_and_Milestones__c==NULL || cs.cusdl_Billing_Requirements__c==NULL || cs.cusdl_Third_Party_Engagement__c==NULL || cs.cusdl_Carriage_and_standard_product__c==NULL || cs.cusdl_Third_parties__c==NULL || cs.cusdl_Once_off_costs__c==NULL ||
                   cs.cusdl_Telstra_services__c==NULL || cs.cusdl_Pricing_Type__c==NULL || cs.cusdl_Benchmarking_Requirements__c==NULL || cs.cusdl_Details__c==NULL || cs.cusdl_non_standard_contract_pricing_oct__c==NULL || cs.cusdl_Proposal_Due_Date__c==NULL ){
                       
                       errorMessage = reqFields;
                   }
            }
            else  if(contextVar == 'onClickModifySol'){
                captureSolutionDetails(caseId,contextVar);
            }
        }
        return errorMessage;
    }
    //Shreyansh Sharma ,Jaipur 11/2/2020
    //P2OB-10467, Button visibility on case stages 'ORB Solution Review' and 'Proposed'
    @AuraEnabled
    public static string captureSolutionDetails(String caseId, String contextVar){
        
        Case cs = [Select id,OpportunityId__c,cusdl_Pricing_Approval_Date__c,cusdl_Pricing_Expiry_Date__c,cusdl_SBC_Approval_Date__c,cusdl_Board_Review_Date__c,
                   cusdl_Quality_Approval_Date__c,cusdl_Pricing_Approver__c,cusdl_Quality_Approver__c,cusdl_Quality_Approval_Link__c,
                   cusdl_Pricing_Approval_Link__c FROM Case where id =:caseId];
        
        if(cs.cusdl_Pricing_Approval_Date__c == NULL || cs.cusdl_Pricing_Expiry_Date__c == NULL || cs.cusdl_SBC_Approval_Date__c == NULL ||
           cs.cusdl_Quality_Approval_Date__c == NULL || cs.cusdl_Pricing_Approver__c == NULL || cs.cusdl_Quality_Approver__c == NULL ||
           cs.cusdl_Quality_Approval_Link__c == NULL || cs.cusdl_Pricing_Approval_Link__c == NULL || cs.cusdl_Board_Review_Date__c == NULL){
               
               errorMessage = reqFields;
           }
        else{
            Id recordTypeId = Schema.SObjectType.soc_Case_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Custom_Deal_Line_Items').getRecordTypeId();
            
            soc_Case_Line_Item__c cli = new soc_Case_Line_Item__c();
            cli.RecordTypeId = recordTypeId;
            cli.soc_CaseId__c = cs.id;
            cli.cusdl_Pricing_Approval_Date__c =  cs.cusdl_Pricing_Approval_Date__c;
            cli.cusdl_Pricing_Expiry_Date__c =  cs.cusdl_Pricing_Expiry_Date__c;
            cli.cusdl_SBC_Approval_Date__c =  cs.cusdl_SBC_Approval_Date__c;
            cli.cusdl_Quality_Approval_Date__c =  cs.cusdl_Quality_Approval_Date__c;
            cli.cusdl_Pricing_Approver__c =  cs.cusdl_Pricing_Approver__c;
            cli.Quality_Approver__c =  cs.cusdl_Quality_Approver__c;
            cli.cusdl_Pricing_Approval_Link__c =  cs.cusdl_Pricing_Approval_Link__c;
            cli.cusdl_Quality_Approval_Link__c = cs.cusdl_Quality_Approval_Link__c;
            cli.cusdl_ORB_Approval_Date__c = cs.cusdl_Board_Review_Date__c;
            insert cli;
            errorMessage = successMsgNewButton;
        }
        return errorMessage;
    }
}