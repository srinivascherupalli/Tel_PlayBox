/**
* Author: Nilima Borse
* Team: Jaipur
* Sprint: 21.03
* JIRA Story: P2OB-10399
* Date: 18/02/2021 
* Description: This class will collect all configuration metadata which need to be shown on get support screen.
**/
public with sharing class csGetCaseConfigurationsCtrl {
    /*
    Method Name:         getGetCaseConfigurations
    Input Parameter:     String strContext: this will give the context like mobile/laptop, String strRecordId: Id of record                       
    Output Parameter:    cs_ResponseWrapper
    Description:         This method will query and filter out the records which needs to be shown on new ux.
    Reference:           JIRA Story: P2OB-10399
    */
   
    @AuraEnabled(cacheable=true)
    public static cs_ResponseWrapper getGetCaseConfigurations(String strContext,  String strRecordId, String strPageType) {

        Id recordIdFromComp;
        String sObjName = '';
        if(strRecordId != null && strRecordId != ''){            
        	recordIdFromComp = strRecordId;
            sObjName = recordIdFromComp.getSObjectType().getDescribe().getName();

        }else{
            sObjName = strPageType;

        }    
        String objFilter = '%' + sObjName + '%';
        cs_ResponseWrapper response = new cs_ResponseWrapper();
        Map<String, List<String>> mapTypetoSubTypes = new  Map<String, List<String>>();
        Map<String, Integer> mapTypeCount = new  Map<String, Integer>();  
        Map<String, String> mapSubTypeFlowInput = new  Map<String, String>();  
        Map<String, String> mapSubTypeDescription = new  Map<String, String>();  
        Map<String, String> mapSubTypeFlowName = new  Map<String, String>();  
        List<string> csAllProfileListLabel = (System.Label.csAllProfileList).split(',');
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        Integer count = 0 ;
        Set<string> strContextConfig = new Set<String>();
        if(strContext == 'Large'){
            strContext = 'Desktop';
        }else if(strContext == 'Small'){
            strContext = 'Mobile';
        }
        strContextConfig.add(strContext);

        if (Schema.sObjectType.Case.isCreateable()) {        
            if(Network.getNetworkId() != null ){
                strContextConfig.add('Community');   
            }
            
            Map<String, String> typePicklistMap = new Map<String, String>();
            List<Schema.PicklistEntry> picklistValues = Case_Types_Configuration__mdt.Type__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry pe: picklistValues) {
                typePicklistMap.put(pe.getValue(), pe.getLabel());
            }
            
            List<Case_Types_Configuration__mdt> caseTypeRecords = [SELECT MasterLabel, Category_Description__c, Category__c, Screen_Flow__c ,Screen_Flow_Input__c, Type__c,
                                                            Context__c, Profile__c, sObject__c 
                                                            FROM Case_Types_Configuration__mdt 

                                                            WHERE sObject__c LIKE : objFilter ORDER BY MasterLabel,Order__c];

                                                            
            
            Map<String,Case_Types_Configuration__mdt> caseTypeRecordsFilter = new Map<String, Case_Types_Configuration__mdt>();
            
            for(Case_Types_Configuration__mdt caseConfigType : caseTypeRecords){
                List<string> csAllProfileList = new List<string>();
                List<string> csAllProfileListConfig = (caseConfigType.Profile__c).split(',');
                csAllProfileList.addAll(csAllProfileListLabel);
                if(csAllProfileListConfig.size() > 1 ){
                    for(String profile : csAllProfileListConfig){
                        if(profile != 'csAllProfileList'){
                            csAllProfileList.add(profile);
                        }
                    }
                }
                System.debug('csAllProfileList ++++++++'+csAllProfileList);
                String contextText = caseConfigType.Context__c;
                List<string> strContextConfigSet  = contextText.split(', ');
                for(String context : strContextConfig){
                    if(strContextConfigSet.contains(context) && csAllProfileList.contains(profileName)){
                        if(!caseTypeRecordsFilter.containsKey(caseConfigType.Category__c)){
                            caseTypeRecordsFilter.put(caseConfigType.Category__c, caseConfigType);
                        }
                    }
                }
                
            }
            
            
            for(Case_Types_Configuration__mdt caseConfigType : caseTypeRecordsFilter.values()){
                count++;
                if(!mapTypetoSubTypes.containsKey('All')){
                    mapTypetoSubTypes.put('All', new List<String>());
                    mapTypeCount.put('All',  0);
                }

                String typeLabel = typePicklistMap.get(caseConfigType.Type__c);
                if(!mapTypetoSubTypes.containsKey(typeLabel)){
                    mapTypetoSubTypes.put(typeLabel, new List<String>{caseConfigType.Category__c});
                    mapTypetoSubTypes.get('All').add(caseConfigType.Category__c);
                    mapTypeCount.put(typeLabel,1);
                    if(mapTypetoSubTypes.containsKey('All') && mapTypeCount.get('All') == 0){
                        mapTypeCount.put('All', 1 );
                    }else{
                        mapTypeCount.put('All', mapTypeCount.get('All') + 1 );
                    }
                }else{
                    mapTypetoSubTypes.get(typeLabel).add(caseConfigType.Category__c);
                    mapTypetoSubTypes.get('All').add(caseConfigType.Category__c);   
                    mapTypeCount.put(typeLabel, mapTypeCount.get(typeLabel) + 1 );
                    mapTypeCount.put('All', mapTypeCount.get('All') + 1 );
                }

                if(!mapSubTypeFlowInput.containsKey(caseConfigType.Category__c)){
                    mapSubTypeFlowInput.put(caseConfigType.Category__c, caseConfigType.Screen_Flow_Input__c);
                }

                if(!mapSubTypeDescription.containsKey(caseConfigType.Category__c)){
                    mapSubTypeDescription.put(caseConfigType.Category__c, caseConfigType.Category_Description__c);
                }

                if(!mapSubTypeFlowName.containsKey(caseConfigType.Screen_Flow_Input__c)){
                    mapSubTypeFlowName.put(caseConfigType.Screen_Flow_Input__c, caseConfigType.Screen_Flow__c);
                }
            }
            if(caseTypeRecordsFilter == null || caseTypeRecordsFilter.isEmpty()){
                response.strError = System.Label.csDoNotHaveAccess;
            }
            response.totalCount = count;
            response.success = true;  
            response.mapTypeCount = mapTypeCount;
            response.mapSubTypeFlowInput = mapSubTypeFlowInput;
            response.mapSubTypeDescription = mapSubTypeDescription;
            response.mapSubTypeFlowName = mapSubTypeFlowName;
            response.mapTypetoSubTypes = new Map<String, List<String>>(mapTypetoSubTypes);
        }
        else{
            response.success = false;  
            response.strError = System.Label.csDoNotHaveAccess;
        }
        return response;
    }

    /*
    Method Name:         getGetCaseConfigurations
    Input Parameter:     String strContext: this will give the context like mobile/laptop, String strRecordId: Id of record                       
    Output Parameter:    cs_ResponseWrapper
    Description:         This method will query and filter out the records which needs to be shown on new ux.
    Reference:           JIRA Story: P2OB-10399
    */
    @AuraEnabled(cacheable=false)
    public static Opportunity getGetOpportunity(string strOpportunity){
        return [Select id, AccountId From Opportunity where id =: strOpportunity];
    }
    
    /*

    Method Name:         setSearchHistory
    Input Parameter:     String searchKeyword: this will give the search value                       
    Output Parameter:    NA
    Description:         This method set the valid search
    Reference:           JIRA Story: P2OB-13761
    */
    @AuraEnabled(cacheable=false)
    public static void setSearchHistory(string searchKeyword){
        List<string> searchHistoryList = new List<string>();
        ss_Case_Search__c[] searchHistoryForUser = [Select id,User__c, Attachments__c, Search_History__c from ss_Case_Search__c where User__c =: userinfo.getuserId()] ;    
        if(searchHistoryForUser.size() > 0){
            String searchHistory = searchHistoryForUser[0].Search_History__c;
            system.debug('searchHistory*****'+searchHistory);
            searchHistoryList  = searchHistory.split(',');
            system.debug('searchHistoryList*****'+searchHistoryList+'*****'+searchKeyword);
            
            if(!searchHistoryList.contains(searchKeyword)){
                if(searchHistoryList.size() < 5 ){
                    searchHistoryList.add(searchKeyword);
                }else if (searchHistoryList.size() >= 5){
                    String searchHistorylst = searchHistoryList.remove(0);
                    searchHistoryList.add(searchKeyword);
                }
                ss_Case_Search__c searchRecord = new ss_Case_Search__c();
                String allstring = string.join(searchHistoryList,',');
                system.debug('alstring*****'+allstring);
                searchRecord.Search_History__c = allstring; 
                searchRecord.User__c = userinfo.getuserId(); 
                searchRecord.Id =  searchHistoryForUser[0].Id;
                update searchRecord;
            }
        }else{
            system.debug('searchKeyword ELSE PORtion*****'+searchKeyword);
            ss_Case_Search__c searchRecord = new ss_Case_Search__c();
            String allstring = searchKeyword;
            searchRecord.Search_History__c = searchKeyword;
            searchRecord.User__c = userinfo.getuserId(); 
            insert searchRecord;
        }
    }
    
    /*

    Wrapper class Name:  cs_ResponseWrapper
    Description:         This class will provide the variables which needed on LWC comp
    Reference:           JIRA Story: P2OB-10399
    */
    public class cs_ResponseWrapper{
        @AuraEnabled
        public Map<String, List<String>> mapTypetoSubTypes {get;set;}
        @AuraEnabled
        public Map<String, Integer> mapTypeCount {get;set;}
        @AuraEnabled
        public Map<String, String> mapSubTypeFlowInput {get;set;}         
         @AuraEnabled
        public Map<String, String> mapSubTypeFlowName {get;set;}
        @AuraEnabled
        public Map<String, String> mapSubTypeDescription {get;set;} 
        @AuraEnabled
        public Integer totalCount {get;set;}
        @AuraEnabled
        public String strFlowName {get;set;}
        @AuraEnabled
        public String strError {get;set;}  
        @AuraEnabled
        public boolean success {get;set;}    
    }

    //Shreyansh Sharma, Team Jaipur
    //P2OB-13643 Move Existing Opportunity Get Support to new UI/UX Opportunity Get Support
   
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getCaseValidations(String oppId, String flowName){ 
      
        Map<String,Object> results=new Map<String,Object>();
        if(oppId != NULL && flowName != NULL){
          
            if(flowName == 'CBSContract'){
                results =   csGetCaseValidationsHelper.existingCBSCaseContractValidation(oppId);
            }
            else if(flowName == 'CBSBilling'){
                results = csGetCaseValidationsHelper.existingCBSCaseValidation(oppId);
            }
            else if(flowName == 'CPE'){
                results = csGetCaseValidationsHelper.getProductDomain(oppId);
            }
			//Added by Sanjay Thakur as a part of P2OB-14486
    		//Adding validation for Presales type as per the Opportunity stages
            else if(flowName == 'Get Solution Support'){
                results = csGetCaseValidationsHelper.presalesOpportunityStageValidation(oppId);
                
            } 
           
           
        }    
        if(results != NULL){
            
            return results;
        }
        else{
           
            return NULL;
        }
    }
    

}