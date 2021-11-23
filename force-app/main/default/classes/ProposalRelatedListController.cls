/*****************************************************************************
@Name : ProposalRelatedListController
@Description : This class is controller class for ProposalRelatedList,CreateProposalModal Aura component. 
@Created by : Shishir Pareek as part of P2OB-13163.
@Description : Logic to get Proposal Created Data for given Opportunity Id and to execute flow from button.
*******************************************************************************/
public class ProposalRelatedListController {
	public static List<ProposalListWrapper> listOfProposalWrapper = new List<ProposalListWrapper>();
    /* 
     * This method will fetch all the proposal data based on the opportunity and send this to lightning component,  
	*/
    @AuraEnabled
    public static List<ProposalListWrapper> getOpportunityFromId(String oppId)
    {	
        SharePoint_Proposal_URL_Prefix__c prefix = SharePoint_Proposal_URL_Prefix__c.getInstance('Non Prod URL Prefix');
        Opportunity opportunityToReturn = [Select Id, Proposal_Documents__c 
                                           FROM Opportunity 
                                           WHERE Id =:oppId];


        if(opportunityToReturn != null && !String.isEmpty(opportunityToReturn.Proposal_Documents__c)) {


            String jsonStringAfterProcessing = opportunityToReturn.Proposal_Documents__c.replaceFirst('"', '');
            jsonStringAfterProcessing = jsonStringAfterProcessing.replace(']"', ']');
            listOfProposalWrapper = (List<ProposalListWrapper>)JSON.deserialize(jsonStringAfterProcessing, List<ProposalListWrapper>.class);
            for(ProposalListWrapper obj : listOfProposalWrapper) {
        	    obj.fileUrl = prefix.Prefix_URL__c + obj.fileUrl; 
            }
            //listOfProposalWrapper.sort();
           //System.debug(listOfProposalWrapper.sort());
        }
        listOfProposalWrapper.sort();
        return listOfProposalWrapper;
    }
    
    /* 
     * This method will fetch all propposal for Infinite loading the list until the all the proposal is showing, 
	*/
    @AuraEnabled
    public static List<ProposalListWrapper> getProposal(Integer offSet, Integer numberOfRows, String oppId) {
        listOfProposalWrapper = getOpportunityFromId(oppId);
        Integer lastLimit;
        if((offSet + numberOfRows) < listOfProposalWrapper.size()) {
            lastLimit = OffSet + numberOfRows;
        } else if((OffSet + numberOfRows) >= listOfProposalWrapper.size()) {
            lastLimit = listOfProposalWrapper.size();
        }
        List<ProposalListWrapper> listOfProposalWrapperForLoading = new List<ProposalListWrapper>();
        for(Integer i = offSet; i < lastLimit; i++) {
            listOfProposalWrapperForLoading.add(listOfProposalWrapper[i]);
        }
        return listOfProposalWrapperForLoading;
    }
    /* 
     * This method will fetch opportunity details for flows 
	*/
    @AuraEnabled
    public static Opportunity getOpportunity(String oppId)
    {	
        Opportunity opportunityToReturn = [Select Id, Proposal_Documents__c, SharePoint_Sync__c, Conga_Status__c, StageName,Product_type__c 
                                           FROM Opportunity 
                                           WHERE Id =:oppId];
        return opportunityToReturn;
    }
        
    @TestVisible 
    public class ProposalListWrapper implements Comparable {
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled 
        public String fileUrl{get;set;}
        @AuraEnabled
        public DateTime ModifiedDate{get;set;}

        public Integer compareTo(Object compareTo) {
            ProposalListWrapper compareToEmp = (ProposalListWrapper)compareTo;
            if (ModifiedDate == compareToEmp.ModifiedDate) return 0;
            if (ModifiedDate < compareToEmp.ModifiedDate) return 1;
            return -1;        
        }
    }
}