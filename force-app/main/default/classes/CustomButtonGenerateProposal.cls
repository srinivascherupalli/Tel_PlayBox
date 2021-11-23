/*
* @Author :  Srujana Durvasula
* @Date   :  12 Jan 2021
* @Desc   :  <Cloudsense> <Proposal Builder> Proposal Word document generation
* @Jira   :  P2OB-11268 
*/
	global with sharing class CustomButtonGenerateProposal extends csbb.CustomButtonExt {
    	public String performAction(String basketId) {
        //return	 createProposal(basketId);
         return null;
    }
	/*
    public static String createProposal(String basketId){
        boolean canCreateProposal = performValidations(basketId); 
        if(canCreateProposal) {
        	String templateID = null;

            String templateName = System.Label.DIP_NonAdaptiveNetworksTemplateName;  //added related to P2OB-13187


        	List<APXTConga4__Conga_Template__c> templateList = [SELECT Id,APXTConga4__Name__c 
                                                                FROM APXTConga4__Conga_Template__c 
                                                                WHERE APXTConga4__Name__c =: templateName 
                                                                ORDER BY APXTConga4__Name__c LIMIT 1];
        	if(templateList.size()>0){
        		templateID = templateList[0].id;
        		templateID = templateID.substring(0,templateID.length() - 3);    
        	}
        	return GenerateProposalHelper.createProposal(templateID, basketId);
        } else {
            return '{"status":"error","text":"Proposals can only be created by members of the Opportunity Team. Please contact the Opportunity Owner to request for new members to be added."}';
        }
      //  String response = GenerateProposalHelper.createProposal(templateID, basketId);
      //  System.debug('Create Proposal Response: '+response);
    }
	
    public static Boolean performValidations(String basketId) {
        Boolean proposalGenerationAllowed = false;
    	String currentUserId = UserInfo.getUserId();
		List<OpportunityTeamMember> listOfOppsTM=[SELECT Id, UserId 
                                                FROM OpportunityTeamMember 
                                                WHERE OpportunityId IN 
                                                (SELECT cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE Id = :basketId)
                                                ];
         system.debug('TM Size: '+listOfOppsTM.size());
         if(listOfOppsTM.size()>0){
        	for(OpportunityTeamMember oppTM : listOfOppsTM){
        		system.debug('TM Id: '+oppTM.UserId);
        		if(oppTM.UserId == currentUserId){
        			proposalGenerationAllowed = true;
                    break;
                } else {
                    continue;
                }
            }
         }
		//System.debug('proposalGenerationAllowed: ' + proposalGenerationAllowed);
		return proposalGenerationAllowed;    
    }*/
}