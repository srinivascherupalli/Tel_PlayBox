/*****************************************************************************
@Name : ProposalGenerationController
@Description : This class is helper class for ProposalGenerationLoadBasket,ProposalGenerationLoadTemplate LWC component. 
@Created by : Ravi Dodiya as part of P2OB-13423 and P2OB-13422.
@Description : Logic to get product basket details for given Opportunity Id and to get  available template details.
*******************************************************************************/
public class ProposalGenerationController {
    
    /* 
     * This method will fetch all the available product basket for given opportunity , 
     * as per the proposal generation requirement 'Closed Won','Cancelled','Draft' stage should not be available 
	*/
    @AuraEnabled(cacheable=true)
    public static List<cscfga__Product_Basket__c> getProductBasket(Id OpptyId){

             cscfga__Product_Basket__c[] OpportunityBasket = [select Id,name,csordtelcoa__Basket_Stage__c,csbb__Synchronised_With_Opportunity__c,CreatedDate,Primary_Basket__c from cscfga__Product_Basket__c where csordtelcoa__Basket_Stage__c not in ('Closed Won','Cancelled','Draft') and cscfga__Opportunity__c =: OpptyId] ;
        return OpportunityBasket;
    }
    
    /* 
     * This method will fetch available Template for Proposal Generation. 
     * Available Templates are setup inside Custom MetaData : Proposal_Templates__mdt 
	*/
    
    public static Set<String> filterProposalTemplate(String basketId) {
    	List<cscfga__Attribute__c> listOfAttribute =  [SELECT cscfga__Value__c 
                                                       FROM cscfga__Attribute__c 
                                                       WHERE Name = 'Product_SC' 
                                                       AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id =: basketId];
		Set<String> setOfProductIds = new Set<String>();
		for (cscfga__Attribute__c att : listOfAttribute){
	 		setOfProductIds.add(att.cscfga__Value__c);
		} 
		List<cspmb__Price_Item__c> listOfPriceItem = [select Id, Domain__c, Product_Family__c from cspmb__Price_Item__c WHERE Id IN :setOfProductIds];
        Set<String> setOfProposalToShow = new Set<String>();
        for(cspmb__Price_Item__c priceItem : listOfPriceItem) {
            if(priceItem.Domain__c == 'DATA & IP' && priceItem.Product_Family__c == 'ADAPTIVE NETWORKS') {
            	setOfProposalToShow.add('Adaptive Networks');
            } else if(priceItem.Domain__c == 'DATA & IP' && priceItem.Product_Family__c != 'ADAPTIVE NETWORKS') {
                setOfProposalToShow.add('Data and IP');
            } else if(priceItem.Domain__c == 'UNIFIED COMMUNICATIONS') {
                setOfProposalToShow.add('Unified Communications');
            }  else if(priceItem.Domain__c == 'MDN') { //added this else if block for MDN related to DIGI-4824
                setOfProposalToShow.add('MDN');
            }else {
                setOfProposalToShow.add('Multidomain');
                break;
            }
        }
        return setOfProposalToShow;
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<Proposal_Templates__mdt> getProposalTemplate(String basketId){
        System.debug(basketId);
        String queryFilter;
        Set<String> setOfProposalTemplate = filterProposalTemplate(basketId);
        if(setOfProposalTemplate != null && (setOfProposalTemplate.size() > 1 || setOfProposalTemplate.size() == 0)) {
        	queryFilter = '%Multidomain%';
        } else if(setOfProposalTemplate != null && setOfProposalTemplate.size() == 1) {
            for(string str : setOfProposalTemplate) {
            	queryFilter = '%' + str + '%';	    
            }
        }
        System.debug(queryFilter);
        List<Proposal_Templates__mdt> lisOfAvailableProposalDocument = [SELECT Id, DeveloperName,Template_Name__c,Domain__c 
                                                               			FROM Proposal_Templates__mdt
                                                                        WHERE Template_Name__c LIKE: queryFilter];
        System.debug(lisOfAvailableProposalDocument);
        return lisOfAvailableProposalDocument;
    }
    
}