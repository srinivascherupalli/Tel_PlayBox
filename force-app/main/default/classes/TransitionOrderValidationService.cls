public with sharing class TransitionOrderValidationService {

	//accepts legacy DTO and returns set of candidate offers 
    public static Set<String> validateLegacyTransition(List<ReplicatorGetServiceDataObject.ServiceDTO> legacyService){
        Set<String> validTransitions = new Set<String>();
        Boolean isBB = false;
        Boolean isVoice = false;
        //TransitionOrderValidationConstants constants = 
        for(ReplicatorGetServiceDataObject.ServiceDTO srvc: legacyService){
            if(srvc.Service_Type == TransitionOrderValidationConstants.legacyTBB){ isBB = true;}
            if(srvc.Service_Type == TransitionOrderValidationConstants.legacyTBV){ isVoice = true;}
            if(srvc.Service_Type == TransitionOrderValidationConstants.legacyDOT){ isBB = true; isVoice = true;}
        }
        if(isBB && isVoice){validTransitions.add(TransitionOrderValidationConstants.DOT);} 
        else if(isBB){      validTransitions.add(TransitionOrderValidationConstants.TBB);
                            validTransitions.add(TransitionOrderValidationConstants.DOT);} 
        else if(isVoice){   validTransitions.add(TransitionOrderValidationConstants.TBV);
                            validTransitions.add(TransitionOrderValidationConstants.DOT);} 
        else{               validTransitions.add(TransitionOrderValidationConstants.ERROR);}

        return validTransitions;
    }
	
	public static Set<String> getEligibleOffersForLegacyServiceTransition(ReplicatorGetServiceDataObject legacyService){
        Set<String> validTransitions = new Set<String>();
        return validTransitions;
    }
	
	public static PageReference createSubscription(ReplicatorGetServiceDataObject legacyProd, String selectedOffer){
        PageReference pageRef = new PageReference('***partialURL***');
        return pageRef;
    }
}