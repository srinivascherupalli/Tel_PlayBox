public class OrderSubmissionUtils {
        
    @TestVisible private static String REQ_FOR_ENRICHMENT_ATTR = 'Required_for_Fulfilment';
    @TestVisible private static String ENRICHMENT_ATTR_VALUE = 'Enrichment';
    @TestVisible private static String SUBMIT_ATTR_VALUE = 'Submit';
    @TestVisible private static Set<String> fulfilmentActions = new Set<String>{'Submit','Enrichment'};
     
    /*
    *   Given a basketId and a Attribute field value will drill down to the Attributes to findout if attributes
    *   that match that criteria have being populated   
    */
    public static List<String> isBeforeFulfilmentActivityCompleteByBasket(Id basketId, String fieldValue) {
        List<String> activityInCompleteAttrList = new List<String>();
        if(basketId == null || fieldValue == null || !fulfilmentActions.contains(fieldValue)) {
            return null;
        }
        
        List<cscfga__Attribute_Field__c> attributeFieldList = new List<cscfga__Attribute_Field__c>([SELECT Id, Name, cscfga__Value__c, cscfga__Attribute__r.Id, cscfga__Attribute__r.Name, cscfga__Attribute__r.cscfga__Value__c
   																				               FROM cscfga__Attribute_Field__c
																				               WHERE cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c = :basketId 
																				               AND Name = : REQ_FOR_ENRICHMENT_ATTR AND cscfga__Value__c = : fieldValue]);
		if(attributeFieldList.size() > 0) {
			activityInCompleteAttrList = activityCompleteEvaluation(attributeFieldList);
		}
        return activityInCompleteAttrList;
    }

    /*
    *   Given a order Id and a Attribute field value will drill down to the Attributes to findout if attributes
    *   that match that criteria have being populated    
    */
    public static List<String> isBeforeFulfilmentActivityCompleteByOrder(Id orderId, String fieldValue) {
        List<String> activityInCompleteAttrList = new List<String>();
        if(orderId == null || fieldValue == null || !fulfilmentActions.contains(fieldValue)) {
            return null;
        }
        
        Set<Id> prodConfigIds = new Set<Id>();
        List<csord__Service__c> serviceList = new List<csord__Service__c>([SELECT Id, Name, csordtelcoa__Product_Configuration__c
													                       FROM csord__Service__c
															               WHERE csord__Subscription__r.csord__Order__c = :orderId]);
        System.debug('ServiceList: ' + serviceList);
		for(csord__Service__c srv : serviceList) {
			prodConfigIds.add(srv.csordtelcoa__Product_Configuration__c);
		}
		
		System.debug('ProdConfigIds: ' + prodConfigIds);
		
		if(prodConfigIds.size() > 0) {
	        List<cscfga__Attribute_Field__c> attributeFieldList = new List<cscfga__Attribute_Field__c>([SELECT Id, Name, cscfga__Value__c, cscfga__Attribute__r.Id, cscfga__Attribute__r.Name, cscfga__Attribute__r.cscfga__Value__c
	   																				               FROM cscfga__Attribute_Field__c
																					               WHERE cscfga__Attribute__r.cscfga__Product_Configuration__c IN :prodConfigIds 
																					               AND Name = : REQ_FOR_ENRICHMENT_ATTR AND cscfga__Value__c = : fieldValue]);
									               
			if(attributeFieldList.size() > 0) {
				activityInCompleteAttrList = activityCompleteEvaluation(attributeFieldList);
			}
		}
        return activityInCompleteAttrList;
    }
    
    private static List<String> activityCompleteEvaluation(List<cscfga__Attribute_Field__c> attrFldList) {
    	List<String> attrList = new List<String>();
    	
    	for(cscfga__Attribute_Field__c attrFld :  attrFldList) {
    		if(String.isBlank(attrFld.cscfga__Attribute__r.cscfga__Value__c)) {
    			attrList.add(attrFld.cscfga__Attribute__r.Name);
    		}
    	}
    	
    	return attrList;
    }

}