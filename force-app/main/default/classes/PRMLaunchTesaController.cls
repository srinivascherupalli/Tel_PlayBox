/*********** 
 * Team : Hawaii
 * Description : Launch tesa from TPC using 'Launch TESA' button on Opportunity
 * Jira : P2OB-6450
 * Created Date : 10 October 2020
*****************/
public with sharing class PRMLaunchTesaController {
    
    //Variable to store custom metadata record
    //public static List<PRMLaunchTesaMetadata__mdt> tesaMetadata;
    
    //get metadata records
    private static List<PRMLaunchTesaMetadata__mdt> getValidData(){
        List<PRMLaunchTesaMetadata__mdt> tesaMetadata = new List<PRMLaunchTesaMetadata__mdt>();
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('PRMLaunchTesaMetadata__mdt')) + '\n ' +
                          ' FROM PRMLaunchTesaMetadata__mdt' ;
        tesaMetadata = Database.query(queryStr);
        return tesaMetadata;
    }
    
    //get boolean value of feature enabled or disabled from custom setting
    @AuraEnabled 
    public static Boolean checkFeatureEnabled(){
        Boolean disable = false;
        disable = PRM_Default__c.getInstance().EnablePartnerTesaLaunch__c;
        return disable;
	}
    
    //aura enabled method call from 'prmLaunchTesaFromOpportunity' lightning component
    @AuraEnabled 
    public static List<OppDataWrapper> getOpportunityData(String oppId){
        List<PRMLaunchTesaMetadata__mdt> tesaMetadata = getValidData();
        //wrapper class to store details of opportunity,custom metadata and error messages
        List<OppDataWrapper> wrapperList = new List<OppDataWrapper>();
        
        //if opportunity is present
        if(tesaMetadata != null && String.isNotBlank(oppId)){
            //Dynamic query from fields in custom metadata
            String query = 'SELECT Id,CIDN__c,Opportunity_Number__c, ';
            for(PRMLaunchTesaMetadata__mdt metadata : tesaMetadata){
                if(metadata.UserType__c == Userinfo.getUserType()){
                    query = query + (metadata.Field_Name__c != null ?  metadata.Field_Name__c + ',' : '');
                }
            }
            
            // Remove last comma
        	if (query.length() > 0) {
            	query = query.substring(0, query.length() - 1);
                query = query + ' From Opportunity where Id =: oppId';
            }
            
            Opportunity opp = Database.query(String.escapeSingleQuotes(query));
            
            PRMLaunchTesaMetadata__mdt mData = new PRMLaunchTesaMetadata__mdt();
            Map<id,List<String>> errorMap =new Map<id,List<String>>();
            Boolean isError = false;
            
            for(PRMLaunchTesaMetadata__mdt metadata : tesaMetadata){
                //check the type of user and get associated data from custom metadata
                if(metadata.UserType__c == Userinfo.getUserType()){
                    mData = metadata;
                    //check conditions from custom metadata record

                    if(metadata.Field_Values__c !=null && (String)opp.get(metadata.Field_Name__c) != null 	&& (metadata.Operator__c != null && metadata.Operator__c == 'contains' ? metadata.Field_Values__c.contains((String)opp.get(metadata.Field_Name__c)) : metadata.Field_Values__c.equals((String)opp.get(metadata.Field_Name__c))) && metadata.Error_Message__c != null){

                        if(errorMap.containsKey(opp.Id)){
                            errorMap.get(opp.Id).add(metadata.Error_Message__c);
                        }else{
                            errorMap.put(opp.Id,new List<String>{metadata.Error_Message__c});
                        }
                        isError = true;
                    }
                }
            }
            
            OppDataWrapper oppWrapper = new OppDataWrapper(errorMap.get(opp.Id),isError,opp,mData);
            wrapperList.add(oppWrapper);
        }
        return wrapperList;
    }
    
    //Wrapper class to store opportunity,error,metadata details
    public class OppDataWrapper{
        //variable to store error messages
        @AuraEnabled
        public List<String> errorMsgs{get;set;}
        //Boolean variable to check if error message is there
        @AuraEnabled
        public Boolean showError{get;set;}
        //Opportunity variable to store opportunity details
        @AuraEnabled
        public Opportunity oppInfo{get;set;}
        //Metadata variable to store metadata records
        @AuraEnabled
        public PRMLaunchTesaMetadata__mdt metaData{get;set;}
        
        //wrapper class constructor
        public OppDataWrapper(List<String> errorMsgs,Boolean showError,Opportunity oppInfo,PRMLaunchTesaMetadata__mdt metaData){
            this.errorMsgs = errorMsgs;
            this.showError = showError;
            this.oppInfo = oppInfo;
            this.metaData = metaData;
        }
    }
}