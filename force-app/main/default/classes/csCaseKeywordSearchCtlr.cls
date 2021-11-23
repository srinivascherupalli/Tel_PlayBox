/**
* Author: Nilima Borse
* Team: Jaipur
* Sprint: 21.03
* JIRA Story: P2OB-10970
* Date: 22/02/2021 
* Description: This class will contains methods to search the custo metadata and to store recent search.
**/
public without sharing class csCaseKeywordSearchCtlr {
    public Static boolean isDefault= false;           

    /*
    Method Name:         getSerachResults
    Input Parameter:     String strSearchKeyword: this will contains the keyword to be search,
                         String strContext: this will give the context like mobile/laptop, String category: Selected type value                       
    Output Parameter:    cs_ResponseWrapper
    Description:         This method will search for the records based on searchkeyword and other required filters
    Reference:           JIRA Story: P2OB-10970
    */
    
    /*
    Jaipur :: Mofit Pathan
    Sprint & US: 21.09 & P2OB-15011
    Description: Bug-fix : Added String strRecordId paramter in getSearchResults method. This will contain RecordId based upon which object type will retrieved.
    */
    @AuraEnabled
    public Static cs_ResponseWrapper getSearchResults(String strSearchKeyword, String strContext, String category, String strRecordId) {
        cs_ResponseWrapper response = new cs_ResponseWrapper();
        List<string> searchHistoryList = new List<string>();
        string searchKeyword = '%' + strSearchKeyword + '%';
        List<Case_Types_Configuration__mdt> caseTypeRecords = new List<Case_Types_Configuration__mdt>(); 
        List<string> csAllProfileListLabel = (System.Label.csAllProfileList).split(',');
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        /* executing query twice on custom metadata because OR can’t be used as a compound filter when child filters are on two different columns. 
        https://dreamevent.secure.force.com/articleView?id=sf.custommetadatatypes_limitations.htm&type=5 */
        
        Id recordIdFromComp;
        String sObjName = '';
        if(strRecordId != null && strRecordId != ''){            
        	recordIdFromComp = strRecordId;
            sObjName = recordIdFromComp.getSObjectType().getDescribe().getName();
		}
		String objFilter = '%' + sObjName + '%';
        system.debug('@@objFilter'+objFilter);
        
        if(category == '' || category == 'All'){
            
            Map<String, Case_Types_Configuration__mdt> caseTypeRecordsForCategory = new  Map<String, Case_Types_Configuration__mdt> ();
            List<String> caseTypeRecordsForSort = new List<String>();
            for(Case_Types_Configuration__mdt caseConfig : [SELECT MasterLabel, Category__c, Screen_Flow__c ,Screen_Flow_Input__c, Type__c,Category_Description__c,
                                                            Context__c, Profile__c, sObject__c, Order__c
                                                            FROM Case_Types_Configuration__mdt 
                                                            WHERE Category__c LIKE :searchKeyword AND sObject__c LIKE : objFilter
                                                            ORDER BY Order__c, Type__c]){
                String mapKey =  caseConfig.Order__c +'-'+ caseConfig.Type__c;
                caseTypeRecordsForCategory.put(mapKey, caseConfig);
            }

            for(Case_Types_Configuration__mdt caseConfig : [SELECT MasterLabel, Category__c, Screen_Flow__c ,Screen_Flow_Input__c, Type__c,Category_Description__c,
                                                             Context__c, Profile__c, sObject__c, Order__c
                                                            FROM Case_Types_Configuration__mdt 
                                                            WHERE Category_Description__c LIKE :searchKeyword AND sObject__c LIKE : objFilter
                                                            ORDER BY Order__c, Type__c]){
                String mapKey =  caseConfig.Order__c +'-'+ caseConfig.Type__c;
                caseTypeRecordsForCategory.put(mapKey, caseConfig);
            }
            caseTypeRecordsForSort.addAll(caseTypeRecordsForCategory.keySet());    
            //now sort them
            caseTypeRecordsForSort.sort();

            for(String order : caseTypeRecordsForSort)
            {
                Case_Types_Configuration__mdt caseConfigMdt = caseTypeRecordsForCategory.get(order);   
                caseTypeRecords.add(caseConfigMdt);
            }  
            System.debug('caseTypeRecords>>>'+caseTypeRecords);          

        }else{
            Map<String, String> typePicklistMap = new Map<String, String>();
                List<Schema.PicklistEntry> picklistValues = Case_Types_Configuration__mdt.Type__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry pe: picklistValues) {
                    typePicklistMap.put(pe.getLabel(), pe.getValue());
                }
            String typeLabelValue = typePicklistMap.get(category); 
            Map<decimal, Case_Types_Configuration__mdt> caseTypeRecordsForCategory = new  Map<decimal, Case_Types_Configuration__mdt> ();
            List<decimal> caseTypeRecordsForSort = new List<decimal>();
            for(Case_Types_Configuration__mdt caseConfig : [SELECT MasterLabel, Category__c, Screen_Flow__c ,Screen_Flow_Input__c, Type__c,Category_Description__c,
                                                            Context__c, Profile__c, sObject__c, Order__c
                                                            FROM Case_Types_Configuration__mdt 
                                                            WHERE Category__c LIKE :searchKeyword AND Type__c =: typeLabelValue ORDER BY Order__c]){
                caseTypeRecordsForCategory.put(caseConfig.Order__c, caseConfig);
            }
            
            for(Case_Types_Configuration__mdt caseConfig : [SELECT MasterLabel, Category__c, Screen_Flow__c ,Screen_Flow_Input__c, Type__c,Category_Description__c,
                                                             Context__c, Profile__c, sObject__c, Order__c
                                                            FROM Case_Types_Configuration__mdt 
                                                            WHERE Category_Description__c LIKE :searchKeyword AND Type__c =: typeLabelValue ORDER BY Order__c]){
                caseTypeRecordsForCategory.put(caseConfig.Order__c, caseConfig);
            }

            caseTypeRecordsForSort.addAll(caseTypeRecordsForCategory.keySet());    
            //now sort them
            caseTypeRecordsForSort.sort();
            for(decimal order : caseTypeRecordsForSort)
            {
                Case_Types_Configuration__mdt caseConfigMdt = caseTypeRecordsForCategory.get(order);   
                caseTypeRecords.add(caseConfigMdt);
            }
            System.debug('caseTypeRecords>>>'+caseTypeRecords);   
        }
        Set<string> strContextConfig = new Set<String>();
        if(strContext == 'Large'){
            strContext = 'Desktop';
        }else if(strContext == 'Small'){
            strContext = 'Mobile';
        }
        strContextConfig.add(strContext);

        if(Network.getNetworkId() != null ){
            strContextConfig.add('Community');   
        }

        Map<String,Case_Types_Configuration__mdt> caseTypeRecordsFilter = new Map<String, Case_Types_Configuration__mdt>();  
        
        //Sort the result based on the context  
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

            String contextText = caseConfigType.Context__c;
            List<string> strContextConfigSet  = contextText.split(', ');
            for(String context : strContextConfig){
                if(strContextConfigSet.contains(context)  && csAllProfileList.contains(profileName)){
                    if(!caseTypeRecordsFilter.containsKey(caseConfigType.Category__c)){
                        caseTypeRecordsFilter.put(caseConfigType.Category__c, caseConfigType);
                    }
                }
            }
            
        }
        response.success = true;  
        response.caseTypeRecords = caseTypeRecordsFilter.values();
        system.debug('caseTypeRecords++++'+caseTypeRecords);
        system.debug('caseTypeRecords++++'+caseTypeRecordsFilter);
        if((caseTypeRecords != null && !caseTypeRecords.isEmpty()) || strSearchKeyword == ''){
            searchHistoryList = csCaseKeywordSearchCtlr.setSearchHistory(strSearchKeyword, caseTypeRecordsFilter);
            response.searchHistoryList = searchHistoryList;
        }else{
            searchHistoryList = csCaseKeywordSearchCtlr.setSearchHistory('', caseTypeRecordsFilter);
            response.searchHistoryList = searchHistoryList;
        }
        response.isDefault = isDefault;        
        return response;
    }


    /*
    Method Name:         getSerachResults
    Input Parameter:     String strSearchKeyword: this will contains the keyword to be search,
                         String strContext: this will give the context like mobile/laptop, String category: Selected type value                       
    Output Parameter:    cs_ResponseWrapper
    Description:         This method will save the recent search based on criteria
    Reference:           JIRA Story: P2OB-10970
    */
    public Static List<string> setSearchHistory(String strCategory, Map<String,Case_Types_Configuration__mdt> caseTypeRecordsFilter) {
        
        List<string> searchHistoryList = new List<string>();
        boolean isUpdate = false;
        ss_Case_Search__c[] searchHistoryForUser = [Select id,User__c, Attachments__c, Search_History__c from ss_Case_Search__c where User__c =: userinfo.getuserId()] ;    
        
        if(searchHistoryForUser.size() > 0){

            //delete files functionality
            String attachmentIds = searchHistoryForUser[0].Attachments__c;
            System.debug('searchHistoryForUser ' +searchHistoryForUser);
            System.debug('strCategory ' +strCategory);
            if(attachmentIds !='' && attachmentIds !=null){
                csFileUploadMetadataHandler.deleteUnattachedFiles(attachmentIds);
            }
            

            String searchHistory = searchHistoryForUser[0].Search_History__c;

            system.debug('searchHistory***'+searchHistory);
            searchHistoryList  = searchHistory.split(',');
            system.debug('searchHistoryList***'+searchHistoryList);
            if(strCategory == '' && searchHistoryList.size() >= 5 ) {
                system.debug('GREATER THAN 5***');
                isDefault = false;
                return searchHistoryList;
            }else if(strCategory == '' ){
                system.debug('CATEGOR BLANK***');
                searchHistoryList = (System.Label.csDefaultTopCategories).split(',');
                isDefault = true;
                return searchHistoryList;
            }else{
                system.debug('DELETE this later FINAL ELSE*****');
            }
            /*Integer searchCount = 0;

            for(String searchResult : caseTypeRecordsFilter.keySet()){
                if(!searchHistoryList.contains(searchResult) && searchCount < 1 ){
                    if(searchHistoryList.size() < 5 ){
                        searchHistoryList.add(searchResult);
                    }else if (searchHistoryList.size() >= 5){
                        String searchHistorylst = searchHistoryList.remove(0);
                        searchHistoryList.add(searchResult);
                    }
                    ss_Case_Search__c searchRecord = new ss_Case_Search__c();
                    String allstring = string.join(searchHistoryList,',');
                    searchRecord.Search_History__c = allstring;
                    searchRecord.User__c = userinfo.getuserId(); 
                    searchRecord.Id =  searchHistoryForUser[0].Id;
                    searchCount++;
                    update searchRecord;
                    break;
                }               

            }*/

            
        } else {
            System.debug('strCategory ' +strCategory);
            if(strCategory == '') {
                searchHistoryList = (System.Label.csDefaultTopCategories).split(',');
                isDefault = true;
                return searchHistoryList;
            }

            /*ss_Case_Search__c searchRecord = new ss_Case_Search__c();

            List<String> keys = new List<String>(caseTypeRecordsFilter.keySet());
            string validSearch = keys[0];
            searchHistoryList.add(validSearch);
            String allstring = string.join(searchHistoryList,',');
            searchRecord.Search_History__c = allstring;
            searchRecord.User__c = userinfo.getuserId(); 

            insert searchRecord;   */

        }    
        
        
        //this should be after metadata insertion
		if(searchHistoryList.size() < 5 ) {
            searchHistoryList = (System.Label.csDefaultTopCategories).split(',');
            isDefault = true;
            return searchHistoryList;
        }
        return searchHistoryList; 
    }

    /*
    Wrapper class Name:  cs_ResponseWrapper
    Description:         This class will provide the variables which needed on LWC comp
    Reference:           JIRA Story: P2OB-10399
    */
    public class cs_ResponseWrapper{
        @AuraEnabled
        public List<Case_Types_Configuration__mdt> caseTypeRecords {get;set;}
        @AuraEnabled
        public Map<String, Integer> mapTypeCount {get;set;}
        @AuraEnabled
        public String strError {get;set;}  
        @AuraEnabled
        public boolean success {get;set;}   
        @AuraEnabled
        public List<string> searchHistoryList {get;set;} 
        @AuraEnabled
        public boolean isDefault {get;set;} 
    }
}