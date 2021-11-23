/*******************************************************************
* Team : Team Hawaii
* Jira No :  P2OB - 9096
* Description : Controller Class for Event Details Component
* Created Date : 29-August-2020
* Modified Date : NA
***********************************************************************/

public with sharing class PRMEventDetailsContr {
    
    public class DetailWrapper {
        @AuraEnabled
        public SObject articleDetail {get; set;}
        @AuraEnabled
        public List<FieldWrapper> fieldDetailsList {get; set;}
        @AuraEnabled
        public String userTimeZone {get; set;}
        
        public DetailWrapper() {
            if(articleDetail == null){
                articleDetail = new Knowledge__kav();
            }
        }
    }
    
    //Sub-Wrapper Class to be used in main wrapper
    public class FieldWrapper {
        @AuraEnabled
        public String fieldLabel {get; set;}
        @AuraEnabled
        public List<String> fieldAPINames {get;set;}
        @AuraEnabled
        public Boolean isDateFormatRequired {get;set;}
        @AuraEnabled
        public Boolean isButton {get; set;}
    }
    
    //Added for P2OB-9096
    @AuraEnabled(cacheable=true)
    public static DetailWrapper getArticleDetail(String articleDetailId, String sObj){
        if(sObj==null){
            sObj = 'Knowledge__kav';
        }
        DetailWrapper adWrapper = new DetailWrapper();
        
        String query = 'SELECT ';
        List<FieldWrapper> fieldDetails = new List<FieldWrapper>();
              
        //Append fields in query and populate the wrapper
        for(PrmEventDetail__mdt f : [Select MasterLabel, Field_Label__c , Field_API__c, Sobject__c , Use_as_a_button__c,
                                     Date_Formatting_Required__c, Display_Order__c from PrmEventDetail__mdt 
                                     Where Sobject__c =: sObj Order by Display_Order__c]){
            FieldWrapper fWrapper = new FieldWrapper(); 
            List<String> allApi = f.Field_API__c.split(',');
            for(String s:allApi){
                query = query + s + ',';
            }
                                         
            fWrapper.fieldAPINames = allApi; 
            fWrapper.fieldLabel = f.Field_Label__c;                           
            fWrapper.isDateFormatRequired = f.Date_Formatting_Required__c;
            fWrapper.isButton = f.Use_as_a_button__c; 
            adWrapper.userTimeZone = UserInfo.getTimeZone().toString();              
            fieldDetails.add(fWrapper);
        }
        if(sObj == 'Knowledge__kav'){ // getting Data Category also if knowledge Object
            query += 'Featured_Image__c, (SELECT Id, toLabel(DataCategoryName) FROM DataCategorySelections) ' ;
        }else{
            query = query.removeEnd(',');
        }
        query = query + ' FROM ' + sObj + ' WHERE Id = :articleDetailId ';
        
        if(articleDetailId != null){
            for(SObject s : Database.query(String.escapeSingleQuotes(query))){
                adWrapper.articleDetail = s;
                adWrapper.fieldDetailsList = fieldDetails;
            }
        }else{
            adWrapper.fieldDetailsList = fieldDetails;
        }
        return adWrapper;
        
    }
}