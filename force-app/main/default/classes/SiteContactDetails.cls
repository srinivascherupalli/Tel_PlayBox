/**
*  Description of the purpose of the classthe method.
*  @name SiteContactDetails
*  @description               : This class is used  in SiteListView LWC to display the  Site and Contact Details 
* 							   Telstra Collaboration Professional Services Attachment
*  @param fulfillmentId       : FulfilmentlineItem Id.
*  @return 				 	 : Json String
*  @Jira Story Ref            : EDGE-120711
*  @createdBy  				 : Purushottama Sahu, Orlando
**/
public with sharing class SiteContactDetails {
    
    @AuraEnabled(cacheable = true)public static List<Map<String,String>>  getSiteContacts(String fulfillmentId) {
        String jsonStr = '';
        List<Map<String,String>> responseData= new List<Map<String,String>>();
        try {
        // Return null if there is no error, else it will return the error message
        
            FulfillmentLineItem__c fulfillment = [SELECT id, subscription__c,subscription__r.csordtelcoa__Product_Configuration__c FROM FulfillmentLineItem__c WHERE id = :fulfillmentId];
            System.debug('fulfillment : ' + fulfillment);
            
            Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap = cssmgnt.API_1.getOEData(new List<id>{fulfillment.subscription__r.csordtelcoa__Product_Configuration__c});        
            responseData=parseResponse(oeMap);
        } 
		catch(Exception e) {
			System.debug(Logginglevel.ERROR, e.getMessage());
			throw new AuraHandledException(e.getMessage());
		}
        return responseData;
    }
    
    public static List<Map<String,String>> parseResponse(Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap){
        
        List<String>  constData = new  List<String>{'Site','SiteName','ContactBusinessHours','ContactBusinessHoursName','SiteContactAfterHours','SiteContactAfterHoursName','TechnicalContact','TechnicalContactName','ProjectContact','ProjectContactName'};  
		List<Map<String,String>> oeConfigAttribuesList = new List<Map<String,String>>();
        
        for(Id configId : oeMap.keySet()){
            List<cssmgnt.ProductProcessingUtility.Configuration > configlst = new List<cssmgnt.ProductProcessingUtility.Configuration>();
            List<cssmgnt.ProductProcessingUtility.Component> objlst = oeMap.get(configId);
            
            for(cssmgnt.ProductProcessingUtility.Component comp : objlst){
                configlst.addAll(comp.configurations);
            }
            //Process each OE config 
            for(cssmgnt.ProductProcessingUtility.Configuration config : configlst){
                Map<String,String> oeConfigAttribues = new Map<String,String>();
                for(cssmgnt.ProductProcessingUtility.Attribute attr : config.attributes){
                    if(	constData.contains(attr.name)){
                        String keyName= (attr.name).equals('TechnicalContact')? 'ContactId' :(attr.name).equals('TechnicalContactName')? 'ContactName' :(attr.name).equals('ContactBusinessHours')? 'SiteContactBusinessHoursId' :(attr.name).equals('ContactBusinessHoursName')? 'SiteContactBusinessHoursName' :(attr.name).contains('Name')? attr.name:(attr.name+'Id');
                        oeConfigAttribues.put(keyName,attr.value);
                    }
                }
                if(oeConfigAttribues.size()>0)
                oeConfigAttribuesList.add(oeConfigAttribues);
            }
            
        }   
        return oeConfigAttribuesList;
    }
    
}