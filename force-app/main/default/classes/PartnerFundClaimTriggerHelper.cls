/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   15/5/2020
Jira                :   P2OB-6000
Desc                :   This class is called from PartnerFundClaimTrigger to show error when status is approved
						and Final approver does not have required permission
***********************************************************************/
public without sharing class PartnerFundClaimTriggerHelper {
	
    Private Static boolean runOnce = false;
    private Static Final String CLAIM_STATUS_APPROVED = 'Approved';
    private static final String CLAIM_ERROR_MESSAGE = Label.PRM_CLAIM_ERROR_MESSAGE;
    Private PRM_Funds_Management__c prmCustSet;
    
    //Default constructor : This constructor is invoked when PartnerFundClaimTriggerHelper class initialize from PartnerFundClaimTrigger 
    public PartnerFundClaimTriggerHelper(){
        //Get instance of PRM_Funds_Management__c custom setting
    	prmCustSet = PRM_Funds_Management__c.getInstance();
    }
	
    /*This method is called from trigger 'PartnerFundClaimTrigger'.If user does not have required permissio to approve record
      it shows error.*/
    Public Void checkClaimCanBeApproved(List<PartnerFundClaim> newClaim,Map<Id,PartnerFundClaim> oldClaimMap){
        //claim Amount
        Decimal claimAmount = prmCustSet != Null && prmCustSet.Claim_Amount__c != Null ? prmCustSet.Claim_Amount__c : 25000;
        String PRMPartnerClaimFinalApprover = prmCustSet != Null && String.IsNotBlank(prmCustSet.Custom_Permission_For_Approval__c) ? prmCustSet.Custom_Permission_For_Approval__c : '';
        String claimApproverError = prmCustSet != Null && String.IsNotBlank(prmCustSet.Claim_Approver_Error__c) ? prmCustSet.Claim_Approver_Error__c : CLAIM_ERROR_MESSAGE;
        Boolean isSecondLevelApprovalRequired = prmCustSet != Null ? prmCustSet.Is_Second_Level_Approval_Required__c : false;
        // check login user has second Level approval permission
        Boolean hasSecondApprovalPermission = checkUserHasValidPermission(PRMPartnerClaimFinalApprover);
        //Check to avoid recursion 
        if(!runOnce){
            runOnce = true;
            for(PartnerFundClaim claim : newClaim){
                //Check values are not null and status is changed to Approved
                if(oldClaimMap.get(claim.Id).Status != Null && claim.Status != Null && claim.Status != oldClaimMap.get(claim.Id).Status && claim.Status == CLAIM_STATUS_APPROVED && claim.Amount != Null && claim.Amount >= claimAmount && isSecondLevelApprovalRequired && !hasSecondApprovalPermission){
                    //Show error message
                    claim.addError(claimApproverError);
                }
            }
    	}
    }
    
    // This method check if user has required permission to approve the second level claim
    Public Static Boolean checkUserHasValidPermission(String PRMPartnerClaimFinalApprover){
        if(String.isNotBlank(PRMPartnerClaimFinalApprover)){
        	return FeatureManagement.checkPermission(PRMPartnerClaimFinalApprover);
        }
        return false;
    }
}