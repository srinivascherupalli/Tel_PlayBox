public with sharing class PRMPartnerPlanNavigation {
    @AuraEnabled
    public static Boolean isPartnerLoggedIn(){
        return (UserInfo.getUserType() == 'PowerPartner');
    }

    @AuraEnabled
    public static ResponseWraper getPlanId(Id recId){
        // If current user is partner user fetch user account id
        ResponseWraper objResp = new ResponseWraper();
        if(UserInfo.getUserType() == 'PowerPartner'){
            list<User> lstUser = [Select Id
                                       , ContactId
                                       , Contact.AccountId 
                                       , Contact.Account.Name
                                 From User 
                                 Where Id =: UserInfo.getUserId()];
            if(!lstUser.isEmpty()){
                // if Partner Plan navigation menu is accessed recId will be null
                objResp.strPartnerAccountId = lstUser[0].Contact.AccountId;
                objResp.strPartnerAccountName = lstUser[0].Contact.Account.Name;
                if(recId != null){
                    objResp.strPlanId = recId;
                    objResp.blnRedirect = false;
                }
            }
            return returnPartnerPlanId(objResp);
        }else if(UserInfo.getUserType() != 'PowerPartner'
        && !String.valueOf(recId).startsWith('001')){
            // if non partner accesses Prev/Next FY quick action on Partner detail page return PartnerId
            objResp.blnRedirect = false;
            return getCurrentPlanDetails(recId, objResp);
        }else{
            objResp.strPartnerAccountId = recId;
            //objResp.blnRedirect = true;
            return returnPartnerPlanId(objResp);
        }
    } // end of getPlanId
    
    public static ResponseWraper returnPartnerPlanId(ResponseWraper objResp){
        // if recId is for partner fetch current partner plan detail
        ResponseWraper objRes = objResp;
        if(objResp.strPlanId == null){
            boolean blnPartnerPlanAccess = Schema.sObjectType.Partner_Plan__c.isAccessible();
            list<Partner_Plan__c> lstP = [Select Id
                                               , Partner_Account__c
                                               , Partner_Account__r.Name
                                               , Financial_Year__c
                                               , Current_FY__c
                                          From Partner_Plan__c
                                          where Partner_Account__c =: objResp.strPartnerAccountId
                                          and Current_FY__c = true
                                          limit 1];
            if(!lstP.isEmpty()){
                objRes.strPlanId = lstP[0].Id;
                objRes.strFinancialYear = lstP[0].Financial_Year__c;
                objRes.blnRedirect = true;
            }else{
                objRes.strPartnerAccountName = [Select Id, Name from Account where Id =:objResp.strPartnerAccountId].Name;
            }
        }else{
            objRes = getCurrentPlanDetails(objResp.strPlanId, objRes);
        }
        return objRes;
    } // end of returnPartnerPlanId
    
    public static ResponseWraper getCurrentPlanDetails(Id recId, ResponseWraper objResp){
        ResponseWraper objR = objResp;
        list<Partner_Plan__c> lstP = [Select Id
                                           , Partner_Account__c
                                           , Partner_Account__r.Name
                                           , Financial_Year__c
                                      From Partner_Plan__c 
                                      Where Id =: recId];
        objR.strPlanId = recId;
        objR.strPartnerAccountId = lstP[0].Partner_Account__c;
        objR.strPartnerAccountName = lstP[0].Partner_Account__r.Name;
        objR.strFinancialYear = lstP[0].Financial_Year__c;
        return objR;
    }

    @AuraEnabled
	public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if(FsMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        system.debug('*****result*****'+result);
        return '['+result+']';
    }

    @AuraEnabled
    public static String getRecords(String sObjectName, String parentFieldName, String parentRecordId
                                  , String fieldNameJson, String planId, String currentFY){
        List<sObject> lstResult = new List<sObject>();
        system.debug('fieldNameJson*****'+fieldNameJson);
        String result = '[]';
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();
            String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                
                query += ' WHERE ' + parentFieldName + ' =:parentRecordId';
                if(String.isNotBlank(planId)){
                    query += ' and Id !=:planId';
                }
                query += ' order by Financial_Year__c';
            }
            system.debug('***** dynamic query*****'+query);
            for(sObject s : Database.query(String.escapeSingleQuotes(query))){
                lstResult.add(s);
            }
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return result;
    }

    public class ResponseWraper{
        @AuraEnabled
        public String strPlanId {get;set;}
        @AuraEnabled
        public String strPartnerAccountId {get;set;}
        @AuraEnabled
        public String strFinancialYear {get;set;}
        @AuraEnabled
        public Boolean blnRedirect {get;set;}
        @AuraEnabled
        public String strPartnerAccountName {get;set;}
    }
}