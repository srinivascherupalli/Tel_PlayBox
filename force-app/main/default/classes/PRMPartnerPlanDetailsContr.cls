/*******************************************************************
* Team : Team Hawaii
* Jira No :  P2OB - 10459
* Description : Controller Class for prmPartnerPlanDetails Component
* Created Date : 03-November-2020
* Modified Date : NA
***********************************************************************/

public class PRMPartnerPlanDetailsContr {
    
    //Method to fetch record, populate wrapper and send to Component
	@AuraEnabled
    public static List<DetailWrapper> getRowData(String rowLabels, String recId, Boolean isCardView){
        List<String> rowApis = new List<String>();   
		List<DetailWrapper> rowDetails = new List<DetailWrapper>();
        String objectName = 'Partner_Plan__c';
        String financialYearField = 'Financial_Year__c';
        
        //Fetch Metadata for API and Label Mapping
        PRM_API_Row_Label_Mapping__mdt[] apiMdt = [SELECT MasterLabel, Field_API__c FROM PRM_API_Row_Label_Mapping__mdt 
                                                  WHERE Object_API_Name__c =:objectName];
        
        Map<String,String> apiToLabelMap = new Map<String,String>();
		
        //Put data to map (API to Label)
        for(PRM_API_Row_Label_Mapping__mdt m : apiMdt){
            apiToLabelMap.put(m.Field_API__c, m.MasterLabel);
        }
        
        //Split rowLabels received and construct dynamic query
        rowApis = rowLabels.split(',');
        rowApis.add(financialYearField);
        String query = 'Select ';
        for(String fieldApi : rowApis){
            query += fieldApi.trim() +',';
        }
        	
        query = query.removeEnd(',');
        query += ' FROM Partner_Plan__c WHERE Id = :recId';
        SObject partnerPlanDetails = Database.query(String.escapeSingleQuotes(query));
        //A map to filter out null value fields
        Map<String, Object> mapForNullCheck = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(partnerPlanDetails));
        //Populate the Wrapper Instances as per business logic
        for(String fieldApi : rowApis){
            String trimmedFieldApi = fieldApi.trim();
            DetailWrapper d = new DetailWrapper();
            d.rowValue = '';
            if(mapForNullCheck.containsKey(trimmedFieldApi)){
                d.rowLabel = apiToLabelMap.get(trimmedFieldApi);
                d.fieldApi = trimmedFieldApi;
            	if(!isCardView){
               		d.rowValue = String.valueOf(partnerPlanDetails.get(trimmedFieldApi));
           		 }
           		else if(isCardView){
                	d.rowValue = (String) partnerPlanDetails.get(trimmedFieldApi);
            	}
                rowDetails.add(d);
            } 
        }
        return rowDetails;
    }
    
    //Wrapper class structure to be returned
    public class DetailWrapper {
        @AuraEnabled
        public String rowLabel {get; set;}
        @AuraEnabled
        public String rowValue {get; set;}
        @AuraEnabled
        public String fieldApi {get; set;}
    }
}